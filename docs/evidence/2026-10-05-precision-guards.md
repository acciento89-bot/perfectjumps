# Perfect Jump precision guard runtime acceptance - 2026-10-05

Fresh Studio QA exercised the production charge/release, landing and failure guards directly.

## Charge/action sequence

- Duplicate release: first and second phase both remained `Airborne`; first/second launch speed were identical (`59.7086258`); duplicate token delta `0`.
- Stale charge: a hold beyond the legal server window was rejected back to `Ready`; launch speed stayed `0`.

## Landing guards

- Landing while not `Airborne` was ignored with no score/platform mutation.
- Upward target touch above the landing vertical-speed threshold was ignored.
- Double landing probe:
  - first landing: score delta `110`, platform delta `1`;
  - second immediate landing call: score delta `0`, platform delta `0`;
  - phase stayed `Landed` until the normal settle transition.

## Failure idempotency

- First failure changed the action token by exactly `1` and entered `GameOver`.
- Second failure call while already in `GameOver` changed the token by `0`.
- Retry then returned to `Ready`.

## Combo/PB journey

- A Perfect landing produced combo `1`.
- The following Good landing reset combo to `0`.
- The existing long-climb runtime path continued through 60 generated landings and PB/highest-platform progression.

## Verification

- Test-first runtime contract added before helpers/events.
- Pure-Luau suite: 30 test files passed.
- StyLua: pass.
- Selene: 0 errors / 0 warnings / 0 parse errors.
- Rojo build: pass.
- Full Studio harness ended with `[PerfectJumpQA] COMPLETE`.
- No filtered CreatorError, Script Error, attempt-to-call or Infinite-yield match occurred.
- Committed runtime-QA flag remains disabled.
