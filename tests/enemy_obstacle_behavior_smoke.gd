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
	player.global_position = Vector2(1260, 660)
	player.set_physics_process(false)
	var thrall := ThrallScene.instantiate()
	thrall.target = player
	actors.add_child(thrall)
	thrall.global_position = Vector2(1140, 660)
	for frame in range(50): await physics_frame
	if thrall.collision_mask != 1:
		_fail("Thrall can still physically pin the player.")
		return
	if thrall.state != ForsakenThrall.State.CHASE:
		_fail("Thrall attacked through the statue instead of routing around it.")
		return
	if not thrall.velocity.is_zero_approx() and thrall.facing_direction.dot(thrall.velocity.normalized()) < 0.5:
		_fail("Thrall is back-walking instead of facing its navigation steering direction.")
		return
	print("Enemy obstacle behavior smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
