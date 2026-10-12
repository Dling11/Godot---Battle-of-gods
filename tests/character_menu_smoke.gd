extends SceneTree

const PlayerScene = preload("res://entities/player/player.tscn")
const CharacterMenuScene = preload("res://ui/character_menu.tscn")
const HudScene = preload("res://ui/combat_hud.tscn")
const KingFrames = preload("res://assets/characters/playable/king/shared_bodies/sword/frames.tres")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	root.get_node("RunSession").reset_run()
	root.get_node("WeaponInventory").reset_inventory()
	root.get_node("GearInventory").reset_inventory()
	root.get_node("MaterialInventory").reset_inventory()
	for action_name in ["player_skill_1", "player_skill_2", "player_skill_3", "player_skill_4", "player_character_menu"]:
		if not InputMap.has_action(action_name):
			_fail("Missing input action: %s" % action_name)
			return
	var has_tab_binding := false
	for input_event: InputEvent in InputMap.action_get_events("player_character_menu"):
		if input_event is InputEventKey and input_event.physical_keycode == KEY_TAB:
			has_tab_binding = true
			break
	if not has_tab_binding:
		_fail("Character-menu action is not physically bound to Tab.")
		return

	var player := PlayerScene.instantiate() as Player
	root.add_child(player)
	player.set_physics_process(false)
	var menu := CharacterMenuScene.instantiate() as CharacterMenu
	menu.player = player
	root.add_child(menu)
	await process_frame

	if menu.visible:
		_fail("Character menu should begin hidden.")
		return
	var physical_tab_event := InputEventKey.new()
	physical_tab_event.physical_keycode = KEY_TAB
	physical_tab_event.pressed = true
	Input.parse_input_event(physical_tab_event)
	await process_frame
	physical_tab_event.pressed = false
	Input.parse_input_event(physical_tab_event)
	if not menu.visible or not paused:
		_fail("The live physical Tab event did not open the character menu and pause gameplay.")
		return
	if menu._equipment_cards.size() != 1 or root.gui_get_focus_owner() != menu._equipment_cards[0]:
		_fail("Character menu did not build and focus King's signature sword in the combined page.")
		return
	var identity_title: Label = menu.get_node("Panel/Margin/Root/Header/Identity/Title")
	if identity_title.text != "KING":
		_fail("Character menu does not present the active King combat proof.")
		return
	if menu.vitality_label.text != "HP 140/140":
		_fail("Character menu does not present King's current level-scaled vitality.")
		return
	var preview_body := menu.get_node(
		"Panel/Margin/Root/PageHost/GearPage/LoadoutRow/PaperDollPanel/"
		+ "PaperDollMargin/PaperDollRoot/EquipmentLayout/Portrait/PortraitCanvas/Body"
	) as AnimatedSprite2D
	if preview_body.sprite_frames != KingFrames or preview_body.position != Vector2(76, 101) or preview_body.scale != Vector2(2, 2):
		_fail("Character menu preview is not using King's body-centered active model.")
		return
	var preview_grip := menu.get_node(
		"Panel/Margin/Root/PageHost/GearPage/LoadoutRow/PaperDollPanel/"
		+ "PaperDollMargin/PaperDollRoot/EquipmentLayout/Portrait/PortraitCanvas/WeaponGrip"
	) as Node2D
	if preview_grip.visible:
		_fail("Character preview duplicates a detached equipment sword over King's integrated sword.")
		return
	if (
		menu._equipment_slot_cards.size() != 10
		or not menu.gear_page.visible
		or menu.skills_page.visible
	):
		_fail("Character menu did not open on the compact ten-position Character & Bag page.")
		return
	var expected_slots := [
		"HEAD",
		"WEAPON ESSENCE",
		"PLATE",
		"GLOVES",
		"LEGGINGS",
		"BOOTS",
		"BRACER",
		"AMULET",
		"RING",
		"TALISMAN",
	]
	for index in expected_slots.size():
		if menu._equipment_slot_cards[index].slot_label.text != expected_slots[index]:
			_fail("Character menu equipment slot %d did not match the finalized model." % index)
			return
	if (
		menu._equipment_slot_cards[0].position.x >= menu.equipment_slots.size.x / 2
		or menu._equipment_slot_cards[CharacterMenu.WEAPON_ESSENCE_SLOT_INDEX].position.x
		<= menu.equipment_slots.size.x / 2
	):
		_fail("Head and Weapon Essence did not flank the centered paperdoll.")
		return
	if (
		menu._equipment_slot_cards[CharacterMenu.WEAPON_ESSENCE_SLOT_INDEX].item_label.text
		!= "KING'S SWORD"
	):
		_fail("King's current weapon did not occupy the Weapon Essence migration slot.")
		return
	if (
		menu._inventory_slots.size() != CharacterMenu.BAG_CAPACITY
		or menu.inventory_grid.columns != CharacterMenu.BAG_COLUMNS
		or menu.bag_capacity_label.text != "SHOWING 1"
		or menu._inventory_slots[0].custom_minimum_size != Vector2(38, 38)
	):
		_fail("Character menu did not build the compact 24-slot bag contract.")
		return
	if player.weapon_catalog == null or not player.weapon_catalog.has_valid_layout():
		_fail("Player does not expose a valid authored weapon catalog.")
		return
	if menu.equipment_detail_panel.current_definition != player.get_equipped_weapon_item():
		_fail("Character menu did not initially inspect the equipped weapon.")
		return
	if (
		(menu.get_node("Panel") as Control).size != Vector2(840, 490)
		or menu.equipment_detail_panel.custom_minimum_size != Vector2(280, 232)
	):
		_fail("Character & Bag did not adopt the approved compact modal and detail dimensions.")
		return
	if menu.skills_tab_button.get_node_or_null(menu.skills_tab_button.focus_neighbor_bottom) != menu._equipment_cards[0]:
		_fail("Both tabs must lead into the visible Character & Bag inventory.")
		return
	await process_frame
	var gear_panel := menu.get_node(
		"Panel/Margin/Root/PageHost/GearPage/LoadoutRow/PaperDollPanel"
	) as Control
	var gear_panel_rect := gear_panel.get_global_rect()
	for card_index in menu._equipment_slot_cards.size():
		var slot_card: Control = menu._equipment_slot_cards[card_index]
		if not gear_panel_rect.encloses(slot_card.get_global_rect()):
			_fail("Equipment slot %d overflowed the finalized Gear panel." % card_index)
			return
		for other_index in range(card_index + 1, menu._equipment_slot_cards.size()):
			if slot_card.get_global_rect().intersects(
				menu._equipment_slot_cards[other_index].get_global_rect()
			):
				_fail("Finalized equipment slots %d and %d overlap." % [card_index, other_index])
				return
	menu._equipment_cards[0].pressed.emit()
	if (
		menu.equipment_detail_panel.current_definition == null
		or menu.equipment_detail_panel.current_definition.item_id != &"weapon_king_signature_sword"
		or not menu.equipment_detail_panel.state_label.text.contains("ACTIVE EFFECTS")
	):
		_fail("Selecting King's Sword did not update the active equipment detail surface.")
		return
	if not root.get_node("MaterialInventory").add_material(&"forest_mire_resin", 3):
		_fail("Could not seed a real saved material quantity for Character & Bag validation.")
		return
	if menu._material_cards.size() != 1 or menu._inventory_slots.size() != CharacterMenu.BAG_CAPACITY:
		_fail("Owned materials did not appear in the shared bag presentation.")
		return
	menu.materials_filter_button.pressed.emit()
	if (
		menu._equipment_cards.size() != 0
		or menu._material_cards.size() != 1
		or menu.bag_capacity_label.text != "SHOWING 1"
	):
		_fail("Materials filter did not isolate the capacity-free material pouch.")
		return
	menu._material_cards[0].pressed.emit()
	if (
		menu.equipment_detail_panel.current_material_definition == null
		or menu.equipment_detail_panel.current_material_definition.material_id != &"forest_mire_resin"
		or menu.equipment_detail_panel.equip_button.visible
	):
		_fail("Selecting a material did not open the read-only material detail view.")
		return
	await process_frame
	var viewport_rect := root.get_viewport().get_visible_rect()
	var panel_rect: Rect2 = (menu.get_node("Panel") as Control).get_global_rect()
	var page_host_rect: Rect2 = (menu.get_node("Panel/Margin/Root/PageHost") as Control).get_global_rect()
	if (
		not viewport_rect.encloses(panel_rect)
		or not page_host_rect.encloses(menu.gear_page.get_global_rect())
		or not page_host_rect.encloses(menu.equipment_detail_panel.get_global_rect())
	):
		_fail("Combined Character & Bag page overflowed its 960x540 modal bounds: viewport %s, panel %s, host %s, gear %s, detail %s." % [viewport_rect, panel_rect, page_host_rect, menu.gear_page.get_global_rect(), menu.equipment_detail_panel.get_global_rect()])
		return
	menu.all_filter_button.pressed.emit()
	menu.skills_tab_button.pressed.emit()
	if menu.gear_page.visible or not menu.skills_page.visible or root.gui_get_focus_owner() != menu._skill_cards[0]:
		_fail("Skills tab did not switch pages and focus the first reusable skill control.")
		return
	await process_frame
	if (
		menu.gear_tab_button.get_node_or_null(menu.gear_tab_button.focus_neighbor_bottom) != menu._skill_cards[0]
	):
		_fail("Character and Skills tabs must lead into the visible Skills page.")
		return
	if not menu.has_node("Panel/Margin/Root/PageHost/SkillsPage/Skills/Skill4") or not (menu._skill_cards[0] is SkillSlotCard):
		_fail("Character menu did not present all four authored reusable skill slots.")
		return
	if (
		menu._future_skill_cards.size() != 2
		or not menu.has_node("Panel/Margin/Root/PageHost/SkillsPage/FutureTiers/UltimateSlot")
		or not menu.has_node("Panel/Margin/Root/PageHost/SkillsPage/FutureTiers/RealityBreakingSlot")
		or not menu._future_skill_cards[0].disabled
		or not menu._future_skill_cards[1].disabled
		or not menu._future_skill_cards[0].text.contains("ULTIMATE")
		or not menu._future_skill_cards[1].text.contains("REALITY BREAKING")
	):
		_fail("Character menu lost the locked Ultimate and Reality Breaking future-tier previews.")
		return
	var skill_host := menu.get_node("Panel/Margin/Root/PageHost") as Control
	var skill_host_rect: Rect2 = skill_host.get_global_rect()
	for card: SkillSlotCard in menu._skill_cards:
		if card.size.y > 72.0 or not skill_host_rect.encloses(card.get_global_rect()):
			_fail(
				"A compact Active Skills card overflowed the character-menu page "
				+ "(card=%s host=%s)." % [card.get_global_rect(), skill_host_rect]
			)
			return
	for card: SkillSlotCard in menu._future_skill_cards:
		if card.size.y > 72.0 or not skill_host_rect.encloses(card.get_global_rect()):
			_fail("A locked future-tier card overflowed the character-menu page.")
			return
	if player.skill_loadout == null or not player.skill_loadout.has_complete_layout():
		_fail("Player does not expose the shared four-slot loadout definition.")
		return
	if (
		player.skill_loadout.get_slot(1).ability == null
		or player.skill_loadout.get_slot(1).ability.ability_id != &"echoing_sever"
		or not menu._skill_cards[0].text.contains("EARTHSPLIT")
	):
		_fail("King's Earthsplitter is not presented as equipped Skill 1.")
		return
	var f9_event := InputEventAction.new()
	f9_event.action = "debug_max_progression"
	f9_event.pressed = true
	player._unhandled_input(f9_event)
	await process_frame
	var material_inventory := root.get_node("MaterialInventory")
	for material: MaterialDefinition in MaterialInventory.MaterialCatalog.materials:
		if (
			material_inventory.get_quantity(material.material_id)
			!= material_inventory.DEBUG_TEST_MATERIAL_QUANTITY
		):
			_fail("F9 did not grant every authored material its reward-safe testing stockpile.")
			return
	if (
		player.skill_loadout.get_slot(2).ability == null
		or player.skill_loadout.get_slot(2).ability.ability_id != &"riftbreak"
		or menu._skill_cards[1].slot_definition.ability == null
		or not menu._skill_cards[1].text.contains("CRASH")
		or menu._equipment_cards.size() != player.weapon_catalog.weapons.size() + 5
		or menu._material_cards.size() != MaterialInventory.MaterialCatalog.materials.size()
		or menu._material_cards[0].quantity_label.text != "MAX"
		or menu.vitality_label.text != "HP 248/248"
	):
		_fail("F9 did not preserve King's current skills while refreshing gear, materials, and Level-10 vitality.")
		return
	menu.gear_tab_button.pressed.emit()
	var gloves: EquipmentDefinition
	for card: InventorySlotButton in menu._equipment_cards:
		if card.equipment_definition.slot == EquipmentDefinition.Slot.GLOVES:
			gloves = card.equipment_definition
			break
	if gloves == null:
		_fail("F9 did not grant the Stage V gloves for equipment testing.")
		return
	var glove_card: InventorySlotButton
	for card: InventorySlotButton in menu._equipment_cards:
		if card.equipment_definition == gloves:
			glove_card = card
			break
	var drag_grab_position := Vector2(17, 13)
	var drag_preview := glove_card._create_drag_preview(drag_grab_position)
	if drag_preview.position != -drag_grab_position or drag_preview.size != Vector2(48, 48):
		_fail("The equipment drag preview does not remain attached to the mouse grab point.")
		return
	drag_preview.free()
	var glove_drop := {"equipment": gloves}
	var glove_slot: EquipmentSlotCard = menu._equipment_slot_cards[3]
	if not glove_slot._can_drop_data(Vector2.ZERO, glove_drop):
		_fail("The Gloves loadout card rejected matching drag data.")
		return
	glove_slot._drop_data(Vector2.ZERO, glove_drop)
	for card: InventorySlotButton in menu._equipment_cards.duplicate():
		var item := card.equipment_definition
		if item != null and item.slot not in [EquipmentDefinition.Slot.WEAPON, EquipmentDefinition.Slot.GLOVES]:
			menu._on_equipment_equip_requested(item)
	if (
		not is_equal_approx(player.health_component.maximum_health, 388.0)
		or not is_equal_approx(player.health_component.armor_rating, 30.0)
		or not is_equal_approx(player.health_component.ward_reduction_ratio, 0.0)
		or not is_equal_approx(player.health_regeneration_component.flat_regeneration_bonus, 2.0)
		or not is_equal_approx(player.attack_component._attack_speed_bonus_ratio, 0.15)
		or not is_equal_approx(player.movement_component.max_speed, 126.5)
	):
		_fail("Equipping the complete Stage V armor set did not apply its real reusable stats.")
		return
	menu.sort_button.pressed.emit()
	if menu.sort_button.text != "SORT: NAME":
		_fail("The inventory sort control did not cycle from slot order to name order.")
		return
	if menu._skill_cards[0].get_node_or_null(menu._skill_cards[0].focus_neighbor_right) != menu._skill_cards[1]:
		_fail("Character skill cards do not provide explicit directional focus navigation.")
		return
	var tab_action_event := InputEventAction.new()
	tab_action_event.action = "player_character_menu"
	tab_action_event.pressed = true
	menu._input(tab_action_event)
	if not menu.visible:
		_fail("Tab should open the menu; Esc or the close button should close it.")
		return
	var escape_event := InputEventAction.new()
	escape_event.action = "ui_cancel"
	escape_event.pressed = true
	menu._input(escape_event)
	if menu.visible or paused:
		_fail("Esc did not close the character menu and resume gameplay.")
		return
	menu.open_menu()
	menu._skill_cards[1].pressed.emit()
	if not menu.skill_detail_label.text.contains("SLOT 2"):
		_fail("Selecting a reusable skill card did not update the information surface.")
		return
	menu.close_button.pressed.emit()
	if menu.visible or paused:
		_fail("The mouse/keyboard close control did not close the character menu.")
		return

	var hud := HudScene.instantiate() as CombatHUD
	root.add_child(hud)
	hud.character_menu_requested.connect(menu.open_menu)
	hud.character_menu_button.pressed.emit()
	if not menu.visible or not paused:
		_fail("The visible HUD character/bag button did not open the menu.")
		return
	menu.close_menu()
	hud.free()

	player.progression_component.grant_rewards(20, 3)
	if menu.level_label.text != "LEVEL 10 / 10" or menu.coin_label.text != "1002 COINS":
		_fail("Character menu did not react to progression changes.")
		return

	print("Character menu smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	paused = false
	push_error(message)
	quit(1)
