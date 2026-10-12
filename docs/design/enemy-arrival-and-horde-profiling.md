# Enemy arrival and focused horde profiling

2026-10-03 · Decision175 · Implemented in normal encounter stages I–VI on Godot 4.7.2. Owner mix/feel and representative-phone performance remain open.

## Current direction: one generic monster spawn

Decision176 supersedes the proposal to make different arrival frames for enemy sizes/tiers. The owner wants one generic, economical spawn effect while retaining actual raster animation. Normal I–VI production cue: a low planted shadow/crack, squat outward dust burst and dissipating remnant. Four generated drawings total, independent of body height; the same cached atlas, scale and floor origin are used for Rootling, Thrall, Crag Bear and Husk. It does not enclose the monster or need to match a body silhouette. Each enemy retains its existing visual appearance transition; those existing transitions differ and are not rewritten or claimed standardized here. No added procedural/vector geometry, per-enemy sprite sheets, new body shader, pooling layer or global manager.

One warning drawing occupies the existing .3s safe reservation. Three release drawings run .56s; final .56/3-second alpha fade clears the remnant. Native cells64x64/floor(32,46), visible25–44px wide and9–19px tall, binary alpha and one48/627 nearest scale for all four drawings. EncounterController still owns placement/cap/revalidation/retry/pause/defeat/actor creation/sound; the VFX only observes release. The original approved earth/wood sound is reused unchanged.

tools/launch_generic_spawn_review.ps1 opens the actual renewed Stage IV with an enemy picker, Spawn selected foe, same-batch Replay,1/3/8 crowds and grass/dark. Selecting a different foe resets/replays one instance; mixed/crowd buttons still use their original Rootling/Rotcaller fixture. Every actor loses rewards before ready; storage user://generic_spawn_review.json and suppressed saves. Native61 checks pass: actual spawn/replay/ground buttons, dropdown opening and its native selection signal, same resource identity/scale/pivot across four real actors, binary four-cell atlas, reservation/materialization/pause/cleanup, rewards/saves, crowds and bag/viewport controls. Synthetic keyboard events did not route reliably into the separate native popup window; the test uses its selection signal after opening the dropdown with the mouse rather than claiming OS keyboard navigation coverage.

Sources/prompt/registration: art_source/generated/vfx/generic_spawn_2026_10_03/. Runtime: assets/vfx/generic_enemy_arrival/ and gameplay/presentation/generic_enemy_arrival.gd. Normal I–VI now use it through common summon_effect.tscn after owner testing; native40 arrival checks pass. Old vector/clock source is archived, SummonEffect is only a release contract. Native captures: historical Git-only review/encounters/generic_spawn_2026_10_03/. Further owner feel/contrast/phone review and scripted boss intros remain outside this delivery. Next: material hit/guard/interruption sound and representative combat profiling, not per-size frame production.

## Earlier A/B/C review: sound accepted, visual replacement pending

The owner approves the arrival sound but rejects the code-drawn/vector-looking spawn. The original four-keyframe A Veil Tear / B Earthwake / C Shadow Cocoon board was insufficient to choose without gameplay. All three now have six transparent generated drawings and registered64px native-cell atlases, playable via retired generation tool (recover from Git history only). Two warning drawings run during the actual0.3s reservation; four non-looping release drawings run for0.56s and the final remnant fades. Each family shares one uniform56/512 nearest scale with authored floor seams at(32,52); native edges are binary alpha. No drawn/vector fallback or whole-effect scale tween. Brightest-pixel registration was rejected because it follows moving rim light instead of the floor.

A/B/C switches/replays the same batch;1/3/8 enemies, Reset, Replay, grass/dark ground, native King/AI/skills/sound/bag/pause are available. The first dark comparison point is below the eastern gate, avoiding occlusion by its tall arch. Enemies retain the existing normal arrival authority/AI but lose rewards before ready; storage is user://enemy_arrival_art_review.json and saving is suppressed. No art choice or campaign replacement is approved yet: normal F5 continues to use the procedural SummonEffect. This dedicated review does not update normal saves or select a preferred family globally.

