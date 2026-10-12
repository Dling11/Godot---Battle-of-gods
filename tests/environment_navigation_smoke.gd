extends SceneTree

const ArenaScene = preload("res://levels/test_arena/test_arena.tscn")
var checks := 0
var failures := 0
var _path_radius := 4.0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	var stage_2 := "--stage-2" in OS.get_cmdline_user_args()
	var stage_3 := "--stage-3" in OS.get_cmdline_user_args()
	var stage_4 := "--stage-4" in OS.get_cmdline_user_args()
	if stage_4: _path_radius = 9.0
	var compact := stage_2 or stage_3 or stage_4
	var scene_path := "res://levels/stage_4/stage_4.tscn" if stage_4 else ("res://levels/stage_3/stage_3.tscn" if stage_3 else "res://levels/stage_2/stage_2.tscn")
	var arena: Node = load(scene_path).instantiate() if compact else ArenaScene.instantiate()
	if compact: arena.review_hold_encounter = true
	arena.encounter_controller.auto_start = false
	root.add_child(arena)
	current_scene = arena
	var player: Player = arena.player
	player.set_physics_process(false)
	var ground: TileMapLayer = arena.get_node("World/Level/Ground")
	var actors: Node2D = arena.get_node("World/Actors")
	for frame in 4: await physics_frame
	_check(ground.get_used_cells().size() == (1344 if compact else 2160) and ground.tile_set.tile_size == Vector2i(32,32),"Renewed stage must bake the finer 32px grid")
	_check(ground.get_used_rect().size*ground.tile_set.tile_size == (Vector2i(1536,896) if compact else Vector2i(1920,1152)),"Terrain density changed the playable map extent")
	_check(ground.layout != null and ground.layout.map_size == (Vector2i(48,28) if compact else Vector2i(60,36)),"Baked terrain lost its authored layout")
	_check(actors.y_sort_enabled,"Props and King no longer share floor-depth sorting")
	_check(arena.encounter_controller.waves.size() == (5 if stage_4 else (2 if stage_3 else (7 if stage_2 else 6))) and arena.encounter_controller.max_active_enemies == (8 if stage_4 else (5 if stage_3 else (6 if stage_2 else 4))),"Environment changed the combat baseline")
	var map := player.get_world_2d().get_navigation_map()
	var space := player.get_world_2d().direct_space_state
	var origin := player.global_position
	var deadline := Time.get_ticks_msec()+2000
	var exit: Vector2 = arena.get_node("SpawnPoints/StageExit").global_position
	while NavigationServer2D.map_get_path(map,origin,exit,true).is_empty() and Time.get_ticks_msec() < deadline:
		await physics_frame
	_check(NavigationServer2D.map_get_iteration_id(map) > 0,"Navigation map never synchronized")
	for target: Node2D in arena.get_node("SpawnPoints").get_children():
		_check(not _blocked(space,target.global_position,7),"Spawn/exit blocked: "+str(target.name))
		var path := NavigationServer2D.map_get_path(map,origin,target.global_position,true)
		_check(path.size() >= 2 and path[-1].distance_to(target.global_position) < 10,"Disconnected spawn/exit: "+str(target.name))
		_check(_path_is_clear(space,path),"Navigation path crosses a physical obstacle: "+str(target.name))
	for prop: Node in actors.find_children("*","StaticBody2D",true,false):
		if not prop is StaticBody2D: continue
		var footprint := prop.get_node_or_null("Footprint") as CollisionShape2D
		if footprint == null:
			_check(prop.collision_layer == 0,"Decorative ground plants unexpectedly block movement")
		else:
			_check(_blocked(space,footprint.global_position,1),"Visible obstacle has no physical footprint: "+str(prop.name))
			var nearest := NavigationServer2D.map_get_closest_point(map,footprint.global_position)
			_check(nearest.distance_to(footprint.global_position) > 6,"Obstacle is missing its navigation cutout: "+str(prop.name))
	var tree: StaticBody2D = actors.get_node("EntryTreeWest" if stage_4 else ("BlightedTreeSouthWest" if stage_3 else ("EntryTreeWest" if stage_2 else "AncientTreeSouthWest")))
	var tree_position := tree.global_position
	var tree_path := NavigationServer2D.map_get_path(map,tree_position+Vector2(0,-60),tree_position+Vector2(0,60),true)
	_check(tree_path.size() >= 3 and _path_is_clear(space,tree_path),"Route does not skirt the compact tree footprint")
	player.global_position = tree_position+Vector2(0,-50)
	await create_timer(.35).timeout
	_check(tree.get_node("Sprite").modulate.a < .6,"Tree conceals King behind its canopy")
	_check(tree.global_position == tree_position,"Canopy presentation moves physical roots")
	player.global_position = tree_position+Vector2(0,50)
	await create_timer(.35).timeout
	_check(tree.get_node("Sprite").modulate.a > .95,"Tree opacity is not restored on exit")
	var birds: Node = arena.get_node("World/GroveAmbience/GroveBirds")
	await create_timer(1.5).timeout
	var first: AnimatedSprite2D = birds.birds[0]
	var previous := first.position
	await create_timer(.35).timeout
	_check(first.visible and first.is_playing() and first.position.distance_to(previous) > 1,"Ambient bird flight is static")
	_check(first.sprite_frames.get_frame_count(&"fly") == 4,"Bird has no actual wing animation")
	_check(root.get_node("SaveService").is_autosave_suppressed_for_debug(),"Environment review touched normal saving")
	if stage_4:
		var gate: Node2D = actors.get_node("EastRuin")
		var path := NavigationServer2D.map_get_path(map,gate.global_position+Vector2(0,-56),gate.global_position+Vector2(0,56),true)
		_check(path.size() >= 2 and _path_is_clear(space,path),"Gateway opening is not walkable")
		_check(not _blocked(space,gate.global_position,9),"Portal center blocks Hog-sized feet")
		_check(arena.get_node("World/NavigationRegion2D").navigation_agent_radius == 12,"Stage IV does not bake Hog clearance")
	print("STAGE_%d_ENVIRONMENT: " % (4 if stage_4 else (3 if stage_3 else (2 if stage_2 else 1))),checks," checks, ",failures," failures")
	quit(1 if failures else 0)

func _blocked(space: PhysicsDirectSpaceState2D,point: Vector2,radius: float) -> bool:
	var shape := CircleShape2D.new()
	shape.radius = radius
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.transform = Transform2D(0,point)
	query.collision_mask = 1
	query.collide_with_areas = false
	return not space.intersect_shape(query,1).is_empty()

func _path_is_clear(space: PhysicsDirectSpaceState2D,path: PackedVector2Array) -> bool:
	for index in path.size()-1:
		var steps := maxi(1,ceili(path[index].distance_to(path[index+1])/8.0))
		for step in steps+1:
			if _blocked(space,path[index].lerp(path[index+1],float(step)/steps),_path_radius): return false
	return true

func _check(ok: bool,message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
