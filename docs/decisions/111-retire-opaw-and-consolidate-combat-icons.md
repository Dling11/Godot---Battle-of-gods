# Decision 111: Retire Opaw and consolidate combat icons

- **Status:** Accepted
- **Date:** 2026-08-16

## Context

King is now the sole production player. Keeping Opaw's complete character, abilities, shop, awakening path, weapons, tests, processors, source art, and imported textures inside runtime folders increased Godot import work and left dead compatibility branches in shared player systems. Attack, Dash, and King's four active skills also used six separate imported images despite sharing one fixed HUD scale and palette.

## Decision

- Retire Opaw from runtime and preserve the removed package under `art_source/archive/retired_opaw_2026-08-16/`, below the repository's Godot-ignored source boundary.
- Migrate shared player progression, vitality, hurt/dash/level audio, generic ability-hit audio, save fixtures, and melee authority to neutral or King-owned resources before archiving Opaw.
- Remove the Opaw-only weapon shop and Skill 2 awakening UI. Orren remains a dialogue NPC; Eira opens the read-only view of King's four equipped skills.
- Use one generated hard-pixel `144x24` combat-action atlas with six fixed `24x24` cells in this order: Skill 1 Echoing Sever, Skill 2 Riftbreak, Skill 3 Sovereign Pursuit, Skill 4 Worldsplitter, Basic Attack, Dodge/Dash. Small `AtlasTexture` resources expose those cells to reusable HUD scenes.
- Archive images only after a runtime-reference audit. The 2026-08-16 audit also retires 30 unreferenced images and the unused four-item equipment-showcase prototype under `art_source/archive/retired_unused_assets_2026-08-16/`.

## Consequences

- Decisions 072 and 077 are superseded only where they require Opaw to remain a supported runtime character.
- Old version-1 weapon snapshots remain accepted for migration, but retired Opaw weapon IDs are discarded and replaced by King's default weapon.
- Skill 4's icon represents the already implemented Worldsplitter two-stage spirit-sword ability; it does not add a fifth skill or new combat mechanic.
- Archived files remain recoverable from source control, while Godot no longer scans or imports them.
