extends Node2D

@export var body: AnimatedSprite2D
@export var warning_lane: Polygon2D
@export var spawn_shadow: Polygon2D

var _direction := "down"
var _state := ArmoredHog.State.SPAWNING
var _tween: Tween
var _hurt_return_pending := false


func set_facing_direction(direction: Vector2) -> void:
	_direction = _direction_name(direction)
	_restore_state_animation()


func play_state(state: ArmoredHog.State, duration_seconds: float) -> void:
	_state = state
	if _tween != null and _tween.is_valid():
		_tween.kill()
	body.position = Vector2(0, -22)
	body.scale = Vector2.ONE
	body.modulate = Color.WHITE
	warning_lane.modulate.a = 0.0
	match state:
		ArmoredHog.State.SPAWNING:
			body.play("idle_down")
			body.modulate = Color(0.35, 0.45, 0.34, 0.0)
			body.scale = Vector2(0.8, 0.8)
			_tween = create_tween().set_parallel(true)
			_tween.tween_property(body, "modulate", Color.WHITE, duration_seconds)
			_tween.tween_property(body, "scale", Vector2.ONE, duration_seconds).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		ArmoredHog.State.CHASE:
			body.play("walk_" + _direction)
		ArmoredHog.State.BRACE:
			body.play("brace_" + _direction)
			warning_lane.modulate = Color(1.0, 0.35, 0.16, 0.12)
			_tween = create_tween()
			_tween.tween_property(warning_lane, "modulate:a", 0.42, duration_seconds)
		ArmoredHog.State.CHARGE:
			body.play("charge_" + _direction)
		ArmoredHog.State.DAZED:
			body.play("crash_" + _direction)
			_tween = create_tween()
			_tween.tween_interval(0.12)
			_tween.tween_callback(func() -> void: body.play("dazed_" + _direction))
		ArmoredHog.State.STAGGER:
			body.play("dazed_" + _direction)
		ArmoredHog.State.DEAD:
			body.play("dead_" + _direction)
			_tween = create_tween()
			_tween.tween_interval(maxf(duration_seconds - 0.2, 0.1))
			_tween.tween_property(body, "modulate:a", 0.0, 0.2)


func play_hurt(_info: DamageInfo) -> void:
	if _state == ArmoredHog.State.DEAD:
		return
	body.play("hurt_" + _direction)
	if not _hurt_return_pending:
		_hurt_return_pending = true
		body.animation_finished.connect(_on_hurt_finished, CONNECT_ONE_SHOT)


func _on_hurt_finished() -> void:
	_hurt_return_pending = false
	_restore_state_animation()


func _restore_state_animation() -> void:
	match _state:
		ArmoredHog.State.CHASE: body.play("walk_" + _direction)
		ArmoredHog.State.BRACE: body.play("brace_" + _direction)
		ArmoredHog.State.CHARGE: body.play("charge_" + _direction)
		ArmoredHog.State.DAZED, ArmoredHog.State.STAGGER: body.play("dazed_" + _direction)
		ArmoredHog.State.DEAD: body.play("dead_" + _direction)
		_: body.play("idle_" + _direction)


func _direction_name(direction: Vector2) -> String:
	if absf(direction.x) > absf(direction.y):
		return "right" if direction.x > 0.0 else "left"
	return "down" if direction.y > 0.0 else "up"
