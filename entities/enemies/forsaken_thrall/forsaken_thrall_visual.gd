extends Node2D

@export var body_visual: AnimatedSprite2D
@export var attack_marker: Polygon2D
@export var spawn_shadow: Polygon2D

var _state_tween: Tween
var _phase_tween: Tween


func set_facing_direction(direction: Vector2) -> void:
	if body_visual == null:
		return
	var direction_name := _direction_name(direction)
	var prefix := body_visual.animation.get_slice("_", 0)
	body_visual.play(prefix + "_" + direction_name)


func play_state(state: ForsakenThrall.State, duration_seconds: float) -> void:
	if body_visual == null or attack_marker == null:
		return
	if _state_tween != null and _state_tween.is_valid():
		_state_tween.kill()
	if _phase_tween != null and _phase_tween.is_valid():
		_phase_tween.kill()
	body_visual.position = Vector2(0, -16)
	body_visual.rotation = 0.0
	match state:
		ForsakenThrall.State.SPAWNING:
			attack_marker.modulate.a = 0.0
			body_visual.play("idle_down")
			body_visual.modulate = Color(0.32, 0.42, 0.34, 0.0)
			body_visual.position = Vector2(0, -8)
			body_visual.scale = Vector2(0.82, 0.82)
			if spawn_shadow != null:
				spawn_shadow.scale = Vector2(0.2, 0.2)
				spawn_shadow.modulate.a = 0.0
			_state_tween = create_tween().set_parallel(true)
			_state_tween.tween_property(body_visual, "modulate", Color.WHITE, duration_seconds)
			_state_tween.tween_property(body_visual, "position", Vector2(0, -16), duration_seconds).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			_state_tween.tween_property(body_visual, "scale", Vector2.ONE, duration_seconds).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			if spawn_shadow != null:
				_state_tween.tween_property(spawn_shadow, "scale", Vector2.ONE, duration_seconds * 0.7).set_trans(Tween.TRANS_QUAD)
				_state_tween.tween_property(spawn_shadow, "modulate:a", 1.0, duration_seconds * 0.7)
		ForsakenThrall.State.CHASE:
			body_visual.scale = Vector2.ONE
			body_visual.modulate = Color.WHITE
			attack_marker.modulate.a = 0.0
			_play_with_prefix("walk")
		ForsakenThrall.State.WIND_UP:
			_play_attack_pair(0, duration_seconds)
			attack_marker.modulate = Color(1.0, 0.34, 0.2, 0.08)
			_state_tween = create_tween()
			_state_tween.tween_property(attack_marker, "modulate:a", 0.28, duration_seconds)
		ForsakenThrall.State.ACTIVE:
			_play_attack_pair(2, duration_seconds)
			body_visual.modulate = Color(1.18, 0.88, 0.82, 1.0)
			attack_marker.modulate.a = 0.0
		ForsakenThrall.State.RECOVERY:
			attack_marker.modulate.a = 0.0
			_play_attack_pair(4, duration_seconds)
			var tween := create_tween()
			tween.tween_property(body_visual, "modulate", Color.WHITE, duration_seconds)
		ForsakenThrall.State.STAGGER:
			attack_marker.modulate.a = 0.0
			_play_with_prefix("idle")
			body_visual.scale = Vector2(1.12, 0.84)
			body_visual.modulate = Color(1.0, 0.86, 0.58, 1.0)
		ForsakenThrall.State.DEAD:
			attack_marker.modulate.a = 0.0
			_play_with_prefix("dead")
			var tween := create_tween()
			tween.tween_property(body_visual, "modulate:a", 0.0, duration_seconds)


func _play_with_prefix(prefix: String) -> void:
	var current_direction := body_visual.animation.get_slice("_", 1)
	if current_direction.is_empty():
		current_direction = "down"
	body_visual.play(prefix + "_" + current_direction)


func _play_attack_pair(first_frame: int, duration_seconds: float) -> void:
	var direction := body_visual.animation.get_slice("_", 1)
	if direction.is_empty():
		direction = "down"
	body_visual.animation = "attack_" + direction
	body_visual.pause()
	body_visual.frame = first_frame
	_phase_tween = create_tween()
	_phase_tween.tween_interval(duration_seconds * 0.5)
	_phase_tween.tween_callback(func() -> void: body_visual.frame = first_frame + 1)


func _direction_name(direction: Vector2) -> String:
	if absf(direction.x) > absf(direction.y):
		return "right" if direction.x > 0.0 else "left"
	return "down" if direction.y > 0.0 else "up"


func facing_basis() -> Vector2:
	match body_visual.animation.get_slice("_", 1):
		"left": return Vector2.LEFT
		"right": return Vector2.RIGHT
		"up": return Vector2.UP
	return Vector2.DOWN
