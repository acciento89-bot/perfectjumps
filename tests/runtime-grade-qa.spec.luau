local fs = require("@lune/fs")

return function()
	local qa = fs.readFile("src/server/services/RuntimeQaService.luau")
	local round = fs.readFile("src/server/services/RoundService.luau")

	assert(
		string.find(round, "local grade = JumpRules.GradeLandingWithPerfectRadius", 1, true),
		"QA landing must expose the production landing grade"
	)
	assert(string.find(qa, '"landing_grade_perfect"', 1, true), "runtime QA must prove Perfect landing")
	assert(string.find(qa, '"landing_grade_good"', 1, true), "runtime QA must prove Good landing")
	assert(string.find(qa, '"landing_grade_safe"', 1, true), "runtime QA must prove Safe edge landing")
	assert(string.find(qa, '"landing_grade_miss"', 1, true), "runtime QA must prove Miss landing")
	assert(string.find(qa, '"landing_grade_miss_retry"', 1, true), "Miss grade QA must recover through Retry")
end
