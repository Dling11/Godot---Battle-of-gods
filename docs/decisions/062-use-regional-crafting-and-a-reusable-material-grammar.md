# Decision 062: Use Regional Crafting and a Reusable Material Grammar

- **Status:** Accepted; Segments 1-4 implemented, Segments 5-8 pending
- **Date:** 2026-07-26

## Context

The implemented campaign advances through authored stages, but cleared stages currently lose most of their purpose. The approved direction introduces replayable material goals, guaranteed stage-clear chests, deterministic crafting, a Sanctuary artisan, Forest equipment, and later regional progression. Planning only the first three stages would force the save schema, item art, monster drops, and recipe data to be rewritten when Stages 4-20 arrive.

Asset scope also needs control. Future venom, acid, hide, fiber, chitin, ore, core, and relic materials should share a readable visual language without becoming indistinguishable relabels or `Leather++` clutter.

## Alternatives Considered

1. Keep stages single-use and let new stages replace old rewards.
2. Add random equipment drops and independently draw every material when its stage is built.
3. Plan Forest Stages 1-10 as one loot/crafting ecosystem and establish reusable cross-region material, monster, folder, save, and replay contracts before implementation.

## Decision

Choose option 3.

The long-term loop is `Fight -> Loot -> Craft -> Build -> Master -> Advance`. First clears guarantee authored progression rewards; replay/Hunt clears guarantee useful material progress; bosses guarantee unique catalysts; deterministic recipes produce known equipment. Target ordinary recipe pacing is roughly two to three useful clears rather than long identical-run grinds.

Each monster's visible ecology, combat behavior, drops, and recipes are designed together. Current monster drop identities and provisional Stage 4-10 enemy/material roles are recorded in `docs/design/forest-loot-crafting-and-regional-material-plan.md`. Names, exact stats, and unbuilt art remain open.

Material art uses exact reuse for universal items, template reuse for shared physical families, and original silhouettes for unique/boss/story items. Labels and rarity frames remain UI data. Material icons use 24x24 runtime art; equipment portraits remain 64x64. Later regions primarily use new-region materials while retaining limited universal/older inputs. Palette-only enemy variants and `Leather+` naming are rejected.

Save/Continue precedes loot implementation. Implemented mutable authorities are `MaterialInventory`, `RecipeDiscovery`, `LootState`, existing progression/story/equipment services, and a versioned `SaveService`; centralized `LootService` resolves immutable enemy/stage tables while UI, pickups, and chest presentation only submit intent and observe results. A separate Sanctuary Rootweaver/Grove Artificer will handle crafting while Orren retains ordinary weapon merchant/equip responsibility.

Character levels expand by controlled regional decisions rather than infinite raw-stat scaling. Optional post-cap Mastery must use bounded utility/crafting/cosmetic rewards. Later stages may expect partial crafted gear but cannot become opaque mandatory stat walls.

## Consequences

- Stages remain useful through explicit replay goals instead of identical compulsory repetition.
- Future monsters and materials must satisfy a complete content contract before generation.
- Region 2 can reuse icon/animation/system grammar without cheap recolors or duplicate infrastructure.
- Save schema and folder structure can anticipate materials, recipes, blueprints, and boss catalysts.
- Stages I-III now provide illustrated enemy drops, protected optional rolls, guaranteed first-clear/replay chests, saved idempotent claims, and rollback of uncommitted expedition rewards.
- Crafting transactions/output equipment, Hunts, Mastery, and Stages 4-20 remain planned until their segments pass implementation and validation; the read-only Rootweaver presentation service is implemented.
