# Decision 094: Move Stage 5 Into a Scrolling Dead-Forest Route

## Status

Accepted — 2026-08-14; Sanctuary destination superseded by Decision 129

## Context

The isolated boss proof established combat and the basin palette, but it was not a production level. Stage 5 needs real traversal from Stage 4, an environmental approach that communicates complete forest death, boundary scenery that feels authored rather than randomly scattered, and a clean seam before the boss entrance package is added.

The owner also rejected the former standalone root-stump asset and asked for unmistakable dead trees, fallen remains, a dead animal with moving flies, and dense tree coverage specifically along the map edges.

## Decision

Add `levels/stage_5/stage_5.tscn` as the production Stage 5 route. It uses one authored 24-by-18 full-decay TileMap, the shared Stage 4 gateway as its southern arrival landmark, a traversable central approach, and the existing boss controller in a separate northern basin. Crossing one basin threshold activates and binds the boss; it cannot chase King through the approach beforehand.

The outer map boundary uses eighteen deliberately placed instances of one reusable three-tree edge-thicket scene. Every group is rooted at or partly beyond one of the four playable-map boundaries; scale and mirroring vary predictably while the central approach remains open. Individual tall trees, snags, fallen trunks, and uprooted logs break repetition inside the boundary. One deliberately tiny, non-graphic pixel carrion detail supplies environmental consequence without realistic anatomy, with four tween-driven fly dots as separate presentation.

Delete the rejected `stage_5_dead_tree_source_v1.png` family completely: generated source, cleaned source, runtime texture/import, review image, scene, processor references, and live instances.

Stage 4's post-clear gateway now targets production Stage 5. Defeating the Stage 5 boss commits the current expedition, records provisional Stage 5 story/boss/discovery IDs, saves, and creates a Sanctuary return ring. This route integration does not invent the final boss name, entrance dialogue, dedicated music/audio, core-gear reward, or later anonymous-power event.

## Consequences

- Stage 5 is now a real scrolling route rather than only a debug-room composition.
- Dense dead trees occupy the edges as intentional boundary language without filling attack lanes randomly.
- The boss basin remains readable and the boss cannot engage prematurely.
- The rejected stump cannot return through processor regeneration or stale scene references.
- Reward/lore/audio work remains explicit follow-up rather than being hidden inside map integration.
