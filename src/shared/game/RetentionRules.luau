--!strict

local RetentionRules = {}

function RetentionRules.dayKey(unixTime: number): number
	return math.floor(unixTime / 86400)
end

function RetentionRules.canClaimDaily(lastClaimDay: number, currentDay: number): boolean
	return currentDay > lastClaimDay
end

function RetentionRules.normalizeChallengeDay(
	storedDay: number,
	currentDay: number,
	perfects: number,
	rewarded: boolean
): (number, number, boolean)
	if storedDay ~= currentDay then
		return currentDay, 0, false
	end
	return storedDay, math.max(0, math.floor(perfects)), rewarded
end

function RetentionRules.applyPerfectChallenge(
	perfects: number,
	rewarded: boolean,
	required: number
): (number, boolean, boolean)
	local nextPerfects = math.max(0, math.floor(perfects)) + 1
	local threshold = math.max(1, math.floor(required))
	local shouldGrant = not rewarded and nextPerfects >= threshold
	return nextPerfects, rewarded or shouldGrant, shouldGrant
end

function RetentionRules.eligibleAchievements(grade: string, combo: number, platformId: number): { string }
	local result = { "first_jump" }
	if grade == "Perfect" then
		table.insert(result, "first_perfect")
		if combo >= 5 then
			table.insert(result, "combo_5")
		end
	end
	if platformId >= 10 then
		table.insert(result, "height_10")
	end
	if platformId >= 25 then
		table.insert(result, "height_25")
	end
	return result
end

return table.freeze(RetentionRules)
