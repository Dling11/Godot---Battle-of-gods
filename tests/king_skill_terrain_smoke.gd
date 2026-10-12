extends SceneTree

const PLAYER = preload("res://entities/player/player.tscn")
const TARGET = preload("res://entities/training/training_target.tscn")
const LANDING = preload("res://gameplay/abilities/king/pursuit_landing.gd")
var checks := 0
var failures := 0
var world: Node2D
var actor: Player

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	root.get_node("SaveService").configure_storage_path_for_testing("user://king_skill_terrain_smoke.json")
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	root.get_node("RunSession").reset_run()
	world = Node2D.new()
	root.add_child(world)
	actor = PLAYER.instantiate() as Player
	world.add_child(actor)
	actor.movement_bounds = Rect2(40,40,840,450)
	actor.global_position = Vector2(260,300)
	actor.set_physics_process(false)
	var obstacle := barrier(Vector2(355,300),Vector2(20,100))
	var behind := target_at(Vector2(410,300))
	var outside := target_at(Vector2(475,300))
	await settle()
	var wave := actor.ability_1_component as EarthsplitterComponent
	var preview := wave.get_target_lane_preview(Vector2(700,300))
	check(is_equal_approx(preview.end.x,424.0) and not preview.blocked, "Skill 1 preview shortened at scenery")
	check(wave.request_cast_at(Vector2(700,300),10.0), "Skill 1 refused cast")
	await create_timer(.9).timeout
	check(health(behind) < 10000.0, "Travelling Skill 1 failed to hit behind obstacle")
	check(health(outside) == 10000.0, "Skill 1 terrain correction increased authored reach")
	for form in [EarthsplitterDefinition.Form.FAN, EarthsplitterDefinition.Form.CASCADE]:
		wave.definition = wave.definition.duplicate(true)
		wave.definition.configure_form(form)
		preview = wave.get_target_lane_preview(Vector2(700,300))
		check(is_equal_approx(preview.end.x,488.0), "Trained Skill 1 lost full reach")
	# Worldsplitter aims beyond the first barrier and hits across a second barrier
	# within its circle, while an outside foot remains excluded.
	behind.position = Vector2(495,300)
	outside.position = Vector2(570,300)
	var blast_obstacle := barrier(Vector2(475,300),Vector2(8,100))
	var blast := actor.ability_4_component as KingSkill4Component
	check(blast.resolve_ground_target(Vector2(450,300)) == Vector2(450,300), "Skill 5 aim was clipped by terrain")
	check(blast.resolve_ground_target(Vector2(999,300)).distance_to(actor.global_position) <= blast.get_target_range_pixels()+.01, "Skill 5 exceeded authored cast range")
	reset_health(behind)
	await settle()
	check(blast.request_cast_at(Vector2(450,300),10.0), "Skill 5 refused cast")
	await create_timer(1.7).timeout
	check(health(behind) < 10000.0, "Skill 5 blast terrain LOS suppressed an inside target")
	check(health(outside) == 10000.0, "Skill 5 hit an outside foot")
	blast_obstacle.queue_free()
	# The basic sword already uses its physical fan without scenery LOS.
	behind.position = Vector2(288,300)
	reset_health(behind)
	var sword_obstacle := barrier(Vector2(274,300),Vector2(3,100))
	await settle()
	check(actor.attack_component.request_attack(Vector2.RIGHT), "Basic sword refused cast")
	await create_timer(.75).timeout
	check(health(behind) < 10000.0, "Basic sword lost reach across nearby scenery")
	sword_obstacle.queue_free()
	behind.position = Vector2(800,100)
	outside.position = Vector2(800,180)
	# Actual movement over a tree-width prop and a solid wall, not a teleport mock.
	var wall := barrier(Vector2(410,300),Vector2(18,120))
	await settle()
	var jump := actor.ability_3_component as SovereignPursuitComponent
	check(jump.resolve_ground_target(Vector2(480,300)).is_equal_approx(Vector2(480,300)), "Clear landing beyond world obstacles was shortened")
	actor.set_physics_process(true)
	check(jump.request_cast_at(Vector2(480,300),10.0), "Pursuit refused clear far landing")
	var crossed := false
	var paused_once := false
	for tick in 100:
		await physics_frame
		await process_frame
		crossed = crossed or actor.global_position.x > wall.global_position.x+20
		if jump.phase == AbilityComponent.Phase.ACTIVE and not paused_once:
			paused_once = true
			var saved_point := actor.global_position
			paused = true
			await create_timer(.08,true).timeout
			check(actor.global_position == saved_point, "Pursuit moved during pause")
			paused = false
		if not jump.is_casting(): break
	check(crossed and actor.global_position.distance_to(Vector2(480,300)) < 3.0, "Pursuit did not travel over the wall to its clear landing")
	check(actor.get_collision_mask_value(1) and not jump._jump_in_progress, "Pursuit did not restore walking collision")
	check(LANDING.is_clear(actor, actor.global_position), "Pursuit landed inside scenery")
	actor.set_physics_process(false)
	for rank in [SovereignPursuitDefinition.Rank.ADVANCED,SovereignPursuitDefinition.Rank.MATURE]:
		actor.position = Vector2(260,300)
		jump.apply_rank(rank)
		jump.clear_cooldown()
		actor.set_physics_process(true)
		var destination := actor.position+Vector2.RIGHT*jump.get_target_range_pixels()
		check(jump.request_cast_at(destination,10.0), "Trained max-range jump was refused")
		for tick in 100:
			await physics_frame
			await process_frame
			if not jump.is_casting(): break
		check(actor.position.distance_to(destination)<3.0 and actor.get_collision_mask_value(1), "Trained jump lost range or collision restoration")
		actor.set_physics_process(false)
	actor.position = Vector2(260,300)
	var resolved := jump.resolve_ground_target(obstacle.global_position)
	check(resolved.x > actor.position.x and resolved.x < obstacle.position.x and LANDING.is_clear(actor,resolved), "Blocked destination did not choose a safe shorter landing")
	check(jump.resolve_ground_target(Vector2(-999,300)).x >= actor.movement_bounds.position.x, "Pursuit escaped playable bounds")
	# Cancel mid-flight inside the prop: reset to safe feet and restore mask.
	jump.clear_cooldown()
	check(jump.request_cast_at(Vector2(480,300),10.0), "Cancel fixture cast refused")
	jump._advance_phase()
	actor.global_position = obstacle.global_position
	jump.cancel_cast()
	check(actor.get_collision_mask_value(1) and LANDING.is_clear(actor,actor.global_position), "Mid-flight cancellation left King embedded or without collision")
	# Preview and commit share the physical feet despite the marker's -16px node.
	var aim := actor.ground_point_targeting
	blast.clear_cooldown()
	check(aim.begin_targeting(blast,Vector2.RIGHT), "AOE targeting did not begin")
	aim.update_aim(Vector2(450,300),Vector2.ZERO)
	check(aim._aim_origin() == actor.global_position and aim._aim_origin()+aim._target_local == Vector2(450,300), "AOE preview origin differs from committed ground point")
	check(aim.is_processing(), "Active aiming does not update at render frame rate")
	aim.cancel_targeting()
	check(not aim.is_processing() and not root.get_node("CursorService").targeting_active, "Inactive aiming kept frame work/cursor state")
	# Clear air is not a landing surface when the scene supplies authored ground.
	var region := NavigationRegion2D.new()
	var navigation := NavigationPolygon.new()
	navigation.vertices = PackedVector2Array([Vector2(40,40),Vector2(320,40),Vector2(320,490),Vector2(40,490)])
	navigation.add_polygon(PackedInt32Array([0,1,2,3]))
	region.navigation_polygon = navigation
	world.add_child(region)
	await settle()
	check(not LANDING.is_clear(actor, Vector2(480,300)), "Pursuit treats empty space outside authored ground as a landing")
	check(jump.resolve_ground_target(Vector2(480,300)).x <= 320, "Pursuit can land beyond the navigation ground")
	world.queue_free()
	await process_frame
	print("KING_SKILL_TERRAIN checks=%d failures=%d" % [checks,failures])
	quit(1 if failures else 0)

func barrier(point: Vector2, size: Vector2) -> StaticBody2D:
	var body := StaticBody2D.new()
	var shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = size
	shape.shape = rectangle
	body.add_child(shape)
	body.position = point
	world.add_child(body)
	return body

func target_at(point: Vector2) -> Node2D:
	var target := TARGET.instantiate() as StaticBody2D
	target.collision_layer = 0
	target.position = point
	world.add_child(target)
	reset_health(target)
	return target

func reset_health(target: Node2D) -> void:
	var hp := target.get_node("HealthComponent") as HealthComponent
	hp.set_maximum_health(10000.0,false)
	hp.set_current_health(10000.0)

func health(target: Node2D) -> float:
	return (target.get_node("HealthComponent") as HealthComponent).current_health

func settle() -> void:
	await physics_frame
	await physics_frame
	await process_frame

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
