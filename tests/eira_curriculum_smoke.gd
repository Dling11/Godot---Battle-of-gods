extends SceneTree

const PROFILE := "user://battle_of_gods_eira_curriculum_smoke.json"
const Training = preload("res://data/abilities/king/king_training_catalog.gd")
var checks := 0
var failures := 0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var save := root.get_node("SaveService")
	check(save.configure_storage_path_for_testing(PROFILE),"Cannot isolate curriculum profile")
	save.delete_profile()
	var session := root.get_node("RunSession")
	var story := root.get_node("StoryState")
	session.reset_run()
	story.reset_story()
	story.remember_story(&"forest_stage_5_cleared")
	var hub: Node = load("res://levels/sanctuary/sanctuary.tscn").instantiate()
	root.add_child(hub)
	current_scene = hub
	await process_frame
	var player: Player = hub.player
	var library: KingSkillLibrary = player.get_node("KingSkillLibrary")
	var layout := library.current_ids()
	# Keep a customized hotkey arrangement through every rank and profile reload.
	check(library.equip("sovereign_pursuit",1),"Cannot arrange curriculum fixture")
	layout = library.current_ids()
	var curve: ProgressionDefinition = player.progression_component.definition
	for id: String in KingSkillCatalog.IDS:
		var course := Training.course(id)
		for index in course.levels.size():
			var level: int = course.levels[index]
			check(level <= curve.maximum_level,"Curriculum requires unreleased campaign levels")
			session.update_progression(curve.total_experience_by_level[level-2],0)
			check(not library.can_upgrade_skill(id,true),"Training bypasses level gate: "+id)
			session.update_progression(curve.total_experience_by_level[level-1],0)
			check(library.can_upgrade_skill(id,true) and not library.can_upgrade_skill(id,false),"Training does not enforce mentor access: "+id)
			check(library.upgrade_skill(id,true),"Eligible training failed: "+id)
			check(session.get(course.field) == index+1,"Wrong trained rank: "+id)
			check(library.current_ids() == layout,"Training replaced customized hotkeys")
		check(not library.can_upgrade_skill(id,true) and not library.upgrade_skill(id,true),"Fully trained technique overlevels: "+id)
	check(player.ability_1_component.definition.form == EarthsplitterDefinition.Form.FAN and player.ability_1_component.definition.build_waves().size() == 4,"Earthsplitter Fan does not apply its real wave mechanics")
	check(player.ability_2_component.definition.form == MoltenCrashDefinition.Form.MATURE and player.ability_2_component.definition.aftershock_damage_share == .2,"Molten training does not apply the mature aftershock")
	check(player.ability_1_component.collision_shape.shape == player.ability_1_component.definition.hitbox_shape and player.ability_2_component.collision_shape.shape == player.ability_2_component.definition.hitbox_shape,"Trained hitboxes do not match ability tuning")
	check(player.ability_4_component.definition.rank == 2,"Final Worldsplitter form is unreachable")
	var snapshot: Dictionary = session.create_snapshot()
	for field in ["king_earthsplitter_rank","king_molten_rank"]:
		var malformed := snapshot.duplicate(true)
		for invalid in [-1,4,1.5,true,"1"]:
			malformed[field] = invalid
			check(not session.can_restore_snapshot(malformed),"Malformed training rank accepted")
	var legacy := snapshot.duplicate(true)
	legacy.erase("king_earthsplitter_rank")
	legacy.erase("king_molten_rank")
	check(session.can_restore_snapshot(legacy),"Older saves became incompatible")
	check(save.has_valid_profile(),"Trained curriculum was not saved")
	session.king_earthsplitter_rank = 0
	session.king_molten_rank = 0
	check(save.load_profile() == save.DEFAULT_SAFE_SCENE and session.king_earthsplitter_rank == 1 and session.king_molten_rank == 3,"Trained forms did not reload")
	var fresh: Player = load("res://entities/player/player.tscn").instantiate()
	root.add_child(fresh)
	await process_frame
	check(fresh.ability_1_component.definition.form == EarthsplitterDefinition.Form.FAN and fresh.ability_2_component.definition.form == MoltenCrashDefinition.Form.MATURE,"New player lost trained forms")
	check(fresh.get_node("KingSkillLibrary").current_ids() == layout,"Profile reload lost customized hotkeys")
	fresh.global_position = Vector2(384,552)
	check(fresh.request_ability(layout.find("echoing_sever")+1) and fresh.ground_point_targeting.is_targeting(),"Restored Fan cannot be aimed from its custom slot")
	fresh.ground_point_targeting.update_aim(fresh.global_position+Vector2.RIGHT*200,Vector2.ZERO)
	fresh.ground_point_targeting.confirm_targeting()
	await create_timer(.25,false,true).timeout
	var waves := get_nodes_in_group("earthsplitter_sequences")
	check(not waves.is_empty() and waves[0].plans.size() == 4,"Restored Fan did not release the trained four-wave cast")
	await create_timer(.7,false,true).timeout
	check(fresh.request_ability(layout.find("riftbreak")+1),"Restored Mature Molten cannot cast from its slot")
	await create_timer(.25,false,true).timeout
	var pulses := get_nodes_in_group("molten_crash_pulses")
	check(pulses.size() == 1 and pulses[0].radius == 86,"Restored Mature Molten did not release its real aftershock")
	await create_timer(.7,false,true).timeout
	check(get_nodes_in_group("molten_crash_pulses").is_empty(),"Trained aftershock persists after its single pulse")
	fresh.queue_free()
	hub.queue_free()
	current_scene = null
	await process_frame
	save.delete_profile()
	save.reset_storage_path_after_testing()
	print("EIRA_CURRICULUM: ",checks," checks, ",failures," failures")
	quit(1 if failures else 0)

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
