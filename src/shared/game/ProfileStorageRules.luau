--!strict

local ProfileStorageRules = {}

function ProfileStorageRules.isForeignActiveLock(lock: any, currentJobId: string, unixNow: number): boolean
	return type(lock) == "table"
		and type(lock.JobId) == "string"
		and lock.JobId ~= ""
		and type(lock.ExpiresAt) == "number"
		and lock.ExpiresAt > unixNow
		and lock.JobId ~= currentJobId
end

function ProfileStorageRules.lockFor(jobId: string, unixNow: number, lockSeconds: number)
	return {
		JobId = jobId,
		ExpiresAt = unixNow + math.max(1, lockSeconds),
	}
end

return table.freeze(ProfileStorageRules)
