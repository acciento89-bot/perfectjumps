local fs = require("@lune/fs")

return function()
	local securityPath = "src/shared/security/GameplayValidation.luau"
	assert(fs.isFile(securityPath), "gameplay validation module missing")

	local GameplayValidation = require("../src/shared/security/GameplayValidation")
	assert(GameplayValidation.isFiniteNumber(0), "zero must be finite")
	assert(not GameplayValidation.isFiniteNumber(0 / 0), "NaN must be rejected")
	assert(not GameplayValidation.isFiniteNumber(math.huge), "positive infinity must be rejected")
	assert(not GameplayValidation.isFiniteNumber(-math.huge), "negative infinity must be rejected")
	assert(GameplayValidation.isFiniteVector3({ X = 1, Y = 2, Z = 3 }), "finite vector-like value rejected")
	assert(not GameplayValidation.isFiniteVector3({ X = 0 / 0, Y = 2, Z = 3 }), "NaN vector must be rejected")
	assert(
		GameplayValidation.isWithinHorizontalDistance({ X = 4, Y = 0, Z = 3 }, { X = 0, Y = 0, Z = 0 }, 5),
		"valid horizontal distance rejected"
	)
	assert(
		not GameplayValidation.isWithinHorizontalDistance({ X = 100, Y = 0, Z = 0 }, { X = 0, Y = 0, Z = 0 }, 5),
		"extreme horizontal distance accepted"
	)
	assert(
		GameplayValidation.isWithinVerticalDistance({ X = 0, Y = 5, Z = 0 }, { X = 0, Y = 0, Z = 0 }, 6),
		"valid vertical distance rejected"
	)
	assert(
		not GameplayValidation.isWithinVerticalDistance({ X = 0, Y = 100, Z = 0 }, { X = 0, Y = 0, Z = 0 }, 6),
		"extreme vertical distance accepted"
	)

	local round = fs.readFile("src/server/services/RoundService.luau")
	assert(
		string.find(round, "GameplayValidation.isFiniteVector3(root.Position)", 1, true),
		"root finite-position guard missing"
	)
	assert(
		string.find(round, "GameplayValidation.isFiniteVector3(round.Lane.TargetCollision.Position)", 1, true),
		"target finite-position guard missing"
	)
	assert(
		string.find(round, "GameplayValidation.isWithinVerticalDistance(", 1, true),
		"vertical teleport guard missing"
	)
	assert(
		string.find(round, "local stateRequestLimiter = RateLimiter.new(1 / 3)", 1, true),
		"GetPlayerState rate limiter missing"
	)
	assert(
		string.find(round, "if not stateRequestLimiter:Allow(player) then", 1, true),
		"GetPlayerState limiter not enforced"
	)
	assert(string.find(round, 'type(action) ~= "string"', 1, true), "round action payload type guard missing")

	local profile = fs.readFile("src/server/services/ProfileService.luau")
	assert(
		string.find(profile, "local metaLimiter = RateLimiter.new(1 / 3)", 1, true),
		"RequestMetaState rate limiter missing"
	)
	assert(string.find(profile, "local purchaseLimiter = RateLimiter.new(1 / 4)", 1, true), "purchase limiter mismatch")
	assert(string.find(profile, "local equipLimiter = RateLimiter.new(1 / 6)", 1, true), "equip limiter mismatch")
	assert(string.find(profile, "local dailyLimiter = RateLimiter.new(1 / 2)", 1, true), "daily limiter mismatch")
	assert(string.find(profile, "local settingLimiter = RateLimiter.new(1 / 6)", 1, true), "setting limiter mismatch")

	assert(
		string.find(round, "JumpRules.GradeLandingWithPerfectRadius(distance", 1, true),
		"landing grade must remain server-derived"
	)
	assert(string.find(round, "root.AssemblyLinearVelocity =", 1, true), "launch impulse must remain server-assigned")
	assert(
		not string.find(round, "clientScore", 1, true) and not string.find(round, "clientGrade", 1, true),
		"client score/grade input must not exist"
	)
end
