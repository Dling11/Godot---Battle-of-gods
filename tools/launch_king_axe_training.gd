extends SceneTree

## Normal Player / Combat Lab controls, isolated storage and session-only kit.
const LAB = preload("res://levels/combat_lab/combat_lab.tscn")
const ITEM = preload("res://data/items/equipment/king_iron_beard_axe.tres")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	root.get_node("SaveService").configure_storage_path_for_testing("user://axe_training_session.json")
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	root.get_node("RunSession").reset_run()
	var lab := LAB.instantiate()
	root.add_child(lab)
	current_scene=lab
	lab.player.apply_debug_testing_preset()
	if not lab.player.equip_owned_weapon(ITEM):
		push_error("Training could not equip Iron Beard from the normal catalog")
		quit(1)
		return
	await process_frame
	await process_frame
	lab.clear_simulation()
	lab.enemy_selector.select(1)
	lab.ai_toggle.set_pressed_no_signal(false)
	lab.set_enemy_ai_enabled(false)
	lab.spawn_selected(1)
	lab.review_tabs.current_tab=0
	root.title="Battle of Gods — Iron Beard Axe / Combat Lab"
	root.grab_focus()
	print("AXE_TRAINING_READY weapon=",lab.player.attack_component.weapon.weapon_id," bag=",lab.get_node("UI/CharacterMenu")!=null)
