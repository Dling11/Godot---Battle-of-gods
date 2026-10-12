# Style Guide

Updated 2026-10-13. Current sources and contracts are authoritative; historical generation trials and archive-dependent tooling were removed (Decision197). See PROJECT_CONTEXT.md and docs/maintenance/repository-cleanup.md.

Keep complete approved native anatomy, real palm grips, fixed density/origin and camera depth. New motion needs separate owner review; frozen-reference hashes remain immutable. Captures/logs use ignored tmp/review/, never tracked archive/review folders.

## Scope

These conventions apply to Godot 4.x GDScript, scenes, resources, and game assets. Prefer consistency with an established local pattern when it is clearly intentional; record any durable convention change here.

## Naming

- Files and folders: `snake_case`.
- GDScript variables and functions: `snake_case`.
- Classes and named custom resources: `PascalCase` via `class_name` when globally useful.
- Constants and enum members: `UPPER_SNAKE_CASE`.
- Signals: past-tense or state-event `snake_case`, such as `health_changed` or `died`.
- Private implementation members: leading underscore when it improves API clarity.
- Node names: `PascalCase`, descriptive, and stable within reusable scenes.
- Input actions: namespaced `snake_case`, such as `player_move_left` and `player_dodge`.
- Regional vocabulary is scoped content, never the game's global naming template. Forest/root/tree/bark/grove language may be used across planned Stages I-X when a character, creature, material, or place genuinely belongs to that ecology, but do not force the motif into every name. Unrelated Sanctuary characters, cross-region services, generic systems, and Stage XI+ content require personal, neutral, or lore-meaningful naming rather than inheriting the Forest motif by habit.
- Reusable enemies, NPCs, projectiles, VFX, sounds, materials, tiles, and environment modules use identity-owned folders and filenames. Never prefix or nest reusable content under `stage_7`, `stage_9`, or another introduction stage. Stage folders own only layouts, encounter composition, stage-specific flow, and assets that truly cannot exist outside that stage.

## GDScript Organization

Use this order when sections are present:

1. `class_name` and `extends`
2. Documentation comment
3. Signals
4. Enums
5. Constants
6. Exported variables
7. Public variables/properties
8. Private variables
9. `@onready` references
10. Godot lifecycle callbacks
11. Public methods
12. Private methods

Use static typing for public APIs, exported data, signals, return values, and non-obvious local values. Avoid `Variant` unless polymorphism is intentional.

## Script Responsibilities

- Assisted controls may produce movement or action intent, but `Player` remains the only body/action authority. Manual input has explicit priority, selection identifies one actor, and target UI/markers remain observers.
- Hitstop is presentation-only. Enemy interruption requires explicit `DamageInfo.stagger_seconds` plus the target's crowd-control policy; never infer stagger from pause duration or repeated input.
- Configure repeat-interruption limits and resistance windows on `EnemyDefinition`; do not add hit counters to individual enemy controllers. A resistance window may reject gameplay stagger only—accepted damage, flash, audio, particles, and bounded hitstop must remain intact.
- Control tier describes reaction strength, not encounter rank. A recurring normal mob may use `HEAVY` without becoming an Elite/mini-boss, and a boss should use data-owned immunity rather than skill-specific exceptions.

- A script should have one clear reason to change.
- Prefer components and collaborators over deep inheritance trees.
- Avoid giant actor controllers; extract coherent capabilities once boundaries are understood.
- Do not create an abstraction for a single trivial use unless it enforces an important boundary.
- Presentation scripts must not silently own combat rules.
- Hit flash and hitstop may observe only accepted-hit signals. They must remain presentation feedback and must not decide damage or contact. Preserve target-local confirmation, but coalesce camera, hitstop, and impact-audio work once per swing/cast impact so multi-target contacts cannot stack pauses or rebuild shared effects.
- Avoid hidden mutations of shared `Resource` assets.
- Fix an incorrect sprite silhouette in processed frame pixels. Permanent node scale is not an acceptable substitute for correcting generated/native actor scale; temporary authored squash/stretch such as spawning remains presentation-only.

## Signals

- Signals notify that something happened; methods request that something happen.
- Declare typed signal parameters.
- Connect/disconnect dynamic relationships with lifecycle ownership in mind.
- Avoid signal chains that obscure the source of a gameplay state change.
- Do not use a global event bus as the default communication mechanism.

## Audio

- Route repeated cooldown attempts through the shared player request method and one presentation-only denied signal. Do not make individual abilities own rejection sounds, do not buffer cooldown-blocked inputs, and keep cooldown buttons tappable across mouse/touch while locked or unavailable slots remain disabled.

- Use `AudioDirector` only for cross-scene music routing; level-local `StageMusic` nodes request tracks.
- Audio observes gameplay and level state. It must not own damage, timing, rewards, or other gameplay authority.
- Route ambience/music through `Music`, combat/world cues through `SFX`, and menu feedback through `UI`.
- Outdoor recording players use `Ambience -> Music`, with quiet data-owned gains, sparse Timer-based positional calls and event-driven combat reduction. Stage freeing stops local audio. Keep the shared profile immutable by duplicating its looping stream. Music & Ambience is one atmosphere toggle; combat remains independent.
- Cross-scene music uses one complete-track player: cancel pending gain/handoff tweens on newer requests/stop, preserve playback for same-track gain requests and reject stale scene gain events by requested stream identity. Music transitions continue during modal pause; headless routing assigns immediately without device playback.
- Do not fake a stem mix by playing two independently composed complete songs together. Encounter music should use one coherent composition or explicitly authored/key-and-tempo-compatible stems; phase changes should cancel prior volume tweens before applying the next mix state.
- Positional actor sounds must live beneath a `Node2D` transform owner and respond to authoritative state signals or accepted-hit events.
- Add third-party audio only with a recorded license and attribution file beside the asset when required or useful for provenance.
- Headless tests may validate stream routing without requiring device playback.

