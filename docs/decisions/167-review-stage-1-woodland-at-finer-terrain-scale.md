# Decision 167: Review Stage I woodland at finer terrain scale

- Date: 2026-10-02
- Status: Implemented2026-10-02; owner accepted current visual direction2026-10-03. Combat/economy balance and phone profiling remain open.
- Source: Owner requested smaller obstacles/tiles and more ambient life for Stages I–VI, explicitly starting with Stage I for review before producing the rest.

## Decision

Use the accepted Sanctuary material/pixel style for Stage I: 32px baked terrain, compact generated woodland props, authored clear lanes, paired shrine markers, upper-foliage wind, player-aware canopy fading and bounded bird flights. Preserve the existing1920x1152 world and encounter/reward contracts. Prop collision/navigation is built from each physical base; small ground plants remain decorative.

Normal Stage I uses the pilot directly so F5 cannot silently show the old design. A no-save launcher opens the same scene peacefully and offers optional real waves with safe King. Preserve the previous scene/layout/navigation test in a Godot-ignored recovery archive. Shared old resources remain live for the other stages.

## Alternatives and consequences

Shrinking the entire stage would also change camera, travel, spawn and combat timing. A single painted backdrop would lose modular placement, collision and depth. Replacing every stage at once would prevent the owner's requested review gate. This pilot replaces only Stage I environment assets/layout and retains reusable native props and a diffable baked ground source.

Decision056's authored TileMap workflow remains. Stage I deliberately supersedes its shared64px forest pairing with a dedicated32px derivative of approved Sanctuary ground. Owner acceptance is recorded2026-10-03. Stage II is renewed under Decision168; III–VI remain unchanged until renewed individually; preserve the distinct existing biome progression. Whole-loop balance and phone profiling are separate follow-ups.

See [design, recovery and verification](../design/stage-1-woodland-renewal.md).
