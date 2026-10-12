# Art Direction

Updated 2026-10-13. Current sources and contracts are authoritative; historical generation trials and archive-dependent tooling were removed (Decision197). See PROJECT_CONTEXT.md and docs/maintenance/repository-cleanup.md.

## Visual Promise

### Current approved baseline

The renewed Sanctuary is installed: gray-stone/timber workshop, blue-roof lodge, connected planting walls, small purposeful NPC workstations, generated courier steps, canopy occlusion and restrained service markers. Eira stands to the right of her lectern; Orren V2 supplies the NPC scale/outline reference. Preserve these production resources.

King uses the frozen complete-body identity library, half-scale weapon presentation and registered ground origins. Sword, axe, accepted Greatsword V2 and Twinsteel V2 are installed. Current Twinsteel carry is a separate motion variant still awaiting owner review; passing geometry/hash checks does not approve motion. Keep native head/chest/waist connections, dark contours and consistent density across directions and equipment. Historical appearance trials remain in Git history only.

### World visual direction

Battle of Gods is a readable retro pixel-action game set in an ancient world shaped by divine conflict. The image should feel mysterious, weathered, and epic without becoming muddy, realistic, or excessively detailed.

The active forest direction is **luminous dark fantasy**: living greens and warm natural light sit beside old stone, restrained violet divinity, and deep shadow. Darkness comes from history, danger, and atmosphere rather than making the whole screen black.

The planned Sanctuary follows the same world language. It is a small safe settlement reclaimed around an ancient divine fountain, not a modern town or a cheerful cartoon village.

## Priorities

When visual goals conflict, use this order:

1. Gameplay silhouette and hazard readability.
2. Consistent pixel density, origin, and animation scale.
3. Clear interaction and UI hierarchy.
4. Shared palette and lighting direction.
5. Atmosphere and decorative detail.

Art must never hide collision boundaries, attack telegraphs, the player, or required interaction feedback.

## Runtime Baseline

| Area | Current baseline | Rule |
|---|---|---|
| Logical viewport | 960x540 | Review every asset at this gameplay scale. |
| Development display | 1920x1080 | Preserve exact 2x integer scaling. |
| Production playable body | Installed King192x128 Spellward/family cells at Body scale0.5 | Use live directional carry/sole/head metadata and approved palette; preserve current origins. Earlier32x32/y30 simple-reboot conventions are historical. |
| Existing enemy-humanoid locomotion | 24x32 cells | Preserve validated Thrall scale and direction columns. |
| Existing extended enemy actions | 64x48 cells | Six-frame actions may exceed the body cell without shrinking the actor. |
| Small creatures | 32x32 cells | Keep silhouettes readable beside modular players and enemy humanoids. |
| Prototype terrain | 64x64 tiles | New terrain must match or deliberately replace this density. |
| Standard action/skill icon | 24x24 | Use a centered readable glyph with transparent padding. |
| Compact status/currency icon | 16x16 | Use only when readable at native size. |
| Inventory equipment portrait | 64x64 | One complete item silhouette, transparent padding, binary alpha, and no baked rarity frame or text. |

Nearest-neighbor filtering, binary-alpha hard-pixel character edges, integer placement, and pixel snapping remain mandatory. Do not disguise an illustration as pixel art by downscaling it.

## Palette and Lighting

The palette is provisional but its semantic roles are stable:

| Token | Reference | Purpose |
|---|---|---|
| `void_ink` | `#090B10` | Deepest background and menu shadow. |
| `obsidian_panel` | `#12151D` | Primary UI panel surface. |
| `bone_text` | `#D9DDCE` | Primary readable text. |
| `muted_moss` | `#74806B` | Secondary text and quiet environment detail. |
| `grove_green` | `#5F8F47` | Living forest midtone. |
| `deep_moss` | `#365A3B` | Forest shadow and structural foliage. |
| `divine_violet` | `#765AA3` | Portals, sealed divinity, and rare arcane accents. |
| `relic_gold` | `#D6C171` | Important focus, equipped state, and earned reward. |
| `spirit_blue` | `#66A4D8` | XP, spirit, and restrained informational emphasis. |
| `danger_red` | `#D65C50` | Damage and hostile warnings only. |

These are coordination references, not a demand that every sprite contain every color. Individual actors should use compact sub-palettes. Avoid uncontrolled hue proliferation.

