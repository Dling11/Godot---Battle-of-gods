extends SceneTree

## Real Combat Lab and Player; isolated storage and session-only F9 equipment.
const LAB = preload("res://levels/combat_lab/combat_lab.tscn")
const ITEM = preload("res://data/items/equipment/king_royal_greatsword_v2.tres")

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	root.get_node("SaveService").configure_storage_path_for_testing("user://greatsword_v2_training_session.json")
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	root.get_node("RunSession").reset_run()
	var lab := LAB.instantiate()
	root.add_child(lab)
	current_scene = lab
	lab.player.apply_debug_testing_preset()
	if not lab.player.equip_owned_weapon(ITEM):
		push_error("Combat Lab could not equip the approved Royal Greatsword")
		quit(1)
		return
	await process_frame
	await process_frame
	lab.clear_simulation()
	lab.enemy_selector.select(1)
	lab.ai_toggle.set_pressed_no_signal(false)
	lab.set_enemy_ai_enabled(false)
	lab.spawn_selected(3)
	lab.review_tabs.current_tab = 2
	root.title = "Battle of Gods — Weapon impacts / Combat Lab"
	root.grab_focus()
	print("GREATSWORD_V2_TRAINING_READY weapon=",lab.player.attack_component.weapon.weapon_id," tabs=",lab.review_tabs.get_tab_count())
	if OS.get_cmdline_user_args().has("--smoke"): quit()
