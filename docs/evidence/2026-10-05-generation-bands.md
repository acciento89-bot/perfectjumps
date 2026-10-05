# Perfect Jump generation-band acceptance - 2026-10-05

The procedural lane now exposes the locked product difficulty bands explicitly while preserving the existing production route for the default QA seed.

## Locked bands

- WarmUp: platforms 1–8.
- Rhythm: platforms 9–20.
- Precision: platform 21 onward.

Spacing remains deterministic:
- gap grows from the configured initial value toward the 17-stud cap;
- vertical step remains the configured 1.35 studs;
- lateral spread stays bounded and varies in both directions.

Platform/safe-zone pressure remains progressive:
- early width > Rhythm width > late Precision width;
- late width bottoms out at the configured 4.5-stud minimum;
- safe landing radius tightens with platform width.

## Pattern variety and deterministic QA seed

- Added configured `Generation.QaSeed = 0`.
- Seed 0 preserves the pre-existing production formula/layout.
- Same platform ID + same seed reproduces the same offset exactly.
- A different seed changes the lateral pattern without changing the gap/vertical model.
- The first 60 targets contain both lateral directions and at least 30 distinct lateral/gap signatures.
- Existing 2,000-target reachability regression remains green.

## Runtime verification

Fresh Studio QA after the refactor retained the same production samples:
- early target 1: width 10, horizontal distance 12.57395;
- mid target 21: width 8, horizontal distance 17.82782;
- late target 51: width 5, horizontal distance 17.41246.

All three passed production reachability and the full harness ended with `[PerfectJumpQA] COMPLETE`.

Static verification:
- 31 pure-Luau test files passed;
- StyLua pass;
- Selene 0 errors / 0 warnings / 0 parse errors;
- release readiness Sandbox-ready;
- Rojo build and `git diff --check` pass.
