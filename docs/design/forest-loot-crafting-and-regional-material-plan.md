# Forest Loot, Crafting, Replay, and Regional Material Plan

- **Status:** Approved Forest Stages I-X regional/economy direction; Segments 1-5 implemented and Segments 6-8 pending. Decision 122 prevents the regional motif from becoming a global naming formula.
- **Approved:** 2026-07-26
- **Runtime coverage today:** Stages I-VI, including the production Elder Ascent route and Crag Bear/Crag Iron/Echo Claw additions; collectible pickups, profile-backed weapon/gear/material/recipe/claim state, Stage III and V milestone chests, six finalized Stage V equipment definitions/icons/recipes with live equip/stat authority, and Rootweaver Nema's atomic category/seal/material/output/save transaction. Stages VII-X remain planned.
- **Planned content covered here:** Forest Stages I-X and reusable loot/crafting infrastructure for Stage XI onward

## Purpose

Battle of Gods must provide a reason to revisit completed stages beyond repeating the same fights for larger numbers. The approved long-term loop is:

```text
Fight -> Loot -> Craft -> Build -> Master -> Advance
```

First clears advance story and unlock content. Replays provide controlled material goals, Hunt variants, and milestone rewards. Sanctuary turns those rewards into deterministic equipment choices. Later regions reuse the same technical and visual grammar without collapsing into `Leather++` inventory clutter or cheap recolors.

This plan is intentionally broader than the six implemented stages so save data, item identities, folder ownership, icon production, monster design, and crafting authority can extend into Stages VII-XX. Forest vocabulary remains region-scoped rather than a default for unrelated characters or global systems.

## Decision 071 Equipment Overlay

The fight/loot/craft/replay structure and Stage III/V/VIII/X reward cadence remain approved. Decision 099 finalizes nine positions: Weapon Essence; Head, Plate, Gloves, and Boots armor; plus Bracer, Amulet, Ring, and Talisman accessories. These items modify a playable character's stats or authored traits without automatically replacing the character's visible signature weapon.

## Approved Product Rules

- Save/Continue is a prerequisite for loot and crafting. Grinding must never depend on keeping one application process open.
- Crafting starts deterministic. A recipe produces one known item with known stats; random affixes are deferred.
- Authored milestone chests never resolve empty; ordinary stages may bank collected enemy drops without a chest.
- First-clear progression rewards belong to authored milestones rather than every stage.
- Replays target roughly two to three useful clears per ordinary equipment piece, not long identical-run grinds.
- Bosses guarantee their unique crafting material.
- Crafted essences/relics improve survivability, expression, and margin for error. A later stage must remain technically beatable through mastery without enforcing an opaque hard gear wall.
- Difficulty must come from readable behaviors, combinations, armor-break opportunities, positioning, and elites rather than health inflation alone.
- Earlier regions retain limited material relevance, but new-region recipes primarily use current-region materials.
- Character level does not become an infinite raw-stat treadmill. Region caps may expand, while post-cap Mastery supplies bounded utility, crafting, cosmetic, title, or material benefits.
- Reward resolution, direct Stage I-II/VI banking, the Stage III Reliquary, Stage V equipment/stats, Rootweaver Nema's atomic crafting, and Decision 126's production Stage VI route are implemented. Hunts, Mastery, and Stages VII-XX remain unimplemented.

## First-Clear and Replay Loop

### First clear

1. Complete the authored encounter.
2. Bank collected drops directly on an ordinary stage or open its authored milestone chest.
3. Receive any milestone-specific permanent seal, discovery, catalyst, or guaranteed material payout.
4. Record the clear in story/profile state.
5. Unlock the next route and the cleared stage's replay/Hunt entry.

### Replay clear

1. Select a previously cleared stage or an authored Hunt variant from Sanctuary.
2. Complete the normal or modified encounter.
3. Retain collected protected enemy drops and any repeatable milestone payout.
4. Roll only the authored optional secondary/rare rewards.
5. Apply bad-luck protection where a material is required by a recipe.

### Hunt variants

Hunts reuse a stage deliberately rather than rerunning an identical campaign scene. Candidate modifiers include:

