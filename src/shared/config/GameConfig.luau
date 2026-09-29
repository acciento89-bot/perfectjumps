--!strict

local GameConfig = {
	ProductId = "perfect_jump",
	DisplayName = "Perfect Jump",

	Charge = {
		MinimumSeconds = 0.12,
		MaximumSeconds = 1.20,
		MinimumPower = 0.28,
		MaximumPower = 1.00,
	},

	Platform = {
		InitialWidth = 10,
		MinimumWidth = 4.5,
		Depth = 8,
		Height = 1,
		EdgeSafetyMargin = 0.55,
	},

	Generation = {
		InitialGap = 7,
		MaximumGap = 17,
		GapGrowthPerLanding = 0.28,
		WidthShrinkPerLanding = 0.10,
		LateralSpread = 5.5,
	},

	Landing = {
		PerfectRadius = 0.75,
		GoodRadius = 2.25,
	},

	Score = {
		Perfect = 100,
		Good = 60,
		Safe = 30,
		ComboStep = 0.10,
		MaximumComboMultiplier = 3.0,
	},

	Economy = {
		PerfectCoins = 3,
		GoodCoins = 2,
		SafeCoins = 1,
	},
}

return table.freeze(GameConfig)
