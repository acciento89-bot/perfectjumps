# Perfect Jump profile hardening acceptance - 2026-10-05

## Scope

This hardening pass serializes all profile mutations per player and centralizes profile-storage lock/migration rules without changing public gameplay behavior.

## Mutation serialization

- Added `MutationGate` with same-key serialization and guaranteed unlock on callback failure.
- `RecordLanding`, Daily claim, cosmetic purchase/equip, settings, revive consumption, receipt processing and explicit saves all pass through the same per-player mutation gate.
- Player cleanup forgets gate state.
- Autosave and shutdown saves route through the serialized save path.

## Storage and migration

- Stored profiles now use explicit `ProfileRules.migrate` before normalization.
- DataStore lock construction and foreign-active-lock checks are centralized in `ProfileStorageRules`.
- Pure tests cover foreign lock rejection, same-server reacquisition, expired-lock recovery, malformed-lock recovery and lock expiry construction.
- Legacy-profile migration tests verify version upgrade, numeric normalization, setting preservation/default backfill and receipt-field backfill.

## Verification

- StyLua: pass.
- Selene: 0 errors / 0 warnings / 0 parse errors.
- Pure-Luau suite: 23 test files passed.
- Release readiness: Sandbox-ready; no configuration blockers.
- Rojo build: pass.
- `git diff --check`: pass.
- Fresh local Studio PlayClient smoke reached normal gameplay with avatar, route, HUD and contextual Supply/Daily actions visible.
- Filtered Studio log contained no Perfect Jump Script/CreatorError, attempt-to-call, or Infinite-yield match. Roblox-internal asset/HTTP diagnostics were observed and are unrelated to this gameplay code.

## Remaining external proof

A real cross-session DataStore rejoin/migration/recovery proof is still required before treating persistence hardening as fully runtime-complete. This pass therefore does not close the real-rejoin gate.
