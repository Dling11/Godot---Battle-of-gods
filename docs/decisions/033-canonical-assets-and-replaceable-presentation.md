# Decision 033 - Give Assets Canonical Identities and Replaceable Presentation Contracts

- **Date:** 2026-07-14
- **Status:** Accepted

## Context

The prototype contains active runtime art, cleaned generation intermediates, original sources, and superseded experiments in overlapping folders. Generic names such as `player_sheet` and `sprites_24x32` make it easy for a human or AI session to confuse identity, lifecycle, and runtime usage. Upcoming title, Sanctuary, NPC, shop, and UI work will multiply that risk.

## Alternatives Considered

- Keep the current folders and rely on visual inspection.
- Delete superseded experiments and rename only new assets.
- Perform an immediate bulk move before documenting references.
- Establish canonical IDs, lifecycle states, theme constraints, and target paths before a controlled migration.

## Decision

`ART_DIRECTION.md` owns the shared visual promise, pixel baselines, palette roles, lighting, and replacement rules. `ASSET_CATALOG.md` owns canonical IDs, current runtime paths, target paths, dimensions, provenance status, and runtime consumers.

Runtime presentation remains replaceable through configured textures, scenes, and Theme resources. Backgrounds never contain baked-in controls or game logic. Non-runtime source, intermediate, and archived art will move under a Godot-ignored `art_source/` tree during a later controlled migration; it is preserved rather than deleted.

## Consequences

- Humans and AI sessions can identify assets without guessing from appearance.
- Backgrounds, icons, panels, and sprites can be replaced without rewriting gameplay logic.
- Asset moves require catalog, reference, generator, and test updates.
- Existing paths remain runtime truth until each migration step is verified.
- Downloaded and generated images require provenance and art-direction review before runtime approval.
