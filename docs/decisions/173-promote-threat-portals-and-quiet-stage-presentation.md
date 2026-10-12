# Decision173: Promote threat portals and quiet stage presentation

Date:2026-10-03.
Status: Implemented under owner instruction to begin work; native owner acceptance and later polish remain open.

2026-10-03 latest owner feedback: all A/B/C illustrations are accepted, lightweight random relaunch selection is requested, and walking King is rejected. Production trio uses still illustrations and a tiny last-index config to avoid consecutive repeats. Title promotion is complete; matching loading redesign remains pending. See [campfire direction](../design/campfire-title-direction.md). Earlier technical stability results do not establish owner art acceptance.

## Context

The owner selected all six portal concepts, approved the generic quiet loading direction with light motion, requested subsequent homepage/chest re-art, then asked to start implementation and leave a reliable handoff for another chat/AI. Decisions119/129 own destination tiers and F travel;172 owns concept selection and proposed lore.

## Decision

Promote six native eight-frame body families under the existing five threat tiers, with two red Boss variants. Keep the independently animated sixteen-frame lightning field and existing route/interaction authority. Use the Grasp Boss on current IV→V; expose Maw as an authored alternate/review asset. Future God/Transcendent artwork does not add routes.

Separate the generic background/seal/King/labels/progress into QuietLoadingView. SceneTransition performs background resource IO, polls only during pending work, then installs a completed PackedScene. Re-entry is rejected. Failed travel preserves the old scene/pause and restores title controls or the nearby portal prompt. Keep progress tied to loader fractions and add no mascot delay.

Reuse that quiet material language for the actual title. Renew only existing chest closed/open states, registered to unchanged native canvases and footprints. Keep gameplay, rewards, savings, controls and spoiler boundaries intact. Preserve retired snapshots rather than deleting shared legacy assets without a full reference audit.

## Alternatives and consequences

A static concept pasted over the scene would bake labels, hide real progress and freeze under synchronous IO. A full story/mechanics rewrite would exceed this presentation scope. Replacing the proven lightning system would add avoidable effect risk. The chosen modular change makes assets reviewable while preserving authority.

Native/headless presentation, interaction, real transition, title/save and rendered expedition checks pass. Main-thread scene instantiation/GPU upload, final owner feel/contrast, phone profiling and shared teardown warnings remain open. Sources, prompts, builders, captures and reproducible review are documented in [stage presentation](../design/stage-exits-and-quiet-transitions.md). [Continuation](../../CONTINUE_PROGRESS.md) is the next-chat entry point.172's native-integration-pending statement is superseded by this delivery, while its lore remains proposed.


## Owner-feedback correction: fixed portal silhouette

2026-10-03: Source-frame audit confirmed the reported wobble. Shared canvas/union registration did not prevent independently generated doorway poses from changing width, angle and feet. Keep the selected art/tiers, use one reference silhouette/rim and whole-pixel registered moving interior colors, and blend adjacent colors on the AnimatedSprite clock. Unique materials prevent one portal's phase from driving another; gameplay pause freezes presentation. Internal hand shading can move inside a planted outline. Full-body generated pose playback and an independent shader TIME clock were rejected because they preserve drift or desynchronize pause.

All six variants pass144 native frame/halfway/inner-motion/seam/pause checks; native integration54/0 and focused headless F/real travel checks pass. Atlases, lightning, collision/routes and reward/save authority remain. New sources require re-auditing reference/offset data. Current before/after and handoff are linked from the stage presentation document.

## Owner-feedback correction: shared quiet seal

The same source-pose drift affects homepage/loading. Both now preserve canonical engraving geometry and animate only Sprite-clock light with unique materials; title decorative pixels fade in place. This follows the fixed-geometry presentation choice above without coupling UI to encounter code. Hidden UI suspends processing; always-processing loading/menu keep motion under gameplay pause. Native195 stability/55 integration checks and title/Continue pass. Sources unchanged; current evidence is in art_source/review/ui/quiet_ui_stability_2026_10_03/.
