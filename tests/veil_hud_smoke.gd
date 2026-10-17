extends SceneTree

const HUB = preload("res://levels/sanctuary/sanctuary.tscn")
const OUT := "res://tmp/review/ui/mastery_ribbon_2026_10_17/"
var checks := 0
var failures := 0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	root.size = Vector2i(960,540)
	var save := root.get_node("SaveService")
	check(save.configure_storage_path_for_testing("user://veil_hud_smoke.json"),"Cannot isolate HUD fixture")
	save.delete_profile()
	root.get_node("RunSession").reset_run()
	root.get_node("WeaponInventory").reset_inventory()
	root.get_node("GearInventory").reset_inventory()
	root.get_node("StoryState").reset_story()
	var hub := HUB.instantiate()
	root.add_child(hub)
	current_scene = hub
	await settle()
	var actor: Player = hub.player
	actor.vitality_component.set_physics_process(false)
	var hud: CombatHUD = hub.combat_hud
	var presenter := hud.status_presenter
	var tray := hud.get_node("ActionTray") as Control
	var before: PackedStringArray = actor.get_node("KingSkillLibrary").current_ids()
	check(presenter.frame.get_node("LevelBadge").get_global_rect().encloses(hud.level_label.get_global_rect()),"Initial level digits escape their plaque")
	check(presenter.frame.get_node("KingPortrait").get_global_rect().end.x < hud.health_bar.get_global_rect().position.x,"Portrait must precede HP on the left")
	check(presenter.frame.get_global_rect().encloses(presenter.mastery_button.get_global_rect()),"Mastery escapes the status card")
	check(not presenter.frame.has_node("AttackReadout") and not presenter.frame.has_node("EquippedWeaponReadout"),"Rejected name/stat chips remain")
	check(tray.size.x <= 300 and tray.size.y <= 80,"Initial dock exceeds the compact budget")
	check(is_equal_approx(tray.get_global_rect().end.y,hud.size.y-2),"Dock must have two pixels of bottom clearance")
	check(hud.character_menu_button.get_global_rect().end.x < hud.options_button.get_global_rect().position.x,"Bottom-right controls overlap")
	check(not tray.get_global_rect().intersects(hud.character_menu_button.get_global_rect()),"Dock covers Bag")
	check(not hud.has_node("CompactSanctuaryFrame"),"Sanctuary restores the obsolete wide HUD frame")
	check(hud.character_menu_button.position.y >= hud.size.y-48,"Bag is not at the bottom-right")
	check(hud.get_node("%HealthBar") == hud.health_bar and hud.get_node("%ExperienceBar") == hud.experience_bar,"Composition loses unique scene controls")
	for slot in hud._skill_slots:
		check(slot.visible == slot.slot_definition.is_equipped(),"Empty or locked slot reserves visible space")
		if slot.visible:
			check(slot.size == Vector2(40,40),"Round slot has unexpected minimum size")
			check(slot.activation_button.get_global_rect().size == slot.size,"Mouse target does not fill the medallion")
	check(tray.get_theme_stylebox("panel") is StyleBoxEmpty,"Plain rectangular dock background returned")
	check(presenter.frame.get_node("VitalityFrame").get_theme_stylebox("panel") is StyleBoxTexture,"HP lost its illustrated frame")
	check(hud.health_bar.get_global_rect().position.x == presenter.mastery_inlay.get_global_rect().position.x and hud.health_bar.size.x == presenter.mastery_inlay.size.x,"HP and mastery inlay endpoints differ")
	check(not presenter.mastery_button.has_node("MasteryProgress") and not presenter.mastery_button.has_node("MasteryRank") and presenter.mastery_button.get_node("MasteryState").text == "SEALED","Inactive mastery looks like missing XP/rank")
	check(not presenter.effect_strip.visible,"Inactive effects leave an empty row")
	check(hud.options_button.get_node("ActionFace").texture != null and hud.options_button.get_node("Keycap").text == "ESC","Settings lost its illustrated gear/keycap")
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		var rendered_hp := root.get_texture().get_image()
		var health_origin := hud.health_bar.get_global_rect().position
		var corner := rendered_hp.get_pixelv(Vector2i(health_origin))
		var center := rendered_hp.get_pixelv(Vector2i(health_origin+Vector2(10,5)))
		var lower_lip := rendered_hp.get_pixelv(Vector2i(health_origin+Vector2(80,13)))
		check(center.r > center.b*2,"HP clipping hides the live red fill")
		check(corner.r < corner.b*2,"Square HP corner paints over the angled opening")
		check(lower_lip.r < lower_lip.b*2,"HP fill paints over the illustrated lower lip")
	await capture("hud_normal.png")
	actor.progression_component.grant_rewards(50,0)
	actor.health_component.set_current_health(105)
	await create_timer(.9,false).timeout
	check(hud.experience_bar.value == 50 and hud.experience_bar.max_value == 150 and hud.health_bar.value == 105,"Illustrated rails disagree with actual partial HP/XP")
	await capture("hud_progress.png")
	actor.health_component.set_current_health(140)
	root.get_node("RunSession").update_progression(0,0)
	actor.apply_debug_testing_preset()
	await settle()
	check(presenter.frame.get_node("LevelBadge").get_global_rect().encloses(hud.level_label.get_global_rect()),"Lv10 digits retain the old LEVEL placeholder width")
	for item: EquipmentDefinition in actor.weapon_catalog.weapons:
		root.get_node("WeaponInventory").acquire_weapon(item)
		check(actor.equip_owned_weapon(item),"Could not equip "+item.display_name)
		await settle()
		check(presenter._mastery_tip().title == actor.attack_component.weapon.family_display_name+" Mastery","Mastery family is stale after swapping")
		check(presenter.mastery_icon.texture == presenter.VeilStyle.FAMILY_ICONS.get(actor.attack_component.weapon.family_display_name),"Family icon is stale after swapping")
		var mastery_tip: Dictionary = presenter._mastery_tip()
		var clear_status: bool = mastery_tip.body.contains("Visit Veyr") if actor.attack_component.weapon.family_display_name == "Axe" else mastery_tip.body.contains("not yet available")
		check(clear_status and not str(mastery_tip).to_lower().contains("mana"),"Mastery availability is unclear or rejected resource copy returned")
	var slot := hud.get_skill_slot(1)
	var tip: Dictionary = slot._tooltip_readout()
	check(tip.title == slot.ability_component.definition.display_name and tip.footer.contains("%.1fs" % slot.ability_component.definition.cooldown_seconds),"Skill hover card ignores current definition")
	check(tip.facts.contains("%.1f" % slot.ability_component.definition.resolve_damage(actor.attack_component.weapon.damage)),"Skill damage facts use stale weapon values")
	slot.activation_button.grab_focus()
	await settle()
	var focus_card: Control = slot.activation_button._focus_card
	check(is_instance_valid(focus_card) and focus_card.mouse_filter == Control.MOUSE_FILTER_IGNORE,"Focus card blocks gameplay or is missing")
	check(focus_card.get_parent() is CanvasLayer,"Focus card follows the world camera instead of the screen")
	check(Rect2(Vector2.ZERO,hud.size).encloses(focus_card.get_global_rect()),"Skill card escapes viewport")
	check(focus_card.get_global_rect().end.y < tray.get_global_rect().position.y,"Bottom skill card covers its source")
	await capture("skill_description.png")
	slot.activation_button.release_focus()
	await settle()
	check(not is_instance_valid(slot.activation_button._focus_card),"Focus card remains after dismissal")
	slot.activation_button.grab_focus()
	var space := InputEventKey.new()
	space.keycode = KEY_SPACE
	space.physical_keycode = KEY_SPACE
	space.pressed = true
	Input.parse_input_event(space)
	await physics_frame
	await process_frame
	space = space.duplicate()
	space.pressed = false
	Input.parse_input_event(space)
	check(actor.evade_component.is_dashing() and not slot.ability_component.is_casting(),"Focused skill Space: dashing=%s casting=%s focus=%s paused=%s" % [actor.evade_component.is_dashing(),slot.ability_component.is_casting(),slot.activation_button.has_focus(),paused])
	actor.evade_component.cancel_evade()
	await settle()
	if DisplayServer.get_name() != "headless":
		var motion := InputEventMouseMotion.new()
		motion.position = slot.activation_button.get_global_rect().get_center()
		root.push_input(motion)
		await create_timer(.8).timeout
		var cards := root.find_children("VeilHoverCard","PanelContainer",true,false)
		check(not cards.is_empty(),"Real delayed mouse hover does not open a themed card")
		await capture("mouse_hover.png")
		motion.position = Vector2(480,270)
		root.push_input(motion)
		await settle()
		check(root.find_children("VeilHoverCard","PanelContainer",true,false).is_empty(),"Mouse tooltip remains after leaving the skill")
	# Live shield state and generic capacity use the same icon/hover path.
	var vow := actor.get_node("UnbrokenVowComponent") as UnbrokenVowComponent
	vow.apply_rank(UnbrokenVowDefinition.Rank.FOUNDATION)
	check(actor.request_ability(4),"Vow cannot start after HUD input")
	await create_timer(.4,false,true).timeout
	var effects: Control = presenter.effect_strip
	var vow_button: Button = effects.get_effect_button(&"vow")
	check(is_instance_valid(vow_button) and effects.visible,"Active Vow has no status icon")
	check(vow_button.content_provider.call().body.contains("+12%") and vow_button.content_provider.call().body.contains(str(ceili(actor.health_component.shield_health))),"Vow hover disagrees with actual shield/damage")
	vow_button.grab_focus()
	await settle()
	var shield_before := actor.health_component.shield_health
	check(actor.health_component.apply_damage(DamageInfo.new(1,actor,Vector2.RIGHT)),"Shield-only hit rejected")
	await settle()
	check(actor.health_component.shield_health < shield_before and vow_button._focus_card.get_node("Fields/body").text.contains("Shield: %d /" % ceili(actor.health_component.shield_health)),"Open effect hover keeps stale shield strength")
	await capture("vow_hover.png")
	vow_button.release_focus()
	if DisplayServer.get_name() != "headless":
		var motion := InputEventMouseMotion.new()
		motion.position = vow_button.get_global_rect().get_center()
		root.push_input(motion)
		await create_timer(.8).timeout
		var mouse_cards := root.find_children("VeilHoverCard","PanelContainer",true,false)
		check(mouse_cards.size() == 1 and mouse_cards[0].get_node("Fields/title").text == "Unbroken Vow","Actual status mouse hover is missing")
		actor.health_component.apply_damage(DamageInfo.new(1,actor,Vector2.RIGHT))
		await settle()
		check(mouse_cards[0].get_node("Fields/body").text.contains("Shield: %d /" % ceili(actor.health_component.shield_health)),"Mouse hover keeps stale effect values")
		await capture("vow_mouse_hover.png")
		motion.position = Vector2(480,270)
		root.push_input(motion)
		await settle()
	for index in 11:
		effects.set_effect(StringName("fixture_%d" % index),{"icon":vow_button.icon,"counter":str(index+1),"harmful":index >= 6,"card":{"title":"Review effect %d" % index,"body":"Presentation capacity fixture only; no gameplay effect."}})
	await settle()
	var effect_buttons := effects.get_children()
	check(effect_buttons.size() == 12 and effects.size.y == 48,"Twelve effects do not fit in two rows")
	for button: Control in effect_buttons:
		check(effects.get_global_rect().encloses(button.get_global_rect()) and presenter.frame.get_global_rect().encloses(button.get_global_rect()),"Wrapped effect is clipped or escapes status bounds")
		for other: Control in effect_buttons:
			if other != button: check(not button.get_global_rect().intersects(other.get_global_rect()),"Wrapped status icons overlap")
	check(not effects.get_global_rect().intersects(hud.coin_label.get_global_rect()),"Effects overlap currency")
	await capture("twelve_effects.png")
	effects.remove_effect(&"fixture_10")
	var root_source := Node.new()
	root.add_child(root_source)
	check(actor.try_begin_root_restraint(root_source,3),"Root fixture cannot restrain")
	var root_button: Button = effects.get_effect_button(&"root")
	check(is_instance_valid(root_button) and root_button.get_node("Counter").text == "3","Root has no escape counter")
	check(root_button.content_provider.call().footer.contains("not seconds"),"Root escape count is labeled as time")
	actor.request_evade(Vector2.DOWN)
	check(root_button.get_node("Counter").text == "2","Escape progress leaves stale status count")
	actor.release_root_restraint(root_source,true)
	check(effects.get_effect_button(&"root") == null,"Ended root leaves a status icon")
	root_source.queue_free()
	for index in 11: effects.remove_effect(StringName("fixture_%d" % index))
	vow.clear_buff()
	await settle()
	check(not effects.visible and effects.size.y == 0 and presenter.frame.size.y == 89,"Expired effects leave empty slots or reserved height")
	var stun_hit := DamageInfo.new(1,actor,Vector2.RIGHT)
	stun_hit.stun_seconds = .25
	check(actor.health_component.apply_damage(stun_hit),"Real incoming stun rejected")
	check(effects.get_effect_button(&"control") != null and effects.get_effect_button(&"control").content_provider.call().title == "Stunned","Accepted stun lacks a control icon")
	await create_timer(.4,false,true).timeout
	check(effects.get_effect_button(&"control") == null,"Recovered stun leaves a control icon")
	# A sparse loadout must resize, preserving its keys and authored saved model.
	var original := actor.skill_loadout
	var sparse := original.duplicate(true) as SkillLoadoutDefinition
	for definition in sparse.slots:
		if definition.slot_number != 1: definition.ability = null
	actor.skill_loadout = sparse
	actor.skill_loadout_changed.emit()
	await settle()
	check(tray.size.x == 220,"Sparse dock does not collapse to its numeric-XP minimum")
	check(hud.get_skill_slot(1).visible and not hud.get_skill_slot(2).visible,"Sparse dock invents placeholders")
	await capture("sparse_loadout.png")
	# Existing 9/0 identities remain present if a legacy loadout equips them.
	sparse.get_slot(10).ability = original.get_slot(1).ability
	actor.skill_loadout_changed.emit()
	await settle()
	check(hud.get_skill_slot(10).visible and hud.get_skill_slot(10).key_label.text == "0","Legacy equipped slot 0 was silently discarded")
	actor.skill_loadout = original
	actor.skill_loadout_changed.emit()
	await settle()
	presenter.mastery_button.grab_focus()
	await settle()
	check(Rect2(Vector2.ZERO,hud.size).encloses(presenter.mastery_button._focus_card.get_global_rect()),"Top-left mastery card escapes viewport")
	await capture("mastery_description.png")
	presenter.mastery_button.release_focus()
	await settle()
	if DisplayServer.get_name() != "headless":
		var motion := InputEventMouseMotion.new()
		motion.position = presenter.mastery_button.get_global_rect().get_center()
		root.push_input(motion)
		await create_timer(.8).timeout
		var mouse_cards := root.find_children("VeilHoverCard","PanelContainer",true,false)
		check(mouse_cards.size() == 1 and mouse_cards[0].get_node("Fields/title").text == presenter._mastery_tip().title,"Actual mastery mouse hover is missing or shows stale family")
		await capture("mastery_mouse_hover.png")
		motion.position = Vector2(480,270)
		root.push_input(motion)
		await settle()
	# A physical UI click must not leak into held primary attack.
	var phase := actor.attack_component.phase
	hud.get_skill_slot(1).activation_button.grab_focus()
	await click(hud.character_menu_button.get_global_rect().get_center())
	check(hub.character_menu.visible and paused,"Physical Bag click no longer opens inventory")
	check(not is_instance_valid(hud.get_skill_slot(1).activation_button._focus_card),"Focus card draws over a paused modal")
	check(actor.attack_component.phase == phase,"HUD mouse click leaked into normal attack")
	hub.character_menu.close_menu()
	await settle()
	root.size = Vector2i(1280,720)
	await settle()
	check(is_equal_approx(tray.get_global_rect().end.y,hud.size.y-2),"Resizing loses bottom anchoring")
	check(not tray.get_global_rect().intersects(hud.character_menu_button.get_global_rect()),"Wide viewport overlaps menu buttons")
	check(PackedStringArray(actor.get_node("KingSkillLibrary").current_ids()) == before,"HUD rewrites saved skill identities")
	await capture("hud_wide.png")
	hub.queue_free()
	current_scene = null
	await process_frame
	save.delete_profile()
	save.reset_storage_path_after_testing()
	print("VEIL_HUD: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)

func settle() -> void:
	for frame in 4: await process_frame

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

func capture(file: String) -> void:
	if DisplayServer.get_name() == "headless": return
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(OUT)
	check(root.get_texture().get_image().save_png(OUT+file) == OK,"Screenshot failed")

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
