# Active Asset Catalog

Updated 2026-10-14. This catalog names current owners. The production graph and Godot resource checks determine actual dependencies; folder/version names do not establish whether an asset is obsolete. Historical models/source sheets/recordings and all archives were deleted by owner request.

| Content | Current owner |
|---|---|
| King signature Sword | entities/player/player.tscn; shared_bodies/sword/frames.tres with retained action rasters |
| Iron Beard | Current21 iron_beard_unified clips;212's canonical steel/icon/carry/idle remain exact.213's69 complete attack actors restore running-compatible proportions, normal overhead landing and continuous eight-heading turn. Current attack source/prompts/recipe: iron_beard_motion_2026_10_15; canonical source folder supplies unchanged weapon/idle.40 white frames/audio unchanged |
| Royal Greatsword | data/weapons/families/royal_greatsword_v2/presentation.tres; accepted referenced carry/combo/FX dependencies |
| Twinsteel | data/weapons/families/twinsteel_v2/presentation.tres; shared_bodies/dual_carry_v3 and canonical blade/FX |
| Iron Reaper playable family | assets/characters/playable/king/iron_reaper:18 current complete body clips, fixed128×192 rigid steel, two empty overlays,24 main white ribbons,8 spin arcs,8 ground sparks and Bag icon. Current120-pose attack/idle sources, exact prompts, grip recipe and motion-authoring.json under iron_reaper_style_unified_2026_10_14; Decision207 translates complete approved poses without changing anatomy/palette and authors full shaft arcs/exposure. Approved running/canonical steel/flight-FX provenance remains under iron_reaper_returning_2026_10_14. Old action sources are historical only. Decision208 adds support-root landmarks and cached ribbon_layout.tres from ribbon-layout.json; Decision209 replaces the white atlas with24 generated frames from iron_reaper_cadence_2026_10_14 and refits all rows/views; complete actor geometry remains unchanged. Follow-up glove-continuity.json remaps96 missing-glove color pixels from a generated brown material reference under iron_reaper_gloves_2026_10_14. Dedicated seven-clip scythe audio lives under assets/audio/sfx/player/iron_reaper with CC0 source/manifest under art_source/audio/iron_reaper_2026_10_14. Source art excluded from game import/export; old runtime spin clips retired (Decision206) |
| Frozen King body reference | assets/characters/playable/king/body_library/v1/contract.json |
| King techniques | data/abilities/king and gameplay/abilities/king; assets/vfx/abilities/king |
| Enemy families | entities/enemies and their referenced assets/characters/enemies, VFX/audio/materials |
| Sanctuary NPCs/layout | levels/sanctuary/town; renewed NPC resources and referenced environment props |
| StagesI–VI | levels and data/environment/layouts; current referenced forest/dead-forest/StageVI atlases |
| Gates/chests | gameplay/encounters, gameplay/loot and current referenced portal/chest assets |
| Title/loading/HUD/Bag | ui and assets/ui; randomized campfire trio, quiet transition, compact portrait/centered paper doll |
| Sound and attribution | assets/audio plus preserved license files; original CC0 contact pack under art_source/audio |
| Current regeneration | Complete Twinsteel running/attack source sheets and prompts, hash recipes/registration; current walk/attack/slash builders; immutable body_library/v1 supplies visual guidance only. Attack pass uses20 selected source sheets,15 clips and one white-slash atlas; unused vertical Twinsteel slash duplicates are retired |

Runtime raster density/palette/origins/import settings remain. Frozen complete body references are immutable; reviewed motion variants use separate resources. No new frame is authored or visually approved by cleanup. The pre-cleanup production hash manifest is docs/maintenance/active-assets-2026-10-13.json.

Keep copyrighted/CC0 attribution/license text with retained content. Current test captures belong in ignored tmp/review/ and should not be committed. A compact playable source ZIP excludes generation sources, tests, docs/history/caches but retains the runtime editor-backdrop scene dependency.
