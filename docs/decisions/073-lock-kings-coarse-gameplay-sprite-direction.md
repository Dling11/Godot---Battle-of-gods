# Decision 073: Lock King's Coarse Gameplay-Sprite Direction

- **Status:** Accepted for body identity; modest-sword, `48x48` armed-cell, and greatsword-rejection clauses superseded by Decision 074
- **Date:** 2026-08-02
- **Related:** Decisions 071-072

## Context

King's first visual exploration preserved the planned navy, charcoal, silver, crimson, sword, and pale-hair-streak identity, but it read as enlarged anime concept art. Its realistic anatomy, detailed face, layered armor, individual hair strands, and rendered metal exceeded the density of Battle of Gods' actual gameplay characters.

A second four-direction proof removed the large portrait and reduced King to a compact, hard-pixel chibi sprite. The owner explicitly approved that second design as the visual direction to preserve.

## Decision

Decision 074 preserves the body/costume/palette/perspective clauses below but replaces the original weapon and armed-cell clauses. Read both decisions for current production work.

The approved identity reference is:

`art_source/generated/characters/playable/king/king_turnaround_direction_reference_approved.png`

Future King body art must preserve its recognizable design:

- oversized simple head, compact torso, short legs, and visible small blocky arms/hands;
- short dark hair formed from a few chunky clusters with one tiny pale memory streak;
- deep-navy short coat/tunic, charcoal lower body, restrained pale armor blocks, and one small crimson accent;
- young-prime, clean-faced presentation with one- or two-pixel facial features at runtime scale;
- a straight, modest-length silver-white signature sword held close to the body;
- front/down, side, and back/up silhouettes that remain readable without realistic anatomy or costume micro-detail.

Directional staging uses a cardinal top-down three-quarter RPG perspective. The down idle is not a perfectly front-facing portrait: shoulders turn roughly 10-15 degrees, feet stagger diagonally, and the sword-side shoulder sits slightly behind while the down attack lane remains unmistakable. Side poses retain a small visible top shoulder/back plane instead of becoming side-view platformer profiles. Walking changes the active pose/direction row and returns to the last direction's idle when movement stops; it never changes the camera language or rotates an already committed attack.

King's compact runtime target remains a `48x48` cell with an approximately 28-32-pixel upright actor. The exact visible height, origin, foot baseline, grip, and sword reach freeze only after the approved reference is manually normalized into an exact-grid production turnaround and reviewed at the 960x540 gameplay scale.

The reference is a visual lock and provenance asset, not a runtime sheet. Do not directly slice its enlarged review layout, treat its background as transparency, or allow direction-to-direction sword placement differences into production. Build exact-grid, binary-alpha runtime art from this identity with hard square pixels, a one-pixel outline, roughly 12-16 character colors, and no more than two or three flat shade steps.

Reject future King generations that drift toward a large hero portrait, anime illustration detail, realistic anatomy, individual hair strands, eyelashes, gradients, antialiasing, painterly metal, ornate armor, oversized pauldrons, a cape, crown, beard, or greatsword-scale starter weapon.

## Consequences

- King's visual-direction gate is complete; exact production normalization and animation remain unimplemented.
- The next art proof is an exact `48x48` four-direction turnaround derived from this identity, followed by a right-facing `PRE_ATTACK -> Opening Cut -> Reversal Cut` strip.
- Extended attacks may use wider cells, but King's approved body scale and coarse pixel density must not change.
- A future King portrait must be derived only after the gameplay identity is stable and must not feed realistic detail back into the sprite.
- Opaw remains unchanged and supported as required by Decision 072.
