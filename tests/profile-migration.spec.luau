local EconomyConfig = require("../src/shared/config/EconomyConfig")
local ProfileRules = require("../src/shared/game/ProfileRules")

return function()
	local migrated = ProfileRules.migrate({
		Version = 0,
		Coins = 42.9,
		BestScore = 17.5,
		HighestPlatform = 4.8,
		Settings = { ReducedMotion = true },
	})

	assert(migrated.Version == EconomyConfig.ProfileVersion, "legacy profile did not migrate to current version")
	assert(migrated.Coins == 42 and migrated.BestScore == 17 and migrated.HighestPlatform == 4, "legacy values changed")
	assert(migrated.Settings.ReducedMotion == true, "legacy setting was lost")
	assert(migrated.Settings.AudioEnabled == true, "new setting default was not backfilled")
	assert(type(migrated.ProcessedReceipts) == "table", "new receipt field was not backfilled")
end
