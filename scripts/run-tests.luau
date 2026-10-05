local tests = {
	require("../tests/runtime-difficulty-qa.spec"),
	require("../tests/runtime-journey-qa.spec"),
	require("../tests/diagnostic-logging.spec"),
	require("../tests/profile-storage-contract.spec"),
	require("../tests/profile-migration.spec"),
	require("../tests/profile-storage-rules.spec"),
	require("../tests/profile-mutation-contract.spec"),
	require("../tests/mutation-gate.spec"),
	require("../tests/feedback-contract.spec"),
	require("../tests/runtime-grade-qa.spec"),
	require("../tests/runtime-launch-qa.spec"),
	require("../tests/graphic-fidelity.spec"),
	require("../tests/menu-visibility-contract.spec"),
	require("../tests/concept-showcase-ui.spec"),
	require("../tests/concept-fidelity.spec"),
	require("../tests/visual-polish.spec"),
	require("../tests/graphics-quality-rules.spec"),
	require("../tests/jump-rules.spec"),
	require("../tests/profile-rules.spec"),
	require("../tests/reachability-rules.spec"),
	require("../tests/receipt-rules.spec"),
	require("../tests/retention-rules.spec"),
	require("../tests/viewport-rules.spec"),
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
