# Archived Decisions 001-025

This is the architecture and product decision record. Decision IDs are permanent. Do not renumber deleted or superseded decisions; mark them superseded and link the replacement.

Each new major decision should include: date, status, context, decision, alternatives considered, consequences, and follow-up.

## Decision 001 - Repository Documentation Is Persistent Project Memory

- **Date:** 2026-07-11
- **Status:** Accepted

### Context

The project is intended for long-term development across multiple human and AI sessions. Conversation history alone is not a reliable or reviewable source of truth.

### Decision

Maintain `README.md`, `GAME_DESIGN.md`, `ARCHITECTURE.md`, `STYLE_GUIDE.md`, `ROADMAP.md`, `CHANGELOG.md`, `KNOWN_ISSUES.md`, and this decision log alongside the code. Contributors should read and maintain the relevant sources of truth.

### Alternatives Considered

- Rely on chat history or external memory.
- Keep a single large project document.
- Document only after implementation is mature.

### Consequences

- Decisions and status remain reviewable in version control.
- Feature work includes small documentation maintenance overhead.
- Documents must distinguish current implementation from planned direction to avoid false confidence.

### Follow-up

Review documentation during every major feature and release milestone.

## Decision 002 - Prefer Composition and Data-Driven Content

- **Date:** 2026-07-11
- **Status:** Proposed; validate during the combat prototype

### Context

The game needs many weapons, enemies, bosses, abilities, and status effects without creating brittle inheritance trees or duplicated logic.

### Decision

Prefer reusable components for capabilities and custom Godot resources for shared content definitions. Actors coordinate components. Per-instance mutable state remains outside shared definition resources.

### Alternatives Considered

- Deep actor and weapon inheritance hierarchies.
- One bespoke script per entity or weapon.
- A single universal gameplay manager.

### Consequences

- Behaviors can be combined and tested independently.
- Scene composition and ownership require clear conventions.
- Excessively granular components can add indirection, so extraction should follow real reuse or boundary needs.

### Follow-up

Accept, amend, or reject this proposal after implementing the first player, enemy, weapon, and status interaction.

## Decision 003 - Preserve Authority Boundaries Without Premature Networking

- **Date:** 2026-07-11
- **Status:** Accepted

### Context

Multiplayer may be explored later, but building a full network abstraction before validating single-player combat would slow development and obscure gameplay iteration.

### Decision

Build single-player first while separating input intent, authoritative gameplay state changes, and presentation. Do not add networking code until multiplayer becomes an approved milestone.

### Alternatives Considered

- Ignore multiplayer implications entirely.
- Network every prototype system from the start.

### Consequences

- Single-player iteration remains focused.
- Future networking is not guaranteed to be inexpensive, but avoidable coupling is reduced.
- Gameplay components should not directly poll local input or depend on a specific HUD.

### Follow-up

Revisit when multiplayer enters the roadmap with concrete requirements.

## Decision 004 - Optimize From Budgets and Profiles

- **Date:** 2026-07-11
- **Status:** Accepted

### Context

Large enemy counts can make pooling, spatial queries, AI scheduling, and rendering budgets important. Implementing every optimization before measuring creates complexity and lifecycle bugs.

### Decision

Design clean lifecycles and performance test scenes early, then introduce pooling and specialized optimizations when profiling or target budgets justify them.

### Alternatives Considered

- Pool all spawned objects immediately.
- Ignore performance until content production.

### Consequences

- Early systems remain understandable while retaining a path to optimization.
- Representative stress tests and target-platform profiling become required work.

### Follow-up

Set measurable budgets for actors, projectiles, effects, navigation, and frame time during the combat prototype.

## Decision 005 - Pin the Prototype to Godot 4.7 Stable

- **Date:** 2026-07-11
- **Status:** Accepted

### Context

The project needs a reproducible engine version before scenes, imports, and project settings are created. Godot 4.7 stable is already available on the development workstation.

### Decision

Use the standard Godot 4.7 stable build for the initial prototype. GDScript is the default language; the .NET build is not required.

### Alternatives Considered

