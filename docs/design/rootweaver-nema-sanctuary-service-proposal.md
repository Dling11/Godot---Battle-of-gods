# Rootweaver Nema Sanctuary Service Proposal

- **Status:** Owner-approved and implemented through the atomic Segment 5 service; Decisions 071 and 120 route outputs through character-owned equipment and validated crafting
- **Prepared:** 2026-07-29
- **Owning production segment:** Forest Segment 4
- **Current concept source:** `art_source/generated/characters/npcs/rootweaver/rootweaver_nema_grove_smith_concept_v3_source.png`
- **Superseded compact concept:** `art_source/generated/characters/npcs/rootweaver/rootweaver_nema_service_concept_v2_source.png`
- **Rejected first concept:** `art_source/generated/characters/npcs/rootweaver/rootweaver_nema_service_concept_source.png`

## Product Clarification

The Rootweaver is a friendly Sanctuary artisan, not a monster. She transforms collected creature and regional materials into deterministic essences and relics that strengthen a character without replacing their signature visible combat identity.

The separate future Stage IV monster remains an unnamed armored, hide-bearing Forest beast. Its visible hide and bark plating will justify the first leather and bark-plate materials.

## Recommended Identity

**Name:** Rootweaver Nema

**Role title:** Grove Smith of the Living Rootforge

**Identity:** Nema is an adult human grove blacksmith who repairs and reforges things other artisans consider ruined. She studies how roots, cloth, resin, bark, hide, and monster remnants retain the strain that shaped them, then heat-binds those memories into practical equipment. She is athletic, attractive, self-assured, clearly mortal, and friendly, with no Rootbound corruption or monster anatomy.

**Personality:**

- Confident, observant, and economical with words
- Warm with a dry, slightly playful edge rather than mascot cheerfulness
- Treats materials as evidence of survival rather than trophies
- Practical enough to disagree with mystical exaggeration

**Service separation:**

- Eira awakens abilities already carried by a playable soul.
- Orren currently sells ordinary forged weapons and may later temper simple mortal essences.
- Nema grove-forges deterministic Weapon Essences, Body/Hand/Foot Relics, and later accessories from earned organic and monster materials.

## Narrative Relationship

Nema recognizes that King carries materials marked by unusual pressure: Mire flexibility, Rootling tension, Thrall wear, Bramble resistance, and the Husk's corrupted endurance. She does not grant power freely. She teaches him to preserve what a material survived, then combines root tension, controlled heat, hammer pressure, and living thread to bind it into a useful relic.

Her first service appearance may occur immediately in Sanctuary, but the menu must honestly show that core-gear crafting remains sealed until the planned Stage V milestone. Stages VI-VII supply accessory-preparation materials and blueprints, Stage VIII permanently unlocks standard accessories, and Stage X permanently unlocks relic/signature crafting.

## Visual Contract

### Character

- Clearly adult human woman; never a tree person, witch monster, child, or Rootbound creature
- Compact Sanctuary-compatible proportions: oversized slightly boxy head, narrow tiny body, tiny grounded feet
- Confident kind black eyes, one small soot mark, and a subtly playful expression
- Long dark-auburn hair tied into one practical side braid
- Muted moss leather forge apron over a dark fitted work shirt, sturdy belt, and compact bracers
- Compact bark-brown, muted-moss, warm-cloth, relic-gold palette with restrained violet stitching
- Upper-left world lighting and hard pixel clusters
- Two integrated work-role props held by visible arms:
  - compact root-forging hammer
  - tongs drawing one strand of restrained relic-gold living thread
- No antlers, horns, plant face, grandmother hood, gray hair, tall anatomy, pin-up armor, combat weapon, or excessive magical aura

The accepted grove-smith concept establishes identity, materials, portrait, and Rootforge language. A separate generated 4x2 actor source board was component-isolated and normalized through `retired generation tool (recover from Git history only)` into exact native-style `48x48` cells. Visible arms/tools are a deliberate Nema-owned work-animation silhouette and do not define playable-character anatomy.

### Runtime actor package

