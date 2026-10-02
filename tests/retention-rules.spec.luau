local RetentionRules = require("../src/shared/game/RetentionRules")

return function()
	assert(RetentionRules.dayKey(0) == 0, "day zero mismatch")
	assert(RetentionRules.dayKey(86400 * 7 + 42) == 7, "day key mismatch")
	assert(RetentionRules.canClaimDaily(4, 5) == true, "new-day claim rejected")
	assert(RetentionRules.canClaimDaily(5, 5) == false, "same-day duplicate claim accepted")

	local day, progress, rewarded = RetentionRules.normalizeChallengeDay(4, 5, 99, true)
	assert(day == 5 and progress == 0 and rewarded == false, "challenge did not reset on new day")
	local sameDay, sameProgress, sameRewarded = RetentionRules.normalizeChallengeDay(5, 5, 3, true)
	assert(sameDay == 5 and sameProgress == 3 and sameRewarded == true, "same-day challenge state changed")
end