- Leave the engine version unspecified.
- Start on another Godot 4.x release.
- Use the .NET build and C# before a measured need exists.

### Consequences

- Project parsing and validation are reproducible against a known engine version.
- Collaborators need Godot 4.7 stable unless an engine upgrade is explicitly recorded and tested.
- Future engine upgrades require compatibility validation and a new or superseding decision.

### Follow-up

Reassess only when an engine defect, platform requirement, or valuable stable feature justifies migration.

## Decision 006 - Use a 640x360 Pixel-Oriented Prototype Baseline

- **Date:** 2026-07-11
- **Status:** Superseded by Decision 014

### Context

The combat prototype needs consistent rendering settings before gameplay scenes and assets are introduced. The game targets a readable 16:9 pixel-art presentation.

### Decision

Use a 640x360 logical viewport, 1280x720 development window, `canvas_items` stretch mode, GL Compatibility rendering, nearest-neighbor texture filtering, and 2D transform/vertex pixel snapping.

### Alternatives Considered

- 320x180 for larger, coarser pixels.
- 480x270 as a middle resolution.
- 960x540 or native-resolution rendering for finer detail.
- Defer all rendering configuration until art exists.

### Consequences

- The project has an immediately testable 16:9 pixel baseline with generous gameplay visibility.
- Camera motion, sprite scale, UI, and actual art may reveal that a different logical resolution is better.
- Final-resolution asset production should wait for an animated-character and camera validation pass.

### Follow-up

Validate the baseline during Phase 1 with representative player animation, camera movement, combat effects, and multiple window sizes.

## Decision 007 - Separate Player Intent From Movement Authority

- **Date:** 2026-07-11
- **Status:** Accepted for the combat prototype

### Context

The player needs responsive local controls now, while future AI, replay, accessibility, or multiplayer work may provide intent from another source. Reading input throughout movement and combat code would make that authority difficult to replace.

### Decision

Use an owned input-source component to translate devices into movement and aim intent. The `Player` remains the physics authority and delegates velocity calculation to a stateless movement component. Facing changes are published to presentation through a typed signal.

The initial aiming model is independent mouse/right-stick aim, with movement direction used only when no deliberate aim direction is available.

### Alternatives Considered

- Read `Input` directly throughout one player controller.
- Make the player always face its movement direction.
- Introduce a full command/network prediction framework immediately.

### Consequences

- Local input can be replaced without rewriting movement calculation.
- Movement tuning is independently smoke-testable.
- The extra component boundary adds a small amount of scene wiring.
- Mouse/right-stick aim supports directional combat but requires later controller and accessibility feel testing.

### Follow-up

Reuse the intent boundary for attack and dodge requests, then reassess it when the first enemy and combat authority exist.

## Decision 008 - Treat Environment Art as Layered Gameplay Assets

- **Date:** 2026-07-11
- **Status:** Accepted direction; exact scene template pending validation

### Context

Top-down combat depends on clear spatial depth, traversability, visibility, and navigation. A single decorative sprite is often insufficient for tall props such as trees, buildings, statues, and walls because the player may need to appear in front of one portion and behind another.

### Decision

Design environment assets for visual quality and gameplay function together. Reusable large props may separate lower visuals, upper occluders, collision, navigation data, shadows, effects, audio, and interactions. Use controlled Godot Y-sorting and stable layer separation, with split visuals when necessary for correct depth.

Tile-based environments must use reusable terrain/tile data supporting variation, transitions, decorative overlays, collision, navigation, and occlusion where appropriate. Pixel density, palette, lighting direction, alignment, and gameplay readability remain consistent across assets.

### Alternatives Considered

- Use one flattened sprite and one collision shape for every prop.
- Paint complete levels as non-reusable background images.
- Fix ordering case-by-case through arbitrary `z_index` changes in gameplay scripts.
- Build a universal environment template containing every possible node.

### Consequences

- Player/prop depth and collision can remain correct in reusable scenes.
- Environment authoring requires deliberate origins, ownership, and review from multiple approach directions.
- Props should include only the gameplay layers they need to avoid bloated scenes.
- The exact Godot 4.7 node/template and tilemap conventions remain uncommitted until tested with representative content.

