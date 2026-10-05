local fs = require("@lune/fs")

return function()
	local qa = fs.readFile("src/server/services/RuntimeQaService.luau")
	local hud = fs.readFile("src/client/controllers/HudController.luau")

	assert(string.find(qa, '"tutorial_fresh_player"', 1, true), "runtime QA must verify fresh tutorial state")
	assert(
		string.find(qa, '"tutorial_completes_after_first_landing"', 1, true),
		"runtime QA must verify tutorial completion after first landing"
	)
	assert(
		string.find(hud, '"PerfectJumpTutorialComplete"', 1, true),
		"HUD must bind tutorial visibility to authoritative tutorial completion"
	)
	assert(
		string.find(hud, "HOLD", 1, true) and string.find(hud, "RELEASE", 1, true),
		"tutorial copy must teach hold/release"
	)
end
