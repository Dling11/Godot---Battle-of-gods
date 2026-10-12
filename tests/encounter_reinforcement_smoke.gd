extends SceneTree

const ArenaScene = preload("res://levels/test_arena/test_arena.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	root.get_node("SaveService").configure_storage_path_for_testing("user://reinforcement_smoke.json")
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	var arena := ArenaScene.instantiate()
	var controller: EncounterController = arena.get_node("GameplayServices/EncounterController")
	controller.auto_start = false
	controller.inter_wave_delay = 0.5
	for resource in controller.waves:
		var wave := resource as EncounterWaveDefinition
		wave.spawn_interval = 0.1
		wave.reinforcement_delay = 0.25
	var expected_spawns := 0
	var expected_reinforcements := 0
	for resource in controller.waves:
		var wave := resource as EncounterWaveDefinition
		expected_spawns += wave.total_enemy_count()
		expected_reinforcements += maxi(0, wave.total_enemy_count() - controller.max_active_enemies)
	var state := {
		"spawned": 0,
		"max_active": 0,
		"cleared": false,
		"reinforcements": 0,
		"waiting_for_reinforcement": false,
		"announced_at_msec": 0,
		"released_too_early": false,
	}
	controller.enemy_spawned.connect(func(_position: Vector2) -> void:
		if state.waiting_for_reinforcement:
			if Time.get_ticks_msec() - state.announced_at_msec < 200:
				state.released_too_early = true
			state.waiting_for_reinforcement = false
		state.spawned += 1
	)
	controller.reinforcement_announced.connect(func(_delay_seconds: float) -> void:
		state.reinforcements += 1
		state.waiting_for_reinforcement = true
		state.announced_at_msec = Time.get_ticks_msec()
	)
	controller.stage_cleared.connect(func() -> void: state.cleared = true)
	root.add_child(arena)
	controller.start_encounter()
	var deadline := Time.get_ticks_msec() + 12000
	while not state.cleared and Time.get_ticks_msec() < deadline:
		await process_frame
		state.max_active = maxi(state.max_active, controller._active_enemies)
		for actor in controller.actors.get_children():
			if actor != controller.player and actor.get("target") == controller.player:
				actor.queue_free()
	if not state.cleared:
		_fail("Queued reinforcement encounter did not reach its direct exit portal in time.")
		return
	if state.spawned != expected_spawns:
		_fail("Reinforcement queue spawned %d enemies, expected %d." % [state.spawned, expected_spawns])
		return
	if state.max_active > controller.max_active_enemies:
		_fail("Reinforcement queue exceeded the configured active-enemy cap.")
		return
	if state.reinforcements != expected_reinforcements:
		_fail("Each pending enemy must receive its own reinforcement warning: actual=%d expected=%d." % [state.reinforcements,expected_reinforcements])
		return
	if state.released_too_early:
		_fail("A reinforcement arrived before its readable warning window elapsed.")
		return
	print("Encounter reinforcement smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