### Follow-up

After the first combat mechanics are established, build one representative tree or statue plus a small terrain sample. Validate Y-sorting, split occlusion, collision, navigation, shadows, transitions, pixel alignment, and performance before approving the production environment pipeline.

## Decision 009 - Establish Combat With a Data-Driven Plain Sword

- **Date:** 2026-07-11
- **Status:** Accepted for the combat prototype

### Context

The game should eventually support swords, spears, dual swords, and other weapon families. The first implementation needs to prove responsive melee timing and damage without hard-coding the player to one final weapon or coupling combat to temporary art.

### Decision

Use a plain one-handed sword as the first weapon. Shared `WeaponDefinition` data configures damage and wind-up/active/recovery timings. Runtime attack state, hit detection, damage delivery, health, and presentation remain separate responsibilities connected through explicit calls and signals.

Temporary sword polygons, swing motion, target feedback, and health text are presentation layers. Future production sprites, animation, effects, audio, weapon icons, equipment screens, and HUD elements may replace or extend them without becoming damage authority.

### Alternatives Considered

- Implement several weapons simultaneously.
- Hard-code sword values and hit detection in the player script.
- Drive damage directly from the visual animation or HUD.
- Start with a more complex dual-wield or ranged weapon.

### Consequences

- The prototype can validate core melee feel quickly.
- Additional weapons can reuse damage contracts while supplying different attack runtimes, hit shapes, and presentations.
- `WeaponDefinition` intentionally remains small until a second weapon proves which fields are genuinely shared.
- Current values and visuals are not production balance or final art.

### Follow-up

Feel-test the sword, define dodge/cancel rules, then use a mechanically different second weapon such as a spear to validate rather than merely assume extensibility.

## Decision 010 - Present the Reusable Evade as a Supernatural Dash

- **Date:** 2026-07-11
- **Status:** Accepted for the combat prototype

### Context

The game needs a responsive defensive movement option. A physical roll would require more directional animation coverage and can obscure the character silhouette during enemy-heavy combat, while the setting supports divine, demonic, and supernatural movement.

### Decision

Implement neutral `EvadeComponent` gameplay phases and present the current player's evade as a short supernatural dash. Movement input determines direction, falling back to facing while stationary. The dash is invulnerable during its movement phase, followed by vulnerable recovery.

Attack and evade requests are mutually exclusive in the initial prototype. Neither action cancels the other. Invulnerability belongs to health/gameplay state; afterimages, flashes, animation, sound, and future HUD indicators are observers only.

### Alternatives Considered

- Directional physical roll.
- Non-invulnerable movement dash.
- Teleport with no traversed path.
- Add attack/dash cancel windows immediately.

### Consequences

- The temporary dash works in every direction without production animation assets.
- Future characters can reuse evade phases while presenting a roll, blink, shield step, leap, or other movement.
- Current distance and recovery require manual combat feel testing.
- Cancel windows remain deliberately postponed until enemy attacks make their balance meaningful.

### Follow-up

Feel-test the dash, then validate immunity and recovery against the first enemy's telegraphed attack before tuning or adding cancellation rules.

## Decision 011 - Begin Enemy Combat With an Open-Arena Forsaken Thrall

- **Date:** 2026-07-11
- **Status:** Accepted for the combat prototype

### Context

Player movement, sword attacks, and evade immunity require a real hostile encounter to evaluate timing and spacing. The current proving ground has no navigation obstacles, so building a full navigation stack now would not validate meaningful environment behavior.

### Decision

Implement the Forsaken Thrall as a data-driven melee pursuer with explicit chase, wind-up, active, recovery, and death states. It uses direct acceleration-based steering toward an arena-injected player target and reuses the common hitbox, hurtbox, damage, and health contracts.

The wind-up has a strong directional marker, and recovery is deliberately vulnerable. Direct steering is scoped only to the open combat arena and is not the production navigation solution.

### Alternatives Considered

