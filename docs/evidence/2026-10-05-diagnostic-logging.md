# Perfect Jump structured diagnostic logging - 2026-10-05

## Scope

Added a compact machine-readable diagnostic format for profile/persistence failure paths without changing player-facing behavior.

## Format

Records use a stable single-line prefix and deterministic key ordering:

`PJ_DIAG event="<event>" severity="<level>" key=value ...`

Control characters in values are normalized so one event stays on one log line.

## Covered failure paths

- DataStore initialization unavailable.
- Profile load failure/fallback.
- Foreign active profile lock.
- Profile save failure.
- Developer Product receipt transaction failure.

## TDD evidence

- Added `tests/diagnostic-logging.spec.luau` first.
- Initial RED failed because the diagnostic formatter did not exist.
- Added `DiagnosticLog.format` plus ProfileService integration.
- GREEN: full pure-Luau suite passes.

## Verification

- StyLua: pass.
- Selene: 0 errors / 0 warnings / 0 parse errors.
- Pure-Luau suite: 24 test files passed.
- Release readiness: Sandbox-ready; no configuration blockers.
- Rojo build: pass.
- `git diff --check`: pass.
- Fresh local Studio PlaySolo: `[Perfect Jump] Server gameplay initialized` and `[Perfect Jump] Client gameplay initialized`.
- Filtered runtime log contained no CreatorError, Script Error, attempt-to-call, or Infinite-yield match from Perfect Jump.
