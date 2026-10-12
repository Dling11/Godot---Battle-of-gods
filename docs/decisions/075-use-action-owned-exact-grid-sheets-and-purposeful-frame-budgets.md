# Decision 075: Use Action-Owned Exact-Grid Sheets and Purposeful Frame Budgets

- **Status:** Accepted
- **Date:** 2026-08-02
- **Related:** Decisions 033, 039-040, 073-074

## Context

Earlier character work exposed recurring failures: irregular generated strips were difficult to divide, frames changed apparent size or center after processing, feet jumped between cells, and chroma residue survived as visible lime/green pixels. Requiring eight frames for every idle and walk also encouraged filler without guaranteeing a correct gait.

The owner clarified that completeness and stability matter more than a fixed high frame count. Compact actions may use two to six meaningful poses where appropriate, while attacks and skills should receive the additional frames needed for anticipation, contact, recoil, follow-through, and recovery. Idle, walk, basic attacks, and each skill should not be baked into one unmanageable atlas.

## Alternatives

- Use one horizontal strip for every direction/action. Rejected as the default because very long strips are difficult to inspect and repair.
- Use one giant character atlas containing every action. Rejected because unrelated frame counts and cell sizes increase drift, empty space, and regeneration cost.
- Require eight or more frames for every animation. Rejected because duplicate or misaligned filler is worse than a smaller complete cycle.
- Import generated boards directly and repair offsets in Godot. Rejected because per-animation offsets hide inconsistent source art and make reuse fragile.

## Decision

Playable characters, enemies, and NPCs use one exact-grid PNG per coherent action family unless a documented asset-specific reason requires otherwise. For directional body sheets:

- rows use `down`, `left`, `right`, `up`;
- animation time advances across columns;
- every cell has one declared size;
- the full PNG dimensions equal cell size multiplied by column/row count;
- all frames share actor scale, foot baseline, pivot/center contract, palette, and lighting;
- body/weapon sheets remain separate from oversized VFX sheets.

Recommended King production ranges are purposeful rather than mandatory: idle 3-4 frames, walk 4 core gait frames with up to 6 when useful, dash 4-6, reactions 3-6, basic attack steps 8-12, charged attacks 12-14, defeat 8-12, and skills 8-24 according to their real phase count. No duplicated filler is required.

Generated boards remain source references until deterministic processing:

1. identifies or assembles each intended frame;
2. applies one approved scale per direction/action rather than fitting every cell independently;
3. aligns a shared foot midpoint and pivot;
4. preserves connected hands, grip, weapon length, and body height;
5. removes the source background before resampling;
6. emits binary alpha and rejects matte-color fringe or isolated residue;
7. packs exact cells into the action-owned sheet;
8. verifies occupied bounds and previews every animation at 1x and 960x540.

For King's up/back shoulder carry specifically, the sword-side arm must bend upward and the hand must visibly grip the hilt at shoulder height. A hanging sword-side hand with a blade emerging from the shoulder/back is rejected.

## Consequences

- King's previously proposed eight-frame idle/walk requirement is replaced by smaller purposeful ranges.
- King's first production artifact will be assembled only after each direction is approved through a small integrated review sheet; an irregular review strip is not itself runtime art.
- Walk, basic combo, dash, reactions, and each skill receive their own coherent sheets. Crescent and cinematic effects remain separate.
- Processors and tests must fail scale, center, baseline, grip, weapon-length, alpha, and source-background-residue violations instead of compensating with per-frame Godot offsets.
- The greatsword attack/VFX proof remains approved; the v1 turnaround's up/back pose is explicitly rejected and cannot enter production.

## Implementation Note

The first attempted artifact did not pass owner review. Although its layered processor made sword-axis measurements deterministic, the constructed weapon degraded the approved character art. The runtime sheets, processor, test, and preview are archived rather than accepted. Production therefore returns to integrated character/weapon review sheets, one direction/action at a time, before any exact-grid packer or `SpriteFrames` resource is created. This correction changes the implementation path without changing the decision's exact-grid, stable-anchor, purposeful-frame, or presentation/gameplay boundaries.

The replacement front/down source subsequently passed the processing gate. Only that direction is normalized: four distinct integrated frames in one `256x64` strip, with a shared 36-pixel full-silhouette scale, y=58 baseline, centered feet, binary alpha, compact shared palette, a single-animation preview, and focused validation. The remaining directions still require separate review sheets before a complete idle resource can exist.
