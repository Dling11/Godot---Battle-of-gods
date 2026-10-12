# Player vitality, growth and bag readability

2026-10-02. Owner provisionally passed Eira, described Nema as clear/accurate, and requested a Nema double-check followed by HP, level and bag improvements with generated artwork. The shared HUD/bag pass is implemented; Decision165 marks Sanctuary temporarily complete. Phone profiling and future balance remain open. King, accepted skills, workshop scale and F-required entry remain the baseline.

## Nema audit and correction

Verified existing recipe previews, material counts, gold fees, seal/category gates, exact crafting, unique-output rejection, result text, bag appearance and equip behavior. No recipe/cost/economy redesign.

A presentation shortcut classified every sealed no-save test session as F9's all-owned preset. It incorrectly showed ALREADY OWNED for an unowned, funded recipe during review. Removed that shortcut: CraftingService.get_recipe_status alone decides readiness/ownership. Actual F9-owned outputs remain uncraftable. Rootforge now observes RunSession currency changes while open, so a changed gold balance refreshes the fee and action. Normal atomic save/reload is covered by crafting_service_smoke; review crafting works in memory without writing its profile.

## Vitality and growth

Owner selected Slim Runic simplicity, then C Portrait Link, then requested a smaller footprint with XP inside its bar. The active connected frame is248x64, about45% less area than the initial300x96. Keep the circular King portrait/LV badge and gold/violet rails; remove both raised plaques and draw native outlined HP/XP digits centered INSIDE the fills, above both bars. Coins/critical sit above a smaller248x26 bag button; shield and finite level notice move upward without overlap. Earlier frames remain historical. Native label/fill rectangles are documented in normalization.json. HP/red fill still update immediately from HealthComponent. The gold trail holds .25s and settles over .55s; healing/max-HP changes snap it. Critical at25% or below has red styling and CRITICAL text; tooltip reads actual regeneration delay. Gameplay and progression are unchanged.

Vow retains its real shield/duration readout, now below the bag button. Shield-only damage leaves HP unchanged. A separate finite level-up notice sits below that readout and names newly eligible Eira training. No perpetual flashing or new per-frame gameplay observer is introduced.

HUD and CharacterMenu share progression_readout.gd. The HUD uses LV.N plus compact exact XP digits, with comma grouping for large numbers. XP is into the current level against its own requirement, not lifetime total: after150 cumulative XP, Level2 displays XP0/250; after175, it displays XP25/250. The concept's3,250/10,000 was illustrative only. Hover and CharacterMenu retain full XP remaining/next-level/training copy. STAGE CAP appears in the XP plaque while the LV badge names the current level; hover names the actual stage/cap requirement. MAX LEVEL remains distinct. ProgressionDefinition display names and next_cap_requirement do not change thresholds, earned levels, growth, caps or rewards. Legacy earned levels above old story gates receive the next higher cap requirement. XP still stops at the ceiling while gold/loot continue.

Current curve: 0/150/400/750/1200/1750/2400/3150/4000/4950 cumulative XP. Base HP remains140 +12 per level, cap10, before gear. Stages I/II/III/IV/V unlock caps4/5/6/7/10.

## Character and bag

The owner selected A Centered Paperdoll, now implemented in the shared840x490 modal at960x540. Five armor cards flank King's left; weapon/bracer/amulet/ring/talisman flank his right, with five aligned38px rows and4px gaps. Stable equipment indices and slot types remain. A152x206 portrait field anchors centrally, with the approved King model at2x scale and x76 in its152px content canvas; the generated frame has zero content margins. The equipment panel is520px wide, with at least280px for actual item details on the right. Ten generated empty-slot silhouettes replace repeated padlocks without implying ownership or locks. King's Sword gets a dedicated generated64px item icon. Clicking equipped cards inspects their actual item.

The full-width bag remains below. Existing12-column grid fills its width, keeps icons bounded to24px and has bounded focus-following scroll. Search matches owned item name, slot/family or rarity, case-insensitively; native clear control removes the query. Original A/B/C concept sources remain under art_source/generated/ui/loadout_choices_2026_10_02/; B/C are unselected and their illustrative counts do not define rules.

All, Equipment, Materials and Sort remain working controls. Unimplemented Consumables/Key bag filters are hidden; their future functionality is not fabricated. Milestone seals retain StoryState/crafting authority. SHOWING counts the actual filtered results. Footer separately reports total owned equipment and material types; materials still consume no equipment bag space. The old24-slot number was display capacity/minimum cells, not a newly enforced transaction limit; no ownership or capacity rules change.

Selection, explicit equip, drag equip, quantities/rarity/equipped markers and sorting remain. Empty searches show an honest empty detail state with no unrelated equip action. Search keeps typing focus; inventory rebuilds restore focused item by stable identity. Equipment/material/weapon events update the visible menu. HUD click and Tab remain entry routes; Esc resumes gameplay.

## Ownership and assets

