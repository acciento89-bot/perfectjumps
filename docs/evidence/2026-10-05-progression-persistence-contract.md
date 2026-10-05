# Perfect Jump progression/persistence contract - 2026-10-05

## Economy

- Landing coin rewards are centralized in pure `EconomyRules` and consumed by `ProfileService`.
- Perfect/Good/Safe base rewards are 3/2/1; Miss grants 0.
- CoinBoost only multiplies coin currency.
- `CompetitiveScorePurchasable == false`; score/PB remains server landing-derived.

## Cosmetic catalog and ownership

The production catalog contains all four locked categories:
- Trails
- LandingEffects
- PlatformThemes
- EnvironmentThemes

Each category has a valid free default and at least three items with non-negative prices.

Server validation rejects:
- invalid categories;
- unknown items;
- unaffordable purchases;
- equipping unowned items.

Fresh profiles own/equip only each category's default until server-validated purchase/equip mutation occurs.

## Versioning / migration / storage rules

- Profiles carry `EconomyConfig.ProfileVersion`.
- `ProfileRules.migrate` normalizes legacy payloads into the current schema and backfills new fields.
- Active foreign locks block acquisition.
- Same-server/expired/malformed-lock paths remain recoverable under tested storage rules.
- Mutation serialization prevents overlapping save/economy/receipt mutation for one player.

## Verification

- Test-first contract initially failed because pure EconomyRules did not exist.
- 32 pure-Luau test files pass.
- StyLua pass.
- Selene 0 errors / 0 warnings / 0 parse errors.
- Release-readiness Sandbox-ready; no configuration blockers.
- Rojo build and `git diff --check` pass.
- Fresh Studio QA retained:
  - cosmetic purchase pass;
  - cosmetic equip pass with Trail `ion`;
  - Daily path pass;
  - persistent in-memory payload with HighestPlatform 60 and Trail `ion`;
  - full `[PerfectJumpQA] COMPLETE`.

A real leave/rejoin against Roblox DataStore is intentionally tracked separately and is not claimed by this evidence.
