extends SceneTree

const HUB = preload("res://levels/sanctuary/sanctuary.tscn")
const Study = preload("res://levels/sanctuary/town/sanctuary_town.gd")
const MATERIALS = preload("res://data/items/materials/material_catalog.tres")
const GEAR = preload("res://data/items/equipment/forest/stage_5_core_catalog.tres")
const PROFILE := "user://player_interface_readability_smoke.json"
const EVIDENCE := "res://tmp/review/ui/centered_paperdoll_2026_10_02/"
var checks := 0
var failures := 0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	root.size = Vector2i(960,540)
	var save := root.get_node("SaveService")
	check(save.configure_storage_path_for_testing(PROFILE),"Cannot isolate interface audit save")
	save.delete_profile()
	for reset in [["RunSession","reset_run"],["StoryState","reset_story"],["MaterialInventory","reset_inventory"],["GearInventory","reset_inventory"],["WeaponInventory","reset_inventory"],["RecipeDiscovery","reset_discoveries"],["LootState","reset_state"]]:
		root.get_node(reset[0]).call(reset[1])
	var hub: Node = HUB.instantiate()
	root.add_child(hub)
	current_scene = hub
	await process_frame
	var actor: Player = hub.player
	actor.vitality_component.set_physics_process(false)
	var hud: CombatHUD = hub.combat_hud
	var presenter: Node = hud.status_presenter
	check(presenter.frame.get_theme_stylebox("panel") is StyleBoxTexture,"HUD does not use the new generated frame")
	check(presenter.frame.size == Vector2(248,64) and presenter.frame.get_theme_stylebox("panel").texture.resource_path.ends_with("portrait_link_compact.png"),"HUD loses the compact Portrait Link frame")
	check(presenter.frame.get_global_rect().encloses(hud.health_bar.get_global_rect()) and hud.health_bar.get_global_rect().encloses(hud.health_label.get_global_rect()) and hud.health_label.get_index() > hud.health_bar.get_parent().get_index(),"HP digits escape the bar or draw beneath its fill")
	check(presenter.frame.get_global_rect().encloses(hud.experience_bar.get_global_rect()) and hud.experience_bar.get_global_rect().encloses(hud.experience_label.get_global_rect()) and hud.experience_label.get_index() > hud.experience_bar.get_index(),"XP digits escape the bar or draw beneath its fill")
	check(not hud.get_node("ProgressPanel").visible and not presenter.health_state.get_global_rect().intersects(hud.coin_label.get_global_rect()) and not presenter.frame.get_global_rect().intersects(hud.character_menu_button.get_global_rect()),"Legacy panel or status/currency/bag overlap remains")
	check(hud.get_node("%LevelLabel") == hud.level_label and hud.get_node("%ExperienceBar") == hud.experience_bar and hud.get_node("%ExperienceLabel") == hud.experience_label and hud.get_node("%CoinLabel") == hud.coin_label,"Portrait composition loses unique progression controls")
	var font := hud.experience_label.get_theme_font("font")
	check(font.get_string_size("XP 3,250 / 10,000",HORIZONTAL_ALIGNMENT_LEFT,-1,hud.experience_label.get_theme_font_size("font_size")).x <= hud.experience_label.size.x,"Five-digit XP values will clip in the approved plaque")
	check(CombatHUD.ProgressionReadout.format_number(10000) == "10,000" and CombatHUD.ProgressionReadout.format_number(3250) == "3,250" and CombatHUD.ProgressionReadout.format_number(0) == "0","XP/currency digits are incorrectly grouped")
	check(hud.get_node("%HealthBar") == hud.health_bar,"Status composition loses the scene's unique health control")
	check(hud.health_bar.value == 140 and hud.health_label.text.contains("140 / 140"),"Initial vitality is inaccurate")
	check(hud.health_label.tooltip_text.contains("100%") and hud.health_label.tooltip_text.contains("5"),"Vitality tooltip is missing or disagrees with regeneration data")
	check(hud.level_label.text == "LV. 1" and hud.experience_label.text == "XP 0 / 150" and hud.experience_label.tooltip_text.contains("150 to Lv.2"),"Actual level and exact XP digits are unclear")
	await capture("hud_normal.png")
	actor.health_component.set_current_health(70)
	check(hud.health_bar.value == 70 and presenter.health_trail.value == 140,"HP delays damage instead of only animating the trail")
	await capture("hud_damage_trail.png")
	actor.health_component.set_current_health(30)
	check(presenter.health_state.text == "CRITICAL" and hud.health_bar.value == 30,"Low vitality has no explicit readable state")
	await create_timer(1,false).timeout
	check(is_equal_approx(presenter.health_trail.value,30),"Damage trail does not settle to actual HP")
	await capture("hud_critical.png")
	actor.health_component.set_current_health(140)
	check(presenter.health_state.text.is_empty() and presenter.health_trail.value == 140,"Healing leaves a false critical/damage display")
	actor.progression_component.grant_rewards(150,0)
	check(actor.progression_component.level == 2 and actor.health_component.maximum_health == 152 and hud.level_label.text == "LV. 2" and hud.experience_label.text == "XP 0 / 250" and hud.experience_bar.max_value == 250 and hud.experience_bar.value == 0,"Real level-up disagrees with HUD level/HP/XP or changes the curve")
	check(presenter.level_toast.visible and presenter._toast_text.text.contains("Earthsplitter"),"Real level-up does not announce Eira training")
	await capture("hud_level_up.png")
	var session := root.get_node("RunSession")
	session.update_progression(400,0)
	check(hud.experience_label.text == "STAGE CAP" and hud.level_label.text == "LV. 3" and hud.experience_label.tooltip_text.contains("Stage I") and hud.experience_label.tooltip_text.contains("Level 4"),"Stage cap fails to name its real unlock")
	actor.progression_component.grant_rewards(999,10)
	check(session.total_experience == 400 and session.coins == 10,"Stage-cap copy changed reward authority")
	await capture("hud_stage_cap.png")
	var story := root.get_node("StoryState")
	story.remember_story(&"forgotten_grove_stage_1_cleared")
	check(hud.experience_label.text == "XP 0 / 350" and hud.experience_label.tooltip_text.contains("350 to Lv.4"),"Unlocking a cap leaves the HUD stuck")
	session.update_progression(1750,10)
	check(hud.experience_label.text == "STAGE CAP" and hud.level_label.text == "LV. 6" and hud.experience_label.tooltip_text.contains("Stage IV") and hud.experience_label.tooltip_text.contains("Level 7"),"Older earned levels are given an obsolete lower cap requirement")
	session.update_progression(400,10)
	check(actor.request_ability(4),"HUD rearrangement blocks Unbroken Vow")
	await create_timer(.2,false,true).timeout
	var vow_status: Control = hud.get_node("VowStatus")
	check(vow_status.visible and not vow_status.get_global_rect().intersects(hud.character_menu_button.get_global_rect()) and not vow_status.get_global_rect().intersects(presenter.level_toast.get_global_rect()),"Vow shield overlaps bag access or level feedback")
	var shield_hit := DamageInfo.new(10,actor,Vector2.RIGHT)
	var health_before := hud.health_bar.value
	check(actor.health_component.apply_damage(shield_hit) and hud.health_bar.value == health_before and vow_status._label.text.contains("VOW"),"Shield-only damage incorrectly drops the HP display")
	await capture("hud_vow_shield.png")
	var study: Node = hub.get_node("SanctuaryTown")
	study.enable_test_controls()
	save.suppress_autosave_for_debug_session()
	var profile_before := FileAccess.get_md5(PROFILE)
	check(not presenter.frame.get_global_rect().intersects(study._panel.get_global_rect()),"Review controls overlap the new status panel")
	study.visit_nema()
	await create_timer(.2).timeout
	await key(KEY_F)
	check(hub.dialogue_panel.visible,"Physical F cannot reach Nema")
	hub.dialogue_panel.close_dialogue(true)
	await process_frame
	var forge: RootforgeMenu = hub.rootforge_menu
	check(forge.visible and paused,"Nema does not open her real service")
	var recipe: RecipeDefinition = forge.catalog.find_recipe(&"forest_stage_5_old_bark_helm")
	forge._select_recipe(recipe)
	check(forge.primary_action_button.disabled and forge.primary_action_button.text.contains("SEAL"),"Sealed crafting lacks an accurate gate")
	await capture("nema_sealed.png")
	story.record_discovery(&"forest_core_gear_crafting")
	story.grant_key_item(&"forest_core_gear_seal")
	check(forge.primary_action_button.disabled and not forge.primary_action_button.text.contains("ALREADY OWNED"),"No-save review falsely marks unowned recipes as owned")
	for ingredient: MaterialStackDefinition in recipe.ingredients:
		root.get_node("MaterialInventory").add_material(ingredient.material.material_id,ingredient.quantity+2)
	check(forge.primary_action_button.disabled,"Crafting ignores missing gold")
	session.update_progression(session.total_experience,recipe.gold_cost+50)
	check(not forge.primary_action_button.disabled,"Currency change does not refresh craft readiness")
	check(forge.output_icon.texture == GEAR.find_item(recipe.output_id).icon and forge.output_stats_label.text == GEAR.find_item(recipe.output_id).get_stat_summary(),"Nema preview disagrees with actual crafted gear")
	await capture("nema_ready.png")
	await reveal_and_click(forge.primary_action_button)
	check(root.get_node("GearInventory").owns_item(recipe.output_id) and session.coins == 50,"Real crafting button fails exact output/gold transaction")
	for ingredient: MaterialStackDefinition in recipe.ingredients:
		check(root.get_node("MaterialInventory").get_quantity(ingredient.material.material_id) == 2,"Nema spends ingredients incorrectly")
	check(forge.primary_action_button.disabled and forge.milestone_label.text.contains("CRAFT"),"Crafting has no completed result/duplicate guard")
	await capture("nema_crafted.png")
	check(save.is_autosave_suppressed_for_debug() and FileAccess.get_md5(PROFILE) == profile_before,"Review audit unexpectedly wrote crafting to its fixture")
	await key(KEY_ESCAPE)
	check(not paused,"Closing Nema leaves gameplay paused")
	for item: EquipmentDefinition in GEAR.items:
		if item.slot == EquipmentDefinition.Slot.WEAPON:
			root.get_node("WeaponInventory").acquire_weapon(item)
		elif not root.get_node("GearInventory").owns_item(item.item_id):
			root.get_node("GearInventory").acquire_item(item)
	for material: MaterialDefinition in MATERIALS.materials:
		root.get_node("MaterialInventory").add_material(material.material_id,30)
	await click(hud.character_menu_button.get_global_rect().get_center())
	var menu: CharacterMenu = hub.character_menu
	check(not menu.consumables_filter_button.visible and not menu.key_filter_button.visible,"Unimplemented bag categories are offered as working filters")
	check(menu.visible and paused,"HUD bag button does not open the inventory")
	await process_frame
	var portrait: Control = menu.portrait_aura.get_parent().get_parent()
	var body: AnimatedSprite2D = portrait.get_node("PortraitCanvas/Body")
	check(is_equal_approx(body.position.x,portrait.get_node("PortraitCanvas").size.x/2) and is_equal_approx(portrait.position.x+portrait.size.x/2,portrait.get_parent().size.x/2),"King or his paperdoll field is not horizontally centered")
	for row in 5:
		var left: Control = menu._equipment_slot_cards[[0,2,3,4,5][row]]
		var right: Control = menu._equipment_slot_cards[[1,6,7,8,9][row]]
		check(left.size == right.size and is_equal_approx(left.position.y,right.position.y) and is_equal_approx(left.position.x,menu.equipment_slots.size.x-right.position.x-right.size.x),"Paperdoll row %d is unbalanced" % row)
		check(not portrait.get_global_rect().intersects(left.get_global_rect()) and not portrait.get_global_rect().intersects(right.get_global_rect()),"Paperdoll row %d covers King" % row)
	check(menu.get_node("Panel").get_theme_stylebox("panel").texture.resource_path.ends_with("centered_paperdoll_frame.png"),"Sanctuary overwrites the chosen A frame")
	check(Rect2(Vector2.ZERO,Vector2(960,540)).encloses(menu.get_node("Panel").get_global_rect()),"Bag exceeds native viewport")
	check(menu.bag_footer.text.contains("15 material types") and menu.bag_footer.text.contains("7 equipment"),"Bag merges material pouch with equipment counts")
	check(menu._selectable_inventory_slots.size() == 22 and menu.bag_capacity_label.text == "SHOWING 22","Combined bag loses owned items")
	check(menu.bag_scroll.get_global_rect().encloses(menu._inventory_slots[0].get_global_rect()),"First bag row is clipped")
	check(menu.bag_scroll.get_global_rect().encloses(menu._selectable_inventory_slots[-1].get_global_rect()),"Last visible material row is clipped")
	menu._selectable_inventory_slots[0].grab_focus()
	await key(KEY_DOWN)
	check(root.gui_get_focus_owner() == menu._selectable_inventory_slots[12],"Bag arrows disagree with the visible rows")
	await click(menu.sort_button.get_global_rect().get_center())
	check(menu._inventory_sort_mode == &"name" and menu._selectable_inventory_slots.size() == 22,"Sorting loses items or no longer cycles")
	await capture("bag_all.png")
	await click(menu.materials_filter_button.get_global_rect().get_center())
	check(menu._material_cards.size() == 15 and menu._equipment_cards.is_empty(),"Material filter leaks equipment")
	await click(menu._material_cards[0].get_global_rect().get_center())
	check(menu.equipment_detail_panel.current_material_definition != null,"Material inspection did not prepare equipment-slot click proof")
	await click(menu._equipment_slot_cards[CharacterMenu.WEAPON_ESSENCE_SLOT_INDEX].get_global_rect().get_center())
	check(menu.equipment_detail_panel.current_definition == actor.get_equipped_weapon_item() and menu.equipment_detail_panel.equip_button.disabled,"Clicking an equipped paperdoll item does not inspect its real equipped state")
	await click(menu.bag_search.get_global_rect().get_center())
	menu.bag_search.text = "VaRkUuN"
	menu.bag_search.text_changed.emit(menu.bag_search.text)
	await process_frame
	check(menu._material_cards.size() == 1 and menu._material_cards[0].material_definition.material_id == &"forest_varkuun_core","Search is not case-insensitive or misses owned materials")
	check(root.gui_get_focus_owner() == menu.bag_search,"Rebuilding search steals typing focus")
	await capture("bag_search.png")
	menu.bag_search.text = "not-an-owned-item"
	menu.bag_search.text_changed.emit(menu.bag_search.text)
	await process_frame
	check(menu._selectable_inventory_slots.is_empty() and menu.bag_empty_label.visible and not menu.equipment_detail_panel.equip_button.visible,"Empty search leaves unrelated equipment actionable")
	await capture("bag_empty_search.png")
	menu.bag_search.text = ""
	menu.bag_search.text_changed.emit("")
	await click(menu.equipment_filter_button.get_global_rect().get_center())
	var helm: InventorySlotButton
	for button: InventorySlotButton in menu._equipment_cards:
		if button.equipment_definition.item_id == recipe.output_id: helm = button
	await click(helm.get_global_rect().get_center())
	check(menu.equipment_detail_panel.current_definition.item_id == recipe.output_id and not menu.equipment_detail_panel.equip_button.disabled,"Crafted gear cannot be inspected/equipped from the bag")
	await click(menu.equipment_detail_panel.equip_button.get_global_rect().get_center())
	check(actor.get_equipped_gear(EquipmentDefinition.Slot.HEAD).item_id == recipe.output_id,"Real bag equip does not apply crafted gear")
	await capture("bag_equipped.png")
	await key(KEY_ESCAPE)
	check(not menu.visible and not paused,"Bag Esc does not resume gameplay")
	story.remember_story(&"forest_stage_5_cleared")
	session.update_progression(4950,50)
	check(hud.experience_label.text == "MAX LEVEL" and actor.progression_component.level == 10,"Maximum level is confused with a stage cap")
	check(save.is_autosave_suppressed_for_debug(),"Review no-save boundary was lost")
	hub.queue_free()
	current_scene = null
	await process_frame
	save.delete_profile()
	save.reset_storage_path_after_testing()
	print("PLAYER_INTERFACE_READABILITY: ",checks," checks, ",failures," failures")
	quit(1 if failures else 0)

func reveal_and_click(control: Control) -> void:
	var scroll := control.find_parent("BodyScroll") as ScrollContainer
	if scroll != null: scroll.scroll_vertical = int(scroll.get_v_scroll_bar().max_value)
	await process_frame
	await click(control.get_global_rect().get_center())

func click(point: Vector2) -> void:
	var event := InputEventMouseButton.new()
	event.position = point
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	root.push_input(event)
	event = event.duplicate()
	event.pressed = false
	root.push_input(event)
	await process_frame
	await process_frame

func key(code: Key) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = true
	root.push_input(event)
	event = event.duplicate()
	event.pressed = false
	root.push_input(event)
	await process_frame
	await process_frame

func capture(file: String) -> void:
	if DisplayServer.get_name() == "headless": return
	await process_frame
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(EVIDENCE)
	check(root.get_texture().get_image().save_png(EVIDENCE+file) == OK,"Capture failed")

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
