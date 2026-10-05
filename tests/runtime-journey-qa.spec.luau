local fs = require("@lune/fs")

return function()
	local qa = fs.readFile("src/server/services/RuntimeQaService.luau")
	local round = fs.readFile("src/server/services/RoundService.luau")

	assert(string.find(round, "Phase = round.Phase", 1, true), "launch sampler must expose the production phase")
	assert(string.find(qa, '"journey_spawn_ready"', 1, true), "runtime journey must verify spawn")
	assert(string.find(qa, '"journey_charge_release"', 1, true), "runtime journey must verify charge/release")
	assert(string.find(qa, '"journey_landing_ready"', 1, true), "runtime journey must verify landing")
	assert(string.find(qa, '"journey_failure"', 1, true), "runtime journey must verify failure")
	assert(string.find(qa, '"journey_retry_respawn"', 1, true), "runtime journey must verify retry respawn")
end
