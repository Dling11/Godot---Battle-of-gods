# Bag equipment inspection — Decision227

Updated2026-10-17. The owner accepts the sealed mastery/level HUD and requests the Bag next. The new Bag is installed and tested; owner visual review remains open.

Art review2026-10-17: the owner accepts the actual-Bag floorless gradient after rejecting architectural and flat-floor trials. The native charcoal-to-muted-violet radial gradient and thin slate border are now installed, with no ground, pedestal or scenery. Existing complete King/steel pixels and0.85 scale are preserved; whole-actor positioning balances the floorless card. The rejected chamber PNG/import is deleted. Selected settings and native captures: art_source/reference/ui/bag-inspection.json. Bag behavior and gameplay remain unchanged.

## Layout and input

The shared840×490 modal stays inside the960×540 logical viewport. CharacterMenu uses z_index10 above HUD key labels; the existing skill collection remains on CanvasLayer110. The page host is a MarginContainer, so visible-page minimum sizes participate in layout. The264px loadout row contains a500px left loadout and at least300px item inspector. Main content clips to its frame.

The inspector keeps its item identity and equip action outside a bounded ScrollContainer. Stats, comparison, lore and all combo details scroll together. Long descriptions cannot enlarge the modal or move the equip action. Selection resets item scroll. Mouse wheel, scrollbar and explicit equip are tested. Themed6px scrollbars match the cyan/violet HUD chrome. Shared illustrated backdrops insert before content and lay out immediately/on resize, avoiding deferred callbacks to freed controls.

All, icon-led Weapons/Armor, Gear and Materials categories show actual owned items. Search appears only for Materials; leaving that category clears the query. Sort is an explicit dropdown: Slot, Rarity, Name, Hit, DPS and Quantity. Rarity uses an ordered presentation rank because serialized IDs place Wood/Stone/Iron after Mythic. Existing saved enum values stay unchanged. Equipment has no item-level model, so no invented level sort/requirements are shown.

## Live item information

equipment_inspection_readout.gd reads WeaponDefinition, SwordComboDefinition, contact rules and returning-attack data each time an item is inspected/rebuilt. Physical damage/DPS use warm red, skill power violet, cadence cyan, and comparison improvements/reductions green/red. Damage rolls, chain duration, per-cut damage, critical chance/multiplier, nominal DPS, pull, wounded thresholds/bonus and outward/return shares come from current definitions. Changing Greatsword tuning therefore updates these readouts on inspection. Static lore/synergy titles stay authored. Legacy get_stat_summary consumers remain compatible.

These are base values, excluding gear attack speed, critical outcomes, buffs, conditional bonuses and defenses. Returning-cut totals require both legs. King skill power remains distinct from final skill damage. Family mastery, earning, item upgrades and balance are not installed by this presentation change.

equipment_icon_presenter.gd caches complete occupied texture regions and fits the actual steel within its preview bounds, tilting straight tall blades. No weapon pixels are repainted. Inspector icons fit72×72 inside84×80 previews; equipment bag glyphs fit28×28. Twinsteel retains two blades and Greatsword retains its broad long silhouette. Rarity name/rim/glow use actual item tier; higher-tier inspection glow pulses only while visible. King's level does not recolour or upgrade an item.

## King preview and retention

The accepted168×206 floorless gradient replaces the illustrated chamber, rotating polygon, dark core and flat shadow. Private complete family rest poses share0.85 scale; their lower boot row anchors at(0.5,0.675) within the portrait. Overall paint bounds include long scarves or integrated blades and cannot define King's centre. Varkuun's unchanged sword form uses the current default Sword family in this presentation. Body/head/weapon pixels and gameplay poses stay unchanged. The168px field keeps large blades inside the portrait beside five balanced equipment rows.

The selected native portrait_backdrop.tres uses a336×412 radial gradient; a1px slate border is drawn by the UI. No background raster is retained. The rejected472,484-byte chamber PNG and its import sidecar are removed. Selected settings and layout: art_source/reference/ui/bag-inspection.json. All683 remaining guarded assets stay byte-identical. The shared older paperdoll frame is still used by expedition feedback.

Reference cues: category-based equipment browsing and a clear rarity/name/stat hierarchy from the [GW2 equipment panel](https://wiki.guildwars2.com/wiki/Equipment) and [item rarity conventions](https://wiki.guildwars2.com/wiki/Rarity). Artwork and implementation are project-specific.

## Verification and review

Native Compatibility Bag audit99/0 covers all six weapons, clipped icons, long scythe/future lore, fixed actions, actual wheel input, categories, material search, sorting, current damage/timing, real equip, Escape and a rendered before/after HUD-key comparison. Native HUD261/0 and weapon/contact/equip301/0 pass. All928 retained resources load. Readability74/0, Sanctuary skills73/0, character menu and equipment catalog checks pass. Weapon audio assertions require native rendering/audio; the headless attempt was stopped after its audio-dependent path failed to complete. Native301/0 is the completed weapon result. Production profile/backup hashes are unchanged. The accepted-gradient follow-up reruns native Bag99/0, character menu, equipment catalog and archive-boundary checks; native captures cover all six items, including oversized Greatsword/Reaper. All683 retained asset hashes match.

Actual1080p captures: ignored tmp/review/ui/bag_inspection_2026_10_17/, including each family, scythe_inspection.png, scythe_mechanics.png and greatsword_compare.png. No screenshot is installed as UI. Stop the old run, F5 → Continue → Tab; use F9 only for session-only all-family review. No commit/push.