Default world light travels from upper-left toward lower-right. Highlights, cast shadows, foliage clusters, statues, buildings, icons with volume, and fountain pieces should agree with that direction.

## Character and Creature Rules

- Direction order is `down`, `left`, `right`, `up` unless a documented asset contract says otherwise.
- Animation names use `<action>_<direction>`, such as `walk_left` or `attack_up`.
- Feet are the stable origin for top-down actors and must not drift between frames.
- The face, approved limb treatment, equipped presentation, and major silhouette features must survive every frame; no transparent holes or accidental fragments. Playable standing references use one documented screen-space width, height, and foot baseline across every direction.
- King's simple down-facing face uses two dark eyes, each exactly two pixels tall. Preserve both eye pixels and keep the chunky black fringe from extending directly into either eye; correct the hair contact rather than shortening, enlarging, or highlighting the eyes.
- King's face remains plain and determined at native scale; his compact silhouette stays serious rather than baby-like or chubby.
- Modular playable weapons may remain separate from the body when stable authored pivots and phase-driven motion make equipment replacement practical. Author each texture with a known grip point and rotate the texture around that point rather than its image center. For armless bodies, keep a small deliberate gap and use a bounded integer-pixel orbit that reads as controlled equipment rather than an accidental missing hand. A restrained active trail may clarify the swing but must not imply a different damage area.
- Weapons remain integrated into attack poses when the actor's hand/body silhouette depends on them, as with the existing Thrall claw action.
- Anticipation, active action, and recovery poses matter more than extra decorative frames.
- Defeat uses readable recoil, weaken/slump, and final grounded poses before runtime fade; fading alone is not an authored death animation.
- Shadows are separate presentation and align beneath the foot position.
- Collision and hurtboxes are authored from gameplay needs, not copied from sprite opacity.

## Environment Rules

- Terrain, decoration, collision, navigation, foreground occlusion, and effects remain separable.
- Tall props use independent base/canopy or base/roof layers when the player can walk behind them.
- Prop collision covers the traversability footprint, never the entire visible crown or silhouette.
- Landmarks guide travel and combat spacing. Avoid random dense prop scattering.
- Shared forest terrain stays bright and low-contrast. Rootbound Hollow must still read as that forest dying: retain roughly half living grass/moss around the approach, then transition through dirt blends and root scars into maroon bark, muted plum-violet roots, bruised moss, and sparse toxic-lime fissures. Stage 4 confines stronger rot to its eastern edge and foreshadows the route with a reduced broken gateway. Production Stage 5 is the deliberate fully decayed endpoint: charcoal soil, gray stone lanes, plum-black roots, sparse lime fissures, and dense grouped dead-tree silhouettes rooted at or partly beyond every outer map edge. Individual bare trees/snags/fallen trunks/uprooted remains may sit inside only where they frame a route rather than fill it. A single tiny, stylized pixel carrion detail with separately moving flies supplies environmental consequence without gore or realistic anatomy. Keep traversal and the boss center quiet enough for warnings and silhouettes; never substitute random interior scattering, unrelated stump art, or one repeated tree without scale/mirror variation.
- Sanctuary assets reuse the forest's lighting and palette while introducing maintained paths, inhabited structures, warm windows, cloth, and the central divine fountain.
- Fountain visuals should separate base stone, water/glow animation, shadow, collision, and optional interaction marker.

The active Sanctuary establishes inhabited fantasy through one fixed generated walk-in angel structure with only its doorway energy animated, a separate divine fountain, compact violet skillkeeper lodge, warm armskeeper workshop and low cart, two tree silhouettes, Skillkeeper Eira, and Armskeeper Orren. Stage exits are architecture-free upright dimensional veils, never floor holes or physical gates. Their compact irregular doorway must move across the entire inner surface: broad, middle, and deep currents change phase independently through the exact middle, while the rim continuously flickers, ripples, and deforms without making the whole portal rotate as a flat wheel. The wider transparent FX field is threat punctuation rather than a universal baseline: blue Normal exits omit lightning, purple Mini Boss exits keep it close and faint, red Boss exits push it outward, searing light God exits flood much of the view, and near-black Transcendent exits own the widest violent violet-black reach. Scale the overlay independently from the stable doorway so extreme forks may cross half the map without turning the portal itself into a giant wheel. Generated landmark architecture must never be redrawn per animation frame; isolate energy so angels, masonry, silhouette, and baseline stay pixel-identical. Dedicated restrained grass and cobblestone transitions replace borrowed combat-stage terrain. The fountain remains physically separate from the portal so its walk-around footprint, visible courtyard gap, broad stairs, and open doorway read at gameplay scale. Service structures use deliberate clusters, clear emblems, complete silhouettes, and no baked-in character bodies. Portal energy, water glints, magic accents, lanterns, windows, tree sway, and one-pixel NPC breathing animate independently from collision and interaction so the hub feels alive without becoming a noisy cartoon town.

