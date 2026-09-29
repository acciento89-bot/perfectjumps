--!strict

local RoundStateRules = {}

export type Phase = "Ready" | "Charging" | "Airborne" | "Landed" | "GameOver"

local ALLOWED = {
	Ready = { Charging = true },
	Charging = { Airborne = true, Ready = true },
	Airborne = { Landed = true, GameOver = true },
	Landed = { Ready = true, GameOver = true },
	GameOver = { Ready = true },
}

function RoundStateRules.CanTransition(from: Phase, to: Phase): boolean
	local nextStates = ALLOWED[from]
	return nextStates ~= nil and nextStates[to] == true
end

return table.freeze(RoundStateRules)