## Scene Organization

- Reusable scenes own their internal nodes and expose a small configured API.
- Use exported node/resource references for required dependencies when editor wiring is stable.
- Use unique node names sparingly and only within a clear scene ownership boundary.
- Avoid distant absolute node paths.
- Keep collisions, visuals, audio, and gameplay components clearly named.
- Prefer instantiable entity scenes over duplicating node trees in levels.
- Inventory grids use compact reusable focusable slots and explicit disabled placeholders. Present equipment and materials through their owning authorities; never create a UI-owned item dictionary. Capacity labels must state which categories consume space, and destructive discard must require a separate confirmed command rather than slot-click side effects.

## Formatting and Documentation

- Use tabs as produced by the Godot editor for GDScript indentation.
- Keep lines readable; break long calls and data declarations deliberately.
- Document intent, invariants, units, and surprising constraints—not obvious syntax.
- Use `##` documentation comments for public classes, exported configuration, and public APIs where useful.
- Include units in names or docs when ambiguity exists, such as `duration_seconds`.
- Remove dead code and stale comments rather than commenting out implementations.

## Physics and Frame Updates

- Put physics movement and collision work in `_physics_process()`.
- Use `_process()` only for frame-dependent presentation or logic that truly needs it.
- Prefer signals, timers, animation callbacks, and explicit state transitions over permanent polling.
- Make delta usage explicit and avoid frame-rate-dependent gameplay behavior.
- When an `Area2D` collection/overlap callback needs to change `monitoring` or `monitorable`, use `set_deferred()`; the physics server blocks direct changes while flushing enter/exit signals. Keep a synchronous logical guard so a deferred disable cannot double-grant the interaction.
- Keep action buffers actor-owned, non-stacking, and bounded to explicit state transitions. Snapshot any required direction/target when input is accepted, expose phase-specific cancel methods instead of broadly resetting a state machine, and regression-test that damage and invulnerability never overlap unintentionally.
- Ability data may declare activation mode, presentation style, authoritative shape, flat/weapon scaling, and phase movement. Snapshot resolved combat values at cast acceptance; actor controllers consume movement, hitboxes consume contacts/damage, and skill visuals/HUD/audio only observe those states.
- Aggregate character/level/equipment maximum-health inputs in a player stat component, then apply the result through `HealthComponent`. Cross-scene current-health memory may live in the narrow run-session service, but every restore, heal, regeneration tick, and damage event must still pass through `HealthComponent`. Prefer damage-reset timers plus discrete healing ticks over per-frame regeneration. Armor UI, level banners, and potion presentation must not become health authority. Keep future mana in a separate resource/component unless an approved shared-stat contract proves necessary.
- Resolve armor only in `HealthComponent` with diminishing returns (`raw * 100 / (100 + armor)`). Enemy armor belongs to `EnemyDefinition`; future player equipment must aggregate into the same component rather than subtracting damage in attacks, hurtboxes, feedback, or UI. Preserve both raw and accepted damage for honest feedback and testing.
- Multi-strike abilities declare their ordered damage multipliers and final-versus-non-final knockback in immutable ability data. The ability runtime may reactivate a hitbox only at explicit strike windows; each body/VFX/sword/audio flourish must observe the emitted strike signal and never create a second contact or damage path.

## Error Handling

- Validate external/configuration data at boundaries.
- Use assertions for developer invariants, not recoverable player-facing failures.
- Fail visibly in development when required dependencies are missing.
- Do not silently swallow invalid state.
- Save authorities expose explicit versioned dictionaries and validate complete input before mutating live state. Disk writes use a validated temporary file plus recoverable backup; never serialize nodes, resources by instance identity, active attacks, or scene trees.
- Autosave only at authored safe milestones. UI may request Continue/New Journey, but `SaveService` owns file validation, recovery, deletion, and restoration. Headless tests must use isolated `user://` paths or suppress production-path persistence.
- Activate a reserved profile extension through its own versioned authority. Preserve explicitly supported legacy-empty sections as clean default state, validate every extension before any authority mutates, and add disk reconstruction plus corruption coverage in the same change.
- Immutable content Resources own stable IDs and authored quantities; global catalogs reject invalid definitions and duplicate IDs. Mutable inventories store only known IDs and plain values, never `Resource` instances or display labels. Recipe discovery remains separate from story flags unless a recipe is itself a narrative key item.
- Enemy controllers, stage scenes, chest UI, and crafting UI may reference definitions or submit requests, but they must not roll rewards, edit material dictionaries, consume recipe costs, or write profiles directly.
- Resolve enemy/stage reward definitions through one gameplay authority, combine repeated material stacks before presentation, and grant only through the owning inventory authority. World pickups present and collect an already-resolved stack; a stage chest requests one idempotent table claim; HUD toasts only observe successful grants.

## Assets and Pixel Art

