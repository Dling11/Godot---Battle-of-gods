extends SceneTree

const CragBearScene = preload("res://entities/enemies/crag_bear/crag_bear.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_validate_data_and_art()
	_validate_stage_contract()
	await _validate_attack_states()
	print("STAGE_6_CRAG_BEAR_SMOKE_PASSED")
	quit(0)


func _validate_data_and_art() -> void:
	var definition := load("res://data/enemies/crag_bear.tres") as CragBearDefinition
	assert(definition != null, "Crag Bear definition must load")
	assert(definition.enemy_id == &"crag_bear", "Crag Bear stable ID drifted")
	assert(definition.maximum_health == 210.0, "Crag Bear health band drifted")
	assert(definition.attack_damage == 24.0, "Crag Bear basic damage drifted")
	assert(definition.ground_slam_damage == 34.0, "Crag Bear slam damage drifted")
	assert(
		definition.crowd_control_tier == EnemyDefinition.CrowdControlTier.HEAVY,
		"Crag Bear requires Heavy control resistance without becoming a mini-boss"
	)
	assert(definition.stagger_interrupt_limit == 4)
	assert(is_equal_approx(definition.stagger_resistance_seconds, 1.05))
	var frames := load(
		"res://assets/characters/enemies/stage_6_crag_bear/crag_bear_sprite_frames.tres"
	) as SpriteFrames
	assert(frames != null, "Crag Bear SpriteFrames must load")
	for direction in [&"down", &"left", &"right", &"up"]:
		assert(frames.get_frame_count(&"walk_%s" % direction) == 4)
		assert(frames.get_frame_count(&"attack_%s" % direction) == 8)
		assert(frames.get_frame_count(&"slam_%s" % direction) == 8)
		assert(frames.get_frame_count(&"hurt_%s" % direction) == 2)
		assert(frames.get_frame_count(&"dead_%s" % direction) == 4)
		var attack_frame := frames.get_frame_texture(
			&"attack_%s" % direction, 5
		) as AtlasTexture
		var slam_frame := frames.get_frame_texture(
			&"slam_%s" % direction, 3
		) as AtlasTexture
		assert(attack_frame != null and attack_frame.region.size == Vector2(96, 64))
		assert(slam_frame != null and slam_frame.region.size == Vector2(96, 80))
	var presentation_bear := CragBearScene.instantiate() as CragBear
	var action_audio := presentation_bear.get_node("ActionAudio") as CragBearActionAudio
	assert(action_audio != null, "Crag Bear requires its dedicated action-audio observer")
	var expected_streams := {
		action_audio.claw_player: "crag_bear_claw_swipe.wav",
		action_audio.growl_a_player: "crag_bear_growl_a.ogg",
		action_audio.growl_b_player: "crag_bear_growl_b.ogg",
		action_audio.slam_player: "crag_bear_ground_slam.wav",
	}
	for player: AudioStreamPlayer2D in expected_streams:
		assert(player != null and player.stream != null)
		assert(player.stream.resource_path.ends_with(expected_streams[player]))
		assert(player.bus == &"SFX")
	var impact_presenter := (
		presentation_bear.get_node("ImpactPresenter") as CragBearImpactPresenter
	)
	assert(impact_presenter != null and impact_presenter.impact_origin != null)
	assert(impact_presenter.impact_scene != null)
	var impact_preview := impact_presenter.impact_scene.instantiate()
	assert(
		impact_preview is CragBearSlamImpactVfx,
		"Ground slam requires the reusable world-anchored impact effect"
	)
	impact_preview.free()
	presentation_bear.free()
	var crag_iron := load(
		"res://data/items/materials/forest/crag_iron.tres"
	) as MaterialDefinition
	var echo_claw := load(
		"res://data/items/materials/forest/echo_claw.tres"
	) as MaterialDefinition
	assert(crag_iron != null and crag_iron.is_valid())
	assert(echo_claw != null and echo_claw.is_valid())
	assert(crag_iron.rarity == MaterialDefinition.MaterialRarity.COMMON)
	assert(echo_claw.rarity == MaterialDefinition.MaterialRarity.UNCOMMON)
	assert(not crag_iron.is_reconstruction_target())
	assert(echo_claw.is_reconstruction_target())
	var drops := load(
		"res://data/loot/forest/enemies/crag_bear_drop_profile.tres"
	) as DropProfileDefinition
	assert(drops != null and drops.has_valid_layout())
	assert(drops.source_enemy_id == definition.enemy_id)
	assert(drops.common_drops[0].chance == 0.3)
	assert(drops.common_drops[0].guaranteed_after_misses == 5)
	assert(drops.optional_secondary[0].chance == 0.08)
	assert(drops.optional_secondary[0].guaranteed_after_misses == 12)
	var catalog := load(
		"res://data/items/materials/material_catalog.tres"
	) as MaterialCatalogDefinition
	assert(catalog.find_material(crag_iron.material_id) == crag_iron)
	assert(catalog.find_material(echo_claw.material_id) == echo_claw)


func _validate_stage_contract() -> void:
	var stage_scene := load("res://levels/stage_6/stage_6.tscn") as PackedScene
	assert(stage_scene != null, "Production Stage VI scene must load")
	var stage := stage_scene.instantiate()
	var encounter := stage.get_node("Services/EncounterController") as EncounterController
	assert(encounter != null, "Stage VI requires EncounterController authority")
	assert(encounter.waves.size() == 5, "Stage VI must own five authored waves")
	assert(encounter.max_active_enemies == 5, "Stage VI live cap drifted")
	assert(encounter.portal_target_scene == "res://levels/sanctuary/sanctuary.tscn")
	assert(encounter.portal_tier == StagePortal.PortalTier.NORMAL, "Stage VI return portal must remain blue Normal")
	var expected_totals := [4, 4, 5, 6, 9]
	var total_bears := 0
	var total_spitters := 0
	var total_thralls := 0
	for index in expected_totals.size():
		var wave := encounter.waves[index] as EncounterWaveDefinition
		assert(wave.total_enemy_count() == expected_totals[index])
		for entry: EncounterSpawnEntryDefinition in wave.spawn_entries:
			var path := entry.enemy_scene.resource_path
			if path.ends_with("crag_bear.tscn"):
				total_bears += entry.count
			elif path.ends_with("bramble_spitter.tscn"):
				total_spitters += entry.count
			elif path.ends_with("forsaken_thrall.tscn"):
				total_thralls += entry.count
	assert(total_bears == 8, "Stage VI must preserve the approved Bear population")
	assert(total_spitters == 5, "Stage VI ranged pressure drifted")
	assert(total_thralls == 14, "Stage VI melee-screening pressure drifted")
	for wave_index in [3, 4]:
		var pressure_wave := encounter.waves[wave_index] as EncounterWaveDefinition
		assert(
			pressure_wave.spawn_entries[1].enemy_scene.resource_path.ends_with(
				"bramble_spitter.tscn"
			),
			"Late Stage VI waves must place ranged pressure in the initial live batch"
		)
	var opening := encounter.waves[0] as EncounterWaveDefinition
	assert(opening.spawn_entries.size() == 3)
	for entry: EncounterSpawnEntryDefinition in opening.spawn_entries:
		assert(not entry.enemy_scene.resource_path.ends_with("mireling.tscn"))
	var navigation := stage.get_node("World/NavigationRegion2D") as NavigationRegion2D
	assert(navigation != null, "Stage VI requires production navigation")
	stage.free()
	var route := load(
		"res://data/expeditions/elder_ascent.tres"
	) as ExpeditionDefinition
	assert(route != null and route.destination_scene == "res://levels/stage_6/stage_6.tscn")


func _validate_attack_states() -> void:
	var arena := Node2D.new()
	root.add_child(arena)
	var target := CharacterBody2D.new()
	target.position = Vector2(26.0, 0.0)
	arena.add_child(target)

	var slam_bear := CragBearScene.instantiate() as CragBear
	slam_bear.definition = slam_bear.definition.duplicate(true) as CragBearDefinition
	slam_bear.definition.spawn_seconds = 0.1
	slam_bear.definition.initial_ground_slam_delay = 0.0
	slam_bear.target = target
	var slam_states: Array[int] = []
	slam_bear.state_changed.connect(
		func(state: CragBear.State, _duration: float) -> void:
			slam_states.append(state)
	)
	arena.add_child(slam_bear)
	await create_timer(1.3).timeout
	assert(CragBear.State.SLAM_WIND_UP in slam_states)
	assert(CragBear.State.SLAM_ACTIVE in slam_states)
	var impact := arena.find_child("CragBearSlamImpactVfx", true, false) as CragBearSlamImpactVfx
	assert(impact != null, "Slam contact must spawn its ground effect")
	assert(
		impact.global_position.distance_to(slam_bear.ground_slam_hitbox.global_position) < 0.1,
		"Slam effect must originate at the authoritative radial hitbox"
	)
	slam_bear.queue_free()
	await process_frame

	var basic_bear := CragBearScene.instantiate() as CragBear
	basic_bear.definition = basic_bear.definition.duplicate(true) as CragBearDefinition
	basic_bear.definition.spawn_seconds = 0.1
	basic_bear.definition.initial_ground_slam_delay = 9.0
	basic_bear.target = target
	var basic_states: Array[int] = []
	basic_bear.state_changed.connect(
		func(state: CragBear.State, _duration: float) -> void:
			basic_states.append(state)
	)
	arena.add_child(basic_bear)
	await create_timer(1.0).timeout
	assert(CragBear.State.BASIC_WIND_UP in basic_states)
	assert(CragBear.State.BASIC_ACTIVE in basic_states)
	for hit in range(3):
		basic_bear.health_component.apply_damage(
			DamageInfo.new(1.0, target, Vector2.RIGHT, 0.0, 0.11)
		)
	assert(basic_bear.state == CragBear.State.STAGGER)
	basic_bear.health_component.apply_damage(
		DamageInfo.new(1.0, target, Vector2.RIGHT, 0.0, 0.11)
	)
	for frame in range(3):
		await physics_frame
		if basic_bear.state != CragBear.State.STAGGER:
			break
	assert(basic_bear.stagger_component.is_resisting_stagger())
	assert(
		basic_bear.state != CragBear.State.STAGGER,
		"Fourth rapid interruption must release Bear to an actionable state"
	)
	arena.queue_free()
	await process_frame
