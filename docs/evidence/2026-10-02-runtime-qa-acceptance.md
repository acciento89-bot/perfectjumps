# Perfect Jump — Runtime QA acceptance

Date: 2026-10-02

## Verified source

Commit: `982d9f0872e4b05dee8fdf860d1f852cd7435e9d`

Static verification on the exact source:
- StyLua: pass
- Selene: 0 errors / 0 warnings / 0 parse errors
- Pure Luau tests: 10 modules passed
- Reachability test: 2,000 generated platform targets satisfy the configured launch model
- Rojo build: pass

## Studio runtime QA

The built-in Studio runtime harness completed successfully after corrective fixes.

Verified:
- profile load
- safe initial round/platform
- avatar spawn
- 60 consecutive accepted landings
- Ready state after every landing
- platform progression to 60
- combo progression to 60
- personal-best/highest-platform progression
- legitimate cosmetic purchase
- server-authoritative cosmetic equip
- daily reward path
- failure transition
- immediate retry
- retry resets score/combo/platform state
- revive inventory path
- revive transition
- revived run marked assisted
- persistent payload contains highest platform and equipped trail
- all configured cosmetic categories expose valid defaults

Final runtime marker:
`[PerfectJumpQA] COMPLETE`

## Corrective defects found and fixed

Two real retry/respawn races were found by the runtime harness:

1. Old Humanoid `Died` listeners could fire while `LoadCharacter()` replaced the character and push the new retry/revive back to GameOver.
2. During lane rebuild, the old avatar could briefly be far from the new platform-0 lane and Heartbeat could classify it as OutOfBounds.

Fixes:
- disconnect stale character listeners before retry/revive `LoadCharacter()`;
- add a `RespawnGuard` that suspends Heartbeat failure checks until the new character is positioned.

The complete runtime suite passes after both corrections.
