local ReceiptRules = require("../src/shared/game/ReceiptRules")

return function()
	local receipts = { a = true, b = true, c = true, d = true }
	assert(ReceiptRules.contains(receipts, "b") == true, "known receipt missing")
	assert(ReceiptRules.contains(receipts, "z") == false, "unknown receipt reported processed")
	assert(ReceiptRules.key(12345) == "12345", "receipt key normalization failed")

	local trimmed = ReceiptRules.trim(receipts, 2)
	local count = 0
	for _ in trimmed do
		count += 1
	end
	assert(count == 2, "receipt history did not trim to cap")
	assert(trimmed.c == true and trimmed.d == true, "receipt trim did not keep deterministic tail")
end
