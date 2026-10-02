local tests = {
	require("../tests/jump-rules.spec"),
	require("../tests/profile-rules.spec"),
	require("../tests/reachability-rules.spec"),
	require("../tests/receipt-rules.spec"),
	require("../tests/retention-rules.spec"),
	require("../tests/launch-rules.spec"),
	require("../tests/round-state-rules.spec"),
	require("../tests/readiness.spec"),
}

local passed = 0
for _, test in tests do
	test()
	passed += 1
end

print(("Perfect Jump: %d pure Luau tests passed"):format(passed))
