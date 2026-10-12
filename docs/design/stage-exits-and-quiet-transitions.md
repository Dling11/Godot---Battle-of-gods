# Stage exits and quiet transitions

2026-10-03 · Decision173 · Implemented presentation; owner feel/art review remains open.

## Delivered

Six generated portal families are normalized into eight-frame,1536x160 atlases with192x160 cells, binary alpha, nearest sampling and a shared132px maximum native height. One source union/scale/origin per loop preserves source offsets but does not prevent generated shape drift. The actual doorway height follows the existing threat scale (.64–.96). Runtime now keeps a fixed doorway/hand silhouette and ground anchor while registered inner currents, finger shading and restrained rim lighting animate. StagePortalArt chooses calm, ominous, grasp, maw, divine or unknowable SpriteFrames. Boss variant0 is Grasp;1 is Maw. StageIV→V uses Grasp by default. Maw is a supported alternate visible in the review, not a new campaign destination.

The existing separate16-frame lightning field is retained, not newly generated. It draws above terrain and behind the colored body. Threat reach/speed/opacity remain tier data; Normal disables lightning. God/Transcendent are future-content art, not unlocked routes. Stage I→II blue, II→III purple, III→IV blue, IV→V red, V→VI blue and VI→Sanctuary blue remain. Portal trigger radius52, F interaction and encounter/chest ordering remain unchanged. The Sanctuary portal is outside scope.

QuietLoadingView composes a new generic960x540 navy background, a small generated eight-frame gold seal, the current outlined Spellward King walk, live native labels and a280x16 progress rail. No baked controls, forest setting, future boss image or patron spoilers. King walks in place as a mascot; the seal glimmers. Motion stops when hidden. Destination changes the heading for Sanctuary and a restrained bar accent.

SceneTransition starts ResourceLoader threaded loading before the .3s fade, polls only while a request is pending, reports changed real resource fractions and retrieves only a LOADED PackedScene. It then installs the scene, waits for scene_changed plus one frame and fades back in. No artificial wait for a complete mascot cycle. The service keeps the same transition_to API, signal/input/pause ownership and rejects concurrent requests. Failure retains the old scene and prior pause state; the title re-enables controls and a nearby portal restores its F prompt without leaving/re-entering range. Resource100% means resource IO completed; scene instantiation/render upload is a later main-thread phase. This is not proof of hitch-free cold GPU rendering.

Normal title startup now selects from three still A/B/C breach/campfire/clash illustrations with a left-side native menu. A small random pick excludes the previous cosmetic index across relaunch; no title walking King or seal remains. Six fixed motes fade. Native Continue/New Journey/Settings/Quit controls remain. Save validation, overwrite confirmation, focus and audio settings are preserved. Menu art was promoted under the owner's latest instruction to begin work; production art remains reviewable and owner visual acceptance is open.

Existing Forest Cache, Rootbound Reliquary and Varkuun Chest have new closed/open PNG pairs. Each pair shares one scale and registered feet. Native canvases remain64x48,72x64 and74x66; existing F range, static footprints, spawn/glow/fade, required III/V claims, loot definitions, first/replay grants, bank and save authority remain. These are two states per chest, not an eight-frame opening animation. No reward chests or gifts were added to other stages.

## Portal wobble correction

The owner reported wobble after integration. Source audit reproduced it: Calm's solid center changes about6.3 source pixels horizontally and its visible foot changes7 pixels vertically. Other families also change shape. The node transform stays planted; common192x160 cells did not make the drawings geometrically consistent. Earlier tests measured motion/canvas dimensions without comparing rendered silhouettes.

StagePortalArt now provides unique per-instance material and whole-pixel registration data for all six atlases. stage_portal_stable_surface.gdshader uses one reference frame for the entire alpha/physical rim, blends registered current/next-frame interior RGB, and permits internal Grasp finger shading within the fixed hand outline. Rim lighting varies gently; geometry never rotates or resizes. stage_portal_surface_animation.gd forwards the real AnimatedSprite frame_progress for smooth interpolation, rather than an independent TIME clock. Gameplay pause and tier speed remain synchronized. Source PNGs and existing trigger, F, arrival tween, lightning and travel rules are unchanged. Replacing source atlases requires re-auditing the measured reference/registration data.

