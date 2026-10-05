local function run()
	local fs = require("@lune/fs")

	local hud = fs.readFile("src/client/controllers/HudController.luau")

	assert(string.find(hud, 'conceptShowcase.Name = "ConceptShowcase"', 1, true), "concept showcase layer missing")
	assert(string.find(hud, 'shopShowcase.Name = "JumpSupplyShowcase"', 1, true), "jump supply showcase missing")
	assert(
		string.find(hud, 'conceptProgressCard.Name = "ConceptProgressCard"', 1, true),
		"concept progress card missing"
	)
	assert(string.find(hud, 'conceptDailyRewards.Name = "ConceptDailyRewards"', 1, true), "daily showcase missing")
	assert(string.find(hud, 'conceptVistaCard.Name = "ConceptVistaCard"', 1, true), "visual showcase missing")
	assert(
		string.find(hud, 'local conceptViewport = Instance.new("ViewportFrame")', 1, true),
		"visual preview must be native ViewportFrame"
	)
	assert(
		string.find(hud, "conceptShowcase.Visible = false", 1, true),
		"concept montage must stay hidden during normal gameplay"
	)
	assert(
		string.find(hud, "tutorial.Position = UDim2.new(0.57, 0, 1, -160)", 1, true),
		"concept tutorial must stay below hero gameplay"
	)
end

return run