Original concept: art_source/generated/vfx/enemy_arrival_choices_2026_10_03/. Built-in imagegen originals/exact prompts/crop-registration manifest: art_source/generated/vfx/enemy_arrival_runtime_preview_2026_10_03/. Runtime comparison atlases: assets/vfx/enemy_arrival_review/. Native review57/0 checks cover real A/B/C clicks, registered six-drawing resources, warning/materialization, pause, cleanup, batches/replay, reward removal, isolated storage, bag controls and viewport bounds. Captures of all three on both grounds: historical Git-only review/encounters/arrival_art_2026_10_03/. Native art/motion approval and phone readability remain owner review; existing shared Texture/RID shutdown warnings persist. The choice takes priority before the earlier next-work list below. After choice, promote only the selected visual family while preserving accepted sound and tested placement/cap/pause/reward authority.

## Player-facing change

This covers EncounterController mobs, including StageV sentries; separately authored Varkuun introduction remains unchanged. The old tall lightning summon is replaced by a planted 48×20 pixel ground seam. A 0.3-second warning appears before an enemy exists in the world. It brightens, then six dust pixels rise as the actor emerges facing King. This is an arrival cue, not a damage zone, attack or new portal. The existing actor-specific 0.5–0.8s safe spawn state still follows it. Rootlings and Mirelings now fade to full visibility in at most 0.22s at their native scale; the old Back tween compressed their bodies nearly flat. Walking/attack sheets, damage, skill reach, waves, counts, caps, rewards and F interactions remain their existing authorities.

The seam is code-native pixel VFX with fixed vertices and Timer steps every 0.07s; no generated sprite frames, continuous polling, runtime audio synthesis or new global service. Original offline audio is a half-second mono earth/wood rustle and soft release. Encounter-owned positional SFX uses one reusable player, -9dB gain,850px maximum distance and a 550ms minimum gap. A simultaneous batch produces one cue. Existing biome music/ambience remains distinct from Sanctuary as delivered under Decisions168/171; no new music track is claimed here.

## Authority and safety

EncounterController waits for the navigation map to synchronize before consuming the initial batch. Its former eight-frame timeout could consume a slot before the map existed, falsely turning an initial enemy into a reinforcement.

Each warning reserves one live slot immediately. The off-tree actor is owned by the controller's pending-arrival dictionary until materialization or cancellation. Placement projects onto navigation, requires a path to King, and queries world/player/enemy body collision using the actor's data-owned movement radius plus 4px (minimum 14px). Pending warning circles remain separated by summed radii plus 8px. Points stay at least 96px from King and 64px from the exit/chest marker. The authored request is tried first, then two small rings and authored markers; unsafe points are deferred rather than using an unchecked nearest fallback.

The location is checked again after the warning. If King or another obstacle occupies it, the arrival cancels and the authored scene returns to the queue; it never silently teleports to a different point after warning. King's defeat cancels pending arrivals and blocks further wave/completion work. Leaving the stage frees pending off-tree actors and their effects. Actor transforms are set in the actor parent's coordinates before ready. Existing facing methods/signals drive the art; no VFX decides AI or contacts.

Initial batches settle before reinforcement announcements. Each reinforcement awaits its real warning/materialization before releasing the queue flag, then schedules the next available slot. Spawn, reinforcement and inter-wave timers stop during modal/gameplay pause. The configured reinforcement delay is retained, with the additional0.3s ground warning. This intentional extra warning changes pacing; whole-loop balance remains owner review.

## Ready in-engine review

Run retired generation tool (recover from Git history only) from this checkout. It opens the actual renewed Stage IV with one Rootling, three roots/caster, or eight-live crowd controls. Reset between batches; safety can be disabled for vulnerable play. WASD, attacks, skills, bag and pause remain real. Normal Stage IV opens the normal five-wave review after the trial. The custom trial strips reward components before ready and uses user://enemy_arrival_review.json with suppressed saves. Normal stage review also remains isolated from ordinary saves. Native capture mode: Godot --path . --script res://tools/launch_enemy_arrival_review.gd -- --capture.

