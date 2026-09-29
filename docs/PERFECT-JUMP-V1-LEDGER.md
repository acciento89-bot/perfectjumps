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
- [ ] P00-T01 Lock “Perfect Jump” identity and score vocabulary
- [ ] P00-T02 Lock charge duration, min/max impulse and air-control rules
- [ ] P00-T03 Lock target/sweet-zone sizes and Perfect/Good/Miss thresholds
- [ ] P00-T04 Lock platform spacing/difficulty bands and fail/revive rules
- [ ] P00-T05 Lock monetization fairness and cosmetic categories
- [ ] P00-T06 Measurable feel/release acceptance criteria

## P01 Technical foundation
- [ ] P01-T01 Rojo client/server/shared layout
- [ ] P01-T02 Shared config/remotes/state
- [ ] P01-T03 Pure jump/round/scoring rule modules
- [ ] P01-T04 Selene/StyLua/tests/build tooling
- [ ] P01-T05 CI + release-readiness checks
- [ ] P01-T06 Dev/prod place and canonical-build policy

## P02 Character, camera and input
- [ ] P02-T01 Safe spawn and starting platform
- [ ] P02-T02 Charge input abstraction for touch/mouse/keyboard/controller
- [ ] P02-T03 Input state cleans up correctly on focus loss, death and retry
- [ ] P02-T04 Camera frames avatar + current platform + target platform during charge
- [ ] P02-T05 Flight camera follows arc without losing target or inducing excessive motion
- [ ] P02-T06 Landing camera settles cleanly before next jump
- [ ] P02-T07 Runtime spawn → charge → jump → land → fail → retry → respawn

## P03 Precision jump mechanic
- [ ] P03-T01 Deterministic charge-to-impulse mapping
- [ ] P03-T02 Server validates legal charge duration/action sequence
- [ ] P03-T03 Jump launch prevents duplicate release or stale input
- [ ] P03-T04 Stable air/landing state detection
- [ ] P03-T05 Edge landings, bounces and sliding cannot double-score
- [ ] P03-T06 Failure boundary triggers once
- [ ] P03-T07 Runtime tuning at min/mid/max charge
- [ ] P03-T08 100-jump repeatability sample shows no unexplained impulse drift

## P04 Landing grade, score and combo
- [ ] P04-T01 Server computes landing center distance from platform sweet zone
- [ ] P04-T02 Perfect/Good/Safe/Miss thresholds are explicit and tested
- [ ] P04-T03 Combo/multiplier rules and break conditions
- [ ] P04-T04 PB/highest-platform persistence
- [ ] P04-T05 Grade feedback appears at landing without hiding next target
- [ ] P04-T06 Anti-replay/duplicate-score guards

## P05 Platform generation and difficulty
- [ ] P05-T01 Reachability envelope derived from actual jump model
- [ ] P05-T02 Horizontal/vertical spacing by difficulty band
- [ ] P05-T03 Platform size/sweet-zone progression
- [ ] P05-T04 Pattern variety without blind/impossible jumps
- [ ] P05-T05 Deterministic QA seed
- [ ] P05-T06 1,000+ generated targets all satisfy reachability model
- [ ] P05-T07 Runtime sample across early/mid/late difficulty

## P06 Progression and persistence
- [ ] P06-T01 Legitimate coin/reward model
- [ ] P06-T02 Trail, landing effect, platform/environment theme catalog
- [ ] P06-T03 Server ownership/equip validation
- [ ] P06-T04 Versioned profile schema/migration
- [ ] P06-T05 Save/lock/recovery rules
- [ ] P06-T06 Real rejoin retains PB, coins, cosmetics and settings

## P07 Tutorial and retention
- [ ] P07-T01 First-time tutorial: hold → release → aim for center
- [ ] P07-T02 First target is forgiving enough to teach the relation between charge and distance
- [ ] P07-T03 Daily login
- [ ] P07-T04 Daily jump/Perfect challenge
- [ ] P07-T05 Achievement milestones
- [ ] P07-T06 PB/Perfect-chain celebration and quick retry

