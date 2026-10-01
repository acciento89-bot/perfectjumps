--!strict

local GameConfig = require("../config/GameConfig")

local LaunchRules = {}

function LaunchRules.HorizontalSpeed(normalizedCharge: number): number
	local alpha = math.clamp(normalizedCharge, 0, 1)
	return GameConfig.Movement.MinimumHorizontalSpeed
		+ (GameConfig.Movement.MaximumHorizontalSpeed - GameConfig.Movement.MinimumHorizontalSpeed) * alpha
end

function LaunchRules.VerticalSpeed(normalizedCharge: number): number
	local alpha = math.clamp(normalizedCharge, 0, 1)
	return GameConfig.Movement.MinimumVerticalSpeed
		+ (GameConfig.Movement.MaximumVerticalSpeed - GameConfig.Movement.MinimumVerticalSpeed) * alpha
end

function LaunchRules.IsFinite(value: number): boolean
	return value == value and value ~= math.huge and value ~= -math.huge
end

function LaunchRules.IsLegalChargeSeconds(heldSeconds: number): boolean
	return LaunchRules.IsFinite(heldSeconds)
		and heldSeconds >= 0
		and heldSeconds <= GameConfig.Charge.MaximumSeconds + 0.35
end

return table.freeze(LaunchRules)
