# Decision 040: Split Playable Animation by Action While Locking Body Scale

- **Date:** 2026-07-15
- **Status:** Accepted

## Context

Opaw's first modular 4x8 atlas proved separate visible equipment, but one generated board coupled unrelated actions and frame counts. Directional poses drifted in apparent scale, the attack had no authored body progression, dash was one pose, and the defeat sequence had to share a narrow 32x32 cell. Fixing individual cells inside that board repeatedly risked new crop and scale errors.

## Alternatives Considered

- Continue repairing individual rows in the single 4x8 atlas.
- Keep one body frame and express every action through runtime offsets and weapon tweening.
- Use one large uniform cell size for every action.
- Author one source/runtime sheet per action while preserving a common animation API and body-scale contract.

## Decision

Opaw uses independent idle, walk, weaponless attack-body, dash, interaction, hurt, and defeat sheets. Every sheet stores canonical direction rows in `down`, `left`, `right`, `up` order and advances frames across columns. `opaw_sprite_frames.tres` continues to expose `<action>_<direction>`, so player scenes and menus do not depend on source-atlas layout.

The processor expands around each ideal generated cell, isolates the complete primary connected actor silhouette plus nearby pieces, removes chroma, quantizes hard alpha, and normalizes the first standing pose of every direction to an 18x27 silhouette on a y=32 foot baseline. This avoids both neighboring-pose contamination and fixed-inset clipping when a head or dash pose crosses the ideal grid line. All frames in that action/direction reuse the same source-to-runtime scale. Compact states use 32x32 cells; attack, dash, and interaction use 48x32 cells; defeat uses 64x32 cells. Wider canvases provide pose room and must never be treated as a larger actor scale.

Normal melee body frames map directly to authoritative phases: frame 0 is wind-up, frame 1 is active, and frame 2 is recovery. The body sheet contains no weapon. `PlayerWeaponVisual`, `SwordPivot`, `MeleeAttackComponent`, and `MeleeHitbox` retain the presentation/gameplay boundaries established by Decision 039.

The serious design baseline uses a slightly boxy head, narrow pure-black determined eyes without highlights, a short rust-red scarf, narrow starter clothes, and small pointed boots. The old single Opaw atlas remains preserved as legacy material and must not regain an active `SpriteFrames` reference.

## Consequences

- Actions can gain appropriate frame counts without repacking unrelated poses.
- Direction and action changes no longer resize the actor node or force a smaller body crop.
- Horizontal reaches and collapse use more texture width but do not alter collision, hurtboxes, Y-sort origin, or gameplay authority.
- Source processing must reject neighboring-grid spill before measuring a pose; raw generated `get_used_rect()` across an unguarded cell is not sufficient.
- Future playable classes and outfit layers must match the same action names, direction rows, body reference scale, and foot baseline if they reuse this rig.
- The seven-sheet contract costs more source and import files, but each asset is independently reviewable and replaceable.
