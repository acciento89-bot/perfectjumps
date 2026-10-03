# Perfect Jump v11 published runtime acceptance — 2026-10-03

- Universe: `10768948354`
- Place: `74217245707666`
- Published Place version: `v11`
- Immediate rollback candidate: `v10`
- Dashboard name corrected from `Untitled Experience` to `Perfect Jump`.
- Content Maturity: `Minimal`
- Content descriptors: none
- Age restriction: none

## Runtime acceptance

The existing cloud Place was opened directly with Studio `EditPlace` and synced from canonical `main` through Rojo. The Studio-only QA flag was enabled locally for the test and reverted afterwards; it was not republished.

The runtime harness completed:
- 60/60 sequential landing transitions;
- PB and Perfect combo progression;
- cosmetic purchase/equip;
- Daily path;
- failure and Game Over;
- Retry/reset;
- Revive and assisted-run semantics;
- persistent profile payload;
- avatar spawn.

The run ended in `[PerfectJumpQA] COMPLETE`.

No new Roblox Place was created during this workflow.