- ui/hud/player_status_presenter.gd composes finite HUD feedback; existing CombatHUD health/progression fields stay live, including unique HealthBar ownership.
- ui/hud/progression_readout.gd formats authoritative progression data for both views.
- CharacterMenu selects/filters/sorts; Player and inventory services still own equip/ownership/save. centered_paperdoll_presenter.gd composes only visual skin and paired slot geometry on build/resize events. It reuses the established Sanctuary control palette in all contexts; SanctuaryInterface preserves its menu-owned theme and frame. No per-frame layout or gameplay authority is introduced.
- Current equipment assets: assets/ui/inventory/ (256x128 nine-slice frame with16px slices, ten24px slot silhouettes and64px signature sword). Built-in imagegen originals/exact prompts and manifests: art_source/generated/ui/centered_paperdoll_2026_10_02/. retired generation tool (recover from Git history only) and retired generation tool (recover from Git history only) apply binary alpha, occupied-pixel crop and nearest resize; icon aspect is preserved. The latter records inspected source gutters because generated rows were not exact fifths. Native review: historical Git-only review/ui/centered_paperdoll_2026_10_02/.
- Generated originals and exact built-in imagegen prompts: art_source/generated/ui/player_readability_2026_10_02/.
- Current runtime assets: assets/ui/player_readability/portrait_link_compact.png248x64 and satchel.png24x24. Binary alpha, nearest sampling, mipmaps disabled. retired generation tool (recover from Git history only) records crop/size/inside-bar slots. Exact built-in edit prompts and preserved source stages: art_source/generated/ui/portrait_link_compact_2026_10_02/. The frame contains the static approved King portrait/empty chrome; numbers/fills remain native controls. Prior frames/sources/builders/captures are historical; satchel art is unchanged.
- Current native evidence: historical Git-only review/ui/portrait_link_compact_2026_10_02/; earlier portrait_link_2026_10_02/, slim_runic_hp_2026_10_02/ and player_readability_2026_10_02/ remain historical.
- Presenter preserves unique scene ownership when mounting health, level, XP and coin controls; legacy HealthPanel/ProgressPanel are hidden. Explicit town test controls start at x324 to clear the wider HUD; this changes debug presentation only.

The HP/bag changes remain shared in normal play. Decision165 promotes the broader renewed Sanctuary and generated modal theme to the normal town; expeditions retain their battle frame. See sanctuary-closeout.md.

## Immediate test

Normal F5/Continue loads the shared HP/bag changes. For a safe interactive fixture:

`powershell -NoProfile -ExecutionPolicy Bypass -File ./tools/launch_sanctuary_study.ps1 -InterfaceDemo`

Starts beside Nema with temporary100 XP,750 gold,8 of every authored material and one owned glove. Saving is suppressed before fixture mutation for the entire process. UI TEST controls: +75 XP triggers real growth/level notices; Lose35 HP exercises actual damage with a1HP floor; Heal restores current maximum; Next stage cap applies the next authored story gate. They hide with other review controls while menus are open. F/dialogue opens Nema, Tab/HUD opens bag. Closing discards this test session; normal saves remain untouched. Existing -Eira/-TrainingDemo routes remain available.

## Verification and limits

74 rendered interface checks: compact texture/dimensions, HP/XP digits inside fills and drawn above them, unique progression controls, five-digit fit/grouping, currency/critical/bag bounds, real portrait/body centering, immediate HP/trail/critical/heal, level-up/HP growth and exact XP reset/fill, stage/max/legacy cap copy, shield-only hits, real F/Nema crafting/exact spends, ownership fix, currency refresh, profile checksum, bag click/counts/navigation/sort/search/focus/empty states and real equip. The first compact pass exposed1px font-height overflow; match the13px bar height to the real font metrics, then all checks pass.

14 rendered launcher checks exercise actual demo buttons, native bounds/map separation, XP cap/unlock, critical/heal, seeded Nema readiness and bag items. CharacterMenu, player/run progression, atomic crafting and UI-icon smoke pass; historical Sanctuary interface52 and retained Eira flow73 headless checks and combined Vow/Worldsplitter49 pass. Editor import and git diff --check pass. Existing GPU shutdown texture warnings remain; automated results do not establish subjective feel or phone readability.

Map/minimap/directory are temporarily withdrawn per owner request. TownMap.PRESENTATION_ENABLED=false stops its timer, activation and M input. Review map action/hint and noticeboard prompt/input are omitted; crossing the inactive noticeboard does not consume F or clear another prompt. Assets/modules remain for later restoration. NPC service beacons/F still work. 68 rendered normal-town checks cover save/services and hidden/stopped map, including failed activation/selection;14 demo checks cover compact bounds, real progression/damage/heal and fixtures. CharacterMenu, player progression and UI-icon smoke pass. Existing GPU shutdown warnings and representative-phone readability remain open.

Selected A verification:87 rendered interface checks include five balanced rows, no King/card overlap, preserved frame in normal Sanctuary, real equipped-card clicks, existing ownership/save and inventory behavior;14 rendered fixture checks and68 normal-town checks pass. CharacterMenu, UI-icon and73 headless Sanctuary skills-flow checks also pass. Native evidence is under centered_paperdoll_2026_10_02/. Earlier counts/captures above describe the compact HUD delivery. Existing GPU shutdown warnings remain.

Next: owner play-checks selected A in the compact UI; later expedition objective/reward and fight/loot/craft/equip/train checks remain. Umi needs targeted observed corrections, not an automatic rewrite. Further houses/interiors remain deferred.

2026-10-13 maintenance: previous generation/comparison commands were retired; current output assets remain authoritative. New captures use ignored tmp/review/. See docs/maintenance/repository-cleanup.md.