```text
assets/characters/npcs/rootweaver/
  rootweaver_nema_service_sheet_48x48.png
  rootweaver_nema_sprite_frames.tres
  rootweaver_nema_portrait_96x96.png

entities/npcs/rootweaver/
  rootweaver_nema.tscn

art_source/generated/characters/npcs/rootweaver/
  rootweaver_nema_service_concept_source.png        # rejected realistic first pass
  rootweaver_nema_service_concept_v2_source.png     # superseded elderly compact proposal
  rootweaver_nema_grove_smith_concept_v3_source.png # current female grove-smith proposal
  rootweaver_nema_service_source.png              # superseded front-facing board
  rootweaver_nema_service_side_source.png         # current magenta side-facing source
  rootweaver_nema_service_clean.png
  rootweaver_nema_portrait_source.png
  rootweaver_nema_portrait_clean.png
```

- Runtime service sheet: `192x96`, eight `48x48` cells
- Row 0: four-frame `idle`
- Row 1: four-frame `work`
- Screen-left three-quarter stationary Sanctuary service presentation; no fake four-direction locomotion
- Every frame retains at least four transparent pixels below the complete boots and nine pixels of horizontal safety margin
- One stable bottom-center foot origin matching Eira and Orren
- `AnimatedSprite2D` exposes named `idle` and `work` animations
- Idle: restrained one-pixel breath, braid shift, stable feet
- Work: tongs present living thread, hammer rises and lands once, then the actor recovers
- Portrait: separate reusable `96x96` transparent pixel portrait for dialogue, crafting, and future codex use
- Shadow, collision, interaction trigger, timed work loop, and strike audio remain separate scene presentation

## Living Rootforge Workshop

Nema should use an open crafting nook rather than a third closed house. The recommended **Living Rootforge** is a low root-wood pavilion with:

- root-wrapped stone anvil
- compact amber-green ember brazier
- small fiber-weaving frame
- hanging organic materials and tool rack
- one warm lantern
- restrained moss and violet stitch accents
- no character baked into the structure

The open front makes crafting readable. The living-root anvil, organic material rack, and amber-green brazier distinguish Nema from Eira's enclosed violet lodge and Orren's ordinary iron workshop.

### Runtime workshop package

```text
assets/environment/sanctuary/services/rootweaver/
  rootweaver_living_rootforge_176x144.png

environment/props/sanctuary/rootweaver_living_rootforge/
  rootweaver_living_rootforge.tscn

art_source/generated/environment/sanctuary/services/rootweaver/
  rootweaver_living_rootforge_source.png
  rootweaver_living_rootforge_clean.png
```

- Complete bottom-center origin on a `176x144` runtime canvas
- Separate rear-rack and central-anvil collision; the broad front/side approach remains open
- Navigation footprint follows collision rather than the visible canopy
- Y-sorted with Sanctuary actors and buildings
- Lantern/forge glow and idle presentation are separate from the static texture
- Implemented placement: west-mid Sanctuary garden at `(240, 610)`, west of the southbound central avenue
- Nema stands at `(342, 630)` on the screen-right side of the Rootforge and faces screen-left toward the work surface
- Preserve the central route, the fountain/portal sightline, the existing west service approach, and a broad player turning circle
- Real-camera review confirms the central avenue, player turning room, and front approach remain clear

## Interaction Contract

**Prompt:** `PRESS F TO VISIT THE LIVING ROOTFORGE`

**Speaker:** `ROOTWEAVER NEMA`

**Proposed first dialogue:**

1. `Roots remember every wound. Metal only remembers the hand that shaped it.`
2. `Bring me what the forest leaves behind. Heat, pressure, and patience will teach it a second purpose.`
3. `Orren sells honest steel. I forge what honest steel cannot become.`

Before the Stage V seal, the service remains honest through the disabled `STAGE V CORE GEAR SEAL REQUIRED` action and the explicit `OUTPUT EQUIPMENT IS NOT YET IMPLEMENTED` status.

`DialogueNpc` continues to own proximity and dialogue intent. `SanctuaryFlow` decides whether completed dialogue opens the crafting surface. Nema's actor scene owns no recipe balance, inventory mutation, seal rule, or save operation.

## Crafting Menu Shell

