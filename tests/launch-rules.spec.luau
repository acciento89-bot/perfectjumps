return function()
	local GameConfig = require("../src/shared/config/GameConfig")
	local rules = require("../src/shared/game/LaunchRules")

	assert(
		math.abs(rules.HorizontalSpeed(0) - GameConfig.Movement.MinimumHorizontalSpeed) < 0.0001,
		"minimum horizontal speed mismatch"
	)
	assert(
		math.abs(rules.HorizontalSpeed(1) - GameConfig.Movement.MaximumHorizontalSpeed) < 0.0001,
		"maximum horizontal speed mismatch"
	)
	assert(
		math.abs(rules.VerticalSpeed(0) - GameConfig.Movement.MinimumVerticalSpeed) < 0.0001,
		"minimum vertical speed mismatch"
	)
	assert(
		math.abs(rules.VerticalSpeed(1) - GameConfig.Movement.MaximumVerticalSpeed) < 0.0001,
		"maximum vertical speed mismatch"
	)
	assert(rules.IsLegalChargeSeconds(0.6), "normal charge should be legal")
	assert(not rules.IsLegalChargeSeconds(math.huge), "infinite charge must be rejected")
	assert(not rules.IsLegalChargeSeconds(9), "stale charge must be rejected")
end
