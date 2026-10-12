# Decision 095: Introduce Varkuun Through an Aerial Entrance and Real-Recording Audio Suite

## Status

Accepted — 2026-08-15

## Context

Production Stage 5 already had its route, basin, boss mechanics, and HUD seam, but the guardian still entered as a placeholder and its first audio pass used procedural cues that did not carry the weight of the approved animation. The owner requested an unmistakable sky-fall entrance, a long audible jump, a stronger prison sound, full in-game boss coverage, and a correction for Space advancing dialogue twice.

## Decision

Name the guardian **Varkuun, Lord of the Withered Grove** while retaining `stage_5_boss` as the stable technical identifier. Crossing the production basin threshold hides combat authority during one presentation sequence: Varkuun descends from 158 pixels above his grounded visual position, lands through the approved crater/shake package, delivers three portrait lines, then enables the named top-screen HUD, boss target/physics, and music.

Use curated real CC0 recordings rather than generated synthesis for every Varkuun action family: footstep, lunge, slap, jump launch, sustained air travel, jump impact, root prison, hurt, 30-percent phase escalation, defeat, entrance descent, and entrance landing. After owner testing found the original loop effectively absent, use Cleyton Kauffman's CC0 `Boss Battle Theme` OGG as a clearly audible fantasy/JRPG orchestral loop at a dedicated -7 dB encounter level; preserve the superseded `Determined Pursuit` WAV outside runtime imports. Store exact source and license provenance in `assets/audio/ATTRIBUTION.md`. `Stage5BossAudio` observes state, landing, movement, and health signals only; it never chooses attacks or damage. One prison cast starts one prison cue, and the phase cue is driven by accepted health damage rather than movement polling.

The northern threshold gates only awakening and entrance presentation. Once combat begins, Varkuun's movement and jump target bounds cover the full traversable production map so retreating down the approach cannot exploit a basin leash.

Let the focused native dialogue button exclusively consume Space/Enter. `DialoguePanel._unhandled_input()` retains F interaction and Escape cancellation but does not independently consume `ui_accept`, preventing one physical press from taking both paths. The visible prompt names F, Enter, and Space.

## Consequences

- The production encounter now has a complete authored start and a coherent heavyweight sound identity.
- Combat jumps read as launch, time in the air, and impact rather than one short disconnected effect.
- All sound playback remains presentation-only and replaceable without touching combat authority.
- The Stage V milestone reward and any post-boss anonymous-power event remain separate future decisions.
