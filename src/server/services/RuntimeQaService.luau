--!strict

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local shared = ReplicatedStorage:WaitForChild("PerfectJump"):WaitForChild("Shared")
local CosmeticConfig = require(shared.config.CosmeticConfig)
local GameConfig = require(shared.config.GameConfig)
local RuntimeQaConfig = require(shared.config.RuntimeQaConfig)
local JumpRules = require(shared.game.JumpRules)
local LaunchRules = require(shared.game.LaunchRules)

local ProfileService = require(script.Parent.ProfileService)
local RoundService = require(script.Parent.RoundService)

local RuntimeQaService = {}

local results: { [string]: any } = {}

local function emit(name: string, passed: boolean, fields: any?)
	results[name] = {
		Passed = passed,
		Fields = fields or {},
	}
	print(
		("[PerfectJumpQA] %s %s %s"):format(
			if passed then "PASS" else "FAIL",
			name,
			HttpService:JSONEncode(fields or {})
		)
	)
end

local function check(name: string, condition: boolean, fields: any?)
	emit(name, condition, fields)
	assert(condition, ("Perfect Jump runtime QA failed: %s"):format(name))
end

local function waitUntil(predicate: () -> boolean, timeout: number): boolean
	local deadline = os.clock() + timeout
	repeat
		if predicate() then
			return true
		end
		task.wait(0.05)
	until os.clock() >= deadline
	return predicate()
end

local function waitReady(player: Player): boolean
	return waitUntil(function()
		local snapshot = RoundService.qaSnapshot(player)
		return snapshot ~= nil and snapshot.Phase == "Ready" and player.Character ~= nil
	end, 8)
end

