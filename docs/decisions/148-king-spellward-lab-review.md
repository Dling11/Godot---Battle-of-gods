# 148 — King C Spellward isolated Lab review

Status: implemented as an opt-in debug Lab review; directional walking, hand motion, three basic attacks and hurt/stun body poses owner-approved. Campaign promotion and dash/defeat final review pending. 2026-09-14.

## Context

The owner selected appearance option 3 / C Spellward, requested clearer stylized detail without realism or increased human scale, then authorized both visual and playable review. Character foundation precedes the next skill redesign. The earlier implementation pause no longer blocks this bounded review.

## Decision

F7's KING REVIEW creates a session-local presentation comparison on the real player. C uses 56px source-body detail in 192x128 cells at half scale, preserving approximately 28 logical pixels and existing feet/collision origins. Generated directional states and three separate cut families replace presentation only while enabled. The original frames/script/scale are restored on comparison. Existing white raster trails, impacts and sounds remain, with the finisher using a distinct atlas row.

The controller, weapon resources, damage fan, phase durations, input buffer, mitigation and progression retain authority. HIT/STUN samples enter the actual health/control pipeline, restore health/immunity and do not add control lock. SPEED uses the existing bounded component interfaces without changing owned gear. Existing skill effects/rules stay in place; temporary C body aliases are explicitly provisional.

## Alternatives

Immediate campaign replacement was rejected for this pass because motion approval is still pending. Enlarging the player to expose detail would change human/boss scale. A standalone animation viewer alone would not validate control, equipment speed, collision or hit feedback.

## Consequences and verification

Owner can review four-direction locomotion, three cuts, white trails, hit/stun, dash/brake and defeat in real combat while comparing the existing King. The extra detail is verified in the actual 1080p canvas-items render. Mirrored asymmetric clothing, source-pose cleanup, side gait feel and provisional skill-body aliases remain review limitations. Campaign appearance, save schema, skills and shared combat resources are unchanged.

The focused 215-check suite, existing Combat Lab regression and 385-check mastery suite pass. A native video, cropped GIFs, render stills, source prompts and measurement data live under art_source/review/characters/king/spellward_lab_2026_09_14.

## September 14 locomotion correction

The owner approves the attacks and flags idle sway, walking coherence, the rear sword/hair overlap and weak outlines. The follow-up retains the accepted attack PNGs byte-for-byte. Idle/walk/interact now derive from one new identity-referenced sheet, using a fixed row scale, foot baseline and upper-hair horizontal registration instead of source cell centers. Idle slows to a two-second loop. The rear carry lies at scarf/upper-back height beneath the hair.

A Lab-only one-source-texel charcoal outline applies to every C body clip. It preserves texture interiors and vertex modulation; comparison restores the original material. The importer exposes --locomotion-only and reproduces the correction after a full build, without touching attacks during the scoped build. Sources, prompts, measurements and fresh actual-Godot review live under the corresponding spellward_locomotion_2026_09_14 folders. Final gait feel and campaign promotion remain pending.

The owner subsequently accepts front/back gait but rejects foot-only side posing. The latest side cycle uses eight coordinated whole-body drawings in walk_side.png; four-frame front/back drawings stay intact. Fourteen FPS maintains the existing cycle period, and the preview animation subclass retains normalized cycle phase on turns between different frame counts. No gameplay speed changes. The source rows share one scale. Focused checks now total 232; whole-body motion approval remains pending.

## Final gait acceptance

The owner accepted the upper-body motion but rejected that generated leg sequence. The final side atlas uses an offline two-bone raster rig under locked approved upper-body frames, preserving foreground leg identity and continuous support/swing paths. The owner explicitly approved this revision. The current accepted proof is spellward_legcycle_2026_09_14. Earlier pending-motion statements are superseded for walking and the accepted hands/attacks. Campaign promotion and the separate skill redesign remain pending.
