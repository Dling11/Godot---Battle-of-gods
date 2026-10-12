# Stage III Hollow renewal and enemy pressure

Environment implemented2026-10-03 under Decision169; Decision171 adds campaign Rotcaller, bounded hordes and new expedition music. IV/V renewal is implemented; VI, Burrowkin, scout/reactions, exploration rewards and Hunts remain planned. See [current campaign and next work](stage-5-renewal-and-combat-polish.md).

## Normal campaign

The normal Stage III scene uses48x28 baked32px cells (1344) across unchanged1536x896 bounds. A ragged western incursion covers27.08% of cells including a two-cell/64px mixed transition;72.92% remains fully living. Decay tapers before the living center/east. Ground derivatives preserve the established Rootbound material and the approved living Grove density. Two worn lanes skirt the low ritual seal; side trails reach both lateral entrances.

Eight newly generated prop families,66 authored placements: blighted_ash106x118, living root_elm88x118, seal129x90, memory_tablet32x35, fallen_root66x31, root_mound44x31, fungi26x19, masonry44x36. Rooted foliage sways and tall canopies fade around King; decorative fungi stay passable. Base shapes own collision/navigation. Birds have a stage-authored route over the living eastern forest; the Sanctuary flight defaults remain unchanged. The western tablet is currently a visual landmark, not an inspectable/reward-bearing interaction.

The seal remains at768,300 with a compact140x40 base and20px baked navigation clearance for the Husk's16px body. Preserve King/bounds, all four entry markers, portal390y and the southern chest approach.

Normal encounter is **13 Rootlings + one Rotcaller / five live -> portrait dialogue -> solo280HP Husk -> required F Reliquary claim -> blue Normal Stage IV portal**. The caster grants ordinary enemy rewards under Decision171. Boss reward, story, replay, recipe and save rules remain authoritative.

## Outdoor sound

The new scene-owned Hollow profile uses recorded forest wind (-30dB) and quiet positional woody creaks (-25dB,28–46s cadence) from authored western sources. Combat reduces both6dB; the actual claimed clear restores them. The creak is a licensed floorboard recording used as woody ambience, not claimed as a tree field recording. It does not reuse the Husk's combat-warning sound. See [source recordings and licenses](../../assets/audio/ATTRIBUTION.md).

Dark Forest Theme (attributed CC0 recording, Decision171) starts at -16dB and increases to -13dB for the Rootling wave. Dialogue still gates the solo Husk and his existing boss track. The claimed clear softens that active track to -17dB; outgoing-stage gain requests cannot change a newly requested track. Existing AudioDirector owns the single music foundation; no new composition is claimed. Music & Ambience controls both atmosphere buses separately from combat SFX.

## Optional pressure comparison

Run `powershell -NoProfile -ExecutionPolicy Bypass -File ./tools/launch_stage_3_renewal.ps1`.

Saving is suppressed before scene entry. King is damage-immune; WASD/skills remain usable. Arrival, West decay, Ritual seal and Overview visit the art. Choose **Normal: 13 roots + caster / 5 live** or **Pressure: 18 roots + caster / 6 live**, then **Start chosen waves**. The selector locks once started; restart the review to compare the other choice. Skip/continue the Husk's dialogue normally. F still claims the Reliquary and uses the portal. Review immunity applies only while this Stage III review remains loaded; forwarded normal stages do not inherit it. Saving stays suppressed until process restart.

`tools/stage_3_pressure_review.gd` duplicates only the approach wave before starting, changes its Rootling count to18, retains one caster and raises the local cap to6, and leaves the solo boss/reinforcement timing intact. The shared campaign wave stays13 Rootlings plus one caster and its cap5. Dialogue reflects the altered brood count. This is an opt-in review candidate; it is not normal balance and cannot prove real difficulty with immune King. Next balance review should use vulnerable King with minimum eligible gear and compare attack readability, death rate and clear time before promotion.

## Enemy recommendations

Prioritize the [Rotcaller and Burrowkin recommendations](forest-enemy-mechanics-recommendations.md). Target priority and warning/recovery patterns offer a fresh decision; an unlimited spawn increase would add crowding without teaching that decision. The19-total/six-live comparison answers how a modest density increase feels while preserving the narrative boss gate.

## Source and recovery

- Runtime kit: assets/environment/forest/hollow_renewal/ and environment/props/hollow/.
- Authored ground: data/environment/layouts/stage_3_rootbound_ground.tres; dedicated hollow_ground_tileset.tres has corrupted, living and mixed sources.
- Source/crops/exact prompt: art_source/generated/environment/forest/hollow_renewal_2026_10_03/.
- Offline builder: retired generation tool (recover from Git history only); --art-only -> Godot editor import -> normal bake. Reuses Stage I footprint/canopy authoring; rebakes replace existing Stage III props/ambience rather than accumulating them.
- Recovery: historical Git-only archive/stage_3_pre_renewal_2026_10_03/ (.gdignore). Shared old64px terrain/tree assets remain live in later stages; they must remain available.
- Native captures: historical Git-only review/environment/stage_3_renewal_2026_10_03/; rendered service/reward proof uses separate expedition_feedback_stage_3_2026_10_03/ evidence.

## Verification boundary

137 environment/navigation checks cover the32px grid, unchanged bounds/waves, every spawn/exit route, physical base/cutout, passable decoration, canopy restoration/fixed roots and actual bird animation. Stage III encounter checks cover west-incursion ratio, small seal,16px Husk path clearance, portrait pause/skip and canonical reward/portal gates.10 pressure checks cover18 real Rootling spawns plus one caster, a six-live cap, unchanged campaign resources, dialogue gate, solo280HP Husk and unchanged normal profile/backup/temp hashes after a save request. Husk combat behavior remains separately tested. Hollow audio passed18 headless/22 rendered lifecycle, gain, actual device playback and measured-bus checks; I/II navigation regressions passed183/178 checks.

The original rendered expedition integration passed95 checks; Decision171 now passes108 checks using an isolated profile and accelerated authoritative deaths. It checks actual chest F input, first/replay rewards, cap handling, clear music/ambience recovery, Sanctuary return, Nema craft, bag equip, Eira training and save/Continue. This does not establish normal fight/economy balance. Owner visual/listening review, full vulnerable combat and representative-phone performance remain open. Existing shared GPU texture/RID teardown warnings persist.

2026-10-13 maintenance: previous generation/comparison commands were retired; current output assets remain authoritative. New captures use ignored tmp/review/. See docs/maintenance/repository-cleanup.md.
