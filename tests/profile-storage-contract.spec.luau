local fs = require("@lune/fs")

return function()
	local source = fs.readFile("src/server/services/ProfileService.luau")
	assert(string.find(source, "ProfileStorageRules", 1, true), "ProfileService must use ProfileStorageRules")
	assert(string.find(source, "ProfileRules.migrate", 1, true), "stored profiles must use explicit migration")
	assert(
		string.find(source, "ProfileStorageRules.isForeignActiveLock", 1, true),
		"DataStore lock checks must use tested storage rules"
	)
	assert(
		string.find(source, "ProfileStorageRules.lockFor", 1, true),
		"DataStore lock creation must use tested storage rules"
	)
end
