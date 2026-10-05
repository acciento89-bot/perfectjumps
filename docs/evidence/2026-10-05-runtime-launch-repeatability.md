# Perfect Jump runtime launch repeatability - 2026-10-05

## Scope

Added a Studio-only launch sampler that exercises the same server launch path used by production charge release. The QA flag remains disabled in committed source and was enabled only for the local Studio acceptance build.

## Test-first implementation

- Added `tests/runtime-launch-qa.spec.luau` first.
- RED: suite failed with `runtime QA must sample 100 launches`.
- GREEN: added the Studio-only launch sampler, min/mid/max runtime checks and the 100-release repeatability gate.
- Final pure-Luau suite: 16 test files passed.
- StyLua: pass.
- Selene: 0 errors / 0 warnings / 0 parse errors.
- Release readiness: Sandbox-ready, no configuration blockers.
- Rojo build and `git diff --check`: pass.

## Studio runtime result

Fresh local PlaySolo completed the complete PerfectJump runtime harness and ended with `[PerfectJumpQA] COMPLETE`.

Production-path release measurements:

- Minimum charge: power `0.28`, horizontal speed `29.2799988`, vertical speed `39.0400009`.
- Midpoint charge: power `0.64`, horizontal speed `38.6399994`, vertical speed `45.5200005`.
- Maximum charge: power `1.00`, horizontal speed `48.0`, vertical speed `52.0`.
- Repeatability: `100/100` midpoint releases, maximum horizontal delta `0`, maximum vertical delta `0`.

The same run also retained the existing 60-landing climb, PB/combo progression, cosmetic purchase/equip, Daily, failure, Retry, Revive and persistent-payload checks.

## Landing grade matrix

A second RED→GREEN runtime-QA increment exercised the production server landing path at four geometric offsets:

- Perfect: returned grade `Perfect` and phase `Landed`, then `Ready`.
- Good: returned grade `Good` and phase `Landed`, then `Ready`.
- Safe/edge: returned grade `Safe` and phase `Landed`, then `Ready`.
- Miss: returned grade `Miss` and phase `GameOver`; Retry returned the run to `Ready`.
- The full harness again ended with `[PerfectJumpQA] COMPLETE`.

The QA helper only positions the avatar at a requested offset; `handleLanding` still computes the actual root-to-target distance and applies the production grade/failure path.

No gameplay CreatorError/ScriptError/Infinite-yield match was present in the filtered runtime QA output.
