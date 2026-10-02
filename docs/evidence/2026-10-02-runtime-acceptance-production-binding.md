# Perfect Jump — Runtime acceptance and production binding

Date: 2026-10-02

## Canonical source

- Repository: `acciento89-bot/perfectjumps`
- Retry/revive race fix: `f7e259851071ff8832edd54e251e19c3d741d383`
- Production identity:
  - Universe ID: `10768948354`
  - Start Place ID: `74217245707666`

## Defect found and fixed

The first end-to-end runtime run exposed a real retry race:
`LoadCharacter()` destroyed the previous Humanoid while its stale `Died`
listener was still connected. That callback could move the freshly reset round
back into `GameOver`.

The fix disconnects old character listeners before both Retry and Revive
character replacement.

## Post-fix runtime journey

The post-fix Studio runtime QA completed successfully.

Verified paths include:

- profile loaded
- deterministic 60-landing climb
- ready state after every landing
- PB/highest-platform progression
- Perfect combo progression
- cosmetic purchase
- cosmetic equip
- daily reward path
- failure path
- GameOver state
- Retry path
- Retry returns to Ready
- Retry resets active score/combo/current platform
- Revive inventory path
- Revive failure setup
- Revive path
- Revive returns to Ready
- Revive marks the run assisted
- persistent-profile payload contains highest platform / Perfects / equipped trail
- default cosmetic categories resolve correctly

The QA harness ended with `[PerfectJumpQA] COMPLETE`.

## Static verification

- StyLua: pass
- Selene: 0 errors / 0 warnings / 0 parse errors
- Pure Luau tests: 10 files passed
- Reachability test samples 2,000 generated targets
- Rojo production build: pass
- GitHub Actions CI for the race-fix commit: success

## Publication

The verified production `.rbxlx` was selected in Studio and the existing
private start place in Universe `10768948354` / Place `74217245707666`
was selected as the overwrite target.

Creator Dashboard metadata/content classification/public-access configuration
remains a dashboard release step until recorded as submitted.

## Residual gates not falsely claimed

- real DataStore new-session rejoin
- real Developer Product receipt + rejoin
- physical phone/tablet/controller smoke
- final Creator Dashboard content questionnaire
- final custom store-art upload
- public access toggle
