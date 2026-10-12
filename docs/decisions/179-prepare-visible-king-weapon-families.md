# Decision 179: Prepare visible King weapon families and equipment

- **Status:** Accepted design direction and preparation; runtime implementation pending
- **Date:** 2026-10-04

## Context

The owner wants more expressive King basic attacks and authorizes refactoring integrated art to support Sword, GreatSword, Dual sword, Axe, Scythe, visible armor and helmets. They request generated samples, correct pixel style, genuine walking/facing and connected weapon movement. They also suggest Pixel Slayer Saga as inspiration.

## Decision

Owner acceptance on2026-10-04: the compact V2 equipment art style is approved. Specific weapon variants, recipe costs and stage assignments are still open; Decision180 now accepts the crafting-led collection model. Approval does not claim implemented animation, masks, crafting recipes or progression.

Owner refinement on2026-10-04: simplifying/recreating armor and weapons to fit King's existing compact body is authorized. New V2 front/back armor appearances and standalone axe/scythe choices plus native-size comparisons are prepared under equipment_design_v2_2026_10_04/. Heartwood is a recommendation, not owner selection; no full armor masks or equipped weapon animation is implemented. Existing item/recipe IDs, stats and progression stay intact.

Owner correction on2026-10-04: axe/scythe concept designs are rejected. Design each new weapon independently first, show weapon-only choices, then use the selected silhouette/proportions/grip as the reference for King carry and animation. Current rejected boards are retained for history and cannot serve as accepted production references. Replacement designs remain pending.

Prepare a small set of weapon-family poses and attacks reusable across compatible item appearances. Preserve King's identity, current gameplay body size, authoritative targeting/damage/phase ownership and existing item/save IDs. Visible family and equipment presentation is allowed to replace the signature-only visual restriction of Decision071 for future King implementation. This does not migrate current equipment or change F5 art by itself.

Generate samples before multiplying full action sets. Six concept boards are complete under art_source/generated/characters/king/equipment_families_2026_10_04/, with individual prompts, unchanged originals and an offline audit. Raw source boards fail runtime alpha/spacing conventions and are not SpriteFrames.

Compare a registered body-plus-weapon approach with integrated corrections for difficult grips. Armor/helmet overlays must share body poses, masking and depth anchors; do not assume any arbitrary helmet fits every head frame. Accessories such as pendants remain stat-only. Item tiers reuse compatible family art, while distinct grips/lengths may need explicit variants.

First prove one heavy attack at native scale, then four directions/chain and real leg-exchange walking. Contact windows and family damage budgets remain data-owned. Do not fake greater reach with a decorative wave or make two blades accidentally double all damage.

Pixel Slayer Saga's official listing supports weapon-dependent moves and customizable looks as inspiration. Actual advertisement choreography, animation frame counts and asset construction remain unverified. Maintain Battle of Gods' direct-control combat and King/divine-patron identity.

## Alternatives and consequences

A full integrated sheet per item has high production cost; one arbitrary rotating weapon over the old sword body breaks grip and leaves the baked sword visible. Family-level reuse with selectively integrated corrections is the preferred proof direction, not a completed implementation.

Keep existing gameplay while proving presentation. Skill transitions to King's summoned weapons, exact family balance/acquisition and any Stage10 reward remain open. No old IDs, profile data or accepted King assets are removed by preparation.

Sources: [family plan](../design/king-weapon-family-and-basic-hit-redesign.md), [official reference listing](https://apps.apple.com/ph/app/pixel-slayer-saga/id6795060070).