- Give each approved asset a canonical semantic ID in `ASSET_CATALOG.md`.
- Runtime filenames use descriptive `snake_case`; prefer `<identity>_<action-or-purpose>_<asset-type>_<dimensions>` where the dimensions communicate a real grid contract.
- Never use `final`, `new`, `fixed`, `better`, unexplained numbers, or personal names in runtime filenames.
- Keep purposeful source and runtime assets distinct. Temporary intermediates/captures belong under ignored `tmp/`; retired content belongs only in Git history. Only runtime assets belong in load-bearing scene paths.
- Backgrounds, icons, and panel art are presentation dependencies. Reference them through configured scenes/resources rather than branching gameplay logic on filenames.
- Follow `ART_DIRECTION.md` for palette roles, lighting, pixel density, and replaceable-background requirements.
- Follow `docs/design/character-animation-pixel-contract.md` when generating or processing character boards; prompts, source boards, runtime cells, safe margins, and acceptance scans must share one explicit pixel contract.
- Every enemy with frame-based body art must use `AnimatedSprite2D` and clearly named `SpriteFrames` families (`idle_<direction>`, `walk_<direction>`, `attack_<direction>`, `hurt_<direction>`, `dead_<direction>`, plus explicit special families where needed). Synchronize authoritative state/contact timing to those frames. Do not fake an absent physical action by scaling an idle pose, rotating a whole sprite, swapping raw textures manually, or hiding it behind VFX.
- Ranged enemies may retreat to preserve role identity, but retreat must be bounded by a fixed target/duration/cooldown and end in a legal decision such as fire, flank, or recover. Never recompute an unlimited directly-away target every path refresh.
- A destructible hostile projectile should compose the shared health/hurtbox path. Mark its hurtbox non-selectable when it is counterplay rather than an enemy target; projectile scripts still own travel, player/world impact, cleanup, and freed-source validation.
- Apply `assets/ui/themes/battle_of_gods_theme.tres` at reusable UI roots; add local theme overrides only for semantic states the shared theme cannot represent.
- Use a `Panel` root for HUD slots whose icon, key and status need separate anchors; `PanelContainer` sizes direct children to its content area and can collapse those layers together. Keep counts and cooldown text bright when dimming an unavailable icon.
- UI icons use stable canonical concepts and native 16x16 or 24x24 textures; detailed inventory item portraits use the approved 64x64 contract. Pass them as presentation configuration or metadata; never parse their filenames to decide gameplay behavior.
- Extend the established crisp 24x24 Battle-of-Gods action-icon language for small semantic controls: navy outline, pale readable core, cyan motion/interaction accent, and restrained gold emphasis. Generated character skill art must still become purpose-built native 24x24 hard-pixel UI: one dominant symbol plus one supporting effect, binary alpha, limited fixed palette, transparent padding, and native-size validation. Do not treat painted detail or a large antialiased reduction as an exception. Never substitute default engine icons or mix unrelated packs. Keep animation to two or a few purposeful frames when motion communicates state.
- Generated UI art keeps approved full-resolution originals under `art_source/generated/ui/<feature>/` and checked-in compact runtime derivatives under the owning `assets/ui/` folder. Preserve the derivation tool or exact processing recipe so runtime files can be reproduced without regenerating the concept.
- Paired generated HUD ornaments should derive the right-hand sprite by mirroring the selected left-hand source, use palette-limited binary-alpha runtime files, and ignore mouse input. Keep decorative silhouettes outside button hitboxes and check the assembled HUD at 960x540.
- Crafting material icons use a 24x24 runtime contract; crafted equipment portraits use the existing 64x64 inventory contract. A material may reuse an approved source silhouette/container template, but its distinct contents, inset glyph, accent cluster, and flattened runtime PNG must communicate its actual identity. Keep names, counts, rarity frames, and region labels in UI/data rather than baking text into the icon.
- Exact reuse is reserved for the same material ID; template reuse may preserve a vial, cloth bundle, shard, plate, seed, spore, or core silhouette; original art is required for signature materials, boss cores, or any resource whose gameplay importance would be obscured by a family template. Do not use runtime recoloring to manufacture separate materials.
- Cross-region progression must not become `Leather+`, `Leather++`, or palette-only enemy variants. Reuse universal components where their fiction still fits, introduce real region materials with new behavior, and distinguish threats through silhouette, animation, telegraph, and mechanics as well as color.
- Before producing a future enemy, record its stage purpose, ecology, combat role, body/action/VFX frame contracts, data-owned movement radius, separate hurtbox/attack shapes, map navigation clearance, audio identity, drop profile, recipe purpose, portrait need, and focused test expectations. Art generation may begin only when that content contract is coherent.
- External or generated audio must match the creature/material action, use a project-compatible license, retain exact provenance/attribution, and be previewed in the live mix before approval. Do not import an entire sound pack when only selected cues are needed.
- Every newly approved named character or recurring enemy should receive a reusable square portrait when it can support dialogue, expedition previews, bestiary entries, or character descriptions. Current dialogue/bestiary portraits use transparent 96x96 runtime PNGs, preserve the gameplay model's identity and upper-left lighting, and remain presentation metadata rather than gameplay authority.
- Multi-speaker dialogue must author an ordered speaker/text/portrait entry per line; do not infer speaker identity from body text or filenames. Keep a visible mouse-operable Skip control on cinematic conversations and route Skip through the same safe owner handoff as normal completion.
- Boss defeat quotes should reveal character or future tension, not merely announce zero health. Keep dialogue, collapse/fade, reward manifestation, and reward claim as distinct ordered beats so a chest never replaces the boss on the same death frame.
- Major-boss chests require a silhouette and footprint distinct from ordinary caches and mini-boss reliquaries. Chest tier may select presentation assets, prompt copy, accent, and collision dimensions; contents and first-clear rules must remain in `LootTableDefinition` and `LootService`.
- Keep small pixel icons on binary alpha with one readable symbol and transparent internal margin. Regenerate the baseline kit through `retired generation tool (recover from Git history only)` rather than hand-editing generated runtime files inconsistently.
- Menu screens must establish an initial focused control, explicit directional focus loops, modal focus transfer, and focus restoration when the modal closes.
- Every gameplay modal must provide a visible mouse-operable primary/close control and support `ui_cancel`; do not rely on a hidden keyboard-only toggle to dismiss it.
- Use native `Button.pressed` activation as the shared path for mouse click, `ui_accept`, and controller confirmation. Do not create separate gameplay outcomes for each device.
- Route pointer-bound world attacks through `_unhandled_input()` when HUD/menu Controls must consume clicks first. Do not poll the same mouse action per physics frame behind native Buttons.
- Handle global modal-open shortcuts in `_input()` when their physical key also serves GUI navigation, mark accepted events handled, and ignore open requests while another owner has paused the tree. Use `_unhandled_input()` only when GUI consumption is intended.
- HUD entry buttons emit gameplay intent without calculating outcomes. The shared `MENU [ESC]` entry may locate the one scene-registered `PauseMenu`, but that menu remains pause authority.
- Full-screen transition or modal shields may use `MOUSE_FILTER_STOP` only while they are intentionally active; transparent idle overlays and decorative controls must use `MOUSE_FILTER_IGNORE` so they cannot silently consume clicks.
- Repeated skill presentation must consume `SkillLoadoutDefinition`/`SkillSlotDefinition` data through reusable slot scenes. HUD views may observe an injected `AbilityComponent`, but UI must not own cast, cooldown, unlock, or damage authority.
- Keep frequently scanned combat actions icon-first and bounded. The current lower tray uses 46x44 numbered skill slots between 54x44 Dash and Attack end cards, with semantic gaps and high-contrast key/status labels. Long names belong in tooltips or paused detail surfaces and must never expand the combat layout.
- In narrow live lists, clip content and provide equal left/right padding. Use a reusable marquee only when measured text exceeds the available width; keep fitting text stationary and avoid rebuilding the control on a polling interval when its visible signature has not changed.
- Ordinary level gain must remain non-modal and combat-readable. Attach its small glow/text confirmation to the actor rather than covering the viewport with a central panel; presentation observes progression and never applies stat changes.
- Major bosses use one scene-owned top-screen `BossHealthHUD` bound to their authoritative `HealthComponent`; do not also retain an actor-local `EnemyHealthBar`. Threshold marks and phase labels may communicate approved health boundaries, but HUD presentation never changes phase behavior, damage, or targeting.
- Repeated paused selectors should show identity/status once and route long descriptions into one selected-detail panel. Do not duplicate multi-line ability copy inside every card when it can force the modal beyond its authored bounds.
- Character equipment uses one stable ten-position vocabulary: Weapon, Head, Plate, Gloves, Leggings, Boots, Bracer, Amulet, Ring, and Talisman. Present the weapon as `Weapon Essence` when character-owned signature art is active. Preserve the compact Character & Bag hierarchy—loadout upper left, information upper right, sortable inventory underneath—and keep Active Skills separate; never relabel explicit accessories as generic numbered slots.
- Repeated weapon presentation must consume `EquipmentDefinition` through reusable item, slot, and detail scenes and read authoritative combat tuning only from its linked `WeaponDefinition`. UI may request a purchase or equip command, but `WeaponInventory`, `PlayerProgressionComponent`, and `Player` validate and commit ownership, coin spending, class compatibility, and combat swapping respectively.
- Weapon cards select and preview; a labeled Equip action commits. If a modal freezes the actor outside an idle-only presentation seam, retain one validated pending weapon definition and apply it on the next safe idle frame instead of silently rejecting the command.
- Expedition routes must consume immutable `ExpeditionDefinition` and `ExpeditionRequirement` data. Use stable `snake_case` IDs for story flags, bosses, discoveries, and narrative key items; display text may humanize or localize those IDs but must never become authority.
- Equipment rank color is semantic: the active beginner pair uses warm ash brown for Wood and pale steel for Iron; spirit blue is reserved for a later higher grade. Stonebound and former A/S/Legendary/Mythic concepts are inactive legacy/future material until a later decision reintroduces them. Rank animation remains a restrained pulse and must not compete with menu focus.
- Store class compatibility as stable lowercase class IDs on item data. Shared ownership may contain another class's weapon, but equip validation must reject it before presentation or combat changes. Every playable character must retain one owned default/fallback weapon; purchasing must never auto-equip or sell skills.
- Title/loading/background art remains under a named presentation owner. Never bake navigation labels or controls into background textures.
- Generated dark-background crops must use asset-specific border cleanup. Do not globally key all dark pixels from characters, buildings, or props; preserve legitimate outlines, interiors, limbs, and connectors.

