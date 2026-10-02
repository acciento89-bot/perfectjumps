local GraphicsQualityRules = require("../src/shared/game/GraphicsQualityRules")

return function()
	assert(GraphicsQualityRules.isLow(0) == false, "automatic graphics must remain engine-managed")
	assert(GraphicsQualityRules.isLow(1) == true, "quality 1 must use low profile")
	assert(GraphicsQualityRules.isLow(3) == true, "quality 3 must use low profile")
	assert(GraphicsQualityRules.isLow(4) == false, "quality 4 must use standard profile")

	local low = GraphicsQualityRules.profile(2)
	assert(low.Low == true, "low profile flag missing")
	assert(low.DecorativePointLightsEnabled == false, "low profile must disable decorative lights")
	assert(low.BloomEnabled == false, "low profile must disable bloom")
	assert(low.TrailLifetimeScale < 1, "low profile must shorten trails")

	local standard = GraphicsQualityRules.profile(8)
	assert(standard.Low == false, "standard profile flag incorrect")
	assert(standard.DecorativePointLightsEnabled == true, "standard profile lights changed")
	assert(standard.BloomEnabled == true, "standard profile bloom changed")
end
