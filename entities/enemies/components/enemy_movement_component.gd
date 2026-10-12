class_name EnemyMovementComponent
extends Node

var _slow_ratio := 0.0
var _slow_timer: Timer

func apply_slow(ratio: float, seconds: float) -> void:
	if _slow_timer == null:
		_slow_timer = Timer.new()
		_slow_timer.one_shot = true
		_slow_timer.timeout.connect(func() -> void: _slow_ratio = 0.0)
		add_child(_slow_timer)
	_slow_ratio = maxf(_slow_ratio, clampf(ratio, 0.0, .5))
	_slow_timer.start(maxf(seconds, _slow_timer.time_left))


func calculate_velocity(
	current_velocity: Vector2,
	direction: Vector2,
	max_speed: float,
	acceleration: float,
	delta: float
) -> Vector2:
	var target_velocity := direction.normalized() * max_speed * (1.0 - _slow_ratio) if not direction.is_zero_approx() else Vector2.ZERO
	return current_velocity.move_toward(target_velocity, acceleration * delta)
