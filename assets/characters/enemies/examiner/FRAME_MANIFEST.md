# Examiner Frame Manifest - Decisions 136-137

The scene-assigned `examiner_sprite_frames.tres` contains 116 named clips. Build with `retired generation tool (recover from Git history only)`; the older builder delegates to this entry point.

Ten action/idle sheets each contain eight columns and four rows of 192x160 cells. Runtime rows are **down, right, left, up**. Body origin is `(0,-48)` and cell baseline is 128. Column spans below are zero-based, end-exclusive.

| Sheet | Animation spans |
|---|---|
| Locomotion | idle 0-2; old walk cells retained as source history |
| Dedicated walk (four columns) | walk 0-4; contacts 0/2, passing knees 1/3; 7 fps |
| Thrust | wind-up 0-3; strike 3-5; recovery 5-8 |
| Sweep | wind-up 0-3; strike 3-6; recovery 6-8 |
| Judgment Charge | wind-up 0-3; travel 3-5; recovery 5-8 |
| Ground Judgment | wind-up 0-3; contact 3-5; recovery 5-8 |
| Refutation | wind-up 0-3; active 3-5; recovery 5-8 |
| Axiom Divide | wind-up 0-2; first contact 2-4; second contact 4-6; recovery 6-8; dash uses Charge travel |
| Descent launch | prepare 0-3; launch 3-8 |
| Descent landing | fall 0-2; impact 2-4; recovery 4-8 |
| Reaction/withdrawal | hurt 0-3; withdrawal 3-8 |

`retired generation tool (recover from Git history only)` owns connected actor extraction, exterior matte removal, binary alpha, one standing-reference scale, and foot anchoring. It recovers weapons crossing imperfect source gutters. Reviewed right profile actions supply mirrored left profiles; reversed landing source rows are corrected before mirroring. Dedicated gait uses front/profile/back studies and a mirrored left profile; turns preserve frame/progress.

Sources, exact built-in ImageGen prompts, and `import_report.json` live in `art_source/generated/characters/disciples/examiner/rework_2026_09_12/`. Superseded 192x128 sheets/imports and prior edited implementations are preserved in `historical Git-only archive/characters/disciples/examiner_before_rework_2026_09_12/`. Do not run legacy V3/V5/V6 processors to rebuild current assets. Reimport textures before geometry/visual tests.

Anticipation excludes contact poses. Controller signals own damage and phase timing; frame fitting, accents, trails, audio, and UI remain observers. Final owner visual/feel approval remains pending.

Ground Judgment column 2 uses the dedicated `slam_raise.png` 2x2 overhead-wind-up supplement. Its source density is normalized once to the locomotion reference grid, then the common runtime scale applies; each pose is not independently fitted. This replaces the clipped, weak overhead pose from the original new eight-column slam board.

Decision 137 adds `polish_2026_09_12/` sources and whole-board component extraction. The repaired slam board replaces source overlaps/clipping; the overhead supplement remains. The main rework importer now chains the gait/effect importer. All 336 packed body cells pass transparent-edge and binary-alpha audit.

The owner accepted the skill follow-up but requested gait identity correction. Current walking sources and prompts are in `identity_2026_09_12/`, packed by `retired generation tool (recover from Git history only)` through the polish importer. Fixed helmet-to-ground measurements match approved idle body size (down 64px, profile 65px, up 69px); weapon height does not control body scale. The earlier ornate polish gait studies are superseded.

Decision 138 keeps all 116 saved clips and the owner-approved identity. Reprisal maps to the charge wind-up/travel/recovery family. Held Judgment plays the overhead slam anticipation over 0.38s then holds until the 1.05s contact. Trial of Worth holds the guarded Refutation frame; its seal and lane effects stay separate from body art.

2026-10-13 maintenance: previous generation/comparison commands were retired; current output assets remain authoritative. New captures use ignored tmp/review/. See docs/maintenance/repository-cleanup.md.
