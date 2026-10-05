# Perfect Jump v23 runtime-hardening publish - 2026-10-05

- Universe: `10768948354`
- Existing production Place: `74217245707666`
- Published Place version: `v23`
- Immediate rollback candidate: `v22`
- Source commit published: `f62ad09a08dc34bfa969a55af5417e3e739f2faa`
- No new Place/Experience was created.

## Included hardening

- per-player serialized profile/economy/receipt/save mutations;
- explicit profile migration and tested DataStore lock rules;
- structured single-line `PJ_DIAG` persistence diagnostics;
- production-path spawn/charge/landing/fail/retry/respawn runtime journey;
- early/mid/late generated-difficulty runtime sampling;
- fresh tutorial completion runtime proof;
- client camera/input reset proof after Retry respawn.

## Publish / smoke evidence

Studio reported:
- `PublishSuccessful`
- `Add publish notes to v23`
- `Published new changes in "Perfekter Sprung" to Roblox.`

Immediate published-place Studio smoke:
- `[Perfect Jump] Server gameplay initialized`
- `[Perfect Jump] Client gameplay initialized`

Studio then returned `StudioAccessToApisNotAllowed` for live DataStore `UpdateAsync`, as expected while Studio API access is disabled. The new diagnostic path emitted a structured `PJ_DIAG event="profile_load_failed"` record. No live DataStore write/rejoin claim is made from this Studio smoke.
