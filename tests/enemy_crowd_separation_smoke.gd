extends SceneTree

const ArenaScene = preload("res://levels/test_arena/test_arena.tscn")
const ThrallScene = preload("res://entities/enemies/forsaken_thrall/forsaken_thrall.tscn")
const MirelingScene = preload("res://entities/enemies/mireling/mireling.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var arena := ArenaScene.instantiate()
	arena.get_node("GameplayServices/EncounterController").auto_start = false
	root.add_child(arena)
	var player: Player = arena.get_node("World/Actors/Player")
	var actors: Node2D = arena.get_node("World/Actors")
	player.global_position = Vector2(960, 1000)
	player.set_physics_process(false)
	var enemies: Array[CharacterBody2D] = []
	var scenes: Array[PackedScene] = [ThrallScene, MirelingScene, ThrallScene, MirelingScene]
	for index in range(scenes.size()):
		var enemy := scenes[index].instantiate() as CharacterBody2D
		enemy.target = player
		actors.add_child(enemy)
		enemy.global_position = Vector2(954 + index * 4, 520)
		enemies.append(enemy)
	for frame in range(110): await physics_frame
	var minimum_distance := INF
	var minimum_x := INF
	var maximum_x := -INF
	for first in range(enemies.size()):
		minimum_x = minf(minimum_x, enemies[first].global_position.x)
		maximum_x = maxf(maximum_x, enemies[first].global_position.x)
		for second in range(first + 1, enemies.size()):
			minimum_distance = minf(minimum_distance, enemies[first].global_position.distance_to(enemies[second].global_position))
	if minimum_distance < 9.0:
		_fail("Crowd separation left enemies stacked at %.2f pixels." % minimum_distance)
		return
	if maximum_x - minimum_x < 18.0:
		_fail("Crowd did not develop readable lateral spacing.")
		return
	for enemy in enemies:
		if enemy.global_position.y <= 520.0:
			_fail("Separation prevented an enemy from advancing toward the player.")
			return
	print("Enemy crowd separation smoke test passed. Minimum spacing: %.2f px." % minimum_distance)
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
