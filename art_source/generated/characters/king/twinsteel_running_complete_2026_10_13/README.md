# Fresh complete Twinsteel running — 2026-10-13

Built-in imagegen created NEW complete character cels at the owner's explicit request (Decision 200). No cropped native heads, necks, torso strips or old gait pixels are reused. Current sources: right-source.png, up-source.png (the selected refined rear sheet), down-source.png. Each is a 1536x1024 transparent 4x2 board of eight complete poses. LEFT mirrors the fresh RIGHT. Every pose includes connected head/neck/scarf/torso/arms/hands/hips/boots and TWO drawn blades.

Generation prompts are preserved individually: right-prompt.txt, up-prompt.txt, down-prompt.txt and up-refine-prompt.txt. Native trace_board.png and the fresh side sheet were visual guides only. The first up draft remains in Codex's generated image output, outside the repository; only the selected rear source is retained here. Tool mode: built-in imagegen, transparent background. No Python/API fallback or head/body art transplant.

bake_recipe.json v3 retains v2 complete source bounds and standing-head body normalization unchanged, then adds accepted-cel hashes, generated removal-mask hashes and a fixed-size canonical vertical weapon contract. All8 keys share one density per direction,192x128 cells,half scale and sole94. The blade extent is separate from head/body dimensions. UP/DOWN anatomy is never enlarged to fix weapon length; SIDE remains byte-identical.

Run anatomy and hands remain the original complete generated cels. For UP/DOWN only, compact up/down-weapon-removal-mask.png inputs derive from the built-in imagegen object-removal plate (original exec-822ddca3-ccde-4dfe-b193-c16b1a2853c0.png remains in Codex generated_images; its SHA256 is recorded in the recipe). The mask extraction protects warm body/scarf/glove pixels and retains no replacement generated anatomy. weapon-removal-prompt.txt records the edit request. Bake the existing Twinsteel steel behind untouched connected fists at unit size. Whole output cels retain both blades, empty hand atlases and hidden extra rigs. Ready/proud idle, attacks, other families and gameplay stay unchanged. .gdignore excludes art-source masks/boards from runtime import.

Rebuild from the project root:

    Godot --headless --path . --script res://tools/build_king_twinsteel_carry.gd
    Godot --headless --path . --editor --import --quit

Godot means your locally installed console executable. Source ownership must be reviewed and recipe hashes updated for a newly generated source; do not blindly crop ideal cells or resize a single wrong frame.

Current verification:511 complete-cel/anatomy/standing-size/fixed-blade assertions,1194 real-input/wall/attack-entry checks,735 shared-body checks,214 equipment/combat checks,70 native capture assertions and868 resource loads pass. The preceding native-idle100 result remains the protected idle baseline. The current native preview is tmp/review/combat/king_dual_carry_motion_2026_10_12/fixed_vertical_blades_2026_10_14/twinsteel-fixed-running-blades.gif. Running bodies are accepted; owner review of the corrected vertical weapon carry remains pending.

- king_twinsteel_walk_smoke:511 assertions; deterministic source normalization, preserved accepted anatomy, same-length vertical steel, visible blade tips, head/body density, binary alpha, sole/gutters and protected endpoints.
- king_dual_gait_smoke: 1194 assertions, actual four-direction input/all eight keys, zero-travel collision behavior, inherited run-to-attack body/visibility and idle release.
- king_shared_body_smoke: 735 assertions, frozen library and exact Sword/axe/Greatsword gait protection plus generated Twinsteel connectivity.
- king_twinsteel_gameplay_smoke: 214 assertions, normal equipment and combat behavior.
- Native king_dual_v2_idle_smoke: 100 assertions, first-glance timing and retrieval/controls. This test requires native rendering, not headless.
- Native four-direction actual Player capture: 70 assertions, 62 frames, current ready/run/ready and unchanged Greatsword comparison.
- All 868 project resources load; all 10 frozen complete body atlas hashes match.
- Only nine walking assets differ from the 646-asset cleanup baseline; 637 other protected assets remain exact. Rebuilding all nine outputs plus registration JSON is byte-for-byte deterministic.

Preview (ignored):tmp/review/combat/king_dual_carry_motion_2026_10_12/fixed_vertical_blades_2026_10_14/twinsteel-fixed-running-blades.gif. Slowed15fps inspection capture of the actual Player, not a change to travel-driven gait speed. Test F5 → F9 → F7 → Weapons → Twinsteel or tools/launch_king_twinsteel_training.ps1 with WASD/held LMB/Space/Tab/Escape. This is a non-saving session. Corrected weapon carry still needs owner review.

Whole-frame review (ignored): tmp/review/twinsteel_fresh/current-four-direction-frames.png shows all 32 current runtime poses, ordered UP, DOWN, LEFT, RIGHT with F01–F08 labels. It renders the actual production textures at 2x, including both drawn swords, without extracting head/neck/body fragments. Use the full poses when sketching corrections. LEFT is the exact mirror of the newly generated RIGHT; the board is a review of the installed redraw, not another generated version.

2026-10-14 weapon-size correction: the owner clarifies that running bodies/gaits are acceptable; the swords shrink in front/back running. Preserve recipe v2 body densities, complete connected anatomy, every non-weapon texel, all side running art and accepted attacks/rest. Recipe v3 removes only the short vertical steel using compact masks derived from a built-in imagegen object-removal plate, then bakes the existing 16x62 Twinsteel raster at unit scale into each vertical cel. Grip-to-tip length remains50 native texels, matching standing. Moving palms/angles change placement only. Original body pixels cover the grips; no generated replacement head, neck, arm or body pixels are used. Both blades remain in the complete output cel, so runtime overlays remain hidden and the hand atlas remains empty. The correction adds no per-frame work and changes no movement, damage, reach, sounds or saves.

Current verification:511 complete-cel/anatomy/standing-size/fixed-blade assertions,1194 real-input/wall/attack-entry checks,735 shared-body checks,214 equipment/combat checks,70 native capture assertions and868 resource loads pass. The preceding native-idle100 result remains the protected idle baseline. The current native preview is tmp/review/combat/king_dual_carry_motion_2026_10_12/fixed_vertical_blades_2026_10_14/twinsteel-fixed-running-blades.gif. Running bodies are accepted; owner review of the corrected vertical weapon carry remains pending.

2026-10-14 owner acceptance: current running and corrected vertical blade size are approved. A fresh Twinsteel attack-art pass is proposed; the existing five-cut attacks remain current and unchanged.