Implemented title: **NEMA'S LIVING ROOTFORGE**

The Segment 4 shell is a paused, theme-backed presentation with:

- compact header showing Nema, current region, and material-pouch summary
- filters for `ALL`, `WEAPONS`, `ARMOR`, and `ACCESSORIES`
- left recipe list with name, tier, category, remembered/sealed state, and a small right-edge output silhouette (or locked-box silhouette for sealed previews)
- right recipe panel with description, blueprint state, and current milestone boundary
- ingredient rows showing material icon plus `owned / required`
- milestone status strip showing the relevant crafting seal
- one primary action that crafts only when ready and otherwise explains the exact missing condition
- controller/mouse focus navigation and Escape/close behavior consistent with existing menus

Examples of honest disabled states:

- `STAGE V CORE GEAR SEAL REQUIRED`
- `STAGE VIII ACCESSORY SEAL REQUIRED`
- `BLUEPRINT NOT REMEMBERED`
- `MISSING MATERIALS`
- `ALREADY OWNED`

The current surface exposes six craftable Stage V outputs and two honest sealed Stage VIII previews.

## Implemented Authority Boundary for Segment 5

`CraftingService` owns validation and atomic transactions:

1. validate recipe and permanent category seal
2. validate blueprint discovery
3. validate output definition and unique ownership rules
4. validate every material quantity
5. reserve exactly one deterministic output
6. consume all costs as one validated batch
7. emit an observation result
8. request the existing safe-profile save only after success

Permanent crafting seals are never consumed. Repeatable boss catalysts are ordinary material costs and may be consumed by recipes. UI, Nema, and the workshop never perform these mutations.

## Segment 4 Acceptance Gate

The owner accepted:

1. `Rootweaver Nema` as the final name
2. attractive adult human woman and grove-blacksmith identity
3. auburn side braid, moss forge apron, root hammer, and gold-thread tongs silhouette
4. west-mid open-air Living Rootforge placement with Nema working from its screen-right side
5. proposed dialogue voice
6. crafting-menu hierarchy

Segment 4 delivered the cleaned/runtime actor, portrait, workshop, dialogue integration, menu shell, asset catalog entries, and Sanctuary regression. Decision 120 activates Segment 5: real Stage V category/seal gates, exact material spending, unique weapon/gear grants, save/rollback, and focused atomic/UI regressions. Stage VIII previews remain non-craftable.

## Concept Generation Record

### 2026-08-01 side-facing actor correction

- **Mode:** built-in image generation edit
- **Use case:** `precise-object-edit`
- **Generated source dimensions:** `1744x902`
- **Project source:** `art_source/generated/characters/npcs/rootweaver/rootweaver_nema_service_side_source.png`
- **Cleaned intermediate:** `art_source/cleaned/characters/npcs/rootweaver/rootweaver_nema_service_side_transparent.png`
- **Edit target:** former front-facing runtime sheet

Final accepted prompt:

```text
Use case: precise-object-edit
Asset type: source board for an 8-frame Godot pixel-art NPC sprite atlas
Edit target: the provided Rootweaver Nema sprite sheet.
Primary request: preserve Nema's compact chibi proportions, dark olive blacksmith apron, auburn hair, small hammer and tongs, and established color palette. Repose her as a readable three-quarter view facing SCREEN-LEFT. Arrange exactly eight isolated full-body character-only sprites in a strict 4-column by 2-row board: top row four subtle idle frames; bottom row four hammer-working frames. In every frame show both boots completely and keep every hand/tool completely attached and visible.
Scene/backdrop: perfectly flat solid #ff00ff chroma-key background, one uniform color with no checkerboard, shadows, gradients, floor, texture, grid lines, cell dividers, or lighting variation. Do not use #ff00ff in the subject.
Style: crisp retro pixel art matching the reference, compact 32-to-48-pixel gameplay sprite density, hard square pixels, no antialiasing, no blur.
Constraints: character and handheld tools only. Absolutely no anvil, forge, sparks, molten metal, workstation, furniture, text, watermark, extra character, or background object. Generous equal padding around every sprite. Stable foot baseline within each row. Do not crop anything.
```

