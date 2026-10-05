# Perfect Jump V1 Quality Ledger

**Portfolio order:** 3 / 4 — build after Perfect Drop and Rising Steps. Precision physics and landing evaluation require stricter runtime tuning.

Status: `[ ]` open · `[~]` implemented but not fully runtime-verified · `[x]` verified complete · `[!]` externally/runtime blocked

## Release quality contract

Perfect Jump succeeds or fails on **feel**. The charge, release, arc, landing and camera must be consistent enough that misses feel like the player’s timing error, not system randomness.

Mandatory V1 rules:
- Avatar remains visible throughout charge, flight, landing and failure.
- Hold/release behavior is consistent across touch, mouse/keyboard and controller.
- Charge meter and jump outcome correspond predictably.
- Camera never hides the target landing platform.
- Landing grade is based on server-verifiable geometry, not client claims.
- Retry is immediate.
- Procedural platforms are physically reachable for the configured charge model.
- UI/art/audio must be production quality, not debug presentation.
- Progression and purchases persist across real rejoin.
- Full run must be tested in the actual published private place before release.
- QA captures use `/tmp/perfectjumps-qa`.

## P00 Product lock
- [x] P00-T01 Lock “Perfect Jump” identity and score vocabulary
- [x] P00-T02 Lock charge duration, min/max impulse and air-control rules
- [x] P00-T03 Lock target/sweet-zone sizes and Perfect/Good/Miss thresholds
- [x] P00-T04 Lock platform spacing/difficulty bands and fail/revive rules
- [x] P00-T05 Lock monetization fairness and cosmetic categories
- [x] P00-T06 Measurable feel/release acceptance criteria

## P01 Technical foundation
- [x] P01-T01 Rojo client/server/shared layout
- [x] P01-T02 Shared config/remotes/state
- [x] P01-T03 Pure jump/round/scoring rule modules
- [x] P01-T04 Selene/StyLua/tests/build tooling
- [x] P01-T05 CI + release-readiness checks
- [x] P01-T06 Dev/prod place and canonical-build policy


P00/P01 verification note (2026-10-01): product vocabulary, charge/air-control rules, landing thresholds, difficulty bands, revive/fairness rules and measurable feel criteria are locked in `docs/plans/P00-product-definition.md`. Rojo/source layout, centralized config/remotes/state, pure rule modules, pinned toolchain, CI and canonical platform-ID policy are present. Commit `ac2ac618...` passed GitHub Actions; the current docs-only P00 follow-up does not alter runtime code. Local verification on the canonical main source also passes StyLua, Selene (0 errors/0 warnings), Rojo build and 4 pure-Luau test files. Release-readiness correctly reports only the three external Roblox ID blockers.

P02/P03 implementation note (2026-10-01): `main` now contains a per-player authored safe lane, unified touch/mouse/keyboard/controller charge input, focus/death charge cleanup, scriptable avatar+target camera, server-timed hold/release, deterministic launch speeds, server-only landing grade/score, duplicate-state guards, failure boundary and immediate Retry. Runtime/device acceptance remains intentionally unclaimed until Studio QA is run.

## P02 Character, camera and input
- [~] P02-T01 Safe spawn and starting platform
- [~] P02-T02 Charge input abstraction for touch/mouse/keyboard/controller
- [~] P02-T03 Input state cleans up correctly on focus loss, death and retry
- [~] P02-T04 Camera frames avatar + current platform + target platform during charge
- [~] P02-T05 Flight camera follows arc without losing target or inducing excessive motion
- [~] P02-T06 Landing camera settles cleanly before next jump
- [x] P02-T07 Runtime spawn → charge → jump → land → fail → retry → respawn — fresh Studio QA exercised the production launch/landing path, GameOver, Retry and a distinct replacement character returning to Ready/platform 0. Evidence: `docs/evidence/2026-10-05-runtime-journey.md`

## P03 Precision jump mechanic
- [x] P03-T01 Deterministic charge-to-impulse mapping
- [~] P03-T02 Server validates legal charge duration/action sequence
- [~] P03-T03 Jump launch prevents duplicate release or stale input
- [~] P03-T04 Stable air/landing state detection
- [~] P03-T05 Edge landings, bounces and sliding cannot double-score
- [~] P03-T06 Failure boundary triggers once
- [x] P03-T07 Runtime tuning at min/mid/max charge — production launch path measured in Studio at all three charge points; evidence: `docs/evidence/2026-10-05-runtime-launch-repeatability.md`
- [x] P03-T08 100-jump repeatability sample shows no unexplained impulse drift — 100/100 midpoint production-path releases measured with 0 horizontal and 0 vertical velocity delta; evidence: `docs/evidence/2026-10-05-runtime-launch-repeatability.md`

