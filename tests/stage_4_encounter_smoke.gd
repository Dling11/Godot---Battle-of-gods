extends SceneTree

const Stage1Scene = preload("res://levels/test_arena/test_arena.tscn")
const Stage2Scene = preload("res://levels/stage_2/stage_2.tscn")
const Stage3Scene = preload("res://levels/stage_3/stage_3.tscn")
const Stage4Scene = preload("res://levels/stage_4/stage_4.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	var expected_early_caps := [4, 6, 5]
	var early_scenes: Array[PackedScene] = [Stage1Scene, Stage2Scene, Stage3Scene]
	for scene_index in early_scenes.size():
		var early_stage := early_scenes[scene_index].instantiate()
		var early_controller := early_stage.get_node("GameplayServices/EncounterController") as EncounterController
		if early_controller.max_active_enemies != expected_early_caps[scene_index]:
			_fail("Stage %d lost its authored live-enemy cap of %d." % [scene_index + 1, expected_early_caps[scene_index]])
			return
		early_stage.free()

	var stage := Stage4Scene.instantiate()
	stage.review_hold_encounter = true
	root.add_child(stage)
	var controller := stage.get_node("GameplayServices/EncounterController") as EncounterController
	var ground := stage.get_node("World/Level/Ground") as TileMapLayer
	if controller.auto_start or controller.waves.size() != 5:
		_fail("Stage 4 must wait for arrival presentation and contain five authored waves.")
		return
	if controller.max_active_enemies != 8:
		_fail("Stage 4 must raise the live-enemy ceiling to eight.")
		return
	var expected_totals := [8, 10, 12, 14, 16]
	var expected_hogs := [1, 1, 2, 2, 2]
	for index in controller.waves.size():
		var wave := controller.waves[index] as EncounterWaveDefinition
		if wave.total_enemy_count() != expected_totals[index]:
			_fail("Stage 4 wave %d has %d enemies instead of %d." % [index + 1, wave.total_enemy_count(), expected_totals[index]])
			return
		if wave.armored_hog_count != expected_hogs[index]:
			_fail("Stage 4 wave %d lost its authored Armored Hog pressure." % [index + 1])
			return
		if wave.spawn_entries.size() != (0 if index == 0 else 1):
			_fail("Stage IV must introduce one Rotcaller per wave after its opener.")
			return
	if controller.armored_hog_scene == null:
		_fail("Stage 4 did not wire the Armored Hog runtime scene.")
		return
	if controller.portal_target_scene != "res://levels/stage_5/stage_5.tscn":
		_fail("Stage 4 must advance through its eastern gateway into the production Stage 5 route.")
		return
	if controller.portal_tier != StagePortal.PortalTier.BOSS:
		_fail("Stage 4 must preview Varkuun with a red Boss portal.")
		return
	if ground.layout == null or ground.layout.resource_path != "res://data/environment/layouts/stage_4_eastern_rot_ground.tres":
		_fail("Stage 4 is not using its authored eastern-rot layout.")
		return
	if ground.get_used_cells().size() != 1344 or ground.tile_set.tile_size != Vector2i(32,32):
		_fail("Stage 4's 48x28 authored TileMap did not populate completely.")
		return
	var source_counts := {0: 0, 1: 0, 2: 0, 3: 0}
	for cell in ground.get_used_cells():
		var source_id := ground.get_cell_source_id(cell)
		if source_id not in source_counts:
			_fail("Stage 4 contains an unexpected terrain source %d." % source_id)
			return
		source_counts[source_id] += 1
		if source_id in [0, 3] and cell.x < 28:
			_fail("Stage 4 decay escaped the authored eastern edge at %s." % cell)
			return
	if source_counts[0] != 440 or source_counts[1] != 848 or source_counts[2] != 0 or source_counts[3] != 56:
		_fail("Stage 4 terrain mix changed: %s." % source_counts)
		return
	for required_node in ["RottedTreeSouthEast", "RottedTreeEast", "RottedTreeNorthEast", "EastRuin"]:
		if stage.get_node_or_null("World/Actors/" + required_node) == null:
			_fail("Stage 4 lost eastern landmark %s." % required_node)
			return
	print("Stage 4 encounter smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
