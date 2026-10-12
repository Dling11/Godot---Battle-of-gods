# Decision 076: Reboot King with simple art and explicit skill targeting

- **Status:** Accepted
- **Date:** 2026-08-11

## Context

The detailed visible-arm/shoulder-greatsword King package produced individually attractive frames but unacceptable identity, grip, scale, and motion drift. Opaw demonstrates that a small stable silhouette plus detached presentation effects is more readable and faster to animate. The owner also found immediate narrow forward skills unreliable when the character's movement-facing did not match the intended target.

## Decision

King keeps his story and character-owned combat role but adopts the approved simple hard-pixel identity under `art_source/generated/characters/playable/king/simple_reboot/`: chunky black hair, plain two-eye face, crimson scarf, compact navy/charcoal body, mitten-block hands, tiny feet, and one short broad straight signature sword. Base movement uses four purposeful frames per direction and changes primarily feet, one-pixel body bob, sleeve swing, and scarf tip. Equipment remains essence/relic power and does not replace the visible signature weapon.

Skills use explicit activation families:

- narrow wedge, line, cone, or actor-dependent skills enter an aim-preview mode before commitment;
- ground attacks such as a jump-smash expose a movable valid-range circle and commit only after confirmation;
- cancel spends no cooldown or resource;
- instant activation is reserved for self-centered AOE, aura, buff, defensive action, or naturally broad wave skills that do not depend on precise facing;
- UI confirmation remains consumed by UI and never leaks into basic attack;
- gameplay resources own range, target validation, collision, commitment, damage, and cooldown; animation and VFX present accepted state only.

The previous detailed King runtime sheets, previews, processors, tests, generated sources, and cleaned/review assets are removed from active paths and preserved under `art_source/archive/characters/playable/king/rejected_detailed_package_2026-08-11/`.

## Consequences

- Decisions 071-072 remain active for Opaw preservation, character-owned combat, roster direction, and essence/relic equipment.
- Decision 075 remains active for action-owned exact-grid sheets and purposeful frame budgets.
- Decisions 073-074 are historical and superseded for King's active visual silhouette, greatsword, shoulder carry, and old crescent package.
- The four-direction walk board now has a deterministic exact-cell runtime review atlas, isolated Godot preview, and focused smoke test; owner motion approval still gates attack production.
- This decision alone implemented no playable King. Decision 077 later activates the simple locomotion/basic-slash proof while targeting, skills, roster state, and save migration remain absent.