## P08 Monetization
- [ ] P08-T01 Final products/passes/prices
- [ ] P08-T02 Revive returns to last valid platform
- [ ] P08-T03 Wider-Perfect-zone boost is temporary, disclosed and excluded from competitive score if required by design
- [ ] P08-T04 Coin multiplier does not buy leaderboard progress
- [ ] P08-T05 Receipt allowlist/idempotency/serialization
- [ ] P08-T06 Explicit purchase UI and ownership states
- [ ] P08-T07 Duplicate/retry/aborted purchase tests
- [!] P08-T08 Real Developer Product receipt + rejoin verification

## P09 Production UI/UX
- [ ] P09-T01 Charge meter is legible and responsive
- [ ] P09-T02 Target/sweet-zone visual is clear without excessive Neon
- [ ] P09-T03 Score/combo/PB hierarchy
- [ ] P09-T04 Result/retry flow
- [ ] P09-T05 Shop/cosmetic previews
- [ ] P09-T06 Compact phone/tablet/desktop layouts
- [ ] P09-T07 Controller focus and accessibility/reduced-motion

## P10 Production art
- [ ] P10-T01 Distinct platform-world environment
- [ ] P10-T02 Platforms have production silhouettes/materials/edge detail
- [ ] P10-T03 Sweet zone is integrated into art, not a debug decal
- [ ] P10-T04 Avatar remains readable against every theme
- [ ] P10-T05 Lighting/background depth supports judging distance
- [ ] P10-T06 Screenshot-quality acceptance at charge, mid-flight and landing

## P11 Audio and VFX
- [ ] P11-T01 Charge buildup audio/visual
- [ ] P11-T02 Release/air cue without noise
- [ ] P11-T03 Landing grade cues
- [ ] P11-T04 Perfect-chain escalation
- [ ] P11-T05 Failure/retry/PB/reward cues
- [ ] P11-T06 Owned/Roblox-safe assets and reduced-motion/audio QA

## P12 Security and persistence hardening
- [ ] P12-T01 Remote/rate-limit audit
- [ ] P12-T02 Client cannot submit impulse, landing grade or score
- [ ] P12-T03 Position/teleport/NaN/extreme-value validation
- [ ] P12-T04 Economy/purchase mutation serialization
- [ ] P12-T05 DataStore migration/lock/recovery
- [ ] P12-T06 Structured diagnostic logging

## P13 Mandatory full runtime journey
- [ ] P13-T01 Fresh spawn/tutorial
- [ ] P13-T02 Min/mid/max charge jumps
- [ ] P13-T03 Perfect + Good + edge landing + miss
- [ ] P13-T04 Combo build/break and PB update
- [ ] P13-T05 Failure → immediate retry
- [ ] P13-T06 Reward and cosmetic buy/equip
- [ ] P13-T07 Revive
- [ ] P13-T08 Respawn camera/input reset
- [ ] P13-T09 New-session persistence/rejoin
- [ ] P13-T10 Extended repeated-jump stability

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
- [ ] P15-T03 Canonical private publish
- [ ] P15-T04 Full P13 journey repeated in published private place
- [ ] P15-T05 Build hash/place version/rollback record
- [!] P15-T06 Public launch after paid receipt/rejoin evidence and zero known P0/P1 defects

## P16 Post-launch
- [!] P16-T01 First telemetry review
- [!] P16-T02 Evidence-based jump/difficulty tuning
- [ ] P16-T03 Platform themes/effects/content cadence

## Definition of Done

Perfect Jump V1 is complete only when charge → release → flight → landing feels deterministic and fair on every supported input method, the camera stays useful throughout the arc, generated targets remain reachable, persistence survives rejoin and the published private build passes the full player journey.
