# Eastern Rot renewal and Rotcaller combat trial

2026-10-03, Decisions170–171. **Normal Stage IV is renewed and now includes campaign Rotcallers.** The isolated no-save trial remains available; Hunts remain planned. See [current campaign, V renewal and next work](stage-5-renewal-and-combat-polish.md).

## Normal Eastern Rot

The living western grove meets pale fungal ash, fallen roots and old gateway rubble on the eastern edge. Eight generated families supply70 authored placements. Ground uses1344 baked32px cells across the unchanged1536x896 world.848 cells remain entirely living,440 are decayed, and56 mix the two over a64px irregular boundary:36.90% affected, matching the previous eastern share. The southern approach, central crossing, western trail and gateway lane remain readable.

Ferns/fungi are passable. Compact roots, rubble and tree bases collide; crowns sway while their bases stay fixed and fade behind King. Birds stay in the living west. The gateway has two separate16x20 pillar bodies at x±44, each with its own navigation cutout. Combining them into one collision-derived convex hull would obstruct the opening. Navigation bakes12px clearance and is tested with9px Hog feet.

Five waves now use totals8/10/12/14/16, Hogs1/1/2/2/2, one Rotcaller in waves2–5,60 enemies overall and an eight-live ceiling. Existing Hog guard/charge/recovery, completion rewards, story flag, Boss-tier F portal into Stage V and normal saves remain authoritative.

Scene-owned positional beds at western(448,440) and eastern(1280,440) blend recorded birds into hollow wind as the listener moves east. Each owns sparse local calls/creaks; combat reduces ambience6dB and actual clear restores it. The newly attributed Dark Forest Theme recording uses exploration/combat/clear gains−16/−13/−17dB through AudioDirector's single player. Recordings are reused from the attributed CC0 I/III assets; no new composition is claimed.

## Playable Rotcaller prototype

The first trial has **one Rotcaller plus two Rootlings**, using three normal wave slots. A separate Spitter toggle resets into a four-slot comparison. King starts at full health and is vulnerable by default; optional safety is explicitly labelled. Reset after defeat creates a fresh Player. Trial rewards, drops, story milestones, chest/portal completion and saving are disabled.

Rotcaller navigates on normal ground with8px feet and real four-direction, four-pose walking. Walking animation follows actual displacement; it stops while casting or blocked. Generated staff-rise, release, struck/recovery and fallen death poses share a64px canvas, fixed foot baseline and approximately40px native walk height. Decision171 replaces walking with clearer articulated knees/feet, consistent staffs, two-frame staff-rise anticipation and the established one-texel King outline. The down-facing strip combines dedicated opposite-step sources. A cropped idle frame supplies the roster portrait.

| Prototype rule | Current value |
|---|---|
| Health / movement |55HP /46px per second |
| Cast reach |180px, clear solid-world sightline |
| Preparation |1.1s; compact cast hint and32px-radius ground ring |
| Target |King's fixed position when preparation starts; marker never chases |
| Contact |One10-damage base contact over .35s; ordinary mitigation/i-frames apply |
| Counter |Accepted damaging hits during preparation cancel the ring; blocked hits do not |
| Punish window | .8s recovery after release or interruption; longer hard stun remains respected |
| Cadence |At least5s between preparations; failed placement retries at .3s |

Navigation and a physical circle query reject disconnected/out-of-bounds centers and solid overlaps. The trial has no service/chest/portal objects. Current finite campaign waves spawn those objects only after all casters die; Stage V places no service in the active approach. Persistent Hunts/scouts still need explicit service-space exclusions. Pause freezes preparation/contact/recovery. Death of caster or target cancels an unfinished warning. Lethal cancellation is separate from the nonlethal interruption counter. One zone per caster prevents stacked pending markers. Authority owns state/contacts; animation, warning drawing and reused quiet root-creak/jab sounds observe signals.

`RotcallerDefinition` supplies tuning; the actor composes existing health, hurtbox, footprint, separation, navigation, stagger and knockback components. Generic `EncounterSpawnEntryDefinition` spawns the caster. Trial setup replaces root flow/controller scripts before tree entry and preserves scene export references; a pre-ready enemy preparation hook removes reward observers. The controller's trial completion overrides only grants/portal behavior, retaining normal spawn/death/slot accounting.

## Ready owner test

Run `powershell -NoProfile -ExecutionPolicy Bypass -File ./tools/launch_stage_4_renewal.ps1`.

The environment opens peacefully with safe King. Arrival/Living west/Eastern gateway/Overview inspect the layout. Start normal waves runs the canonical Stage IV encounter. Outdoor sound and Local wood creak expose its regional sound layers.

Click **Try Rotcaller → Start trial**. Use WASD, the normal sword attack and current skills. Hit the caster while **INTERRUPT CAST** is visible, or leave the ring. Successful interruptions update the counter. **Reset trial** restores full health; **Spitter** starts a fresh selected comparison; **King safe** controls real damage immunity; **Stage IV environment** switches back. Tab/Esc use normal bag/pause menus. Review controls remain responsive during hitstop and hide while either modal is open. Closing and restarting normal F5 restores ordinary saving.

Direct trial entry: `Godot --path . --script res://tools/launch_stage_4_renewal.gd -- --trial`. The dedicated trial is separate from the general F7 Combat Lab.

## Verification and boundaries

- Stage IV environment/navigation:153 checks, including every spawn/exit, collision-derived cutouts, Hog-sized routes, gateway opening, canopy fade and animated birds. Canonical Stage IV resource smoke and Hog art/guard/charge/recovery smoke pass.
- Rotcaller: initial36 headless, now47 rendered checks cover real Player sword interruption, fixed marker, accepted/blocked damage, recovery, pause, one contact, leaving the marker, navigation exclusions, actual animated movement, four directions, death/defeated-target cancellation, three/four slots and no campaign grants. Native47 includes seven image captures; the separate review also captures its controls.
- Review UI:18 rendered checks cover real clicks, vulnerable entry, death/reset/full HP, Spitter, immunity, Tab/Esc ownership and return to canonical IV.
- Regional audio: initial21 headless, now27 device-rendered checks. Real clear/reward/receipt/Sanctuary return/isolated save/Continue plus existing NPC services:108 rendered checks. Stage III navigation137 and pressure10 remain passing.

Native evidence is under `art_source/review/environment/stage_4_renewal_2026_10_03/`, `art_source/review/characters/rotcaller_2026_10_03/` and `art_source/review/ui/expedition_feedback_stage_4_2026_10_03/`. Previous Stage IV scene/layout/test remain in the Godot-ignored recovery archive. Shared coarse textures remain live in the separate legacy boss proof and VI and are not deleted.

Owner visual/listening acceptance, minimum-gear difficulty, final balance and phone profiling remain open. Revised directional poses are implemented but await owner acceptance. Stage V renewal is implemented; VI, Burrowkin, scout/reactions, interactable lore/cache/breakables and Hunts remain planned. Known shared GPU texture/RID shutdown warnings persist; successful assertions do not claim those resolved.