## P04 Landing grade, score and combo
- [x] P04-T01 Server computes landing center distance from platform sweet zone — Studio landing matrix positions the avatar at known offsets while production `handleLanding` computes root-to-target geometry and returns the expected grades
- [x] P04-T02 Perfect/Good/Safe/Miss thresholds are explicit and tested
- [x] P04-T03 Combo/multiplier rules and break conditions
- [~] P04-T04 PB/highest-platform persistence — profile payload/runtime progression verified; real new-session rejoin remains open
- [~] P04-T05 Grade feedback appears at landing without hiding next target
- [~] P04-T06 Anti-replay/duplicate-score guards

## P05 Platform generation and difficulty
- [x] P05-T01 Reachability envelope derived from actual jump model
- [~] P05-T02 Horizontal/vertical spacing by difficulty band
- [~] P05-T03 Platform size/sweet-zone progression
- [~] P05-T04 Pattern variety without blind/impossible jumps
- [~] P05-T05 Deterministic QA seed
- [x] P05-T06 1,000+ generated targets all satisfy reachability model — current pure test covers 2,000 generated targets
- [x] P05-T07 Runtime sample across early/mid/late difficulty — actual generated targets at platform progression 0/20/50 passed production reachability; target widths tightened 10 → 8 → 5. Evidence: `docs/evidence/2026-10-05-runtime-difficulty-sampling.md`

## P06 Progression and persistence
- [~] P06-T01 Legitimate coin/reward model
- [~] P06-T02 Trail, landing effect, platform/environment theme catalog
- [~] P06-T03 Server ownership/equip validation
- [~] P06-T04 Versioned profile schema/migration
- [~] P06-T05 Save/lock/recovery rules
- [!] P06-T06 Real rejoin retains PB, coins, cosmetics and settings — requires an actual live-player leave/rejoin against Roblox DataStore; published-place Studio smoke cannot prove it because Studio API access is disabled

## P07 Tutorial and retention
- [~] P07-T01 First-time tutorial: hold → release → aim for center — HUD flow implemented; physical-input runtime acceptance remains
- [x] P07-T02 First target is forgiving enough to teach the relation between charge and distance — regression test enforces broad Safe and reachable Perfect charge windows
- [~] P07-T03 Daily login
- [~] P07-T04 Daily jump/Perfect challenge
- [~] P07-T05 Achievement milestones
- [~] P07-T06 PB/Perfect-chain celebration and quick retry

## P08 Monetization
- [x] P08-T01 Final products/passes/prices — live Creator Hub IDs and fixed prices bound in source
- [~] P08-T02 Revive returns to last valid platform — runtime harness verified revive Ready/assisted path
- [x] P08-T03 Wider-Perfect-zone boost is temporary, disclosed and excluded from competitive PB progression
- [x] P08-T04 Coin multiplier does not buy leaderboard/PB progress — multiplier changes coin reward only
- [~] P08-T05 Receipt allowlist/idempotency/serialization
- [~] P08-T06 Explicit purchase UI and ownership states — live IDs + configured/owned states implemented; runtime prompt smoke remains
- [~] P08-T07 Duplicate/retry/aborted purchase tests
- [!] P08-T08 Real Developer Product receipt + rejoin verification

## P09 Production UI/UX
- [x] P09-T01 Charge meter is legible and responsive — live compact/tablet/desktop review confirms the charge control remains readable and unobstructed
- [x] P09-T02 Target/sweet-zone visual is clear without excessive Neon — live Studio review confirms integrated Good/Perfect target geometry with restrained cyan/amber precision accents
- [x] P09-T03 Score/combo/PB hierarchy — live HUD review confirms compact stats plus dedicated combo-progress hierarchy without covering the route
- [x] P09-T04 Result/retry flow — production result UI is event-driven and the Studio QA path verifies GameOver → Retry → Ready/reset
- [x] P09-T05 Shop/cosmetic previews — live Precision Supply modal plus authored cosmetic swatches/category actions verified in the production UI
- [x] P09-T06 Compact phone/tablet/desktop layouts — live Studio resize acceptance covered compact, tablet and wide desktop compositions without blocking avatar/target/charge controls
- [~] P09-T07 Controller focus and accessibility/reduced-motion — selectable controls, modal SelectedObject focus, ButtonA/ButtonX/ButtonY bindings, Reduced Motion and Audio settings are implemented; physical controller navigation remains P14 runtime evidence

