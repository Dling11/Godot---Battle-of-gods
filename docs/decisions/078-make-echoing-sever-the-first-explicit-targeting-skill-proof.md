# Decision 078: Make Echoing Sever the First Explicit-Targeting Skill Proof

## Status

Accepted on 2026-08-11.

## Context

King needs a first skill that proves deliberate aim and readable contact before more generated animation work. Reusing Opaw's immediate Skill 1 would preserve the exact blind-direction problem the new character is meant to solve, while generating a complete animation package before testing targeting and timing risks another expensive discarded sheet.

## Alternatives

- Reuse Piercing Rush or Crescent Sever as an immediate directional cast.
- Generate final body/VFX sheets first and fit authority to the art afterward.
- Prove one fresh aimed skill with temporary replaceable presentation, then authorize exact-grid art after gameplay review.

## Decision

- King Skill 1 is `Echoing Sever`, not Crescent Sever or an Opaw ability variant.
- First press enters a 130-pixel, 100-degree wedge preview. Pointer or right stick aims continuously through 360 degrees without changing ordinary movement-facing rules; King selects the nearest existing cardinal body animation only for presentation.
- Left-click or right trigger confirms. Repeating Skill 1 is consumed but does not commit, preventing accidental double-tap casts. Right-click or Esc cancels without cost or cooldown. Movement preserves the preview; dash cancels it before moving. Confirmation snapshots direction and starts cooldown.
- The first contact deals 110% weapon damage. The same fixed rift reactivates once after a 0.30-second inactive delay for 75%; neither window grants invulnerability.
- `DirectionalWedgeTargeting` owns intent/presentation only. `EchoingSeverComponent` owns phases and exactly two hitbox activations. VFX/audio remain observers.
- The target preview draws its pixel wedge at the exact aim angle while keeping its node transform stable, plus an approved sword-point hardware confirmation cursor. After owner approval, the primary cleave and delayed rift moved to separate action-owned six-frame exact-grid atlases, received distinct cut/fracture audio and restrained recoil, and intentionally retained King's stable nearest-cardinal six-frame slash body. A unique Skill 1 body sheet is deferred rather than blocking later abilities.
- Opaw data and behavior remain untouched. His explicit regression setup restores Piercing Rush/Consecutive Thrust on the benched player scene.

## Consequences

- King now has one honestly equipped playable skill while Skills 2-4 remain sealed.
- Basic-attack mouse input cannot leak through while targeting.
- The delayed rift can be balanced independently from the initial cut without hidden continuous damage.
- Next review focuses on aim feel, visible/contact coverage, echo readability, cooldown, and damage before generating skill frames.