- Elite enemy replacement
- Rootstorm or another hazard derived from the replayed stage's actual region
- Increased ranged pressure
- Limited regeneration
- Boss-remnant encounter
- Bonus chest objective
- Restricted recovery window

No daily timer, advertisement loop, or real-money loot-box structure is approved.

## Current Enemy Drop Direction

These names and region-prefixed stable IDs are now approved through their `MaterialDefinition` resources. Initial quantities remain balance-tunable until reward and crafting playtests, but their identity and purpose are locked.

| Implemented enemy | Material identity | Crafting direction |
|---|---|---|
| Mireling | Mire Resin; Mire Membrane | Regeneration, status resistance, flexible footwear |
| Rootling | Root Fiber; Young Heartwood | Bindings, gloves, beginner protective pieces |
| Forsaken Thrall | Forsaken Cloth; Weathered Fittings | Armor lining and weapon fittings |
| Bramble Spitter | Barbed Seed; Thorn Sap | Thorn/critical identity and ranged-pressure resistance |
| Rootbound Husk | Husk Heartwood; Rootbound Core | Reinforced Forest equipment and rare recipes |
| Crag Bear | Crag Iron; Echo Claw | Reinforced fittings, resonance, and future accessory components |

Leather is not assigned arbitrarily to a creature without a visible hide identity. The implemented Stage 4 Armored Hog now supplies the first true hide and bark-plate inputs. Stages 1-3 instead support rootfiber wraps, cloth equipment, charms, and weapon components.

## Provisional Forest Stage IV-X Content Skeleton

The later roles and material purposes below remain planning slots rather than final names or approved enemy art. Stage IV's eastern-decay level, Armored Hog, Hide, and Living Bark Plate and Stage V's Varkuun milestone are implemented. Decision 122 permits the Forest theme through Stage X while rejecting repetitive motif-first naming.

| Stage | New enemy/content role | Material purpose |
|---|---|---|
| 4 | Armored hide-bearing Forest beast | Hide and bark plates for leather armor |
| 5 | Implemented Varkuun major-boss milestone | Permanent core-gear crafting seal plus repeatable Varkuun Core catalyst |
| 6 | Implemented `The Elder Ascent`; normal armored Crag Bear melee/slam family | Crag Iron fittings and Echo Claw resonance/accessory components |
| 7 | Compact story stage with the masked Examiner and a Continue/Challenge event; ordinary roster remains open | Any ordinary-stage drops may prepare accessory components, but the optional overpowered test cannot gate core progression |
| 8 | Fungal/spirit mini-boss milestone | Permanent standard-accessory seal plus repeatable fungal/spirit catalyst |
| 9 | Modular reclaimed magical ruins; provisional fast Mage plus space-controlling Stone Warden pairing | Arcane/resonant plus durable/ancient component families for refined accessories |
| 10 | Major Forest boss | Permanent relic/signature-accessory crafting seal plus repeatable unique catalyst |

Stage VI onward introduces new roles rather than continuing Mireling/Rootling filler. Decision 127 removes Mirelings and Rootlings from Stage VI; known Forest enemies may return only in authored combinations where their role remains useful. Stage VI therefore uses Thralls as melee screeners, rebuilt Spitters as ranged priorities, and one finale Hog around the approved Bear population. Aim for roughly one important new family every one or two stages and never use palette-only replacements.

Decisions 124-127 complete Stage VI on the approved muted teal/pale-stone top-down terrace with modular cliffs, trees, rocks, fixed-bank waterfall, collision/navigation, composition-heavy five-wave pressure, Crag Bear drops, and production completion. The rejected distant canyon/threshold remain archive-only. Decisions 131-132 assign Stage VII a compact story role: the calm masked Examiner presents an honest Continue/Challenge choice and an optional fair recognition test. His lean ivory/gold silhouette, Divine Split Glaive, animation-first behavior, and art-first large-scale approval gate are documented; he does not die during the expected first encounter, and defeating the optional overpowered test cannot be required for ordinary progression. His personal name, ordinary roster, dialogue, reward, replay, saving, transition rules, selected size, and final pixel proof remain open.

