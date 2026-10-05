--!strict

local EconomyConfig = require("../config/EconomyConfig")
local MonetizationConfig = require("../config/MonetizationConfig")

local EconomyRules = {}

local BASE_REWARD = table.freeze({
	Perfect = EconomyConfig.PerfectCoins,
	Good = EconomyConfig.GoodCoins,
	Safe = EconomyConfig.SafeCoins,
})

function EconomyRules.landingCoins(grade: string, coinBoostActive: boolean): number
	local base = BASE_REWARD[grade] or 0
	if base <= 0 then
		return 0
	end
	if coinBoostActive then
		return base * MonetizationConfig.DeveloperProducts.CoinBoost15m.Multiplier
	end
	return base
end

return table.freeze(EconomyRules)