Normal F5 stages use the new effect automatically; the Sanctuary/title/loading/chest artwork is unchanged. The loading screen is already implemented. A matching illustrated loading redesign is optional future work, not a prerequisite or current task.

## Verification and measured limits

- Native summon_effect_smoke: 39 checks/0 failures; checks real warning-before-actor, pause, fixed location/facing, full-scale silhouette, one/three/eight slots, ninth queueing, static collision, pending spacing, native device playback, cancellation on King entry/defeat, and teardown. Evidence-camera adjustments follow edge warnings without moving King; they are not production camera changes.
- Native enemy_arrival_review_smoke: 30 checks/0 failures; actual mouse buttons, labelled counts, reward stripping, isolated storage, reset, safety, bag visibility and normal Stage IV shortcut.
- Headless expedition_feedback_smoke: 101 checks/0 failures; normal I–V waves, actual rewards/chests/receipts/return, Nema craft, equipment, Eira training and isolated save/Continue. The accelerated fixture's timeout now budgets the new authoritative warning per enemy; no runtime delay is shortened for this test.
- Encounter reinforcement, Stage IV authored encounter, combat feedback and current audio smoke checks pass. Audio smoke referenced retired Echoing Sever/Riftbreak fields and an obsolete dash asset/gain; its checks now follow implemented presenters and the accepted grounded dash. Production combat audio was not altered by that test repair.

First/repeated Foundation casts against stationary high-HP 1/5/8 targets, native 960×540 Compatibility/OpenGL AMD:

| Targets | First/repeat contacts | Global pauses | First/repeat p95 frame interval | First/repeat maximum physics monitor |
|---|---|---|---|---|
|1|1 /1|0 /0|14.86 /14.21ms|3.01 /2.08ms|
|5|5 /5|0 /0|14.40 /14.28ms|16.82 /2.55ms|
|8|8 /8|0 /0|14.85 /14.52ms|3.09 /3.26ms|

Eight contacts span seven physics ticks and preserve the earlier Skill 1 no-global-pause correction. A first five-target sample includes a 16.82ms physics peak; this is retained as follow-up evidence, not explained away or claimed fixed. Frame maximum across these samples reaches17.54ms. These are short fixture frame intervals/CPU monitors and draw/node counts, not GPU timings, allocation measurements, a completely cold campaign or a phone profile. Enemy AI is disabled to isolate the cast; normal native trial permits actual movement/attacks. Other owner/editor activity was not forcibly stopped. No speculative pooling or contact/range/damage changes were introduced. Reproduce with tests/earthsplitter_horde_feedback_smoke.gd -- --profile --targets=1 (or5/8); JSON records under the evidence folder.

Sources: gameplay/encounters/encounter_controller.gd, summon_effect.gd/.tscn; small Rootling/Mireling/Rotcaller visual corrections; tools/build_enemy_arrival_audio.js; assets/audio/sfx/enemy_arrival.wav. Earlier summon effect is recoverable under historical Git-only archive/enemy_arrival_pre_renewal_2026_10_03/ (.gdignore). Captures/logs/JSON: historical Git-only review/encounters/arrival_2026_10_03/. Existing two 5460-byte Texture/RID shutdown warnings persist on native exit.

## Next work

1. Blade/wood/armor contact cues, guard/interruption sounds and four-direction visible-versus-physical reach review. Preserve local accepted-contact feedback and bounded shared audio/camera; show actual vulnerable one/eight-target play.
2. Reproduce the first-cast physics spike in full cold/warm campaign combat before optimizing; measure AI/navigation, audio and VFX separately, then representative phone. Keep shutdown ownership separate.
3. Pointer/blocked-target and walk/stop clarity, then muted-teal Stage VI renewal, warned Burrowkin, useful scout/reactions and authored exploration/Hunts under existing reward/save contracts.

2026-10-13 maintenance: previous generation/comparison commands were retired; current output assets remain authoritative. New captures use ignored tmp/review/. See docs/maintenance/repository-cleanup.md.
