extends "res://tests/sanctuary_test_base.gd"

const STAGE := preload("res://levels/stage_4/stage_4.tscn")
const ROOTLING := preload("res://entities/enemies/rootling/rootling.tscn")
const ROTCALLER := preload("res://entities/enemies/rotcaller/rotcaller.tscn")
const EVIDENCE := "res://tmp/review/encounters/arrival_2026_10_03/"
var stage: Node
var encounter: EncounterController
var spawned: Array[Node] = []

func _run() -> void:
	var save := root.get_node("SaveService")
	save.configure_storage_path_for_testing("user://enemy_arrival_smoke.json")
	save.suppress_autosave_for_debug_session()
	root.size = Vector2i(960, 540)
	stage = STAGE.instantiate()
	stage.review_hold_encounter = true
	root.add_child(stage)
	current_scene = stage
	encounter = stage.encounter_controller
	encounter._spawning = true
	encounter._initial_batch_active = true
	stage.player.global_position = Vector2(768, 500)
	stage.player.set_physics_process(false)
	stage.player.get_node("Camera2D").reset_smoothing()
	encounter.enemy_spawned.connect(func(_point: Vector2) -> void:
		for child in encounter.actors.get_children():
			if child != stage.player and child.get("health_component") != null and not child in spawned:
				spawned.append(child)
				child.set_physics_process(false)
	)
	await create_timer(.35).timeout
	check(encounter.max_active_enemies == 8, "Stage IV cap changed")
	check(not encounter._arrival_is_safe(stage.player.global_position,14), "Arrival can overlap King")
	check(not encounter._arrival_is_safe(encounter.portal_spawn_point.global_position,14), "Arrival can overlap the exit/chest space")
	# A real static footprint rejects spawning even on reachable navigation.
	var obstacle := StaticBody2D.new()
	var collision := CollisionShape2D.new()
	collision.shape = CircleShape2D.new()
	collision.shape.radius = 24
	obstacle.add_child(collision)
	encounter.actors.add_child(obstacle)
	obstacle.global_position = Vector2(768, 350)
	await physics_frame
	check(not encounter._arrival_is_safe(obstacle.global_position,14), "Arrival ignores world collision")
	obstacle.queue_free()
	await physics_frame
	encounter._spawn_enemy(ROOTLING)
	check(encounter._active_enemies == 1 and encounter._arrivals.size() == 1, "Warning did not reserve exactly one slot")
	check(spawned.is_empty(), "Attackable enemy exists before its ground warning")
	var pending: Node = encounter._arrivals.keys()[0]
	var effect: SummonEffect = encounter._arrivals[pending].effect
	check(not effect.released, "Warning starts in emergence phase")
	await create_timer(.1).timeout
	if DisplayServer.get_name() != "headless":
		check(encounter._arrival_audio.playing, "Native arrival has no device playback")
	frame_warning(effect.global_position)
	await capture("one_warning.png")
	var sprite := effect.get("sprite") as AnimatedSprite2D
	check(sprite != null, "Campaign still uses procedural arrival instead of shared raster frames")
	var phase: int = sprite.frame
	paused = true
	await create_timer(.4).timeout
	check(spawned.is_empty() and sprite.frame == phase, "Pause advances the warning or materializes an enemy")
	paused = false
	await create_timer(.25).timeout
	check(spawned.size() == 1 and effect.released, "Real enemy did not emerge after its warning")
	if not spawned.is_empty():
		var enemy: Rootling = spawned[0]
		check(enemy.global_position.distance_to(effect.global_position) < .1, "Enemy teleported away from its warning")
		check(enemy.facing_direction.dot((stage.player.global_position-enemy.global_position).normalized()) > .99, "Emerging enemy faces away from King")
		check(enemy.state == Rootling.State.SPAWNING and not enemy.attack_hitbox.monitoring, "Arrival bypasses the actor's existing safe spawn state")
	await create_timer(.22).timeout
	if not spawned.is_empty():
		var body: Sprite2D = spawned[0].get_node("Visual/Body")
		check(body.modulate.a > .95 and body.scale == Vector2.ONE, "Arrival distorts or hides the native enemy silhouette")
	await capture("one_emergence.png")
	await create_timer(.45).timeout
	await capture("one_settled.png")
	await clear_actors()
	for scene in [ROOTLING, ROOTLING, ROTCALLER]: encounter._spawn_enemy(scene)
	check(encounter._active_enemies == 3 and encounter._arrivals.size() == 3, "Three warnings are not accounted as three slots")
	var arrivals: Array = encounter._arrivals.values()
	for a in arrivals.size():
		for b in range(a+1,arrivals.size()):
			check(arrivals[a].point.distance_to(arrivals[b].point) >= arrivals[a].radius+arrivals[b].radius+8, "Concurrent warning footprints overlap")
	check(encounter.effects_parent.get_children().filter(func(n: Node) -> bool: return n is AudioStreamPlayer2D).size() == 1, "Arrival batch stacks audio players")
	check(encounter._arrival_audio.bus == AudioDirector.SFX_BUS and encounter._arrival_audio.stream.get_length() <= .51, "Arrival cue has incorrect routing/duration")
	await create_timer(.45).timeout
	check(spawned.size() == 3, "Three arrivals were lost or duplicated")
	frame_actors()
	await capture("three_emergence.png")
	await clear_actors()
	for index in 8: encounter._spawn_enemy(ROOTLING)
	check(encounter._active_enemies == 8, "Eight warnings do not fill the cap")
	encounter._spawn_enemy(ROOTLING)
	check(encounter._active_enemies == 8 and encounter._pending_enemies.size() == 1, "Ninth arrival bypasses the cap instead of queueing")
	await create_timer(.45).timeout
	check(spawned.size() == 8 and encounter._active_enemies == 8, "Eight-live emergence exceeded or lost its reserved cap")
	frame_actors()
	await capture("eight_emergence.png")
	encounter._pending_enemies.clear()
	await clear_actors()
	# King entering the warned space cancels it; never quietly relocate an arrival.
	encounter._spawn_enemy(ROOTLING)
	pending = encounter._arrivals.keys()[0]
	var point: Vector2 = encounter._arrivals[pending].point
	stage.player.global_position = point
	await create_timer(.4).timeout
	check(spawned.is_empty() and encounter._active_enemies == 0, "Arrival materialized on King after the warning")
	check(encounter._pending_enemies.size() == 1, "Cancelled unsafe arrival lost an authored enemy")
	encounter._pending_enemies.clear()
	stage.player.global_position = Vector2(768,500)
	encounter._spawn_enemy(ROOTLING)
	stage.player.health_component.current_health = 0
	await create_timer(.4).timeout
	check(spawned.is_empty() and encounter._active_enemies == 0 and encounter._arrivals.is_empty(), "An arrival survives King's defeat")
	stage.player.health_component.current_health = stage.player.health_component.maximum_health
	encounter._spawn_enemy(ROOTLING)
	pending = encounter._arrivals.keys()[0]
	stage.queue_free()
	await process_frame
	check(not is_instance_valid(pending), "Leaving the stage leaks an off-tree pending actor")
	await create_timer(.4).timeout
	print("ENEMY_ARRIVAL checks=%d failures=%d" % [checks, failures])
	quit(1 if failures else 0)

