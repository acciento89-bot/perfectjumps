local fs = require("@lune/fs")

return function()
	local loggerPath = "src/shared/security/DiagnosticLog.luau"
	assert(fs.isFile(loggerPath), "diagnostic formatter missing")
	local logger = fs.readFile(loggerPath)
	local profile = fs.readFile("src/server/services/ProfileService.luau")
	local DiagnosticLog = require("../src/shared/security/DiagnosticLog")

	local formatted = DiagnosticLog.format("profile_save_failed", "warn", {
		UserId = 123,
		ReleaseLock = true,
		Error = "timeout\nretry",
	})
	assert(string.sub(formatted, 1, 7) == "PJ_DIAG", "diagnostic record prefix mismatch")
	assert(string.find(formatted, 'event="profile_save_failed"', 1, true), "diagnostic event missing")
	assert(string.find(formatted, 'severity="warn"', 1, true), "diagnostic severity missing")
	assert(string.find(formatted, "UserId=123", 1, true), "numeric field missing")
	assert(string.find(formatted, "ReleaseLock=true", 1, true), "boolean field missing")
	assert(not string.find(formatted, "\n", 1, true), "diagnostic values must stay single-line")

	assert(string.find(logger, "PJ_DIAG", 1, true), "diagnostic records need a stable machine-readable prefix")
	assert(string.find(logger, "function DiagnosticLog.format", 1, true), "diagnostic formatter missing")
	assert(
		string.find(profile, 'DiagnosticLog.format("profile_load_failed"', 1, true),
		"load failure diagnostic missing"
	)
	assert(string.find(profile, 'DiagnosticLog.format("profile_lock_blocked"', 1, true), "lock diagnostic missing")
	assert(
		string.find(profile, 'DiagnosticLog.format("profile_save_failed"', 1, true),
		"save failure diagnostic missing"
	)
	assert(
		string.find(profile, 'DiagnosticLog.format("receipt_transaction_failed"', 1, true),
		"receipt diagnostic missing"
	)
end
