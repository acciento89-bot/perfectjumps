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

## Definition of Done
Identifiers, constants and monetization boundaries are stable enough for P01/P03 to implement without reopening product design.
