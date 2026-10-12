# Stage 5 Boss Content Contract

## Status

Identity, standing/idle, walking, reaction, melee, jump, and root-prison families now drive both the F8 proof and the production Stage 5 encounter. Varkuun's display name, health-tier jump rules, entrance, portrait dialogue, named boss HUD, dedicated music, and real-recording action audio are implemented. The Stage V milestone reward remains unimplemented.

## Naming direction

- The approved boss-bar identity is `Varkuun, Lord of the Withered Grove`.
- Production paths retain the stable `stage_5_boss` identifier; display lore does not churn technical asset paths.

## Approved identity

- A massive hunched humanoid forest guardian with distorted root limbs.
- Enormous asymmetric root arms support future sweeping and slamming attacks.
- A layered dead-bark shell splits across the torso and reveals a restrained toxic-lime core inside a dark hollow.
- Thick planted root feet and heavy legs communicate weight without making the boss stationary.
- Broken chest plates support a future armor-break silhouette and phase transition.
- Dead umber, bruised maroon, muted plum-violet, sparse toxic lime, near-black cavities, and restrained bone highlights remain the palette direction.

The approved concept source is `art_source/generated/characters/enemies/stage_5_boss/stage_5_boss_identity_approved.png`. The small crowned figure generated inside that concept is not King, is not approved character art, and must never define runtime scale or be extracted as an asset.

## Scale boundary

- The boss must be unmistakably larger than the Rootbound Husk mini-boss.
- Target runtime standing height is approximately `1.35-1.5x` the Husk, with roughly `2.5-3x` King's visual mass.
- King should visually reach around the boss's waist/lower torso.
- The complete boss must remain visible during ordinary play and leave meaningful dodge space around it.
- Stage 10 retains colossal, arena-transforming, or screen-dominating boss scale. Stage 5 must not consume that escalation.

Likely runtime action cells are `112x96` or `128x112`, but final cell size is not approved until one normalized directional standing proof is reviewed at 960x540.

## Approval boundary

The concept approves anatomy, silhouette, palette direction, and relative size intent only. Before animation generation, separately approve:

1. The boss's gameplay mechanics and phase rules.
2. A true gameplay-scale standing proof beside the actual King and Husk sprites.
3. Direction order, exact frame budgets, foot baseline, and action/VFX separation.
4. Boss reward identity and Stage 5 crafting-unlock contract.

Do not generate a large animation package until these points are locked.

## Phase 1 standing candidate

- Generated source: `art_source/generated/characters/enemies/stage_5_boss/stage_5_boss_idle_source_v1.png`
- Chroma-clean source: `art_source/cleaned/characters/enemies/stage_5_boss/stage_5_boss_idle_clean_v1.png`
- Exact-grid candidate: `historical Git-only review/characters/enemies/stage_5_boss/stage_5_boss_idle_sheet_112x96_candidate.png`
- Direction/idle review: `historical Git-only review/characters/enemies/stage_5_boss/stage_5_boss_idle_sheet_3x_review.png`
- True scale comparison: `historical Git-only review/characters/enemies/stage_5_boss/stage_5_boss_real_scale_comparison_4x.png`
- Deterministic processor: `retired generation tool (recover from Git history only)`

The candidate uses exactly four columns by four `down/left/right/up` rows, one shared `0.264407` scale, 112x96 cells, local y=90 foot contact, binary alpha, and all sixteen generated poses. Its 78-pixel maximum standing height is approximately 1.4 times the active Husk down-frame height. The owner approved this checkpoint on 2026-08-14.

## Phase 2 walking candidate

- Generated source: `art_source/generated/characters/enemies/stage_5_boss/stage_5_boss_walk_source_v1.png`
- Chroma-clean source: `art_source/cleaned/characters/enemies/stage_5_boss/stage_5_boss_walk_clean_v1.png`
- Exact-grid candidate: `historical Git-only review/characters/enemies/stage_5_boss/stage_5_boss_walk_sheet_112x96_candidate.png`
- Static review: `historical Git-only review/characters/enemies/stage_5_boss/stage_5_boss_walk_sheet_2x_review.png`
- Animated review: `historical Git-only review/characters/enemies/stage_5_boss/stage_5_boss_walk_all_directions_preview.gif`
- Deterministic processor: `retired generation tool (recover from Git history only)`

The walking candidate uses six chronological gait frames in each `down/left/right/up` row: planted push, weight transfer, passing step, opposite plant, opposite transfer, and opposite passing step. All 24 cells are non-empty and byte-distinct; the processor uses one fixed scale per direction derived from the approved idle stature, 112x96 cells, y=90 foot contact, and binary alpha. The owner approved this checkpoint on 2026-08-14. Basic attacks and jump-skill families remain separate future checkpoints.

## Phase 3 hurt and defeat candidate

- Generated parent sheets: `stage_5_boss_reaction_hurt_source_v1.png` and `stage_5_boss_reaction_defeat_source_v1.png`
- Chroma-clean parent sheets: matching files under `art_source/cleaned/characters/enemies/stage_5_boss/`
- Exact-grid candidate: `historical Git-only review/characters/enemies/stage_5_boss/stage_5_boss_reaction_sheet_144x112_candidate.png`
- Static and animated reviews: `stage_5_boss_reaction_sheet_2x_review.png` and `stage_5_boss_reaction_all_directions_preview.gif`
- Deterministic assembler: `retired generation tool (recover from Git history only)`

