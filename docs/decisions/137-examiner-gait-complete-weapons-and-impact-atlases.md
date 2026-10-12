# Decision 137: Examiner Gait, Complete Weapons, and Impact Atlases

## Status

Implemented in the F7 proof on 2026-09-12. The owner accepted Decision 136's overall look, attacks, and Court, then requested alternating footsteps, complete weapon tips, stronger skill effects, red RPG telegraphs, and a heavier Divine Descent. This follow-up remains subject to owner feel review. Stage VII is still unimplemented.

## Evidence and choice

The six-frame walk repeated nearly the same leg silhouette. The source extractor limited its search to a 46-pixel margin, which could sever a long blade before padding made the runtime cell appear valid. The old slam board also contained overlapping figures and source-edge clipping. Enlarging the final canvas alone would not fix either source problem.

- Extract entire connected actors before cropping. Reject merged actors and source-edge contact; verify retained-pixel counts. Keep the common action scale and padded 192x160 cells. A repaired slam source replaces the overlapping board; the dedicated overhead-raise supplement remains.
- Use three reviewed four-pose gait studies (front, profile, back), with an exact mirrored profile for left. Contact frames 0/2 alternate the planted leg; frames 1/3 pass the other knee. One standing-reference scale per direction preserves mass; foot baseline stays 128 and body origin stays -48. Walking direction changes preserve frame/progress, and footsteps now observe 0/2.
- Four eight-frame raster atlases replace procedural yellow attack lines: energy lance, dedicated thick Axiom beam, crescent slash, and slate eruption/crater. The shared atlas helper only samples presentation. Contact events and existing lane timers still own activation; no damage, cooldown, or phase authority moved into art. Reviewed impact cores are translated to (128,192) without per-frame scaling so the crater remains fixed.
- Generated crimson circular and arrow-lane decals communicate danger. The circle has a fixed 72-pixel slam extent, placed at the actual hitbox center; its interior fills over the wind-up. Axiom warnings retain data-owned segment width/length plus endpoint caps. Its bright beam core remains inside that lane; the wider dim fringe is cosmetic. Divine Descent's floor shader derives the exact four 54-pixel safe holes from Court data.
- Ground Judgment and Divine Descent use separate weighted slab breaks, rumble, and falling rubble; Axiom gets a charged beam cut. Audio remains original deterministic synthesis, with no downloaded samples or additional music layer.

## Validation and limitations

All 336 body cells retain transparent padding and binary alpha. The extractor regression checks a blade crossing far beyond the former crop margin and rejects a genuinely clipped source. Focused Godot checks cover body/contact timing, gait continuity on turning, existing combat/wards/phase behavior, all eight effect frames, timed Axiom resolution, transient cleanup, lab boundaries, and runtime/archive references. GPU captures exercise walking in four directions and scripted real-controller actions with sound; they are presentation reviews rather than autonomous player playthroughs.

Sources and exact built-in ImageGen prompts live under `art_source/generated/characters/disciples/examiner/polish_2026_09_12/`. Runtime effects are identity-owned under `assets/vfx/divine_order/examiner/`. The old accepted sources remain available in the earlier rework folder. This change does not complete Stage VII outcomes, rewards, saves, or replay.

## Identity correction after owner review

The owner accepted the skill effects but rejected the replacement walk identity. The identity follow-up now derives front/profile/back studies from isolated approved locomotion references, restores the narrow mask and long ivory coat, and matches helmet-to-ground body scale per direction. Skills, audio, HUD, and combat authority are unchanged; the revised gait awaits owner review.

`identity_2026_09_12/` contains selected built-in ImageGen sources, isolated approved references, exact prompts, and measured import anchors. `tools/process_examiner_identity.py` owns gait packing; the polish importer delegates to it so rebuilding cannot restore the rejected ornate walk. Runtime remains four frames per direction at 7 fps, with contacts 0/2 and a mirrored left profile. A dedicated GPU capture reviews idle, walk, and combo transitions in all four directions.
