--!strict

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local shared = ReplicatedStorage:WaitForChild("PerfectJump"):WaitForChild("Shared")
local EconomyConfig = require(shared.config.EconomyConfig)
local MonetizationConfig = require(shared.config.MonetizationConfig)
local RetentionConfig = require(shared.config.RetentionConfig)
local ProfileRules = require(shared.game.ProfileRules)
local ReceiptRules = require(shared.game.ReceiptRules)
local RetentionRules = require(shared.game.RetentionRules)
local RateLimiter = require(shared.security.RateLimiter)

local ProfileService = {}

local LOCK_SECONDS = 180
local store: any = nil
local storeOk, storeResult = pcall(function()
	return DataStoreService:GetDataStore(EconomyConfig.DataStoreName)
end)
if storeOk then
	store = storeResult
elseif not RunService:IsStudio() then
	warn("[Perfect Jump] DataStore unavailable")
end

local profiles: { [Player]: any } = {}
local dirty: { [Player]: boolean } = {}
local revisions: { [Player]: number } = {}
local metaChanged: RemoteEvent?

local purchaseLimiter = RateLimiter.new(0.25)
local equipLimiter = RateLimiter.new(0.15)
local dailyLimiter = RateLimiter.new(0.75)
local settingLimiter = RateLimiter.new(0.15)

local function keyFor(player: Player): string
	return ("u_%d"):format(player.UserId)
end

local function nowUnix(): number
	return os.time()
end

local function currentDay(): number
	return RetentionRules.dayKey(nowUnix())
end

local function decodeStored(value: any)
	if type(value) == "table" and type(value.Profile) == "table" then
		return ProfileRules.normalize(value.Profile), value.Lock
	end
	return ProfileRules.normalize(value), nil
end

local function wrapped(profile, keepLock: boolean?)
	return {
		Profile = ProfileRules.normalize(profile),
		Lock = if keepLock == false
			then nil
			else {
				JobId = game.JobId,
				ExpiresAt = nowUnix() + LOCK_SECONDS,
			},
	}
end

local function normalizeDaily(profile)
	local day, perfects, rewarded = RetentionRules.normalizeChallengeDay(
		profile.DailyChallengeDay,
		currentDay(),
		profile.DailyChallengePerfects,
		profile.DailyChallengeRewarded
	)
	profile.DailyChallengeDay = day
	profile.DailyChallengePerfects = perfects
	profile.DailyChallengeRewarded = rewarded
end

local function syncAttributes(player: Player, profile)
	normalizeDaily(profile)
	player:SetAttribute("PerfectJumpCoins", profile.Coins)
	player:SetAttribute("PerfectJumpBestScore", profile.BestScore)
	player:SetAttribute("PerfectJumpHighestPlatform", profile.HighestPlatform)
	player:SetAttribute("PerfectJumpTrail", profile.Equipped.Trails)
	player:SetAttribute("PerfectJumpLandingEffect", profile.Equipped.LandingEffects)
	player:SetAttribute("PerfectJumpPlatformTheme", profile.Equipped.PlatformThemes)
	player:SetAttribute("PerfectJumpEnvironmentTheme", profile.Equipped.EnvironmentThemes)
	player:SetAttribute("PerfectJumpReducedMotion", profile.Settings.ReducedMotion)
	player:SetAttribute("PerfectJumpAudioEnabled", profile.Settings.AudioEnabled)
	player:SetAttribute("PerfectJumpTutorialComplete", profile.TutorialComplete)
	player:SetAttribute("PerfectJumpRevives", profile.Inventory.Revives)
	player:SetAttribute("PerfectJumpWidePerfectUntil", profile.Boosts.WidePerfectUntil)
	player:SetAttribute("PerfectJumpCoinBoostUntil", profile.Boosts.CoinBoostUntil)
	player:SetAttribute("PerfectJumpProfileLoaded", true)
end

