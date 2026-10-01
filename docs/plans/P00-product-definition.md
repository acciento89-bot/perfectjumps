# P00 - Product Definition

## Goal
Freeze Perfect Jump's tiny V1 scope before implementation so speed never turns into scope drift.

## P00-T01 Identity and terminology
- Display name: **Perfect Jump**
- Internal project ID: `perfect_jump`
- Primary score: `Score`
- Best-score field: `BestScore`
- Consecutive Perfect landings: `Combo`
- Soft currency: `Coins`
- Landing grades: `Perfect`, `Good`, `Safe`, `Miss`
- One gameplay run is a `Round`

## P00-T02 Core gameplay constants
V1 starts with one visible-avatar mechanic:
1. avatar stands on the current platform
2. player holds the primary action to charge jump power
3. release launches toward the next platform
4. landing position is graded against the platform center
5. successful landing immediately generates the next platform
6. missing the platform ends the round
7. retry returns to gameplay with one obvious action

Initial tuning guardrails:
- charge duration: 0.12-1.20 seconds
- initial platform width: 10 studs
- minimum late-game platform width: 4.5 studs
- initial gap: 7 studs
- maximum V1 generated gap: 17 studs
- Perfect center radius: 0.75 studs
- Good center radius: 2.25 studs
- Safe radius is derived from platform half-width minus edge margin
- generator must never create an impossible jump under the configured movement model

## P00-T03 Monetization boundaries
Allowed:
- one-round revive/continue
- temporary wider Perfect zone
- temporary coin multiplier
- cosmetic trails
- landing effects
- platform/environment themes

Not allowed:
- buying leaderboard score
- silently boosting recorded best score
- purchase prompt on spawn
- paid-only access to the base mechanic

## P00-T04 Difficulty and failure lock
- Warm-up band: platforms 1–8, wider surfaces and conservative lateral offsets.
- Rhythm band: platforms 9–20, gradually longer gaps and narrower landing surfaces.
- Precision band: platform 21 onward, capped at the configured 17-stud center gap and 4.5-stud minimum width.
- A Miss, falling below the failure boundary or leaving the lane envelope ends the round exactly once.
- V1 allows at most one paid revive per round; revive returns to the last validated platform and does not directly grant score.
- Normal Retry starts a fresh score/combo round immediately while retaining account progression.

## P00-T05 Fairness lock
- Competitive score comes only from validated landings.
- Coin multipliers affect cosmetic currency only.
- Wider-Perfect-zone assistance must be disclosed and may not silently improve a competitive PB.
- Cosmetics never alter collision, launch velocity or platform reachability.
- No purchase prompt is allowed on first spawn.

## P00-T06 Feel acceptance criteria
- Charge input is edge-triggered: one hold creates at most one launch.
- Server time, not client-submitted duration, determines charge power.
- Air walk speed is 0 in V1; the launch vector is deterministic toward the active target.
- Repeating the same normalized charge from the same state must produce identical configured horizontal/vertical launch speeds.
- Release, failure and Retry must each change round state exactly once.
- Camera acceptance requires avatar + active target to remain in frame during Ready, Charging and Airborne phases.
- Runtime tuning must explicitly sample minimum, middle and maximum legal charge before release.

## Definition of Done
Identifiers, constants, air-control behavior, difficulty bands, failure/revive semantics, measurable feel criteria and monetization boundaries are stable enough for implementation without reopening product design.
