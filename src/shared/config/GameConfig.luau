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

	Movement = {
		PlatformWalkSpeed = 8,
		AirWalkSpeed = 0,
		MinimumHorizontalSpeed = 22,
		MaximumHorizontalSpeed = 48,
		MinimumVerticalSpeed = 34,
		MaximumVerticalSpeed = 52,
		LandingVerticalSpeedLimit = 18,
	},

	Failure = {
		KillPlaneY = -28,
		MaximumHorizontalDistanceFromLane = 80,
		MaximumVerticalDistanceFromLane = 96,
		RetryDelaySeconds = 0.2,
	},

	Camera = {
		FieldOfView = 68,
		Distance = 18,
		Height = 9,
		TargetLead = 0.58,
		Smoothness = 10,
	},

	Platform = {
		InitialWidth = 10,
		MinimumWidth = 4.5,
		Depth = 8,
		Height = 1,
		EdgeSafetyMargin = 0.55,
	},

	Generation = {
		InitialGap = 12.5,
		MaximumGap = 17,
		GapGrowthPerLanding = 0.28,
		WidthShrinkPerLanding = 0.10,
		LateralSpread = 5.5,
		VerticalStep = 1.35,
		LaneSpacing = 120,
		VisiblePlatformHistory = 4,
		QaSeed = 0,
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
