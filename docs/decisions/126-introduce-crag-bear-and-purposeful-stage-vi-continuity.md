# Decision 126: Introduce Crag Bear and Purposeful Stage VI Continuity

- **Status:** Accepted; Stage VI roster/composition clauses superseded by Decision 127
- **Date:** 2026-08-24

## Context

Stage VI needed its first production enemy and a complete playable route. The owner revised the earlier strict exclusion of early enemies by approving one Mireling at the opening as deliberate continuity. The new recurring mob must remain simpler than a mini-boss while creating a clear step above early Forest enemies and contributing materials to accessory progression.

## Alternatives

1. Remove every earlier enemy and introduce several complex Stage VI archetypes at once.
2. Fill Stage VI with larger groups of existing enemies.
3. Open with one familiar Mireling, then make one new armored melee family the primary threat.

## Decision

Choose Alternative 3.

- Stage VI opens with exactly one Mireling as a familiar straggler. It is authored continuity, not filler; Rootlings remain absent.
- Crag Bear is a normal recurring mob, not an Elite, mini-boss, or boss. Its kit is one paw-swipe basic attack and one telegraphed radial ground slam.
- Crag Bear owns recognizable dark-bear anatomy, pale crafted armor, a leather harness, foreleg bracers, a forehead guard, and restrained teal engravings.
- Five waves total 1/1/2/3/4 enemies under a three-active-enemy cap. Later waves combine Crag Bears with Armored Hog pressure rather than only multiplying one enemy.
- Crag Bear drops Common Crag Iron and Uncommon Echo Claw through canonical material/drop systems. Echo Claw automatically becomes eligible for Umi reconstruction; Crag Iron remains sellable/meld fuel.
- `EncounterSpawnEntryDefinition` supplies reusable scene-plus-count composition for new enemies. Existing legacy wave count fields remain compatible with Stages I-IV.
- Stage VI remains freely enterable at Level 6 after Stage V story/boss/discovery requirements. No equipment ownership gate is added.

This decision supersedes only Decision 121's strict statement that Stage VI contains no Mirelings. Its free-entry and meaningful-gear balance rules remain accepted.

Decision 127 later removes the Mireling, raises the live cap, and recomposes all five waves after owner playtesting. Crag Bear identity, behavior, artwork, materials, and the no-equipment-gate rule remain accepted here.

## Consequences

- Stage VI is now a production expedition with navigation, encounters, loot, clear banking, completion memory, and a Normal portal back to Sanctuary.
- Crag Bear art, directional action frames, portrait, materials, and processing provenance become reusable runtime assets.
- Starter-versus-crafted clear time, incoming damage, slam readability, and three-enemy crowd feel still require an owner playtest before values are final.
- Stage VII can be designed from a completed Stage VI baseline.