This review family uses eight chronological frames in each `down/left/right/up` row: three reusable hurt/recovery poses followed by fatal buckle, one-knee collapse, committed fall, grounded defeat, and final settle. All 32 cells are non-empty and byte-distinct. Wider 144x112 cells prevent the fallen body from forcing a scale reduction; local y=98 preserves the approved sheets' world-space contact offset of 42 pixels below cell center. It remains source/review art until owner approval and does not yet define runtime death timing.

## Phase 4 basic melee candidate

- Generated parent sheets: `stage_5_boss_basic_attack_windup_source_v1.png` and `stage_5_boss_basic_attack_contact_source_v1.png`
- Chroma-clean parent sheets: matching files under `art_source/cleaned/characters/enemies/stage_5_boss/`
- Exact-grid candidate: `historical Git-only review/characters/enemies/stage_5_boss/stage_5_boss_basic_attack_sheet_144x112_candidate.png`
- Static and animated reviews: `stage_5_boss_basic_attack_sheet_2x_review.png` and `stage_5_boss_basic_attack_all_directions_preview.gif`
- Deterministic assembler: `retired generation tool (recover from Git history only)`

The original basic melee is a close-range asymmetric root-arm **lunge**, not a sweep, skill, or root summon. Each `down/left/right/up` row retains its eight authored forward-extension poses and activates one controller-owned contact. A separate heavy overhead slap owns another eight-pose row per direction: neutral anticipation, lift, high cock, held apex, downward release, planted-hand contact, compressed brace, and pullback/recovery. `retired generation tool (recover from Git history only)` extracts all 32 connected actors globally, keeps every generated pose, normalizes them into 144x112 cells on y=101, and writes binary alpha. Runtime alternates lunge and slap through separate states and hitboxes; neither atlas grants damage or bakes impact VFX.

## Phase 5 jumping skill candidate

- Generated body parents: `stage_5_boss_jump_takeoff_source_v1.png` and `stage_5_boss_jump_landing_source_v1.png`
- Generated impact source: `stage_5_boss_jump_impact_source_v1.png`
- Chroma-clean sources: matching files under `art_source/cleaned/characters/enemies/stage_5_boss/`
- Exact body candidate: `stage_5_boss_jump_body_sheet_144x112_candidate.png`
- Exact impact candidate: `stage_5_boss_jump_impact_sheet_192x112_candidate.png`
- Animated reviews: `stage_5_boss_jump_body_all_directions_preview.gif` and `stage_5_boss_jump_impact_preview.gif`
- Deterministic processors: `retired generation tool (recover from Git history only)` and `retired generation tool (recover from Git history only)`

The body uses eight poses in every `down/left/right/up` row: deep compression, explosive extension, rising tuck, apex hang, descent tuck, pre-contact brace, maximum impact compression, and heavy rebound. The actor root—not the atlas—must own the real world-space arc and target travel. All 32 body cells remain unique, binary-alpha, fixed-scale, and share the action-family y=98 body baseline. The generated right-facing impact/rebound drifted toward a rear view; the processor therefore uses exact horizontal counterparts of the approved left-profile poses for only those two cells while preserving the other 30 generated frames.

The separate eight-frame impact uses 192x112 cells and one stable center: pressure mark, first contact, explosive peak, expanding shockwave, radial fracture, debris settling, residual crater, and persistent final crater. Body frame seven is the single authoritative landing contact; impact frame two begins at that boundary. The narrow lime center communicates the real damage region, while the far ring and debris remain cosmetic. The generated horizontal source drifts across equal eighth boundaries, so its processor assigns complete connected pieces to the nearest real frame center; crop-first slicing is forbidden because it displays neighboring-frame fragments at the left/right edges. Runtime places authored impact y=82 exactly on the boss-foot world anchor. A separate six-frame open-center root-spike eruption rises, peaks, retracts, and hides while the crater remains world-locked, outlives body recovery briefly, and fades independently. A short landing camera shake is presentation-only and triggers even when King dodges.

## Isolated runtime proof

`res://levels/stage_5_boss_test/stage_5_boss_test.tscn` and the Admin Combat Lab place real King against the provisional four-action controller. The aggressive feel-test uses 58 px/s movement, 480 acceleration, a 9 fps walk, a 0.62/0.12/0.66-second lunge, and a 0.60/0.12/0.54-second slap. Jump count is current-health-driven and repeatable: exact 80-100% uses one; below 80% alternates two/three; exact 30% or lower cycles three/four/five. Multi-jumps reuse approved body/impact families with direct, 46-pixel velocity lead, 28+42-pixel perpendicular cutoff, opposite-side cutoff when a fifth jump exists, and direct final targeting. Warnings remain fixed once shown. Mid-health chains use 0.58-second travel, 0.18 intermediate recovery, and a 120% final slam. Low health uses 0.42 travel, 0.10 recovery, a 150% final slam, and 0.45/0.35 root warning/tracking. Prison begins only after the finisher and retains its 2.2-second five-Dash escape plus positional 300 damage. Prison recovery starts the tier's reuse cooldown. Values remain provisional.

Both review arenas and production Stage 5 use `res://ui/boss/boss_health_hud.tscn`. It binds the real boss `HealthComponent`, displays Varkuun's approved title/context, exact HP, an immediate crimson value with delayed orange loss, and Phase I/II/III at the authoritative 80/30 boundaries. The 30% and 80% ticks communicate those thresholds without calculating them. The boss actor has no local `EnemyHealthBar`; a scene must own the one active top-screen binding.

2026-10-13 maintenance: previous generation/comparison commands were retired; current output assets remain authoritative. New captures use ignored tmp/review/. See docs/maintenance/repository-cleanup.md.
