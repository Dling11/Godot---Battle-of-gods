# 087 - Gate a reusable Combat Lab behind debug Admin Mode

## Status

Accepted on 2026-08-14.

## Context

Reviewing enemy art and attacks only through full stages makes iteration slow and obscures whether a defect belongs to the actor, encounter, environment, or progression. The focused Stage 5 arena proved the value of direct playable review, but one scene per enemy would duplicate setup and drift away from production behavior.

## Alternatives

- Continue building isolated scenes for individual enemies.
- Use headless tests and sprite previews without a playable simulator.
- Add a reusable lab that instantiates canonical runtime actors behind an explicit debug-only gate.

## Decision

Add session-only `DebugAdminState`. F10 toggles Admin Mode in debug builds and reveals a Sanctuary-side Combat Lab entrance; F7 enters or exits the lab. F8 retains the narrower Stage 5 arena while the same gate is active.

The Combat Lab composes the real player, navigation, projectiles, feedback, and canonical enemy scenes. It supports selected x1/x4/x8 spawns, enemy-target AI pause/resume, King invincibility, the authored unlimited-skill test kit, clear, reset, and health/status presentation. Before any lab enemy enters the tree, its reward component is removed. Lab entry suppresses autosave for the debug session.

## Consequences

- Owner and agent can reproduce actor defects immediately without replaying stages.
- Crowd, Elite, mini-boss, and boss behavior share one repeatable visual test surface.
- The simulator cannot grant XP, coins, materials, story progress, stage claims, or saved state.
- Admin Mode is not authentication or a shipping cheat menu; release builds reject it and no enabled state persists.
- Production encounters and focused automated tests remain authoritative for progression and correctness.
