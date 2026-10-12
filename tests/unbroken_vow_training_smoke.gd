extends SceneTree

const SANCTUARY = preload("res://levels/sanctuary/sanctuary.tscn")
const PLAYER = preload("res://entities/player/player.tscn")
const PROFILE := "user://battle_of_gods_vow_training_smoke.json"
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
	# Simulate an older saved default kit without the new optional fields.
	session.king_skill_slots = ["echoing_sever","riftbreak","sovereign_pursuit","king_skill_4"]
	session.king_skill_layout_version = 0
	var sanctuary: Node = SANCTUARY.instantiate()
	root.add_child(sanctuary)
	current_scene = sanctuary
	await process_frame
	var actor: Player = sanctuary.player
	var library: KingSkillLibrary = actor.get_node("KingSkillLibrary")
	var vow := actor.get_node("UnbrokenVowComponent") as UnbrokenVowComponent
	check(library.current_ids().slice(0,5) == KingSkillCatalog.IDS and session.king_skill_layout_version == 2, "Legacy campaign kit did not migrate")
	check(actor.progression_component.level == 7 and library.can_upgrade_vow(true) and not library.can_upgrade_vow(false), "Eira/Level 7 gating failed")
	library.open_collection(true)
	var collection: Node = library._collection
	collection._selected = "unbroken_vow"
	collection._refresh()
	check(collection._upgrade_button.visible and not collection._upgrade_button.disabled, "Trainer UI has no enabled Vow upgrade")
	collection._upgrade_button.pressed.emit()
	collection._close()
	await process_frame
	check(session.king_vow_rank == 1 and vow.definition.rank == 1, "Trainer click did not grant Advanced")
	check(not library.can_upgrade_vow(true), "Mature unlocked before Level 10")
	story.remember_story(&"forest_stage_5_cleared")
	session.update_progression(4950,0)
	check(actor.progression_component.level == 10 and library.upgrade_vow(true), "Mature training failed at cap")
	check(session.king_vow_rank == 2 and vow.definition.rank == 2 and not library.can_upgrade_vow(true), "Mature rank can overlevel")
	check(save.has_valid_profile(), "Upgrade was not saved")
	session.king_vow_rank = 0
	check(save.load_profile() == save.DEFAULT_SAFE_SCENE and session.king_vow_rank == 2, "Rank did not restore from disk")
	var fresh := PLAYER.instantiate() as Player
	root.add_child(fresh)
	await process_frame
	check(fresh.get_node("UnbrokenVowComponent").definition.rank == 2 and fresh.get_ability_component_for_slot(5).definition.ability_id == &"king_skill_4", "Reload lost rank or Worldsplitter")
	check(fresh.health_component.shield_health == 0.0, "Transient shield was saved")
	var snapshot: Dictionary = session.create_snapshot()
	snapshot.king_vow_rank = 1.5
	check(not session.can_restore_snapshot(snapshot), "Fractional buff rank accepted")
	snapshot.erase("king_vow_rank")
	snapshot.erase("king_skill_layout_version")
	check(session.can_restore_snapshot(snapshot), "Older snapshot became invalid")
	fresh.queue_free()
	sanctuary.queue_free()
	current_scene = null
	await process_frame
	save.delete_profile()
	save.reset_storage_path_after_testing()
	print("VOW_TRAINING: ",checks," checks, ",failures," failures")
	quit(1 if failures else 0)

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1; push_error(message)
