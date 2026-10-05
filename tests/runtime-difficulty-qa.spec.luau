local fs = require("@lune/fs")

return function()
	local qa = fs.readFile("src/server/services/RuntimeQaService.luau")

	assert(
		string.find(qa, "ReachabilityRules", 1, true),
		"runtime difficulty QA must use production reachability rules"
	)
	assert(string.find(qa, '"difficulty_early"', 1, true), "early difficulty sample missing")
	assert(string.find(qa, '"difficulty_mid"', 1, true), "mid difficulty sample missing")
	assert(string.find(qa, '"difficulty_late"', 1, true), "late difficulty sample missing")
	assert(string.find(qa, '"difficulty_progression"', 1, true), "difficulty progression comparison missing")
end
