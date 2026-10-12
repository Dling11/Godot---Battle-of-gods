# Sanctuary courtyards and ambient life

2026-10-02. Normal-town baseline under Decision165; this pass is temporarily complete. See [closeout](sanctuary-closeout.md). Previous courier/house comparison history is preserved in the recovery archive.

Nema/Umi use eight-pose work atlases and matching portraits on their original DialogueNpc bodies. Shared service_work_animation.gd holds attention for greetings/dialogue, resumes work on close and plays Nema's existing forge strike at frame5. Crafting/exchange authority remains unchanged.

Corrected overhead houses use assets/environment/sanctuary/orthographic/{nema,umi}.png. Doorstep paths/footprints remain clear; angled candidates are archived. Eira's off-road lectern is344,410, Eira directly right at384,410, and approach384,446.

Rowan's sixteen directional walk poses plus standing poses follow traveled distance. The authored route pauses at delivery stops, yields near King, resolves blockage and leaves service F priority intact. His conversation grants no items/rewards. Tree crowns use bounded foliage_wind.gdshader motion without moving collision; canopy reveal keeps King visible. Two swallows use timer/tween flights.

Ownership: town_dressing.gd, garden_birds.gd and foliage_wind.gdshader under levels/sanctuary/town/; entities/npcs/courier/ for Rowan. Sources/prompts remain under art_source/generated/characters/npcs/ and art_source/generated/environment/sanctuary/. build_sanctuary_courtyards.gd builds current actors/courier/birds; corrected houses use build_sanctuary_interface_art.gd. Builders no longer recreate older walk/house outputs.

Validation/native evidence: CHANGELOG.md. Representative-phone profiling remains deferred.