- Favor strong silhouettes, limited palettes, and readable animation keys.
- Use nearest-neighbor filtering and pixel-consistent import settings once the base resolution is decided.
- Avoid subpixel shimmer by aligning camera/rendering policy with the chosen pixel scale.
- Separate gameplay hit shapes from sprite opacity or detailed outlines.
- Name animation clips and sprite assets consistently with their gameplay action.
- Align sprite origins deliberately, usually around the gameplay contact point or feet for Y-sorted actors and props.
- Keep pixel density consistent; scaling a sprite to disguise a mismatched source resolution requires explicit art-direction approval.
- Maintain a documented shared palette and lighting direction once the first production palette is approved.
- Judge animation at gameplay scale and speed, not only zoomed in within an art tool.
- Prefer simple color blocks and controlled clusters over noisy micro-detail; environment assets must not visually overpower actors or combat telegraphs.
- Validate asset scale in the full gameplay viewport before approving detail density.
- King and future character-owned combatants start from a reviewed four-direction turnaround. King C uses exact-grid `96x64` cells with y=48 feet and approximately 27px standing anatomy; padding protects the complete greatsword rather than enlarging his body. The style is hard-pixel chibi with an oversized head, short body, simple connected visible arms, and readable hand-to-signature-weapon contact—not realistic anatomy or a detached weapon orbit. Existing enemy-humanoid locomotion may retain its validated 24x32 contract, and small creatures retain 32x32.
- Prefer one exact-grid PNG per coherent action family with `down/left/right/up` rows and time across columns. Do not default to unwieldy one-row strips or combine unrelated idle, walk, attack, and skill actions into one atlas. Every frame uses the same declared cell, and PNG dimensions equal cell size times column/row count. Keep King's body/weapon and oversized crescent VFX in separate `AnimatedSprite2D` assets even if a combined proof is used for timing review.
- Keep active actor sheets on a fixed direction-row grid: down, left, right, up; action time advances across columns.
- Character body scale must remain constant across directions and action cells. Normalize from a per-direction standing reference, keep one foot baseline, and allocate a wider cell rather than shrinking an actor, long weapon, reach, lean, or collapse.
- Generated multi-frame actors must never be independently width-fit or height-fit per cell. Derive one scale from the approved standing reference for each direction row, apply it unchanged across that row, preserve the source-cell origin, and widen the runtime canvas for extended poses. Prefer source-board dimensions divisible by the declared grid; when a preserved legacy board is not divisible, derive rounded proportional boundaries instead of truncating every cell. Recover only the connected actor when a pose crosses an ideal source-cell edge and reject disconnected neighboring fragments or decorative debris. Prefer named `SpriteFrames` on `AnimatedSprite2D` for recurring body states so artists can preview the active animation in Godot; controller signals still own gameplay timing and hitboxes.
- For a visible-limbed playable character, reject any frame with disconnected hands, changing arm count/length, a weapon grip that jumps between hands, inconsistent weapon length, or anatomy that changes between directions. Approve identity and contact frames at gameplay scale before producing a complete skill sheet.
- Validate rigid weapons as complete constructions, not blade silhouettes: extend both blade rails through the guard and reject any hand, grip, or pommel outside them. If an integrated character/weapon sheet fails, regenerate or repair that integrated sheet one direction/action at a time. Do not replace its character or weapon with programmer-drawn raster layers unless the owner explicitly approves that visual method.
- Prefer action-owned playable sheets when one mixed board would couple unrelated frame counts or encourage unstable crops. Preserve the `<action>_<direction>` animation API so scenes do not depend on atlas layout.
- Generated poses may cross an ideal source-grid boundary. Isolate the complete connected actor from an expanded cell before measuring scale; do not use a fixed inset that can flatten a head or include the next pose in the reference bounds.
- Attack and dash normalization must preserve a fully padded head silhouette and direction-appropriate facial landmarks: two readable eyes facing down, one profile eye facing left/right, and a complete back-of-head facing up. Down/up attacks keep the head and tunic centered on the same screen-space vertical axis; do not reuse a diagonal side lunge for a cardinal vertical strike. Put extreme motion into torso, feet, cloth, and equipment rather than rotating a low-resolution head until its face disappears.
- Existing integrated actor actions that extend beyond a 24x32 locomotion cell may retain a documented larger fixed canvas, currently 64x48, provided body scale and foot baseline remain constant across every frame.
- Modular playable weapons may be separate `Sprite2D` presentation driven by the same attack-phase signals as the actor, or integrated into character-owned action frames when the silhouette requires visible hand/weapon contact. There must be one presentation owner per action. Never rotate a separate weapon around its texture center unless the grip is actually centered. Visible weapons use reviewed integer-pixel hand anchors, never own hit timing or damage, and remain close enough to read as intentionally controlled. King and later visible-limbed characters align to authored hands. Equipping an essence does not automatically replace the signature weapon sprite.
- Each obtainable melee weapon must reference a valid data-owned `Shape2D`. Combat installs that shape as contact authority; presentation may read its bounds to size a trail or cleave guide but may never derive damage or contacts. Every opaque or strongly emphasized part of a contact VFX, including its side edges and tip, must remain inside that authority and receive focused center/edge regression coverage. New greatsword, axe, scythe, spear, or dual-weapon families must author reviewed family shapes instead of silently inheriting Balanced Slash.
- Keep weapon skill power separate from normal-hit tuning. `WeaponDefinition.damage` feeds weapon-scaled abilities; `basic_damage_minimum/maximum` own the integer normal-hit roll. Do not rebalance one by silently changing the other.
- Front-facing detached equipment must make the grip connection readable before implying anatomical handedness. Side grips remain close and above the torso midpoint unless a weapon family's weight deliberately requires a broader stance.
- Keep sword grade separate from animation duplication. Grades may reuse one weaponless body sheet and one `SwordAttackStyleDefinition`; author a new style only when the weapon family needs a meaningfully different orbit, extension, trail, or accent. Style data is presentation-only and must not silently alter authoritative reach, damage, knockback, or phase timing.
- Normal sword variety may cycle deterministic style-owned sweep directions and arc/extension multipliers when an authoritative wind-up begins. Keep the sequence readable, reset it when changing weapon definitions, and describe any visually stronger final sweep honestly unless gameplay authority separately grants a combo bonus.
- A true combo must be data-owned rather than inferred from visual cycling. Each accepted step snapshots its direction and owns timings, damage multiplier, movement, contact shape, control values, buffer/reset windows, and animation key; presentation may not redirect the step when later movement input arrives.
- Alternate or superseded character art must use a separate variant folder and complete presentation resource. Before an active-model replacement, preserve the previous full sheet set and `SpriteFrames` as a restorable variant unless the project owner explicitly requests permanent deletion after approving the replacement; never depend on filename history alone for a requested visual backup.
- Keep only active assets and maintained tools/tests. Delete rejected experiments and superseded processors after checking dependencies; Git history provides recovery. Do not create another tracked archive or leave obsolete regeneration commands in current docs.
- Left/right modular weapon attacks must be true screen-space mirrors unless the weapon explicitly requires asymmetric technique. Keep the trail center on the authored hand path rather than the face or actor origin; small scale/color accents may add impact but must remain presentation-only.
- Integrated weapon-and-hand art remains appropriate for non-modular actors whose silhouettes depend on it. Do not mix integrated and detached versions of the same active weapon without an explicit presentation owner.
- Compact service NPCs may use visible integrated arms and role tools when a stationary authored work animation depends on readable hand-to-tool contact. Treat this as an actor-specific action silhouette and keep body scale and foot baseline stable.
- Defeat presentation should use authored recoil/weaken/slump frames before a runtime fade. Keep active raster edges binary-alpha; translucency belongs to runtime modulation rather than partially transparent sprite fragments.
- Active hard-pixel sheets must use binary alpha only. Semi-transparent edge fragments are prohibited.
- Remove generated source mattes before nearest-neighbor reduction and fail processing when matte-family pixels remain connected to or isolated around an actor. Inspect transparent outputs over checkerboard, green grass, lime-corrupted terrain, and a dark floor; visible green/lime, magenta, blue, or dark background fringe is never an acceptable runtime pixel.
- Oversized ability VFX may use effect-only atlases with cells larger than the actor when that space preserves a peak plume, shock ring, or decay frame without shrinking it. Keep one stable local origin, rotate reusable directional effects through a presentation pivot, use a narrow bright core to communicate the real contact lane, and document all larger outer ribbons as cosmetic. Never bake an actor body, hand, or equipment grade into a reusable technique atlas.
- Cinematic character skills may coordinate `AnimatedSprite2D`, `AnimationPlayer`, CanvasLayer overlays, camera, shader, and audio presentation, but must release overlays and camera state on completion, cancel, defeat, pause, transition, and teardown. Screen cracks, black frames, letterboxing, and reality distortion never own hit resolution, invulnerability, or saved progression.
- Movement collision represents the underfoot footprint; hurtboxes represent the damageable body and remain separate shapes. Enemy movement and crowd-separation radii belong to `EnemyDefinition` and must be applied through `EnemyFootprintSystem` so physical collision and `NavigationAgent2D` cannot drift. Attack geometry remains ability-specific and must never be replaced by the movement circle merely for consistency.
- Palette reduction must use no dithering for the current style unless a later art-direction decision explicitly changes it.