The built-in image result was chroma-removed with the image-generation skill's standard helper, then processed through `retired generation tool (recover from Git history only)`. The processor keeps one scale across the eight connected actors, hardens binary alpha, adds the project outline, fits content within a `40x40` limit, and aligns the complete boots to a 44-pixel baseline inside every `48x48` cell.

### Runtime actor board

- **Mode:** built-in image generation
- **Use case:** `style-transfer`
- **Generated source dimensions:** `1672x941`
- **Project source:** `art_source/generated/characters/npcs/rootweaver/rootweaver_nema_service_source.png`
- **References:** approved v3 concept for identity; Eira/Orren runtime sheets for scale and pixel language

Final prompt:

```text
Use case: style-transfer
Asset type: Battle of Gods Godot NPC animation source board for later deterministic pixel-art processing
Primary request: Create one clean 4-column by 2-row sprite animation board for Rootweaver Nema, the attractive adult female grove-smith shown in Image 1. Preserve her identity: warm confident face, auburn side braid, moss-green forge apron and dark work clothes, compact oversized-head tiny-body proportions, root-bound hammer, gold-thread tongs, violet stitch accents. Visible arms and hands are intentional and required for this NPC's readable forge work.
Input images: Image 1 is the approved Rootweaver Nema identity, costume, tools, and Living Rootforge concept reference. Images 2 and 3 are strict style, scale, compact-body, and game-sprite readability references from the existing Battle of Gods NPC cast.
Scene/backdrop: perfectly flat solid #00FFFF chroma-key background across the entire canvas for local background removal. No panels, boxes, separators, floor, shadows, gradients, texture, or lighting variation.
Style/medium: crisp hand-authored-looking top-down/front-facing pixel art matching Images 2 and 3; limited earthy forest palette; hard readable pixel clusters; no smoothing, painterly rendering, or semi-realistic proportions.
Composition/framing: exactly eight separate complete full-body sprites arranged as four equally spaced columns and two evenly spaced rows. Each cell has identical safe margins and the same stable foot baseline. Row 1: four subtle stationary idle frames, front-facing, small breathing/braid/apron motion. Row 2: four stationary forge-work frames forming one readable hammer-and-tongs action cycle; tools remain integrated with her hands and body. Every sprite stays fully inside its own cell and never touches another.
Constraints: preserve Nema's face, braid, outfit, palette, tools, compact silhouette, and front-facing orientation. Consistent body size and feet position across every frame. No Living Rootforge or workshop in this board. No loose tools outside her hands. No text, labels, numbers, arrows, grid lines, borders, UI, watermark, cast shadow, contact shadow, or extra characters. Do not use #00FFFF anywhere in Nema or her tools. Background must be exactly one uniform cyan color.
```

### Current female grove-smith revision

- **Mode:** built-in image generation
- **Use case:** `style-transfer`
- **Generated source dimensions:** `1672x941`

Final prompt:

```text
Use case: style-transfer
Asset type: Battle of Gods pixel-game female grove-blacksmith NPC and Sanctuary service concept board
Input images: Image 1 is the EDIT TARGET and current elderly Rootweaver board; Image 2 is Eira's actual 48x48 runtime sprite-sheet STYLE AND PROPORTION REFERENCE; Image 3 is Orren's actual 48x48 runtime sprite-sheet STYLE AND PROPORTION REFERENCE.
Primary request: redesign Rootweaver Nema as an attractive adult female fantasy grove blacksmith while preserving Image 1's compact board layout, organic Forest-crafting purpose, and Sanctuary-compatible pixel style. She forges armor and weapons from bark, hide, resin, roots, and monster materials; Orren is now dialogue-only.
Subject: Nema is unmistakably an adult woman, athletic and charismatic, with a confident subtly playful expression. Long dark auburn hair tied into one practical side braid, a tiny soot mark on one cheek, dark fitted work shirt, moss-green leather forge apron, sturdy belt, short work gloves or bracers, tiny boots, and one restrained violet stitch accent. Her blacksmith identity should be immediate through a detached compact root-forging hammer and detached tongs holding one short strand of relic-gold living thread. No elderly features, gray hair, hood, grandmother appearance, or masculine design.
World-sprite proportions: match Images 2 and 3 exactly in visual language—oversized round/boxy head occupying about half the visible height, tiny narrow torso, extremely short legs and feet, simple face, large chunky pixel clusters, stable bottom-center origin. Keep the actor genuinely suitable for clean native 48x48 cells. Attractive adult identity must come from hair silhouette, confident eyes, apron, stance, and portrait—not realistic anatomy or a taller body.
Board composition: plain near-black horizontal source board. Left: four evenly spaced front-facing idle-frame thumbnails designed for individual 48x48 cells, with hammer and tongs detached from the body. Center: one simplified square approximately 96x96-style dialogue portrait of the same woman, attractive, self-assured, warm, with a slight knowing half-smile, still chunky pixel art rather than anime or realism. Beneath or beside it: separate root-forging hammer and tongs/golden-thread props. Right: a simplified Sanctuary Rootforge workshop in front-facing top-down three-quarter game-sprite viewpoint: low open timber-and-root pavilion, one chunky stone anvil entwined with living roots, one compact amber-green ember brazier, one simple material rack, one small weaving frame for fibers, one warm lantern, broad uncluttered player approach. It is a small readable game building asset, not an isometric diorama.
Style/medium: deliberately low-resolution handcrafted retro pixel art matching Images 2 and 3. Bold near-black/dark-brown outlines, crisp hard edges, large pixel clusters, flat fills, only 1-2 shade steps per material, approximately 10-14 character colors, restrained detail, upper-left lighting.
Color palette: deep brown hair, bark brown, dark leather, muted moss green, warm beige skin, ember amber, restrained relic gold and one tiny divine-violet accent.
Constraints: clearly adult female; attractive and charismatic but practical and non-explicit; compact Sanctuary proportions mandatory; workshop simpler and chunkier than high-detail concept art; body, hammer, and tongs remain separate; no text, labels, logos, or watermark.
Avoid: elderly woman, gray hair, hood, male character, childlike identity, sexualized armor, cleavage-focused clothing, pin-up pose, realistic anatomy, tall body, large breasts emphasized, smooth facial rendering, anime portrait, painterly shading, gradients, anti-aliasing, dense texture noise, ornate isometric diorama, extra characters, combat pose, ordinary steel sword shop, UI mockup, text.
```

### Superseded compact elderly revision

- **Mode:** built-in image generation
- **Use case:** `style-transfer`
- **Generated source dimensions:** `1672x941`

Final prompt:

```text
Use case: style-transfer
Asset type: Battle of Gods pixel-game NPC and Sanctuary service concept board
Input images: Image 1 is the EDIT TARGET and rejected realistic Rootweaver concept; Image 2 is Eira's actual 48x48 runtime sprite-sheet STYLE AND PROPORTION REFERENCE; Image 3 is Orren's actual 48x48 runtime sprite-sheet STYLE AND PROPORTION REFERENCE.
Primary request: completely redesign Rootweaver Nema so she visibly belongs beside Eira and Orren in the current Sanctuary. Preserve only her friendly elderly human craftswoman identity, muted bark-brown and moss-green palette, crescent weaving hook, golden thread spool, and open Living Loom service idea from Image 1. Do not preserve Image 1's realistic anatomy, dense rendering, or isometric complexity.
Subject: a friendly elderly human artisan named Rootweaver Nema. Her neutral actor sprite must use the same cute compact visual language as Images 2 and 3: oversized round/boxy head occupying about half her visible height, tiny narrow torso, extremely short legs and feet, simple face readable at tiny scale, bark-brown hood, gray hair accents, moss-green apron, one small purple stitch accent. No tree face, horns, monster anatomy, or realistic hands.
Board composition: clean horizontal pixel-art source board on a plain near-black backdrop. Left: four evenly spaced front-facing idle-frame thumbnails designed to fit individual 48x48 cells, with the hook and spool omitted from the body frames. Center: one simplified square dialogue portrait focused on the same oversized head and hood, approximately 96x96-source style, not realistic. Below or beside it: separate compact hook prop and golden thread-spool prop with clear silhouettes. Right: one simplified Sanctuary crafting nook / Living Loom, shown in the same front-facing top-down three-quarter game-sprite viewpoint as a small building asset, not an isometric diorama; low open pavilion, chunky roots and timber, one simple loom, a few hanging fibers, one lantern, uncluttered silhouette.
Style/medium: deliberately low-resolution handcrafted pixel art matching Images 2 and 3. Bold dark brown/near-black outlines, large chunky pixel clusters, flat fills, only 1-2 shade steps per material, limited approximately 10-14 color palette, crisp hard pixel edges. The character should feel like the same artist and same game made her at the same sprite scale as Eira and Orren.
Color palette: bark brown, dark olive, muted moss green, warm beige skin, small gray-white hair clusters, tiny purple accent, restrained relic-gold thread. Match the low contrast and saturation discipline of Images 2 and 3.
Constraints: character must be genuinely 48x48-cell compatible in proportions and detail density; oversized head and tiny body are mandatory; workshop must be substantially simpler and chunkier than Image 1; props must remain detached; no text or labels; no watermark.
Avoid: realistic or semi-realistic anatomy, painterly face, smooth facial shading, anime portrait, high-detail wrinkles, long adult body proportions, fine fabric texture, anti-aliasing, gradients, soft glow, dense noise, ornate isometric workshop, cinematic concept art, extra characters, weapons, UI mockup, text.
```