- Add Godot navigation and avoidance before an environment exists.
- Build multiple enemy roles simultaneously.
- Script attacks through animation-only callbacks.
- Use an always-contact-damage enemy without a telegraph.

### Consequences

- The prototype now tests a complete player-versus-enemy combat loop.
- Enemy stats and presentation can change without replacing combat contracts.
- The Thrall cannot navigate complex maps or coordinate with crowds yet.
- Navigation and AI update budgets must be validated with representative obstacles and multiple enemies.

### Follow-up

Feel-test the encounter, add player defeat/reset feedback, then build an environment/navigation test before expanding enemy counts or claiming intelligent obstacle routing.

## Decision 012 - Keep Defeat Authority Outside the HUD

- **Date:** 2026-07-11
- **Status:** Accepted for the combat prototype

### Context

Enemy damage needs visible consequences and a repeatable encounter loop. Coupling restart, health mutation, or input shutdown to HUD controls would make future save, checkpoint, multiplayer, and UI replacement work unnecessarily difficult.

### Decision

`HealthComponent` remains health truth, `Player` owns its defeated state and combat shutdown, `CombatHUD` observes and presents state, and `ArenaFlow` owns restart. On zero health, the player cancels attack/evade, rejects new combat requests, and emits `defeated`. After a short presentation delay, the HUD offers R/gamepad north-button restart; ArenaFlow reloads the current scene.

The prototype restart has no progression penalty and restores the complete arena. Damage flashes, immunity text, health bars, and fallen panels remain replaceable presentation.

### Alternatives Considered

- Let the HUD set player health and reload scenes directly.
- Automatically restart immediately on death.
- Add checkpoint/save penalties before progression exists.
- Keep the player controllable at zero health.

### Consequences

- Health, defeat, presentation, and scene flow have explicit ownership.
- The combat encounter is repeatable without external editor actions.
- Reloading the entire arena is simple but will later need replacement or extension for checkpoints, run state, and persistent progression.
- No global pause or slow-motion defeat effect is implemented yet.

### Follow-up

Feel-test the HUD and defeat delay. Revisit restart ownership when checkpoints or run persistence are designed, without moving gameplay authority into UI code.

## Decision 013 - Validate Environment Assets and Navigation Together

- **Date:** 2026-07-11
- **Status:** Accepted for the prototype

### Context

Environment art affects draw depth, collision, visibility, navigation, and enemy behavior. Producing a large tileset or many props before validating those relationships would risk incompatible sprite origins, oversized collision, and navigation that ignores visual obstacles.

### Decision

Establish the pipeline with a small real raster asset set: four ground variants, a split ancient tree, and a ruined statue. Use a Godot `TileSet`/`TileMapLayer` for ground, reusable prop scenes for large objects, one Y-sorted actor/prop owner, footprint-only collision, and explicit navigation cutouts.

Build arena navigation through Godot 4.7 `NavigationMeshSourceGeometryData2D` and `NavigationServer2D` baking. Use `NavigationAgent2D` for the Thrall, calling path advancement every physics frame while scheduling target repaths at 0.2-second intervals. Retain direct steering only when no navigation path exists in isolated tests.

### Alternatives Considered

- Continue using only Godot polygons as environment visuals.
- Produce a large final tileset before testing scale and layering.
- Use `NavigationObstacle2D` alone and assume it changes pathfinding.
- Recalculate the full enemy target path assignment without cadence limits.

### Consequences

- The repository now contains real replaceable raster assets and a verified Godot import pipeline.
- Player/prop depth, collision footprints, tile population, and path routing can be evaluated together.
- The generated art remains prototype quality and may be replaced without changing prop or navigation ownership.
- Runtime baking and forced startup synchronization are acceptable for this tiny arena but should be replaced by authored/baked data for production maps when appropriate.
- Crowd avoidance and multi-enemy navigation budgets remain unresolved.

### Follow-up

Feel-test the environment in Godot, then add terrain-transition authoring conventions and a multi-enemy navigation stress test before scaling map content.

## Decision 014 - Favor a Wider, Simpler, Brighter Gameplay Presentation

