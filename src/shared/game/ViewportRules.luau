--!strict

local ViewportRules = {}

function ViewportRules.classify(width: number): string
	if width <= 760 then
		return "compact"
	elseif width <= 1100 then
		return "tablet"
	end
	return "desktop"
end

function ViewportRules.uiScale(width: number): number
	return math.clamp(width / 980, 0.80, 1.06)
end

function ViewportRules.cameraDistance(width: number, defaultDistance: number): number
	return if ViewportRules.classify(width) == "compact" then math.min(defaultDistance, 15.4) else defaultDistance
end

return table.freeze(ViewportRules)
