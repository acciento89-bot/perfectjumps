--!strict

return table.freeze({
	MaxProcessedReceipts = 50,
	DeveloperProducts = table.freeze({
		Revive = table.freeze({
			ProductId = 0,
			Robux = 29,
			Grant = "Revive",
			MaxInventory = 3,
		}),
		WidePerfect5m = table.freeze({
			ProductId = 0,
			Robux = 39,
			Grant = "WidePerfect",
			DurationSeconds = 300,
			RadiusMultiplier = 1.35,
		}),
		CoinBoost15m = table.freeze({
			ProductId = 0,
			Robux = 49,
			Grant = "CoinBoost",
			DurationSeconds = 900,
			Multiplier = 2,
		}),
	}),
	GamePasses = table.freeze({
		PremiumThemes = table.freeze({
			GamePassId = 0,
			Robux = 99,
		}),
	}),
	CompetitiveScorePurchasable = false,
})
