# Decision 060: Tighten Starter Cleave and Localize Feedback

- **Status:** Accepted
- **Date:** 2026-07-26

## Context

The first contact-alignment pass correctly made Balanced Slash's complete visible edge deal damage, but its 62-pixel-forward by 108-pixel-wide fan read too strongly for Opaw's beginner swords. The center-screen level/vitality banner also obscured combat and the player, while a level increase only needs a brief confirmation. Finally, a broad normal swing could request camera, hitstop, and impact-audio presentation once for every enemy contacted, producing avoidable work and a lag-like clustered-hit feel.

The weapon data already separates authoritative `Shape2D`, presentation style, damage, timing, grip, and texture. This is sufficient for later short sword, greatsword, axe, scythe, and other family-specific cleaves without adding weapon-type checks to `Player`.

## Alternatives Considered

1. Keep the oversized starter fan and compensate only by fading its VFX.
2. Hard-code reach by weapon category in the player controller and retain the HUD banner.
3. Tighten the shared beginner-sword resource, keep every future family data-owned, move level feedback onto Opaw, and coalesce swing-wide presentation.

## Decision

Choose option 3.

Balanced Slash now uses a 58-pixel-forward by 96-pixel-wide convex fan. Its white-gold trail and translucent outer band continue reading the equipped weapon's shape bounds, with slightly reduced trail width. The center and visible side edge remain authoritative one-hit contacts. Ashwood Blade and Iron Sword intentionally share this beginner-sword profile; future axes, greatswords, scythes, or other families must provide their own reviewed shapes and styles through `WeaponDefinition`.

Level gain no longer creates a center-screen HUD panel. `PlayerLevelUpVisual` owns a short, low-opacity gold/spirit glow around Opaw, a small rising `LEVEL N` label above his head, and the existing restrained chime. It observes progression and never changes level or health.

One accepted normal swing preserves a flash, damage number, and burst for every target, but requests camera movement, impact audio, and a 25-millisecond light hitstop only once for the complete swing. Heavy Consecutive Thrust finish contact retains a separate 40-millisecond tier. Hitstop remains presentation-only and cannot stack within a swing.

## Consequences

- Beginner swords retain satisfying multi-target coverage without reading like future heavy weapons.
- Weapon families can differ honestly in cleave size, arc, timing, and presentation without controller branching.
- Level gain remains visible without covering Opaw or combat space.
- Clustered normal hits perform less shared presentation work while retaining target-local confirmation.
- Human feel testing is still required for the 58x96 fan and 25-millisecond light-hit tier.
