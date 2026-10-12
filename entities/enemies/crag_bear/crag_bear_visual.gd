extends Node2D

@export var body: AnimatedSprite2D
@export var basic_marker: Polygon2D
@export var ground_slam_marker: Polygon2D
@export var spawn_shadow: Polygon2D

var _direction := "down"
var _state := CragBear.State.SPAWNING
var _state_tween: Tween
var _frame_tween: Tween
var _hurt_return_pending := false


func set_facing_direction(direction: Vector2) -> void:
	_direction = _direction_name(direction)
	_restore_state_animation()


func play_state(state: CragBear.State, duration_seconds: float) -> void:
	_state = state
	_kill_tweens()
	body.position = Vector2(0, -22)
	body.scale = Vector2.ONE
	body.modulate = Color.WHITE
	basic_marker.modulate.a = 0.0
	ground_slam_marker.modulate.a = 0.0
	match state:
		CragBear.State.SPAWNING:
			body.play("idle_down")
			body.modulate = Color(0.34, 0.44, 0.38, 0.0)
			body.scale = Vector2(0.82, 0.82)
			if spawn_shadow != null:
				spawn_shadow.scale = Vector2(0.2, 0.2)
				spawn_shadow.modulate.a = 0.0
			_state_tween = create_tween().set_parallel(true)
			_state_tween.tween_property(body, "modulate", Color.WHITE, duration_seconds)
			_state_tween.tween_property(body, "scale", Vector2.ONE, duration_seconds).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			if spawn_shadow != null:
				_state_tween.tween_property(spawn_shadow, "scale", Vector2.ONE, duration_seconds * 0.7)
				_state_tween.tween_property(spawn_shadow, "modulate:a", 1.0, duration_seconds * 0.7)
		CragBear.State.CHASE:
			body.play("walk_" + _direction)
		CragBear.State.BASIC_WIND_UP:
			body.position = Vector2(0, -30)
			_play_frame_span("attack_", 0, 5, duration_seconds)
			basic_marker.modulate = Color(1.0, 0.36, 0.2, 0.08)
			_state_tween = create_tween()
			_state_tween.tween_property(basic_marker, "modulate:a", 0.3, duration_seconds)
		CragBear.State.BASIC_ACTIVE:
			body.position = Vector2(0, -30)
			_play_frame_span("attack_", 5, 1, duration_seconds)
			body.modulate = Color(1.14, 0.9, 0.84, 1.0)
		CragBear.State.BASIC_RECOVERY:
			body.position = Vector2(0, -30)
			_play_frame_span("attack_", 6, 2, duration_seconds)
		CragBear.State.SLAM_WIND_UP:
			body.position = Vector2(0, -38)
			_play_frame_span("slam_", 0, 5, duration_seconds)
			ground_slam_marker.modulate = Color(1.0, 0.29, 0.16, 0.1)
			_state_tween = create_tween()
			_state_tween.tween_property(
				ground_slam_marker, "modulate:a", 0.42, duration_seconds
			)
		CragBear.State.SLAM_ACTIVE:
			body.position = Vector2(0, -38)
			_play_frame_span("slam_", 5, 1, duration_seconds)
			body.modulate = Color(1.2, 0.86, 0.74, 1.0)
		CragBear.State.SLAM_RECOVERY:
			body.position = Vector2(0, -38)
			_play_frame_span("slam_", 6, 2, duration_seconds)
		CragBear.State.STAGGER:
			body.play("idle_" + _direction)
			body.scale = Vector2(1.08, 0.9)
			body.modulate = Color(1.0, 0.82, 0.56, 1.0)
		CragBear.State.DEAD:
			body.play("dead_" + _direction)
			_state_tween = create_tween()
			_state_tween.tween_interval(maxf(duration_seconds - 0.2, 0.1))
			_state_tween.tween_property(body, "modulate:a", 0.0, 0.2)


func play_hurt(_info: DamageInfo) -> void:
	if _state == CragBear.State.DEAD:
		return
	body.position = Vector2(0, -22)
	body.play("hurt_" + _direction)
	if not _hurt_return_pending:
		_hurt_return_pending = true
		body.animation_finished.connect(_on_hurt_finished, CONNECT_ONE_SHOT)


func _on_hurt_finished() -> void:
	_hurt_return_pending = false
	_restore_state_animation()


func _play_frame_span(
	prefix: String, first_frame: int, frame_count: int, duration_seconds: float
) -> void:
	body.animation = prefix + _direction
	body.pause()
	body.frame = first_frame
	if frame_count <= 1:
		return
	_frame_tween = create_tween()
	var frame_seconds := duration_seconds / float(frame_count)
	for offset in range(1, frame_count):
		_frame_tween.tween_interval(frame_seconds)
		_frame_tween.tween_callback(body.set_frame.bind(first_frame + offset))


func _restore_state_animation() -> void:
	body.position = Vector2(0, -22)
	match _state:
		CragBear.State.CHASE:
			body.play("walk_" + _direction)
		CragBear.State.BASIC_WIND_UP, CragBear.State.BASIC_ACTIVE, CragBear.State.BASIC_RECOVERY:
			body.position = Vector2(0, -30)
			body.play("attack_" + _direction)
		CragBear.State.SLAM_WIND_UP, CragBear.State.SLAM_ACTIVE, CragBear.State.SLAM_RECOVERY:
			body.position = Vector2(0, -38)
			body.play("slam_" + _direction)
		CragBear.State.DEAD:
			body.play("dead_" + _direction)
		_:
			body.play("idle_" + _direction)


func _kill_tweens() -> void:
	if _state_tween != null and _state_tween.is_valid():
		_state_tween.kill()
	if _frame_tween != null and _frame_tween.is_valid():
		_frame_tween.kill()


func _direction_name(direction: Vector2) -> String:
	if absf(direction.x) > absf(direction.y):
		return "right" if direction.x > 0.0 else "left"
	return "down" if direction.y > 0.0 else "up"
