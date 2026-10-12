# King impact, typed damage and counter review

2026-10-04. Decision178. **Delivered:** approved damage families/resistance, matching skill and gear copy, Hog brace metadata repair, larger red critical digits and a registered four-frame critical burst in normal gameplay. **Playable comparison only:** perfect-dodge counter and 36/42px basic sword reach. **Planned:** further third-cut material/audio polish, one authored elite break experiment and representative cold campaign/GPU/phone profiling.

## Damage rules in normal gameplay

| Family | Reduction | Normal digits |
|---|---|---|
| Physical | `raw × 100/(100+armor) × (1-ward)` | Ivory |
| Magic | `raw × 100/(100+magic resistance) × (1-ward)` | Cool blue |
| Pure | Bypasses armor, magic resistance and ward | Pale violet |

Resistance cannot be negative; universal ward remains capped at75%. Guard, temporary shields and normal invulnerability still apply to pure. Debug/cinematic immunity remains absolute. Missing/invalid type metadata defaults to physical, preserving existing callers. No mana system or new saved type field is introduced.

| King's action | Active type |
|---|---|
| Basic sword | Physical |
| Slot1 Earthsplitter, all waves/forms | Physical |
| Slot2 Molten Crash, including later heat pulse | Magic |
| Slot3 Sovereign Pursuit landing | Physical |
| Slot4 Unbroken Vow | Self buff |
| Slot5 Worldsplitter, every ranked plunge | Magic |

Rotcaller ground spells are magic. Other legacy enemy contacts remain physical. Crag Bear/Varkuun/Examiner start with magic resistance12/30/38, matching existing armor. Heartwood Plate supplies30 armor and30 magic resistance; its summary/comparison/synergy explains both. This preserves current spell-versus-armored-target and Rotcaller-versus-geared-King mitigation while allowing future profiles to differ deliberately. Existing damage multipliers are unchanged. Pure remains rare; Worldsplitter's520–700% budget is not pure.

Metadata drives training cards, details, loadout tooltips and weapon summaries. Color supplements labels. Critical is independent: any family can crit if its profile permits it. Type never grants stun, flinch duration or knockback.

## Critical presentation delivered

Normal digits remain11px. Critical digits use duplicated17px LabelSettings, measured centering, dark outline and red `CRIT` text. Shared settings masked the old font-size theme override. White base font color preserves type/red tint.

Critical contacts replace the ordinary burst with four generated scarlet/ivory drawings: tight contact, broken-X pressure, fragments and remnant. Original source/exact prompt are retained under art_source/generated/vfx/critical_impact_2026_10_04/. Offline retired generation tool (recover from Git history only) registers a common(24,24) contact anchor in48px cells using one0.075 nearest scale and binary alpha. Source cells are543x724; their layout is not assumed square. registration.json records anchors/crops/visible bounds. Runtime assets/vfx/combat/critical_impact/frames.tres shares one192x48 atlas,25fps,nonloop0.16s. No per-target sheet generation or added global freeze.

Roll once per swing/strike and preserve deduplication. Only accepted contacts show feedback; artwork never schedules damage. Starter King's Sword still has0% base crit; Varkuun Edge remains8% at1.5x. The review visibly labels50% test chance. Shared camera/audio/hitstop stays bounded per swing; Earthsplitter owns sequence feedback without per-victim global pauses. Hog brace preserves type/crit/accepted amount instead of reconstructing a stripped payload; frontal reduction and hard-stun rejection remain.

## Playable counter/reach comparison

Run `powershell -ExecutionPolicy Bypass -File .\tools\launch_combat_impact_review.ps1` from the repository. Real Stage IV is rewardless, with isolated storage and suppressed autosaves. Default King is vulnerable, counter on, current36px reach and labelled50% test criticals. WASD, left-click attack, Space dodge,1/2/3/5 skills, Tab bag, Esc pause.

Buttons compare authored/forced physical/magic/pure, authored defenses/100 armor/100 magic resistance/50% ward, weapon versus50% crit,36px versus42px forward reach (same44px width), counter on/off and vulnerable/safe King. Spawn one Rootling or eight foes including one Rotcaller. Reset to repeat. Comparison clones restore authored tuning without mutating production assets/saves.