func clear_actors() -> void:
	for actor in spawned:
		if is_instance_valid(actor): actor.queue_free()
	spawned.clear()
	await process_frame
	# Eight 70ms presentation steps need 560ms after release, plus a frame margin.
	await create_timer(.65).timeout
	check(encounter._active_enemies == 0, "Removed actors leave reserved slots behind")
	check(encounter.effects_parent.get_children().filter(func(n: Node) -> bool: return n is SummonEffect).is_empty(), "Emergence effect does not clean up")

func capture(name: String) -> void:
	if DisplayServer.get_name() == "headless": return
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(EVIDENCE))
	check(root.get_texture().get_image().save_png(EVIDENCE+name) == OK, "Cannot save native arrival evidence")

func frame_warning(point: Vector2) -> void:
	var camera: Camera2D = stage.player.get_node("Camera2D")
	# Evidence follows the warning, including edge spawns, without moving King.
	camera.limit_left = -100000
	camera.limit_top = -100000
	camera.limit_right = 100000
	camera.limit_bottom = 100000
	camera.position = point-stage.player.global_position
	camera.zoom = Vector2.ONE
	camera.reset_smoothing()

func frame_actors() -> void:
	var point := Vector2.ZERO
	for actor in spawned: point += actor.global_position
	frame_warning(point / maxf(1, spawned.size()))
	stage.player.get_node("Camera2D").zoom = Vector2(.8,.8)
