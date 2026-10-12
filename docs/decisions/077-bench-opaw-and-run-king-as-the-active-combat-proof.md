# Decision 077: Bench Opaw and Run King as the Active Combat Proof

## Status

Accepted on 2026-08-11.

## Context

King's approved simple identity now has stable four-direction locomotion and a first directional basic-slash board. The owner wants development and playtesting to focus on King instead of continuing to expand Opaw. A full roster/save migration is not ready, but leaving Opaw as the live presentation prevents honest gameplay-scale review of King's frames and combat direction.

## Alternatives

- Keep Opaw active until King's complete attacks, reactions, skills, roster data, and save record exist.
- Delete or archive Opaw and rewrite the player around King immediately.
- Temporarily make King the live presentation/loadout while retaining Opaw as a complete regression-tested rollback package.

## Decision

- `entities/player/player.tscn` temporarily instantiates King as `character_id = king` and uses King's simple `SpriteFrames`.
- Opaw's compact and Wayfarer resources, abilities, data, scripts, and focused tests remain active supported project content; they are benched, not archived or deleted.
- King's integrated signature sword hides only the detached equipment weapon sprite. Existing presentation-only cleave trails and authoritative weapon data/contact shape remain reusable during the proof.
- King initially received four honest named but unequipped skill slots. Decision 078 now equips only the implemented Echoing Sever proof in Slot 1; Slots 2-4 remain sealed. F9 does not silently equip Opaw's skills on King, and Eira cannot awaken Opaw's Skill 2 for a non-Opaw character.
- King's authored locomotion and basic slash are production review assets. Locomotion-derived dash and temporary reaction aliases prevent missing animation calls but are not final King action art.
- Owner review rejected the first four-pose slash. The replacement uses six chronological poses per direction, exact mirrored side rows, one stable body scale/baseline per direction, and two presentation frames for each authoritative combat phase. The isolated preview must mirror the real one-body node structure and cycle animations rather than displaying four `AnimatedSprite2D` bodies simultaneously.
- Shared progression, vitality, inventory, and weapon-stat authorities remain in place for this proof. Their current Opaw-named data is compatibility scaffolding, not final per-character progression.

## Consequences

- Normal game launch, Sanctuary, and Stages I-III now provide gameplay-scale King movement/basic-attack review.
- King Skill 1 is available under Decision 078; Skills 2-4 remain unavailable until their own targeting and gameplay authority exist.
- Opaw-specific tests must configure Opaw deliberately instead of assuming the default player scene is Opaw.
- The next production gate remains one King mechanic at a time: approve Echoing Sever's targeting/contact proof, then author its dedicated action-owned body/VFX sheets or proceed to dedicated reactions. Do not generate all four skills at once.
- A later roster selection system supersedes this temporary default swap without discarding either character.
