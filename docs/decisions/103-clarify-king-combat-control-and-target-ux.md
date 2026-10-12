# Decision 103: Clarify King Combat Control and Target UX

- **Status:** Accepted; targeting presentation and Attack engagement refined by Decision 104
- **Date:** 2026-08-15

## Context

Playtesting showed that the former click selection immediately attacking felt like auto-play, normal hits looked as if they had no impact, and it was hard to compare active threats while defending.

## Decision

An empty left-click now creates a navigation-aware move destination with a brief blue circle/arrow. Clicking an enemy selects only that enemy and shows a red underfoot circle; it does not attack. `BASIC ATTACK` or a clickable enemy-roster card begins approach-and-repeat basic attacks. Escape, right-click, and the target-card close button stop selection/assistance.

Normal sword strikes apply a 0.11-second Light-enemy flinch and retain reduced Elite/boss control tiers. King slows to a 0.59-second basic cycle. Echoing Sever and Riftbreak use stronger stagger, while Sovereign Pursuit applies a 0.78-second stun-like interruption; bosses still reject all forced movement and interruption.

The selected-target card moves to the left player-status column with a circular portrait. A compact bottom-right roster lists all active enemies with circular portraits, live health, and Boss/Elite labels; bosses sort first and the existing top boss HUD remains the major-boss surface.

## Consequences

- Click movement and assisted combat remain optional; WASD immediately overrides click movement and assisted pursuit.
- Hit reactions are readable without permitting basic attacks to permanently lock an enemy.
- Enemy footprints remain the real collision/hitbox authority. Target circles are presentation only.