- **Date:** 2026-07-11
- **Status:** Superseded by Decision 015

### Context

Hands-on Godot testing found the 640x360 view cramped, the dark generated environment too detailed, the polygon characters inconsistent with sprite scenery, the tree roots incorrectly participating in canopy depth swaps, and the enemy's obstacle clearance visually too wide.

### Decision

Use an 800x450 logical viewport displayed at 1600x900 for exact 2x scaling. Adopt simpler colorful grass/green-tree art with restrained mystical accents. Use static sprite silhouettes for the player and Thrall until directional animation is designed.

Split tall-tree presentation by responsibility: stump/roots remain permanently on the ground plane, while the separate canopy participates in Y-sorted occlusion. Align navigation with the visible trunk using a 20x22 footprint expanded by a 6-pixel agent radius, producing a tested 16-pixel center clearance.

Simplify the gameplay HUD by retaining essential HP/controls/defeat information and removing the large in-arena title.

### Alternatives Considered

- Keep 640x360 and scale all props down.
- Preserve the dark detailed environment palette.
- Continue using polygons for characters beside raster scenery.
- Keep one Y-sorted tree object for roots and canopy.
- Reduce navigation clearance without aligning physics and agent radius.

### Consequences

- The player sees more world while pixels remain evenly scaled.
- Character, environment, and combat silhouettes are easier to distinguish.
- Tree depth is more believable and roots no longer jump across the player plane.
- Runtime assets remain prototypes; directional animation and production palette approval are still required.
- Existing 640x360 assumptions are superseded and must not be reintroduced accidentally.

### Follow-up

Feel-test the revised scene in Godot. If scale and palette are approved, create directional idle/walk/attack/dash animations before adding broad environment content.

## Decision 015 - Enforce Strict 24x32 Sprite Cells and Integrated Weapon Poses

- **Date:** 2026-07-11
- **Status:** Superseded by Decision 016

### Context

The 800x450 revision improved color and spacing, but hands-on testing still found the HUD too large, the character assets too similar to downscaled fantasy illustrations, and the separately rendered sword visibly disconnected from the player's hands.

### Decision

Use a 960x540 logical viewport displayed at 1920x1080 for exact 2x scaling. Standardize prototype actor presentation on fixed 24x32 cells in a 4x4 direction/action grid.

The player sheet uses columns down/left/right/up and rows idle/walk/sword attack/dash. The Thrall uses the same directions with idle/walk/attack/defeated rows. Sheets are exactly 96x128, palette-quantized without dithering to 10 player colors and 9 Thrall colors.

Draw the sword directly into each player attack pose. Remove the visible floating sword and permanent aim arrow. Retain the invisible directional pivot exclusively for hitbox authority. Animation remains an event-driven presentation observer.

### Alternatives Considered

- Continue downscaling large illustrated characters.
- Keep static sprites and a rotating weapon overlay.
- Use larger 48x64 or 64x64 actor cells.
- Let animation frames determine attack damage timing.

### Consequences

- Character art now obeys measurable sprite constraints instead of relying on a pixel-art appearance.
- Sword/hand contact is coherent in every attack direction.
- The wider view and smaller HUD expose more useful play space.
- Current walk cycles use two prototype frames; richer animation timing can be authored later without changing combat logic.
- Direction/action grid consistency is now a required asset review criterion.

### Follow-up

Feel-test the native-size characters and integrated sword poses. If accepted, refine frame timing and add additional authored frames rather than increasing cell resolution or reverting to illustration-style assets.

## Decision 016 - Preserve Body Scale and Separate the Hand-Anchored Swing

- **Date:** 2026-07-11
- **Status:** Superseded by Decision 017

### Context

Inspection of the first 24x32 sheets revealed that independently fitting each source cell caused side attack poses to occupy only 20 vertical pixels while idle poses occupied 30. Palette conversion also retained partial alpha and enclosed transparent holes, producing missing facial/body fragments. Shadows remained at the old `y = 7` offset, and collision shapes still represented placeholder bodies rather than top-down foot footprints.

### Decision

