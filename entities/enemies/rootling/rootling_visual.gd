extends Node2D

## Presentation-only observer for Rootling's unique, locked root-jab attack.

@export var body: Sprite2D
@export var root_jab_vfx: Sprite2D
@export var walk_texture: Texture2D
@export var reaction_texture: Texture2D
@export var vfx_texture: Texture2D

var _direction_row := 0
var _walk_frame := 0
var _walk_tween: Tween
var _body_tween: Tween
var _vfx_tween: Tween


func _ready() -> void:
	body.hframes = 4
	body.vframes = 4
	root_jab_vfx.texture = vfx_texture
	root_jab_vfx.hframes = 4
	root_jab_vfx.vframes = 4
	root_jab_vfx.hide()
	_show_walk_frame(0)


func set_facing(direction: Vector2) -> void:
	if direction.is_zero_approx():
		return
	if absf(direction.x) > absf(direction.y):
		_direction_row = 2 if direction.x > 0.0 else 1
	else:
		_direction_row = 0 if direction.y > 0.0 else 3
	if body.texture == walk_texture:
		_show_walk_frame(_walk_frame)


func play_state(state: Rootling.State, duration_seconds: float) -> void:
	_stop_walk()
	match state:
		Rootling.State.SPAWNING:
			body.texture = walk_texture
			_show_walk_frame(0)
			body.modulate = Color(1.0, 1.0, 1.0, 0.0)
			body.scale = Vector2.ONE
			_body_tween = create_tween()
			_body_tween.tween_property(body, "modulate:a", 1.0, minf(.22, duration_seconds))
		Rootling.State.CHASE:
			body.texture = walk_texture
			body.modulate = Color.WHITE
			body.scale = Vector2.ONE
			body.position = Vector2(0.0, -16.0)
			_start_walk()
		Rootling.State.WIND_UP:
			body.texture = walk_texture
			_show_walk_frame(1)
			body.position = Vector2(0.0, -16.0)
			body.scale = Vector2.ONE
			_body_tween = create_tween()
			# Rootling braces outward but keeps its full height. The former y=0.84
			# squash made its down-facing jab look like a shrinking sprite.
			_body_tween.tween_property(body, "scale", Vector2(1.08, 1.0), duration_seconds).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		Rootling.State.ACTIVE:
			body.modulate = Color(1.2, 1.08, 0.72, 1.0)
		Rootling.State.RECOVERY:
			body.texture = walk_texture
			_show_walk_frame(0)
			body.scale = Vector2.ONE
			var recovery_tween := create_tween()
			recovery_tween.tween_property(body, "modulate", Color.WHITE, duration_seconds)
		Rootling.State.STAGGER:
			body.texture = reaction_texture
			body.frame = _direction_row * 4 + 2
			body.scale = Vector2(1.08, 0.84)
			body.modulate = Color(1.0, 0.84, 0.56, 1.0)
		Rootling.State.DEAD:
			_stop_root_jab_vfx()
			body.texture = reaction_texture
			body.frame = _direction_row * 4 + 3
			body.scale = Vector2.ONE
			var death_tween := create_tween()
			death_tween.tween_property(body, "modulate:a", 0.0, duration_seconds)


func play_hurt(_info: DamageInfo) -> void:
	if body.texture == reaction_texture or body.modulate.a <= 0.0:
		return
	if _body_tween != null and _body_tween.is_valid():
		_body_tween.kill()
	body.texture = reaction_texture
	body.frame = _direction_row * 4 + 1
	_body_tween = create_tween()
	_body_tween.tween_interval(0.08)
	_body_tween.tween_callback(func() -> void:
		if body.texture == reaction_texture:
			body.texture = walk_texture
			_show_walk_frame(_walk_frame)
	)


func show_root_jab_telegraph(direction: Vector2, duration_seconds: float) -> void:
	_stop_root_jab_vfx()
	root_jab_vfx.position = Vector2(0.0, -6.0) + direction * 22.0
	root_jab_vfx.frame = _direction_row * 4
	root_jab_vfx.modulate = Color(1.0, 1.0, 1.0, 0.9)
	root_jab_vfx.show()
	_vfx_tween = create_tween()
	_vfx_tween.tween_interval(duration_seconds * 0.62)
	_vfx_tween.tween_callback(_show_crack_branch)


func play_root_jab(direction: Vector2) -> void:
	_stop_root_jab_vfx()
	root_jab_vfx.position = Vector2(0.0, -6.0) + direction * 22.0
	root_jab_vfx.frame = _direction_row * 4 + 2
	root_jab_vfx.modulate = Color.WHITE
	root_jab_vfx.show()
	_vfx_tween = create_tween()
	_vfx_tween.tween_interval(0.09)
	_vfx_tween.tween_callback(_show_retracting_crack)
	_vfx_tween.tween_interval(0.12)
	_vfx_tween.tween_callback(root_jab_vfx.hide)


func _start_walk() -> void:
	_show_walk_frame(0)
	_walk_tween = create_tween().set_loops()
	for frame_index in [1, 2, 3, 0]:
		_walk_tween.tween_interval(0.11)
		_walk_tween.tween_callback(_show_walk_frame.bind(frame_index))


func _stop_walk() -> void:
	if _walk_tween != null and _walk_tween.is_valid():
		_walk_tween.kill()


func _show_walk_frame(frame_index: int) -> void:
	_walk_frame = frame_index
	body.texture = walk_texture
	body.frame = _direction_row * 4 + _walk_frame
	# The generated front strip carries the alternating root steps itself. Keep
	# every frame on the same presentation baseline to prevent size popping.
	body.position = Vector2(0.0, -16.0)


func _stop_root_jab_vfx() -> void:
	if _vfx_tween != null and _vfx_tween.is_valid():
		_vfx_tween.kill()
	root_jab_vfx.hide()


func _show_crack_branch() -> void:
	root_jab_vfx.frame = _direction_row * 4 + 1


func _show_retracting_crack() -> void:
	root_jab_vfx.frame = _direction_row * 4 + 3
