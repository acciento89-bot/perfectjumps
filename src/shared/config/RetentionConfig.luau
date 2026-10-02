--!strict

return table.freeze({
	DailyChallenge = table.freeze({
		PerfectsRequired = 5,
		RewardCoins = 45,
	}),
	Achievements = table.freeze({
		first_jump = table.freeze({ DisplayName = "First Landing", RewardCoins = 10 }),
		first_perfect = table.freeze({ DisplayName = "Perfect Jump", RewardCoins = 20 }),
		combo_5 = table.freeze({ DisplayName = "Five Perfects", RewardCoins = 35 }),
		height_10 = table.freeze({ DisplayName = "Ten Platforms", RewardCoins = 45 }),
		height_25 = table.freeze({ DisplayName = "High Precision", RewardCoins = 80 }),
	}),
})