## UI Language

UI should resemble ancient crafted interfaces without sacrificing clarity:

The owner selected Eclipse Bind as the action-tray direction: one continuous obsidian shadow frame with inward thorn corners, a small eclipse crest and restrained violet veins. The active 720x104 native border is generated from a text-free source with its dark interior cleared; a separate 78%-opacity veil supplies readable contrast over gameplay after the lighter pass felt too transparent. Keep the border crisp and the live Godot slot labels, cooldown/charge feedback and click/touch targets independent at 960x540. Space uses a matching shadow-step glyph. This HUD motif does not establish the still-undecided recurring emblem of the gods. The earlier detached dragon pass is retained only as historical source art.

King's approved skill-icon family follows the B+C hybrid contract: C's simple silhouette and limited shading with B's compact impact grouping. Each native 24x24 icon uses one symbol plus one effect, a maximum 14-color King palette, binary alpha, top-left light, and generous transparent padding. Tiny dark crimson is reserved for a physical hilt accent; spirit blue/violet carries ability energy. Realistic materials, ornate gold, ribbons, fog, and particle clutter are rejected.

- Dark flat panels with one-pixel or two-pixel borders.
- Relic-gold focus/equipped states and violet sealed/divine states.
- Strong rectangular silhouettes and restrained corner ornament.
- Minimal animation: short fades, focus shifts, small glows, and deliberate selection motion.
- No highly rendered fantasy frames, noisy filigree, fake metallic gradients, or baked-in text.
- Icons use one clear symbol, a limited palette, and a consistent internal margin.

The UI implementation uses `battle_of_gods_theme.tres` as its reusable base. Buttons, panels, labels, progress bars, focus states, and disabled states consume that shared theme; scene-local overrides remain only for semantic states such as health, cooldown, equipped, or sealed content. The first named 16x16/24x24 icon kit follows the same palette and hard-pixel rules.

Equipment presentation extends that language without becoming noisy loot UI. The active early ladder uses warm ash brown for Wood, neutral stone gray for Stonebound, pale steel for Iron, and spirit blue for Rare. The former A/S/Legendary/Mythic palette is preserved only with legacy concepts and is not shown to beginner players. Rarity frames and optional aura pulses remain separate Godot presentation, so item images contain only the complete 64x64 silhouette and can be restyled independently.

The Stage V Varkuun core set shares one authored material family: petrified heartwood, charcoal iron reinforcement, restrained moss green, a controlled acid-green core accent, tiny muted-violet corruption seams, and sparse aged-gold fasteners. Each icon must remain recognizable by slot at native 64x64 size; family resemblance must come from materials and lighting rather than repeating one silhouette.

The active playable presentation is King: a serious compact mortal with four-direction locomotion and authored sword actions. His chunky dark hair, plain determined face, crimson scarf, compact body, tiny feet, and short broad signature sword establish the production baseline. Locomotion uses 32x32 cells on a y=30 foot baseline; larger action cells preserve body scale while providing reach and impact space. Eira and Orren share the broad compact scale language while retaining original violet-scholar and rust/iron-armskeeper identities. Rootbound Husk establishes the first reviewed mini-boss scale: a broad stump silhouette, compact branch crown, separated root legs, foreground/background limb layering, and a lime core that survives locomotion, root-command attacks, reactions, and defeat.

Decision 132 establishes The One Above's first reusable divine-order language without revealing its story meaning: smooth fully covered masks, pale ivory/white-stone material, restrained warm-gold geometry, limited floating construction, and physically impossible signature weapons. The Examiner is a tall, lean masculine humanoid with a Divine Split Glaive; his near-still observation contrasts with sudden precise movement. The future-only Executioner is a still larger/broader armored feminine/subtly feminine silhouette with darker divine material, restrained violet accents, four to six fractured halo pieces, and a broken circular Divine Execution Wheel. They do not need to share King's compact scale: tall or huge is acceptable. No numeric height or runtime cell is approved until a preview-only same-baseline art board is shown to and approved by the owner. Both must look admirable/divine before they look suspicious—never generic demons, skull knights, horned villains, or red-eyed blood armor. The exact repeated emblem remains open until the missing concept reference is reattached and inspected.

