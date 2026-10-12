extends Node2D

const IdleTexture = preload("res://assets/characters/enemies/stage_5_boss/stage_5_boss_idle_sheet_112x96.png")
const WalkTexture = preload("res://assets/characters/enemies/stage_5_boss/stage_5_boss_walk_sheet_112x96.png")
const ReactionTexture = preload("res://assets/characters/enemies/stage_5_boss/stage_5_boss_reaction_sheet_144x112.png")
const AttackTexture = preload("res://assets/characters/enemies/stage_5_boss/stage_5_boss_basic_attack_sheet_144x112.png")
const SlapTexture = preload("res://assets/characters/enemies/stage_5_boss/stage_5_boss_slap_sheet_144x112.png")
const JumpTexture = preload("res://assets/characters/enemies/stage_5_boss/stage_5_boss_jump_body_sheet_144x112.png")

@export var body: AnimatedSprite2D
@export var shadow: Polygon2D

var _direction := "down"
var _state := Stage5Boss.State.SPAWNING
var _moving := false
var _base_body_position := Vector2(0.0, -42.0)
var _tween: Tween
var _hurt_pending := false

const DEATH_FADE_SECONDS := 0.65


func _ready() -> void:
	body.sprite_frames = _build_frames()
	body.position = _base_body_position
	body.play(&"idle_down")


func set_facing(direction: Vector2) -> void:
	_direction = _direction_name(direction)
	_restore()


func set_moving(value: bool) -> void:
	_moving = value
	if _state == Stage5Boss.State.CHASE:
		_restore()


func set_jump_height(height_pixels: float) -> void:
	body.position = _base_body_position + Vector2(0.0, -roundf(height_pixels))
	shadow.scale = Vector2.ONE * lerpf(1.0, 0.55, clampf(height_pixels / 96.0, 0.0, 1.0))
	shadow.modulate.a = lerpf(0.42, 0.16, clampf(height_pixels / 96.0, 0.0, 1.0))


func play_state(state: Stage5Boss.State, duration_seconds: float) -> void:
	if _hurt_pending and state != Stage5Boss.State.CHASE:
		_cancel_hurt()
	_state = state
	if _tween != null and _tween.is_valid():
		_tween.kill()
	body.modulate = Color.WHITE
	match state:
		Stage5Boss.State.SPAWNING:
			body.play(&"idle_down")
			body.modulate.a = 0.0
			_tween = create_tween()
			_tween.tween_property(body, "modulate:a", 1.0, duration_seconds)
		Stage5Boss.State.CHASE:
			_restore()
		Stage5Boss.State.LUNGE_WIND_UP:
			_play_fit("lunge_wind_up_" + _direction, duration_seconds)
		Stage5Boss.State.LUNGE_ACTIVE:
			_play_fit("lunge_active_" + _direction, duration_seconds)
		Stage5Boss.State.LUNGE_RECOVERY:
			_play_fit("lunge_recovery_" + _direction, duration_seconds)
		Stage5Boss.State.SLAP_WIND_UP:
			_play_fit("slap_wind_up_" + _direction, duration_seconds)
		Stage5Boss.State.SLAP_ACTIVE:
			_play_fit("slap_active_" + _direction, duration_seconds)
		Stage5Boss.State.SLAP_RECOVERY:
			_play_fit("slap_recovery_" + _direction, duration_seconds)
		Stage5Boss.State.JUMP_WIND_UP:
			_play_fit("jump_wind_up_" + _direction, duration_seconds)
		Stage5Boss.State.JUMP_TRAVEL:
			_play_fit("jump_travel_" + _direction, duration_seconds)
		Stage5Boss.State.JUMP_LAND:
			_play_fit("jump_land_" + _direction, duration_seconds)
		Stage5Boss.State.JUMP_RECOVERY:
			_play_fit("jump_recovery_" + _direction, duration_seconds)
		Stage5Boss.State.ROOT_WIND_UP:
			_play_fit("slap_wind_up_" + _direction, duration_seconds)
		Stage5Boss.State.ROOT_TRACK:
			_play_fit("slap_active_" + _direction, duration_seconds)
		Stage5Boss.State.ROOT_CHANNEL:
			_hold_frame("slap_active_" + _direction, 1)
		Stage5Boss.State.ROOT_EXECUTION:
			_hold_frame("slap_active_" + _direction, 1)
		Stage5Boss.State.ROOT_RECOVERY:
			_play_fit("slap_recovery_" + _direction, duration_seconds)
		Stage5Boss.State.DEAD:
			body.position = _base_body_position
			body.visible = true
			shadow.visible = true
			shadow.scale = Vector2.ONE
			shadow.modulate = Color.WHITE
			_play_fit("dead_" + _direction, duration_seconds)
			_tween = create_tween()
			_tween.tween_interval(maxf(duration_seconds, 0.0) + 0.2)
			_tween.tween_property(body, "modulate:a", 0.0, DEATH_FADE_SECONDS)
			_tween.parallel().tween_property(shadow, "modulate:a", 0.0, DEATH_FADE_SECONDS)
			_tween.tween_callback(_finish_death_fade)


