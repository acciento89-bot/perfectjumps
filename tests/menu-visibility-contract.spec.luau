local function run()
	local fs = require("@lune/fs")

	local hud = fs.readFile("src/client/controllers/HudController.luau")
	local shop = fs.readFile("src/client/controllers/ShopController.luau")
	local art = fs.readFile("docs/ART-DIRECTION.md")

	assert(string.find(hud, "conceptShowcase.Visible = false", 1, true), "concept montage must stay hidden in gameplay")
	assert(
		not string.find(hud, 'conceptShowcase.Visible = viewportClass ~= "compact"', 1, true),
		"desktop must not force the concept montage visible"
	)
	assert(
		string.find(hud, 'player:SetAttribute("PerfectJumpDailyOpen", true)', 1, true),
		"Daily action must open Daily only"
	)
	assert(string.find(shop, 'dailyPanel.Name = "DailyRewardsPanel"', 1, true), "Daily needs a dedicated modal panel")
	assert(string.find(shop, "dailyPanel.Visible = false", 1, true), "Daily modal must be hidden by default")
	assert(
		string.find(shop, 'player:SetAttribute("PerfectJumpDailyOpen", false)', 1, true),
		"Daily modal needs an explicit close path"
	)
	assert(string.find(hud, "resultPanel.Visible = false", 1, true), "Revive/result must be event-driven")
	assert(
		string.find(art, "feature montage", 1, true),
		"art direction must define the concept image as a feature montage"
	)
end

return run
