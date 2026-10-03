# Perfect Jump — Monetization binding

Date: 2026-10-03

## Live Creator Hub products

- Revive — Developer Product `3716160802` — 29 R$
- Wider Perfect Zone - 5 min — Developer Product `3716161039` — 39 R$
- 2x Coins - 15 min — Developer Product `3716161121` — 49 R$
- Premium Themes — Game Pass `2006672673` — 99 R$

Managed/regional pricing is disabled for all four offers so the source-disclosed fixed Robux prices match Creator Hub.

## Fairness contract

- Revive marks the run assisted.
- Wider Perfect is limited to 300 seconds and marks the run assisted, so it cannot improve competitive PB progression.
- 2x Coins is limited to 900 seconds and changes coin rewards only, not score/PB.
- Premium Themes is cosmetic-only.

## Source and release guard

`MonetizationConfig` is bound to the four live Roblox IDs above. `ReadinessRules` now treats missing Developer Product or Game Pass IDs as release blockers, and the readiness test covers all seven required platform/monetization IDs.

Verification after binding:
- StyLua: pass
- Selene: 0 errors / 0 warnings / 0 parse errors
- Pure Luau tests: 10 modules passed
- Rojo build: pass
- Release readiness: Sandbox-ready yes / zero configuration blockers

A real paid Developer Product receipt/rejoin transaction remains a separate live-marketplace release gate and is not claimed by this configuration evidence.
