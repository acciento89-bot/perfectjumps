--!strict

return table.freeze({
	{ Name = "RoundAction", Kind = "Event", RateLimitPerSecond = 12 },
	{ Name = "RoundState", Kind = "Event", RateLimitPerSecond = 0 },
	{ Name = "GetPlayerState", Kind = "Function", RateLimitPerSecond = 3 },
	{ Name = "MetaStateChanged", Kind = "Event", RateLimitPerSecond = 0 },
	{ Name = "RequestMetaState", Kind = "Function", RateLimitPerSecond = 3 },
	{ Name = "PurchaseCosmetic", Kind = "Function", RateLimitPerSecond = 4 },
	{ Name = "EquipCosmetic", Kind = "Function", RateLimitPerSecond = 6 },
	{ Name = "ClaimDaily", Kind = "Function", RateLimitPerSecond = 2 },
	{ Name = "SetSetting", Kind = "Function", RateLimitPerSecond = 6 },
})
