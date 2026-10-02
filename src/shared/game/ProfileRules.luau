--!strict

local CosmeticConfig = require("../config/CosmeticConfig")
local EconomyConfig = require("../config/EconomyConfig")

local ProfileRules = {}

local function ownedDefaults()
	local owned = {}
	local equipped = {}
	for category, definition in CosmeticConfig.Categories do
		owned[category] = { [definition.Default] = true }
		equipped[category] = definition.Default
	end
	return owned, equipped
end

function ProfileRules.defaultProfile()
	local owned, equipped = ownedDefaults()
	return {
		Version = EconomyConfig.ProfileVersion,
		Coins = 0,
		BestScore = 0,
		HighestPlatform = 0,
		Owned = owned,
		Equipped = equipped,
		Settings = {
			ReducedMotion = false,
			AudioEnabled = true,
		},
		TutorialComplete = false,
		DailyLastClaimDay = -1,
		DailyChallengeDay = -1,
		DailyChallengePerfects = 0,
		DailyChallengeRewarded = false,
		Achievements = {},
		Inventory = { Revives = 0 },
		Boosts = { WidePerfectUntil = 0, CoinBoostUntil = 0 },
		ProcessedReceipts = {},
	}
end

local function booleanMap(value)
	local result = {}
	if type(value) == "table" then
		for key, enabled in value do
			if type(key) == "string" and enabled == true then
				result[key] = true
			end
		end
	end
	return result
end

function ProfileRules.normalize(value)
	local profile = ProfileRules.defaultProfile()
	if type(value) ~= "table" then
		return profile
	end

	profile.Coins = math.max(0, math.floor(tonumber(value.Coins) or 0))
	profile.BestScore = math.max(0, math.floor(tonumber(value.BestScore) or 0))
	profile.HighestPlatform = math.max(0, math.floor(tonumber(value.HighestPlatform) or 0))
	profile.DailyLastClaimDay = math.floor(tonumber(value.DailyLastClaimDay) or -1)
	profile.DailyChallengeDay = math.floor(tonumber(value.DailyChallengeDay) or -1)
	profile.DailyChallengePerfects = math.max(0, math.floor(tonumber(value.DailyChallengePerfects) or 0))
	profile.DailyChallengeRewarded = value.DailyChallengeRewarded == true
	profile.Achievements = booleanMap(value.Achievements)
	profile.ProcessedReceipts = booleanMap(value.ProcessedReceipts)
	profile.TutorialComplete = value.TutorialComplete == true

	if type(value.Settings) == "table" then
		profile.Settings.ReducedMotion = value.Settings.ReducedMotion == true
		profile.Settings.AudioEnabled = value.Settings.AudioEnabled ~= false
	end
	if type(value.Inventory) == "table" then
		profile.Inventory.Revives = math.max(0, math.floor(tonumber(value.Inventory.Revives) or 0))
	end
	if type(value.Boosts) == "table" then
		profile.Boosts.WidePerfectUntil = math.max(0, math.floor(tonumber(value.Boosts.WidePerfectUntil) or 0))
		profile.Boosts.CoinBoostUntil = math.max(0, math.floor(tonumber(value.Boosts.CoinBoostUntil) or 0))
	end

	if type(value.Owned) == "table" then
		for category, definition in CosmeticConfig.Categories do
			profile.Owned[category] = booleanMap(value.Owned[category])
			profile.Owned[category][definition.Default] = true
		end
	end

	if type(value.Equipped) == "table" then
		for category, definition in CosmeticConfig.Categories do
			local itemId = value.Equipped[category]
			if type(itemId) == "string"
				and profile.Owned[category][itemId] == true
				and definition.Items[itemId] ~= nil
			then
				profile.Equipped[category] = itemId
			end
		end
	end

	profile.Version = EconomyConfig.ProfileVersion
	return profile
end

function ProfileRules.validatePurchase(profile, category: string, itemId: string): (boolean, string, number)
	local categoryConfig = CosmeticConfig.Categories[category]
	if not categoryConfig then
		return false, "invalid_category", 0
	end
	local item = categoryConfig.Items[itemId]
	if not item then
		return false, "unknown_item", 0
	end
	if profile.Owned[category][itemId] == true then
		return false, "already_owned", item.Price
	end
	if profile.Coins < item.Price then
		return false, "insufficient_coins", item.Price
	end
	return true, "ok", item.Price
end

function ProfileRules.validateEquip(profile, category: string, itemId: string): (boolean, string)
	local categoryConfig = CosmeticConfig.Categories[category]
	if not categoryConfig or categoryConfig.Items[itemId] == nil then
		return false, "unknown_item"
	end
	if profile.Owned[category][itemId] ~= true then
		return false, "not_owned"
	end
	return true, "ok"
end

return table.freeze(ProfileRules)
