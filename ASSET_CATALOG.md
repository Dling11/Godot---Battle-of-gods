# Active Asset Catalog

Updated2026-10-16. Decision223 retains final playable art plus compact important support. art_source/generated and image builders are deleted; raw trials use temporary ignored staging in future work.

| Content | Current owner |
| --- | --- |
| King Sword | sword_unified;15 clips,20×80 steel,36 white frames; Decision221 attacks/224 side run |
| Iron Beard | iron_beard_unified;21 clips, canonical thin steel/back carry,40 white frames; Decision213 |
| Royal Greatsword | greatsword_unified;18 clips,30×140 steel, selected shoulder rest, full spin/landing effects; Decision217 |
| Twinsteel | twinsteel_unified;21 clips,16×68 pair/Bag icon,60 white frames; Decision219 |
| Iron Reaper | iron_reaper;18 clips,128×192 steel, throw/orbit/spark/catch effects, dedicated audio; Decisions206–209 |
| Frozen King references | assets/characters/playable/king/body_library/baseline; ten immutable complete body atlases |
| King techniques | data/abilities/king and gameplay/abilities/king with referenced VFX/audio; legacy Sword/Spellward art remains live |
| NPCs/Sanctuary | levels/sanctuary/town, renewed NPC resources and referenced environment art |
| Enemies/stagesI–VI | entities/enemies, environment, levels and data/environment/layouts |
| Gates/chests | gameplay/encounters and gameplay/loot with current referenced assets |
| Title/loading/HUD/Bag | ui and assets/ui; campfire trio, quiet transition, compact portrait and centered paper doll |
| Compact support | art_source/production-assets.json; small King reference images and axe-motion.json/reaper-grounding.json |
| Licensed audio | assets/audio plus attribution and retained licensed originals under art_source/audio |

Weapon artwork paths are under assets/characters/playable/king/. Every installed runtime raster/audio file remains unchanged by source removal. Frame/resource SHA checks and native gameplay preserve current presentation. Current source/size/test evidence: docs/maintenance/repository-cleanup.md. Current review routes: CONTINUE_WEAPONS.md.

Retain pixel density, palette, origins, complete anatomy and import settings. Do not transplant reference anatomy or silently update accepted hashes to hide drift. Publish approved assets from temporary staging and clear trials; do not retain permanent generated/archive collections. Runtime dependencies include tools/editor backdrops. Captures, exports, caches and raw generation trials stay outside Git/distribution.

Decision224 changes only Sword horizontal run atlas/grips; prompt/calibration audit is sword-side-run.json under compact King references. Current raw authoring sheets stay temporary; owner review is pending.
