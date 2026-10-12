# Decision 106: Restore Left Click Attack and Right Click Cancel

- **Status:** Accepted and implemented; owner feel test pending
- **Date:** 2026-08-16

## Context

Decision 105 correctly restored Skills `1`-`4` and contextual right-click world commands, but removing the established left-click manual sword attack made ordinary free swings less direct. Escape-only targeting cancellation also made the mouse workflow unnecessarily modal.

## Decision

Left click returns to the established immediate manual basic attack outside targeted-skill previews. Right click remains contextual in the world: ground moves and clears combat, while an enemy immediately selects and auto-engages. During a targeted-skill preview, left click confirms and right click or `Esc` cancels; the preview consumes both commands so no attack or movement leaks through.

The unnumbered Attack HUD fallback moves to the far-right end of the action tray, after Skills `1`-`4`. A drag-to-cancel region is unnecessary for the current desktop controls and remains a possible future touch-specific treatment.

## Consequences

- Manual air swings retain one-click access without taking a number key away from skills.
- Right click has one world meaning and one modal-preview meaning, resolved by explicit targeting state.
- The action tray reads Dash, Skills `1`-`4`, then Attack.
- Decision 105 remains authoritative for contextual right-click world commands and restored skill keys; its Escape-only cancellation and no-mouse manual attack clauses are superseded.
