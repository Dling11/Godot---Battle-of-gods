# King complete-body reference contract

Updated 2026-10-13. Runtime/frozen assets are retained; historical archives and regenerated comparison files are deleted (Decision197).

assets/characters/playable/king/body_library/v1 contains immutable complete accepted Greatsword ready/gait and relaxed King poses. contract.json records10 PNG SHA256s. Cells remain192×128, four columns, scale0.5 and visual offset(0,-16). Pose/action may legitimately compress or turn; width/height alone is not identity. Never alter a frozen version or scale King for a blade.

Sword, Iron Beard and Royal Greatsword reuse canonical gaits. Current Twinsteel uses distinct shared_bodies/dual_carry_v3 complete cels (Decision196): its entire approved native upper carry is preserved through the waist, with canonical side legs/new generated vertical legs at one density/view and native palette. Ready/run blade angles/palms/depth match. This candidate requires owner motion approval; it is not exact full-gait equality.

Retain native head/neck/scarf/chest/arms/waist as connected complete anatomy. Review real grips, foot alternation, gutters/origins, camera-relative depth, actual attack handoffs and idle retrieval together. Do not stamp a head onto an unreviewed torso or use a detached runtime limb rig to pass geometry. Accepted axe/Greatsword/Twinsteel contacts, steel, FX, clocks and gameplay remain.

Current Twinsteel carry rebuild: tools/build_king_twinsteel_carry.gd reads the current profile, frozen anatomy, tools/king_dual_steady_carry.gd and retained gait_source.png. It writes only current carry siblings and matching endpoints, with no archive input or historical builder inheritance. Other weapon generation trials were removed; future changes need new scoped generation/review, not restoring the obsolete chain.

Check immutable references with tools/check_king_body.gd. tests/king_shared_body_smoke.gd covers canonical gait/identity and Sword composition; tests/king_dual_steady_carry_smoke.gd covers steady upper anatomy/legs/endpoints; tests/king_dual_gait_smoke.gd exercises real input/travel/walls and attack/idle transitions. The small tests/king_art_test_base.gd supplies complete connectivity/equality helpers. Production asset hash evidence for this cleanup lives in docs/maintenance/active-assets-2026-10-13.json, not a permanent promise that future art cannot change.

Test F5 → F9 → F7 → Weapons/Tab. Use native rendering for timing/art/UI checks; headless verifies structure only. Capture output is ignored tmp/review/. No accepted visual changes are introduced by cleanup.
