# Decision 113: Make Sanctuary a full-health recovery checkpoint

- **Status:** Accepted
- **Date:** 2026-08-16

## Context

Current HP persisted through safe-point Continue, so launching a valid profile could place King in Sanctuary at the low health recorded after an expedition. This was consistent with the old persistence rule but read as an immediate startup defect and made the safe hub feel incomplete.

## Decision

- Entering Sanctuary, including through Continue, restores King to his current maximum health.
- The heal occurs before the Sanctuary safe-point save, so the recovered value becomes the next valid profile state.
- Stage-to-stage transitions inside an expedition continue to preserve current HP. Regeneration and combat damage rules remain unchanged outside Sanctuary.

## Consequences

- Continue never begins with inherited expedition damage while still restoring XP, coins, story, materials, equipment, and claims.
- Returning to Sanctuary ends expedition attrition and establishes an explicit recovery checkpoint.
- Regression coverage must verify both the live player's full health and synchronized `RunSession` health.
