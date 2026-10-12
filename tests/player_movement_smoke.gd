extends SceneTree

const PlayerScene = preload("res://entities/player/player.tscn")


func _initialize() -> void:
	var player := PlayerScene.instantiate()
	root.add_child(player)

	var movement_component = player.get_node("MovementComponent")
	var accelerated: Vector2 = movement_component.calculate_velocity(
		Vector2.ZERO,
		Vector2.RIGHT,
		1.0
	)
	_assert_near(accelerated.length(), movement_component.max_speed, "maximum speed")

	var diagonal: Vector2 = movement_component.calculate_velocity(
		Vector2.ZERO,
		Vector2(1.0, 1.0),
		1.0
	)
	_assert_near(diagonal.length(), movement_component.max_speed, "diagonal speed")

	var stopped: Vector2 = movement_component.calculate_velocity(
		Vector2.RIGHT * movement_component.max_speed,
		Vector2.ZERO,
		1.0
	)
	_assert_near(stopped.length(), 0.0, "deceleration")

	player.queue_free()
	print("Player movement smoke test passed.")
	quit(0)


func _assert_near(actual: float, expected: float, label: String) -> void:
	if not is_equal_approx(actual, expected):
		push_error("Expected %s %s, received %s." % [label, expected, actual])
		quit(1)