## P10 Production art
- [x] P10-T01 Distinct platform-world environment — live authored aerial-highline environment verified in Studio
- [x] P10-T02 Platforms have production silhouettes/materials/edge detail — metal/diamond-plate bodies, precision borders, structural arches/masts and depth layers verified
- [x] P10-T03 Sweet zone is integrated into art, not a debug decal — production GoodZone, PerfectCore, LandingRing and TargetBracket geometry is integrated into the platform presentation
- [~] P10-T04 Avatar remains readable against every theme — default highline theme is visually accepted with avatar readability; remaining cosmetic themes still require visual cycling
- [x] P10-T05 Lighting/background depth supports judging distance — live Studio review confirms layered skyline/highline depth, atmospheric clouds and restrained precision lighting
- [~] P10-T06 Screenshot-quality acceptance at charge, mid-flight and landing — overall compact/tablet/desktop gameplay composition is accepted; charge/mid-flight/landing triptych remains open because OS-level input injection did not drive Roblox gameplay state

## P11 Audio and VFX
- [x] P11-T01 Charge buildup audio/visual — responsive charge meter plus dedicated Charge cue implemented and regression-tested
- [x] P11-T02 Release/air cue without noise — dedicated Release cue is phase-transition driven, rate-limited and covered by the feedback contract
- [x] P11-T03 Landing grade cues — distinct Perfect/Good/Safe audio and landing-ring feedback retained and the production grade matrix passed in Studio
- [x] P11-T04 Perfect-chain escalation — Perfect cue pitch and landing-ring emphasis now scale from authoritative combo while remaining capped
- [x] P11-T05 Failure/retry/PB/reward cues — Failure and Reward/PB cues retained; dedicated GameOver→Ready Retry cue added and full QA journey rerun
- [~] P11-T06 Owned/Roblox-safe assets and reduced-motion/audio QA — Roblox built-in audio, AudioEnabled guard, Reduced Motion guard and transient overlap cap are verified in source/tests; physical mobile-speaker mix/fatigue listen remains open

## P12 Security and persistence hardening
- [~] P12-T01 Remote/rate-limit audit
- [~] P12-T02 Client cannot submit impulse, landing grade or score
- [~] P12-T03 Position/teleport/NaN/extreme-value validation
- [x] P12-T04 Economy/purchase mutation serialization — all profile/economy/receipt/save mutations now share a tested per-player `MutationGate`; 23-test suite and Studio smoke pass. Evidence: `docs/evidence/2026-10-05-profile-hardening.md`
- [~] P12-T05 DataStore migration/lock/recovery — explicit profile migration plus tested lock construction/foreign-lock/expiry/malformed-lock recovery are implemented; real cross-session DataStore rejoin/recovery proof remains open. Evidence: `docs/evidence/2026-10-05-profile-hardening.md`
- [x] P12-T06 Structured diagnostic logging — stable single-line `PJ_DIAG` records now cover DataStore init, profile load/lock/save and receipt transaction failures; 24-test suite and fresh Studio server/client smoke pass. Evidence: `docs/evidence/2026-10-05-diagnostic-logging.md`

## P13 Mandatory full runtime journey
- [x] P13-T01 Fresh spawn/tutorial — fresh Studio profile starts with tutorial incomplete; HUD binds to the authoritative flag; first production-path landing flips completion true and the full QA harness completes. Evidence: `docs/evidence/2026-10-05-fresh-tutorial-runtime.md`
- [x] P13-T02 Min/mid/max charge jumps — Studio QA exercised the real server launch path at minimum, midpoint and maximum charge and matched configured velocity expectations
- [x] P13-T03 Perfect + Good + edge landing + miss — production server landing path verified in Studio for all four grades; Miss reached GameOver and recovered through Retry/Ready
- [~] P13-T04 Combo/PB progression verified by runtime harness; real player-input break cases remain open
- [x] P13-T05 Failure → immediate retry — post-fix runtime harness passes failure/GameOver/Retry/Ready/reset
- [x] P13-T06 Reward and cosmetic buy/equip — runtime harness passes coin grant, purchase and equip
- [x] P13-T07 Revive — runtime harness passes failure/revive/Ready/assisted
- [x] P13-T08 Respawn camera/input reset — Studio client QA verifies the replacement character owns the Scriptable camera/CameraSubject with current+target state loaded, while charging is false, phase is Ready and no modal remains open. Evidence: `docs/evidence/2026-10-05-respawn-camera-input.md`
- [!] P13-T09 New-session persistence/rejoin — external live-client/DataStore gate; Studio reports `StudioAccessToApisNotAllowed` by design, so no false rejoin claim is made
- [~] P13-T10 Extended repeated-jump stability — 60 generated landing transitions pass; physical repeated-input soak remains open

## P14 Device, input and performance QA
- [ ] P14-T01 Compact phone touch hold/release
- [ ] P14-T02 Tablet
- [ ] P14-T03 Desktop mouse/keyboard
- [ ] P14-T04 Controller analog/button behavior
- [ ] P14-T05 Camera/target readability per viewport
- [ ] P14-T06 Stable FPS/memory and platform cleanup