Rebuild character sheets with binary alpha, no enclosed transparent holes, and stable player body bounds between idle and attack rows. Retain 14 player and 11 Thrall opaque colors to preserve critical facial pixels without dithering.

Use a separate 48x48 three-frame pixel sword swing for wind-up, active, and recovery. Anchor it at the player's body/hand center and rotate it with the same invisible pivot as the authoritative hitbox. The body attack cell remains full scale and no long weapon is fitted inside its 24x32 bounds.

Use a 6-pixel circular movement footprint at `y = -4`, a separate 24-pixel hurtbox capsule at `y = -14`, and a compact shadow at `y = -2` for both player and Thrall. Reduce melee hit shapes to match the new visible reach.

### Alternatives Considered

- Keep independently scaled attack cells.
- Increase actor cell size solely to fit a long sword.
- Return to a detached rotating polygon sword.
- Keep semi-transparent alpha and manually patch only obvious facial holes.
- Use one collision capsule for movement and damage reception.

### Consequences

- Character size no longer changes during attacks.
- Facial/body pixels cannot disappear through partial-alpha conversion or enclosed transparency.
- The sword visibly swings through three gameplay phases while remaining aligned with hitbox direction.
- Foot collision, hurtboxes, shadows, and visible sprite placement now have distinct responsibilities.
- The swing effect can be redrawn later without modifying attack authority or character sheets.

### Follow-up

Feel-test hand alignment and perceived reach in Godot. Future frames must pass binary-alpha, stable-bound, swing-phase, and foot-plane regression checks.

## Decision 017 - Author Full-Body Six-Frame Sword Attacks

- **Date:** 2026-07-11
- **Status:** Superseded for the active player by Decision 039; retained as prototype history

### Context

The corrected three-frame swing removed character shrinking but still felt visually wrong because the sword moved independently around a mostly static body. It lacked anticipation, torso involvement, continuous hand contact, a clear impact pose, and authored follow-through.

### Decision

Use a larger 64x48 action canvas for sword attacks while retaining 24x32 locomotion cells. Author six complete character-and-weapon poses per direction: anticipation, coil, fast swing, impact, follow-through, and recovery. The final sheet is 384x192 with six columns and four directional rows.

All attack cells share one global scale and foot baseline. Hands, arms, sword, torso, hood, face, and cloak are drawn together. No visible weapon child remains under `SwordPivot`; that pivot exists only to orient the authoritative hitbox.

Map gameplay phases deterministically: wind-up uses frames 0-1, active damage uses frames 2-3, and recovery uses frames 4-5. Each pair advances halfway through its gameplay phase duration.

### Alternatives Considered

- Keep the three-frame hand-centered weapon overlay.
- Animate only the sword while leaving the body static.
- Force the complete attack into 24x32 cells.
- Run a six-frame animation on an unrelated presentation timer.

### Consequences

- The body visibly participates in attacks and the sword remains connected to the hands.
- Attack silhouettes have room for blade extension without shrinking the actor.
- Visual impact aligns with the actual active hit window.
- Attack art uses a larger canvas but preserves the same body scale and baseline as locomotion.
- Future weapons require their own authored action sheets or a documented compatible animation strategy.

### Follow-up

Feel-test anticipation, impact readability, hand contact, and perceived reach. Tune gameplay phase durations only with corresponding animation review so the visual and authoritative windows stay aligned.

## Decision 018 - Polish Enemy Arrival, Footprint Navigation, and Combat-Space Presentation

- **Date:** 2026-07-12
- **Status:** Accepted for the prototype

### Context

The Thrall appeared instantly, stopped paths 28 pixels away despite a 6-pixel foot body, and presented its strike as a detached rectangle. Environment props visually overpowered actors, the tree was static, and persistent instructional UI occupied combat space.

### Decision

Add a non-hostile `SPAWNING` state before pursuit, match navigation radius and completion tolerance to the physical foot radius, and present the existing authoritative melee phases as a recoil-and-lunge claw swipe. Replace the active tree/statue with reduced limited-palette assets, separate tree base/canopy responsibilities, and animate canopy sway through intermittent tweens. Keep only compact health and contextual combat feedback visible during play.