### Rejected first pass

The first concept is retained only as archived generation history. Owner review rejected its long adult proportions, smooth facial rendering, dense costume texture, and ornate isometric workshop because they did not belong beside Eira and Orren. It must not guide runtime body scale or pixel density.

- **Mode:** built-in image generation
- **Use case:** `stylized-concept`
- **Generated source dimensions:** `1672x941`

Final prompt:

```text
Use case: stylized-concept
Asset type: Battle of Gods game character and Sanctuary workshop approval concept board
Primary request: Design ROOTWEAVER NEMA, a clearly friendly Sanctuary crafting artisan who transforms monster materials into deterministic weapons and armor. She is an NPC, not a monster and not a combatant.
Scene/backdrop: clean dark obsidian concept-board background divided into three readable areas with no text: a large full-body front three-quarter character view, a close head-and-shoulders portrait, and a small top-down three-quarter workshop vignette.
Subject: a compact elderly human woman with Battle of Gods proportions—oversized slightly boxy head, narrow tiny body, tiny grounded feet, serious kind black eyes, visible human face, short ash-gray hair under a bark-brown work hood, muted moss-green apron and layered weathered cloth. Two clean detached role props define her: a crescent wooden weaving hook and a spool of glowing relic-gold root thread. Add a few restrained violet stitches, but no magical overload. She should look practical, calm, clever, and trustworthy.
Workshop vignette: an open-air southwest Sanctuary crafting nook called the Living Loom, visually expressed without lettering: low root-wood pavilion, small loom, hanging fiber bundles, stone worktable, warm lantern, material drawers, broad unobstructed front approach, compact footprint, no character baked into the structure.
Style/medium: crisp retro top-down pixel-art game concept, luminous dark fantasy, compact palette, deliberate hard pixel clusters, binary-looking edges, no smoothing, no painterly rendering, no fake 3D, consistent with a 960x540 Godot pixel-action game and 48x48 NPC runtime direction.
Composition/framing: landscape concept board, generous separation between the character, portrait, and workshop; complete silhouettes with padding; upper-left lighting.
Color palette: void ink and obsidian shadows, bark brown, muted moss, warm cloth, relic-gold thread and lantern, very restrained divine violet accent.
Constraints: original design; clearly human and friendly; readable at small scale; no text, labels, logos, UI, watermark, weapons, combat pose, baked rarity frames, floor reflections, antlers, horns, tree-face, monstrous anatomy, mascot smile, chibi roundness, anime rendering, excessive detail, dithering, gradients, or anti-aliased softness.
```

2026-10-13 maintenance: previous generation/comparison commands were retired; current output assets remain authoritative. New captures use ignored tmp/review/. See docs/maintenance/repository-cleanup.md.
