# Iron Reaper side-motion preview

Historical motion-study record (Decisions202–203). The owner subsequently accepted the oversized variant; Decision204 installs the complete playable equipment. See [current weapon guide](king-iron-reaper.md) and tools/launch_king_iron_reaper.ps1. Statements below describe the isolated preview at delivery time.

2026-10-14. The chosen silhouette is Iron Reaper. This delivery is a complete left/right motion study; it is not a fifth playable weapon. Current Sword, axe, Greatsword and Twinsteel remain protected.

Four proposed cuts: broad shoulder-to-hip sweep, upward return hook, full turning cut, finishing reap.32 complete newly generated character/scythe poses and16 separate white effect frames. Two-handed grips, lean King anatomy, dark outlines, scarf response, hip/boot weight transfer and the selected angular inner cutting blade guide the art. Wide swing trails are presentation ideas, not proof of damage reach or enemy pulling. No pulling/rooting mechanic is implemented.

The proposed four-cut animation lasts2.38 seconds, excluding the viewer's0.5-second entry/0.6-second rest. Slow anticipation leads to a short release and readable follow-through; the spin has0.62 seconds to turn. These are review clocks, not a data-owned combat combo or balance commitment. Last reap source poses8 and7 are displayed in that order to finish with an upright gather. Every source pose can be stepped through.

Launch from the project root:

~~~powershell
.\tools\launch_king_iron_reaper_preview.ps1
~~~

Use -GodotPath on another PC. The viewer shows both mirrored facings enlarged3× above an actual half-scale comparison with the approved complete King. Space pauses/resumes; arrows step through32 poses;1–4 select cuts; Tab toggles white effects; S toggles half speed; Escape closes. Selecting/stepping then resuming continues from that pose. Existing F5/F9/F7 controls remain unchanged; Iron Reaper is not available there yet.

Rebuild: tools/build_king_iron_reaper_preview.gd. Source PNGs, exact built-in imagegen prompts, selected weapon concept, registration-recipe.json and current protected-asset hashes live under art_source/generated/characters/king/iron_reaper_side_preview_2026_10_14/. Preview atlases are offline derivatives; their folder is excluded from Godot import/export by .gdignore and is not a gameplay dependency.

Native capture: tools/review_king_iron_reaper.gd -- --capture. The209-frame60fps GIF is tmp/review/iron_reaper_2026_10_14/iron-reaper-side-combo.gif. Frames/captures/rejected drafts remain ignored. Builder checks738/0; controls46/0; native capture covers all32 poses in both facings. Source registration/gutters/body scale and532 current King-file hashes pass. Production scythe blade rigidity across new cardinal art, equip/run/idle transitions, damage/range/control/audio and acquisition are still unimplemented. Owner judgment remains pending.

Next after side-motion acceptance: cardinal attack/running/idle generation, reviewed compact item/icon art, data-owned combat role and safe normal equipment routing. Real-enemy and horde profiling follow implementation; do not infer performance or balance from this isolated sprite preview.

Additional verification:875 retained project resources load; ten immutable complete body atlases match; all five preview outputs rebuild byte-identically. Selected source set is8.92MiB and does not enter runtime/export packaging.

Oversized study2026-10-14 (Decision203): owner likes the original detail and requests a larger shaft/hook. The viewer now defaults to a completed passing oversized variant; V compares both sizes and --original starts the earlier one. New source/atlases are separate; original source and PNGs stay exact. Enlarged352×288 cells/sole216, whole-standing57-texel calibration, source alpha cleanup and two-column spin/reap sources avoid clipped parts, shared fringe and incorrect foot registration.752 build checks and52 controls per variant pass;875 resources load; five enlarged outputs reproduce.209-frame GIF: tmp/review/iron_reaper_oversized_2026_10_14/iron-reaper-oversized-combo.gif. Source6.44MiB stays outside lightweight packaging. Hook and Reap remains a proposed specialty: see iron-reaper-specialty-proposal.md. Owner size/motion judgment precedes implementation.