func play_hurt(_info: DamageInfo) -> void:
	## Boss attacks are committed. Their local hit flash still confirms damage,
	## but replacing an authored attack pose with a reaction corrupts readability.
	if _state != Stage5Boss.State.CHASE or _hurt_pending:
		return
	_hurt_pending = true
	body.speed_scale = 1.0
	body.play("hurt_" + _direction)
	if not body.animation_finished.is_connected(_on_hurt_finished):
		body.animation_finished.connect(_on_hurt_finished, CONNECT_ONE_SHOT)


func play_desperation() -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	body.modulate = Color.WHITE
	_tween = create_tween()
	for pulse in range(3):
		_tween.tween_property(body, "modulate", Color(0.72, 1.0, 0.48, 1.0), 0.055)
		_tween.tween_property(body, "modulate", Color.WHITE, 0.055)


func _on_hurt_finished() -> void:
	_hurt_pending = false
	_restore()


func _cancel_hurt() -> void:
	if body.animation_finished.is_connected(_on_hurt_finished):
		body.animation_finished.disconnect(_on_hurt_finished)
	_hurt_pending = false


func _finish_death_fade() -> void:
	body.visible = false
	shadow.visible = false


func _restore() -> void:
	if _hurt_pending:
		return
	if _state == Stage5Boss.State.CHASE:
		body.play(("walk_" if _moving else "idle_") + _direction)


func _play_fit(animation: String, duration_seconds: float) -> void:
	body.speed_scale = 1.0
	if duration_seconds > 0.0:
		var frames := body.sprite_frames
		var authored := frames.get_frame_count(animation) / frames.get_animation_speed(animation)
		body.speed_scale = authored / maxf(duration_seconds, 0.01)
	body.play(animation)


func _hold_frame(animation: String, frame_index: int) -> void:
	body.speed_scale = 1.0
	body.play(animation)
	body.set_frame_and_progress(frame_index, 0.0)
	body.pause()


func _build_frames() -> SpriteFrames:
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	var directions := ["down", "left", "right", "up"]
	for row in range(4):
		var direction: String = directions[row]
		_add_range(frames, "idle_" + direction, IdleTexture, Vector2i(112, 96), row, 0, 4, 3.2, true)
		_add_range(frames, "walk_" + direction, WalkTexture, Vector2i(112, 96), row, 0, 6, 9.0, true)
		_add_range(frames, "hurt_" + direction, ReactionTexture, Vector2i(144, 112), row, 0, 3, 10.0, false)
		_add_range(frames, "dead_" + direction, ReactionTexture, Vector2i(144, 112), row, 3, 8, 5.0, false)
		_add_range(frames, "lunge_wind_up_" + direction, AttackTexture, Vector2i(144, 112), row, 0, 4, 5.0, false)
		_add_range(frames, "lunge_active_" + direction, AttackTexture, Vector2i(144, 112), row, 4, 6, 14.0, false)
		_add_range(frames, "lunge_recovery_" + direction, AttackTexture, Vector2i(144, 112), row, 6, 8, 5.0, false)
		_add_range(frames, "slap_wind_up_" + direction, SlapTexture, Vector2i(144, 112), row, 0, 4, 5.0, false)
		_add_range(frames, "slap_active_" + direction, SlapTexture, Vector2i(144, 112), row, 4, 6, 14.0, false)
		_add_range(frames, "slap_recovery_" + direction, SlapTexture, Vector2i(144, 112), row, 6, 8, 5.0, false)
		_add_range(frames, "jump_wind_up_" + direction, JumpTexture, Vector2i(144, 112), row, 0, 2, 4.0, false)
		_add_range(frames, "jump_travel_" + direction, JumpTexture, Vector2i(144, 112), row, 2, 6, 5.0, false)
		_add_range(frames, "jump_land_" + direction, JumpTexture, Vector2i(144, 112), row, 6, 7, 8.0, false)
		_add_range(frames, "jump_recovery_" + direction, JumpTexture, Vector2i(144, 112), row, 7, 8, 4.0, false)
	return frames


func _add_range(frames: SpriteFrames, name: String, texture: Texture2D, cell: Vector2i, row: int, start: int, end: int, speed: float, loop: bool) -> void:
	frames.add_animation(name)
	frames.set_animation_speed(name, speed)
	frames.set_animation_loop(name, loop)
	for column in range(start, end):
		var atlas := AtlasTexture.new()
		atlas.atlas = texture
		atlas.region = Rect2(column * cell.x, row * cell.y, cell.x, cell.y)
		frames.add_frame(name, atlas)


func _direction_name(direction: Vector2) -> String:
	if absf(direction.x) > absf(direction.y):
		return "right" if direction.x > 0.0 else "left"
	return "down" if direction.y > 0.0 else "up"
