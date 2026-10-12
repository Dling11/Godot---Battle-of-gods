# Decision 092: Give Major Bosses One Reusable Top-Screen Health HUD

## Status

Accepted — 2026-08-14

## Context

The focused F8 arena had a duplicated hand-built proof bar, while the Combat Lab showed only the Stage 5 actor's small world-space enemy bar and latest-enemy text. Major boss presentation needs a consistent screen-space hierarchy that can later move into the real encounter without copying UI nodes or moving health authority into a level script.

## Alternatives

- Keep the F8-only panel and add another bespoke panel to Stage 5 later.
- Enlarge the actor-local `EnemyHealthBar` for boss entities.
- Put boss-health behavior directly inside `CombatHUD`.
- Create a reusable presentation scene bound explicitly by encounter owners.

## Decision

Add `BossHealthHUD` as an independent reusable Control. Its public `bind_boss()` accepts one authoritative `HealthComponent`, display title, and context. It observes health/death, updates the crimson front value immediately, eases an orange damage trail after a short delay, displays exact HP, and derives Phase I/II/III presentation from the approved 80% and 30% boundaries. Marker lines communicate those boundaries without owning them.

F8 binds its authored Stage 5 boss directly. Combat Lab binds the newest spawned Stage 5 boss, clears the HUD with simulation reset, and falls back to another valid spawned boss when the bound actor exits. The Stage 5 boss scene removes its actor-local `EnemyHealthBar`; only one health hierarchy is visible.

`STAGE 5 BOSS` and `COMBAT PROOF`/`COMBAT LAB` are honest development copy. This decision does not invent the final canon boss name.

## Consequences

- F8, Combat Lab, and the future real encounter can share one boss-health scene.
- UI never mutates health, selects jump counts, or triggers phase behavior.
- Major bosses using the screen HUD must not also carry a local enemy bar.
- Multiple bosses in the debug lab still show one deliberately selected latest-valid binding rather than stacked top bars.
- Final name/title, entrance treatment, and production encounter timing remain open.
