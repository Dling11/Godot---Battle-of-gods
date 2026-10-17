# 224 - Sword compact side-running guard

Status: implemented2026-10-16; owner provisionally accepts final running/grip and settles current weapon artwork.

The owner rejects the starter Sword's left/right run because the weapon follows an empty-hand arm pump and looks unappealing. Up/down running is accepted and must remain exact.

Generate eight fresh COMPLETE side-running poses with a compact bent elbow, held forward/up guard, separate foot contact/passing and scarf/body response. Use the current complete actors as style references without pasting heads or anatomy. One frozen.19 density applies to the entire board; crown registration stays99–100, body height54–59 native pixels and all poses keep the same256px cells/half-scale origin.

The initial generated blade was too short. Built-in image editing removes the generated steel using a temporary guide pass, preserving connected complete anatomy. Compose the existing20×80 sword at unit scale behind the real closed brown fist. Stable15-degree guard and integer registered palms reduce X hand travel from18 native pixels to2; Y travel is2. Canonical weapon size/colors are unchanged. Empty hand atlases and hidden duplicate rigs remain.

Replace only sword_unified/side/run_body.png and side/run.tres. LEFT mirrors SIDE. Up/down, idle, attacks, FX, sounds, movement, stride cadence, collision, damage, saves and other families are byte-preserved. No presentation/controller code changes. Current production hashes track the installed candidate; they do not imply owner approval.

Alternative rigidly repositioning the old sword leaves the rejected pumping pose intact. New complete poses preserve coherent hand/torso/foot motion. A shoulder/back carry would change the default weapon's readiness silhouette further than needed.

Owner follow-up: the running passes, but the sketch circles the hidden handle. Rendering the entire sword behind the complete pose hid the guard/handle in the torso and forearm. Keep all eight original bodies, palms, directions and unit-size steel. Change only the run grasp from(10,66) to(10,70), exposing the guard farther forward, and compose canonical hilt rows55–79 in the foreground except the same pose's closed brown glove within3px of the real palm. The glove is an occlusion mask from its own complete pose, never a transplanted hand. Guard and pommel remain visible in all eight frames; LEFT uses the existing exact mirror. No new generation or runtime code is needed for this depth correction.

Small prompts/calibration/grips/current hashes are retained in art_source/reference/characters/king/sword-side-run.json. Built-in imagegen was used; raw sheets, temporary references and captures are staged under ignored tmp/sword_side_guard_2026_10_16. Automatic approval review rejected their PNG deletion with "blocked by policy"; the files remain ignored and are not runtime dependencies. Do not restore a permanent source collection or add another selectable weapon version.

Natural-grip follow-up: the owner finds(10,70) too close to the pommel and asks for a lower sword. Restore middle-leather grasp(10,66), retracting the canonical steel four source pixels relative to the same actual glove; lower the angle from15 to10 degrees and update only the secondary direction hints. Foreground hilt/same-pose glove depth remains. All eight body poses and real palm positions stay exact. A rear-handle visibility regression requires exposed leather behind the glove in addition to the complete guard and pommel. No extra art generation is needed.

Hilt follow-up validation passed: king_sword_side_run_smoke (64 checks), king_sword_unified_smoke (571), native king_sword_gameplay_smoke (1,233) and resource loading (919). Measure fixed canonical steel points rather than the grasp-to-tip span to detect accidental scaling independently of the changed grasp. The production audit preserves 651 of 653 files; only the intended side atlas and resource change. Original profile/backup/cosmetic hashes remain exact. Native previews use actual equipped Players. The owner provisionally accepts the final running/grip and moves on to next-work planning.
