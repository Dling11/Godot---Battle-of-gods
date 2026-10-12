# Decision 048: Use an Effect-Only Animation Atlas for Piercing Rush

- **Date:** 2026-07-18
- **Status:** Accepted

## Context

Piercing Rush's first vertical slice proved movement, weapon scaling, hitbox ownership, and input routing, but its code-drawn straight beam was too modest and visually static for Opaw's first signature Warrior technique. Enlarging the ability hitbox to match a dramatic illustration would damage early balance, while baking Opaw or Ashwood Blade into new action frames would undermine the armless modular character and future weapon grades.

## Alternatives Considered

- Keep the provisional code-drawn beam and tune only its length.
- Make the gameplay hitbox as large as the desired visual plume.
- Generate new body-and-sword frames for every direction and sword grade.
- Use one unanimated effect texture stretched through every phase.
- Use a generated effect-only frame sequence around the existing authoritative hit lane.

## Decision

Piercing Rush uses a generated six-frame right-facing VFX sequence: compressed charge, ignition, extended lance, oversized peak plume, shock-ring impact, and fading energy. The runtime atlas contains six 192x192 cells and rotates through `AbilityPivot` for the four cardinal directions. It contains no character, limbs, hands, or sword, so Opaw's current body sheet remains untouched and equipped weapons continue to use `PlayerWeaponVisual`.

`tools/process_piercing_rush_vfx.gd` reproducibly captures the generated board's intentionally irregular zones, downsamples by nearest neighbor, hardens alpha, and packs the runtime atlas. The original chroma-key board and cleaned intermediate remain under `art_source`; only the normalized atlas under `assets` is loaded by gameplay.

The roughly 160-pixel peak plume is presentation only. `AbilityDefinition.hitbox_shape`, `AbilityComponent`, and `Player` retain collision, damage, movement, and timing authority. A narrow bright underlay marks the real contact lane while larger wings, sparks, and ribbons provide spectacle.

## Consequences

- Piercing Rush gains a real animated visual arc without changing its 135% damage, roughly 50-pixel movement, 78 pushback, timings, cooldown, or invulnerability rules.
- Ashwood, Iron, and future compatible swords reuse the same technique art without copied character sheets.
- The outer plume can be visually exaggerated beyond the hitbox, so gameplay-scale testing must confirm that the narrow core remains readable and the effect does not obscure enemy telegraphs.
- Future signature skills may use the same effect-only atlas pattern, but each still needs an explicit visual-versus-authority boundary and viewport-scale review.
- Decision 047 remains authoritative for Piercing Rush gameplay and replaces only its provisional code-drawn presentation description through this decision.
