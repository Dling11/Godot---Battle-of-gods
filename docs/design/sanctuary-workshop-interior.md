# Orren workshop interior

2026-10-02. One current interior is part of normal Sanctuary under Decision165. Further rooms are deferred. See [closeout](sanctuary-closeout.md). Earlier oversized-room/comparison history is archived.

Approach the workshop door and press F at the prompt. Walking alone never transfers. WASD walks, right-click routes around furniture, F inspects bench/forge/rack, and F at the south opening returns. The same Player, health, gear and services remain; no extra Orren shop or reward authority is added.

Retain the owner's provisionally accepted furniture scale relative to unchanged King. Separate overhead floor/wall, workbench, forge and rack sprites live under assets/environment/sanctuary/interiors/orren/v2/. Oversized predecessors are archived. Shared measured footprints drive physics/navigation; furniture sorts at its feet and bounded embers add motion.

levels/sanctuary/town/workshop_visit.gd owns F prompts, validated transfer/inspection/return. It cancels stale click movement and snapshots/restores bounds, camera and navigation tolerance. workshop_interior.gd owns room composition/footprints. Region/collision disable outside visits. Town-map selection survives suspension; indoor/modal headers stay unobstructed. Debug visit controls return King outdoors first.

Normal saving remains active. Explicit no-save launchers/F10 keep suppression until restart. Visit state is transient; Continue returns to the Sanctuary checkpoint.

Builder: retired generation tool (recover from Git history only); sources/prompts: art_source/generated/environment/sanctuary/. Retained tests cover physical doorway F, near-threshold entry, furniture/mouse routes, inspection/pause/inventory and safe return. Indoor audio, phone profiling and further rooms are deferred.

2026-10-13 maintenance: previous generation/comparison commands were retired; current output assets remain authoritative. New captures use ignored tmp/review/. See docs/maintenance/repository-cleanup.md.
