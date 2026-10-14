# Iron Reaper complete side preview — 2026-10-14

Generated using the built-in imagegen tool with the imagegen skill. Four separate4×2 transparent sheets contain32 complete King/scythe poses; slash-source.png supplies sixteen effect-only frames. Exact prompts are retained beside each selected sheet. selected-iron-reaper.png preserves the owner's chosen original concept. Frozen complete King references guide anatomy/palette only; no transplanted character fragments enter the outputs. LEFT is an exact mirror of RIGHT.

Each source contains eight complete connected actors despite uneven spacing across nominal grid lines. registration-recipe.json owns source hashes, exact component bounds/pixel counts, traced head rectangles, boot baselines and a fixed isotropic density per action. Offline extraction retains the whole connected actor including both hands/scythe. preview/ contains256×224 binary-alpha atlases at sole164, plus a neutral sixteen-frame slash atlas. This is source-only motion review; .gdignore excludes the folder from game imports/exports.

~~~powershell
& 'D:/WORK_APP/godot/Godot_v4.7-stable_win64_console.exe' --headless --path . --script tools/build_king_iron_reaper_preview.gd
.\tools\launch_king_iron_reaper_preview.ps1
& 'D:/WORK_APP/godot/Godot_v4.7-stable_win64_console.exe' --headless --path . --script tools/review_king_iron_reaper.gd -- --verify-controls
& 'D:/WORK_APP/godot/Godot_v4.7-stable_win64_console.exe' --path . --script tools/review_king_iron_reaper.gd -- --capture
~~~

Space pause, arrows step,1–4 cuts, Tab effects, S half speed, Escape close. The standalone viewer suppresses campaign saves and never equips a weapon or delivers damage. Capture artifacts stay in ignored tmp/review/iron_reaper_2026_10_14/. The GIF encodes209 native frames with cumulative60fps timing. Four proposed cuts total2.38 seconds plus1.1 seconds of preview rest; final source poses8 then7 finish with upright gather.

Verification:738 builder/preservation checks and46 control checks pass; native capture visits all32 poses in both mirrored views. protected-assets.json locks all532 existing King assets unchanged. These checks do not establish owner approval, gameplay/scythe rigidity, future cardinal frames, inventory integration or combat balance. See Decision202 and docs/design/king-iron-reaper-side-preview.md.

Verification:738 builder/preservation checks,46 controls,875 retained project resources loaded,10 immutable body atlases verified and five byte-identical rebuilt preview PNGs. Selected source set is8.92MiB; captures and source art are excluded from lightweight playable packaging.