PerfectDodgeCounter is installed **only here**, not on production Player:

- Actual enemy damage rejected by dash invulnerability in the first0.12s awards a0.75s opportunity. Empty/late dashes, self damage and debug immunity cannot farm it. Runtime EnemyDefinition identifies real enemy sources; no nonexistent scene group is required.
- Next basic attack snapshots pure damage and an additive+25% weapon multiplier. First accepted positive-damage contact consumes readiness; all targets in that committed cleave retain the same type. No automatic stun or longer displacement.
- Misses may retry before expiry. Same-dash crowd contacts cannot refresh it. Taking health damage or defeat clears it. Physics Timers inherit pause; a small lavender `PURE COUNTER` label observes readiness without idle per-frame work.
- Dodge movement, invulnerability and cooldown remain unchanged. Resolve, Vow and Pursuit-link modifiers are independent. Counter/reach require owner feel/balance review before production promotion.

## Evidence and limits

Native Godot4.7.2 Compatibility/OpenGL review46/0 covers actual typed sword contacts/HP values/colors, four shared48px binary-alpha frames/captures, tuning restoration and an actual early-dodged Rootling jab. Typed authority50/0 covers100 raw →40 physical/20 magic/100 pure under armor100/MR300/ward20%, shield/guard/immunity, Hog metadata, real Foundation wave/Mature heat/Mature descent contacts and equipped Heartwood defenses/copy. Counter25/0 covers commitment, deduplication, consumption, misses/expiry, pause and farming protections. Existing critical authority, armor, Hog/control, Pursuit charges, Sanctuary training73 headless/84 native, Worldsplitter118 and Vow/Worldsplitter49 regressions pass. Rotcaller40 headless checks pass after awaiting actual materialized arrivals.

Short native Stage IV measurements: fresh process per batch, moving Rootlings plus one Rotcaller for>=3, vulnerable stationary high-HP King, real terrain/AI/feedback, no grants.

| Foes | First/repeat contacts | First/repeat physics peak | First/repeat frame p95 |
|---|---|---|---|
|1|1/1|3.077/2.819ms|14.372/14.317ms|
|5|5/5|4.456/3.601ms|14.700/15.004ms|
|8|7/8|3.884/3.874ms|14.947/14.843ms|

Baseline median frames are about13.3ms on this desktop, including display pacing. Eight-foe first cast: moving AI leaves one actor outside the lane; counts are measured, not promised hits on every moving actor. Incoming10-damage attacks produce normal player-hurt hitstop: one pause in5/8 samples and one1-foe repeat. Earthsplitter requests no per-target pause. These samples did not reproduce the historical16.82ms physics spike; they do not close cold-loading/allocation/GPU/phone performance. No speculative pooling was added. Existing shutdown-resource warnings remain.

Native screenshots/logs/JSON: historical Git-only review/combat/critical_impact_2026_10_04/. Earlier19/27 Varkuun captures and later20/24 runs are distinct measurements; damage random rolls need not match between runs. Raster/native frames were inspected; final owner art/feel acceptance remains open.

## Next work

Owner's subsequent feedback authorizes five visible weapon families, armor and helmets. Read [King weapon families and basic-hit redesign](king-weapon-family-and-basic-hit-redesign.md) and Decision179. Six generated concept studies are complete; runtime presentation is pending. Current integrated signature sword and Stage10 rewards remain unchanged. Prove one registered short attack before producing a full family set.

Owner plays the counter/reach comparison; choose promotion/timing after evaluating whiffs, input feel, horde counter access and damage versus defenses. Continue third-cut material/audio weight without automatically increasing existing165% damage/200% knockback or adding stun. Opt-in elite pressure/break remains planned: designated finishers/counters build pressure, eligible attacks expose a brief break, and post-break resistance prevents locks. Bosses stay immune unless a fight authors an opening. Charged-hold input is separate future work. Preserve accepted King body, targeting circle, loading/title/portals and normal profiles.

2026-10-13 maintenance: previous generation/comparison commands were retired; current output assets remain authoritative. New captures use ignored tmp/review/. See docs/maintenance/repository-cleanup.md.
