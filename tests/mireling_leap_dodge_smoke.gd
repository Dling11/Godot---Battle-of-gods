extends SceneTree

const PlayerScene = preload("res://entities/player/player.tscn")
const MirelingScene = preload("res://entities/enemies/mireling/mireling.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var player := PlayerScene.instantiate()
	var mireling := MirelingScene.instantiate()
	mireling.target = player
	var target_lock := {"value": false}
	mireling.leap_targeted.connect(func(_position: Vector2, _duration: float) -> void:
		target_lock.value = true
		player.global_position = Vector2(200, 330)
	)
	root.add_child(player)
	root.add_child(mireling)
	player.global_position = Vector2(200, 200)
	mireling.global_position = Vector2(280, 200)
	player.set_physics_process(false)
	var health: HealthComponent = player.get_node("HealthComponent")
	for frame in range(120): await physics_frame
	if not target_lock.value:
		_fail("Mireling never telegraphed a snapshot landing target.")
		return
	if health.current_health < health.maximum_health:
		_fail("Mireling leap followed the player instead of missing the old position.")
		return
	print("Mireling leap dodge smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
