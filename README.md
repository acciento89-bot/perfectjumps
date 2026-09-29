# Perfect Jump

A compact third-person precision platformer. The visible Roblox avatar charges jump power, releases, lands on progressively harder platforms, builds Perfect combos and immediately retries after failure.

## Product rule

This is intentionally a **small-scope, high-quality Roblox game**. Small scope does not permit placeholder presentation, debug-looking UI, inaccessible geometry, broken mobile layouts or unverified monetization.

## Core loop

Hold to charge jump power, release to jump, land as close to the platform sweet spot as possible, then immediately face the next jump.

## Non-negotiables

- The Roblox avatar remains visible during core gameplay.
- Retry from failure must be fast and obvious.
- First-time understanding target: under 10 seconds.
- Short-session loop with score, best score and readable progression.
- Server-authoritative rewards, purchases and persistent progression.
- Mobile, tablet, desktop and controller support.
- No surprise purchase prompt on spawn.
- Monetization accelerates/revives/cosmetics; it must not directly buy leaderboard placement.
- Production-quality UI, lighting, sound/VFX and environment treatment before public release.
- No QA screenshots or temporary artifacts on the user's Desktop. Use `/tmp/perfectjumps-qa`; only intentionally retained evidence belongs under `docs/evidence/`.

## Monetization direction

Revive/continue, temporary wider Perfect zone, coin multiplier, cosmetic trails/landing effects, platform themes. No pay-to-win leaderboard placement.

## Canonical execution order

1. `README.md`
2. `docs/MASTER-PLAN.md`
3. `docs/ART-DIRECTION.md`
4. `docs/PERFECT-JUMP-V1-LEDGER.md`
5. Detail plan for the next open phase

The ledger is the source of truth for implementation state.
