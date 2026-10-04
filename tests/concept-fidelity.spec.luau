local fs = require("@lune/fs")

return function()
	local hud = fs.readFile("src/client/controllers/HudController.luau")
	local art = fs.readFile("src/server/services/WorldArtService.luau")

	assert(string.find(hud, 'logo.Name = "PerfectJumpLogo"', 1, true), "HUD needs a branded Perfect Jump logo")
	assert(
		string.find(hud, 'comboProgress.Name = "ComboProgress"', 1, true),
		"HUD needs a concept-style combo progress strip"
	)
	assert(string.find(hud, 'quickRail.Name = "ConceptQuickRail"', 1, true), "HUD needs compact concept actions")
	assert(string.find(art, 'gateway.Name = "HeroGateway"', 1, true), "world needs a hero gateway landmark")
	assert(string.find(art, '"SkySunDisc"', 1, true), "world needs a warm sky focal point")
	assert(string.find(art, '"CloudGarden"', 1, true), "world needs layered sky depth")
end
