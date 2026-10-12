# Eira training and Sanctuary NPC usability

Current runtime: 2026-10-02, Decisions164/165; temporarily complete for this pass. Owner requested Eira immediately to the RIGHT of the book, a useful service, clearer skill layout and a playable upgrade loop. Further houses/interiors remain deferred; retain approved furniture size and F-required doors.

## Placement and purpose

In the normal town Eira stands at **(384,410)**, directly beside the right edge of the lectern at (344,410), on the same foot baseline. Approach is (384,446); nameplate offset is (12,-62). The neighboring planter moves to (440,336), clearing her silhouette and label. Lamp stays at (456,432). Decision165 promotes this placement; old position/presentation are archived.

Eira is King's **Skill Mentor**. Expedition experience earns levels; return to Eira and press F, then finish/skip dialogue to open Training directly. Select a technique to see its role, current effect, next effect, required/current level and rank ladder. Training costs no coins/materials. Click Train once per rank; upgrades apply immediately and persist in normal play. All five base techniques remain learned from the start. Training improves them rather than adding duplicate equipped skills.

## Reachable curriculum

| Technique | Training levels | Result |
| --- | --- | --- |
| Earthsplitter | 2 | Fan: three spreading lanes and a stronger center follow-up, 228px final reach |
| Molten Crash | 3 / 6 / 9 | Advanced / Awakened / Mature: larger impact, then a delayed heat pulse and stronger center |
| Sovereign Pursuit | 5 / 8 | Two / three independently aimed uses, 250 / 280px reach |
| Unbroken Vow | 7 / 10 | Stronger shield and offense; movement bonus; Mature empowers the third basic strike |
| Worldsplitter | 8 / 10 | Two / three fresh summoned blades, 600 / 700% total weapon damage |

The current cap remains Level 10. Worldsplitter's former 10/15 gates are superseded; existing trained ranks remain valid. Earthsplitter Cascade stays a Lab alternative, not a higher campaign rank. Accepted combat artwork, animations, cooldowns and per-form tuning are reused.

## Training and Loadout

The themed 860x480 modal fits native 960x540. Eira portrait/header explain her purpose. Training and Loadout are distinct tabs; five icon-bounded techniques stay in core order at left. The right pane shows role/current effect, rank ladder and one training action, or ten combat slots in two rows of five. No currency selector or extra purchase screen is introduced.

In Loadout select a technique, then click a slot. Occupied slots swap; right-click or Clear selected slot clears. Restore core layout returns learned core techniques to 1-5. Visible result text and library events update the menu and live HUD immediately; keyboard focus survives rebuilds.

Tab -> Active Skills -> ARRANGE SKILLS opens ordinary Loadout. Its Training tab explains requirements but cannot upgrade remotely. Esc closes Eira's direct modal and resumes play. When arranging from ordinary inventory, Esc returns to inventory; a second Esc resumes play. The shared CharacterMenu retains bounded 24px icons and separate disabled future tiers.

## Authority and persistence

KingTrainingCatalog owns names, rank fields, gates and benefit copy. KingSkillLibrary validates trainer access, current level, Sanctuary/busy guards and rank limits. It saves the new session rank, rolls it back on failed save, then applies the real definition/hitbox and refreshes without replacing custom hotkeys. RunSession stores optional Earthsplitter/Molten ranks alongside existing fields. Legacy version-1 profiles default missing fields to Foundation; malformed ranks are rejected. Lab selectors do not train or save.

Explicit debug review suppresses profile writes for the whole process. Training/loadout changes there work in memory and reset when closed. Normal progression is untouched by the optional Level-10 training demo.

## Test routes and evidence

- F5 -> Continue -> walk to Eira or select her in the M map -> F -> finish/skip dialogue -> Training. Switch to Loadout to arrange.
- Immediate all-rank testing: `powershell -NoProfile -ExecutionPolicy Bypass -File ./tools/launch_sanctuary_study.ps1 -TrainingDemo`. This opens at Eira with temporary Level 10 and saves suppressed.
- Direct Godot script accepts `-- --eira --training-demo`. `-Eira` on the PowerShell launcher visits her without granting demo levels.

Native captures: `art_source/review/ui/eira_training_v2_2026_10_02/`. Existing generated frames/portrait/icons are reused; no artwork was generated this pass. Earlier evidence remains preserved.

Verified: 84 rendered functional checks cover physical F, right-edge/name separation, direct entry, every real upgrade-button click, all five completed rank ladders, pointer swaps/clears/core restore, HUD updates, focus and pause cleanup. 91 curriculum checks cover exact level/access gates, rank limits, real form/hitbox application, custom-layout preservation, legacy/malformed snapshots, save/reload and restored Fan/Mature casts with the single aftershock. 64 rendered interface, 94 headless study, 14 Worldsplitter trainer, 14 Vow trainer and 49 combined Vow/Worldsplitter combat checks pass; CharacterMenu, Pursuit trainer, run progression and production kit smoke pass. Existing GPU shutdown texture warnings remain.

Owner provisionally passed Eira on 2026-10-02; full balance and representative-phone profiling remain open. Nema was subsequently considered clear/accurate and audited rather than redesigned; player HP/growth/bag work and the small Nema corrections are in player-interface-readability.md. Umi gets targeted observed feedback; deliberate town-art promotion remains separate.
Closeout: docs/design/sanctuary-closeout.md owns normal-town/archive status. Further NPC redesign is deferred; next work is expedition objective/reward feedback.
