local fs = require("@lune/fs")

return function()
	local round = fs.readFile("src/server/services/RoundService.luau")
	local qa = fs.readFile("src/server/services/RuntimeQaService.luau")

	assert(string.find(round, "function RoundService.qaReleaseSequence", 1, true), "release-sequence QA helper missing")
	assert(string.find(round, "function RoundService.qaLandingGuardProbe", 1, true), "landing guard QA helper missing")
	assert(string.find(round, "function RoundService.qaDoubleLanding", 1, true), "double-landing QA helper missing")
	assert(
		string.find(round, "function RoundService.qaFailureIdempotency", 1, true),
		"failure idempotency QA helper missing"
	)

	for _, marker in
		{
			'"stale_charge_rejected"',
			'"duplicate_release_ignored"',
			'"landing_requires_airborne"',
			'"ascending_touch_ignored"',
			'"double_landing_no_double_score"',
			'"failure_idempotent"',
			'"combo_breaks_on_good"',
		}
	do
		assert(string.find(qa, marker, 1, true), "missing runtime precision gate " .. marker)
	end
end
