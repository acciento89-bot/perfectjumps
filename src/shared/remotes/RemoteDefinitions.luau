--!strict

return table.freeze({
	{ Name = "RoundAction", Kind = "Event", RateLimitPerSecond = 12 },
	{ Name = "RoundState", Kind = "Event", RateLimitPerSecond = 0 },
	{ Name = "GetPlayerState", Kind = "Function", RateLimitPerSecond = 3 },
})
