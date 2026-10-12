# Decision 071: Use Character-Owned Combat and Equipment Essences

- **Status:** Accepted, with Opaw replacement/archive consequences superseded by Decision 072; future King signature-only visible-weapon restriction superseded by Decision179 (preparation, runtime pending)
- **Date:** 2026-08-02

## Context

The active prototype binds Opaw's compact armless body to a detached visible sword and a profile-backed weapon inventory. That proved equipment, skills, save/load, and directional combat, but it makes each later weapon family demand more presentation work and does not support the owner's new character-led direction. At this decision's creation King was expected to replace Opaw; Decision 072 now preserves Opaw and adds King as a separate character. The character-owned combat and essence conclusions remain active.

The current three-swing normal attack also changes only presentation. A reported opposite-direction input during an attack exposed the risk of allowing live facing presentation to drift from snapshotted hit authority.

## Alternatives

1. Keep Opaw and expand detached visible weapon families indefinitely.
2. Make every playable character a cosmetic skin over the same weapons, attacks, and skills.
3. Give each character an owned visible weapon/fighting style and equip stat-bearing essences/relics.

## Decision

Adopt option 3. Each playable character owns their signature visual weapon/fighting style, body presentation, authoritative basic attack chain, skill loadout, and ultimate presentation contract. Equipment becomes stable-ID essences/relics that modify stats and authored traits without automatically swapping the visible signature weapon. Decision 072 establishes King as additive roster content and keeps Opaw active.

`Player` remains the generic technical actor. Character data and runtime roster state must be separate. Combat direction is snapshotted per accepted attack/cast and cannot rotate until that committed action releases. Cinematic effects remain presentation observers of authoritative gameplay events.

Opaw remains active supported runtime content before and after King launches. His specific assets/code/data are not migration archive candidates. Reusable systems support both characters; only rejected experiments or genuinely superseded duplicates move to the archive.

## Consequences

- Forest crafting Segment 5 pauses until its output equipment is defined as essence/relic content rather than physical visible weapon replacement.
- The existing Ashwood/Iron ownership and save data need explicit aliases or a profile migration.
- A real attack-chain resource and character-definition boundary are required before King content production.
- King and later characters require separately approved body/action frames, hand/weapon contacts, portraits, skills, and VFX.
- The existing maps, enemies, Sanctuary NPCs, loot, materials, recipe data, encounter systems, and generic combat components remain useful.
- Spectacular abilities may use camera/overlay/VFX choreography, but presentation cannot own damage, invulnerability, target resolution, or persistent state.
