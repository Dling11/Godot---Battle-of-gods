# Fresh repository baseline — 2026-10-13

The owner created [Dling11/Godot---Battle-of-gods](https://github.com/Dling11/Godot---Battle-of-gods) to make an ordinary clone small. Decision 198 owns this change. The new baseline starts from the cleaned tracked source at original commit 1c635ab551ed8218516e8789d3912d05ecc23c40, plus repository/setup documentation changes.

The original [Dling11/godot-practice-first-game](https://github.com/Dling11/godot-practice-first-game) remains available with the old art history and seven cleanup commits. Its history is not imported into the new repository. No force-push or old-repository history rewrite is performed.

## Clone and play

~~~bash
git clone https://github.com/Dling11/Godot---Battle-of-gods.git
~~~

An ordinary clone is sufficient; no depth flag is needed to exclude the original history. Install Godot 4.7.2 standard, import project.godot, wait for resource import and press F5. Godot cache grows locally; player saves are not transferred by Git.

## Same-folder continuity

The current D:/React_ONLY_2026/GODOT-BATTLE-OF-GODS folder keeps its active source, art, editor state and cache. Fresh Git metadata is prepared separately using an explicit current-source manifest and published to the empty destination. The original metadata is preserved outside the project before the new metadata replaces it. Local AGENTS.md/AI_NOTES.md exclusions and author/line-ending settings remain local. Private user saves and ignored captures/packages are excluded.

Do not attach/push legacy refs into the new origin: their old objects would restore the large clone cost. Recover a needed old file from the original repository individually.

## Verification

Publication and normal-clone measurements are recorded when the final migration checks finish. The existing full-suite cleanup evidence remains in cleanup-tests-2026-10-13.json; this migration changes repository metadata/documentation, not combat, art or balance. Fresh-clone resource/import validation is additional evidence, not new owner visual approval.
