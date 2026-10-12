# Decision 165: Finalize the current Sanctuary and archive the legacy town

- Date: 2026-10-02
- Status: Implemented; Sanctuary temporarily complete for this development pass.
- Source: Owner requested cleanup, recoverable archiving of old code/design, and temporary Sanctuary closeout.

## Context

The renewed town worked only as a reversible no-save study layered over the old campaign scene. Normal Continue could therefore return to old art. Keeping both layouts also required duplicate assets, presentation snapshots, idle timers and obsolete comparison tests. Eira was provisionally passed and Nema's service audited before this closeout.

## Decision

Use the renewed town as the normal Sanctuary baseline. Compose it once through SanctuaryFlow under SanctuaryTown, with current NPC frames loaded by their own scenes. Remove old/new comparison, old town instances and restoration branches. Share NPC work/dialogue animation through a presentation component; retain service, collision, inventory, progression and save authority.

Normal entry heals and saves as before. No demo rewards or review controls appear in normal play. Debug entry and the existing launcher reuse this town and suppress saving before fixtures or controls become available.

Preserve retired code, art, sidecars, old tests and pre-closeout documentation in art_source/archive/sanctuary_retired_2026_10_02/, excluded from Godot import by .gdignore. Keep current source artwork, exact prompts, asset builders and meaningful regression tests. Consolidate the handoff instead of continuing to prepend conflicting instructions.

## Alternatives and consequences

Keeping the town as a study would preserve the duplicate runtime and old Continue behavior. Deleting history would lose recovery/provenance. Archiving while promoting the current version removes that duplication and keeps recovery possible.

This supersedes Decision 163's optional-only/compare boundary and Decision 164's study-only Eira placement. It does not approve every balance value or establish mobile performance. Further interiors, indoor audio and later campaign content stay deferred. Accepted King art/skills and current furniture scale remain unchanged.

Read ../design/sanctuary-closeout.md for controls, ownership, recovery and validation.
