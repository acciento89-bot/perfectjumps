--!strict

local ReadinessRules = {}

function ReadinessRules.Evaluate(platform)
	local blockers = {}
	if platform.UniverseId <= 0 then
		table.insert(blockers, { Code = "UNIVERSE_ID", Detail = "Roblox UniverseId is not configured." })
	end
	if platform.DevelopmentPlaceId <= 0 then
		table.insert(blockers, { Code = "DEV_PLACE_ID", Detail = "Development place ID is not configured." })
	end
	if platform.ProductionPlaceId <= 0 then
		table.insert(blockers, { Code = "PROD_PLACE_ID", Detail = "Production place ID is not configured." })
	end
	return {
		ReadyForSandbox = #blockers == 0,
		Blockers = blockers,
	}
end

return table.freeze(ReadinessRules)
