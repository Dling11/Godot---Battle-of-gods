# Stage V Core Equipment Set

- **Status:** Six output definitions, live equipment authority, stats, sorting, drag-to-equip, persistence, and atomic Rootforge crafting implemented
- **Approved direction:** 2026-08-15
- **Owning decisions:** 071, 097, 101, 120, 121

## Purpose

The first crafted set must reward completing The Dead Forest without erasing earlier challenge. It uses only live reusable authorities: weapon/basic damage, maximum health, armor, Ward, normal-attack speed, regeneration, and grounded movement speed. King retains his visible sword; the Weapon Essence changes combat data, not character art.

## Set

| Slot | Item | Implemented data | Intended role |
|---|---|---:|---|
| Weapon Essence | Varkuun Edge | 16-20 Basic Hit; 38 Skill Power; 8% critical chance; 150% critical damage | meaningful Stage VI-XV damage band with unchanged timing/reach/art |
| Head | Old Bark Helm | +50 maximum health; +2 health/second | regeneration plus moderate health |
| Plate | Heartwood Plate | +30 armor | main damage-reduction investment |
| Gloves | Rootfiber Gloves | +15% basic-attack speed | offensive handling without changing skill cadence |
| Leggings | Mirebound Leggings | +90 maximum health | primary health investment |
| Boots | Mirehide Boots | +15% grounded movement speed | raises 110 px/s base movement to 126.5 px/s |

The five armor pieces total +140 maximum health, +30 armor, +2 health/second, +15% basic-attack speed, and +15% grounded movement speed. Every value is live when equipped. Shared caps prevent future stacking from exceeding +50% basic-attack speed, +35% movement speed, or 50% critical chance.

## Recipes

| Output | Exact cost |
|---|---|
| Varkuun Edge | 2 Varkuun Core, 3 Rootbound Core, 5 Weathered Fittings, 3 Living Bark Plate |
| Old Bark Helm | 1 Varkuun Core, 3 Living Bark Plate, 2 Rootbound Core, 4 Forsaken Cloth |
| Heartwood Plate | 1 Varkuun Core, 4 Living Bark Plate, 4 Armored Hog Hide, 4 Husk Heartwood |
| Rootfiber Gloves | 6 Root Fiber, 3 Armored Hog Hide, 3 Thorn Sap |
| Mirebound Leggings | 1 Varkuun Core, 4 Armored Hog Hide, 3 Living Bark Plate, 4 Root Fiber |
| Mirehide Boots | 5 Armored Hog Hide, 4 Mire Membrane, 4 Root Fiber |

The complete set consumes five Varkuun Cores. Stage V grants two on first clear and one on replay, so a full set requires first clear plus three successful replay claims. Gloves and Boots deliberately use the Stage I-IV ecology without an additional boss catalyst.

## Visual Contract

All six icons use 64x64 binary-alpha runtime PNGs with a shared petrified-root, charcoal iron, restrained moss, green core, muted violet seam, and sparse aged-gold language. Varkuun Edge, Helm, Plate, and Gloves use the clearer generated V2 silhouettes; Boots and Leggings retain their approved sources. Varkuun Core's 24x24 material icon is a separate cracked seed-heart held by roots so it cannot be mistaken for a bottle.

## Progression Boundary

Varkuun Edge is intended to carry a normal player through roughly Stages VI-XV, not the entire game. Stage VI remains enterable with King's starter equipment: crafted ownership is never checked by the portal or stage flow. The difficulty contract instead uses tougher, harder-hitting new enemies so skipping the set costs time and safety. Mirelings and Rootlings remain in earlier stages/replays but do not belong to the new Stage VI campaign roster. Exact encounter values still require Stage VI implementation and a starter-versus-crafted playtest.

## Current Boundary

- Nema presents and atomically crafts all six recipes after the Stage V category discovery, permanent seal, and exact costs are present.
- F9 grants maximum materials, all six outputs, their blueprint discoveries, and the Stage V seal without saving.
- Owned non-weapon gear can be selected or dragged into matching slots; effects and equipped choices persist in normal saves.
- Stage VIII accessory recipes remain future previews and are not part of this set.
