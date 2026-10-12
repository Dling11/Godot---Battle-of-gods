extends Node2D

@export var body: AnimatedSprite2D
@export var root_spear_vfx: Array[AnimatedSprite2D] = []

const ROOT_SPEAR_CENTER_DISTANCE := 64.0
const ROOT_SPEAR_GROUND_HEIGHT := -4.0

var _direction := &"down"
var _is_moving := false
var _active_state := RootboundHusk.State.SPAWNING
var _body_tween: Tween
var _camera_tween: Tween
var _telegraphed_directions: Array[Vector2] = []


func _ready() -> void:
	for vfx in root_spear_vfx:
		vfx.hide()
		vfx.animation_finished.connect(_on_root_spear_animation_finished.bind(vfx))
	_play_body(&"idle_down")


func set_facing(direction: Vector2) -> void:
	if direction.is_zero_approx():
		return
	_direction = (
		(&"right" if direction.x > 0.0 else &"left")
		if absf(direction.x) > absf(direction.y)
		else (&"down" if direction.y > 0.0 else &"up")
	)
	if _active_state == RootboundHusk.State.CHASE:
		_play_chase_animation()


func play_state(state: int, duration_seconds: float) -> void:
	_stop_body_tween()
	_active_state = state
	match state:
		RootboundHusk.State.SPAWNING:
			body.modulate = Color(1.0, 1.0, 1.0, 0.0)
			_play_body(&"idle_down")
			_body_tween = create_tween()
			_body_tween.tween_property(body, "modulate:a", 1.0, duration_seconds)
		RootboundHusk.State.CHASE:
			body.modulate = Color.WHITE
			_play_chase_animation()
		RootboundHusk.State.SPEAR_WIND_UP:
			body.modulate = Color.WHITE
			_play_body(_directional_animation(&"root_attack_wind_up"), duration_seconds)
		RootboundHusk.State.TRIAD_WIND_UP:
			body.modulate = Color(1.08, 0.88, 1.16, 1.0)
			_play_body(_directional_animation(&"root_attack_wind_up"), duration_seconds)
		RootboundHusk.State.SPEAR_ACTIVE:
			body.modulate = Color(1.08, 1.03, 0.9, 1.0)
			_play_body(_directional_animation(&"root_attack_active"), duration_seconds)
		RootboundHusk.State.TRIAD_ACTIVE:
			body.modulate = Color(1.16, 0.82, 1.18, 1.0)
			_play_body(_directional_animation(&"root_attack_active"), duration_seconds)
		RootboundHusk.State.BURST_WIND_UP:
			body.modulate = Color(1.16, 0.74, 0.56, 1.0)
			_play_body(_directional_animation(&"root_attack_wind_up"), duration_seconds)
		RootboundHusk.State.BURST_ACTIVE:
			body.modulate = Color(1.28, 0.94, 0.72, 1.0)
			_play_body(_directional_animation(&"root_attack_active"), duration_seconds)
		RootboundHusk.State.RECOVERY:
			body.modulate = Color.WHITE
			_play_body(_directional_animation(&"root_attack_recovery"), duration_seconds)
		RootboundHusk.State.DEAD:
			_stop_root_spears()
			_play_body(_directional_animation(&"dead"), duration_seconds)
			_body_tween = create_tween()
			_body_tween.tween_property(body, "modulate:a", 0.0, duration_seconds)


func set_moving(is_moving: bool) -> void:
	_is_moving = is_moving
	if _active_state == RootboundHusk.State.CHASE:
		_play_chase_animation()


func play_hurt(_info: DamageInfo) -> void:
	if body.modulate.a <= 0.0 or _active_state == RootboundHusk.State.DEAD:
		return
	_stop_body_tween()
	body.modulate = Color(1.18, 0.82, 0.68, 1.0)
	_play_body(_directional_animation(&"hurt"))
	_body_tween = create_tween()
	_body_tween.tween_property(body, "modulate", Color.WHITE, 0.14)
	_body_tween.tween_callback(_restore_state_animation)


func show_root_attack_telegraph(directions: Array[Vector2], duration_seconds: float) -> void:
	_stop_root_spears()
	_telegraphed_directions.clear()
	for direction in directions:
		_telegraphed_directions.append(direction)
	for index in mini(directions.size(), root_spear_vfx.size()):
		var vfx := root_spear_vfx[index]
		_set_vfx_direction(vfx, directions[index])
		vfx.modulate = (
			Color(0.82, 0.34, 1.0, 0.82)
			if directions.size() == 3 and index > 0
			else Color(1.0, 0.36, 0.24, 0.82)
		)
		vfx.speed_scale = _animation_speed_to_fit(vfx.sprite_frames, &"telegraph", duration_seconds)
		vfx.play(&"telegraph")
		vfx.show()


