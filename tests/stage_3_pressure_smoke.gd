extends SceneTree

const Pressure = preload("res://tools/stage_3_pressure_review.gd")
var checks := 0
var failures := 0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var save := root.get_node("SaveService")
	var disk_before := _profile_files(save.get_profile_path())
	save.suppress_autosave_for_debug_session()
	var campaign: Node = load("res://levels/stage_3/stage_3.tscn").instantiate()
	var stage: Node = load("res://levels/stage_3/stage_3.tscn").instantiate()
	stage.review_hold_encounter = true
	var encounter: EncounterController = stage.encounter_controller
	Pressure.configure(encounter)
	_check(campaign.encounter_controller.waves[0].rootling_count == 13 and campaign.encounter_controller.max_active_enemies == 5,"Review edited campaign balance")
	_check(encounter.waves[0] != campaign.encounter_controller.waves[0],"Review shares the mutable brood resource")
	campaign.free()
	encounter.waves[0].spawn_interval = .04
	encounter.waves[0].reinforcement_delay = .04
	encounter.inter_wave_delay = .05
	root.add_child(stage)
	current_scene = stage
	stage.player.health_component.is_damage_immune = true
	var spawned := [0]
	encounter.enemy_spawned.connect(func(_position: Vector2) -> void: spawned[0] += 1)
	encounter.start_encounter()
	var initial_deadline := Time.get_ticks_msec() + int((encounter.arrival_warning_seconds + 5 * encounter.waves[0].spawn_interval + 1.0) * 1000)
	while spawned[0] < 6 and Time.get_ticks_msec() < initial_deadline:
		await process_frame
	_check(spawned[0] == 6 and encounter._active_enemies == 6,"Pressure did not fill its bounded six-enemy first group")
	var exceeded_cap := false
	var deadline := Time.get_ticks_msec()+12000
	while not paused and Time.get_ticks_msec() < deadline:
		exceeded_cap = exceeded_cap or encounter._active_enemies > 6
		for actor in encounter.actors.get_children():
			if (actor is Rootling or actor is Rotcaller) and actor.health_component.current_health > 0:
				var damage := DamageInfo.new(10000,stage.player,Vector2.ZERO)
				damage.ignores_invulnerability = true
				actor.health_component.apply_damage(damage)
		await process_frame
	_check(not exceeded_cap and spawned[0] == 19,"Brood reinforcements exceeded cap or lost queued enemies")
	_check(paused and stage.dialogue_panel.visible and encounter.wave_index == 0,"Pressure bypassed the portrait gate")
	stage.dialogue_panel.close_dialogue(false)
	await create_timer(1.2).timeout
	var bosses := encounter.actors.get_children().filter(func(actor: Node) -> bool: return actor is RootboundHusk)
	_check(not paused and bosses.size() == 1 and spawned[0] == 20 and encounter._active_enemies == 1,"Review boss wave is not solo after dialogue")
	if bosses.size() == 1:
		_check(bosses[0].health_component.maximum_health == 280,"Review changed the boss baseline")
	var ambience: Node = stage.get_node("World/OutdoorAudio")
	_check(is_equal_approx(ambience.bed.volume_db,-36),"Pressure did not duck the Hollow bed")
	_check(save.is_autosave_suppressed_for_debug(),"Pressure did not suppress saving")
	save.save_profile()
	_check(_profile_files(save.get_profile_path()) == disk_before,"Pressure changed normal profile/backup/temp bytes")
	stage.queue_free()
	await process_frame
	print("STAGE_3_PRESSURE: ",checks," checks, ",failures," failures")
	quit(1 if failures else 0)

func _profile_files(path: String) -> Dictionary:
	var files := {}
	for file: String in [path,path+".bak",path+".tmp"]:
		files[file] = FileAccess.get_sha256(file) if FileAccess.file_exists(file) else "absent"
	return files

func _check(ok: bool,message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