## Environment Scene Organization

- Group visuals, collision, navigation, shadows, effects, audio, and interaction areas under clearly named owners.
- Do not add empty organizational nodes when a prop does not need that responsibility.
- Split tall objects into lower and upper visuals when correct player occlusion requires separate draw ordering.
- Place collision around the traversability footprint, not the full visible canopy, roof, or decorative silhouette.
- Keep navigation obstacles/regions consistent with collision unless a documented gameplay rule requires different behavior. Bake obstacle clearance for at least the largest movement radius expected to use that map, and verify routes around large blockers with that actor's physical footprint; do not mask a wedged route with teleport correction.
- A controller that owns a `NavigationAgent2D` must consume its next path position during active pursuit instead of moving on direct target bearing. Committed leaps or teleports must separately validate the destination against both navigation and the actor's physical footprint; collision-derived steering fallback may escape local prop contact but must not silently move an announced landing marker after commitment.
- Keep shadows presentation-only; shadows must not determine collision or damage.
- Use `Polygon2D` for an editable visual shadow and `CollisionPolygon2D` for an irregular static physics footprint. Never expect a visual polygon to participate in collision.
- Use Y-sorting within controlled world/prop boundaries and reserve fixed canvas layers or `z_index` bands for genuinely separate visual planes.
- Never manipulate draw order every frame when a stable scene hierarchy, Y-sort origin, or split sprite solves the relationship.
- Test each large prop from the front, behind, and both sides with the player before approving it for reuse.
- Safe-hub props follow the same separation as combat props: raster, shadow/glow, collision, interaction, and idle presentation remain independently replaceable.
- Side-facing service NPCs require matching lateral work geometry: place the usable surface on the actor-facing edge, compare the prop against the actor's native cell before import, and reject front-facing symmetry or landmark scale when the contract calls for a compact workstation.
- Crafting UI may report readiness and request a craft but must never spend or grant directly. One service validates the canonical recipe and all costs before mutation, reserves unique output ownership, spends one complete material batch, saves once, and rolls back authority snapshots on failure.
- Drag previews use logical canvas coordinates and offset themselves by the local grab point. Do not apply window-scale compensation manually; drop targets remain the only equipment mutation authority.
- Roll critical chance once per authoritative swing/strike activation, never once per victim in the same cleave. Carry the accepted result through `DamageInfo` and keep `CRIT` color/scale presentation-only. Clamp attack-speed, movement-speed, and critical-chance bonuses at their shared data/runtime boundaries.
- Equipment and crafting surfaces should fit the native 960x540 viewport without oversized empty panels. Formula rows reserve a small right-aligned output silhouette (or locked-box silhouette) so slot type is readable before the name; detail panels show concise deltas against the equipped reference without duplicating gameplay calculations.
- Ambient idle motion uses bounded tweens or animations. It must not move collision, interaction ranges, navigation footprints, or gameplay authority.
- Quiet UI emblems use one canonical engraving and animated light, never independently generated near-matching structural poses. Check actual title/loading silhouette at all frames and halfway phases, seam, pause behavior and hidden-process suspension. Decorative one-pixel UI specks fade in place rather than translate under pixel snapping.
- Generated landmark architecture uses one fixed raster. Animate a separate cropped energy layer; never rely on near-matching full-structure generations. Architecture-free stage portals keep one physical silhouette, ornaments and ground anchor. Animate registered currents through upper, middle, lower and central interior regions; vary rim lighting and internal hand shading without swapping differently shaped doorway poses or rotating the whole gate. Shared source canvas/union registration alone is insufficient: compare rendered alpha at every frame and halfway blend, test the loop seam, and verify pause. The stable-surface shader uses the actual AnimatedSprite frame clock and unique per-instance materials; replacing an atlas requires re-auditing its reference/registration data. Keep lightning/particles on a separately replaceable larger overlay whose opacity and independent reach are tier data: Normal has none; Mini Boss stays restrained; Boss extends beyond the doorway; God and Transcendent may cross a large part of the viewport. Never scale the base doorway merely to obtain far lightning. Each sheet preserves a stable center alignment, cell size, and seamless loop. Interaction collision and scene-transition authority remain stable and code-owned.
- Pixel-character ambient breathing should use integer-pixel, timer/animation-driven visual steps with a stable gameplay footprint; do not poll or translate the actor root every frame.
- Use the shared `EditorPreviewBackdrop` as a direct child when an isolated transparent asset is unreadable against Godot's dark 2D canvas. Editor previews must be context-gated, processing-disabled, collision-free, and absent from runtime drawing.

