local fs = require("@lune/fs")

return function()
	local config = require("../src/shared/config/RuntimeQaConfig")
	local qa = fs.readFile("src/server/services/RuntimeQaService.luau")
	local round = fs.readFile("src/server/services/RoundService.luau")

	assert(config.LaunchRepeatabilitySampleCount == 100, "runtime QA must sample 100 launches")
	assert(
		string.find(round, "function RoundService.qaLaunch", 1, true),
		"RoundService must expose a Studio-only launch sampler"
	)
	assert(
		string.find(round, "launchWithHeldSeconds(round, heldSeconds)", 1, true),
		"QA launch sampler must exercise the same held-seconds launch path as production"
	)
	assert(string.find(qa, '"charge_min"', 1, true), "runtime QA must measure minimum charge")
	assert(string.find(qa, '"charge_mid"', 1, true), "runtime QA must measure midpoint charge")
	assert(string.find(qa, '"charge_max"', 1, true), "runtime QA must measure maximum charge")
	assert(
		string.find(qa, '"launch_repeatability_100"', 1, true),
		"runtime QA must record the 100-launch repeatability gate"
	)
end
