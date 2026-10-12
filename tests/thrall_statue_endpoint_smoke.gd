extends SceneTree

const ArenaScene = preload("res://levels/test_arena/test_arena.tscn")
const ThrallScene = preload("res://entities/enemies/forsaken_thrall/forsaken_thrall.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var arena := ArenaScene.instantiate()
	arena.get_node("GameplayServices/EncounterController").auto_start = false
	root.add_child(arena)
	var player: Player = arena.get_node("World/Actors/Player")
	var actors: Node2D = arena.get_node("World/Actors")
	player.global_position = Vector2(1200, 676)
	player.set_physics_process(false)
	var thrall := ThrallScene.instantiate()
	thrall.target = player
	actors.add_child(thrall)
	thrall.global_position = Vector2(1200, 610)
	var longest_stall := 0
	var current_stall := 0
	for frame in range(240):
		await physics_frame
		if thrall.state == ForsakenThrall.State.CHASE and thrall.global_position.distance_to(player.global_position) > thrall.definition.attack_range:
			if thrall.velocity.length() < 1.0:
				current_stall += 1
				longest_stall = maxi(longest_stall, current_stall)
			else:
				current_stall = 0
	if longest_stall > 45:
		_fail("Thrall stalled behind the statue for %d consecutive frames." % longest_stall)
		return
	if thrall.global_position.distance_to(player.global_position) > thrall.definition.attack_range + 12.0:
		_fail("Thrall never completed its route around the statue.")
		return
	print("Thrall statue endpoint smoke test passed. Longest stall: %d frames." % longest_stall)
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