## Tilemaps and Modular Environments

- Build reusable terrain and prop sets instead of painting one-location-only combined images.
- Playable maps must preserve the established top-down/slightly angled top-down camera language through their full viewport. Upper map boundaries use in-world elevated terrain, cliffs, trees, rocks, water, and authored collision; never introduce a sky, horizon, distant side-view mountain, or scenic landscape that changes perspective.
- Support terrain transitions, ground variations, decorative overlays, collision, navigation, and foreground occlusion as separate data/layers where appropriate.
- Keep decorative variation independent from gameplay collision whenever possible.
- Reuse tile sources and terrain definitions across maps; do not duplicate a tileset solely to recolor or rearrange one level without a documented reason.
- Validate seams, transition coverage, collision edges, navigation continuity, and pixel alignment before content-scale painting.
- Save active combat-stage TileMap cells in the owning scene. Use `AuthoredGroundLayout` as the diffable composition source and `tools/bake_authored_ground.gd` when regenerating a whole map; ordinary local adjustments may then be painted and saved directly in Godot without runtime randomization.
- In authored ground legends, use `Vector2i(atlas_x, atlas_y)` for source 0 and `Vector3i(atlas_x, atlas_y, source_id)` only when a transition map intentionally combines registered TileSet sources.
- Use `AuthoredGroundLayout.empty_tile_keys` only for deliberate absent terrain such as a canyon or water reveal. Pair every exposed void with reviewed world collision and future navigation outlines; never infer a safe boundary from transparent pixels or the absence of a TileMap cell.
- Keep shared biome tiles under `assets/environment/<biome>/shared/`; keep genuinely region-specific tiles and props under `assets/environment/<biome>/<region>/`. Preserve generated source/clean boards under the matching `art_source/generated/environment/` hierarchy.
- Organic tree placement may be asymmetric. Landmark props must align to a visible path, threshold, plaza, encounter boundary, or authored symmetry and must not be scattered through empty space merely for variation.
- On even-width tilemaps, center a landmark between the paired middle columns only when its approach also uses both columns; snap single-cell service approaches to the owning doorway's exact tile center and preserve intentional terrain breaks around local aprons.
- Prefer maintainable Godot 4.7 tilemap tooling over custom placement code unless profiling or authoring requirements prove it insufficient.

