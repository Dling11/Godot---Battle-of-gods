extends Node2D

@export var body: AnimatedSprite2D
@export var landing_marker: Polygon2D

var _motion_tween: Tween

var _direction := "down"


func _ready() -> void:
	landing_marker.top_level = true
	landing_marker.hide()


func set_facing(direction: Vector2) -> void:
	_direction = ("right" if direction.x > 0.0 else "left") if absf(direction.x) > absf(direction.y) else ("down" if direction.y > 0.0 else "up")
	if body.animation.begins_with("idle_"): body.play("idle_" + _direction)


func play_state(state: Mireling.State, duration: float) -> void:
	if _motion_tween != null and _motion_tween.is_valid(): _motion_tween.kill()
	match state:
		Mireling.State.SPAWNING:
			body.play("idle_down")
			body.modulate.a = 0.0
			body.scale = Vector2.ONE
			var tween := create_tween()
			tween.tween_property(body, "modulate:a", 1.0, minf(.22, duration))
		Mireling.State.CHASE:
			body.position = Vector2(0, -16)
			body.modulate = Color.WHITE
			body.play("hop_" + _direction)
		Mireling.State.WIND_UP:
			body.play("attack_" + _direction)
			_motion_tween = create_tween()
			_motion_tween.tween_property(body, "scale", Vector2(1.16, 0.82), duration).set_trans(Tween.TRANS_QUAD)
		Mireling.State.LEAP:
			body.scale = Vector2.ONE
			_motion_tween = create_tween()
			_motion_tween.tween_property(body, "position:y", -30.0, duration * 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			_motion_tween.tween_property(body, "position:y", -16.0, duration * 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		Mireling.State.ACTIVE:
			body.modulate = Color(1.25, 0.86, 0.72, 1.0)
			landing_marker.hide()
		Mireling.State.RECOVERY:
			body.play("idle_" + _direction)
			create_tween().tween_property(body, "modulate", Color.WHITE, duration)
		Mireling.State.STAGGER:
			landing_marker.hide()
			body.play("idle_" + _direction)
			body.position = Vector2(0, -14)
			body.scale = Vector2(1.14, 0.82)
			body.modulate = Color(1.0, 0.86, 0.58, 1.0)
		Mireling.State.DEAD:
			landing_marker.hide()
			body.play("dead_" + _direction)
			create_tween().tween_property(body, "modulate:a", 0.0, duration)


func show_landing_target(global_target: Vector2, duration: float) -> void:
	landing_marker.global_position = global_target
	landing_marker.modulate.a = 0.15
	landing_marker.show()
	var tween := create_tween()
	tween.tween_property(landing_marker, "modulate:a", 0.7, duration)
