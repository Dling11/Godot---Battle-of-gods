extends "res://tools/launch_sanctuary_study.gd"

var checks := 0
var failures := 0

func _run() -> void:
	root.size = Vector2i(960,540)
	if not "--interface-demo" in OS.get_cmdline_user_args():
		push_error("Run with -- --interface-demo")
		quit(1)
		return
	await super._run()
	await process_frame
	var hub: Node = current_scene
	var study: Node = hub.get_node("SanctuaryTown")
	var row: Control = study._panel.get_child(0).get_node("InterfaceDemoControls")
	check(root.get_node("SaveService").is_autosave_suppressed_for_debug(),"Demo permits normal profile writes")
	check(hub.player.progression_component.total_experience == 100 and hub.player.progression_component.coins == 750,"Demo fixture did not apply")
	check(Rect2(Vector2.ZERO,Vector2(960,540)).encloses(row.get_global_rect()) and not row.get_global_rect().intersects(hub.combat_hud.status_presenter.frame.get_global_rect()) and not study.town_map.enabled and not study.town_map.mini.visible,"Demo controls cover the compact HUD or revive the withdrawn map")
	await click(button(row,"+75 XP"))
	check(hub.player.progression_component.level == 2 and hub.combat_hud.status_presenter.level_toast.visible and hub.combat_hud.experience_label.text == "XP 25 / 250" and hub.combat_hud.experience_bar.value == 25 and hub.combat_hud.experience_bar.max_value == 250,"XP preview fails actual level-up or carries the previous level's XP into the bar")
	for _hit in 4: await click(button(row,"Lose 35 HP"))
	check(hub.player.health_component.current_health == 12 and hub.combat_hud.status_presenter.health_state.text == "CRITICAL","Repeated demo damage cannot show critical health")
	await capture_demo("interface_demo_critical.png")
	await click(button(row,"Heal"))
	check(hub.player.health_component.current_health == hub.player.health_component.maximum_health and hub.combat_hud.status_presenter.health_state.text.is_empty(),"Demo heal leaves stale vitality")
	for _reward in 4: await click(button(row,"+75 XP"))
	check(hub.player.progression_component.level == 3 and hub.combat_hud.experience_label.text.begins_with("STAGE CAP"),"Demo bypasses the actual progression ceiling")
	await click(button(row,"Next stage cap"))
	check(hub.player.progression_component.get_current_level_cap() == 4 and hub.combat_hud.experience_label.text == "XP 0 / 350" and hub.combat_hud.experience_label.tooltip_text.contains("350 to Lv.4"),"Demo stage control does not unlock the real next gate")
	await capture_demo("interface_demo_growth.png")
	await create_timer(.5,false,true).timeout
	var event := InputEventKey.new()
	event.keycode = KEY_F
	event.physical_keycode = KEY_F
	event.pressed = true
	root.push_input(event)
	event = event.duplicate()
	event.pressed = false
	root.push_input(event)
	await process_frame
	check(hub.dialogue_panel.visible,"Demo does not start at a reachable Nema")
	hub.dialogue_panel.close_dialogue(true)
	await process_frame
	var forge: RootforgeMenu = hub.rootforge_menu
	forge._select_recipe(forge.catalog.find_recipe(&"forest_stage_5_old_bark_helm"))
	check(forge.visible and not forge.primary_action_button.disabled,"Seeded Nema demo is not craftable")
	forge.close_menu()
	hub.character_menu.open_menu()
	await process_frame
	check(hub.character_menu._material_cards.size() == 15 and hub.character_menu._equipment_cards.size() == 2,"Demo bag does not show the seeded gear and pouch")
	await capture_demo("interface_demo_bag.png")
	hub.character_menu.close_menu()
	hub.queue_free()
	current_scene = null
	await process_frame
	print("PLAYER_INTERFACE_DEMO: ",checks," checks, ",failures," failures")
	quit(1 if failures else 0)

func button(row: Control, title: String) -> Button:
	for child in row.get_children():
		if child is Button and child.text == title: return child
	return null

func click(control: Control) -> void:
	var event := InputEventMouseButton.new()
	event.position = control.get_global_rect().get_center()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	root.push_input(event)
	event = event.duplicate()
	event.pressed = false
	root.push_input(event)
	await process_frame
	await process_frame

func capture_demo(file: String) -> void:
	if DisplayServer.get_name() == "headless": return
	await process_frame
	await RenderingServer.frame_post_draw
	var folder := "res://tmp/review/ui/centered_paperdoll_2026_10_02/demo/"
	DirAccess.make_dir_recursive_absolute(folder)
	check(root.get_texture().get_image().save_png(folder+file) == OK,"Demo capture failed")

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
