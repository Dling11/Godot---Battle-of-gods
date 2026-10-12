# Decision 118: Generate Full-Surface Abyssal Portal and Dense Lightning Boards

## Status

Accepted — 2026-08-21

## Context

The ground vortex, portal-shaped FX ring, and localized circular-eye animation all failed owner review. The desired stage exit is smaller on screen but visually deeper: motion must cover the entire inner surface and exact middle, the outer edge must continuously change, and different layers must not rotate as one flat wheel. The separately liked lightning language must become more frequent and intense, with several simultaneous discharges distributed around the complete circumference and extending far outward.

## Alternatives

1. Continue transforming one static portal master procedurally.
2. Keep the localized center rotation and add more particles.
3. Generate a new base board but retain procedural lightning.
4. Generate fresh 4x4 animation boards for both the complete portal and independent lightning field.

## Decision

Generate and normalize two new sixteen-frame boards:

- `stage_abyssal_veil_base_16x_160x192.png` owns full-surface layered vortex motion, a nonempty moving exact center, and a rippling/deforming energy rim.
- `stage_abyssal_veil_lightning_fx_16x_256x224.png` owns dense simultaneous lightning, curved streaks, sparks, and particles around all sides and into the far field.

The generated source boards are exact 4x4 layouts. A deterministic processor removes the preview matte, finds each cell, preserves frame-to-frame scale differences inside one stable alignment, converts values for runtime tier tinting, and exports horizontal sheets. `PortalFx` remains independent, faster, and phase-offset. Normal runtime scale drops to `0.64`; higher tiers scale from that smaller baseline. Interaction, collision, travel timing, and scene-transition authority do not change.

Automated acceptance requires all sixteen frames, visible alpha at the exact center in every base frame, meaningful changes across upper/middle/lower interior zones, rim changes outside the inner body, minimum per-frame FX density, and accumulated lightning presence at the top, bottom, left, and right far regions.

## Consequences

- The portal reads as layered depth instead of a small spinning circle or flat wheel.
- Generated edge variation supplies continuous rim motion rather than a static cutout.
- Frequent lightning remains independently tunable and can overlap beyond the smaller portal body.
- Normal through Transcendent tiers still reuse neutral sheets; a future Demon tier remains a separate content decision.
- Final subjective size, intensity, loop smoothness, and gameplay readability still require owner review at 960x540.
- All rejected portal passes and their obsolete processors remain recoverable under `art_source/archive/environment/portals/` and have no active runtime references.
