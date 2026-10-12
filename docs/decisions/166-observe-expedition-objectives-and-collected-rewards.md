# Decision 166: Observe expedition progress and collected rewards

- Date: 2026-10-02
- Status: Implemented; owner runtime review remains open.
- Source: Owner approved the proposed expedition objectives, reward feedback and fight-to-town service verification after accepting the compact HUD and centered paperdoll.

## Context

The six implemented stages granted progression/materials and opened exits, but players lacked a persistent account of queued enemies, required chest claims, collected rewards and newly available services. Sanctuary's completed presentation should now support a understandable expedition loop.

## Decision

Expose event-driven encounter snapshots and actual credited progression deltas; observe existing loot grants in a stage-local presentation ledger. Use the approved gold/violet frame for a compact objective tracker and opt-in completion receipt. Required Stage III/V claims retain F, first-clear/replay and banking authority. Receipts display credited amounts rather than nominal enemy rewards or authored chest guarantees.

Offer Keep Exploring and a voluntary Return to Sanctuary after a completed, banked expedition while preserving F at the forward portal. Revalidate completion, alive state and bank status in a shared travel helper; UI does not commit rewards or grant progression. Keep normal saving and full-health Sanctuary entry.

## Alternatives and consequences

An automatic popup would interrupt boss farewell/collapse and late pickups. Computing rewards from definitions would misreport caps, replay and inventory overflow. Replacing loot or NPC service authority would expand this presentation pass unnecessarily. The opt-in ledger preserves those systems, allows remaining drops to be collected and has no persistence of its own.

All current root flows install the shared presenter; Stage V supplies explicit boss milestones. Later content must expose its own authoritative completion contract. No new rewards, Hunts or economy rebalance are included. Rendered integration uses isolated saving and explicit fixtures; representative-phone testing and owner feel remain open.

See [design and verification](../design/expedition-objectives-and-receipts.md).
