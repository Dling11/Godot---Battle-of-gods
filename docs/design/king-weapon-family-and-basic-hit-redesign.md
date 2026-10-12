# King basic-hit redesign and visible weapon families

**Current equipped families (2026-10-06):** Royal Greatsword, Iron Beard and Twinsteel equip through King catalog/Player/Bag with session F9 access. Iron Beard now plays five connected cuts: chop, rise, axe-head thrust, hop slam and whirlwind. Third hit leads with its cutting head and a broad white effect;25/0/60% walking and all native directional gait/idle remain. [Axe implementation](king-axe-cardinal-motion.md); other guides are king-greatsword-oathbound-motion.md and king-dual-sword-design.md. Acquisition/crafting remains pending; older four-cut/handle-jab/isolated notes are historical.

**Current axe V3 review (2026-10-04):** Owner requests actual huge reach, relaxed carry, back-stowed AFK and creative attack variety. Existing PowerShell launcher now selects an isolated five-move side/rising/down/hop/whirlwind review. Actual forward reach72px and side width108px; whirlwind68px radius reaches rear targets with outward knockback.48 registered body frames, one rigid axe and20 white raster FX frames; low carry transitions after4s inactivity to arms-down back stow. Optional per-step shapes/radial flags are combat data; visuals never award damage. Native496 checks plus melee/style regressions pass and190-frame GIF/gallery are recorded. Normal F5 weapon/equipment/skill/crafting promotion and full directions/gait remain pending. Earlier V2/current36px descriptions below are historical.

**First implemented candidate (2026-10-04):** Iron Beard axe now has a playable right-facing motion/contact proof: eight registered body-only poses, one canonical weapon and hand masks synchronized to real melee phases. retired generation tool (recover from Git history only) is stationary/rewardless with isolated/suppressed storage; native62 assertions pass. Source/prompt/registration and native gallery/GIF are preserved under the dated proof/review folders. Comparison contact remains the36px sword fan with10-12 basic damage,0.24/0.13/0.31s review timings and current cut sound. This does not select final axe balance, claim walking/other directions or install crafting. The owner accepts the collection model below (Decision180), not exact stage/cost assignments.

2026-10-04. Status: owner-authorized design/preparation (Decision179), six concept studies generated; runtime families and equipment animation are not implemented. The owner finds King's basic attacks sloppy/boring and authorizes Sword, GreatSword, Dual sword, Axe, Scythe, visible armor and helmets, with samples before full frame production. Stage10 remains a candidate introduction, not a required gate. Preserve current saves, King identity and functioning skills. Decision179 permits future visible King families beyond Decision071's signature-only visual restriction; the existing integrated sword remains runtime truth until a tested implementation replaces it.

## Verified implementation

Current player.tscn binds Spellward192x128 AtlasTextures with Body scale0.5. The old32x32 simple-reboot contract is historical, not the active production sheet. Match the current visible body at gameplay scale rather than adopting generated source dimensions as a new character size.

King uses integrated body/weapon artwork through player.tscn → spellward_frames.tres → KingSpellwardAnimation/KingGreatswordAnimation. Idle, movement, basic cuts and some skill poses contain the signature sword. uses_integrated_visual hides the detached WeaponVisual sprite. Equipping Varkuun Edge changes stats/critical chance but keeps the same sword art and chain.

Ownership, equipment UI, class compatibility, persistence, independent Basic Hit/Skill Power, weapon-owned contact shapes and combo tuning already exist. The three cuts use distinct attack/return_cut/heavy_cleave clips and100/115/165% damage, but all share one36-forward/44-wide fan. SwordAttackStyleDefinition describes legacy detached presentation; it does not automatically replace King's integrated weapon. New family animation routing, grip/depth registration and skill transitions are additional work, not a completed modular King feature.

## Recommended next slice

Redesign the basic combo at gameplay scale before replacing the whole character. Aim for readable fast opening cut, a distinct reverse cut, then a planted heavy finisher with visible weight transfer, compact weapon-bound crescent and separate contact/recovery. The actual contact window must agree with the strongest slash drawing; recoveries should permit the intended input buffer/dodge behavior. Do not enlarge only decorative light while retaining misleading reach.

