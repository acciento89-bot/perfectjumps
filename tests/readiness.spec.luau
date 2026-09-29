return function()
	local rules = require("../src/shared/release/ReadinessRules")

	local blocked = rules.Evaluate({
		UniverseId = 0,
		DevelopmentPlaceId = 0,
		ProductionPlaceId = 0,
	})
	assert(blocked.ReadyForSandbox == false, "unconfigured platform must block sandbox readiness")
	assert(#blocked.Blockers == 3, "expected three platform blockers")

	local ready = rules.Evaluate({
		UniverseId = 1,
		DevelopmentPlaceId = 2,
		ProductionPlaceId = 3,
	})
	assert(ready.ReadyForSandbox == true, "configured platform should be sandbox-ready")
	assert(#ready.Blockers == 0, "configured platform should have no blockers")
end