## Asset Review Checklist

Before approving a sprite, prop, tile set, or environment scene, verify:

1. Pixel density, palette, lighting direction, and origin match the project baseline.
2. Silhouette and interaction state remain readable during combat.
3. Collision and navigation match the intended traversable footprint.
4. Foreground/background ordering works from every relevant approach direction.
5. The asset is reusable and does not contain unnecessary level-specific coupling.
6. Animation, effects, and shadows do not obscure hazards or player feedback.

## Version Control

- Keep commits focused and describe the player-facing or architectural outcome.
- Do not commit `.godot/` generated cache content.
- Do commit project settings, import metadata required by Godot, source assets, scenes, resources, scripts, and documentation.
- Update affected documentation in the same change as the code.

### Examiner rework import convention (Decision 136)

- Examiner action cells are 192x160 with foot baseline 128 and visual origin -48. Apply one standing-reference scale; never fit extended poses independently or anchor a downward thrust by its blade tip.
- Anticipation excludes contact frames. Contact animations begin at the controller damage boundary; permitted directional retargeting preserves frame/progress. Profile mirroring and reversed source rows are explicit importer mappings.
- Traversable floor engravings and ward plates must agree with independently authored world collision and exact protection geometry.

### Examiner gait and skill effects (Decision 137)

- Resolve complete connected actors across the whole source before cropping; reject merged figures and source-edge clipping. Runtime padding cannot prove the source tip survived extraction.
- Contact/passing gait poses must alternate legs. Preserve gait phase across turns and attach footsteps to planted contacts.
- Raster effects retain one scale and a reviewed shared contact origin. Keep damage marker bounds fixed to actual radii/lanes; animate the interior and texture. Descent shader safe holes read Court points/radius.

