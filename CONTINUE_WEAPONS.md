# Continue current weapons

Updated2026-10-16. The owner provisionally accepts Decision224 Sword running and requests a natural grasp. Middle-leather grasp(10,66), a lower10-degree blade and foreground hilt/same-pose glove occlusion replace the rejected pommel-end(10,70) grasp. Accepted body poses and motion are unchanged. Grip review is pending. Up/down and all attacks/gameplay remain exact. Audit/prompts: art_source/reference/characters/king/sword-side-run.json. Test F5 → F9 → F7 → Weapons → King’s Sword.

 The owner provisionally settles the five current weapon families and requests cleanup before the next feature. Decision222 owns this closeout; preserve the current artwork and gameplay. Do not restart redesign by default.

## Current families

| Family | Current contract | Production artwork |
| --- | --- | --- |
| King's Sword |221 attacks/224 side run;3 cuts;1.76s | sword_unified |
| Iron Beard |213;5 cuts;3.19s | iron_beard_unified |
| Royal Greatsword |217 shoulder rest;4 cuts;2.16s | greatsword_unified |
| Twinsteel |219;5 cuts;2.20s | twinsteel_unified |
| Iron Reaper |206–209;throw/linger/return;2.59s | iron_reaper |

Artwork paths are under assets/characters/playable/king/. Runtime resources/scenes remain authority; nominal times exclude equipment speed, hitstop and player decisions.

Decision223 supersedes source retention in222. All305 generated source files and their image builders are deleted. Retain game-ready art, compact King references, two small motion/grounding audits, production hashes and licensed audio. Use temporary ignored generation staging for future work; publish approved outputs and clear staging. No permanent raw-generation archive is part of this project.

## Play and verify

F5 → F9 → F7 → Weapons selects all five in the real non-saving Combat Lab. WASD moves; held LMB repeats attacks; Space dodges; Tab opens the Bag; Escape closes panels. Dedicated launchers: launch_king_sword_training.ps1, launch_king_axe_training.ps1, launch_king_greatsword_training.ps1, launch_king_twinsteel_training.ps1 and launch_king_iron_reaper.ps1 under tools/.

Start with PROJECT_CONTEXT.md, ROADMAP.md and KNOWN_ISSUES.md. Use these current family guides under docs/design/: king-default-sword-unified.md, king-axe-cardinal-motion.md, king-greatsword-front-combo.md, king-twinsteel-motion.md and king-iron-reaper.md. Do not restore deleted preview builders or old head/body reuse.

The deleted image builders cannot be used to rebake old raw sheets. Current runtime assets and compact references are the baseline for future complete-pose artwork. Do not restore discarded source collections or anatomical fragments. Native review launchers remain available.

Read docs/maintenance/repository-cleanup.md for current retention and cleanup evidence. Run tools/check_project_resources.gd after editor import and tools/check_king_body.gd for immutable references. Native family/gameplay tests cover movement/walls, grip/steel/scale, combos, release/cancel, idle/retrieval, Bag/swap, skills and actual enemies. Technical tests do not authorize changing accepted artwork.

## Compatibility and remaining work

Canonical family routes: data/weapons/families/sword, iron_beard, royal_greatsword, twinsteel and iron_reaper. The stable saved Greatsword ID still ends in _v2; preserve it and the old-ID migration. No selectable Greatsword V1 remains. Older Sword/Spellward frames are live skill/reaction/Varkuun dependencies, not an archive. Frozen body_library/baseline references remain comparison assets, never anatomical fragments to paste into generated poses.

Next work: earned family recipes/acquisition through Nema and stage rewards, then intentional campaign role/balance tuning. F9 kit grants remain session-only. Greatsword has dedicated weighty contacts and a stronger jump smash; Reaper has dedicated throw/spin/catch audio. Preserve them. Real-enemy comparisons cover one/eight Rootlings and Armored Hog; phone, cold-load and very large horde profiling remain open. Sanctuary map stays hidden; six campaign stages are implemented. No commit/push unless the owner explicitly requests it.
