local GameConfig = require("../src/shared/config/GameConfig")
local ReachabilityRules = require("../src/shared/game/ReachabilityRules")

return function()
	local checked = 0
	for platformId = 1, 2000 do
		local lateral, vertical, gap = ReachabilityRules.generatorOffset(platformId)
		local distance = math.sqrt(lateral * lateral + gap * gap)
		local width = math.max(
			GameConfig.Platform.MinimumWidth,
			GameConfig.Platform.InitialWidth - math.max(0, platformId - 1) * GameConfig.Generation.WidthShrinkPerLanding
		)
		local landingRadius = math.max(0.8, width / 2 - GameConfig.Platform.EdgeSafetyMargin)
		assert(
			ReachabilityRules.isReachable(distance, vertical, landingRadius),
			("unreachable generated target %d: distance=%.3f vertical=%.3f width=%.3f error=%.3f"):format(
				platformId,
				distance,
				vertical,
				width,
				ReachabilityRules.bestDistanceError(distance, vertical)
			)
		)
		checked += 1
	end
	assert(checked == 2000, "reachability sample count mismatch")

	local a = ReachabilityRules.travelDistance(0.5, GameConfig.Generation.VerticalStep)
	local b = ReachabilityRules.travelDistance(0.5, GameConfig.Generation.VerticalStep)
	assert(a ~= nil and b ~= nil and math.abs(a - b) < 1e-9, "launch model is not deterministic")
	assert(ReachabilityRules.isReachable(math.huge, 0, 2) == false, "infinite distance must be rejected")
	assert(ReachabilityRules.isReachable(8, 100, 2) == false, "extreme vertical target must be rejected")
end
