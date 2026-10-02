local ViewportRules = require("../src/shared/game/ViewportRules")

return function()
	assert(ViewportRules.classify(414) == "compact", "phone classification failed")
	assert(ViewportRules.classify(760) == "compact", "compact upper boundary failed")
	assert(ViewportRules.classify(761) == "tablet", "tablet lower boundary failed")
	assert(ViewportRules.classify(1100) == "tablet", "tablet upper boundary failed")
	assert(ViewportRules.classify(1101) == "desktop", "desktop lower boundary failed")
	assert(math.abs(ViewportRules.uiScale(320) - 0.80) < 0.001, "small viewport scale clamp failed")
	assert(math.abs(ViewportRules.uiScale(980) - 1.0) < 0.001, "baseline viewport scale failed")
	assert(math.abs(ViewportRules.uiScale(1600) - 1.06) < 0.001, "large viewport scale clamp failed")
	assert(ViewportRules.cameraDistance(414, 18) == 15.4, "compact camera distance failed")
	assert(ViewportRules.cameraDistance(1200, 18) == 18, "desktop camera distance changed")
end
