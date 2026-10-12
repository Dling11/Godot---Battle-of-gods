# Decision 054: Rootling as the Compact Stage 1 Root-Jab Enemy

- **Date:** 2026-07-19
- **Status:** Accepted

## Context

The approved Rootbound Husk source art has a tall, imposing silhouette appropriate for a later larger enemy. The first forest tutorial needs a visibly smaller, cute-but-hostile mob that is distinct from a Thrall and teaches one readable dodge decision without reading as a boss.

## Alternatives Considered

- Shrink Rootbound Husk into Stage 1 despite its heavy silhouette.
- Reskin a Mireling or Forsaken Thrall.
- Use a compact Rootling with its own anchored ground-jab behavior and preserve Husk for Stage 2.

## Decision

Rootling is a dedicated Light-tier `CharacterBody2D` with its own source-art pipeline, scene, controller, and presentation observer. It uses shared health, rewards, navigation, separation, knockback, stagger, hurtbox, hitbox, health-bar, and positional-audio components without inheriting another enemy's combat behavior.

At 35 health, 52 px/s, 6 damage, 0.58-second wind-up, 0.12-second active period, 0.82-second recovery, 9 XP, and 1 coin, it is a compact Stage 1 threat. The controller snapshots a single direction at the start of wind-up, draws a small crack in that exact direction, and activates only a narrow 40x16 lane for the root jab. Target movement and enemy knockback never rotate the lane after telegraph. The visual package consists of 4x4 directional walk frames, 4x4 reaction/defeat frames, and a separate 4x4 directional crack/eruption VFX atlas; all gameplay authority remains outside pixels and animation.

Stage 1 introduces Rootling in Wave 2 beside two familiar Mirelings, then introduces Thralls in Wave 3 beside one Rootling, and ends with one Mireling, one Rootling, and two Thralls. The active cap remains four.

## Consequences

- The forest roster gets a cute readable starter identity without compromising the later Husk/Elder escalation.
- `EncounterWaveDefinition` gains data-only `rootling_count`; the controller retains one generic queue/spawn lifecycle.
- Rootling requires ongoing in-motion feel testing for telegraph length, sound, lane clarity, and crowd readability before Husk is implemented in Stage 2.
