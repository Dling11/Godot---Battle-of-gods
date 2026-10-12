# Decision 029: Use a Session-Only Authored Level-10 Progression Foundation

- **Date:** 2026-07-14
- **Status:** Accepted

## Context

The first playable slice needs visible advancement without turning its early combat into a random, interruption-heavy upgrade loop. Persistence, coin sinks, and final skill loadout rules are not ready for a permanent save schema.

## Alternatives Considered

1. Delay all progression until inventory and save systems exist.
2. Use a roguelite-style random choice every level.
3. Add permanent progression and a save format now.

## Decision

Implement a reusable, session-only progression component with a fixed level-10 cap, cumulative XP thresholds, enemy XP/coin rewards, and a small HUD readout. Levels do not pause combat or alter stats. Enemies award values from their existing data definitions. A later skill-information/setup menu will consume the authored progression rules rather than random options.

## Consequences

- The current prototype communicates progress immediately and keeps combat uninterrupted.
- Restarting reloads the scene and resets XP/coins; this is intentional until save/death rules are approved.
- `PlayerProgressionComponent`, `ProgressionDefinition`, and `EnemyRewardComponent` are reusable boundaries for later unlocks, currency sinks, and persistence.
- Any future persistent progression must add an explicit save decision and schema rather than quietly changing this session contract.