func play_root_attack(directions: Array[Vector2]) -> void:
	for direction in directions:
		var index := _find_telegraphed_direction(direction)
		if index < 0 or index >= root_spear_vfx.size():
			continue
		var vfx := root_spear_vfx[index]
		_set_vfx_direction(vfx, direction)
		vfx.modulate = Color.WHITE
		vfx.speed_scale = 1.0
		vfx.play(&"erupt")
		vfx.show()
	_pulse_camera(2.4 if directions.size() > 1 else 1.5)


func show_root_burst_telegraph(duration_seconds: float) -> void:
	_stop_root_spears()
	var vfx := root_spear_vfx[0]
	vfx.position = Vector2(0.0, ROOT_SPEAR_GROUND_HEIGHT)
	vfx.rotation = 0.0
	vfx.scale = Vector2(1.15, 1.15)
	vfx.modulate = Color(1.0, 0.48, 0.2, 0.88)
	vfx.speed_scale = _animation_speed_to_fit(vfx.sprite_frames, &"telegraph", duration_seconds)
	vfx.play(&"telegraph")
	vfx.show()


func play_root_burst() -> void:
	var vfx := root_spear_vfx[0]
	vfx.modulate = Color.WHITE
	vfx.speed_scale = 1.0
	vfx.play(&"erupt")
	vfx.show()
	_pulse_camera(3.2)


func _find_telegraphed_direction(direction: Vector2) -> int:
	for index in _telegraphed_directions.size():
		if _telegraphed_directions[index].dot(direction) >= 0.999:
			return index
	return -1


func _set_vfx_direction(vfx: AnimatedSprite2D, direction: Vector2) -> void:
	vfx.position = direction * ROOT_SPEAR_CENTER_DISTANCE + Vector2(0.0, ROOT_SPEAR_GROUND_HEIGHT)
	vfx.rotation = 0.0
	vfx.scale = Vector2.ONE


func _play_chase_animation() -> void:
	_play_body(_directional_animation(&"walk" if _is_moving else &"idle"))


func _play_body(animation_name: StringName, duration_seconds := 0.0) -> void:
	body.speed_scale = 1.0
	if duration_seconds > 0.0:
		body.speed_scale = _animation_speed_to_fit(body.sprite_frames, animation_name, duration_seconds)
	body.play(animation_name)


func _restore_state_animation() -> void:
	match _active_state:
		RootboundHusk.State.CHASE:
			_play_chase_animation()
		RootboundHusk.State.SPEAR_WIND_UP, RootboundHusk.State.TRIAD_WIND_UP:
			_play_body(_directional_animation(&"root_attack_wind_up"))
		RootboundHusk.State.SPEAR_ACTIVE, RootboundHusk.State.TRIAD_ACTIVE:
			_play_body(_directional_animation(&"root_attack_active"))
		RootboundHusk.State.BURST_WIND_UP:
			_play_body(_directional_animation(&"root_attack_wind_up"))
		RootboundHusk.State.BURST_ACTIVE:
			_play_body(_directional_animation(&"root_attack_active"))
		RootboundHusk.State.RECOVERY:
			_play_body(_directional_animation(&"root_attack_recovery"))


func _directional_animation(action: StringName) -> StringName:
	return StringName("%s_%s" % [action, _direction])


func _animation_speed_to_fit(frames: SpriteFrames, animation_name: StringName, duration_seconds: float) -> float:
	var duration := 0.0
	for frame_index in frames.get_frame_count(animation_name):
		duration += frames.get_frame_duration(animation_name, frame_index)
	duration /= frames.get_animation_speed(animation_name)
	return duration / maxf(duration_seconds, 0.01)


func _stop_body_tween() -> void:
	if _body_tween != null and _body_tween.is_valid():
		_body_tween.kill()


func _stop_root_spears() -> void:
	for vfx in root_spear_vfx:
		vfx.stop()
		vfx.hide()
		vfx.scale = Vector2.ONE


func _pulse_camera(strength: float) -> void:
	var camera := get_viewport().get_camera_2d()
	if camera == null or DisplayServer.get_name() == "headless":
		return
	if _camera_tween != null and _camera_tween.is_valid():
		_camera_tween.kill()
	var base_offset := camera.offset
	_camera_tween = create_tween()
	_camera_tween.tween_property(camera, "offset", base_offset + Vector2(strength, -1.0), 0.025)
	_camera_tween.tween_property(camera, "offset", base_offset + Vector2(-strength, 1.0), 0.04)
	_camera_tween.tween_property(camera, "offset", base_offset, 0.05)


func _on_root_spear_animation_finished(vfx: AnimatedSprite2D) -> void:
	if vfx.animation == &"erupt":
		vfx.hide()