Native portal_surface_stability_smoke:144 checks,0 failures. At authored scales every frame and halfway blend has zero changed silhouette pixels across all six families; upper/middle/lower current RGB still changes with glimmer disabled. Frame7 blend1 equals frame0 exactly. Actual Sprite frame/progress/material blend stay frozen under gameplay pause. Native integrated stage_transition_presentation_smoke rerun:54/0; real loading seal/King changed7/13 frames. Focused headless portal interaction and real stage travel pass. These checks do not claim whole-game profiling or resolved shutdown ownership.

Current source/render geometry, native stability/integration logs and a32-frame10fps comparison GIF live in historical Git-only review/ui/portal_stability_2026_10_03/. Before is raw source playback on the left; after is the actual corrected material on the right. Both use the same native tier scale; lightning is intentionally hidden only in this diagnostic comparison. Existing gallery captures and Grasp/Maw motion GIFs were refreshed with complete production lightning. Restart a running playtest to load this correction.

## Earlier homepage/loading wobble correction (title superseded)

Owner follow-up identified the shared seal too. Source audit shows666–1736 alpha pixels change versus frame0, and ornament bounds move despite shared112x112 cells. ui/presentation/quiet_seal_animation.gd creates a unique quiet_seal_surface.gdshader material per actual title/loading instance: fixed frame0 engraving and alpha, restrained moving angular light driven by real Sprite frame/progress. Source art remains unchanged. Hidden ancestry disables processing; UI always-process behavior preserves motion during gameplay pause. Homepage decorative pixels now fade in place, removing snapped drift and their loop reset.

Native quiet_ui_stability_smoke:195 checks,0 failures. Both actual screens have zero silhouette changes at all8 frames and halfway phases, changing light, exact seam, advancing paused UI, stopped hidden processing and independent materials; all6 title specks retain their positions. Loading keeps actual37.3% (display37%) and walking King. Native integrated transition rerun55/0 (seal/King7/13), native title and headless Continue pass. Evidence/GIFs: historical Git-only review/ui/quiet_ui_stability_2026_10_03/. Native GIFs are24-frame10fps rehearsals; loading preview is labelled37%, not real loading progress. Existing stage presentation gallery captures and loading GIF refreshed. No whole-game profiling/teardown fix claimed.

## Files and provenance

- gameplay/encounters/stage_portal_art.gd: immutable family selection and measured surface data; unique per-instance materials.
- gameplay/encounters/stage_portal_stable_surface.gdshader and stage_portal_surface_animation.gd: fixed silhouette/registered current interpolation, presentation only.
- gameplay/encounters/stage_portal.gd/.tscn: presentation and existing interaction/travel.
- autoload/scene_transition.gd: background resource load and pause/input boundary.
- ui/transitions/quiet_loading_view.gd/.tscn: disposable native presentation.
- ui/screens/title/title_background.gd/.tscn and title_screen.gd/.tscn: quiet title and failure recovery.
- gameplay/loot/stage_reward_chest.tscn: new texture references; reward script unchanged.
- retired generation tool (recover from Git history only) and retired generation tool (recover from Git history only): reproducible technical normalization.
- art_source/generated/environment/portals/threat_family_2026_10_03/: six source sheets, exact prompts, normalization.
- art_source/generated/ui/quiet_transition_2026_10_03/: background/seal sources and prompts.
- art_source/generated/environment/chests/renewal_2026_10_03/: six-state source, prompts and pair manifest.
- historical Git-only archive/stage_presentation_pre_renewal_2026_10_03/: retired transition/title/portal-frame/chest-scene snapshots. Runtime never loads the archive. Legacy neutral portal and old chest PNGs are retained for existing offline tools/recovery; this is not a repository-wide deletion pass.

Builder order after editing sources: run threat builder with --art-only, editor --import, threat builder with --frames-only; run chest builder, then editor --import. Do not substitute color-key removal for source alpha or scale/crop each animation frame independently.

