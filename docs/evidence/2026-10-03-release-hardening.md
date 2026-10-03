# Perfect Jump — Release hardening

Date: 2026-10-03

## Canonical production identity

- Universe ID: `10768948354`
- Start / production Place ID: `74217245707666`
- `PlatformConfig.ProductionPlaceId` is now bound to the canonical place.
- Release-readiness reports `Sandbox-ready: yes` with no configuration blockers.

## First-jump correction

A pre-release physics audit found that the old first target was centered at about 7.13 studs while the minimum legal launch travels about 10.53 studs at the configured vertical step. That made Good/Perfect physically unavailable on the teaching jump.

The initial gap was retuned from 7 to 12.5 studs. The reachability regression now samples 201 legal charge values and requires:
- at least 80 Safe-or-better samples for platform 1;
- at least 15 Perfect samples for platform 1;
- all 2,000 generated targets to remain reachable.

## Monetization UI hardening
Developer Product controls now expose configured/not-live state explicitly instead of silently doing nothing. Premium Themes now has a dedicated Game Pass purchase/owned-state UI and remains explicitly cosmetic-only.

## Verification

After both changes:
- StyLua: pass
- Selene: 0 errors / 0 warnings / 0 parse errors
- Pure Luau tests: 10 modules passed
- Rojo build: pass
- Release-readiness: Sandbox-ready yes, no configuration blockers

Remaining external release gates are real Roblox product/pass IDs, live paid receipt + rejoin evidence, device/input smoke, final Creator Dashboard classification/store art, and public access.
