# Known Issues

Updated 2026-10-14. Historical fixed bugs and rejected art trials were removed from this active list. Runtime code remains the authority.

- **Weapon acquisition/balance:** debug equipment availability does not establish campaign crafting/unlock rules. Compare reach, damage, knockback, recovery and incoming pressure before retuning. Iron Reaper is selected but not implemented.
- **Performance:** prior short desktop samples are not phone/cold-load/stress guarantees. Keep event/phase-driven presentation; profile crowded fights and skill1 feedback on target devices.
- **Campaign completeness:** production route reaches VI. StagesVII onward, divine/domain rewards and Stage XX routing are not implemented; Examiner remains an isolated Lab trial.
- **Progression/economy:** later skill forms are Lab experiments; campaign unlock/persistence and Nema/Umi resource/gold pacing need full fresh-save measurements. Accessories and later gear remain incomplete.
- **Encounter feel:** Stage VI mixed Bear/Hog/Spitter composition, anti-stunlock breakouts and final boss survival need owner testing across no-armor/starter/crafted builds.
- **Presentation:** Sanctuary map is intentionally hidden. Portal tier dominance, actor occlusion and full moving-camera readability still need owner-scale review; cleanup changes no portal art/physics.
- **Regression fixtures:** 54 of 134 retained smoke scripts emit ObjectDB/resource exit warnings despite passing assertions. All134 currently pass assertions and all 868 resources load. Treat those passes and clean teardown separately; see cleanup verification for exact results.
- **Legacy Git storage:** old art history stays in Dling11/godot-practice-first-game and the separate local metadata backup. The new Dling11/Godot---Battle-of-gods repository starts from cleaned source and does not require a shallow clone to avoid that history. Do not push old branches/tags into it. Godot cache and local test captures are separate from clone size.
- **Distribution:** the lightweight ZIP is a Godot source project. A standalone executable/export is not yet validated by this cleanup. Saves are local and excluded.

Current cleanup scope/results are recorded in docs/maintenance/repository-cleanup.md. No archive dependency should remain in supported tools/tests.