local function snapshot(profile)
	normalizeDaily(profile)
	return {
		Coins = profile.Coins,
		BestScore = profile.BestScore,
		HighestPlatform = profile.HighestPlatform,
		Owned = profile.Owned,
		Equipped = profile.Equipped,
		Settings = profile.Settings,
		TutorialComplete = profile.TutorialComplete,
		DailyClaimable = RetentionRules.canClaimDaily(profile.DailyLastClaimDay, currentDay()),
		DailyPerfects = profile.DailyChallengePerfects,
		DailyRequired = RetentionConfig.DailyChallenge.PerfectsRequired,
		DailyRewarded = profile.DailyChallengeRewarded,
		Achievements = profile.Achievements,
		Inventory = profile.Inventory,
		Boosts = profile.Boosts,
	}
end

local function emit(player: Player)
	local profile = profiles[player]
	if profile and metaChanged then
		syncAttributes(player, profile)
		metaChanged:FireClient(player, snapshot(profile))
	end
end

local function markDirty(player: Player)
	if profiles[player] then
		dirty[player] = true
		revisions[player] = (revisions[player] or 0) + 1
		syncAttributes(player, profiles[player])
		emit(player)
	end
end

local function loadPlayer(player: Player)
	if profiles[player] then
		return
	end

	if not store and RunService:IsStudio() then
		local profile = ProfileRules.defaultProfile()
		profiles[player] = profile
		dirty[player] = false
		revisions[player] = 0
		player:SetAttribute("PerfectJumpPersistenceHealthy", true)
		player:SetAttribute("PerfectJumpStudioMemoryProfile", true)
		syncAttributes(player, profile)
		emit(player)
		return
	end

	local loadedValue = nil
	local lockedByOther = false
	local lastError = nil
	for attempt = 1, EconomyConfig.LoadAttempts do
		local ok, result = pcall(function()
			return store:UpdateAsync(keyFor(player), function(oldValue)
				local profile, lock = decodeStored(oldValue)
				if
					type(lock) == "table"
					and type(lock.ExpiresAt) == "number"
					and lock.ExpiresAt > nowUnix()
					and lock.JobId ~= game.JobId
				then
					lockedByOther = true
					return nil
				end
				return wrapped(profile, true)
			end)
		end)
		if ok and result ~= nil then
			loadedValue = result
			lastError = nil
			break
		end
		if lockedByOther then
			break
		end
		lastError = result
		if attempt < EconomyConfig.LoadAttempts then
			task.wait(EconomyConfig.LoadRetrySeconds * attempt)
		end
	end

	if lockedByOther then
		player:Kick("Your Perfect Jump profile is active in another server. Please try again shortly.")
		return
	end
	if loadedValue == nil then
		if RunService:IsStudio() then
			warn(("[Perfect Jump] Studio profile fallback: %s"):format(tostring(lastError)))
			local profile = ProfileRules.defaultProfile()
			profiles[player] = profile
			dirty[player] = false
			revisions[player] = 0
			player:SetAttribute("PerfectJumpPersistenceHealthy", false)
			syncAttributes(player, profile)
			emit(player)
			return
		end
		player:Kick("Your Perfect Jump data could not be loaded safely. Please rejoin.")
		return
	end

	local profile = decodeStored(loadedValue)
	profiles[player] = profile
	dirty[player] = false
	revisions[player] = 0
	player:SetAttribute("PerfectJumpPersistenceHealthy", true)
	syncAttributes(player, profile)
	emit(player)
end

