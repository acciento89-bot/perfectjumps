--!strict

local GameplayValidation = {}

function GameplayValidation.isFiniteNumber(value: any): boolean
	return type(value) == "number" and value == value and value ~= math.huge and value ~= -math.huge
end

function GameplayValidation.isFiniteVector3(value: any): boolean
	if value == nil then
		return false
	end
	return GameplayValidation.isFiniteNumber(value.X)
		and GameplayValidation.isFiniteNumber(value.Y)
		and GameplayValidation.isFiniteNumber(value.Z)
end

function GameplayValidation.isWithinHorizontalDistance(position: any, origin: any, maximumDistance: number): boolean
	if
		not GameplayValidation.isFiniteVector3(position)
		or not GameplayValidation.isFiniteVector3(origin)
		or not GameplayValidation.isFiniteNumber(maximumDistance)
		or maximumDistance < 0
	then
		return false
	end

	local deltaX = position.X - origin.X
	local deltaZ = position.Z - origin.Z
	local distanceSquared = deltaX * deltaX + deltaZ * deltaZ
	return GameplayValidation.isFiniteNumber(distanceSquared) and distanceSquared <= maximumDistance * maximumDistance
end

function GameplayValidation.isWithinVerticalDistance(position: any, origin: any, maximumDistance: number): boolean
	if
		not GameplayValidation.isFiniteVector3(position)
		or not GameplayValidation.isFiniteVector3(origin)
		or not GameplayValidation.isFiniteNumber(maximumDistance)
		or maximumDistance < 0
	then
		return false
	end

	local deltaY = math.abs(position.Y - origin.Y)
	return GameplayValidation.isFiniteNumber(deltaY) and deltaY <= maximumDistance
end

return table.freeze(GameplayValidation)
