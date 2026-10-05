# Perfect Jump retention runtime acceptance - 2026-10-05

## Daily login

Fresh Studio profile claim:
- reward: 30 coins;
- observed coin delta: exactly 30;
- second same-day claim: rejected with `already_claimed`;
- no second coin mutation.

The production Daily modal already reflects authoritative `DailyClaimable` state and stays closed until the DAILY launcher is activated.

## Daily Perfect challenge

`RetentionRules.applyPerfectChallenge` is now the pure exact-once rule used by ProfileService:
- before threshold: progress increments, no reward;
- threshold crossing: reward flag/grant exactly once;
- later Perfects: progress continues, no duplicate reward.

Studio long-climb state finished with:
- Perfect progress: 63;
- required: 5;
- `DailyChallengeRewarded == true`.

## Achievements

Eligibility is centralized in `RetentionRules.eligibleAchievements`.
Fresh Studio journey earned all configured milestone classes:
- `first_jump`
- `first_perfect`
- `combo_5`
- `height_10`
- `height_25`

Achievement rewards remain idempotent because `awardAchievement` checks the authoritative profile-owned map before granting coins.

## PB / Perfect-chain / quick Retry feedback

Client feedback contract retains:
- reward cue for `NewPB`;
- reward cue for achievement coins;
- reward cue for Daily challenge coins;
- Perfect cue/ring escalation from authoritative combo;
- Retry cue on GameOver → Ready.

The same Studio run retained PB/highest-platform progression, Perfect chain growth, failure and immediate Retry and ended with `[PerfectJumpQA] COMPLETE`.

## Verification

- TDD RED: retention contract failed before challenge/achievement pure rules existed.
- 33 pure-Luau test files pass.
- StyLua pass.
- Selene: 0 errors / 0 warnings / 0 parse errors.
- Release-readiness: Sandbox-ready; no blockers.
- Rojo build and `git diff --check`: pass.
- No filtered CreatorError, Script Error, attempt-to-call or Infinite-yield match.
- Runtime-QA flag is disabled in committed source.
