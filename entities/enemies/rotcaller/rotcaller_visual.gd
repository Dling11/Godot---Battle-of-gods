extends Node2D

## Presentation follows authority events and actual movement, never drives casts.
var _direction := "south"
var _state := Rotcaller.State.SPAWNING
var _moving := false
var _interrupted := false
var _pose_tween: Tween
@onready var body: AnimatedSprite2D = $Body
@onready var hint: Label = $CastHint

func set_facing(direction: Vector2) -> void:
	_direction = ("east" if direction.x > 0 else "west") if absf(direction.x) > absf(direction.y) else ("south" if direction.y > 0 else "north")
	if _state == Rotcaller.State.POSITIONING: _show("walk" if _moving else "idle")
	elif _state == Rotcaller.State.SPAWNING: _show("idle")

func set_moving(moving: bool) -> void:
	_moving = moving
	if _state == Rotcaller.State.POSITIONING: _show("walk" if moving else "idle")

func interrupt() -> void:
	_interrupted = true

func play_state(state: Rotcaller.State, seconds: float) -> void:
	_state = state
	if _pose_tween != null: _pose_tween.kill()
	hint.visible = state == Rotcaller.State.WIND_UP
	match state:
		Rotcaller.State.SPAWNING:
			_show("idle")
			body.modulate.a = 0
			_pose_tween = create_tween()
			_pose_tween.tween_property(body,"modulate:a",1.0,seconds)
		Rotcaller.State.POSITIONING: _show("walk" if _moving else "idle")
		Rotcaller.State.WIND_UP:
			_interrupted = false
			_show("windup")
		Rotcaller.State.RECOVERY:
			_show("recovery" if _interrupted else "release")
			if not _interrupted:
				_pose_tween = create_tween()
				_pose_tween.tween_interval(.14)
				_pose_tween.tween_callback(_show.bind("recovery"))
		Rotcaller.State.STAGGER: _show("recovery")
		Rotcaller.State.DEAD:
			_show("death")
			_pose_tween = create_tween()
			_pose_tween.tween_property(body,"modulate:a",0.0,seconds)

func _show(action: String) -> void:
	var animation := StringName(action+"_"+_direction)
	if body.animation != animation: body.play(animation)
	elif action == "walk" and not body.is_playing(): body.play(animation)
