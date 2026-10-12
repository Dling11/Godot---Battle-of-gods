# Decision 198 — Start a fresh repository from the cleaned project

2026-10-13. Status: accepted by the owner.

## Context

The cleanup reduced current source to about 54 MiB, but normal clones of Dling11/godot-practice-first-game still include multi-gigabyte historical art. A tested depth-one clone is small, but the owner wants an ordinary clone to be small too and created Dling11/Godot---Battle-of-gods for that purpose.

## Decision

Publish only the cleaned tracked source in a new root commit on main to the verified-empty destination. Do not copy old Git objects, branches, tags, caches, exports, captures or local saves. Keep the existing project folder and active source/art files; build fresh metadata separately, preserve the original .git outside the workspace, then switch the folder's origin/upstream to the new repository after publication is verified. Preserve local agent exclusions and existing author/line-ending configuration.

Verify protected production assets, exact non-document source identity, all runtime dependencies, a normal GitHub clone and its Godot resource import/loading. Record actual clone storage; Godot's generated cache is separate. Use ordinary pushes only.

## Alternatives

- Depth-one clones of the original repository are already small, but require remembering a flag and leave the original normal-clone cost unchanged.
- Rewriting/force-pushing the original history could reduce its size but would disrupt existing checkouts. The owner selected a separate repository instead.
- Pushing the existing branch to the new repository would transfer its old parents/art history and fail the storage goal.

## Consequences

The new repository contains current supported game content and small future history. Earlier trials/commits remain recoverable from the original repository and separate local metadata backup. They are not accessible through the new main history. Future pushes use the new origin; importing legacy branches/tags would reintroduce the unwanted objects. The metadata backup still occupies local disk until the owner separately chooses to discard it.

See [repository migration](../maintenance/repository-migration.md).
