# Perfect Jump remote/security hardening - 2026-10-05

## Remote/rate-limit audit

All inbound client-callable surfaces now have server-side throttling aligned with `RemoteDefinitions`:

- `RoundAction`: 12 actions/second rolling server window.
- `GetPlayerState`: 3 requests/second.
- `RequestMetaState`: 3 requests/second.
- `PurchaseCosmetic`: 4 requests/second.
- `EquipCosmetic`: 6 requests/second.
- `ClaimDaily`: 2 requests/second.
- `SetSetting`: 6 requests/second.

Server-to-client remotes (`RoundState`, `MetaStateChanged`) do not need inbound rate limits. Developer Product receipts enter through Roblox `MarketplaceService.ProcessReceipt`, not a client-supplied grant remote.

## Server authority

The client can only send a string action for the round. It never submits held duration, launch velocity, landing grade or score.

- Charge duration is measured with server `os.clock()`.
- Launch impulse is calculated and assigned by the server.
- Landing distance is measured from server-observed character/target positions.
- Grade and score are derived from server-side rules.
- Economy/profile mutations remain server-owned and serialized.

## Position / teleport / invalid-value validation

Added `GameplayValidation` and server guards for:

- NaN / +∞ / -∞ numbers and vector components.
- Excessive horizontal distance from the active lane.
- Excessive vertical displacement from the active lane.
- Invalid root/target/current positions before launch/landing.
- Heartbeat out-of-bounds/fall validation.

## Verification

- Test-first RED failed because `GameplayValidation` did not exist.
- GREEN: 29 pure-Luau test files passed.
- StyLua: pass.
- Selene: 0 errors / 0 warnings / 0 parse errors.
- Release readiness: Sandbox-ready; no blockers.
- Rojo build: pass.
- `git diff --check`: pass.
- Fresh Studio QA under the hardened guards emitted `[PerfectJumpClientQA] COMPLETE` and `[PerfectJumpQA] COMPLETE`.
- No filtered CreatorError, Script Error, attempt-to-call or Infinite-yield match occurred.
- The committed runtime-QA flag remains disabled.
