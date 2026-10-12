# Decision 116: Separate Fixed Sanctuary Architecture from Tiered Stage Vortices

Status: Accepted

## Context

Animating multiple generated versions of the complete Sanctuary gate caused the angels and masonry to wobble by tiny pixel differences. The first stage-exit pass also read as another structure, while the intended route marker was an energy vortex whose importance could scale from ordinary encounters through god-tier content.

## Alternatives

- Keep looping complete generated structures and tolerate small registration drift.
- Use one animated portal design for both Sanctuary and every stage exit.
- Lock Sanctuary architecture to one raster, animate only isolated energy, and use a separate data-styled vortex for stage exits.

## Decision

Sanctuary uses one fixed angel/masonry image derived from the approved generated artwork. Only a cropped four-frame doorway-energy child animates. Stage exits use one architecture-free eight-frame ground-vortex sheet. `StagePortal` owns Normal, Mini Boss, Boss, God, and Transcendent presentation data for tint, scale, speed, and guide color. A local downward arrow marks an on-screen portal; a small clamped screen-edge arrow points toward it while it is distant.

## Consequences

- Generated structure drift can no longer move the Sanctuary angels or stonework.
- One vortex sheet supports future encounter superiority without duplicating large textures.
- Tier styling remains presentation-only; proximity, collision, and transition authority do not change.
- Runtime and smoke tests must validate fixed/animated layer separation, eight vortex frames, tier response, and the on-screen/off-screen guide switch.
