# Decision 038: Preview Skill-Synergy Equipment Before Persistence

- **Date:** 2026-07-15
- **Status:** Amended by Decisions 039 and 065; authority boundary remains accepted, exact layout superseded

## Context

Equipment can make progression and Sanctuary services meaningful, but a numerical gear ladder can also make active skills feel unnecessary. Inventory ownership, shop prices, drops, persistent profiles, stat formulas, and death consequences are not approved. Implementing those rules together would hide several major product decisions inside one UI task.

## Alternatives Considered

- Delay all equipment work until the complete profile, inventory, and economy are designed.
- Implement random drops and shop purchases immediately using the current session-only XP/coin state.
- Add large equipment bonuses first and rebalance skills and enemies afterward.
- Build an honest read-only armory preview that validates item identity, rarity, slots, and skill relationships without claiming acquisition or combat effects exist.

## Decision

At acceptance, the character surface used `Gear & Armory` and `Active Skills`, with five eventual slots around an animated preview. Decision 065 supersedes that exact Gear layout with `Character & Bag`, seven paper-doll positions, and a compact shared inventory presentation. The rule that UI observes equipment authority rather than owning it remains unchanged. Armor and accessories may remain icon-and-stat equipment in the first playable version; they do not require layered world sprites.

The original preview explored `A Grade`, `S Grade`, `Legendary`, and `Mythic` through Wayfarer's Iron, Gloamfang, Sunroot Oath, and Veilrender. Decision 039 supersedes that vocabulary for the active beginner surface: Opaw now shows only the Wood-rank Ashwood Blade, and the former four concepts remain preserved legacy material. The read-only presentation boundary in this decision still applies.

Every showcased weapon may have an authored skill-synergy identity. Equipment may reinforce normal attacks, dash, and equipped skills, but must not replace active-skill decisions or readable combat mastery. These synergy descriptions and preview power values are presentation only. The authoritative Ashwood Blade remains `WeaponDefinition` with the existing 25 damage; no preview resource changes combat, inventory, saving, rewards, or enemy balance.

## Consequences

- The equipment and skills UX can be reviewed now without committing to unsafe persistence or economy rules.
- `EquipmentDefinition` and `EquipmentShowcaseDefinition` are immutable content/presentation boundaries, not mutable inventory state.
- Higher-rank items must not become Stage 1 shop stock or ordinary drops merely because concept art exists. Active equipment progression will require persistent ownership, acquisition rules, stat aggregation, and stronger authored elite/boss encounters.
- Item icons and restrained rarity auras may be replaced without moving gameplay authority into UI.
- A future decision must approve profile saving, death consequences, inventory ownership, equip/unequip commands, prices/drops, and stat formulas before these previews become obtainable equipment.
