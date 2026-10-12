# Decision 174 - Upgrade the development engine to Godot 4.7.2

- Date: 2026-10-03
- Status: Accepted; supersedes Decision 005's exact 4.7 engine pin.

The owner requested the latest stable maintenance release in the existing installation folder, with backups and compatibility checks. Use standard Godot 4.7.2 stable; the project remains a game in active development, with the same Compatibility renderer and GDScript baseline. No gameplay systems or project feature flags are changed.

The installation is D:\WORK_APP\godot. Canonical 4.7.2 GUI/console executables are present. Existing Godot_v4.7-stable_win64.exe and Godot_v4.7-stable_win64_console.exe paths contain the same verified 4.7.2 binaries so shortcuts and launch scripts continue working. Their filenames are compatibility aliases, not reliable version indicators; use --version.

Backup and validation evidence: D:\WORK_APP\godot-backups\2026-10-03-pre-4.7.2-170917. engine-4.7 preserves the original pair; project preserves all 10,192 project files including uncommitted work and Git metadata; godot-user-data preserves editor settings and game saves. validation-project is a separate disposable test copy. Official release asset SHA256 matches GitHub's digest; the GUI executable has a valid Prehensile Tales B.V. signature. Source backup verification covered 1,415 script/scene/resource/document files. Production profile and recovery-save hashes remained unchanged after tests.

Godot 4.7.2 import, movement, melee combat and isolated save/Continue checks pass. Native rendered tests pass 72 title, 144 portal, 27 loading and 108 expedition/reward/service/save checks with zero assertion failures. The expedition test was completed with native rendering after the headless attempt did not complete; the stopped headless attempt is not a pass. Existing shutdown ObjectDB/texture RID warnings persist. Full-session balance, owner feel, exports and representative-phone profiling remain unverified. Export templates must match 4.7.2 when exports are prepared; this update did not install export templates.

Rollback: close all Godot processes, restore the two executables from engine-4.7 into D:\WORK_APP\godot, and launch the old GUI path. Keep the separate 4.7.2 executables unused during rollback. Restore project or saves only if needed, after preserving any work done since this snapshot. Do not overwrite newer game work with the snapshot as routine engine rollback.
Final launch verification: the real project reopened through the preserved executable path; the editor window is visible, unminimized and responding. Production save hashes remain unchanged after reopening.