Stage IX owns the reclaimed magical-ruins direction that was deliberately removed from Stage VII. Its modular top-down environment and provisional Mage/Warden pairing should create ranged repositioning behind physical space control. The Mage must use bounded retreat rather than indefinite kiting; the Warden must block/control space rather than being ignorable slow health. Their material families prepare later accessory work, but exact IDs, rarities, drops, and recipes require the individual content contracts.

### Forest crafting tiers

- **Stages 1-3:** collect and inspect root, mire, cloth, thorn, and Husk preparation materials; no recipe unlock is granted yet
- **Stage 4:** implemented environment/crowd-pressure route plus Armored Hog hide-bearing ecology and protected materials; leather recipes remain future work
- **Stage 5:** permanently unlock core crafting for Weapon Essence plus Head, Plate, Gloves, and Boots; consume a repeatable boss catalyst in relevant recipes
- **Stages VI-VII:** expand spirit, reinforced armor, heavier weapon support, and standard-accessory components/blueprints
- **Stage VIII:** permanently unlock standard accessories and award a repeatable fungal/spirit/binding catalyst
- **Stage IX:** refine regional fittings and advanced preparation
- **Stage X:** permanently unlock relic/signature-accessory crafting and supply the repeatable signature catalyst

A crafting seal is permanent progression and is never consumed. A catalyst is repeatable inventory material and may be consumed by deterministic recipes. Decision 101 locks Stage V to Varkuun Edge, Old Bark Helm, Heartwood Plate, Rootfiber Gloves, Mirebound Leggings, and Mirehide Boots; their exact costs and stat budgets live in `docs/design/stage-5-core-equipment-set.md`. Mireward Charm and Thornward Clasp remain Stage VIII regional previews. Decision 101 preserves later accessory slots as Bracer, Amulet, Ring, and Talisman; their final items and stat budgets remain unimplemented.

Stage V's six recipes and item names are locked by Decisions 100-101 and craftable under Decision 120. Crag Bear, Crag Iron, and Echo Claw are locked by Decision 126. Decision 131 locks the Stage VII/IX narrative roles; Decision 132 locks the Examiner/Executioner role titles and high-level visual/weapon identities. Their personal names plus Mage, Warden, material, and item names remain open until their individual content contracts are approved. The regional theme does not require every name to mention roots or trees. Stage IV's Armored Hog contract remains locked.

## Monster Content Contract

Every new recurring monster requires an approved contract before bulk art or runtime implementation:

1. Narrative and ecological identity
2. Combat role, telegraph, and counterplay
3. Stage introduction and later reuse
4. Silhouette, pixel dimensions, palette, and lighting
5. Animation list, direction rows, cell sizes, safe margins, and frame counts
6. Movement collision, hurtbox, attack shape, navigation footprint, and occlusion needs
7. Controller state ownership and reusable components
8. Audio identity and legal provenance
9. Common, secondary, rare, elite, or boss drops
10. Recipes and stats supported by those drops
11. Portrait/profile requirement
12. Focused regression and performance coverage

Visible biology must support loot identity. Bark-plate drops require visible armor-like bark; venom requires a readable gland, sac, sting, or attack; fungal thread requires fungal or mycelial anatomy. A material may not be attached after the fact merely to fill a recipe.

## Material-Family Visual Grammar

The project uses a small reusable visual language instead of creating every icon from zero or relabeling indistinguishable recolors.

### Approved icon families

- Vial: venom, acid, oil, holy water, liquid essence
- Hide: ordinary hide, barkhide, scaled hide, frost hide
- Fiber bundle: root fiber, silk, mycelial thread, spectral thread
- Plate/chitin: bark plate, insect chitin, volcanic shell
- Ore/fitting: iron scrap, warden fitting, divine alloy
- Seed/crystal: barbed seed, frost seed, ember crystal
- Core: Rootbound Core, later regional cores
- Relic: unique boss and story materials

### Reuse levels

