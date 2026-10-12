# Decision 039: Use Modular Mortal Character Presentation

- **Date:** 2026-07-15
- **Status:** Accepted

## Context

The full-body Awakened sword sheets proved combat timing, but every weapon required a new body animation and the integrated silhouette made visible equipment and future Warrior, Ranger, and Mage variants expensive to author. The approved new direction uses a smaller, serious mortal with simple eyes, starter clothing, and equipment that can exist as a separate world layer. Existing enemy art and gameplay behavior remain readable and do not require the same migration.

## Alternatives Considered

- Continue authoring a complete six-frame body sheet for every weapon and class.
- Create separate complete player scenes for Warrior, Ranger, and Mage.
- Keep the old body and attach only inventory icons without visible world equipment.
- Use a shared modular body and event-driven presentation layers while preserving independent gameplay authority.

## Decision

The current playable identity is **Opaw**, a mortal wayfarer beginning as a **Novice Warrior**. `Player` remains the technical actor role and reusable gameplay scene name.

Opaw uses a normalized four-direction hard-pixel body with no integrated weapon. Decision 040 supersedes this decision's original single eight-row atlas layout with action-owned sheets while preserving the modular body, stable foot origin, and external equipment boundary. Future hair, class clothing, armor, hats, weapons, and auras may be independent presentation layers that share the actor's animation state.

The active weapon appears beneath `VisualRoot/WeaponVisual`. That node is the hand/grip pivot rather than the texture center. Each `WeaponDefinition` supplies `sprite_offset_from_grip`, `world_visual_scale`, and `swing_visual_radius`, allowing a short sword or future greatsword to reuse one rig without floating or orbiting around its midpoint. `PlayerWeaponVisual` observes facing, melee phases, ability phases, and defeat; it may position/rotate the visible weapon and show a brief active trail, but `MeleeAttackComponent`, `SwordPivot`, and `MeleeHitbox` remain the only authorities for timing, reach, accepted contacts, and damage.

The first active weapon is the **Ashwood Blade**. It is a small wooden sword with separate 16x24 world art and a 64x64 inventory portrait. Its current 25-damage prototype tuning is preserved so this presentation migration does not silently rebalance combat.

The early material vocabulary is **Wood → Stonebound → Iron → Rare**, with Rare using restrained spirit blue. Only Wood is active now. The former A Grade, S Grade, Legendary, and Mythic showcase remains preserved as legacy concept work and is removed from the beginner-facing armory.

Decision 017 is superseded for the active player presentation. Its integrated full-body attack approach remains valid historical context and may still suit non-modular actors. Existing enemies are not migrated. Skillkeeper Eira and Armskeeper Orren keep their identities and current scenes until a later NPC presentation pass adapts the shared scale with richer outfit, hat, staff, and merchant-prop layers.

## Consequences

- New weapon families can change visible world art without rebuilding Opaw's complete locomotion atlas.
- Warrior, Ranger, and Mage can share body and animation contracts while retaining class-specific data, clothing, weapons, and skills.
- Weapon motion must remain synchronized with authoritative phases and may never decide damage.
- Generated direction order must be normalized into the canonical runtime `down, left, right, up` contract, and modular attacks must preserve body scale rather than selecting a smaller pose.
- The old Awakened locomotion and sword sheets become legacy fallback material; they are preserved rather than deleted.
- NPC and environment restyling becomes a phased art task, not a prerequisite for keeping the current game playable.
- Rotated pixel weapons require gameplay-scale review for shimmer and anchor alignment before additional weapon families are produced.