## P15 Release
- [ ] P15-T01 Production icon/thumbnails/metadata
- [ ] P15-T02 Privacy/content questionnaire
- [x] P15-T03 Canonical private publish — Universe 10768948354 / Place 74217245707666 republished from canonical main commit `f62ad09` as v23
- [x] P15-T04 Full P13 journey repeated in published private place — v11 Studio run completed 60/60 landings plus PB/combo, cosmetics, Daily, failure, Retry, Revive and persistent payload with `[PerfectJumpQA] COMPLETE`
- [x] P15-T05 Build hash/place version/rollback record — production Place v23 from source `f62ad09`; immediate rollback v22. Evidence: `docs/evidence/2026-10-05-v23-runtime-hardening-publish.md`
- [~] P15-T06 Public launch — zero known P0/P1 gameplay defects; owner directs completed games to public release. Content Maturity is Minimal with no age restriction; final store presentation/public toggle remains

## P16 Post-launch
- [!] P16-T01 First telemetry review
- [!] P16-T02 Evidence-based jump/difficulty tuning
- [ ] P16-T03 Platform themes/effects/content cadence

## Definition of Done

Perfect Jump V1 is complete only when charge → release → flight → landing feels deterministic and fair on every supported input method, the camera stays useful throughout the arc, generated targets remain reachable, persistence survives rejoin and the published private build passes the full player journey.


Runtime acceptance update (2026-10-02): post-fix Studio QA completed through 60 landing transitions, PB/combo progression, cosmetic purchase/equip, daily path, failure, Retry reset, Revive and persistent-profile payload, ending in `[PerfectJumpQA] COMPLETE`. The retry/revive character-listener race was fixed in `f7e259851071ff8832edd54e251e19c3d741d383`. Production identity is Universe `10768948354`, Start Place `74217245707666`; `PlatformConfig` is now bound on main. GitHub Actions is green. Real DataStore rejoin, physical-input/device smoke, real paid receipt, final store/questionnaire and public-access gates remain intentionally unclaimed. Evidence: `docs/evidence/2026-10-02-runtime-acceptance-production-binding.md`.

## 2026-10-04 concept visual-polish pass

- [x] Native Roblox concept-quality presentation pass implemented for this game; no static concept screenshot is used in gameplay.
- [x] Lighting/VFX and native ScreenGui styling are test-guarded and pass local static verification plus Studio PlaySolo runtime QA.
- [x] Evidence: `docs/evidence/2026-10-04-concept-visual-polish.md`.

## 2026-10-04 concept-fidelity pass 2

- [x] HUD now carries a branded wordmark, combo-progress hierarchy and compact quick actions while keeping hold/release gameplay unobstructed.
- [x] Highline world presentation gained brighter authored structure, cloud depth, hero gateway and warm sky focal point.
- [x] Final PlaySolo runtime: server/client gameplay initialized with 0 CreatorErrors; 12 pure-Luau tests and static gates green.

## 2026-10-05 concept production publish

- [x] Concept-fidelity source published to existing production Place `74217245707666` as `v15`.
- [x] Post-publish server/client gameplay initialization passed; only the expected Studio DataStore-access fallback was observed.
- [x] Concept-fidelity pass 3: live Jump Supply + progress/daily/highline preview cards, score/combo/PB pill and non-overlapping charge/tutorial composition are implemented and runtime-verified.

## 2026-10-05 graphic-fidelity pass 4

- [x] Source-side concept graphic fidelity implemented: Aerial highline depth, structural arches, motion ribbons, sky focal halo, target-ring and platform underside detail.
- [x] Contextual-menu rule preserved: full Shop/Daily/Style/Revive/Result surfaces are not permanently visible during normal gameplay.
- [x] CI verification green on run `37270778429`; merged source commit `fbd0b7a`.
- [x] Fresh Roblox Studio PlaySolo visual acceptance passed: aerial-highline composition, avatar/jump readability and contextual Supply/Daily behavior verified with clean local server/client startup.
- [x] Graphic-fidelity source published to existing canonical Place `74217245707666` as `v18`; no new Place/Experience created. Post-publish Studio persistence smoke is limited only by disabled Studio API access. Evidence: `docs/evidence/2026-10-05-graphic-fidelity-runtime-publish.md`.


## 2026-10-05 runtime/feedback production publish

- [x] Min/mid/max production-path launch measurements and 100-release repeatability are runtime-verified.
- [x] Perfect/Good/Safe/Miss production landing matrix plus Miss→Retry→Ready is runtime-verified.
- [x] UI/art/feedback pass is published to existing Place `74217245707666` as `v19` from source commit `42bb6ac`.
- [x] No new Place/Experience was created; contextual Supply/Daily/Result visibility contract remains preserved.
- [!] Remaining acceptance is device/external only for physical controller/touch, real paid receipt/rejoin, physical speaker mix and the charge/mid-flight/landing capture triptych.
