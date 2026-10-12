# Stage II bramble renewal and outdoor audio

Implemented 2026-10-03 under Decision168. All five world-life recommendations are approved; this is their first delivery after the accepted Stage I pilot. Current Decision171 adds IV/V renewal, campaign Rotcaller and new Dark Forest Theme music to normal I–IV. VI, the scout, reactions, exploration and Hunts remain planned. Stage II visual/mix acceptance and phone profiling remain open.

## Playable environment

Normal `levels/stage_2/stage_2.tscn` uses a baked 48x28 grid of 32px cells (1344 cells) over the existing 1536x896 world. The accepted Grove ground atlas is reused because Stage II is still living forest; its new props have their own silhouettes/materials rather than being recolored Stage I trees. Two worn lanes skirt the Broken Heart ruin; branches reach the western/eastern entrances. Bramble/root groups explain edge pockets without blocking reinforcement points or ranged fighting space.

Eight native prop families: birch92x118, thorn_tree91x112, shrine56x70, bramble52x40, root66x32, stones46x27, thorn_fern29x28, flowers24x17. Eighty-three authored placements use separate base collision and navigation cutouts; decorative plants remain passable. Existing rooted wind, tall-tree canopy fade, floor Y sorting and four-frame bird flights are reused. Thorns are visual environment identity, not a new damage hazard. The central landmark retains its BrokenHeart name.

King scale, bounds, seven authored waves/32 enemies, six-live ceiling, direct Mini Boss portal to Stage III, rewards, story milestone and normal saving remain. Smaller bases can change positioning; automated accelerated completion is not a normal difficulty/balance judgment.

## Sound and music flow

`AudioDirector` still owns one cross-scene music player. A changed track fades out for .28s, switches at -48dB and fades in for .65s. Same-track requests adjust gain over .45s without restarting. A newer request or stop cancels prior music tweens; an outgoing scene cannot change the requested next track's gain. Handoffs continue through modal pause. Headless checks assign track/gain immediately and do not open a device.

`BiomeAudioProfile` resources select recordings, gains, cue cadence and attenuation. `BiomeAmbience` creates one scene-local background player and one positional call player, using a single one-shot Timer; freeing the stage stops both. A duplicated bed stream loops without mutating the immutable shared profile. `Ambience` sends to `Music`, preserving the atmosphere toggle independently of combat SFX. Pause menu now names it **MUSIC & AMBIENCE**. World callers inherit a Node2D transform and authored cue positions.

Stages I/II use the attributed recorded forest loop and sparse bird calls. Stage II's quieter bed is -31dB; calls are -21dB every24–40s. Stage I uses -29/-19dB every18–32s. The first real wave reduces both ambience gains by6dB; inter-wave recovery keeps the combat mix; the actual final clear restores it. Stage II music goes -16dB on arrival -> -13dB combat -> -17dB clear; Stage I preserves its -13dB start/combat and softens to -17dB on clear. Existing boss music selection and requested gains remain authoritative. Later biome recording profiles and a new arranged regional score are not implemented.

Sources are public HQ MP3 previews of two CC0 recordings, not original WAVs or newly composed music. See [recordings and verified license provenance](../../assets/audio/ATTRIBUTION.md). Listen with real combat before adopting a final mix.

## Source, rebuild and recovery

- Props: `assets/environment/forest/thorns_renewal/`, `environment/props/thorns/`.
- Ground source: `data/environment/layouts/stage_2_forest_ground.tres`, shared `grove_ground_tileset.tres`.
- Generated source/prompt/crops: `art_source/generated/environment/forest/thorns_renewal_2026_10_03/`.
- Builder: `retired generation tool (recover from Git history only)`; run --art-only -> Godot editor import -> normal bake. Inherits Stage I's prop-scene authoring with virtual output-directory hooks. The Stage II scene UID is retained. Existing OutdoorAudio/StageMusic nodes survive rebakes.
- Recovery: `historical Git-only archive/stage_2_pre_renewal_2026_10_03/` (.gdignore). Shared coarse terrain/tree/statue resources still serve later stages; do not delete them.

## Ready no-save review

Run `powershell -NoProfile -ExecutionPolicy Bypass -File ./tools/launch_stage_2_renewal.ps1`.

The same normal Stage II scene opens peacefully with saving suppressed before scene entry and damage-immune King. WASD explores; Arrival/Broken Heart/North threshold and Overview visit the layout. **Start normal waves** runs the actual authored encounter. Music/Outdoor sound toggles separate the review layers; Local bird call demonstrates attenuation. Music handoff demo temporarily requests the existing Varkuun composition then returns to the Grove; it is a presentation demonstration, not a boss encounter or new score. Review tools do not write progression to the normal profile. Restart normal F5/expedition play for ordinary saving and vulnerability.

`--capture` produces native960x540 arrival, ruin, threshold, canopy, overview and live-wave proof in `historical Git-only review/environment/stage_2_renewal_2026_10_03/`.

## Verification

Stage II environment smoke:178 checks for world/grid, all reinforcement/exit paths sampled against physical collisions, every base/cutout, passable decoration, canopy restore/fixed roots and animated birds. Stage I regression:183 checks. Stage II encounter, wave structure, reinforcement, pause and Stage V music/environment regressions are required alongside shared audio checks.

`tests/biome_audio_smoke.gd`:18 headless /22 rendered checks for gain transitions, same-track continuity, latest-request/stop cancellation, paused handoff, outgoing-scene guards, looping without resource mutation, timer cadence, actual device playback/measured bus signal, combat duck/recovery, disable/re-enable and scene teardown. The clear signal in this audio test is a presentation fixture; it does not prove rewards. The rendered expedition integration passed91 checks, separately exercising actual Stage II deaths/clear/receipt/return/save before existing milestone/crafting/equip/training checks, using an isolated profile and accelerated encounters. Its updated UI proof is under historical Git-only review/ui/expedition_feedback_2026_10_03/; prior evidence is preserved. Owner listening/visual review, whole-loop balance and representative-phone performance remain unverified. Existing shared GPU shutdown texture/RID warnings persist.

2026-10-13 maintenance: previous generation/comparison commands were retired; current output assets remain authoritative. New captures use ignored tmp/review/. See docs/maintenance/repository-cleanup.md.
