extends SceneTree

const HUB = preload("res://levels/sanctuary/sanctuary.tscn")
const Readout = preload("res://ui/equipment/equipment_inspection_readout.gd")
const OUT := "res://tmp/review/ui/bag_inspection_2026_10_17/"
var checks := 0
var failures := 0

func _initialize() -> void: call_deferred("_run")

func _run() -> void:
	AudioServer.set_bus_mute(0,true)
	root.size = Vector2i(960,540)
	var save := root.get_node("SaveService")
	check(save.configure_storage_path_for_testing("user://bag_inspection_smoke.json"),"Cannot isolate Bag test save")
	save.delete_profile()
	for entry in [["RunSession","reset_run"],["WeaponInventory","reset_inventory"],["GearInventory","reset_inventory"],["StoryState","reset_story"],["MaterialInventory","reset_inventory"]]: root.get_node(entry[0]).call(entry[1])
	var hub := HUB.instantiate()
	root.add_child(hub)
	current_scene = hub
	await settle()
	var actor: Player = hub.player
	actor.apply_debug_testing_preset()
	actor.vitality_component.set_physics_process(false)
	await key(KEY_TAB)
	var menu: CharacterMenu = hub.character_menu
	var detail := menu.equipment_detail_panel
	check(menu.visible and paused,"Physical Tab does not open and pause the Bag")
	check(not menu.bag_search.is_visible_in_tree(),"Equipment still exposes search")
	check(menu.z_index > hub.combat_hud.get_skill_slot(1).key_label.z_index,"HUD key labels can draw over the modal")
	var fixed_footer := detail.equip_button.get_global_rect()
	for item: EquipmentDefinition in actor.weapon_catalog.weapons:
		menu._on_equipment_selected(item)
		await settle()
		check(Rect2(Vector2.ZERO,Vector2(960,540)).encloses(menu.get_node("Panel").get_global_rect()),item.display_name+" grows the outer modal")
		check(menu.gear_page.get_global_rect().encloses(detail.get_global_rect()),item.display_name+" pushes detail outside the page")
		check(menu.gear_page.get_parent().get_global_rect().encloses(menu.gear_page.get_global_rect()),item.display_name+" pushes the page outside its host")
		check(detail.get_global_rect().encloses(detail.body_scroll.get_global_rect()),item.display_name+" scroll escapes the item panel")
		check(detail.equip_button.get_global_rect() == fixed_footer,item.display_name+" moves the equip footer")
		check(detail.power_label.get_parsed_text().contains("%.1f" % WeaponCombatReadout.base_dps(item.weapon_definition)),item.display_name+" DPS ignores current tuning")
		check(detail.synergy_body.get_parsed_text().contains("%.1f–%.1f" % [WeaponCombatReadout.step_range(item.weapon_definition,0).x,WeaponCombatReadout.step_range(item.weapon_definition,0).y]),item.display_name+" combo damage is stale")
		var icon := detail.item_icon
		for corner in [Vector2.ZERO,Vector2(icon.size.x,0),icon.size,Vector2(0,icon.size.y)]:
			check(icon.get_parent().get_global_rect().grow(.1).has_point(icon.get_global_transform()*corner),item.display_name+" icon is clipped")
	var scythe := actor.weapon_catalog.find_weapon(&"weapon_king_iron_reaper")
	menu._on_equipment_selected(scythe)
	await settle()
	check(detail.body_scroll.get_v_scroll_bar().max_value > detail.body_scroll.size.y,"Scythe has no accessible scroll range")
	await wheel(detail.body_scroll.get_global_rect().get_center())
	if DisplayServer.get_name() != "headless": check(detail.body_scroll.scroll_vertical > 0,"Actual mouse wheel cannot scroll item details")
	detail.body_scroll.scroll_vertical = 10000
	await settle()
	check(detail.equip_button.get_global_rect() == fixed_footer and detail.equip_button.visible,"Scrolling hides or moves the equip action")
	await capture("scythe_scrolled_960.png")
	# A long future description must not enlarge the layout.
	var verbose := scythe.duplicate() as EquipmentDefinition
	verbose.lore = "A longer description with several lines of readable item lore. ".repeat(60)
	detail.configure(verbose,false,true,actor.get_equipped_weapon_item())
	await settle()
	check(detail.equip_button.get_global_rect() == fixed_footer and menu.gear_page.get_global_rect().encloses(detail.get_global_rect()),"Long lore enlarges the item inspector")
	# Mutating an isolated definition updates all displayed numbers on selection.
	var tuned := scythe.duplicate() as EquipmentDefinition
	tuned.weapon_definition = scythe.weapon_definition.duplicate(true)
	tuned.weapon_definition.basic_damage_minimum = 100
	tuned.weapon_definition.basic_damage_maximum = 120
	check(Readout.stats(tuned).contains("100–120") and Readout.mechanics(tuned).contains("100.0–120.0"),"Inspector duplicates old weapon damage numbers")
	tuned.weapon_definition.combo.windups[0] += 1
	check(Readout.stats(tuned).contains("%.2fs" % WeaponCombatReadout.duration(tuned.weapon_definition)),"Inspector ignores changed combo timings")
	var wood := EquipmentDefinition.new()
	wood.rarity = EquipmentDefinition.Rarity.WOOD
	var mythic := EquipmentDefinition.new()
	mythic.rarity = EquipmentDefinition.Rarity.MYTHIC
	menu._inventory_sort_mode = &"rarity"
	check(menu._equipment_sort_less(mythic,wood) and not menu._equipment_sort_less(wood,mythic),"Historical rarity IDs sort Wood above Mythic")
	var header := menu.all_filter_button.get_parent()
	await click(header.get_node("WeaponsFilterButton").get_global_rect().get_center())
	check(menu._equipment_cards.size() == actor.weapon_catalog.weapons.size() and menu._material_cards.is_empty(),"Weapons category leaks armor or materials")
	for card in menu._equipment_cards: check(card.equipment_definition.slot == EquipmentDefinition.Slot.WEAPON,"Weapons category includes armor")
	await click(header.get_node("ArmorFilterButton").get_global_rect().get_center())
	check(menu._equipment_cards.size() == 5 and not menu.bag_search.is_visible_in_tree(),"Armor category is incorrect or exposes search")
	await click(menu.materials_filter_button.get_global_rect().get_center())
	check(menu._material_cards.size() == 15 and menu.bag_search.is_visible_in_tree(),"Material pouch/search regressed")
	menu.bag_search.text = "VaRkUuN"
	menu.bag_search.text_changed.emit(menu.bag_search.text)
	await settle()
	check(menu._material_cards.size() == 1 and menu._material_cards[0].material_definition.material_id == &"forest_varkuun_core","Material search fails")
	await click(header.get_node("WeaponsFilterButton").get_global_rect().get_center())
	check(menu._equipment_cards.size() == actor.weapon_catalog.weapons.size() and menu.bag_search.text.is_empty(),"Hidden material search filters equipment")
	for mode in CharacterMenu.SORT_MODES:
		var index := CharacterMenu.SORT_MODES.find(mode)
		menu.sort_button.select(index)
		menu.sort_button.item_selected.emit(index)
		check(menu._inventory_sort_mode == mode and menu._equipment_cards.size() == actor.weapon_catalog.weapons.size(),"Sort selection loses items")
	menu._on_equipment_selected(scythe)
	await settle()
	await click(detail.equip_button.get_global_rect().get_center())
	check(actor.get_equipped_weapon_item() == scythe and detail.equip_button.disabled,"Scroll footer cannot equip the inspected weapon")
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		var with_keys := root.get_texture().get_image()
		var keys: Array[Label] = []
		for slot in hub.combat_hud._skill_slots:
			if slot.visible:
				keys.append(slot.key_label)
				slot.key_label.hide()
		await RenderingServer.frame_post_draw
		var without_keys := root.get_texture().get_image()
		var changes := 0
		for label in keys:
			var rect := Rect2i(label.get_global_rect().intersection(menu.get_node("Panel").get_global_rect()))
			for y in range(rect.position.y,rect.end.y):
				for x in range(rect.position.x,rect.end.x):
					var a := with_keys.get_pixel(x,y)
					var b := without_keys.get_pixel(x,y)
					if maxf(absf(a.r-b.r),maxf(absf(a.g-b.g),absf(a.b-b.b))) > .012: changes += 1
			label.show()
		check(changes == 0,"HUD numbers visibly bleed through the Bag")
		await capture("bag_native_960.png")
	await key(KEY_ESCAPE)
	check(not menu.visible and not paused,"Bag close does not resume gameplay")
	hub.queue_free()
	current_scene = null
	await process_frame
	save.delete_profile()
	save.reset_storage_path_after_testing()
	print("BAG_INSPECTION: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)

func settle() -> void:
	for frame in 5: await process_frame

func click(point: Vector2) -> void:
	var event := InputEventMouseButton.new()
	event.position = point
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	root.push_input(event)
	event = event.duplicate()
	event.pressed = false
	root.push_input(event)
	await settle()

func wheel(point: Vector2) -> void:
	var event := InputEventMouseButton.new()
	event.position = point
	event.button_index = MOUSE_BUTTON_WHEEL_DOWN
	event.pressed = true
	root.push_input(event)
	event = event.duplicate()
	event.pressed = false
	root.push_input(event)
	await settle()

func key(code: Key) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = true
	root.push_input(event)
	event = event.duplicate()
	event.pressed = false
	root.push_input(event)
	await settle()

func capture(filename: String) -> void:
	if DisplayServer.get_name() == "headless": return
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(OUT)
	check(root.get_texture().get_image().save_png(OUT+filename) == OK,"Cannot save native Bag review")

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
