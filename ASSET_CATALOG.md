# Active Asset Catalog

Updated 2026-10-13. This catalog names current owners. The production graph and Godot resource checks determine actual dependencies; folder/version names do not establish whether an asset is obsolete. Historical models/source sheets/recordings and all archives were deleted by owner request.

| Content | Current owner |
|---|---|
| King signature Sword | entities/player/player.tscn; shared_bodies/sword/frames.tres with retained action rasters |
| Iron Beard | data/weapons/families/iron_beard/presentation.tres; shared_bodies/axe |
| Royal Greatsword | data/weapons/families/royal_greatsword_v2/presentation.tres; accepted referenced carry/combo/FX dependencies |
| Twinsteel | data/weapons/families/twinsteel_v2/presentation.tres; shared_bodies/dual_carry_v3 and canonical blade/FX |
| Frozen King body reference | assets/characters/playable/king/body_library/v1/contract.json |
| King techniques | data/abilities/king and gameplay/abilities/king; assets/vfx/abilities/king |
| Enemy families | entities/enemies and their referenced assets/characters/enemies, VFX/audio/materials |
| Sanctuary NPCs/layout | levels/sanctuary/town; renewed NPC resources and referenced environment props |
| StagesI–VI | levels and data/environment/layouts; current referenced forest/dead-forest/StageVI atlases |
| Gates/chests | gameplay/encounters, gameplay/loot and current referenced portal/chest assets |
| Title/loading/HUD/Bag | ui and assets/ui; randomized campfire trio, quiet transition, compact portrait/centered paper doll |
| Sound and attribution | assets/audio plus preserved license files; original CC0 contact pack under art_source/audio |
| Current regeneration | art_source/generated/characters/king/dual_carry_gait_2026_10_12, small King references, current Twinsteel builder |

Runtime raster density/palette/origins/import settings remain. Frozen complete body references are immutable; reviewed motion variants use separate resources. No new frame is authored or visually approved by cleanup. The pre-cleanup production hash manifest is docs/maintenance/active-assets-2026-10-13.json.

Keep copyrighted/CC0 attribution/license text with retained content. Current test captures belong in ignored tmp/review/ and should not be committed. A compact playable source ZIP excludes generation sources, tests, docs/history/caches but retains the runtime editor-backdrop scene dependency.
