# Decision176: Use one generic underfoot monster arrival

Date: 2026-10-03.
Status: Implemented in normal I–VI after owner testing; further owner feel/phone review remains open.

## Context

Owner accepts arrival sound, rejects code-drawn visuals and initially requests raster A/B/C choices in-game. After asking whether effects depend on monster size, they reject multiplying frame sets for small/large/boss tiers: a generic monster spawn should be easier to create and reuse. Frames remain useful, but the mechanism must avoid body-dependent art production.

## Decision

Make the cue a low ground-level event at the arrival point, independent of monster height/silhouette. One shared generated four-drawing atlas (warning/burst/dissipating/remnant) serves every ordinary encounter mob. Keep native pixel density/origin, reuse existing enemy body appearance, and let EncounterController retain safe reserved timing/materialization/AI/rewards/sound. No body-fitted portal or per-enemy art selector. Prototype small Rootling/tall Thrall/large Crag Bear/Husk with the exact same resource/scale before campaign promotion.

## Alternatives

Size-specific or tier-specific A/B/C sheets multiply art/registration work and require future monster configuration. Stretching a tall portal blurs pixel density and still depends on body shape. Full per-character dissolve shaders or a new particle/pooling framework add implementation scope without proving the needed generic cue. A small shared raster ground burst retains real changing drawings with only four assets total.

## Consequences

Visible footprint is a spawn cue, not a collider or a body enclosure; actual safe placement uses enemy definition footprints independently. Existing body spawn transitions differ and remain untouched; custom scripted boss introductions are outside this prototype. Same timing/SFX/real actors and isolated rewardless/suppressed-save review allow direct owner testing. Source/prompt/manifest are retained. Native61 prototype checks passed. After owner testing, the common summon scene now uses shared raster presentation; native40 campaign arrival checks pass. The procedural source is archived and SummonEffect is only a release contract. These checks do not establish final owner art approval or phone performance. Generic review supersedes further primary A/B/C selection or per-size frame generation.

See docs/design/enemy-arrival-and-horde-profiling.md and art_source/review/encounters/generic_spawn_2026_10_03/README.md.
