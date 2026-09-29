# P01 - Technical Foundation

## Goal
Create a small but production-grade Roblox codebase with server/client/shared boundaries, deterministic pure rules, CI and a single verification path.

## P01-T01 Rojo/source layout
- `src/shared`: pure rules/config/remotes
- `src/server`: authoritative game services/bootstrap
- `src/client`: input/camera/UI/presentation
- `tests`: pure-Luau specifications
- `scripts`: test/release-readiness runners

Acceptance:
- `rojo build default.project.json` succeeds.

## P01-T02 Shared config/remotes/state
Centralize:
- product/platform config
- gameplay tunables
- remote registry
- landing/charge/scoring rules
- round state transitions

Acceptance:
- no core mechanic requires UI-owned magic numbers.

## P01-T03 Toolchain
Pinned Rokit tools:
- Rojo
- StyLua
- Selene
- Lune

Acceptance:
- formatter check and Selene complete without warnings/errors.

## P01-T04 CI/release readiness
GitHub Actions executes:
1. formatting
2. lint
3. Rojo build
4. pure tests
5. release-readiness report

Acceptance:
- workflow is deterministic from a fresh checkout.

## P01-T05 Dev/prod platform config
Universe/place/product IDs live only in one shared config module. Unknown IDs stay explicit `0` values and are reported as external configuration blockers rather than scattered placeholders.

## Definition of Done
P02 can implement the character loop without restructuring the project.
