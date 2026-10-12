# Decision 119: Tier Stage Portals by Threat Color and Lightning Reach

## Status

Accepted — 2026-08-21; stage assignment wording superseded by Decision 129

## Context

The approved abyssal portal art already reads as a dangerous high-tier exit because its separate FX board contains immense lightning. Showing that complete field on every Normal route removes surprise and prevents later destinations from communicating a meaningful threat increase. The same two neutral sheets should support the hierarchy without generating one asset family per tier.

## Decision

Keep the five existing destination tiers and give each one a strict presentation role:

- **Normal — blue:** compact and lightning-free. Full-surface vortex and rim motion remain visible.
- **Mini Boss — purple:** restrained, close lightning with low opacity.
- **Boss — red:** stronger, faster lightning extending beyond the doorway.
- **God — searing light:** bright white-gold energy with intense discharges reaching across much of the viewport.
- **Transcendent — near-black:** the darkest portal body and the widest violent violet-black field, exceeding half the 960-pixel viewport.

`StagePortal.TIER_PRESENTATION` owns color, portal scale, base/FX speed, FX opacity, and independent FX reach. `PortalVisual` keeps the doorway-sized vortex while `PortalFx` alone expands with threat. Normal disables the FX sprite entirely. The chosen presentation is passed into `SceneTransition` so the blocking loading veil preserves the same tier instead of restoring maximum lightning.

The current stage assignments remain data-owned: ordinary routes default to Normal, Stage III's mini-boss route uses Mini Boss, and Stage IV/Stage V boss routes use Boss. God and Transcendent are ready for future content but do not imply that those encounters are implemented.

## Consequences

- Portal threat becomes readable before interaction and higher tiers retain surprise.
- One approved base/FX asset pair still serves all tiers; color and magnitude remain code/data presentation.
- Extremely distant lightning is reserved for the highest tiers and never changes collision, interaction radius, travel timing, encounter authority, or damage.
- A future Demon tier remains a separate content decision rather than an alias for Transcendent.
- Runtime feel review is still required for the exact Mini Boss/Boss opacity and the highest-tier half-screen reach.