### Consequences

- Enemy arrival is announced before pursuit or damage begins.
- Obstacle approaches end near the real footprint rather than at an arbitrary 28-pixel buffer.
- Tree movement costs no continuous `_process()` work and cannot affect collision.
- Combat space has less persistent UI obstruction.
- Multi-enemy avoidance and a fully authored multi-frame Thrall claw sheet remain future work.

## Decision 019 - Author the Thrall Claw Scratch as Full-Body Directional Animation

- **Date:** 2026-07-12
- **Status:** Accepted for the prototype

### Context

The procedural recoil/lunge still read as a reaching hand followed by a detached red marker. It did not show a recognizable scratch, body commitment, impact pose, or follow-through.

### Decision

Use a 384x192 claw sheet containing six 64x48 full-body poses for each of four directions. Map wind-up to anticipation and raised-arm frames 0-1, active damage to slash and impact frames 2-3, and recovery to follow-through and return frames 4-5. Retain only a faint curved ground cue during wind-up; authored claw trails communicate the active strike.

### Consequences

- The Thrall visibly scratches instead of extending one static hand.
- Visual impact and authoritative damage use the same phase timing.
- Locomotion remains on the compact 24x32 sheet while attacks receive enough canvas for extended arms.
- Future enemy attacks should use the same phase-aligned presentation boundary without making animation damage authority.

## Decision 020 - Turn the Proving Ground Into a Small Staged Playable Level

- **Date:** 2026-07-12
- **Status:** Superseded by Decision 022

### Context

The single-screen arena, manually placed Thrall, visible training target, and repeating ground could no longer validate camera travel, encounter pacing, mixed enemies, purposeful landmarks, or future boss-stage structure.

### Decision

Expand the world to 30x18 cells with a non-smoothed pixel-stable Camera2D. Remove the training target and manually placed enemy from normal play. Use data-driven stage resources, seven distant spawn markers, and one encounter controller to produce four mixed Mireling/Thrall trials followed by a sealed Stage 5 boss gate. Add the Mireling as weak early fodder. Keep the lower HUD clear for one weapon and at most two future skills.

### Consequences

- The project now has a small scrolling level and repeatable encounter progression rather than a static test room.
- Stage, spawn, and enemy ownership remain separate from HUD presentation.
- The boss, mini-boss/elite archetype, skills, equipment UI, audio, crowd avoidance, and production terrain transitions remain explicitly unimplemented.
- Encounter counts and landmark layout require hands-on feel testing before content expansion.

## Decision 021 - Make Enemy Pressure Dodgeable and Obstacle-Correct

- **Date:** 2026-07-12
- **Status:** Accepted for the prototype

### Context

The small Mireling repeatedly damaged players at contact, distant spawning delayed encounters, Thralls visually back-walked while following paths, and attack-locked enemy bodies could pin the player against overlapping statue collision.

### Decision

Enlarge Mirelings to 32x32 and make their attack snapshot a marked landing position, leap over time, damage only at landing, and expose a long recovery. Make Thralls face path steering and require clear world line-of-sight before attacking. Enemy movement bodies collide with world but not players. Replace the statue rectangles with one convex physics/navigation footprint. Spawn enemies in a navigation-safe 250-340 pixel ring and show a transient direction arrow.

### Consequences

- Mireling damage is avoidable through movement or dash rather than constant proximity damage.
- Thralls no longer appear to retreat while pathing forward or attack through props.
- Players cannot be physically wedged between an attacking enemy and a prop.
- Enemy-to-enemy separation is still required.
- Blocking bushes should be introduced only after separation and path-budget testing; decorative bushes may remain non-blocking.

## Decision 022 - Define Waves Within a Stage and Exit Through a Portal

- **Date:** 2026-07-12
- **Status:** Accepted for the prototype

### Context

The initial encounter data incorrectly treated each enemy group as a separate stage and reserved a fifth entry as a boss gate. The intended structure is several waves within one map stage, followed by a portal and scene/loading transition. The exact statue-opposite chase also exposed a NavigationAgent2D deadlock and edge-centered detour.

