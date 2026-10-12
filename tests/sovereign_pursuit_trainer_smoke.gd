extends SceneTree

const Sanctuary = preload("res://levels/sanctuary/sanctuary.tscn")
const PlayerScene = preload("res://entities/player/player.tscn")
const TEST_PROFILE := "user://battle_of_gods_pursuit_trainer_smoke.json"
var failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var save := root.get_node("SaveService")
	check(save.configure_storage_path_for_testing(TEST_PROFILE), "Could not isolate the test profile")
	save.delete_profile()
	root.get_node("RunSession").reset_run()
	root.get_node("StoryState").reset_story()
	root.get_node("StoryState").remember_story(&"forgotten_grove_completed")
	root.get_node("RunSession").update_progression(1200, 0)
	var sanctuary := Sanctuary.instantiate()
	root.add_child(sanctuary)
	current_scene = sanctuary
	await process_frame
	var actor: Player = sanctuary.player
	var library: KingSkillLibrary = actor.get_node("KingSkillLibrary")
	var pursuit := actor.ability_3_component as SovereignPursuitComponent
	check(actor.progression_component.level == 5, "Level 5 gate setup failed")
	check(not library.can_upgrade_pursuit(false) and library.can_upgrade_pursuit(true), "Level 5 upgrade is not Eira-only")
	var menu: CharacterMenu = sanctuary.character_menu
	menu.open_skillkeeper_menu()
	check(menu._skillkeeper_access, "Eira did not open the trainer context")
	var collection_button: Button = menu.collection_button
	check(collection_button != null, "Eira's skills page has no collection entry")
	if collection_button != null:
		collection_button.pressed.emit()
	var collection: Node = library._collection
	check(collection != null and collection.trainer_access, "The collection lost Eira access")
	if collection != null:
		collection._selected = "sovereign_pursuit"
		collection._refresh()
		check(collection._upgrade_button.visible and not collection._upgrade_button.disabled, "The Level 5 trainer button is unavailable")
		collection._upgrade_button.pressed.emit()
		collection._close()
	menu.close_menu()
	check(root.get_node("RunSession").king_pursuit_rank == 1 and pursuit.get_max_charges() == 2, "Level 5 upgrade did not reach two charges")
	check(not library.can_upgrade_pursuit(true), "Level 8 upgrade opened at Level 5")
	root.get_node("StoryState").remember_story(&"forest_stage_5_cleared")
	root.get_node("RunSession").update_progression(3150, 0)
	check(actor.progression_component.level == 8 and library.can_upgrade_pursuit(true), "Level 8 gate did not open")
	check(library.upgrade_pursuit(true), "Eira could not grant the Level 8 upgrade")
	check(root.get_node("RunSession").king_pursuit_rank == 2 and pursuit.get_max_charges() == 3, "Level 8 upgrade did not reach three charges")
	check(save.has_valid_profile(), "Pursuit upgrade was not saved")
	root.get_node("RunSession").king_pursuit_rank = 0
	check(save.load_profile() == save.DEFAULT_SAFE_SCENE and root.get_node("RunSession").king_pursuit_rank == 2, "Saved Pursuit rank was not restored")
	var fresh := PlayerScene.instantiate() as Player
	root.add_child(fresh)
	await process_frame
	check((fresh.ability_3_component as SovereignPursuitComponent).get_max_charges() == 3, "Restored rank did not configure a new player")
	save.delete_profile()
	save.reset_storage_path_after_testing()
	print("SOVEREIGN_PURSUIT_TRAINER_FAILURES=%d" % failures)
	quit(1 if failures > 0 else 0)


func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)
