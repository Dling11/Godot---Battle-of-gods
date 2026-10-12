# Decision 028 - Teach Ranged Pressure in an Authored Second Stage

- **Date:** 2026-07-14
- **Status:** Accepted for the combat prototype

## Context

Stage 1 teaches movement, direct melee pursuit, snapshot leaps, and portal use. The Bramble Spitter adds a substantially different positioning problem and made the beginner final wave less focused. Stage 2 existed only as a quiet placeholder, so the game had no authored space in which to introduce a new enemy role with sufficient attention.

## Alternatives Considered

- Keep the Bramble Spitter in Stage 1 Wave 3.
- Add the Spitter immediately to a large mixed Stage 2 crowd.
- Keep Stage 2 non-combat until progression systems are complete.

## Decision

Restore Stage 1 Wave 3 to two Mirelings and two Thralls. Build the first compact Stage 2 encounter, `Thorns of the Forgotten Grove`: an arrival-lore pause, a two-Mireling warm-up, then one Mireling plus one Bramble Spitter. The Stage 2 exit portal to Stage 1 is created only after both waves clear.

## Consequences

- The player learns ranged marker dodging in a readable two-enemy encounter.
- Stage 1 remains a focused early-combat tutorial rather than a mixed-role final exam.
- `EncounterController` gains an idempotent public start request so a stage flow may present lore before combat while preserving encounter authority.
- Future XP, coin, and skill systems now have a real two-stage loop to evaluate against, but remain unimplemented.
