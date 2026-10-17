# Active Asset Catalog

Current Weapon Court 234: assets/characters/npcs/veyr/idle.png (384x192, eight complete 96px hooded cels, 33,743 bytes); assets/environment/sanctuary/weapon_court/training_pavilion.png (232x152, 224x122 occupied, 46,488 bytes); training_post.png (256x64, four whole recoil cels, 10,761 bytes). These replace the same three paths; binary alpha/nearest filtering remain. Gate/energy are unchanged. Five current court/gate/NPC PNGs total 152,139 bytes. The other 689 guarded assets remain exact; guard count stays 692. Veyr's 0.5 runtime scale/y=-15 and post 0.65/y=-14.3 preserve grounding. Prompts/source/hashes/registration: art_source/reference/environment/weapon-court.json. Earlier 232/233 totals are historical.

Cyclone231 final VFX under assets/vfx/abilities/weapons/axe_war_cyclone/: motion.png1024x1024(155,517 bytes), outer.png320x320(45,051), ground.png1024x512(33,433), icon.png96x96(20,112). Total254,113 bytes; old spin/recovery/slash sheets retired. Three unchanged recorded PCM WAVs remain under assets/audio/sfx/abilities/weapons/war_cyclone/. Sole compact prompts/source/registration/audio audit: art_source/reference/abilities/axe-war-cyclone.json. No permanent generation archive; ordinary weapon art/audio remain protected.


Bag227 uses assets/ui/inventory/portrait_backdrop.tres: a native336×412 GradientTexture2D displayed168×206, with a thin slate border. The rejected472,484-byte chamber PNG/import is removed; no background raster is added. Existing complete King/steel textures remain unchanged. Selected settings/layout: art_source/reference/ui/bag-inspection.json; current UI rules: docs/design/bag-inspection-refresh.md.

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
| Title/loading/HUD/Bag | ui and assets/ui; campfire trio, quiet transition, reference-matched portrait/mastery/skill UI (veil_sigils,28 PNGs plus bundled Lora font) and centered paper doll |
| Compact support | art_source/production-assets.json; small King reference images and axe-motion.json/reaper-grounding.json |
| Licensed audio | assets/audio plus attribution and retained licensed originals under art_source/audio |

Weapon artwork paths are under assets/characters/playable/king/. Every installed runtime raster/audio file remains unchanged by source removal. Frame/resource SHA checks and native gameplay preserve current presentation. Current source/size/test evidence: docs/maintenance/repository-cleanup.md. Current review routes: CONTINUE_WEAPONS.md.

Retain pixel density, palette, origins, complete anatomy and import settings. Do not transplant reference anatomy or silently update accepted hashes to hide drift. Publish approved assets from temporary staging and clear trials; do not retain permanent generated/archive collections. Runtime dependencies include tools/editor backdrops. Captures, exports, caches and raw generation trials stay outside Git/distribution.

Decision224 changes only Sword horizontal run atlas/grips; prompt/calibration audit is sword-side-run.json under compact King references. Current raw authoring sheets stay temporary; owner review is pending.
