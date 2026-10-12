# Decision 110: Adopt B+C Hard-Pixel King Skill Icons

- **Status:** Accepted and implemented
- **Date:** 2026-08-16

## Context

The first generated King skill-icon pass followed Decision 109's painted-raster direction. Owner review found it too realistic and inconsistent with King's simple coarse-pixel identity. The pass also derived 64-pixel antialiased icons, contradicting `ART_DIRECTION.md`: standard action/skill icons are native 24x24, binary-alpha hard-pixel assets, and a detailed illustration must not be disguised as pixel art through downscaling.

The owner approved the B/C concept family: C's simple silhouette and limited shading combined with B's strong contact cracks and compact impact grouping.

## Decision

- King Skills 1-4 use one B+C hybrid icon family designed as coarse 48x48 logical pixel-art source and deterministically normalized to native 24x24 runtime PNGs.
- Every icon uses one dominant symbol plus one supporting effect, top-left light, generous transparent padding, a fixed maximum 14-color King palette, and binary alpha.
- The shared palette uses void/navy charcoal, muted steel, bone-white, restrained spirit blue/violet, and only a tiny dark-crimson physical-hilt accent. It rejects realistic material rendering, gradients, ornate gold, ribbons, fog, and particle clutter.
- Silhouettes remain ability-specific: paired crescents for Echoing Sever, planted radial rupture for Riftbreak, diagonal landing strike for Sovereign Pursuit, and an oversized pale vertical spirit blade for Worldsplitter.
- Generated originals live under `art_source/generated/ui/king_skill_icons_bc_hybrid/`. `tools/prepare_generated_combat_ui.gd` owns chroma removal where needed, 48-pixel logical normalization, fixed-palette mapping, exact 2:1 nearest reduction, and binary alpha.
- Ability resources reference only the 24x24 derivatives. Presentation filenames, colors, and pixels never decide targeting, cooldown, damage, movement, automation, or input behavior.

## Consequences

- Decision 109 is superseded for King skill icons. Its first painted 64-pixel derivatives are rejected and no longer runtime references.
- Decision 109's separately generated cursor experiment remains technically installed but is not approved by this skill-icon decision; cursor replacement needs its own B/C-scale review.
- Decision 108's accepted four-arrow movement marker and targeted-slot feedback remain unchanged.
- Native-size tests now enforce icon dimensions, transparency, binary alpha, and the 14-color ceiling.
