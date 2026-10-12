# Decision 117: Layer Upright Stage Portals from Separate Vortex and Lightning Sheets

## Status

Superseded by Decision 118 — 2026-08-21

## Context

The temporary stage exit was an architecture-free ground vortex. Owner review instead selected the deep tunnel and wide doorway of the Veil Whirlpool concept, combined with the jagged lightning language of the Lightning Iris concept. The desired exit must remain an upright portal, partially transparent, visibly spinning inside, and large enough to read as enterable. Lightning, particles, and future superiority escalation also need room to extend beyond the core doorway without shrinking every animation cell or forcing all effects into one cadence.

## Alternatives

1. Keep one compact sheet containing vortex, lightning, and particles.
2. Use one static generated portal and animate only shader/procedural distortion.
3. Build a physical arch or monument around the effect.
4. Separate the upright vortex body from a larger lightning/particle overlay.

## Decision

Use two independently animated neutral-value sheets:

- `stage_veil_portal_base_12x_192x224.png` owns the compact irregular silhouette and translucent gaps. Its doorway and broad bands remain fixed; only a small central vortex eye rotates.
- `stage_veil_portal_particle_fx_12x_320x288.png` owns sparse detached motes and incomplete lightning discharges that reach far outside the base footprint without tracing another portal ring.

Both sheets contain twelve large horizontal cells and share a stable center pivot. The base-localized motion contract forbids frame differences outside the central eye. The FX contract requires low overall pixel density plus visible pixels at the far canvas edges. `StagePortal` starts the FX layer phase-offset, plays it faster than the base, and applies tier-owned tint, reduced display scale, and intensity. The transition loading veil mirrors both layers. Interaction range, travel timing, collision, and scene replacement remain unchanged and presentation-independent.

Normal through Transcendent currently reuse the same two sheets. Later Demon or other named superiority tiers require an explicit gameplay/content decision, but should first vary data-driven palette, speed, scale, intensity, and optional additive overlays before duplicating the base animation family.

## Consequences

- The inner vortex can rotate smoothly without making the lightning feel glued to it.
- The FX canvas can overlap a much larger field while the base remains readable and partially transparent.
- Tier progression remains data-driven and does not multiply sheets for palette-only changes.
- Both sheets, their cell sizes, pivots, and loop lengths must be verified together.
- The generated masters intentionally pass through a deterministic matte-removal and grayscale-normalization pipeline before becoming runtime assets.
- Final scale, lightning intensity, and tier readability still require owner review at the 960x540 gameplay viewport.