Retired playable-character presentations are recoverable under `historical Git-only archive/retired_opaw_2026-08-16/`; they are historical sources, not supported runtime rollback assets.

The older `handless`, `armless`, and `armless_small_feet` experiments remain review/source history under Godot-ignored `historical Git-only archive/`; they no longer occupy runtime `assets/`, tools, or regression tests. The complete Wayfarer rollback remains independently loadable under active `assets/`.

Active armless attacks communicate force through anticipation, whole-body rotation/lean, planted or lunging tiny feet, head counter-motion, scarf follow-through, detached weapon acceleration, trail, hit flash, and hitstop. The compact proportion must remain grounded, serious, and combat-capable rather than round, smiling, or mascot-like.

## Replaceable Background Contract

Title, menu, dialogue, and loading backgrounds must be easy to replace without changing navigation or gameplay code.

- Background presentation lives in a named `Background` owner or a dedicated presentation scene.
- Screens reference backgrounds through exported `Texture2D`, `PackedScene`, or theme/configuration resources.
- Text, buttons, logos, and interaction logic are never baked into a background image.
- Decorative animation layers remain separate from the static base image.
- A title background should support: `Base`, `DistantSilhouette`, `Atmosphere`, and `Vignette` layers when needed.
- Backgrounds design for 960x540 and define whether they crop, letterbox, or tile at other aspect ratios.
- Replacing a background must not change button paths, focus navigation, audio routing, or scene transitions.

A new background can differ in composition, but it must still match Battle of Gods lighting, palette roles, pixel density, and tone.

The active title implementation follows this contract through `TitleBackground`: a generated-on-grid 960x540 base grove, separate enlarged existing tree silhouettes, tweened mist/fireflies, and a vignette. The base contains no title text or controls and is reproducible through `retired generation tool (recover from Git history only)`.

## Asset Lifecycle

Every visual file has one lifecycle state:

```text
concept -> source -> cleaned -> runtime -> archived
```

- `concept`: reference or exploration; never loaded by a scene.
- `source`: original handmade, generated, or downloaded material preserved for provenance.
- `cleaned`: intermediate crop, chroma removal, palette reduction, or grid correction.
- `runtime`: the exact approved file imported and referenced by Godot.
- `archived`: rejected or superseded work retained for learning and history.

Future non-runtime art belongs under `art_source/`, with a `.gdignore` at its root. This keeps source and mistakes safe without importing them into Godot. Runtime content belongs under `assets/` only.

The active combat-stage environment follows that lifecycle: generated 4x4 forest and Rootbound source boards plus the chroma-clean arena seal are preserved under `art_source/generated/environment/forest/`; normalized 64px atlases and the fixed-canvas transparent seal are the only versions referenced at runtime. Stage 5 follows the same separation under `art_source/generated/environment/stage_5/`, with cleaned chroma props under the matching cleaned path and only normalized terrain/tree/shrine outputs under runtime `assets/`. Camera captures used for visual review live under `historical Git-only review/environment/`.

## External and Generated Art

- Record source URL, author, license, and modification notes for external assets.
- Prefer CC0 or clearly compatible licenses. Do not use an image merely because it can be downloaded.
- Generated images are source material, not automatically approved runtime art.
- Clean generated work onto the required grid, remove anti-aliased fragments, reduce the palette without dithering, and inspect every animation cell.
- Do not mix unrelated asset packs without palette, lighting, scale, and silhouette normalization.
- Keep reproducible processing scripts when they materially transform an asset.

## Approval Checklist

An asset becomes `active_runtime` only when:

1. Its canonical ID and path are recorded in `ASSET_CATALOG.md`.
2. Its dimensions, grid, direction order, and origin are known.
3. It matches the theme, palette roles, and upper-left lighting.
4. It remains readable at the 960x540 gameplay viewport.
5. Its collision, navigation, occlusion, or UI behavior is verified where relevant.
6. Its source/license or generation provenance is recorded.
7. Relevant scenes, generators, and tests load without errors.

2026-10-13 maintenance: previous generation/comparison commands were retired; current output assets remain authoritative. New captures use ignored tmp/review/. See docs/maintenance/repository-cleanup.md.
