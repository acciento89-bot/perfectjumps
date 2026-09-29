return function()
	local rules = require("../src/shared/game/RoundStateRules")

	assert(rules.CanTransition("Ready", "Charging"), "Ready -> Charging expected")
	assert(rules.CanTransition("Charging", "Airborne"), "Charging -> Airborne expected")
	assert(rules.CanTransition("Airborne", "Landed"), "Airborne -> Landed expected")
	assert(rules.CanTransition("Airborne", "GameOver"), "Airborne -> GameOver expected")
	assert(rules.CanTransition("GameOver", "Ready"), "GameOver -> Ready expected")
	assert(not rules.CanTransition("Ready", "Landed"), "Ready -> Landed must be rejected")
	assert(not rules.CanTransition("GameOver", "Airborne"), "GameOver -> Airborne must be rejected")
end