local function savePlayer(player: Player, releaseLock: boolean?): boolean
	local profile = profiles[player]
	if not profile then
		return true
	end
	if not store then
		if RunService:IsStudio() then
			dirty[player] = false
			return true
		end
		return false
	end

	local revisionAtStart = revisions[player] or 0
	local payload = ProfileRules.normalize(profile)
	local succeeded = false
	local ok, err = pcall(function()
		local result = store:UpdateAsync(keyFor(player), function(oldValue)
			local _storedProfile, lock = decodeStored(oldValue)
			if
				type(lock) == "table"
				and type(lock.ExpiresAt) == "number"
				and lock.ExpiresAt > nowUnix()
				and lock.JobId ~= game.JobId
			then
				return nil
			end
			return wrapped(payload, releaseLock ~= true)
		end)
		succeeded = result ~= nil
	end)
	if not ok or not succeeded then
		warn(("[Perfect Jump] profile save failed for %d: %s"):format(player.UserId, tostring(err)))
		return false
	end
	if (revisions[player] or 0) == revisionAtStart then
		dirty[player] = false
	end
	return true
end

local function awardAchievement(profile, achievementId: string): number
	if profile.Achievements[achievementId] then
		return 0
	end
	local definition = RetentionConfig.Achievements[achievementId]
	if not definition then
		return 0
	end
	profile.Achievements[achievementId] = true
	profile.Coins += definition.RewardCoins
	return definition.RewardCoins
end

function ProfileService.WaitForProfile(player: Player)
	local deadline = os.clock() + 12
	while player.Parent and not profiles[player] and os.clock() < deadline do
		task.wait()
	end
	return profiles[player]
end

function ProfileService.GetSnapshot(player: Player)
	local profile = profiles[player]
	return if profile then snapshot(profile) else nil
end

function ProfileService.IsWidePerfectActive(player: Player): boolean
	local profile = profiles[player]
	return profile ~= nil and profile.Boosts.WidePerfectUntil > nowUnix()
end

function ProfileService.RecordLanding(
	player: Player,
	grade: string,
	score: number,
	platformId: number,
	combo: number,
	competitive: boolean
)
	local profile = profiles[player]
	if not profile then
		return { Coins = 0, NewPB = false, AchievementCoins = 0, ChallengeCoins = 0 }
	end
	normalizeDaily(profile)

	local reward = if grade == "Perfect"
		then EconomyConfig.PerfectCoins
		elseif grade == "Good" then EconomyConfig.GoodCoins
		else EconomyConfig.SafeCoins
	if profile.Boosts.CoinBoostUntil > nowUnix() then
		reward *= MonetizationConfig.DeveloperProducts.CoinBoost15m.Multiplier
	end
	profile.Coins += reward

	local oldBest = profile.BestScore
	if competitive then
		profile.BestScore = math.max(profile.BestScore, math.max(0, math.floor(score)))
		profile.HighestPlatform = math.max(profile.HighestPlatform, math.max(0, math.floor(platformId)))
	end

	if not profile.TutorialComplete then
		profile.TutorialComplete = true
	end

	local achievementCoins = awardAchievement(profile, "first_jump")
	if grade == "Perfect" then
		profile.DailyChallengePerfects += 1
		achievementCoins += awardAchievement(profile, "first_perfect")
		if combo >= 5 then
			achievementCoins += awardAchievement(profile, "combo_5")
		end
	end
	if platformId >= 10 then
		achievementCoins += awardAchievement(profile, "height_10")
	end
	if platformId >= 25 then
		achievementCoins += awardAchievement(profile, "height_25")
	end

	local challengeCoins = 0
	if
		not profile.DailyChallengeRewarded
		and profile.DailyChallengePerfects >= RetentionConfig.DailyChallenge.PerfectsRequired
	then
		profile.DailyChallengeRewarded = true
		challengeCoins = RetentionConfig.DailyChallenge.RewardCoins
		profile.Coins += challengeCoins
	end

	markDirty(player)
	return {
		Coins = reward,
		NewPB = profile.BestScore > oldBest,
		AchievementCoins = achievementCoins,
		ChallengeCoins = challengeCoins,
		Competitive = competitive,
	}
end