1. **Exact reuse:** a universal material remains the same item and ID across regions, such as Leather, Cloth, Iron Fittings, or Binding Thread.
2. **Template reuse:** the approved silhouette/container is reused, but the substance, internal cluster, palette, glyph, and final texture differ. Mire Venom and future Corrosive Acid may share a vial family without becoming the same icon.
3. **Original silhouette:** boss hearts, divine relics, story key items, and physically unique materials receive dedicated art.

Text labels are data and are never painted into material icons. Rarity frames belong to UI presentation rather than the item bitmap. Important differences use silhouette, internal shape, glyph, or pattern and never depend on color alone.

### Venom/acid example

| Property | Forest venom | Future corrosive acid |
|---|---|---|
| Family | Vial | Vial |
| Container | Shared approved silhouette | Shared approved silhouette |
| Substance | Thick drops | Bubbling corrosive fluid |
| Identity mark | Fang/leaf | Corrosion/hazard |
| Tags | Poison, thorn, critical | Corrosion, armor break, resistance |
| Final runtime file | Separate PNG | Separate PNG |
| Display label | Resource data | Resource data |

Templates support deterministic generation, but each approved material receives a flattened final runtime PNG and a separate data resource. Runtime shaders must not recolor one generic icon into every material.

## Cross-Region Material Rules

Stage XI onward reuses the technical grammar and some universal materials, never the entire Forest economy or naming language.

- Ordinary later-region recipes should use roughly 20-30% universal or older materials and 60-70% current-region materials, with an occasional elite/boss catalyst.
- Old boss materials appear only in special cross-region upgrades, never every recipe.
- Higher-region materials differ by function and ecology, not names such as `Leather+`, `Leather++`, `Strong Leather`, or `Super Leather`.
- Examples of meaningful non-Forest variants include Acid-Sealed Hide, Scaled Hide, and Spectral Hide.
- A future region may reuse an enemy animation contract or technical behavior composition, but a regional creature variant requires distinct readable anatomy, attack behavior, telegraph/VFX, audio layer, drop profile, and `SpriteFrames` resource. Palette-only enemy swaps are insufficient.

The Stage XI-XX region theme, exact mechanics, and material roster remain open. The data/art grammar is locked so that choice does not require new infrastructure or recycled Forest terminology.

## Implemented Segments 2-3 Contracts

The following immutable contracts and responsibility boundaries are implemented. Segment 3 grants their authored rewards; no contract crafts an output.

### `MaterialDefinition`

- Stable `material_id`
- Display name and description
- Region ID
- Material family
- Grade/rarity metadata
- 24x24 runtime icon
- Crafting tags
- Optional source-lore metadata

### `DropProfileDefinition`

- Percentage-based common material entries
- Optional secondary entries
- Rare entries
- Quantity ranges
- Elite/boss guarantees
- Bad-luck-protection key where required

Enemy controllers do not calculate or roll loot.

### `LootTableDefinition`

- Stage/region identity
- First-clear guarantees
- Replay guarantees
- Optional rolls
- Blueprint/discovery/key-material entries
- Protection rules

Stage UI and chest presentation do not roll rewards themselves.

### `RecipeDefinition`

- Stable recipe ID
- Output equipment/material ID and quantity
- Required material IDs and quantities
- Unlock requirement
- Region/tier metadata
- Crafting category
- Deterministic result

### Runtime authorities

- `MaterialInventory`: implemented mutable known-material quantities with a versioned snapshot
- `RecipeDiscovery`: implemented known-recipe IDs in a dedicated versioned snapshot, separate from `StoryState`
- `LootState`: implemented first-clear claim IDs and bad-luck miss counters in a dedicated versioned snapshot
- `LootService`: implemented enemy/stage table resolution, validated material grants, expedition reward baselines, and reward observation signals
- `CraftingService`: implemented validation of unlocks/material-plus-gold costs/unique outputs and atomic spend/grant/save transactions
- `EnemyMemory`: implemented stable-ID defeat counts and spent boss-reconstruction charges
- `MaterialExchangeService`: implemented metadata-driven sale/reconstruction validation and atomic material/coin/memory rollback
- Existing equipment inventory/stat authorities: own crafted equipment and equip state
- `SaveService`: serializes explicit snapshots from progression, story, equipment, materials, recipes, enemy memory, and safe-location state
- UI: observes definitions/state and submits requests only

