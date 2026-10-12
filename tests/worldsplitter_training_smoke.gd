extends SceneTree

const PROFILE := "user://battle_of_gods_worldsplitter_training_smoke.json"
var failures := 0
var checks := 0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var save := root.get_node("SaveService")
	check(save.configure_storage_path_for_testing(PROFILE), "Isolated save unavailable")
	save.delete_profile()
	var session := root.get_node("RunSession")
	var story := root.get_node("StoryState")
	session.reset_run()
	story.reset_story()
	story.remember_story(&"forest_stage_4_cleared")
	session.update_progression(2400,0)
	var sanctuary: Node = load("res://levels/sanctuary/sanctuary.tscn").instantiate()
	root.add_child(sanctuary)
	current_scene = sanctuary
	await process_frame
	var actor: Player = sanctuary.player
	var library: KingSkillLibrary = actor.get_node("KingSkillLibrary")
	check(not library.can_upgrade_worldsplitter(true), "Upgrade ignored level requirement")
	story.remember_story(&"forest_stage_5_cleared")
	session.update_progression(3150,0)
	check(actor.progression_component.level == 8 and library.can_upgrade_worldsplitter(true) and not library.can_upgrade_worldsplitter(false), "Eira/level gate wrong")
	library.open_collection(true)
	var collection: Node = library._collection
	collection._selected = "king_skill_4"
	collection._refresh()
	check(collection._upgrade_button.visible and not collection._upgrade_button.disabled, "Eira has no Worldsplitter training")
	collection._upgrade_button.pressed.emit()
	collection._close()
	await process_frame
	check(session.king_worldsplitter_rank == 1 and actor.ability_4_component.definition.rank == 1, "Training click did not grant Advanced")
	check(library.get_worldsplitter_upgrade_level() == 10 and not library.can_upgrade_worldsplitter(true), "Mature bypassed its Level 10 gate")
	session.king_worldsplitter_rank = 0
	check(save.load_profile() == save.DEFAULT_SAFE_SCENE and session.king_worldsplitter_rank == 1, "Rank failed save/reload")
	var player: Player = load("res://entities/player/player.tscn").instantiate()
	root.add_child(player)
	await process_frame
	check(player.ability_4_component.definition.rank == 1 and player.get_ability_component_for_slot(5) == player.ability_4_component, "New player lost trained rank/binding")
	var snapshot: Dictionary = session.create_snapshot()
	for invalid in [-1,3,1.5,"1",true]:
		snapshot.king_worldsplitter_rank = invalid
		check(not session.can_restore_snapshot(snapshot), "Invalid saved rank accepted")
	snapshot.erase("king_worldsplitter_rank")
	check(session.can_restore_snapshot(snapshot), "Old save became incompatible")
	player.queue_free()
	sanctuary.queue_free()
	current_scene = null
	await process_frame
	save.delete_profile()
	save.reset_storage_path_after_testing()
	print("WORLDSPLITTER_TRAINING: ",checks," checks, ",failures," failures")
	quit(1 if failures else 0)

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1; push_error(message)