function ProfileService.ClaimDaily(player: Player)
	local profile = profiles[player]
	if not profile then
		return { ok = false, reason = "profile_unavailable" }
	end
	local day = currentDay()
	if not RetentionRules.canClaimDaily(profile.DailyLastClaimDay, day) then
		return { ok = false, reason = "already_claimed", meta = snapshot(profile) }
	end
	profile.DailyLastClaimDay = day
	profile.Coins += EconomyConfig.DailyRewardCoins
	markDirty(player)
	return { ok = true, rewardCoins = EconomyConfig.DailyRewardCoins, meta = snapshot(profile) }
end

function ProfileService.PurchaseCosmetic(player: Player, category: string, itemId: string)
	local profile = profiles[player]
	if not profile then
		return { ok = false, reason = "profile_unavailable" }
	end
	local ok, reason, price = ProfileRules.validatePurchase(profile, category, itemId)
	if not ok then
		return { ok = false, reason = reason, meta = snapshot(profile) }
	end
	profile.Coins -= price
	profile.Owned[category][itemId] = true
	markDirty(player)
	return { ok = true, meta = snapshot(profile) }
end

function ProfileService.EquipCosmetic(player: Player, category: string, itemId: string)
	local profile = profiles[player]
	if not profile then
		return { ok = false, reason = "profile_unavailable" }
	end
	local ok, reason = ProfileRules.validateEquip(profile, category, itemId)
	if not ok then
		return { ok = false, reason = reason, meta = snapshot(profile) }
	end
	profile.Equipped[category] = itemId
	markDirty(player)
	return { ok = true, meta = snapshot(profile) }
end

function ProfileService.SetSetting(player: Player, setting: string, enabled: boolean)
	local profile = profiles[player]
	if not profile or type(enabled) ~= "boolean" then
		return { ok = false, reason = "invalid_setting" }
	end
	if setting == "ReducedMotion" then
		profile.Settings.ReducedMotion = enabled
	elseif setting == "AudioEnabled" then
		profile.Settings.AudioEnabled = enabled
	else
		return { ok = false, reason = "invalid_setting" }
	end
	markDirty(player)
	return { ok = true, meta = snapshot(profile) }
end

function ProfileService.ConsumeRevive(player: Player): boolean
	local profile = profiles[player]
	if not profile or profile.Inventory.Revives <= 0 then
		return false
	end
	profile.Inventory.Revives -= 1
	markDirty(player)
	return true
end

local function applyProduct(profile, productName: string, unixNow: number): boolean
	local product = MonetizationConfig.DeveloperProducts[productName]
	if not product then
		return false
	end
	if product.Grant == "Revive" then
		profile.Inventory.Revives = math.min(product.MaxInventory, profile.Inventory.Revives + 1)
	elseif product.Grant == "WidePerfect" then
		profile.Boosts.WidePerfectUntil = math.max(unixNow, profile.Boosts.WidePerfectUntil) + product.DurationSeconds
	elseif product.Grant == "CoinBoost" then
		profile.Boosts.CoinBoostUntil = math.max(unixNow, profile.Boosts.CoinBoostUntil) + product.DurationSeconds
	else
		return false
	end
	return true
end

function ProfileService.ProcessReceipt(player: Player, purchaseId: string, productName: string): boolean
	local profile = profiles[player]
	if not profile then
		return false
	end
	if profile.ProcessedReceipts[purchaseId] then
		return true
	end
	if not savePlayer(player, false) then
		return false
	end

	if not store then
		if not RunService:IsStudio() or not applyProduct(profile, productName, nowUnix()) then
			return false
		end
		profile.ProcessedReceipts[purchaseId] = true
		profile.ProcessedReceipts =
			ReceiptRules.trim(profile.ProcessedReceipts, MonetizationConfig.MaxProcessedReceipts)
		markDirty(player)
		return true
	end

	local updatedProfile = nil
	local ok, err = pcall(function()
		local result = store:UpdateAsync(keyFor(player), function(oldValue)
			local storedProfile, lock = decodeStored(oldValue)
			if
				type(lock) == "table"
				and type(lock.ExpiresAt) == "number"
				and lock.ExpiresAt > nowUnix()
				and lock.JobId ~= game.JobId
			then
				return nil
			end
			if storedProfile.ProcessedReceipts[purchaseId] then
				return wrapped(storedProfile, true)
			end
			if not applyProduct(storedProfile, productName, nowUnix()) then
				return nil
			end
			storedProfile.ProcessedReceipts[purchaseId] = true
			storedProfile.ProcessedReceipts =
				ReceiptRules.trim(storedProfile.ProcessedReceipts, MonetizationConfig.MaxProcessedReceipts)
			return wrapped(storedProfile, true)
		end)
		if result then
			updatedProfile = decodeStored(result)
		end
	end)
	if not ok or not updatedProfile then
		warn(("[Perfect Jump] receipt transaction failed for %d: %s"):format(player.UserId, tostring(err)))
		return false
	end

	profiles[player] = updatedProfile
	dirty[player] = false
	revisions[player] = (revisions[player] or 0) + 1
	syncAttributes(player, updatedProfile)
	emit(player)
	return true
