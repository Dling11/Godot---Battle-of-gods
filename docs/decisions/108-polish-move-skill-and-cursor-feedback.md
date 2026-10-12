# Decision 108: Polish Move, Skill, and Cursor Feedback

- **Status:** Partially superseded by Decision 109; four-arrow marker and HUD feedback retained, hand-authored skill/cursor art rejected
- **Date:** 2026-08-16

## Context

The two-frame walking-foot destination marker read as a generic movement badge rather than a precise ground destination. King's four skill icons also used inconsistent canvas sizes and framing, and a targeted skill did not identify the active aim/cancel state inside its own action slot. The existing semantic cursor service was technically complete but its interaction and targeting silhouettes needed a clearer hand and sword read.

## Decision

- Ground movement uses a small original four-arrow convergence marker. Two 24-pixel source frames animate inward, but runtime presentation is limited to 20 pixels so it remains subordinate to hazards and combat effects.
- All four King skill icons use one crisp 24-by-24 navy, cyan, white, and gold vocabulary while retaining distinct ability silhouettes.
- Skill slots draw restrained ability-specific corner accents. Directional and ground-targeted skills pulse only while aiming and show `AIM RMB`; right click or `Esc` still cancels through existing targeting authority.
- Interactive controls retain a compact gold glove cursor. Selected combat targets and skill confirmation use a brighter sword-and-target cursor. Hardware cursors remain owned by `CursorService` so no per-frame pointer follower is introduced.
- The combat action tray and enemy roster receive local themed borders. A broad global menu rewrite remains separate so established screens are not destabilized in one visual pass.

## Consequences

- Click movement has a familiar four-direction destination grammar without copying another game's artwork.
- Skill targeting state and cancellation are visible at the action tray instead of relying only on world preview knowledge.
- Existing skill damage, cooldown, targeting, automation, and input authority remain unchanged.
- Further menu polish can reuse these accent colors and silhouettes after live owner review.
