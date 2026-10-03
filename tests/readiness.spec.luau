return function()
	local rules = require("../src/shared/release/ReadinessRules")

	local blocked = rules.Evaluate({
		UniverseId = 0,
		DevelopmentPlaceId = 0,
		ProductionPlaceId = 0,
	}, {
		DeveloperProducts = {
			Revive = { ProductId = 0 },
			WidePerfect5m = { ProductId = 0 },
			CoinBoost15m = { ProductId = 0 },
		},
		GamePasses = { PremiumThemes = { GamePassId = 0 } },
	})
	assert(blocked.ReadyForSandbox == false, "unconfigured release IDs must block sandbox readiness")
	assert(#blocked.Blockers == 7, "expected three platform and four monetization blockers")

	local ready = rules.Evaluate({
		UniverseId = 1,
		DevelopmentPlaceId = 2,
		ProductionPlaceId = 3,
	}, {
		DeveloperProducts = {
			Revive = { ProductId = 4 },
			WidePerfect5m = { ProductId = 5 },
			CoinBoost15m = { ProductId = 6 },
		},
		GamePasses = { PremiumThemes = { GamePassId = 7 } },
	})
	assert(ready.ReadyForSandbox == true, "configured release IDs should be sandbox-ready")
	assert(#ready.Blockers == 0, "configured release IDs should have no blockers")
end
