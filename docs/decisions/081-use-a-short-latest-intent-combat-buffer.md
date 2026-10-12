# Decision 081: Use a Short Latest-Intent Combat Buffer

- **Date:** 2026-08-12
- **Status:** Accepted

## Context

Battle of Gods already retained one basic attack or immediate skill through a committed normal attack or active dash. Owner playtesting identified the broader responsiveness rule: pressing Riftbreak immediately after confirming Sovereign Pursuit should execute Riftbreak when the leap finishes, while no input should remain queued through a long cooldown or unrelated delay.

This generalizes Decision 046's one-action, safe-boundary principle. It does not add a character-specific combo bonus or allow live damage/invulnerability windows to overlap.

## Alternatives Considered

- Keep separate hard-coded buffers for dash attacks and selected skill pairs.
- Store an unlimited command queue until every input can execute.
- Buffer through cooldowns for multiple seconds.
- Cancel any committed action as soon as a new input arrives.
- Retain only the latest valid combat intent for a short shared window.

## Decision

`Player` owns one latest combat intent for at most 0.8 seconds. A newer valid input replaces the previous intent. The buffer stores the action family plus captured direction and, for skills, the requested slot.

Normal attack, dash, and equipped-skill inputs may enter the same buffer while another attack, dash, or non-cancelable skill is committed. Execution happens only at the first legal boundary: attack/dash recovery where already supported, or `ability_finished` for a committed skill. Repeated primary attacks are the deliberate exception: they wait for the current attack's `attack_finished` signal so rapid presses cannot delete weapon recovery and create an unlimited-cadence loop. Existing explicitly authored cancel rules remain authoritative.

An input must be usable when requested; the buffer never waits for a cooldown. Immediate/self-area skills cast at the boundary. Directional or ground-targeted skills reopen their targeting preview rather than guessing a target. Defeat, expiry, or replacement clears the intent, and inputs never stack.

## Consequences

- `Sovereign Pursuit -> Riftbreak` works from an immediate `3`, then `2` input sequence without hidden combo state or bonus damage.
- Attack, dash, and future equipped skills share one reusable responsiveness rule instead of pair-specific branches.
- Long animations and cooldowns cannot trigger stale actions much later.
- Committed hit windows, traversal invulnerability, cooldown ownership, targeting confirmation, and damage authority remain unchanged.
- The 0.8-second window and boundary feel require gameplay-scale approval and may be tuned from observed input timing.
