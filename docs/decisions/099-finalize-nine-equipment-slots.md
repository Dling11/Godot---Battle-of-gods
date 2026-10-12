# Decision 099: Finalize Nine Explicit Equipment Slots

> Superseded in armor count by Decision 101, which adds Leggings and finalizes ten positions.

- **Status:** Accepted; Gear presentation implemented, non-weapon equipment authority planned
- **Date:** 2026-08-15

## Context

The former paper doll used one weapon, three broad relic positions, and two generic accessory positions. That model did not clearly communicate what the player could build, made bracers compete with gloves, and left future crafting and balance dependent on ambiguous `Accessory I-II` labels. The equipment model needs to be settled before armor, recipes, item stats, and save data are implemented.

## Alternatives Considered

1. Retain the compact six-slot essence/relic model and let item families share broad positions.
2. Use one weapon, four armor positions, and two generic accessory positions.
3. Use one weapon, four explicit armor positions, and four explicit accessory positions.

## Decision

Choose option 3. Every character loadout has exactly nine positions:

| Group | Slot | Primary future design space |
|---|---|---|
| Weapon | Weapon Essence | attack power, basic-chain traits, and skill scaling without replacing character-owned signature art |
| Armor | Head | defense, resistance, and situational protection |
| Armor | Plate | maximum vitality, armor, and broad survivability |
| Armor | Gloves | attack handling, recovery, and close-combat utility |
| Armor | Boots | movement, dash recovery, and hazard protection |
| Accessory | Bracer | stagger, offensive handling, and modest skill tempo |
| Accessory | Amulet | vitality, regeneration, and resistance |
| Accessory | Ring | cooldown, skill power, and bounded conditional triggers |
| Accessory | Talisman | dash, mobility, hazard, and status utility |

The paused surface retains the compact two-page `CHARACTER & BAG` / `ACTIVE SKILLS` structure. The first page places the loadout and King preview at upper left, selected-item information at upper right, and the 24-position filtered inventory across the bottom. Head begins the left armor column, Weapon Essence sits upper-center, and the four accessories form the right column. Cards group inward beside the portrait rather than occupying the outer panel edges. Empty equipment positions are honest placeholders; they do not imply implemented item definitions, stats, crafting, equipping, or persistence.

Decision 069's Stage V/VIII/X cadence remains accepted, but its two-generic-accessory model and gloves/bracers slot sharing are superseded. Stage V should complete the first Weapon Essence plus Head, Plate, Gloves, and Boots crafting tier. Stages VI-VII prepare accessories, Stage VIII unlocks standard accessories, and Stage X supplies signature/relic-tier accessory outcomes.

## Consequences

- The final loadout has one weapon, four armor pieces, and four accessories.
- Each accessory has a stable identity suitable for future item data, crafting, stat budgets, and save fields.
- The nine-slot paper doll remains readable through compact symmetric slot cards while the familiar right-side information and bottom inventory layout remain intact.
- Current weapon resources retain ordinal zero and remain compatible with the expanded `EquipmentDefinition.Slot` enum.
- Armor/accessory item definitions, stat aggregation, equip commands, crafting transactions, and save migration remain separate future implementation work.