## Rootweaver Sanctuary Role

The approved crafting role is now implemented as **Rootweaver Nema**, an attractive adult female grove smith with a west-mid open-air Living Rootforge. Her compact screen-left three-quarter actor follows Eira and Orren's Sanctuary proportions while the portrait, auburn hair, forge apron, root hammer, tongs, and approved visible-arm work silhouette carry the adult character identity. Earlier realistic, elderly, and front-facing boards remain provenance only. `docs/design/rootweaver-nema-sanctuary-service-proposal.md` records the accepted identity, runtime package, dialogue, placement, and atomic crafting contract.

The role must remain distinct from Orren:

- Orren is dialogue-only after retirement of the weapon shop; he does not own current economy mutation.
- The Rootweaver transforms creature/region materials through deterministic recipes.

Segment 4 delivers:

- Character identity and narrative relationship
- Workshop placement and traversable footprint
- Opaw-scale sprite contract and named `AnimatedSprite2D` states
- 96x96 portrait/profile asset
- Dialogue and crafting interaction
- Tool/idle sounds plus attribution
- Crafting UI responsibilities

`RootforgeMenu` observes recipe/category discovery, seal ownership, material readiness, and unique output ownership. It delegates to the implemented atomic `CraftingService`, which coordinates the existing material, weapon/gear, and safe-profile authorities without allowing UI-owned mutation.

## Umi and the Echo Crucible

Decision 123 implements Umi as a global Sanctuary service rather than another Forest/root-named specialist. Her compact side-facing station sells ordinary surplus and reconstructs catalog materials from meld fuel, gold, and recorded source-enemy victories. The complete player flow and defaults live in `docs/design/umi-echo-crucible-material-exchange.md`.

The NPC owns no material table. Every `MaterialDefinition` declares its source, values, costs, thresholds, and protections; adding a valid definition to the canonical catalog automatically adds its Sell/Reconstruct behavior. Boss resources are explicitly protected from sale/fuel and require same-region Rare catalysts plus a ten-victory memory charge.

## Level, Gear, and Mastery Direction

- Current Forest development remains bounded by the authored character Level 1-10 curve.
- Later regions may expand the character cap in controlled bands rather than enabling infinite raw-stat scaling.
- Post-cap Mastery may be uncapped only if rewards stay bounded: crafting efficiency, material bonuses, titles, cosmetics, discoveries, or small capped utility.
- Varkuun Edge is targeted for Stages VI-XV. Stage VI remains freely enterable without crafted ownership; eight Bears plus five-live Thrall/Spitter pressure make starter-gear clears intentionally slower and riskier without an HP gate. Mirelings and Rootlings are absent.
- Stage XI should be balanced around partial Forest equipment, not require a complete perfect set.
- An expert player with incomplete gear should retain a viable path through readable mastery.

Exact regional caps, final character cap, Mastery categories, and reward percentages remain open.

## Asset and Folder Contract

Planned organization:

```text
art_source/generated/items/materials/templates/
assets/items/materials/common/
assets/items/materials/forest/
assets/items/materials/<future_region>/
data/items/materials/common/
data/items/materials/forest/
data/items/materials/<future_region>/
data/loot/forest/
data/loot/<future_region>/
data/crafting/recipes/forest/
data/crafting/recipes/<future_region>/
```

- Material wallet/list icons use native 24x24 pixel art.
- Detailed equipment portraits retain the approved 64x64 contract.
- Generated assets retain source board, cleaned/intermediate material where needed, deterministic processor, final runtime PNG, and import metadata.
- Character sheets follow `docs/design/character-animation-pixel-contract.md`.
- Final recurring actors expose named `SpriteFrames` on `AnimatedSprite2D`.
- Audio must be original, CC0, or clearly license-compatible; exact provenance belongs in `assets/audio/ATTRIBUTION.md`.
- Never rip art/audio from another game or bulk-import an unreviewed pack.
- Superseded runtime code/assets are reference-checked, then removed or preserved under Godot-ignored `art_source/archive/` only when they retain real source value.

## Segmented Implementation Order

