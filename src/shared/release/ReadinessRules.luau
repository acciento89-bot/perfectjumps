--!strict

local ReadinessRules = {}

function ReadinessRules.Evaluate(platform, monetization)
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
	if monetization then
		for productName, definition in monetization.DeveloperProducts do
			if definition.ProductId <= 0 then
				table.insert(blockers, {
					Code = "PRODUCT_ID_" .. string.upper(productName),
					Detail = ("Developer Product %s is not configured."):format(productName),
				})
			end
		end
		for passName, definition in monetization.GamePasses do
			if definition.GamePassId <= 0 then
				table.insert(blockers, {
					Code = "PASS_ID_" .. string.upper(passName),
					Detail = ("Game Pass %s is not configured."):format(passName),
				})
			end
		end
	end
	return {
		ReadyForSandbox = #blockers == 0,
		Blockers = blockers,
	}
end

return table.freeze(ReadinessRules)
