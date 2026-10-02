local CosmeticConfig = require("../src/shared/config/CosmeticConfig")
local ProfileRules = require("../src/shared/game/ProfileRules")

return function()
	local fresh = ProfileRules.defaultProfile()
	assert(fresh.Coins == 0 and fresh.BestScore == 0 and fresh.HighestPlatform == 0, "fresh profile mismatch")

	for category, definition in CosmeticConfig.Categories do
		assert(fresh.Owned[category][definition.Default] == true, "default cosmetic not owned")
		assert(fresh.Equipped[category] == definition.Default, "default cosmetic not equipped")
	end

	local normalized = ProfileRules.normalize({
		Coins = -200,
		BestScore = 41.9,
		HighestPlatform = 8.7,
		Settings = { ReducedMotion = true, AudioEnabled = false },
		Inventory = { Revives = 2.8 },
		Boosts = { WidePerfectUntil = 500, CoinBoostUntil = 900 },
	})
	assert(normalized.Coins == 0, "negative coins were not clamped")
	assert(normalized.BestScore == 41 and normalized.HighestPlatform == 8, "score/platform normalization failed")
	assert(
		normalized.Settings.ReducedMotion == true and normalized.Settings.AudioEnabled == false,
		"settings normalization failed"
	)
	assert(normalized.Inventory.Revives == 2, "revive inventory normalization failed")

	normalized.Coins = 1000
	local ok, reason, price = ProfileRules.validatePurchase(normalized, "Trails", "ion")
	assert(ok and reason == "ok" and price == 300, "valid cosmetic purchase rejected")
	normalized.Owned.Trails.ion = true
	local duplicateOk, duplicateReason = ProfileRules.validatePurchase(normalized, "Trails", "ion")
	assert(duplicateOk == false and duplicateReason == "already_owned", "duplicate purchase accepted")
	local equipOk = ProfileRules.validateEquip(normalized, "Trails", "ion")
	assert(equipOk == true, "owned cosmetic could not equip")
end