### Segment 0 - Design lock

- This document, ADR, sources of truth, folder contracts
- No runtime feature claims

### Segment 1 - Save/Continue — implemented

- **Completed 2026-07-29:** one safe-point profile, atomic temporary writes, rotating backup/recovery, title Continue/New Journey protection, and isolated persistence tests
- Versioned profile schema
- Continue/New Journey
- Safe-point autosave, temporary write, backup/recovery
- Snapshot/migration/corruption tests

### Segment 2 - Material and crafting data — implemented

- **Completed 2026-07-29:** stable material, material-stack, drop-entry, drop-profile, loot-table, and recipe Resources plus validated global catalogs
- Authored ten current-enemy materials, five enemy profiles, the retained Stage III milestone table, and four deterministic starter recipe blueprints; superseded Stage I-II tables were removed when those stages adopted direct banking
- Added versioned `MaterialInventory` and `RecipeDiscovery` snapshots through the reserved profile extensions, including legacy-empty compatibility
- At Segment 2 completion, added no reward resolution, chest/Rootweaver art, or crafting output; Segment 3 subsequently consumes these definitions.
- **Character & Bag preparation completed 2026-07-29:** real nonzero material stacks are inspectable through a capacity-free material pouch in the shared 24-slot inventory presentation; Segment 3 now supplies final current icons and the normal acquisition path.

### Segment 3 - Loot and milestone rewards — implemented

- **Completed 2026-07-29:** enemy drop-profile integration through centralized `LootService`, collectible world pickups, and compact HUD confirmation
- Sparse ordinary common/secondary percentage rolls with sixth/twelfth-attempt protection caps; guaranteed boss rewards include both Husk Heartwood and Rootbound Core
- Hop/hover presentation plus delayed magnetic auto-collection, retaining contact as a fallback
- Direct clear banking and portal creation for Stages I-II; explicit `F` interaction, collision, Y-sorting, spawn reveal, and Rootbound Reliquary presentation for the Stage III milestone
- Versioned idempotent first-clear claims plus expedition rollback before defeat/abandon and commit before stage-clear autosave in both completion modes
- Ten distinct flattened 24x24 Forest icons with preserved source/clean/review boards
- Focused protection, duplicate-grant, persistence, rollback, chest, stage-wiring, and icon tests

### Segment 4 - Rootweaver production — implemented

- Approved identity, portrait, sprite sheets, `SpriteFrames`, workshop, interaction, sound

### Segment 5 - Crafting and material exchange — implemented

- Atomic material-plus-gold crafting service and deterministic transaction UI
- Six Stage V Forest recipes and equipment/stat integration
- Umi's catalog-driven selling, reconstruction, enemy memory, and boss safeguards

### Segment 6 - Replay Hunts

- Cleared-stage selection, authored modifiers, replay rewards

### Segment 7 - Forest Stages VI-X

- Approve each monster content contract before art/runtime work
- Preserve the Stage V core-gear, Stage VIII standard-accessory, and Stage X relic/signature cadence
- Use varied, meaningful identities within the Forest rather than naming every new creature or item after roots/trees
- Finish the Stage X boss and signature regional craft

### Segment 8 - Stage XI and next region

- Approve the next region's distinct identity
- Reuse technical material grammar with genuinely new ecology, variants, and recipes
- Expand cap/Mastery only through a separate balance decision

Each segment requires focused tests, full regression validation, relevant documentation updates, asset review, attribution, and removal/archive of superseded active-runtime material.

## Intentionally Open Choices

These are not blockers for Save/Continue, but must be approved before their owning segment:

- Campaign-scale tuning of the implemented recipe fees and material sell/reconstruction defaults
- Final Stage VIII/X milestone identities, seals/catalysts, quantities, and first-clear presentation
- Stage VII-X monster names, visuals, behavior timing, and encounter composition; Stage VI balance remains owner-tunable
- Stage X boss identity
- Stage XI+ biome/region theme and naming language
- Exact regional level-cap expansion
- Mastery categories and percentages
- Hunt modifier list and reward multipliers

Future work must not silently resolve these choices while implementing a lower segment.
