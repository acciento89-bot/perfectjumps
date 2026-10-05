# Concept production publish - 2026-10-05

- Source commit: `cd7bc7760529b056774f5412ac72ca18fe5a8b4c`
- Existing Universe: `10768948354`
- Existing production Place: `74217245707666`
- Canonical `main` was synced through Rojo into the existing cloud Place; no new Place/Experience was created.
- Roblox Studio reported `PublishSuccessful`, `Published new changes in "Perfekter Sprung" to Roblox.` and publish notes target `v15`.
- Post-publish PlaySolo initialized server and client gameplay. Studio API access was disabled, so persistence used the existing Studio profile fallback; this was not a gameplay startup defect.
