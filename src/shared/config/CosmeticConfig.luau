--!strict

local CosmeticConfig = {
	Categories = table.freeze({
		Trails = table.freeze({
			Default = "none",
			Items = table.freeze({
				none = table.freeze({ DisplayName = "No Trail", Price = 0, RGB = { 220, 228, 238 } }),
				ion = table.freeze({ DisplayName = "Ion Arc", Price = 300, RGB = { 94, 235, 255 } }),
				ember = table.freeze({ DisplayName = "Ember Wake", Price = 450, RGB = { 255, 143, 74 } }),
			}),
		}),
		LandingEffects = table.freeze({
			Default = "basic",
			Items = table.freeze({
				basic = table.freeze({ DisplayName = "Impact Ring", Price = 0, RGB = { 255, 184, 76 } }),
				spark = table.freeze({ DisplayName = "Precision Sparks", Price = 350, RGB = { 255, 214, 107 } }),
				pulse = table.freeze({ DisplayName = "Sky Pulse", Price = 550, RGB = { 104, 190, 255 } }),
			}),
		}),
		PlatformThemes = table.freeze({
			Default = "steel",
			Items = table.freeze({
				steel = table.freeze({
					DisplayName = "Precision Steel",
					Price = 0,
					BaseRGB = { 54, 61, 72 },
					AccentRGB = { 255, 184, 76 },
				}),
				forge = table.freeze({
					DisplayName = "Copper Forge",
					Price = 650,
					BaseRGB = { 91, 54, 42 },
					AccentRGB = { 255, 155, 72 },
				}),
				frost = table.freeze({
					DisplayName = "Frost Grid",
					Price = 720,
					BaseRGB = { 43, 72, 87 },
					AccentRGB = { 135, 232, 255 },
				}),
			}),
		}),
		EnvironmentThemes = table.freeze({
			Default = "skyline",
			Items = table.freeze({
				skyline = table.freeze({ DisplayName = "Highline", Price = 0 }),
				dusk = table.freeze({ DisplayName = "Dusk Circuit", Price = 900 }),
				storm = table.freeze({ DisplayName = "Storm Span", Price = 1100 }),
			}),
		}),
	}),
}

return table.freeze(CosmeticConfig)
