local GameConfig = require("../src/shared/config/GameConfig")
local JumpRules = require("../src/shared/game/JumpRules")
local ReachabilityRules = require("../src/shared/game/ReachabilityRules")

return function()
	assert(ReachabilityRules.difficultyBand(1) == "WarmUp", "platform 1 must be WarmUp")
	assert(ReachabilityRules.difficultyBand(8) == "WarmUp", "platform 8 must be WarmUp")
	assert(ReachabilityRules.difficultyBand(9) == "Rhythm", "platform 9 must be Rhythm")
	assert(ReachabilityRules.difficultyBand(20) == "Rhythm", "platform 20 must be Rhythm")
	assert(ReachabilityRules.difficultyBand(21) == "Precision", "platform 21 must be Precision")

	local _, warmVertical, warmGap = ReachabilityRules.generatorOffset(1)
	local _, rhythmVertical, rhythmGap = ReachabilityRules.generatorOffset(12)
	local _, precisionVertical, precisionGap = ReachabilityRules.generatorOffset(40)
	assert(warmGap < rhythmGap, "Rhythm gap must exceed early WarmUp gap")
	assert(rhythmGap <= precisionGap, "Precision gap must not be easier than Rhythm gap")
	assert(precisionGap == GameConfig.Generation.MaximumGap, "late Precision gap must reach configured cap")
	assert(
		warmVertical == GameConfig.Generation.VerticalStep
			and rhythmVertical == GameConfig.Generation.VerticalStep
			and precisionVertical == GameConfig.Generation.VerticalStep,
		"vertical step must remain predictable across bands"
	)

	local warmWidth = ReachabilityRules.platformWidth(1)
	local rhythmWidth = ReachabilityRules.platformWidth(20)
	local precisionWidth = ReachabilityRules.platformWidth(60)
	assert(warmWidth > rhythmWidth and rhythmWidth > precisionWidth, "platform width must tighten with progression")
	assert(precisionWidth == GameConfig.Platform.MinimumWidth, "late width must respect configured minimum")
	assert(
		JumpRules.SafeRadius(warmWidth) > JumpRules.SafeRadius(rhythmWidth)
			and JumpRules.SafeRadius(rhythmWidth) > JumpRules.SafeRadius(precisionWidth),
		"safe landing radius must tighten with platform width"
	)

	local positive, negative = 0, 0
	local signatures = {}
	for platformId = 1, 60 do
		local lateral, vertical, gap = ReachabilityRules.generatorOffset(platformId)
		assert(math.abs(lateral) <= GameConfig.Generation.LateralSpread + 1e-9, "lateral spread exceeded")
		assert(vertical > 0 and gap > 0, "generated target must stay forward/upward readable")
		if lateral > 0.05 then
			positive += 1
		elseif lateral < -0.05 then
			negative += 1
		end
		signatures[string.format("%.3f/%.3f", lateral, gap)] = true
	end
	assert(positive >= 10 and negative >= 10, "pattern variety must cover both lateral directions")
	local signatureCount = 0
	for _ in signatures do
		signatureCount += 1
	end
	assert(signatureCount >= 30, "pattern variety is too repetitive")

	local seed = GameConfig.Generation.QaSeed
	local a1, a2, a3 = ReachabilityRules.generatorOffset(17, seed)
	local b1, b2, b3 = ReachabilityRules.generatorOffset(17, seed)
	assert(a1 == b1 and a2 == b2 and a3 == b3, "same QA seed must reproduce the same target")
	local c1 = ReachabilityRules.generatorOffset(17, seed + 1)
	assert(c1 ~= a1, "different QA seed should alter the lateral pattern")
	local d1, d2, d3 = ReachabilityRules.generatorOffset(17)
	assert(d1 == a1 and d2 == a2 and d3 == a3, "default generator must use configured QA seed")
end
