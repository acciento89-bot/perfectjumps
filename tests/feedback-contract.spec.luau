local fs = require("@lune/fs")

return function()
	local feedback = fs.readFile("src/client/controllers/FeedbackController.luau")

	assert(string.find(feedback, "Charge = {", 1, true), "charge cue definition missing")
	assert(string.find(feedback, "Release = {", 1, true), "release cue definition missing")
	assert(string.find(feedback, "Retry = {", 1, true), "retry cue definition missing")
	assert(string.find(feedback, 'playCue("Charge"', 1, true), "charge phase must play a cue")
	assert(string.find(feedback, 'playCue("Release"', 1, true), "airborne release must play a cue")
	assert(string.find(feedback, 'playCue("Retry"', 1, true), "GameOver -> Ready must play a retry cue")
	assert(string.find(feedback, "payload.Combo", 1, true), "Perfect feedback must use combo for escalation")
	assert(string.find(feedback, "MAX_TRANSIENT = 4", 1, true), "audio overlap cap must remain enforced")
	assert(string.find(feedback, "rbxasset://sounds/", 1, true), "feedback must use Roblox-safe built-in audio")
	assert(string.find(feedback, "reducedMotion()", 1, true), "reduced-motion guard missing")
	assert(string.find(feedback, "audioEnabled()", 1, true), "audio accessibility guard missing")
end
