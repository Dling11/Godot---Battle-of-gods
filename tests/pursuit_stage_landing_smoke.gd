extends SceneTree

const LANDING = preload("res://gameplay/abilities/king/pursuit_landing.gd")
const ROOM = preload("res://levels/sanctuary/town/workshop_interior.gd")
var failures := 0
var checks := 0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	root.get_node("SaveService").configure_storage_path_for_testing("user://pursuit_stage_landing_smoke.json")
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	root.get_node("RunSession").reset_run()
	for scene_path: String in ["res://levels/stage_4/stage_4.tscn", "res://levels/sanctuary/sanctuary.tscn"]:
		var scene: Node = load(scene_path).instantiate()
		if scene_path.contains("stage_4"): scene.review_hold_encounter = true
		root.add_child(scene)
		current_scene = scene
		await create_timer(.7).timeout
		if scene.has_method("clear_simulation"): scene.clear_simulation()
		var actor: Player = scene.player
		actor.set_physics_process(false)
		var map := actor.get_world_2d().get_navigation_map()
		var outdoors := scene_path.contains("sanctuary")
		var active_regions := 0
		for region in NavigationServer2D.map_get_regions(map):
			if NavigationServer2D.region_get_enabled(region): active_regions += 1
		if outdoors:
			check(not NavigationServer2D.map_get_regions(map).is_empty(), "Workshop navigation fixture missing")
			check(active_regions == 0, "Outdoor workshop navigation should be disabled")
		var misses := 0
		for x in range(int(actor.movement_bounds.position.x)+20, int(actor.movement_bounds.end.x)-20, 20):
			for y in range(int(actor.movement_bounds.position.y)+20, int(actor.movement_bounds.end.y)-20, 20):
				var point := Vector2(x,y)
				var physical := actor.get_world_2d().direct_space_state.intersect_shape(LANDING.query_for(actor,point),1).is_empty()
				if physical and not LANDING.is_clear(actor,point):
					misses += 1
					if misses <= 6: print("PURSUIT_NAV_REJECT ",scene_path," point=",point," nav_distance=",point.distance_to(NavigationServer2D.map_get_closest_point(map,point)))
		print("PURSUIT_STAGE_AUDIT ",scene_path," physically_clear_nav_rejected=",misses)
		if outdoors: check(misses == 0, "Disabled workshop navigation rejects clear outdoor ground")
		var jump := actor.ability_3_component as SovereignPursuitComponent
		var origin := Vector2(520,480) if scene_path.contains("stage_4") else actor.global_position
		for direction in [Vector2.RIGHT,Vector2.LEFT,Vector2.UP,Vector2.DOWN]:
			actor.global_position = origin
			actor.velocity = Vector2.ZERO
			jump.clear_cooldown()
			var requested: Vector2 = origin+direction*(24.0 if outdoors and direction == Vector2.DOWN else 180.0)
			var target := jump.resolve_ground_target(requested)
			if outdoors:
				check(LANDING.is_clear(actor, requested), "Outdoor requested landing should be clear")
				check(target.distance_to(requested)<1.0, "Outdoor clear landing lost its requested reach")
			actor.set_physics_process(true)
			check(jump.request_cast_at(requested,10.0),"Real-scene jump refused")
			for tick in 120:
				await physics_frame
				await process_frame
				if not jump.is_casting(): break
			print("PURSUIT_STAGE_JUMP ",scene_path," origin=",origin," requested=",requested," resolved=",target," landed=",actor.global_position)
			check(actor.global_position.distance_to(target)<3.0,"Real-scene jump missed its resolved landing")
			check(actor.get_collision_mask_value(1),"World collision not restored")
			actor.set_physics_process(false)
		if outdoors:
			var room := scene.find_child("OrrenWorkshopInterior", true, false) as Node2D
			check(room != null, "Actual workshop room missing")
			if room != null:
				var outdoor_bounds := actor.movement_bounds
				room.set_active(true)
				actor.movement_bounds = Rect2(room.global_position+ROOM.FLOOR.position, ROOM.FLOOR.size)
				actor.global_position = room.global_position+ROOM.SPAWN
				await physics_frame
				await process_frame
				await physics_frame
				check(NavigationServer2D.region_get_enabled(room.navigation.get_rid()), "Workshop navigation did not enable")
				var landing := room.global_position+Vector2(200,150)
				var off_floor := room.global_position+Vector2(240,220)
				check(LANDING.is_clear(actor, landing), "Active workshop rejects clear floor")
				check(actor.get_world_2d().direct_space_state.intersect_shape(LANDING.query_for(actor, off_floor),1).is_empty(), "Off-floor navigation probe is physically blocked")
				check(not LANDING.is_clear(actor, off_floor), "Enabled workshop navigation permits absent ground")
				check(not LANDING.is_clear(actor, room.global_position+Vector2(240,114)), "Workshop furniture landing permitted")
				jump.clear_cooldown()
				actor.set_physics_process(true)
				check(jump.request_cast_at(landing,10.0), "Workshop jump refused")
				for tick in 120:
					await physics_frame
					await process_frame
					if not jump.is_casting(): break
				check(actor.global_position.distance_to(landing)<3.0, "Workshop jump missed clear floor")
				check(actor.get_collision_mask_value(1), "Workshop jump did not restore collision")
				actor.set_physics_process(false)
				room.set_active(false)
				actor.movement_bounds = outdoor_bounds
				actor.global_position = origin
				await physics_frame
				await process_frame
				await physics_frame
				check(LANDING.is_clear(actor, origin+Vector2.RIGHT*180.0), "Workshop departure breaks outdoor landing again")
		scene.queue_free()
		current_scene = null
		await process_frame
		await physics_frame
	print("PURSUIT_STAGE_LANDING checks=%d failures=%d" % [checks,failures])
	quit(1 if failures else 0)

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
