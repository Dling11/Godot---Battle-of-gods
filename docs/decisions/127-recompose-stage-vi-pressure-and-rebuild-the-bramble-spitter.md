# Decision 127: Recompose Stage VI Pressure and Rebuild the Bramble Spitter

- **Status:** Accepted
- **Date:** 2026-08-24

## Context

Owner testing approved the Crag Bear and environment but found Stage VI too easy even without armor because its three-live cap and sparse Bear/Hog waves allowed effortless disengagement. The single opening Mireling no longer served the desired first major difficulty jump. The returning Bramble Spitter also exposed an older presentation and AI seam: its three attack frames reused idle/locomotion poses, its procedural seed lacked identity, and its continuously recalculated retreat target allowed endless kiting.

Stage V itself remained fully implemented, but the Sanctuary expedition menu omitted a Stage V definition and visually jumped from Stage IV to Stage VI.

## Alternatives

1. Inflate Bear health/damage and leave the sparse roster unchanged.
2. Add more Bears while keeping the older Spitter and Mireling opening.
3. Preserve the approved Bear population, raise role-based pressure with Thralls and rebuilt Spitters, restore the missing Stage V menu route, and tune Bear drops for the future accessory-material role.

## Decision

Choose Alternative 3.

- The expedition menu now presents the implemented route in canonical I, II, III, IV, V, VI order. `dead_forest.tres` opens Stage V at Level 5 after the Stage IV clear/discovery; it does not duplicate Stage V runtime authority.
- Stage VI removes Mirelings entirely, preserves eight total Crag Bears, and uses five authored waves totaling 4/4/5/6/9 enemies under a five-live cap. Fourteen Forsaken Thralls provide melee screening, five Bramble Spitters provide ranged priority pressure, and the final wave retains one Armored Hog.
- Difficulty comes from composition, target priority, movement, and reinforcement pressure rather than raising Bear health/damage.
- Crag Iron changes to 30% with fifth-attempt protection; Echo Claw changes to 8% with twelfth-attempt protection. With eight Bears per clear, the provisional target is roughly two to three Iron and zero to one Claw per clear. Final accessory recipe quantities remain a later Stage VIII decision.
- Bramble Spitter remains a 40-health Light ranged enemy but now deals 14 projectile damage with a 0.62-second telegraph and 0.82-second recovery. Its body uses `AnimatedSprite2D` with four-direction idle, four-pose walk, hurt, collapse, and eight-pose physical spit families.
- A Spitter may perform one fixed 0.55-second/72-pixel retreat burst, then must commit to a shot when line of sight is available until its 1.65-second retreat cooldown expires. Navigation clamps the fixed target; the player cannot drag a continuously recomputed retreat across the map.
- The new animated thorn-seed travels at 155 px/s and owns a one-health, non-selectable `HurtboxComponent`. Player hitboxes can destroy it through the normal damage pipeline, while assisted target selection and the enemy roster ignore it.
- Long-lived projectiles validate freed shooters, impacts validate their parent, Spitter firing validates its projectile parent/type, and death/stagger cancel retreat/attack authority. Focused tests cover shooter death during wind-up, shooter deletion after launch, target deletion, counter hits, cleanup, and scene unload.

## Consequences

- Decision 126 remains authoritative for Crag Bear identity, art, combat, material identity, and the free-entry gear boundary. Its one-Mireling, three-live-cap, and original wave-composition clauses are superseded here.
- Stage VI needs a new owner playtest with starter gear, the full skill kit, and the Stage V set. Exact crowd comfort and material pacing remain tunable from measured results.
- Stage VII may introduce a genuinely new ranged family instead of requiring Stage VI to contain every future role.
