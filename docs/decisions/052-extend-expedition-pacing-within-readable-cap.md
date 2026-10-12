# Decision 052: Extend Expedition Pacing Within the Readable Four-Enemy Cap

- **Date:** 2026-07-19
- **Status:** Accepted, revised 2026-07-19

## Context

Both expeditions ended too quickly for Opaw's completed starter techniques and weapon progression to be meaningfully exercised. The first authored pacing pass still ended too quickly because every wave could contain only the live-enemy cap. Raising health values alone would make enemies feel spongy, while spawning an unbounded crowd would undermine telegraphs, dodge readability, and the validated local separation budget.

## Alternatives Considered

- Raise all existing enemy health and leave the two/three-wave structure unchanged.
- Add a large enemy horde with no new pacing structure.
- Add authored waves using only previously introduced roles and retain the current four-enemy cap.
- Allow each authored wave to contain a longer queue, released in paced reinforcements as active enemies fall.

## Decision

`EncounterWaveDefinition` may contain more total enemies than the live cap and declares a reinforcement delay. `EncounterController` spawns an initial group up to the configured cap, then releases pending enemies after a short delay as positions open. It remains the authority for the maximum active count; content data never spawns an oversized crowd.

Stage 1 has six beginner waves totaling 30 Mireling/Rootling/Thrall enemies: 3; 4; 5; 5; 6; and 7. It never spawns a Bramble Spitter. Stage 2 has seven Grove waves totaling 32 enemies: 3; 3; 4; 4; 5; 6; and 7. It teaches Mirelings, then Spitter pressure, then Rootling/ranged pressure before its mixed finale. Both stages retain the 2.25-second inter-wave recovery window and never exceed four live enemies.

## Consequences

- Encounters provide a longer, authored runway for normal attacks, dodge, Piercing Rush, and Consecutive Thrust without making starter enemies health sponges or forcing a large live crowd.
- Players see mixed pressure only after the individual enemy roles have been introduced, and can read a short reinforcement gap before the next group arrives.
- The controller is regression-tested with an automated full queued encounter to ensure every authored enemy arrives without exceeding the active cap.
- Future increases beyond four active enemies require profiling and a separate readability decision.
