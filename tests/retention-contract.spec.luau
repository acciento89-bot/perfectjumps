local fs = require("@lune/fs")
local RetentionConfig = require("../src/shared/config/RetentionConfig")
local RetentionRules = require("../src/shared/game/RetentionRules")

return function()
	local p1, rewarded1, grant1 = RetentionRules.applyPerfectChallenge(0, false, 5)
	assert(p1 == 1 and rewarded1 == false and grant1 == false, "challenge rewarded too early")

	local p5, rewarded5, grant5 = RetentionRules.applyPerfectChallenge(4, false, 5)
	assert(p5 == 5 and rewarded5 == true and grant5 == true, "challenge threshold must grant exactly once")

	local p6, rewarded6, grant6 = RetentionRules.applyPerfectChallenge(5, true, 5)
	assert(p6 == 6 and rewarded6 == true and grant6 == false, "challenge must not grant twice")

	local function contains(items, wanted)
		for _, item in items do
			if item == wanted then
				return true
			end
		end
		return false
	end

	local first = RetentionRules.eligibleAchievements("Good", 0, 1)
	assert(contains(first, "first_jump"), "first landing achievement missing")
	assert(not contains(first, "first_perfect"), "Good landing cannot grant first Perfect")

	local perfect = RetentionRules.eligibleAchievements("Perfect", 5, 25)
	for _, id in { "first_jump", "first_perfect", "combo_5", "height_10", "height_25" } do
		assert(contains(perfect, id), "missing achievement milestone " .. id)
		assert(RetentionConfig.Achievements[id] ~= nil, "unknown configured achievement " .. id)
	end

	local profile = fs.readFile("src/server/services/ProfileService.luau")
	assert(
		string.find(profile, "RetentionRules.applyPerfectChallenge", 1, true),
		"ProfileService must use the tested challenge rule"
	)
	assert(
		string.find(profile, "RetentionRules.eligibleAchievements", 1, true),
		"ProfileService must use tested achievement eligibility"
	)

	local qa = fs.readFile("src/server/services/RuntimeQaService.luau")
	for _, marker in
		{
			'"daily_claim_once"',
			'"daily_duplicate_rejected"',
			'"daily_challenge_completed"',
			'"achievement_milestones"',
		}
	do
		assert(string.find(qa, marker, 1, true), "missing runtime retention gate " .. marker)
	end

	local feedback = fs.readFile("src/client/controllers/FeedbackController.luau")
	assert(string.find(feedback, "reward.NewPB == true", 1, true), "PB celebration trigger missing")
	assert(string.find(feedback, "reward.AchievementCoins", 1, true), "achievement celebration trigger missing")
	assert(string.find(feedback, "reward.ChallengeCoins", 1, true), "challenge celebration trigger missing")
	assert(string.find(feedback, 'playCue("Retry")', 1, true), "quick-retry cue missing")
	assert(string.find(feedback, "comboScale", 1, true), "Perfect-chain escalation missing")
end
