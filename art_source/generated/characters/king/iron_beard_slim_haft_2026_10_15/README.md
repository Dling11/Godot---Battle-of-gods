# Iron Beard — thin shaft, original length

2026-10-15. The owner clarified WIDTH, not length. The earlier compact32%-short variant misunderstood the request and is superseded.

Built-in image edit. Exact prompt: prompt.txt. Input reference: reference-original-16x.png (a nearest16x enlargement of the original55×64 axe). Selected output: source.png. The first draft stretched the shaft and was rejected to ignored tmp/review.

The generated narrow shaft/red wrapping are the only imported region. weapon-recipe.json records source SHA256/connected component bounds, source red-wrap grip/cap, uniform grip-to-cap calibration and a shaft edit polygon in the original native coordinate system. Pixels outside that polygon come from the original axe at offset(8,8), preserving its metal head exactly. This is an offline rigid-weapon edit, never a cropped actor/anatomy transplant or runtime segmented rig.

Original lower-handle length29.8329px is retained exactly; grip-to-edge remains(-31,-3). Cross-section at the grip narrows9.25→5.125px (about45%); wood at17px down the shaft narrows7.25→3.125px. Measurements sample opaque width perpendicular to the shaft. Source art is palette-matched to the retained original with binary alpha and safe gutters.80×80 is transparent padding, not weapon size. Grip(47,41), cutting edge(16,38), cap(54,70). Body palettes/poses/palms/density, motion, sound, combat range/damage and3.19s clock are unchanged.

Build: Godot --headless --path . --script res://tools/build_king_axe_unified.gd, then --headless --editor --import. Runtime texture assets/characters/playable/king/iron_beard_unified/iron_beard_slim.png;64px Bag icon assets/ui/inventory/weapons/iron_beard_slim.png. Same equipment/save ID. Original and compact trial assets remain preserved for provenance.

Tests: king_axe_grip_smoke verifies original length, thinner cross-sections, actual edge/cap, unit steel/palm attachment across336 pose-direction keys and renderer interpolation. king_axe_cardinal_smoke checks real equipment/Bag/idle/combo/skills/StageI. Evidence is ignored under tmp/review/axe_grip_2026_10_15/slim-*. No new visible Godot or sound audition while the owner plays Monster Hunter World. Offline comparison is slim-width-compare.png; fresh native approval is pending.

Final verification:724 production/preservation checks,1339 grip/carry/interpolation/width/length checks across336 pose-direction keys,171 headless gameplay checks and952 resources pass. All18 complete body atlases retain exact pixels. Weapon is one connected raster; original pixels outside the final shaft mask stay exact. Existing fixture exit warning remains separate; native feel awaits the owner’s next session.

Finalized after owner selection: all21 clips use the same slim weapon and current Bag icon. The widened lower source mask includes the entire former shaft outline; all visible steel is one connected component.1339 checks cover all336 attack/run/idle pose-direction samples. Four obsolete compact short-haft runtime/icon files were moved into ignored review, keeping their hashes in retired-files.json. Final current handoff: CONTINUE_WEAPONS.md.
