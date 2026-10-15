# Iron Beard full-body scale and overhead/spin motion

2026-10-15, Decision213. Built-in ImageGen generated complete source actors. Exact generation/correction prompts are adjacent.212's accepted axe/grips/carry and running/idle stay protected. Its2.1-head-width prompt compressed chest/legs despite matching hair width; new complete actors calibrate head, torso, legs and boots together. No anatomy pieces are pasted.

| Asset | Final source | Exact prompt set |
|---|---|---|
| Side | side-source.png | side-prompt.txt |
| Rear | up-source.png | up-prompt.txt creates up-base.png; up-correction-prompt.txt redraws complete final actors |
| Front | down-source.png | down-prompt.txt creates down-base.png; down-correction-prompt.txt redraws complete final actors |
| Turn | turn-source.png | turn-prompt.txt |
| Unchanged steel/idle | ../iron_beard_canonical_2026_10_15/ | Original axe-prompt.txt and idle-prompt.txt |

Generation inputs:212 side/up/down-reference.png; side additionally uses its accepted full-size turn as proportion guidance. They guide identity, never supply transplanted anatomy pixels. Failed larger vertical drafts remain only in ignored tmp/review/axe_motion_2026_10_15/.

registration-recipe.json owns complete actor components, source hashes, real shaft/head/palm/support traces and fixed sheet densities0.32/0.24/0.25/0.18. Standing guards54–57px,256px cells/sole158/half scale. Rod caps are visual guides, not trusted semantic labels: manually trace ambiguous ends from actual pose. Face/hair along a shaft is not a palm; rear occlusion is explicit. Head rectangles are audit landmarks, never pasted pixels or independent resize instructions.

69 complete source actors are published:30 side,15 rear,16 front,8 turn. Side20 is absent; side27 has inconsistent airborne orientation; rear9 has a bad hold. Explicit action maps exclude them. Fewer vertical keys have deliberate exposure within existing13-key clocks; turn retains16 runtime keys. Every state uses the exact212 canonical axe at unit scale. Chop/jump retain one blade face with no camera-dependent reversal; turn advances eight45-degree directions with the edge leading.

Bake tools/build_king_axe_unified.gd, then editor import. No image/palm solving runs during gameplay. registration.json records published cel hashes/unit weapon bases/native head/body bounds. retained-assets.json protects25 current carry/weapon/combat/FX/audio files; production also checks370 other-family assets. Gameplay,3.19s chain, damage/reach/movement, sounds, effects and saves stay unchanged.

verification.json records final tests/native preview paths. Captures remain ignored/outside the playable graph. Owner allows visible Godot and approves this axe art/motion on2026-10-15. approval.json records the accepted runtime-asset hashes; preserve them during other family work. Campaign balance/acquisition remain separate.