## Review and verification

Run powershell -ExecutionPolicy Bypass -File .\tools\launch_stage_presentation.ps1. It configures user://stage_presentation_review.json before showing controls, so title/New Journey/real travel cannot touch the ordinary profile. Six buttons display the real portal body/FX beside native King and all closed/open chest states. Loading motion preview uses a labelled fixed37% rehearsal; Esc closes it. Test REAL loading enters normal StageI. Title / menu preview opens the actual startup menu, using the isolated profile. Close/relaunch the review to return to its menu.

F5 uses normal title/startup and the existing ordinary save. To see campaign exit art, clear a stage and use F; claim required III/V chests first. The gallery is the quick route to all selected variants.

Affected checks pass: portal_interaction_smoke, scene_transition_smoke, title_screen_smoke, title_continue_smoke, stage_transition_presentation_smoke and rendered expedition_feedback_smoke. The new presentation check exercises wrong-resource failure, prior paused state, title recovery, real overlap/F departure/failure prompt restoration, six anchored live families, FX ordering, slim progress bounds, concurrent-request rejection and a real StageI install with animated seal/King during the paused transition. Real native final pass:54 checks,0 failures; seal/King changed6/12 frames. Headless final focused pass:45 checks,0 failures; changed5/10 frames. Counts vary slightly with loader progress events. Existing full rendered expedition run:108 checks,0 failures. Verify subsequent logs before quoting later runs.

Evidence: historical Git-only review/ui/stage_presentation_2026_10_03/. title.png, portal_1.png–portal_6.png, loading_real_transition.png, loading_motion_preview.png and arrived_stage_1.png are rendered engine captures. GIFs are native motion rehearsals, not recorded resource progress; grasp/maw16 frames each, loading24 frames at fixed37%. The preceding integration baseline recorded ordinary profile SHA25661064D867D024D1F63491540ECF67F3118244177F2131724EEDDA79AD2EEF8BA. The wobble follow-up observed a different current hash while a separate normal game was running; latest observation is recorded in CONTINUE_PROGRESS.md. Focused verification suppresses saves or uses isolated storage. Never restore historical profile bytes.

Existing GPU shutdown warnings persist: two Texture/RID allocations,5460bytes each, and RenderingServer null during cleanup. Some early-exit scripts report ObjectDB references. Do not describe these as new gameplay freezes or as resolved.

## Updated order after Decision175

Enemy emergence/arrival sound is implemented in normal I–VI; see docs/design/enemy-arrival-and-horde-profiling.md. Title is owner accepted. Loading is implemented; further matching art is optional/deferred. Contact audio/reach and measured performance follow next. The list below records the prior ordered program; step2 is delivered.

## Earlier ordered work

1. Owner native review of compact gate/hand silhouettes, portal FX contrast, quiet title/loading pacing and chest scale. Adjust presentation assets/data only when feedback identifies a problem.
2. Enemy emergence and sound: short readable warning/materialization, actual direction, one restrained arrival cue per spawn/batch, safe terrain/actor/chest placement. Test one/three arrivals and IV eight-live pressure without changing enemy/reward authority.
3. Combat hit sound/contact review: blade/wood/armor/guard/interruption cues, local accepted-contact feedback and bounded shared camera/audio. Compare one/eight targets, preserve Skill1 no-global-hit-pause correction and damage/reach/interrupt rules.
4. Cold/warm physics/render/audio/VFX profiling, then pointer/walk clarity; fix measured costs before pooling. Representative-phone performance and existing teardown ownership remain separate open work.
5. StageVI muted-teal ascent renewal, warned Burrowkin prototype, a useful entrance scout, saved Sanctuary reactions, authored lore/cache/breakables and Hunts in the existing authority model.

Read CONTINUE_PROGRESS.md before resuming. Story expansion remains documentation/proposals; this art pass implements no divine gifts, gods, demon attacks, dialogue reveals or ending.


2026-10-13 maintenance: previous generation/comparison commands were retired; current output assets remain authoritative. New captures use ignored tmp/review/. See docs/maintenance/repository-cleanup.md.
