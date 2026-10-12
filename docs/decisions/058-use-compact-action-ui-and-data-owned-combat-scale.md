# Decision 058: Use Compact Action UI and Data-Owned Combat Scale

- **Status:** Accepted; vitality/contact tuning superseded by Decision 059 and level-up presentation superseded by Decision 060
- **Date:** 2026-07-26

## Context

The first dash HUD addition sat beside four text-heavy skill controls whose child minimum widths could exceed their authored boxes. The same problem appeared in Eira's Active Skills page because every card repeated the full ability description. Opaw's detached sword sat far from the body and appeared in his anatomical left hand from the front, while the normal attack used one hard-coded 30-pixel capsule that could not honestly support future greatswords, axes, or scythes. Both active skills looked much broader than their narrow contact lanes. Maximum health also remained fixed at 100 and leveling had only a generic text announcement.

## Alternatives Considered

1. Keep the existing controls and reduce only their font sizes.
2. Increase modal and HUD bounds to contain the overflowing text.
3. Make action controls icon-first, move descriptions into one detail surface, and make vitality/reach data owned.

## Decision

Choose option 3.

The lower HUD uses one centered themed tray containing five fixed `52x48` controls: dash followed by skills 1-4. Each control shows an icon, key, compact readiness/cooldown text, and a thin cooldown bar; names remain in tooltips. The top-right entry is labeled `MENU [ESC]`. Active Skills cards use a compact `128x68` title/status treatment and the selected skill's complete description remains in the existing detail panel.

Opaw uses `PlayerVitalityDefinition` plus `PlayerVitalityComponent`: `100 + 8 * (level - 1) + flat equipment bonus`. Level 10 therefore reaches 172 maximum health before armor. Increasing maximum health preserves missing damage while granting the newly gained capacity. `HealthComponent` remains health authority. Future armor may inject the flat equipment bonus; mana requires its own later resource/component and is not implied by vitality.

`WeaponDefinition` owns an authoritative melee `Shape2D`. Balanced Slash uses a reusable 52-pixel-forward, 36-pixel-wide cleave polygon. `MeleeAttackComponent` installs the equipped weapon's shape, while the detached sword's inner trail and translucent white-blue cleave band read the same data-owned reach. Opaw's front-view sword moves to his anatomical right, and side grips move upward and closer. Future greatswords, axes, and scythes must author family-appropriate shapes and presentation rather than inherit Balanced Slash accidentally.

Piercing Rush widens from `128x30` to `128x40`; Consecutive Thrust widens from `128x26` to `128x44` and exposes a longer contact guide. Their damage, timing, cooldown, movement, invulnerability, and cancellation rules remain unchanged.

Normal level gain presents a world-space gold/spirit aura, a compact `LEVEL UP` vitality banner, and an original deterministic UI chime. These use the existing code-native/pixel presentation pipeline, so no separate generated bitmap is required.

## Consequences

- Dash and skill controls cannot collide through long localized names.
- Eira's skill page keeps full information without oversized repeated cards.
- Attack VFX more honestly communicates normal and skill contact areas.
- Weapon families can differ in authoritative reach without duplicating player controllers.
- Opaw gains restrained survivability across the ten-level arc; armor and mana remain separate future systems.
- The wider contacts and level-scaled vitality require human Stage I-III balance testing before Stage IV enemy damage is raised.
