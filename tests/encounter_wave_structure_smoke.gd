extends SceneTree

const ArenaScene = preload("res://levels/test_arena/test_arena.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var arena := ArenaScene.instantiate()
	var controller: EncounterController = arena.get_node("GameplayServices/EncounterController")
	controller.auto_start = false
	root.add_child(arena)
	if controller.waves.size() != 6:
		_fail("Stage 1 must contain six authored forest waves.")
		return
	if controller.inter_wave_delay < 2.0:
		_fail("Inter-wave recovery is too short to provide a readable breathing window.")
		return
	if controller.max_active_enemies != 4:
		_fail("Stage 1 must retain the validated four-enemy active cap.")
		return
	if controller.rootling_scene == null:
		_fail("Stage 1 Rootling waves require the dedicated Rootling scene.")
		return
	for index in range(controller.waves.size()):
		var wave := controller.waves[index] as EncounterWaveDefinition
		if wave.total_enemy_count() < 3:
			_fail("Wave %d must contain a meaningful combat group." % [index + 1])
			return
	var reinforcement_wave := controller.waves[2] as EncounterWaveDefinition
	if reinforcement_wave.total_enemy_count() != 5 or reinforcement_wave.reinforcement_delay < 0.5:
		_fail("Stage 1 must introduce controlled reinforcements in Wave 3.")
		return
	var final_wave := controller.waves[5] as EncounterWaveDefinition
	if final_wave.bramble_spitter_count != 0:
		_fail("Stage 1 must remain a beginner melee and leap tutorial without Bramble Spitters.")
		return
	if final_wave.mireling_count != 2 or final_wave.rootling_count != 2 or final_wave.thrall_count != 3:
		_fail("Stage 1 finale must be a seven-enemy melee/leap/root-jab endurance wave.")
		return
	if final_wave.total_enemy_count() != 7 or final_wave.reinforcement_delay < 0.5:
		_fail("Stage 1 finale must use the reinforcement queue instead of an oversized initial crowd.")
		return
	var clear_state := {"emitted": false}
	controller.stage_cleared.connect(func() -> void: clear_state.emitted = true)
	var loot_service := root.get_node("LootService")
	var material_inventory := root.get_node("MaterialInventory")
	material_inventory.reset_inventory()
	loot_service.reset_expedition_tracking()
	loot_service.begin_expedition()
	material_inventory.add_material(&"forest_root_fiber", 1)
	controller._complete_encounter()
	await process_frame
	if not clear_state.emitted:
		_fail("Stage 1 did not open its portal immediately after banking clear loot.")
		return
	if loot_service.has_active_expedition():
		_fail("Stage 1 direct completion did not bank its expedition rewards.")
		return
	for actor in controller.actors.get_children():
		if actor is StageRewardChest:
			_fail("Stage 1 unexpectedly spawned a reward chest.")
			return
	if arena.get_node("World/Effects").get_child_count() != 1:
		_fail("Stage 1 direct completion did not create exactly one exit portal.")
		return
	print("Encounter wave structure smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
