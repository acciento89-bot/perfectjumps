--!strict

local GameConfig = require("../config/GameConfig")
local LaunchRules = require("./LaunchRules")

local ReachabilityRules = {}

local GRAVITY = 196.2

function ReachabilityRules.flightTime(normalizedCharge: number, verticalDelta: number): number?
	local verticalSpeed = LaunchRules.VerticalSpeed(normalizedCharge)
	local discriminant = verticalSpeed * verticalSpeed - 2 * GRAVITY * verticalDelta
	if discriminant < 0 then
		return nil
	end
	return (verticalSpeed + math.sqrt(discriminant)) / GRAVITY
end

function ReachabilityRules.travelDistance(normalizedCharge: number, verticalDelta: number): number?
	local time = ReachabilityRules.flightTime(normalizedCharge, verticalDelta)
	if not time then
		return nil
	end
	return LaunchRules.HorizontalSpeed(normalizedCharge) * time
end

function ReachabilityRules.bestDistanceError(horizontalDistance: number, verticalDelta: number): number
	local target = math.max(0, horizontalDistance)
	local best = math.huge
	for step = 0, 200 do
		local alpha = step / 200
		local chargePower = GameConfig.Charge.MinimumPower
			+ (GameConfig.Charge.MaximumPower - GameConfig.Charge.MinimumPower) * alpha
		local distance = ReachabilityRules.travelDistance(chargePower, verticalDelta)
		if distance then
			best = math.min(best, math.abs(distance - target))
		end
	end
	return best
end

function ReachabilityRules.isReachable(
	horizontalDistance: number,
	verticalDelta: number,
	landingRadius: number
): boolean
	if horizontalDistance ~= horizontalDistance or verticalDelta ~= verticalDelta then
		return false
	end
	if horizontalDistance < 0 or math.abs(verticalDelta) > 12 then
		return false
	end
	local tolerance = math.max(0.8, landingRadius)
	return ReachabilityRules.bestDistanceError(horizontalDistance, verticalDelta) <= tolerance
end

function ReachabilityRules.difficultyBand(platformId: number): string
	local id = math.max(1, math.floor(platformId))
	if id <= 8 then
		return "WarmUp"
	elseif id <= 20 then
		return "Rhythm"
	end
	return "Precision"
end

function ReachabilityRules.platformWidth(platformId: number): number
	return math.max(
		GameConfig.Platform.MinimumWidth,
		GameConfig.Platform.InitialWidth
			- math.max(0, math.floor(platformId) - 1) * GameConfig.Generation.WidthShrinkPerLanding
	)
end

function ReachabilityRules.generatorOffset(nextId: number, seed: number?): (number, number, number)
	local progress = math.max(0, nextId - 1)
	local gap = math.min(
		GameConfig.Generation.MaximumGap,
		GameConfig.Generation.InitialGap + progress * GameConfig.Generation.GapGrowthPerLanding
	)
	local lateralScale = math.min(1, 0.25 + progress * 0.04)
	local effectiveSeed = if seed == nil then GameConfig.Generation.QaSeed else seed
	local phase = nextId * 1.71 + effectiveSeed * 0.61803398875
	local lateral = math.sin(phase) * GameConfig.Generation.LateralSpread * lateralScale
	return lateral, GameConfig.Generation.VerticalStep, gap
end

return table.freeze(ReachabilityRules)