end

function ProfileService.Save(player: Player): boolean
	return savePlayer(player, false)
end

function ProfileService.start()
	local remotes = ReplicatedStorage:WaitForChild("PerfectJumpRemotes")
	metaChanged = remotes:WaitForChild("MetaStateChanged") :: RemoteEvent
	local requestMeta = remotes:WaitForChild("RequestMetaState") :: RemoteFunction
	local purchaseCosmetic = remotes:WaitForChild("PurchaseCosmetic") :: RemoteFunction
	local equipCosmetic = remotes:WaitForChild("EquipCosmetic") :: RemoteFunction
	local claimDaily = remotes:WaitForChild("ClaimDaily") :: RemoteFunction
	local setSetting = remotes:WaitForChild("SetSetting") :: RemoteFunction

	requestMeta.OnServerInvoke = function(player)
		local profile = ProfileService.WaitForProfile(player)
		return if profile
			then { ok = true, meta = snapshot(profile) }
			else { ok = false, reason = "profile_unavailable" }
	end
	purchaseCosmetic.OnServerInvoke = function(player, category, itemId)
		if not purchaseLimiter:Allow(player) then
			return { ok = false, reason = "rate_limited", meta = ProfileService.GetSnapshot(player) }
		end
		return ProfileService.PurchaseCosmetic(player, category, itemId)
	end
	equipCosmetic.OnServerInvoke = function(player, category, itemId)
		if not equipLimiter:Allow(player) then
			return { ok = false, reason = "rate_limited", meta = ProfileService.GetSnapshot(player) }
		end
		return ProfileService.EquipCosmetic(player, category, itemId)
	end
	claimDaily.OnServerInvoke = function(player)
		if not dailyLimiter:Allow(player) then
			return { ok = false, reason = "rate_limited", meta = ProfileService.GetSnapshot(player) }
		end
		return ProfileService.ClaimDaily(player)
	end
	setSetting.OnServerInvoke = function(player, setting, enabled)
		if not settingLimiter:Allow(player) then
			return { ok = false, reason = "rate_limited", meta = ProfileService.GetSnapshot(player) }
		end
		return ProfileService.SetSetting(player, setting, enabled)
	end

	Players.PlayerAdded:Connect(loadPlayer)
	for _, player in Players:GetPlayers() do
		task.defer(loadPlayer, player)
	end

	Players.PlayerRemoving:Connect(function(player)
		savePlayer(player, true)
		purchaseLimiter:Forget(player)
		equipLimiter:Forget(player)
		dailyLimiter:Forget(player)
		settingLimiter:Forget(player)
		profiles[player] = nil
		dirty[player] = nil
		revisions[player] = nil
	end)

	task.spawn(function()
		while true do
			task.wait(EconomyConfig.AutosaveSeconds)
			for player in profiles do
				if dirty[player] then
					task.spawn(savePlayer, player, false)
				end
			end
		end
	end)

	game:BindToClose(function()
		for player in profiles do
			savePlayer(player, true)
		end
	end)
end

return ProfileService