local function run(player: Player)
	task.wait(RuntimeQaConfig.StartupDelaySeconds)

	check(
		"profile_loaded",
		waitUntil(function()
			return player:GetAttribute("PerfectJumpProfileLoaded") == true
		end, 8)
	)
	check("round_ready", waitReady(player))

	local initial = RoundService.qaSnapshot(player)
	check("initial_platform", initial.CurrentPlatformId == 0 and initial.TargetPlatformId == 1, initial)
	check("avatar_spawned", player.Character ~= nil and player.Character:FindFirstChild("HumanoidRootPart") ~= nil)

	local minimumSeconds = GameConfig.Charge.MinimumSeconds
	local midpointSeconds = (GameConfig.Charge.MinimumSeconds + GameConfig.Charge.MaximumSeconds) / 2
	local maximumSeconds = GameConfig.Charge.MaximumSeconds

	local function checkCharge(name: string, heldSeconds: number)
		local sample = RoundService.qaLaunch(player, heldSeconds)
		local chargePower = JumpRules.NormalizeCharge(heldSeconds)
		local expectedHorizontal = LaunchRules.HorizontalSpeed(chargePower)
		local expectedVertical = LaunchRules.VerticalSpeed(chargePower)
		check(
			name,
			sample ~= nil
				and math.abs(sample.HorizontalSpeed - expectedHorizontal) <= 0.001
				and math.abs(sample.VerticalSpeed - expectedVertical) <= 0.001,
			sample
		)
	end

	checkCharge("charge_min", minimumSeconds)
	checkCharge("charge_mid", midpointSeconds)
	checkCharge("charge_max", maximumSeconds)

	local baseline = RoundService.qaLaunch(player, midpointSeconds)
	local repeatCount = 0
	local maxHorizontalDelta = 0
	local maxVerticalDelta = 0
	if baseline then
		for _ = 1, RuntimeQaConfig.LaunchRepeatabilitySampleCount do
			local sample = RoundService.qaLaunch(player, midpointSeconds)
			if sample then
				repeatCount += 1
				maxHorizontalDelta =
					math.max(maxHorizontalDelta, math.abs(sample.HorizontalSpeed - baseline.HorizontalSpeed))
				maxVerticalDelta = math.max(maxVerticalDelta, math.abs(sample.VerticalSpeed - baseline.VerticalSpeed))
			end
		end
	end
	check(
		"launch_repeatability_100",
		baseline ~= nil
			and repeatCount == RuntimeQaConfig.LaunchRepeatabilitySampleCount
			and maxHorizontalDelta <= 0.001
			and maxVerticalDelta <= 0.001,
		{
			Samples = repeatCount,
			MaxHorizontalDelta = maxHorizontalDelta,
			MaxVerticalDelta = maxVerticalDelta,
		}
	)

	local function checkLandingGrade(name: string, centerDistance: number, expectedGrade: string)
		local accepted, grade = RoundService.qaLand(player, centerDistance)
		local snapshot = RoundService.qaSnapshot(player)
		if expectedGrade == "Miss" then
			check(name, accepted == false and grade == expectedGrade and snapshot.Phase == "GameOver", {
				Grade = grade,
				Phase = snapshot.Phase,
			})
			return
		end

		check(name, accepted == true and grade == expectedGrade, {
			Grade = grade,
			Phase = snapshot.Phase,
		})
		check(name .. "_ready", waitReady(player))
	end

	checkLandingGrade("landing_grade_perfect", 0, "Perfect")
	checkLandingGrade(
		"landing_grade_good",
		(GameConfig.Landing.PerfectRadius + GameConfig.Landing.GoodRadius) / 2,
		"Good"
	)
	checkLandingGrade("landing_grade_safe", GameConfig.Landing.GoodRadius + 0.5, "Safe")
	checkLandingGrade("landing_grade_miss", GameConfig.Platform.InitialWidth, "Miss")
	check("landing_grade_miss_retry", RoundService.qaRetry(player))
	check("landing_grade_miss_retry_ready", waitReady(player))

	local perfectCount = 0
	for index = 1, RuntimeQaConfig.LandingSampleCount do
		check(("landing_%03d"):format(index), RoundService.qaLand(player, 0), { Index = index })
		check(
			("ready_after_landing_%03d"):format(index),
			waitUntil(function()
				local snapshot = RoundService.qaSnapshot(player)
				return snapshot ~= nil and snapshot.Phase == "Ready"
			end, 2)
		)
		perfectCount += 1
	end

	local afterClimb = RoundService.qaSnapshot(player)
	check("long_climb_height", afterClimb.CurrentPlatformId == RuntimeQaConfig.LandingSampleCount, afterClimb)
	check("perfect_combo_progresses", afterClimb.Combo >= RuntimeQaConfig.LandingSampleCount, {
		Combo = afterClimb.Combo,
	})
	check(
		"pb_progresses",
		(player:GetAttribute("PerfectJumpHighestPlatform") or 0) >= RuntimeQaConfig.LandingSampleCount,
		{
			HighestPlatform = player:GetAttribute("PerfectJumpHighestPlatform"),
		}
	)

	ProfileService.qaGrantCoins(player, 3000)
	local buy = ProfileService.PurchaseCosmetic(player, "Trails", "ion")
	check("cosmetic_purchase", buy.ok == true or buy.reason == "already_owned", { Reason = buy.reason })
	local equip = ProfileService.EquipCosmetic(player, "Trails", "ion")
	check("cosmetic_equip", equip.ok == true and player:GetAttribute("PerfectJumpTrail") == "ion", {
		Reason = equip.reason,
		Trail = player:GetAttribute("PerfectJumpTrail"),
	})

	local daily = ProfileService.ClaimDaily(player)
	check("daily_path", daily.ok == true or daily.reason == "already_claimed", { Reason = daily.reason })

	check("failure_path", RoundService.qaFail(player, "StudioQA"))
	check(
		"game_over_state",
		waitUntil(function()
			return player:GetAttribute("PerfectJumpPhase") == "GameOver"
		end, 1)
	)
	check("retry_path", RoundService.qaRetry(player))
	check("retry_ready", waitReady(player))
	local retrySnapshot = RoundService.qaSnapshot(player)
	check(
		"retry_resets_run",
		retrySnapshot.Score == 0 and retrySnapshot.Combo == 0 and retrySnapshot.CurrentPlatformId == 0,
		retrySnapshot
	)

	ProfileService.qaGrantRevive(player)
	check("revive_inventory", (player:GetAttribute("PerfectJumpRevives") or 0) >= 1)
	check("revive_failure_setup", RoundService.qaFail(player, "StudioQARevive"))
	check("revive_path", RoundService.qaRevive(player))
	check("revive_ready", waitReady(player))
	local revived = RoundService.qaSnapshot(player)
	check("revive_marks_assisted", revived.Assisted == true, revived)

	local persistent = ProfileService.qaPersistentPayload(player)
	check(
		"persistent_payload",
		persistent ~= nil
			and persistent.HighestPlatform >= RuntimeQaConfig.LandingSampleCount
			and persistent.Equipped.Trails == "ion",
		{
			HighestPlatform = if persistent then persistent.HighestPlatform else -1,
			Trail = if persistent then persistent.Equipped.Trails else "missing",
			Perfects = perfectCount,
		}
	)

	for category, definition in CosmeticConfig.Categories do
		check(
			("default_cosmetic_%s"):format(category),
			definition.Items[definition.Default] ~= nil,
			{ Default = definition.Default }
		)
	end

	player:SetAttribute("PerfectJumpQaComplete", true)
	print("[PerfectJumpQA] COMPLETE " .. HttpService:JSONEncode(results))
end

function RuntimeQaService.start()
	if not RunService:IsStudio() or not RuntimeQaConfig.EnabledInStudio then
		return
	end

	local function startFor(player: Player)
		task.spawn(function()
			local ok, err = pcall(run, player)
			if not ok then
				warn("[PerfectJumpQA] ABORT " .. tostring(err))
			end
		end)
	end

	Players.PlayerAdded:Connect(startFor)
	for _, player in Players:GetPlayers() do
		startFor(player)
	end
end

return RuntimeQaService
