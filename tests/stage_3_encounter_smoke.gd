extends SceneTree

const Stage3Scene = preload("res://levels/stage_3/stage_3.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	var stage := Stage3Scene.instantiate()
	stage.review_hold_encounter = true
	var controller: EncounterController = stage.get_node("GameplayServices/EncounterController")
	root.add_child(stage)
	var ground := stage.get_node("World/Level/Ground") as TileMapLayer
	var navigation_region := stage.get_node("World/NavigationRegion2D") as NavigationRegion2D
	if controller.auto_start or controller.waves.size() != 2:
		_fail("Stage 3 must wait for arrival lore and retain its authored two-wave structure.")
		return
	var brood_wave := controller.waves[0] as EncounterWaveDefinition
	if brood_wave.rootling_count != 13 or brood_wave.total_enemy_count() != 14 or brood_wave.spawn_entries.size() != 1:
		_fail("Stage 3's approach requires thirteen Rootlings and one Rotcaller.")
		return
	var boss_wave := controller.waves[1] as EncounterWaveDefinition
	if boss_wave.rootbound_husk_count != 1 or boss_wave.total_enemy_count() != 1:
		_fail("Stage 3's finale must be a solo Rootbound Husk encounter.")
		return
	if controller.rootbound_husk_scene == null or controller.max_active_enemies != 5:
		_fail("Stage 3 lost its Husk scene or the five-enemy cap.")
		return
	if controller.portal_target_scene != "res://levels/stage_4/stage_4.tscn":
		_fail("Stage 3's post-mini-boss portal must continue into Stage 4.")
		return
	if controller.portal_tier != StagePortal.PortalTier.NORMAL:
		_fail("Stage 3 must return to a blue Normal portal after its mini-boss is defeated.")
		return
	if (
		controller.completion_reward_mode
			!= EncounterController.CompletionRewardMode.STAGE_CHEST
		or controller.reward_chest_scene == null
		or controller.stage_loot_table == null
		or controller.reward_chest_tier
			!= StageRewardChest.ChestTier.ROOTBOUND_RELIQUARY
	):
		_fail("Stage 3 must gate its forward portal behind the authored clear chest.")
		return
	if 2 not in controller.gated_wave_numbers:
		_fail("Stage 3 must gate the solo Husk until its skippable introduction closes.")
		return
	if stage.get("dialogue_panel") == null or stage.get("rootbound_husk_portrait") == null:
		_fail("Stage 3 lost its dialogue panel or Rootbound Husk portrait.")
		return
	if ground.layout == null or ground.layout.resource_path != "res://data/environment/layouts/stage_3_rootbound_ground.tres":
		_fail("Stage 3 is not using its authored Rootbound Hollow ground layout.")
		return
	if ground.tile_set.resource_path != "res://assets/environment/forest/hollow_renewal/hollow_ground_tileset.tres":
		_fail("Stage 3 is not using the organized Rootbound Hollow TileSet.")
		return
	if ground.get_used_cells().size() != 1344 or ground.tile_set.tile_size != Vector2i(32,32):
		_fail("Stage 3's 48x28 decaying-forest TileMap did not populate completely.")
		return
	var corrupted_cells := 0
	var living_cells := 0
	var transition_cells := 0
	for cell in ground.get_used_cells():
		match ground.get_cell_source_id(cell):
			0:
				corrupted_cells += 1
			1:
				living_cells += 1
			2:
				transition_cells += 1
	var affected_ratio := float(corrupted_cells + transition_cells) / float(ground.get_used_cells().size())
	if affected_ratio < 0.24 or affected_ratio > 0.3 or transition_cells != 56:
		_fail("Stage 3 decay must remain a restrained 24-30%% incursion with two transition tiles per row; received %.2f%%." % (affected_ratio * 100.0))
		return
	if living_cells + corrupted_cells + transition_cells != 1344:
		_fail("Stage 3 contains cells outside its living, Rootbound, and transition terrain sources.")
		return
	var left_corruption := 0
	var center_corruption := 0
	var right_corruption := 0
	for cell in ground.get_used_cells():
		if ground.get_cell_source_id(cell) not in [0, 2]:
			continue
		if cell.x < 16:
			left_corruption += 1
		elif cell.x < 32:
			center_corruption += 1
		else:
			right_corruption += 1
	if left_corruption < 300 or center_corruption > 16 or right_corruption > 0:
		_fail("Stage 3 decay must enter from the west and taper before overtaking the living center/east.")
		return
	var arena_seal := stage.get_node_or_null("World/Actors/RootboundArenaSeal") as StaticBody2D
	if arena_seal == null or not arena_seal.has_node("NavigationCutout"):
		_fail("Stage 3 lost its colliding, navigation-aware arena landmark.")
		return
	if not is_equal_approx(navigation_region.navigation_agent_radius, 20.0):
		_fail("Stage 3 navigation is not baked for the Rootbound Husk's large footprint.")
		return
	var navigation_map := navigation_region.get_world_2d().get_navigation_map()
	var seal_route := PackedVector2Array()
	for attempt in range(30):
		seal_route = NavigationServer2D.map_get_path(
			navigation_map,
			Vector2(768.0, 150.0),
			Vector2(768.0, 760.0),
			true,
			1
		)
		if seal_route.size() >= 3:
			break
		await physics_frame
	if seal_route.size() < 3:
		_fail("The Husk cannot obtain a route around the central Rootbound seal.")
		return
	var seal_base := arena_seal.get_node("Footprint") as CollisionShape2D
	var seal_shape := seal_base.shape as RectangleShape2D
	if seal_shape.size.x > 160 or seal_shape.size.y > 48:
		_fail("Renewed seal footprint is too large for compact fighting lanes.")
		return
	var husk_clearance := Rect2(seal_base.global_position-seal_shape.size*.5,seal_shape.size).grow(16.0)
	for point_index in range(seal_route.size() - 1):
		var start := seal_route[point_index]
		var finish := seal_route[point_index + 1]
		var sample_count := maxi(ceili(start.distance_to(finish) / 4.0), 1)
		for sample_index in range(sample_count + 1):
			var sample := start.lerp(finish, float(sample_index) / float(sample_count))
			if husk_clearance.has_point(sample):
				_fail("The Husk route clips its body into the central seal at %s." % sample)
				return
	var dialogue := stage.get("dialogue_panel") as DialoguePanel
	var skipped := [false]
	dialogue.dialogue_closed.connect(func(completed: bool) -> void: skipped[0] = not completed, CONNECT_ONE_SHOT)
	dialogue.show_dialogue(
		"ROOTBOUND HUSK",
		["The roots remember."],
		stage.get("rootbound_husk_portrait") as Texture2D
	)
	if not paused or not dialogue.visible or not dialogue.portrait.visible:
		_fail("Portrait dialogue did not pause safely or present the configured face.")
		return
	dialogue.close_dialogue(false)
	if paused or not skipped[0]:
		_fail("Skipping the Husk introduction did not resume gameplay cleanly.")
		return
	var miniboss_music: AudioStream = stage.get_node("GameplayServices/MinibossMusicTrigger").miniboss_music
	if miniboss_music == null or miniboss_music.resource_path != "res://assets/audio/music/miniboss/rootbound_husk_basilisk_miniboss_loop.ogg":
		_fail("Stage 3 mini-boss music is not configured.")
		return
	print("Stage 3 encounter smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
