local fs = require("@lune/fs")

local function section(source: string, startMarker: string, endMarker: string): string
	local startAt = assert(string.find(source, startMarker, 1, true), "missing " .. startMarker)
	local endAt = assert(string.find(source, endMarker, startAt + #startMarker, true), "missing " .. endMarker)
	return string.sub(source, startAt, endAt - 1)
end

return function()
	local source = fs.readFile("src/server/services/ProfileService.luau")
	assert(string.find(source, "MutationGate", 1, true), "ProfileService must require MutationGate")
	assert(
		string.find(source, "local mutationGate = MutationGate.new()", 1, true),
		"ProfileService must own a mutation gate"
	)

	local functions = {
		{ "function ProfileService.RecordLanding", "function ProfileService.ClaimDaily" },
		{ "function ProfileService.ClaimDaily", "function ProfileService.PurchaseCosmetic" },
		{ "function ProfileService.PurchaseCosmetic", "function ProfileService.EquipCosmetic" },
		{ "function ProfileService.EquipCosmetic", "function ProfileService.SetSetting" },
		{ "function ProfileService.SetSetting", "function ProfileService.ConsumeRevive" },
		{ "function ProfileService.ConsumeRevive", "local function applyProduct" },
		{ "function ProfileService.ProcessReceipt", "function ProfileService.Save" },
		{ "function ProfileService.Save", "function ProfileService.qaGrantCoins" },
	}
	for _, markers in functions do
		local body = section(source, markers[1], markers[2])
		assert(string.find(body, "mutationGate:Run(player", 1, true), markers[1] .. " must serialize profile mutation")
	end

	assert(
		string.find(source, "mutationGate:Forget(player)", 1, true),
		"player cleanup must release mutation gate state"
	)
end
