extends SceneTree

## Production dead forest. Legacy boss proof remains separately playable.
var checks := 0
var failures := 0
var stage: Node

func _initialize() -> void: call_deferred("_run")

func _run() -> void:
	var save := root.get_node("SaveService")
	var profile_before := FileAccess.get_sha256(save.get_profile_path())
	save.suppress_autosave_for_debug_session()
	root.size = Vector2i(960,540)
	stage = load("res://levels/stage_5/stage_5.tscn").instantiate()
	stage.review_hold_approach = true
	root.add_child(stage)
	current_scene = stage
	stage.player.health_component.is_damage_immune = true
	var ground: TileMapLayer = stage.get_node("World/Level/Ground")
	_check(ground.get_used_cells().size() == 1728 and ground.tile_set.tile_size == Vector2i(32,32),"Dead Forest lost its 48x36 compact ground")
	_check(stage.boss.arena_bounds == Rect2(72,72,1392,1008),"Boss pursuit bounds changed")
	_check(not stage.boss.visible and not stage.boss.is_physics_processing(),"Boss begins before its guard gate")
	_check(not stage.boss.health_component.apply_damage(DamageInfo.new(10,stage.player,Vector2.ZERO)),"Invisible dormant boss can take guard-fight damage")
	var actors: Node2D = stage.get_node("World/Actors")
	_check(actors.get_node("DeadAnimalLandmark/Flies").get_child_count() == 4,"Animated carrion flies were lost")
	var edges := 0
	for actor in actors.get_children():
		if actor.name.begins_with("Edge"): edges += 1
		if actor is StaticBody2D and actor.has_node("Sprite"):
			var sprite: Sprite2D = actor.get_node("Sprite")
			_check(sprite.texture.get_height() <= 118 and actor.scale == Vector2.ONE,"Prop is oversized or stretched")
			_check(actor.has_node("NavigationCutout") or actor.collision_layer == 0,"Solid prop has no navigation exclusion")
	_check(edges == 24,"Dead forest needs a coherent dense edge around the open basin")
	var region: NavigationRegion2D = stage.get_node("World/NavigationRegion2D")
	await create_timer(0.6).timeout
	var music: AudioStream = load("res://assets/audio/music/dead_forest_dark_place.ogg")
	_check(music.get_length() > 20 and music.loop,"Dead Forest music is incomplete or does not loop")
	_check(root.get_node("AudioDirector").music_player.stream == music,"Stage V uses the old exploration theme")
	var map := region.get_world_2d().get_navigation_map()
	var start: Vector2 = stage.player.global_position
	for point in stage.get_node("ApproachSpawnPoints").get_children():
		var route := NavigationServer2D.map_get_path(map,start,point.global_position,true)
		_check(route.size() >= 2 and route[-1].distance_to(point.global_position)<4,"Guard spawn is disconnected")
	var route := NavigationServer2D.map_get_path(map,start,Vector2(768,260),true)
	_check(route.size() >= 2 and route[-1].distance_to(Vector2(768,260))<4,"Boss clearing disconnected from arrival")
	var gate: Node2D = actors.get_node("ArrivalGateway")
	_check(gate.get_child_count() == 3 and gate.get_node("WestPillar") != gate.get_node("EastPillar"),"Gateway lost separate pillar bodies")
	var query := PhysicsShapeQueryParameters2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 9
	query.shape = circle
	query.collision_mask = 1
	for y in range(1060,1104,4):
		query.transform = Transform2D(0,Vector2(768,y))
		_check(stage.player.get_world_2d().direct_space_state.intersect_shape(query).is_empty(),"Arrival doorway blocks movement")
	await _capture("arrival.png")
	var encounter: EncounterController = stage.approach_encounter
	encounter.waves = [encounter.waves[0].duplicate(true)]
	encounter.waves[0].spawn_interval = 0.05
	encounter.waves[0].reinforcement_delay = 0.05
	encounter.inter_wave_delay = 0.05
	var spawned := [0]
	var casters := [0]
	var coins_before: int = stage.player.progression_component.coins
	var xp_before: int = stage.player.progression_component.total_experience
	encounter.enemy_spawned.connect(func(_point: Vector2) -> void: spawned[0] += 1)
	encounter.start_encounter()
	await create_timer(0.5).timeout
	_check(encounter._active_enemies == 5,"First guard batch must fill exactly five slots")
	_check(stage.expedition_feedback.view.status.text.contains("/ 6"),"Sentry objective does not include queued enemies")
	stage.player.global_position = Vector2(768,575)
	await physics_frame
	await physics_frame
	_check(not stage._boss_started,"Basin can skip living sentries")
	_check(not stage.expedition_feedback._completed,"Guard encounter completed the boss stage")
	await _capture("sentries.png")
	var deadline := Time.get_ticks_msec()+5000
	var exceeded_cap := false
	while not encounter._completion_spawned and Time.get_ticks_msec() < deadline:
		exceeded_cap = exceeded_cap or encounter._active_enemies > 5
		for actor in actors.get_children():
			if actor == stage.player or actor == stage.boss or actor.get("health_component") == null: continue
			if actor.health_component.current_health <= 0: continue
			if actor is Rotcaller:
				casters[0] += 1
				_check(actor.has_node("EnemyRewardComponent"),"Campaign caster has no reward observer")
			actor.set_physics_process(false)
			var damage := DamageInfo.new(10000,stage.player,Vector2.ZERO)
			damage.ignores_invulnerability = true
			actor.health_component.apply_damage(damage)
		await process_frame
	_check(encounter._completion_spawned and spawned[0] == 6 and casters[0] == 1,"Guard queue lost or duplicated enemies")
	_check(not exceeded_cap,"Guard reinforcement exceeds live cap")
	_check(stage.player.progression_component.coins-coins_before == 7,"Sentries did not grant their real 2 + 5 coins once")
	_check(stage.player.progression_component.total_experience-xp_before == 57,"Sentries did not grant their real 12 + 45 XP once")
	_check(root.get_node("LootService").has_active_expedition() and not stage.stage_completed and not stage.expedition_feedback._completed,"Sentry clear banked/unlocked the entire boss stage")
	_check(stage._boss_started,"Finishing guards inside the basin incorrectly requires leaving/reentering")
	await create_timer(1.8).timeout
	if stage.dialogue_panel.visible: stage.dialogue_panel.close_dialogue(true)
	await process_frame
	_check(stage.boss.target == stage.player and stage.boss.is_physics_processing(),"Boss entrance did not activate ordinary combat")
	_check(not stage.boss.health_component.is_damage_immune,"Boss stays invulnerable after its entrance")
	_check(stage.outdoor_audio._combat,"Boss activation does not duck its outdoor audio")
	await _capture("boss_basin.png")
	_check(FileAccess.get_sha256(save.get_profile_path()) == profile_before,"Test wrote the normal profile")
	stage.queue_free()
	await process_frame
	print("STAGE_5_RENEWAL: ",checks," checks, ",failures," failures")
	quit(1 if failures else 0)

func _capture(name: String) -> void:
	if DisplayServer.get_name() == "headless": return
	root.mode = Window.MODE_WINDOWED
	root.grab_focus()
	await RenderingServer.frame_post_draw
	var directory := "res://tmp/review/environment/stage_5_renewal_2026_10_03/"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory))
	root.get_texture().get_image().save_png(directory+name)

func _check(ok: bool,message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
