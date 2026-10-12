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

The clean root commit is 29a52973b0c2d3b8e868fe3dcf5ebff777e111ef. An ordinary GitHub clone of that baseline contains one commit and 2,815 tracked files, with no original history. Before opening Godot it occupies 107,859,033 bytes (107.9 MB / 102.9 MiB), including 51,286,371 bytes of Git metadata. After fresh Godot import/resource verification it occupies 145,831,376 bytes (145.8 MB / 139.1 MiB); exact measurements are in repository-migration-2026-10-13.json. Generated cache can grow during later play/editor use. A small subsequent documentation commit records these results.

All 2,559 non-document Git blobs match the previous cleaned baseline exactly. All 646 protected asset hashes remain unchanged. Godot 4.7.2 fresh editor import completed without errors; the fresh clone loaded all 868 supported resources with zero failures. The original remote main still points to 1c635ab551ed8218516e8789d3912d05ecc23c40. That original commit object is absent from the fresh local metadata.

The original metadata is preserved at D:/React_ONLY_2026/GODOT-BATTLE-OF-GODS-git-history-backup-2026-10-13-PSMN3a/.git; its HEAD matches the original cleaned commit. The active project folder now uses the new origin/main, while local agent exclusions and author/line-ending settings are preserved. This backup retains old-history disk usage separately; it is not sent to new clones.

The existing full-suite cleanup evidence remains in cleanup-tests-2026-10-13.json; this migration changes repository metadata/documentation, not combat, art or balance. Fresh-clone resource/import validation is additional evidence, not new owner visual approval.