### Decision

Stage 1 contains exactly three `EncounterWaveDefinition` resources with one to four enemies each. Clearing Wave 3 spawns one `StagePortal`. The portal owns an optional target scene path; while Stage 2 is absent, entering it reports a sealed destination. Future mini-bosses or bosses belong to a stage's authored wave/story structure, not arbitrary global stage-number entries.

Call `NavigationAgent2D.get_next_path_position()` every chase frame after target assignment and use corridor-funnel postprocessing for Thralls.

### Consequences

- UI now says Wave 1/3 through Wave 3/3 rather than Stage 1/5.
- A stage is a map/story unit; waves are encounter groups inside it.
- Scene loading can be connected later by assigning the portal's target scene without changing wave ownership.
- Stage 2, loading presentation, story sequence, mini-boss, and boss remain unimplemented.
- The statue-opposite route no longer stalls and avoids the former extreme detour.

## Decision 023 - Use Local Proximity Separation for Prototype Crowds

- **Date:** 2026-07-13
- **Status:** Accepted for the prototype

### Context

Stage 1 can place four mixed enemies on converging paths. With enemy bodies intentionally not blocking the player, enemies could visually stack into one unreadable mass. Global neighbor scans would create unnecessary work, while avoidance during attacks would move committed telegraphs.

### Decision

Compose Thralls and Mirelings with `EnemySeparationComponent`, an enemy-layer `Area2D` with a 30-pixel neighborhood. During chase only, blend desired navigation direction with weighted repulsion from overlapping enemy bodies. Do not apply separation during committed attack phases or Mireling leaps.

### Consequences

- Mixed enemies spread while continuing to pursue the player.
- Player movement remains unblocked because separation observes only the enemy layer.
- Work is proportional to local overlaps rather than all enemies in the scene.
- The current four-enemy regression reaches 20.19 pixels minimum spacing from a tight cluster.
- Larger hordes may require NavigationServer avoidance or spatial partitioning after profiling.

## Decision 024 - Announce Spawns With a Reusable Summon Effect

- **Date:** 2026-07-13
- **Status:** Accepted for the prototype

### Context

Enemy materialization prevented instant attacks but remained visually understated, especially near the camera edge. A full lightning storm for every spawn would create excessive flashes during four-enemy waves.

### Decision

At every encounter spawn, instantiate one short-lived `SummonEffect` under the world effects owner. Present a violet ground rune, inward-moving sparks, one segmented energy strike, and a compact flash over 0.7 seconds. Keep enemy materialization and combat authority in enemy state machines. Add a 2.25-second recovery interval and wave-clear announcement between groups.

### Consequences

- Spawn locations and timing are easier to read without persistent UI or damaging VFX.
- All current and future encounter enemies can reuse the effect automatically.
- The effect self-cleans and performs no continuous processing.
- Flash intensity should be feel-tested before adding screen shake, sound, or additional particles.

## Decision 025 - Make Portals Explicit Reusable Scene Boundaries

- **Date:** 2026-07-13
- **Status:** Accepted for the prototype

### Context

Automatic teleportation on portal overlap would surprise players and couple world collision directly to loading. Future portals, doors, NPCs, and interactables need consistent proximity prompts. Scene fades must survive scene replacement and prevent gameplay during loading.

### Decision

`StagePortal` emits contextual prompt state on player enter/exit and accepts `player_interact` only while nearby. HUD presents the prompt. Delegate valid destination loading to the `SceneTransition` autoload, which pauses the tree, fades to black with a loading message, changes scenes, resumes, and fades in. Stage 2 is a deliberately minimal destination with a reliable spawn and return portal.

### Consequences

- Walking over a portal never teleports the player automatically.
- Leaving portal range immediately removes its prompt.
- Future interactables can reuse the prompt boundary without depending on scene loading.
- Transition presentation and validation remain cross-scene while progression state remains unimplemented.
- Stage 2 content, story, NPCs, enemies, and persistence still require separate design milestones.
