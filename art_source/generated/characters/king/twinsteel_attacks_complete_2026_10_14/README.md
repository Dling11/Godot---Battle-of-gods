# Twinsteel complete attacks — 2026-10-14

Generated with the built-in imagegen tool, not the CLI/API fallback. The selected20 PNG sheets and their exact matching *-prompt.txt files are saved in this directory. Fifteen whole-character4×2 sheets contain120 complete new action poses; five separate horizontal4-frame strips supply20 new slash frames. LEFT mirrors RIGHT; side/up/down boards are authored separately. References supply visual identity/proportion guidance only, with no cropped head/body transplantation.

Actions: diagonal, return, rising_cross, hop_spin, cross_finish. Short cyan/magenta source rods register closed fists, then are removed offline. They are guides, not final weapons or game colors. The canonical Twinsteel16×62 raster supplies fixed unit-size steel at both moving palms. Generated anatomy covers the blades/grips; neither King nor his swords are scaled per runtime frame. The back hop-spin includes actual profile/front/back turning poses and settles back to its original facing.

tools/king_twinsteel_attack_baker.gd records each source SHA256, collar, head span, sole, palms and blade direction in bake_recipe.json. One isotropic density per action board is calibrated from standing anatomy. Nearest sampling,5-bit colors and alpha180 produce crisp complete192×192 cels. Sole126 at half scale and offset(0,-16) is the same world ground origin as running192×128/sole94. registration.json records195 runtime keys; protected_assets.json locks approved running and idle inputs. Guide crossings over anatomy are source errors and must be regenerated.

Rebuild after an ordinary source checkout and Godot import:

~~~powershell
& 'D:/WORK_APP/godot/Godot_v4.7-stable_win64_console.exe' --headless --path . --script tools/build_king_twinsteel_attacks.gd
& 'D:/WORK_APP/godot/Godot_v4.7-stable_win64_console.exe' --headless --path . --editor --import --quit
~~~

Use -- --register only for deliberate source-registration changes. Gameplay tuning stays in the current twinsteel_v2 combo/weapon definitions. Runtime uses only the published attack PNG/resources plus a single slash atlas; source PNGs, prompts, recipes and tests are not runtime dependencies. Captures/rejected drafts stay in ignored tmp/review/.

Verify king_twinsteel_attacks_smoke, king_twinsteel_walk_smoke, king_dual_gait_smoke, king_shared_body_smoke and king_twinsteel_gameplay_smoke; native Godot additionally runs king_dual_v2_idle_smoke and tools/review_king_twinsteel_attacks.gd. Normal test route: F5 → F9 → F7 → Weapons → Twinsteel; WASD, held LMB, Space, Tab, Escape. The owner accepts the installed attacks on2026-10-14; preserve this pass alongside approved running/rest.

Final verification2026-10-14:1346 fresh action checks,511 running,1194 real-input gait/wall/handoff,735 shared-body,214 headless/244 native gameplay,100 native idle/retrieval and198 capture assertions pass;873 resources load. All267 unrelated recorded King assets, including approved running/rest and other weapons, remain exact;46 authorized attack/FX assets change and2 unused effects retire. Native preview: tmp/review/twinsteel_attacks_2026_10_14/twinsteel-four-direction-combo.gif (186 frames, cumulative60fps GIF timing). The owner accepts game-scale motion and identity on2026-10-14. Selected source set is about28MiB and stays excluded from lightweight playable packaging.
