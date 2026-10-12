# Decision 124: Establish Stage VI with Monumental Depth Before Enemies

- **Status:** Partially superseded by Decision 125
- **Date:** 2026-08-24

## Context

> Decision 125 preserves this decision's environment-before-enemies sequencing
> but replaces the distant canyon and monumental threshold with a modular
> top-down upper terrace, cliff boundary, trees, rocks, and waterfall.

Stages I-V communicate the Forest arc through authored ground and local props,
but Stage VI needs a visible production leap rather than another rectangular
field populated by random trees. Enemy roles are not yet locked, so terrain
must first establish their future lanes, silhouettes, and encounter scale.

## Alternatives

1. Reuse the existing bright Forest TileSet and add more tree instances.
2. Bake one complete illustration as the playable surface and infer collision
   from its pixels.
3. Compose a generated distant vista and landmark over authored, separately
   collidable terrain with explicit transparent canyon cells.

## Decision

Choose Alternative 3.

- Stage VI's working title is `The Elder Ascent`.
- Its environment foundation uses a colossal living-root canyon, misty depth,
  pale ruined terraces, restrained teal ground, and one asymmetric root-and-
  stone threshold with a wide traversable opening.
- The generated backdrop and landmark are presentation. Authored TileMap cells,
  stable collision, and future navigation remain gameplay authority.
- `AuthoredGroundLayout.empty_tile_keys` supports deliberate absent cells so a
  map can reveal a real background without runtime random fill.
- The threshold separates grounded feet from an overhead crown. The feet own
  collision while the crown supplies foreground occlusion.
- The current scene is an environment preview only. It is accessible through
  debug Admin Mode and is not connected to Stage V progression, encounters,
  rewards, saves, or Stage VI completion.
- Stage VI enemies remain a separate decision. They may not reuse Mirelings or
  Rootlings in forward campaign progression and may not hard-gate entry on gear.

## Consequences

- Stage VI can be reviewed at gameplay scale before enemy art or balance is
  generated around the wrong terrain.
- The map now has a reusable authored-background seam instead of treating every
  combat stage as an opaque rectangle.
- Future enemy design must respect the wide terrace lanes and monumental
  threshold rather than filling the map with arbitrary blockers.
- The new background/collision contract requires focused structural and live
  movement review before campaign integration.
