local fs = require("@lune/fs")

return function()
	local world = fs.readFile("src/server/services/WorldService.luau")
	local art = fs.readFile("src/server/services/WorldArtService.luau")
	local direction = fs.readFile("docs/ART-DIRECTION.md")

	assert(string.find(art, 'farLayer.Name = "ParallaxHighlineFar"', 1, true), "far depth layer missing")
	assert(string.find(art, '"HighlineArch"', 1, true), "course arch missing")
	assert(string.find(art, '"MotionRibbon"', 1, true), "motion ribbon missing")
	assert(string.find(art, '"SunHalo"', 1, true), "sun halo missing")
	assert(string.find(world, '"PlatformFin"', 1, true), "platform underside detail missing")
	assert(string.find(world, '"LandingRing"', 1, true), "target ring missing")
	assert(string.find(direction, "sky-course identity", 1, true), "sky-course identity missing")
end
