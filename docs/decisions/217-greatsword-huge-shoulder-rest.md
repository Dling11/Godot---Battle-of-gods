#217 — Huge Greatsword shoulder rest

2026-10-16. Owner selects concept B and explicitly requires the huge sword in every direction. Supersedes216's rejected lower-blade brace/plant and the unselected hop/sentinel concepts. New motion is implemented and natively verified; the owner approves the motion2026-10-16, with the accepted runtime hashes in approval.json.

## Choice and ownership

Generate three twelve-pose COMPLETE side/rear/front actor boards from the approved whole scythe identity and selected B motion. No transplanted heads/necks/limbs or per-pose body scaling. Use one source density per complete board (.1765 SIDE, .19 UP/DOWN), whole support roots, source-owned palms and frozen clothing/hair palettes. Exclude SIDE9–11 because they dropped the gripping hand; reuse complete accepted shoulder/quiet-look actors in the rest loop. LEFT mirrors SIDE.

Compose the unchanged30×140 steel at unit scale around each real fist. Source guide colors are registration marks, not weapon art. The shaft settles to a low shoulder angle as the free hand reaches the hip; later loop keys retain a stable view-specific direction. Whole body pixels occlude their own grip, including rear depth. Metadata keeps113 native/56.5 world pixels between hilt and tip; never shrink steel to fit King or the cell. All cells remain384×384, sole222, half scale/offset−16.

Preserve the first four ready cels and their weapon metadata exactly, along with running, attacks, .46s spin/2.16s chain, damage/reach/control, FX/audio, item/save identity and other families. Only three idle resources/body atlases change; shoulder idle shares the existing same-size empty attack overlay. Rest has16 keys: preserved ready0–3, new lift/settle4–11, slow quiet loop11–15. Entry1.05s, loop7.5s (1.5s per exposure); no ground plant, released sword, burial or body lift.

Optional WeaponFamilyPoseDefinition.retrieval_start_pose defaults−1, retaining existing families' behavior. Greatsword starts retrieval at neutral11 instead of replaying the slow glance cells rapidly; ordinary.28s retrieval and Player's input buffer stay authoritative. Remove the now-unused216 grounded_blade_brace flag/presenter branch and old rest emission from the full builder. Existing ordinary planted-family behavior remains.

## Reproduction and review

Current source/exact prompts/recipe/frozen complete ready inputs/423-file prior snapshot/native contract: art_source/generated/characters/king/greatsword_shoulder_idle_2026_10_16/. tools/king_greatsword_shoulder_idle.mjs exports buildShoulderIdle(PNG); full tools/build_king_greatsword_unified.mjs invokes it.519 build checks publish151 registered actor entries/120 effect slots. Full rebuild reproduces all six idle outputs without drift. Source guide bodies contain no shortened generated blade; canonical steel is composed offline. Normal play needs only Godot.

Play F5 → F9 → F7 → Weapons → Royal Greatsword, stop to trigger the rest. WASD/LMB/Tab/Escape retain normal behavior and non-saving Lab rules. Native capture/test results and owner-facing GIF are saved under ignored tmp/review/greatsword_shoulder_idle_2026_10_16; verification.json records current counts and limits. Owner motion/grip/identity review, campaign acquisition/balance and device profiling remain separate.
