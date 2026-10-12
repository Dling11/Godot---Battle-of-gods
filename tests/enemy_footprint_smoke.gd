extends SceneTree

const ENEMY_SCENES: Array[PackedScene] = [
	preload("res://entities/enemies/rootling/rootling.tscn"),
	preload("res://entities/enemies/mireling/mireling.tscn"),
	preload("res://entities/enemies/forsaken_thrall/forsaken_thrall.tscn"),
	preload("res://entities/enemies/bramble_spitter/bramble_spitter.tscn"),
	preload("res://entities/enemies/rootbound_husk/rootbound_husk.tscn"),
]


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var actors := Node2D.new()
	root.add_child(actors)
	var target := CharacterBody2D.new()
	actors.add_child(target)

	var enemies: Array[CharacterBody2D] = []
	for scene: PackedScene in ENEMY_SCENES:
		var enemy := scene.instantiate() as CharacterBody2D
		enemy.set("target", target)
		actors.add_child(enemy)
		enemy.set_physics_process(false)
		enemies.append(enemy)
	await process_frame

	for enemy: CharacterBody2D in enemies:
		var definition := enemy.get("definition") as EnemyDefinition
		var body_collision := enemy.get_node("BodyCollision") as CollisionShape2D
		var navigation_agent := enemy.get_node("NavigationAgent2D") as NavigationAgent2D
		if definition == null or body_collision == null or navigation_agent == null:
			_fail("Enemy is missing its footprint dependencies: %s" % enemy.name)
			return
		if not body_collision.shape is CircleShape2D:
			_fail("Enemy movement footprint is not circular: %s" % enemy.name)
			return
		var physical_radius := (body_collision.shape as CircleShape2D).radius
		if (
			not is_equal_approx(physical_radius, definition.movement_footprint_radius)
			or not is_equal_approx(
				navigation_agent.radius, definition.movement_footprint_radius
			)
		):
			_fail("Enemy movement and navigation footprints diverged: %s" % enemy.name)
			return

		var separation := enemy.get_node_or_null("EnemySeparationComponent") as EnemySeparationComponent
		if separation == null:
			if enemy.name != "RootboundHusk":
				_fail("Ordinary enemy lost crowd separation: %s" % enemy.name)
				return
			continue
		var detection := separation.get_node("DetectionShape") as CollisionShape2D
		if (
			not is_equal_approx(separation.separation_radius, definition.crowd_separation_radius)
			or not detection.shape is CircleShape2D
			or not is_equal_approx(
				(detection.shape as CircleShape2D).radius,
				definition.crowd_separation_radius
			)
		):
			_fail("Enemy crowd-separation radius diverged from its definition: %s" % enemy.name)
			return

	print("Enemy footprint smoke test passed for five archetypes.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
