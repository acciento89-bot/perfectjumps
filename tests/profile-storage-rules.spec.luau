local ProfileStorageRules = require("../src/shared/game/ProfileStorageRules")

return function()
	local foreign = { JobId = "server-b", ExpiresAt = 200 }
	assert(
		ProfileStorageRules.isForeignActiveLock(foreign, "server-a", 100) == true,
		"foreign active lock must block acquisition"
	)
	assert(
		ProfileStorageRules.isForeignActiveLock(foreign, "server-b", 100) == false,
		"same-server lock must be reacquirable"
	)
	assert(
		ProfileStorageRules.isForeignActiveLock(foreign, "server-a", 200) == false,
		"expired lock must be recoverable"
	)
	assert(
		ProfileStorageRules.isForeignActiveLock({ JobId = "server-b" }, "server-a", 100) == false,
		"malformed lock must not strand the profile"
	)

	local lock = ProfileStorageRules.lockFor("server-a", 100, 180)
	assert(lock.JobId == "server-a" and lock.ExpiresAt == 280, "lock expiry construction mismatch")
end
