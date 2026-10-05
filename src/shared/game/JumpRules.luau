--!strict

local GameConfig = require("../config/GameConfig")
local EconomyRules = require("./EconomyRules")

local JumpRules = {}

export type LandingGrade = "Perfect" | "Good" | "Safe" | "Miss"

function JumpRules.NormalizeCharge(heldSeconds: number): number
	if heldSeconds ~= heldSeconds or heldSeconds == math.huge or heldSeconds == -math.huge then
		return GameConfig.Charge.MinimumPower
	end
	local duration = math.clamp(heldSeconds, GameConfig.Charge.MinimumSeconds, GameConfig.Charge.MaximumSeconds)
	local span = GameConfig.Charge.MaximumSeconds - GameConfig.Charge.MinimumSeconds
	local alpha = if span <= 0 then 1 else (duration - GameConfig.Charge.MinimumSeconds) / span
	return GameConfig.Charge.MinimumPower + (GameConfig.Charge.MaximumPower - GameConfig.Charge.MinimumPower) * alpha
end

function JumpRules.SafeRadius(platformWidth: number): number
	return math.max(0, platformWidth / 2 - GameConfig.Platform.EdgeSafetyMargin)
end

function JumpRules.GradeLandingWithPerfectRadius(
	centerDistance: number,
	platformWidth: number,
	perfectRadius: number
): LandingGrade
	local distance = math.max(0, centerDistance)
	local safeRadius = JumpRules.SafeRadius(platformWidth)
	local effectivePerfect = math.clamp(perfectRadius, 0, math.min(GameConfig.Landing.GoodRadius, safeRadius))
	if distance <= effectivePerfect then
		return "Perfect"
	elseif distance <= GameConfig.Landing.GoodRadius then
		return "Good"
	elseif distance <= safeRadius then
		return "Safe"
	end
	return "Miss"
end

function JumpRules.GradeLanding(centerDistance: number, platformWidth: number): LandingGrade
	return JumpRules.GradeLandingWithPerfectRadius(centerDistance, platformWidth, GameConfig.Landing.PerfectRadius)
end

function JumpRules.NextCombo(currentCombo: number, grade: LandingGrade): number
	if grade == "Perfect" then
		return math.max(0, currentCombo) + 1
	end
	return 0
end

function JumpRules.ScoreForLanding(grade: LandingGrade, combo: number): number
	if grade == "Miss" then
		return 0
	end
	local base = GameConfig.Score[grade]
	local multiplier =
		math.min(GameConfig.Score.MaximumComboMultiplier, 1 + math.max(0, combo) * GameConfig.Score.ComboStep)
	return math.floor(base * multiplier + 0.5)
end

function JumpRules.CoinsForLanding(grade: LandingGrade): number
	return EconomyRules.landingCoins(grade, false)
end

return table.freeze(JumpRules)
