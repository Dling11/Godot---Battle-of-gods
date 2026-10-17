# Combat interface and weapon progression proposal

Updated 2026-10-17. Status: historical owner-requested concept review; the selected C2 HUD is now installed. Read veil-sigils-hud.md for actual native layout/data/validation. Weapon progression and future capacity remain proposals. Current five-family artwork remains provisionally settled under Decision224.

## Direction and references

The owner wants the clarity and visual appeal of RPG skill bars, centered enemy information, XP placement and objective tracking, adapted to Battle of Gods. Use information hierarchy as inspiration and create original pixel artwork, symbols and frames. Official reference refresh2026-10-17: FFXIV's HUD-layout guide explicitly separates position, size, visibility and transparency (https://na.finalfantasyxiv.com/uiguide/know/know-hud/hud-layout.html); its screen manual distinguishes parameter bars, hotbars and system menus (https://na.finalfantasyxiv.com/game_manual/view/). ArenaNet's historical UI notes describe small usability refinements and staged skill choices (https://www.guildwars2.com/en/news/the-big-beta-weekend-preview/). These guide design judgment; they do not establish matching art, current balance, or a claim that another game's layout is directly reusable. The earlier GW2 part-2 link currently resolves to a different/localized guide section, so do not rely on it as exact HUD-placement evidence.

Maintain the 960x540 logical viewport, integer-scaled hard pixels, navy/obsidian panels, weathered iron/silver, bone text and restrained cyan/violet accents. Health remains deep red. Avoid broad gold borders and oversized ornament. The map remains hidden. Show the actual King identity and preserve the central combat area. Validate over a forest, a dark scene and a bright/busy encounter before selecting final contrast values.

## Three layout candidates

### Current format: top-left status, bottom skills and proposed8+6 active slots

The owner selects C2 Status Card, the second/B refinement of C Veil Sigils (Decision225), retaining its portrait and round skill artwork, avatar FIRST on the LEFT with HP extending RIGHT, and mastery/stat readouts grouped beside the avatar. Keep accepted bottom-right Bag/TAB and Settings/ESC. Shrink UI and anchor the skill dock close to the bottom. Owner confirms the bottom instruction applies ONLY to the skill dock's floating gap: avatar/HP/mastery/stats stay top-left, utilities stay bottom-right, and the dock uses a minimal2-4px inset. Keep numerical red current/max health and one King level badge. Bottom-center skills retain separate SPACE and thin numeric player XP, without a duplicate avatar/HP. Preserve the compact original dark-fantasy pixel identity and central play space.

The owner proposes8 King active skills plus6 equipped-weapon techniques,14 total. This is the current review target, superseding the earlier10+10 samples; final active limits remain a design decision, not a runtime migration. Recommendation: use these as active-loadout caps and allow a larger learned library later, rather than requiring every learned skill to consume a hotkey. Preserve existing powers until an explicit migration is accepted. Four available King skills still means only four visible buttons; no weapon unlocks means no weapon row.

Earlier corner studies cover early4 and full14 in tmp/review/combat_hud_corner_portrait_2026_10_17/; exact inputs/prompts are combat-hud-corner-portrait-prompts.json. Full proposal: lower row1-8 for King, upper rowF1-F6 for the equipped weapon; SPACE is a separate utility outside the14. These are remappable example bindings: F5/F6 overlap editor/debug routes and must be resolved before implementation. The owner now requests a small weapon-mastery preview; real mastery display still requires a progression authority. One-versus-two readied weapons remains undecided.

Approximate native review budgets at960x540:28px icons with2px gaps, about64px-wide corner portrait/HP, and a full skill dock around290px wide and at most82px high. Keep small key/HP/XP digits readable. These are targets for generated samples, not verified Godot dimensions; implementation must use one consistent icon/font sizing contract across unlock states. Earlier dock-portrait samples at4/10/20 remain local historical references, not the current placement/capacity specification.

Review result: both corner-portrait samples are generated. Visual inspection confirms top-left avatar/HP, no avatar in the bottom dock, exactly8+6 or4+0 skills, and separate SPACE utility. A targeted edit removes the full sample's duplicate7/extra icon. Full sample centers the shorter top row; final native alignment, fixed sizes and glyph identities remain open. Local comparison: tmp/review/combat_hud_corner_portrait_2026_10_17/index.html. All653 protected production files remain unchanged.

### Selected C2: compact sizing, hover details and recommendations

The owner selects the second/B arrangement below, C2 Status Card. Keep C's specific portrait drawing and round glyphs, avatar-first order, mastery below HP and stat/status chips beneath that readout. Mastery belongs to the equipped weapon family; King level and blue player XP remain separate. The sample MASTERY5, ATK32, DEF18 and AS+8% are not earned runtime data or a guarantee of a specific hit's damage. Native UI must use one mastery meter, removing the generated decorative duplicate-track artifact.

The owner explicitly asks for hover descriptions and prioritizes saving space. Initial native review target: about300px dock width and80px height at960x540, with2-4px bottom clearance and roughly28px visual medallions. Measure real fonts/24px icon padding/hit areas before accepting these targets; do not scale the flattened screenshot into a UI texture. Hide unavailable unlocks and collapse missing rows while keeping stable key order and consistent slot size.

Replace/extend current basic text tooltips with small themed, non-blocking hover/focus cards. After roughly0.35s, show a skill's name/key, concise description and applicable actual damage/type, cooldown, charges and effects. Prefer a compact card above the bottom dock, clamped to the viewport; dismiss on mouse exit/focus change, no combat pause or focus trap. Mastery/stat cards explain the current weapon, progress/next reward when real data exists and the meaning of units. Keep long descriptions off the permanent HUD. Reuse existing SkillSlotDefinition descriptions and gameplay authority rather than duplicating them in presentation.

Additional recommendations for discussion, not yet accepted features: a bounded active-only buff/debuff row with duration/stack counts; clearer existing cooldown/charge rendering with a restrained ready pulse; Compact/Normal/Large native UI presets with readable fonts. They should improve situational feedback without adding permanent empty frames, repeated READY text or extra always-visible bars. Keep low-health feedback subtle and use actual health/status events. Native HUD sizing inspiration: https://na.finalfantasyxiv.com/uiguide/know/know-hud/hud-layout.html. The user requests this discussion before implementation; no runtime work is performed by recording it.

Earlier refinement alternatives:

| C variation | Mastery position | Small stat/status group |
| --- | --- | --- |
| C1: Combat Readout | Shallow card to the left of F1, using the space beside the shorter weapon row | Beneath top-left HP, to the portrait's right |
| C2: Status Card | Beneath top-left HP beside the avatar; bottom dock stays clean | Directly below the mastery/HP readouts |
| C3: Technique Strip | Thin header above the six weapon medallions | Below the top-left player-status module |

Exact inputs/prompts: combat-hud-c-mastery-prompts.json. Requested final review PNGs/gallery: tmp/review/combat_hud_c_mastery_2026_10_17/. Count all6 F keys and8 King keys, check portrait-first orientation and distinct mastery/XP colors, and preserve accepted utility positions. These widgets must not resemble extra skill buttons or create a large mandatory panel.

Before native display, define ATK's resolved power/range meaning, bind DEF to actual armor, and label AS as attack speed rather than movement speed. Show only real active buffs/debuffs when those states exist. Mastery cannot borrow King XP or hardcode a sample rank. The UI requests do not implement earning rules, caps, persistence, skills, weapon swaps or input migration. Current runtime remains unchanged.

Review result: C1/C2/C3 final PNGs and local comparison page are saved. Visual inspection confirms portrait-first/HP-right,6 weapon and8 King round skills, separate SPACE, one mastery label/filled purple progress readout, three labeled stat examples and retained bottom-right utilities. C2's duplicate purple fill is removed, though its generated decorative underline still resembles a small empty track; native UI must render one authoritative meter only. Generated proportions remain illustrative and need compact native review. The prior image pass verified all653 protected production files unchanged and image links valid. The owner subsequently selects C2 and confirms skills-only bottom anchoring; exact native metrics remain pending.

### Earlier complete artwork comparison (C selected)

The owner accepts Bag/Settings placement but clarifies that new design means improving the skill artwork as well as the avatar and health display. Earlier status-only comparisons kept the skill glyphs unchanged and do not fulfill this expanded artwork request. Create three separate full-screen edits with fresh14-icon families and matching slot frames/action-bar treatments, freshly painted King busts guided by approved identity, and different HP arrangements:

| Option | Skill artwork and frame | Player status |
| --- | --- | --- |
| A: Ashsteel | Engraved steel square tiles, dynamic ivory weapon silhouettes and controlled blue/violet powers | Portrait on left, numerical horizontal HP extending right |
| B: Bloodstone | Carved blackstone clipped cards, substantial low-relief glyphs and muted pewter edges | Vertical red HP rail left of the portrait; numeric HP below the group |
| C: Veil Sigils | Round inset rune medallions with new pixel emblems and small key tabs | Portrait at right end of the top-left module, HP ribbon extending left |

Keep the approved bottom-right utility pair, same6 weapon/8 King review counts, separate SPACE, numeric XP, world, target/objective regions and general placement. New skill art must have distinct silhouettes, useful negative space and limited palette, rather than repainting every icon as the same bright crescent or cross. Generated26-28px-native-looking illustrations are review studies, not validated production icons or an automatic replacement for ART_DIRECTION.md's current24px/14-color contract.

The first five lower-row glyph concepts loosely follow current skill roles (blade fissure, local molten impact, landing leap, oath protection, radial split). Slots6-8 and the six weapon glyphs remain illustrative capacity samples: no new binding-chain, spectral-step, finisher or progression mechanic is implemented by these pictures. New portrait art may change rendering, not King identity or accepted actor anatomy. Compare HP right of the portrait, a left vertical rail and HP extending left; preserve readable actual current/max digits and a clear dark unfilled capacity.

Exact edit prompts/input roles: combat-hud-full-art-prompts.json. Final temporary review outputs/gallery: tmp/review/combat_hud_full_art_2026_10_17/. Current production HUD, skills, inputs, saves and artwork remain unchanged. Owner selection and native review are still required before installation.

Generation result: all three full artwork samples are saved and visually reviewed. Each has6 F-key weapon icons,8 number-key King icons and separate SPACE, freshly painted glyphs/portrait/slot treatment, and bottom-right Bag/Settings. A uses HP to the right, B a left vertical rail, and C HP extending left. Generated action docks exceed the native compact sizing target; use them to choose artwork, then measure real28px slots and fixed fonts instead of copying screenshot scale. Portrait rendering and health fill are illustrative. All653 protected production files remain unchanged. Full-screen local comparison links are verified; the owner subsequently selects C in Decision225, while mastery/status placement remains in review.

### Earlier portrait/HP-only alternatives (utility position accepted)

The owner finds the first corner portrait/HP artwork insufficient and requests several distinct designs, while retaining the overall format. Generate three separate full-screen edits with the same14-button dock and approved King96x96 portrait as identity guidance:

| Option | Player-status treatment | Shared utility placement |
| --- | --- | --- |
| A: Runic Medallion | Round muted-silver bust frame, small level tab, short curved-end red HP bar below | Bottom-right satchel/TAB and cog/ESC pair |
| B: Sentinel Card | Connected charcoal rectangular portrait card, clipped corners and inset HP ribbon below | Same pair and spacing |
| C: Riftline | Smaller octagonal portrait and light angular HP strip below, little enclosing decoration | Same pair and spacing |

Utility arrangement: two recognisable24px icon controls with small key tags, equal baseline/spacing and a safe screen margin; remove the old wide Bag/Menu banners beneath the avatar. Keep utilities apart from combat skills and upper-right objectives. The owner now accepts these bottom-right positions; they are not yet installed runtime interactions. Tooltips, hit areas and keyboard discoverability still require native review; small artwork must not force unusably small controls.

Compare shape, portrait readability, HP digits/fill and occupied space. Keep the same world, target/objective data, skill count, key order and XP so the choice concerns status artwork. Do not interpret generated glyph drift as new skill definitions. Current/max HP should read1240/1600 with approximately77.5% fill. Avoid huge heads, broad gold framing, gem/spike clutter and fake mastered progress. All imagery is illustrative; no production assets are installed.

Exact prompts/input roles/source links: combat-hud-status-variants-prompts.json. Requested final review outputs and comparison page: tmp/review/combat_hud_status_variants_2026_10_17/. Keep these temporary and Godot-excluded, without recreating art_source/generated. Owner selection of a particular status treatment remains open.

Generation review: all three requested final images are saved. Visual inspection confirms distinct round/card/octagonal status frames, HP below the portrait,8+6 skills with separate SPACE, and bottom-right satchel/TAB plus cog/ESC with the former banners removed. A is the round option; B is the connected card; C exposes a longer, cleaner health strip with a small angular portrait. Generated metrics and HP fill remain approximate. The local gallery includes status close-ups and full-screen views; all image links are checked. All653 protected production files remain identical. No status treatment is owner-selected yet.

### Earlier layout exploration (superseded by current direction)

Each is a separate full-screen concept, using the same live Stage I screenshot as world/character reference. UI values, skills, cast, enemy level and objective are illustrative samples, not existing content or authoritative balance. The boss panel is an example of the future interface, not a claim that this boss appears in Stage I. None of these images is a runtime texture.

| Candidate | Player status and skills | Purpose |
| --- | --- | --- |
| A: Relic Orbit | Compact red central health orb, four King powers arranged around it, a smaller F1-F4 weapon row above | Strong central health focus and a symmetrical combat dock |
| B: Portrait Command | King portrait at the dock's left; horizontal HP bar and four King powers to its right; weapon techniques above | Keep the owner's approved portrait identity in a consolidated dock |
| C: Steel Ribbon | Low horizontal HP/skill strip, weapon and King groups side by side; small portrait/level in a corner | Preserve the most world space and simplify the visual frame |

Common: one target header at top center, compact upper-right objective tracker, small Bag/Menu controls, bottom-edge XP numbers, a weapon/mastery readout and a dodge indicator. Samples have four proposed weapon technique slots labeled F1-F4 and four King powers labeled 1-4. Slot count and unlock schedule remain design proposals. The owner requests function-key techniques; no keys are rebound during preview work. Controls must remain remappable.

Initial concept images are saved under ignored, Godot-excluded tmp/review/combat_hud_concepts_2026_10_16/. Exact built-in generation prompts and input roles are in combat-hud-concept-prompts.json beside this document. Expanded/adaptive samples have their own compact prompt records and temporary review paths below. Keep only the requested final review outputs while design selection is pending; do not restore art_source/generated or create a permanent iteration archive.

Review after generation: A most clearly expresses the requested central-orb direction; C leaves the most world space; B retains the approved portrait emphasis. A includes duplicate level labels that should become one label in implementation, and B's two rows should be measured carefully at native size. The initial recommendation is A's orb with lighter framing, subject to owner selection. Generated text, levels and values are placeholders. Rebuild the selected design using native Godot controls, real data and purpose-sized art; never install a flattened full-screen image or assume generated typography/icon sizes are production-ready. Three final concepts are saved; all653 guarded runtime files remain exact. No gameplay test run is necessary for this documentation/preview-only pass.

## Information behavior

Review result: three compact B samples are generated with HP below the avatar and visible counts4+0,6+4 and10+10. The gallery is `tmp/review/combat_hud_compact_portrait_2026_10_17/index.html`. Generated sizing is approximate: use a single native icon-size contract when implemented rather than tracing the different mockup sizes. These remain concepts, not installed UI.

### Earlier capacity exploration:10 King and10 weapon skills (superseded)

The earlier owner request specified up to10 King skills and10 weapon skills, producing the historical studies below. The later8+6 proposal above is the current review target. Current SkillLoadoutDefinition still supports10 King slots; a separate weapon-technique authority is future work.

The owner clarifies that20 is a maximum, not a permanently visible bar: show only currently unlocked active skills and grow with further unlocks. Four available skills means four buttons. The initial full-capacity candidate uses two ten-slot rows around A's central orb; other layouts must also support the same growth. Start with approximately32px King icons and28px weapon icons at960x540; measure actual dock/font sizes before accepting dimensions. King1-0 and weaponF1-F10 are proposed, remappable bindings. F5-F10 conflict with existing editor/debug routes and require a deliberate input/debug migration before implementation. Do not change bindings during concept review. Active-skill availability, any later loadout-selection policy and control mapping remain separate from visible capacity.

The owner now requests another edited sample showing the expanded capacity. Prepare D: Twenty-skill Orbit from A's orb and C's lighter framing, with ten visible weapon techniques F1-F10 above ten King powers1-0. Each row has five icons on either side of the central orb; retain separate utilities and XP. This visual sample uses20 simultaneously visible slots to judge space/readability and does not settle learned-versus-equipped rules or authorize implementation. Its exact edit prompt is combat-hud-twenty-slot-prompt.json; the local output is tmp/review/combat_hud_concepts_2026_10_16/d_twenty_skill_orbit.png.

D is generated and saved. Visual inspection confirms all ten F1-F10 labels and all ten1-0 labels, a single central HP orb/level, XP, mastery, portrait and separate dodge. The generated dock occupies more width than the initial compact budget; final native control/icon/font sizes still need review at960x540. Do not treat the concept's physical pixel dimensions as final Godot UI sizes. Runtime remains unchanged.

### Adaptive comparison set requested by owner

The owner also wants the other visual directions expanded, not only the orb version. Prepare all three layouts at three independently growing states:

| State | King powers | Weapon techniques | Total visible buttons |
| --- | --- | --- | --- |
| Early | 1-4 | None | 4 |
| Growing | 1-6 | F1-F4 | 10 |
| Full | 1-0 | F1-F10 | 20 |

These counts illustrate layout behavior, not an accepted level/unlock schedule. Keep identical example HP/XP/level data so only capacity and arrangement change. Reuse the existing A full20 sample; generate the other eight requested screens. Exact prompts: combat-hud-adaptive-prompts.json. Local outputs and a nine-image comparison gallery live under ignored, Godot-excluded tmp/review/combat_hud_adaptive_2026_10_17/.

The nine-image comparison is now available in that folder's index.html: select4,10 or20 skills, compare A/B/C and click any image to enlarge. Eight new built-in edits plus the retained A full20 output are present; visual inspection confirms the requested key/slot counts and no locked placeholders. Generated studies vary in some decorative text, icon art and physical icon metrics; final native controls must use a consistent icon/key mapping, fixed pixel sizes and real values. All653 guarded runtime files remain exact. No game HUD, controls or progression is implemented by this gallery.

Visibility rules for implementation: locked skills have no button or reserved gap; an empty category row collapses; frame and spacing fit the populated content without enlarging icons. Preserve key assignments and order as skills unlock, rather than renumbering existing actions. Cooldowns, insufficient resource and temporarily unavailable states stay visible so controls do not jump during combat. Show only the equipped weapon's available techniques when changing family. Passive mastery choices do not become hotkeys. Rebuild layout only on unlock/loadout/equipment events; it owns no progression or skill authority. Preserve the health focal point and readable typography as the dock expands. These behaviors are requirements for a future implementation, not current runtime features.

- Player: one primary HP display, current/max numbers, visible low-health state and restrained damage trail. XP retains current/required numbers; show actual max-level state when capped. Level and family mastery are separate concepts.
- Target: selected normal enemy, elite or boss uses one shared top-center region. Prioritize the active boss during its encounter, and avoid duplicating the same boss in two full headers. Show authoritative name, health, tier and relevant statuses; show enemy level only if an actual gameplay level exists. Casting and guard/break meters require corresponding authority/events before becoming UI. Hide absent or undiscovered information.
- World health bars: retain small nearby bars for damaged/relevant enemies; avoid a large labeled panel over every member of a horde. Keep hazards, sprites and telegraphs readable.
- Objectives: start by presenting existing expedition/wave/guardian/chest progress. A full quest journal and new quest content are separate future systems. Track one main objective and at most one optional objective, with collapse available.
- Skills: keybind, authored icon, cooldown, selected/unavailable state, resource requirement and a useful tooltip. Do not repeat READY/EMPTY across every slot. Reveal progression choices deliberately rather than filling the bar with permanent dead slots.
- Weapon mastery: display a meter only after a real mastery authority exists. It must not reuse player XP or show invented progress. Buff/debuff rows stay bounded; overflow can aggregate.

## Weapon roles before recipe progression

The owner's priority is all-family progression and balance, not merely adding recipes for one weapon. Establish each role and test its costs first. These mechanics are proposals, except existing Reaper hook/return/wounded rules.

| Family | Intended strength | Potential signature | Cost to preserve |
| --- | --- | --- | --- |
| Sword | Responsive dueling and adaptation | Timed guard/counter | Moderate burst and crowd clearing |
| Greatsword | Very strong committed hits and packed-group cleaves | Momentum and a crushing finisher | Preparation/recovery, punishable misses |
| Axe | Armored enemies and elites | Fracture armor/guard to open a damage window | Less broad coverage than Greatsword |
| Twinsteel | Focused sustained damage and agility | Flow built through contact and timed dodges | Short reach and limited interruption |
| Reaper | Space control and arranging groups | Refine existing hook, returning throw and wounded finish | Lower direct armored-target pressure; bounded control |

Fast contact can still feel heavy: adjust anticipation/recovery and per-hit payoff without turning the accepted contact animation into slow motion. Current basic-attack phases and animation already scale by 1/(1+equipment attack-speed bonus), capped at +50%; Reaper flight scales too. Movement, reach, skill cooldowns and per-hit damage do not automatically gain that bonus. Compare roles at baseline and maximum speed.

Test every family against the same ordinary target, armored elite, mobile enemy and growing mixed groups. Measure damage, meaningful targets hit, stagger/control, exposure, clear time and frame time. Balance on-hit healing/status/resource generation so rapid hits and large cleaves do not multiply every benefit without limits. A future horde stage should favor cleave/control while still giving focused weapons priority targets to eliminate. Current campaign ends at Stage VI; Stage XII and 100-enemy scenarios are future test/design examples, not implemented content. Profile simultaneous enemy count separately from total enemies across waves.

## Progression and skills

Owner direction226 extends this plan: weapons craft at Sanctuary/base, weapon techniques come from mastery, and item upgrades eventually have visible weapon/icon/UI milestones. Read weapon-mastery-crafting-and-combat-expansion.md for the verified damage/control baseline, HP/status expansion, earning options, mentor proposal and example weapon techniques. None of that progression is installed by the HUD concepts.

Proposed ownership: King level for general growth; Nema for item forging/upgrades; Eira for King powers/loadout; a possible new weapons mentor for family lessons/trials. Veyr the Godscarred is a working proposal only, and current NPC services are not moved by this document. Mastery follows the weapon family across equipment variants and grows from meaningful combat contribution rather than raw hit count; the suggested clear bonuses and milestone proofs still need agreement. New families need useful complete basic combos immediately; mastery adds choices instead of requiring a long grind for baseline usability.

Separate King powers from weapon techniques. Current review target:8 King active slots and6 equipped-weapon active slots. Recommend keeping learned capacity separate from equipped capacity; exact learned limits, technique unlocks and passive/finisher branch rules still need agreement. Preserve current skills and the implemented ten-slot loadout until an explicit migration design is accepted. Avoid a universal skill invalidating every weapon's offensive niche.

Open product decision: one weapon selected before a stage versus two readied weapons with an in-combat swap. The previous recommendation favors two; the owner has not selected this yet. Concepts do not establish an implemented swap system. If adopted, respect attack commitment and released-weapon ownership, retain cooldowns across swaps and prevent swap-based resets. Example future combinations: Axe fracture into Twinsteel pressure, or Reaper control into Greatsword cleave.

## Delivery order and acceptance

1. Owner selects a layout or combines specific elements; confirm the skill/keybind model and one-versus-two weapon decision.
2. Build a HUD-only native review using existing real health/progression/target/skill data. Test logical-size readability, safe margins, tooltips, mouse passthrough, keyboard/controller navigation, no-target/max-level states and overlap with dialogue/Bag/boss/objectives. Presentation must not become gameplay authority.
3. Prototype and compare all five weapon identities together, preserving accepted artwork unless a particular new action requires reviewed complete poses. Show current and proposed cadence, damage, reach and control clearly.
4. Add mastery/technique authorities and progression, with backward-compatible saves and isolated migration tests; then connect earned recipes, costs, rewards and Eira/Nema presentation.
5. Verify a fresh campaign and existing profile, locked/unlocked loadouts, family changes, attack-speed extremes, mixed encounters and crowded performance before replacing the current gameplay flow.

No implementation or removal is authorized merely by a generated mockup. The owner asked to review ideas and examples first. Do not add another raw-art archive, change accepted actor art, delete existing powers or commit/push during this planning pass.
