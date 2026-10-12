# Decision 042: Share Body Animation Across Data-Driven Sword Styles and Grades

- **Date:** 2026-07-18
- **Status:** Accepted

## Context

Opaw's weaponless attack body and detached Ashwood Blade already separate character motion from equipment art. Future wooden, Stonebound, Iron, or Rare swords should not require duplicate body sheets merely because their texture or stats change. At the same time, genuinely different sword families need room for distinct visible swing weight without moving contact, damage, or timing authority into animation.

## Alternatives Considered

- Duplicate Opaw's complete attack body animation for every sword grade.
- Keep one body animation but hard-code one visible swing for every sword.
- Put visible arc values on each weapon, duplicating a complete set of tuning across similar grades.
- Reference reusable presentation-only sword styles from weapon definitions while keeping gameplay data authoritative elsewhere.

## Decision

`WeaponDefinition` may reference an immutable `SwordAttackStyleDefinition`. A style owns only the detached weapon's wind-up/strike arcs, active extension, trail points/width/color/fade, strike scale/tint, and deterministic normal-swing presentation variants. Balanced Slash cycles an outward sweep, reverse return, and extended visual finish. The sequence advances when authoritative wind-up begins, but does not change combat values. Swift Slash and Heavy Cleave are authored reusable profiles for future content but do not create obtainable weapons.

Sword grades may share Opaw's same weaponless `SpriteFrames` and the same style while supplying their own world texture, grip offset, visual scale, swing radius, damage, knockback, and authoritative phase timing. `Player.set_weapon_definition()` synchronizes the combat component and weapon presentation only while no attack, ability, dash, or defeat is active. This seam does not implement inventory, ownership, drops, purchases, equipment UI commands, or saving.

## Consequences

- A higher-grade sword can reuse the current polished body motion without copied animation assets.
- A distinct sword family can change visible weight and momentum through a reviewed shared profile.
- Style changes cannot modify hitbox reach, accepted contacts, damage, knockback, or phase timing.
- The body animation remains stable when runtime weapon data changes.
- Actual additional weapons still require approved art, stats, acquisition, persistence, and balance rules before activation.
