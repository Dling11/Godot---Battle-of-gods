# 142 - King is a progressing adventurer, with compact gameplay scale

- **Status:** Owner selected compact greatsword C; production installation and combat rules are recorded in Decision 143.
- **Date:** 2026-09-12

## Context

The owner requested improved King movement, attacks, skills, portrait and weight, then rejected the initial crown, gold armor and royal mantle concept. King's name does not make him a literal monarch by appearance. He should look like a simple, cool MMORPG adventurer who can progress, matching the existing game's pixel style. Examiner's large boss scale is intentional; it is not the player scale reference. Future NPC revisions must respect the same human-scale baseline.

## Decision

- Continue Decision 076's compact identity: black hair, simple face, muted crimson scarf/clothing, charcoal/navy body and a short broad signature sword. Starter clothing and restrained practical equipment leave room for progression.
- Do not add a crown, ceremonial armor, elaborate gold detailing or a long royal mantle as a consequence of his name. Royal-themed techniques remain allowed independently of everyday clothing.
- Existing movement cells are 48x32 with y=30 foot baseline; current first-frame opaque heights are 27/26/26/28px across source rows. Use roughly 26-28px standing body height as this review's baseline. Measure head-to-foot anatomy separately from weapon extent.
- Preserve native hard-pixel density and compact proportions across body animations, portraits and other human-scale NPC reviews. Larger action canvases preserve weapons; they do not enlarge anatomy.
- Review one small identity/scale study before producing further full animation sheets. The rejected sovereign study is not an animation reference.

## Alternatives

The ornate sovereign concept was rejected by the owner. Scaling that detailed character down would retain the wrong costume and pixel density. Enlarging King toward Examiner would also distort existing NPC and world proportions.

## Consequences

The corrected four-view study is retained under `art_source/review/characters/king/adventurer_2026_09_12/`. The interrupted combat draft is preserved there, disconnected from runtime. Decision 143 subsequently installs the selected C identity, new gait/actions, combat chain, passive, portrait and capped growth. Examiner remains separately owned.

## Sword comparison follow-up

The owner accepted the corrected four-view simple-adventurer direction and requested sword/design alternatives before selection. The comparison board under `art_source/review/characters/king/sword_options_2026_09_12/` shows A shortsword, B longsword with a plain baldric, and C compact two-handed greatsword. These are enlarged concept samples, not animation-ready native atlases. The owner selected C and explicitly authorized its installation; see Decision 143. Keep the accepted compact body scale regardless of weapon choice.
