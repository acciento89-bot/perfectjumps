local fs = require("@lune/fs")

local world = fs.readFile("src/server/services/WorldService.luau")
local art = fs.readFile("src/server/services/WorldArtService.luau")
local direction = fs.readFile("docs/ART-DIRECTION.md")

assert(string.find(art, 'farLayer.Name = "ParallaxHighlineFar"', 1, true), "world needs a far highline depth layer")
assert(string.find(art, '"HighlineArch"', 1, true), "world needs repeated highline arch silhouettes")
assert(string.find(art, '"MotionRibbon"', 1, true), "world needs authored motion ribbons")
assert(string.find(art, '"SunHalo"', 1, true), "sun focal point needs a layered halo")
assert(string.find(world, '"PlatformFin"', 1, true), "jump platforms need authored underside fins")
assert(string.find(world, '"LandingRing"', 1, true), "landing target needs a premium ring treatment")
assert(string.find(direction, "aerial highline", 1, true), "art direction must lock the aerial highline identity")

return true