First build one short direction/finisher proof with current King silhouette and test against one moving enemy and a crowd. Review body scale, fixed feet, weapon length/grip, anticipation, contact, recovery and how the slash blends over terrain. Then author the other directions/chain only if the proof is useful. Existing three-cut gameplay and skills remain while the comparison is prepared. No new Momentum bar or competing Resolve resource is assumed.

## Equipment art strategy

| Change | Reusable work | Additional artwork |
|---|---|---|
| Same-family stat/essence grade | Current body, signature sword, chain and skills | Item icon/description; optional explicitly authored effect |
| Visibly different sword of compatible proportions | One weapon-family body/hand animation set after a modular split | Blade appearance with reviewed pose/direction registration |
| Much larger greatsword | Compatible two-handed poses where the grip/weight still fits | Larger carry/attack silhouette and selected poses; new family contact/timing |
| Axe | Character identity, generic movement/combat/equipment systems | Axe-family grip, carry, wind-up/contact/follow-through and weapon drawings |

Target cost scales with a few weapon families, not the total number of loot items. This reuse is proposed for King: his current baked sword must first be removed/re-authored in affected poses or retained in a separate integrated family set. Modular presentation must follow authored hands with proper foreground/background depth; a floating rotating PNG does not meet his approved style. Same-family item skins are not automatically compatible if hilt, length or grip differs substantially.

A hybrid is worth comparing: reusable body plus registered weapon layer for compatible shapes, and integrated pose corrections for difficult two-handed contacts. An integrated set per family is an alternative with stronger hand contact but more art per visible variant. Do not promise that every axe works with the existing sword sheet.

## Skills and progression proposal

2026-10-04 owner question: the expanded axe is a basic-combo presentation/contact proof; existing skill rules, ranges, damage and controls are unchanged. Recommendation remains keeping King-specific techniques and explicitly stowing/drawing the equipped weapon around casts. A skill that must use the actual equipped axe requires family-specific poses. This is a recommendation awaiting owner acceptance, not an installed skill redesign.

Keep King-specific summoned spectral weapons as personal techniques rather than redrawing every skill for every equipped blade. A visibly equipped axe would need an intentional transition to summoned-sword poses, such as concealing/stowing its layer during the technique. This proposed rule requires owner acceptance; it is not yet installed. If skills must wield the actual equipped axe, those particular skill poses also need family variants.

Improve the starting basic combo now; early combat should be enjoyable before Stage10. Stage10 is a candidate reward for a new heavy family or awakened stance with a travelling finisher wave. It is not a current route/reward addition. Keep Varkuun useful and avoid deleting existing item IDs or imposing an equipment entry gate. The exact Stage10 acquisition and family choice remain open.

A large travelling wave changes contact gameplay and should be deliberately earned/budgeted as a final cut, counter or cooldown technique. Author travel/range, per-target deduplication and readable damage area separately from artwork. Avoid giving every opening hit skill-sized coverage or silently inflating all skill damage when a slower heavy weapon gains Basic Hit. The existing independent Skill Power field supports this distinction.

## Open choices / proof before production