- For a generated replacement animation, use isolated approved character poses as identity references. Match mask, armor, coat, weapon, shading, and helmet-to-ground size beside idle/attack at runtime density. Weapon-inclusive silhouette height alone is not a body-scale measurement. Keep the chosen direction scale fixed across the whole cycle.

- Arena verdicts that bypass action i-frames must opt in on `DamageInfo`; retain normal armor/ward mitigation and separate explicit debug immunity. Earned-safe-zone geometry and visual shader flags must share the same active point list. Trial completion, death, and reset cancel pending authoritative hazards and their visuals.

### Examiner identity continuity (Decision 139)

Use the owner-approved ivory/navy/gold body sheets as the mandatory reference for any new Examiner action. Prefer composing their existing raise, release, landing and recovery poses with independently authored effects. Never regenerate a new character identity to obtain a spell effect. The Sun board is VFX-only, uses fixed cell scaling and padded complete silhouettes, and records source/prompt plus approved body hashes. New mechanics must expose distinct warning/contact/recovery timing without moving damage into the animation presenter.

- Examiner energy loops use fixed cells and stable core scale; continuous buildup is presentation-driven growth around those cells, not per-frame source fitting. Body bracing rotates around the established foot origin. Multi-projectile spectacles must retain a tested escape route, fixed warning geometry and bounded simultaneous audio/camera feedback.

### Randomized boss pressure and outcomes

- Random attacks must commit visible warning geometry before damage. Use seed injection for reproducible checks and bound concurrent threats; do not turn a moving target snapshot into hidden homing. Test arena edges as well as center.
- Keep encounter outcome authority separate from dialogue. Clear owned hazards before cinematics, restore input on completion/skip, and reject asynchronous callbacks from an earlier encounter binding. Reuse approved body poses when presenting new transitions.

### King and human-scale character reviews

For King locomotion, register horizontal position from the upper hair band, excluding the shoulder blade and moving arms, and retain one scale per direction. Source cell centers are not body anchors. Use a coherent source for idle and walking; keep accepted attack drawings intact during a locomotion correction. Canonical Sword locomotion uses its baked outline; the legacy outline shader remains only for unchanged skill/action art.

Judge walk cycles as coordinated body motion, not independent boot positions: include pelvis/chest silhouette changes, opposite arm swing, supported weapon weight and cloth follow-through. Multi-row source layouts for a single direction share one scale. When direction clips differ in frame count, retain normalized cycle phase and cycle duration; wrapping raw frame indices skips half-strides.

Decisions 142-143 keep King near the existing 26-28px standing height; active C atlases use padded 96x64 cells on y=48, centered at sprite position (0,-16). The prior 48x32/y30 set is visual rollback. Compare candidate art beside current runtime King at identical nearest-neighbor zoom before producing complete sheets. Do not infer a crown or ceremonial costume from his name, use Examiner as a human scale reference, or fit anatomy to weapon-inclusive bounds. Native pixel density and starter-adventurer readability govern future NPC comparisons too.

King C imports measure a fixed standing head-to-boot scale per direction/action board, exclude blade extent from anatomy, extract complete connected islands across nominal cell boundaries, and retain binary alpha. Back-facing contact uses the dedicated northward correction board. Never carry an old Godot resource UID onto a replacement script path: verify the actual loaded resource. Contact light is texture-mapped inside the authoritative polygon; no detached Line2D duplicate. Walk cadence follows equipment movement speed; action frames follow live phase durations.

Review complete runtime frame boards as well as source sheets. Reject wrong-facing, missing-blade and source-edge-clipped drawings even if the atlas has empty margins; a padded atlas alone is not proof of complete anatomy. Keep a stable approved guard/defeat hold when a candidate settle is defective. Remove dark magenta fringes without removing navy clothing or scarf colors. Floor effects use explicit authored ground contact points through build-up, impact and residue; never recenter on changing airborne-debris bounds. Test contact against the actual world hitbox and actor feet, distinguishing a pivot-local compensation from a world-space offset. A presentation sequence that outlives recovery needs its own bounded cleanup lifecycle.

### Evolving King assets and loadouts

For new techniques, retain C anatomy and 96×64/y48 body origins; enlarge separate VFX, not King. The Oath spin has eight poses in four directions. Storm/rupture atlases use fixed 192 px cells and fixed centers, black-matte removal and nearest filtering; never recenter each expanding debris frame. Generated source/prompt and deterministic import measurements live under the identity-owned King source folder. Original Oath audio is reproducible with `retired generation tool (recover from Git history only)`.

Explicitly duplicate each external slot Resource when constructing a mutable player loadout. Do not assume deep duplication of a Resource's exported array isolates every external element. Store stable IDs, not resource paths or current rank names. Presentation binds gameplay signals and disconnects on removal; detached HUD controls must not keep receiving cooldown events.

## Released skills and expandable loadouts

- Keep action commitment separate from released attack lifetime. A released attack snapshots its tuning, source, world point, damage and critical profile; never read a later cast's mutable component state to resolve that attack.
- Overlapping core/rim visuals require one explicit damage-tier choice per target, not two independent hitboxes that unintentionally stack damage.
- SkillLoadoutDefinition.SLOT_COUNT owns equipped capacity. Slot 10 displays key 0. Empty IDs represent unoccupied positions; preserve legacy choices during expansion and never turn migration into a reward grant.
- Temporary slow modifies bounded movement state with expiry; never edit shared EnemyDefinition speed. Boss-specific control eligibility remains explicit.

2026-10-13 maintenance: previous generation/comparison commands were retired; current output assets remain authoritative. New captures use ignored tmp/review/. See docs/maintenance/repository-cleanup.md.
