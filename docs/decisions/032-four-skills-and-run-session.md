# Decision 032 - Use Four Numbered Skills and a Narrow In-Memory Run Session

- **Date:** 2026-07-14
- **Status:** Accepted

## Context

The prototype had one implemented skill on Q, one reserved E slot, and player-owned XP/coins that disappeared whenever a portal replaced the scene. The intended compact level-10 path needs predictable controls and progression continuity without prematurely defining disk saves or unfinished powers.

## Alternatives Considered

- Keep two Q/E skill slots.
- Use three active skills beside attack and dash.
- Use four numbered active slots and retain Q temporarily for compatibility.
- Store progression in scene transition parameters or build the final save service now.

## Decision

Use four active skill slots on keys 1-4. Sweeping Cut occupies slot 1; Q remains a temporary legacy fallback. Slots 2-4 stay visibly sealed until their authored abilities and unlock rules are approved. A paused Tab character menu presents progression and skill information without owning gameplay rules.

Use the narrow `RunSession` autoload to retain only total XP and coins while portal transitions replace the player scene. `PlayerProgressionComponent` remains level and reward authority, reconstructing level from its definition. Defeat restart explicitly resets the run. Nothing is persisted to disk.

## Consequences

- The combat HUD and future input hints have one stable 1-4 vocabulary.
- Additional skills can be added without redesigning the HUD layout.
- Portal travel no longer discards earned rewards.
- Run state remains intentionally separate from future profile/save data.
- Level 3/6/9 labels are provisional presentation scaffolding, not implemented unlock promises.
