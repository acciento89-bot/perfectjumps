--!strict

local GraphicsQualityRules = {}

function GraphicsQualityRules.isLow(savedQualityValue: number): boolean
	return savedQualityValue >= 1 and savedQualityValue <= 3
end

function GraphicsQualityRules.profile(savedQualityValue: number)
	local low = GraphicsQualityRules.isLow(savedQualityValue)
	return table.freeze({
		Low = low,
		DecorativePointLightsEnabled = not low,
		BloomEnabled = not low,
		TrailLifetimeScale = if low then 0.65 else 1,
	})
end

return table.freeze(GraphicsQualityRules)