Choose a first heavy-family direction (greatsword is closest to King's current identity; axe is a larger art change), compare the hybrid/integrated approach on one real pose, and decide whether visible equipment applies only to basics/carry or to all skills. Native feel, cardinal/diagonal contacts, enemy tells, input buffering/dodge, swap/reset/save compatibility and a first/repeated crowded attack profile remain required before promotion. No new King animation, visible weapon swapping, huge wave or Stage10 reward is completed by this document.

## Generated samples and reference scope

**Compact V2 refinement,2026-10-04:** Owner permits simplifying/recreating armor and weapons to match King's body. New equipment_design_v2_2026_10_04/ sources show Light Leather/Heartwood/Forged Guard front/back designs and weapon-only axe/scythe options. Native960x540 previews use one1/16 source scale beside current Body0.5 with4x nearest enlargement; they do not equip an actor or establish motion/rigid grip correctness. Heartwood is recommended, not selected. Prefer one major chest shape/small patches, visible face/scarf and simple functional weapon silhouettes. Exact prompts/provenance/alpha audit are retained. Prior detailed armor remains an earlier concept and prior axe/scythe poses remain rejected.

**Owner correction, 2026-10-04:** The axe and scythe designs are rejected. Preserve their sources as rejected studies, not reference weapons for future King animation. For new weapons, first generate weapon-only design choices and settle silhouette, blade/head shape, haft/grip, materials, details and intended gameplay size. Show the design before attaching it to King or multiplying poses. The owner asks for cooler weapon designs; no particular replacement silhouette is selected yet. Other studies remain concepts and are not implicitly approved by this correction.

Six built-in image_gen studies use the current exact King reference. Sources, exact prompts, provenance and source_audit.json are in art_source/generated/characters/king/equipment_families_2026_10_04/. Each weapon has four carry directions followed by eight right-facing attack poses. Armor has Leather Scout, Steel Vanguard and Runic Guard front/back appearances plus matching open helmets. All remain concepts: source alpha is not binary and content overlaps nominal cells. No walk, complete directional combo, equipment overlay or production registration is claimed.

The owner suggests Pixel Slayer Saga after seeing an ad. Its [official listing](https://apps.apple.com/ph/app/pixel-slayer-saga/id6795060070) explicitly advertises weapon-dependent moves and customized looks. Use that as inspiration for recognizable silhouettes and family-specific action identity. The exact ad, in-game animation timing and underlying asset pipeline have not been inspected. The studies were already generating when the reference arrived and do not use that game's artwork. King remains an actively controlled Battle of Gods character.

| Family | Proposed feel | Contact concern to prove |
|---|---|---|
| Sword | Quick opener, distinct reverse cut, committed final slice | Precision/readability without decorative reach inflation |
| GreatSword | Loaded two-handed cleave and planted recovery | Both hands, blade rigidity, heavy timing and actual broad contact |
| Dual sword | Alternating blades with body counter-rotation | Deliberate separate contact windows and bounded combined damage |
| Axe | Overhead/diagonal chop and slower recovery | Haft continuity, anticipation, impact and punishable recovery |
| Scythe | Hooked reaping sweep | Outer blade contact versus near-hilt space; test before adding a dead zone |

Armor and helmets should reuse registered body action poses through authored anchors/masks or selective integrated corrections. An open face keeps King recognizable; pendants/rings/talismans need no world sprite. No arbitrary overlay is assumed to fit every pose.

## Ordered production plan

Before step1, establish the weapon design independently of character posing: prepare a small weapon-only choice board, a native-size readability sample and the selected weapon's fixed proportions/grip reference. Axe and scythe must restart here. Use the chosen design consistently in subsequent carry/attack drawings; do not let each pose invent its own weapon. This is the owner's explicit design-review order, not an additional deployment permission requirement.

1. Prove one heavy right-facing attack at current body size. Redraw/re-register any drifting grip or scale; retain anticipation, contact, follow-through and recovery. Measure feet independently of blade bounds.
2. Bind contact drawings to authoritative phase windows. Current basic art hardcodes wind-up0–2/active3–4/recovery5–7; do not blindly reuse that map for a source whose strongest contact is pose4. Family presentation metadata should describe its actual windows while gameplay owns hit activation.
3. Expand the accepted action to four cardinal directions and its intended chain. Verify diagonal aiming, actual reach and enemy response with one moving target and a crowd. Keep existing skills usable while equip-to-summoned-weapon transitions are decided.
4. Author real movement before normal equipment swapping: idle2 and walk8 per cardinal direction, with alternating planted feet/passing poses and connected carry grips. Extend dash/hurt/defeat after the family locomotion proof; shared body poses are reused where they actually fit.
5. Add equipment-family routing and compatible item appearances, then armor/helmet masks and action depth. Swap through existing equipment events, preserve IDs and saves, and verify pause/load/unequip/skill transitions. No new global resource or per-frame inventory lookup is needed.

Suggested body action budget per complete family: idle8 poses, walk32, three8-pose cuts in four directions96, dash16, hurt16, defeat24 (192 total before any proven reuse). This is a planning estimate, not generated content or a requirement to redraw192 poses per loot item. Dual-sword contact count is a gameplay decision separate from this art budget. Bulk generation follows the one-action proof, avoiding a large set of inconsistent sheets.

## Godot community and official animation research — 2026-10-04

This research was conducted after the initial combined character/weapon samples and the owner's axe/scythe rejection. Those samples were not based on a previously researched community rig. No community code or artwork has been copied into the project.

Primary sources:

- [Godot community: reusable weapon and shield animation](https://forum.godotengine.org/t/how-to-create-a-stable-weapon-system/100168): a participant recommends animating a parent Node2D/Marker2D and swapping its WeaponSprite. This is one first-hand example (Godot4.3), not evidence that all games use this method or that it solves King's baked sword.
- [Marker2D class](https://docs.godotengine.org/en/stable/classes/class_marker2d.html): an editable position marker with ordinary Node2D behavior; it does not automatically discover drawn hands or enforce a grip.
- [AnimatedSprite2D class](https://docs.godotengine.org/en/stable/classes/class_animatedsprite2d.html): SpriteFrames, animation/frame state, frame_changed and animation_changed permit synchronized frame-based presentation. The docs also identify subpixel centering as a pixel-art issue.
- [Godot cutout animation](https://docs.godotengine.org/en/stable/tutorials/animation/cutout_animation.html): discusses pivots, parent-relative limb parts, cel animation for complex hands/feet and front/back ordering. The page explicitly warns that its tutorial content has not been updated for4.7; its old editor IK instructions must not be treated as a verified current runtime IK solution.
- [Bone2D class](https://docs.godotengine.org/en/stable/classes/class_bone2d.html): establishes current bone-chain primitives as an available alternative. No skeleton/IK implementation or native pixel-quality comparison is completed here.

| Approach | Holding/swing construction | King tradeoff |
|---|---|---|
| Integrated drawn frames | Body, hands and weapon are drawn together per pose | Strong contact control, but visible item variants cost more art |
| Drawn body + registered weapon layer | Each action/direction/frame supplies hand position, weapon orientation/art frame and layer order; weapon grip aligns to that hand | Compatible item reuse; requires removing King's baked sword and authoring real grips |
| Cutout/bone rig | Shoulder/arm/hand form a parent chain; weapon follows a hand mount while limb parts rotate | Reusable posing, but pixel silhouette, joints and depth require a native-quality proof |

Recommended proof remains a hybrid, not a completed implementation: retain drawn pixel body motion, add explicitly registered weapon/hand layers for compatible poses, and use integrated corrections where two-handed contact or perspective cannot be kept clean. A full cutout rewrite is not presumed necessary.

### How the arm actually holds the weapon

1. Establish one canonical weapon design with grip position(s), dimensions and perspective references. Two-handed weapons need compatible handle spacing; dual swords need two independent hand/grip records.
2. Draw the matching arm/hand/body poses without the old sword, keeping connected shoulders/elbows and planted feet. A Marker2D cannot infer these coordinates from a PNG.
3. For each animation/direction/frame, record the hand point in body-local coordinates, weapon angle or authored weapon drawing, and front/back visibility. Offset the weapon texture so its grip is at the mount origin; never pivot around the image center by default. Account for centered Sprite2D offsets and the common0.5 Body scale.
4. Align grip to hand in that same coordinate space. For a two-handed rigid weapon, verify the second hand against the transformed second grip; incompatible hand spacing requires a new pose or weapon variant, not stretching the limb/blade to hide the error.
5. Draw fingers/foreground hand pixels over the handle where needed; direction and swing may put the weapon behind the torso. A single whole-weapon Z change cannot solve every case where part of the shaft passes behind the body, so use authored masks/split layers or an integrated pose.
6. Synchronize body frame, grip record and weapon drawing from the same action/frame state. Refresh on equip/animation/frame changes and initial setup, not by searching inventory each render frame. Existing combat phases still own damage and contact; the visual mount does not become a moving damage collider by accident.

Use drawn angled weapon frames where free sprite rotation damages the pixel silhouette. Nearest sampling and pixel snapping are baseline settings, not guarantees of identical pixel shapes at arbitrary angles. Body/weapon density, scale and rigid dimensions stay fixed; do not resize each frame to its occupied bounds.

The native proof must show one approved design in a carry pose and a short anticipation/contact/recovery sequence at normal King scale, including the side/back grip and a two-handed contact if applicable. Inspect the hands/feet/occlusion, then test contact against a moving enemy. Axe/scythe weapon-only design selection remains the first task before producing their character poses.

## Candidate armor and weapon acquisition cadence — 2026-10-04

Owner now approves the compact V2 art style. This approves the visual direction, not a specific weapon variant or the stage/crafting rules proposed below.

Status: recommendation for owner discussion, not accepted unlocks or implemented equipment content. Live Nema Rootforge already crafts Varkuun Edge and five core armor pieces after the Stage V category/seal and exact material/gold requirements; Stage VI is playable and Stage VII remains planned. Existing Varkuun ownership/reward IDs stay valid.

Recommended combined cadence: Stages I–II retain a readable starter outfit and gather basic materials; III–IV may introduce a small optional early armor tier through separate starter recipes; V retains its meaningful core-set milestone, with visible equipment art added to the existing pieces. Avoid one complete new outfit per stage. Early armor recipes would be new content with their own unlocks, not a removal of the existing V seal.

Stages VI–VII are a candidate introduction for a first alternate weapon-family blueprint and deterministic crafting choice. Stage clears could unlock a known recipe; enemy materials and Nema's existing Rootforge produce the chosen item. Keep Varkuun Edge useful and improve King's starter attacks immediately, so the new family adds playstyle rather than delaying enjoyable combat. Exact stage, first family, recipe costs and clear-reward wiring remain open. Scythe can be a later specialized recipe once its weapon-only design and swing proof are selected. Existing VIII accessory milestone remains the baseline.

First production priority: settle weapon-only references and one armor appearance, prove equipped King motion, then add visible versions of existing core equipment before creating numerous recipes or new tiers. No new drops, blueprints, early recipe category, Stage VII route or armor layer is completed by this recommendation.

## Recommended weapon collection and recipe progression — 2026-10-04

Status: owner accepted this crafting-led collection direction on2026-10-04 (Decision180). Runtime collection migration remains pending. Stage11 axe/Stage20 weapon examples are hypothetical; no acquisition stage is assigned by this discussion.

Separate three things: a weapon family determines the authored fighting style; an item variant determines a compatible design and bounded tuning; its blueprint/material requirements determine acquisition. Early campaign milestones should offer a small meaningful choice of families. Later stages introduce stronger or specialized variants, boss designs and optional techniques within those families, rather than assigning every region one compulsory weapon type.

Use crafting as the main collection path: authored clears/discoveries unlock known blueprints, encounters supply purposeful materials, and Nema's existing Rootforge crafts the player's choice. Boss catalysts should have guaranteed milestone payouts. Give several compatible recipes a common usable material pool so players choose what to spend on. Preserve earlier weapon relevance through handling and roles; improve King's starter basic attacks now rather than withholding enjoyable combat until a later weapon stage.

Players may own many distinct weapon IDs and equip one at a time. Initially keep one owned copy per authored design, consistent with current unique crafting; repeated identical weapons, random affixes, dismantling and rerolling require separate economy/ownership work and are not assumed. Prototype two family choices with a few meaningful variants before multiplying to the full five-family roster. Each family reuses proven body/hand action poses for compatible item shapes; unusual grip/length/depth still requires corrections.

Candidate later-stage rewards include a new axe blade/material/handling variant for an existing axe user, a specialized scythe recipe, or a clearly budgeted authored technique. They need not invalidate earlier swords or force the player into a new family. Exact unlock stages, first family, recipe costs and trait rules remain open. Keep the Stage V Varkuun/core-set milestone and existing item IDs useful; the VIII accessory baseline is unchanged.

Implementation boundary from live inspection: CraftingService already supports deterministic one-output transactions and rejects already-owned equipment, but resolves outputs through the fixed Stage5CoreEquipment catalog and recognizes the existing Forest core seal. RecipeDefinition data alone cannot make arbitrary new weapons craftable. Before adding real recipes, generalize the canonical equipment catalog/unlock lookup with explicit seal rules while retaining material/gold/output rollback, safe-point saving, unique IDs and old profile compatibility. Full family/equipment routing remains a separate dependency; a first isolated right-facing axe pose observer is now implemented.

2026-10-13 maintenance: previous generation/comparison commands were retired; current output assets remain authoritative. New captures use ignored tmp/review/. See docs/maintenance/repository-cleanup.md.
