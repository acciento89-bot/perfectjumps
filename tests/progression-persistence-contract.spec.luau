local fs = require("@lune/fs")
local CosmeticConfig = require("../src/shared/config/CosmeticConfig")
local EconomyConfig = require("../src/shared/config/EconomyConfig")
local MonetizationConfig = require("../src/shared/config/MonetizationConfig")
local ProfileRules = require("../src/shared/game/ProfileRules")
local ProfileStorageRules = require("../src/shared/game/ProfileStorageRules")

return function()
	local economyPath = "src/shared/game/EconomyRules.luau"
	assert(fs.isFile(economyPath), "pure economy rules module missing")
	local EconomyRules = require("../src/shared/game/EconomyRules")

	assert(EconomyRules.landingCoins("Perfect", false) == EconomyConfig.PerfectCoins, "Perfect base reward mismatch")
	assert(EconomyRules.landingCoins("Good", false) == EconomyConfig.GoodCoins, "Good base reward mismatch")
	assert(EconomyRules.landingCoins("Safe", false) == EconomyConfig.SafeCoins, "Safe base reward mismatch")
	assert(EconomyRules.landingCoins("Miss", false) == 0, "Miss must not grant coins")
	assert(
		EconomyRules.landingCoins("Perfect", true)
			== EconomyConfig.PerfectCoins * MonetizationConfig.DeveloperProducts.CoinBoost15m.Multiplier,
		"coin boost reward mismatch"
	)
	assert(MonetizationConfig.CompetitiveScorePurchasable == false, "competitive score must never be purchasable")

	local expectedCategories = {
		Trails = true,
		LandingEffects = true,
		PlatformThemes = true,
		EnvironmentThemes = true,
	}
	for category in expectedCategories do
		local definition = CosmeticConfig.Categories[category]
		assert(definition ~= nil, "missing cosmetic category " .. category)
		assert(definition.Items[definition.Default] ~= nil, "default item missing for " .. category)
		assert(definition.Items[definition.Default].Price == 0, "default cosmetic must be free for " .. category)
		local count = 0
		for _, item in definition.Items do
			count += 1
			assert(type(item.Price) == "number" and item.Price >= 0, "invalid cosmetic price in " .. category)
		end
		assert(count >= 3, "cosmetic category too small: " .. category)
	end

	local profile = ProfileRules.defaultProfile()
	profile.Coins = 1000
	local invalidCategory, invalidCategoryReason = ProfileRules.validatePurchase(profile, "Nope", "x")
	assert(not invalidCategory and invalidCategoryReason == "invalid_category", "invalid purchase category accepted")
	local unknownItem, unknownItemReason = ProfileRules.validatePurchase(profile, "Trails", "not_real")
	assert(not unknownItem and unknownItemReason == "unknown_item", "unknown cosmetic accepted")
	profile.Coins = 0
	local poor, poorReason = ProfileRules.validatePurchase(profile, "Trails", "ion")
	assert(not poor and poorReason == "insufficient_coins", "unaffordable cosmetic accepted")
	local equipUnowned, equipUnownedReason = ProfileRules.validateEquip(profile, "Trails", "ion")
	assert(not equipUnowned and equipUnownedReason == "not_owned", "unowned cosmetic equipped")

	local legacy = ProfileRules.migrate({ Version = 0, Coins = 12.9 })
	assert(legacy.Version == EconomyConfig.ProfileVersion and legacy.Coins == 12, "profile migration/version mismatch")

	assert(
		ProfileStorageRules.isForeignActiveLock({ JobId = "other", ExpiresAt = 200 }, "self", 100),
		"active foreign lock must block"
	)
	assert(
		not ProfileStorageRules.isForeignActiveLock({ JobId = "other", ExpiresAt = 90 }, "self", 100),
		"expired lock must recover"
	)

	local profileSource = fs.readFile("src/server/services/ProfileService.luau")
	assert(
		string.find(profileSource, "EconomyRules.landingCoins", 1, true),
		"ProfileService must use tested economy rules"
	)
	assert(string.find(profileSource, "ProfileRules.validatePurchase", 1, true), "server purchase validation missing")
	assert(string.find(profileSource, "ProfileRules.validateEquip", 1, true), "server equip validation missing")
end
