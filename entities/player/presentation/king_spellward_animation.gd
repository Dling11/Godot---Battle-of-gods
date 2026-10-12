extends "res://entities/player/presentation/king_greatsword_animation.gd"

## Production King C body; gameplay components retain all control timing.
var _legacy_outline: Material
var _uses_shared_body := false

func _ready() -> void:
	_legacy_outline = material
	_uses_shared_body = sprite_frames.resource_path.ends_with("shared_bodies/sword/frames.tres")
	animation_changed.connect(_sync_body_material)
	super._ready()
	_sync_body_material()
	sprite_frames = sprite_frames.duplicate(true)
	var sheet := preload("res://assets/vfx/abilities/king/unbroken_vow_test/body_down.png")
	sprite_frames.add_animation("unbroken_vow_down")
	sprite_frames.set_animation_loop("unbroken_vow_down", false)
	for index in 8:
		var texture := AtlasTexture.new()
		texture.atlas = sheet
		texture.region = Rect2(Vector2(index%4,index/4)*Vector2(192,128),Vector2(192,128))
		texture.filter_clip = true
		sprite_frames.add_frame("unbroken_vow_down", texture)

func _sync_body_material() -> void:
	# The complete canonical body already owns its outline, like the family
	# presenters. Retain the old shader only for untouched legacy action art.
	var locomotion := String(animation).begins_with("idle_") or String(animation).begins_with("walk_")
	material = null if _uses_shared_body and locomotion else _legacy_outline

func _play_action_phase(phase: int, seconds: float) -> void:
	var active := (owner as Player).get_active_ability_component()
	if active is UnbrokenVowComponent:
		_play_vow_phase(phase, seconds)
		return
	if active == null and attack_component.committed_vow_finisher:
		super._play_action_phase(phase, seconds)
		if phase == MeleeAttackComponent.Phase.WIND_UP:
			_attack_phase_tween.parallel().tween_property(self, "position", _base_position+Vector2(0,-5), seconds)
		elif phase == MeleeAttackComponent.Phase.ACTIVE:
			position = _base_position+Vector2(0,-5)
			_attack_phase_tween.parallel().tween_property(self, "position", _base_position, minf(seconds,.06))
		return
	if not active is EarthsplitterComponent:
		super._play_action_phase(phase, seconds)
		return
	_kill_recoil_tween()
	_kill_attack_phase_tween()
	speed_scale = 1.0
	_action_locked = true
	if phase == AbilityComponent.Phase.WIND_UP:
		_action_direction = _direction
	stop()
	animation = "heavy_cleave_" + _action_direction
	position = _base_position
	var first: int = [0, 4, 5][clampi(phase - 1, 0, 2)]
	var last: int = [3, 5, 7][clampi(phase - 1, 0, 2)]
	frame = first
	_attack_phase_tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	_attack_phase_tween.tween_method(_set_attack_frame, float(first), float(last), maxf(seconds, .01))


func _play_locomotion() -> void:
	var previous := animation
	var previous_count := maxi(1, sprite_frames.get_frame_count(previous))
	var stride_phase := (frame + frame_progress) / previous_count
	super._play_locomotion()
	# Preserve cycle phase across a turn even if a loadout has another count.
	if previous != animation and String(previous).begins_with("walk_") and String(animation).begins_with("walk_"):
		var next_frame := stride_phase * sprite_frames.get_frame_count(animation)
		set_frame_and_progress(int(next_frame), fposmod(next_frame, 1.0))

func resume_locomotion() -> void:
	var actor := owner as Player
	if actor != null and (actor.is_defeated or actor.is_in_hit_recovery()):
		return
	super.resume_locomotion()

func play_hit_recovery(_duration_seconds: float) -> void:
	_kill_recoil_tween()
	_kill_attack_phase_tween()
	speed_scale = 1.0
	_action_direction = _direction
	_action_locked = true
	position = _base_position
	var actor := owner as Player
	var stunned := actor != null and actor.stagger_component.is_stunned()
	play(("stagger_" if stunned else "hurt_") + _action_direction)

func _on_animation_finished() -> void:
	var actor := owner as Player
	if actor != null and (actor.is_defeated or actor.is_in_hit_recovery()):
		return
	super._on_animation_finished()

func _play_vow_phase(phase: int, seconds: float) -> void:
	_kill_recoil_tween()
	_kill_attack_phase_tween()
	speed_scale = 1.0
	_action_locked = true
	if phase == AbilityComponent.Phase.WIND_UP: _action_direction = _direction
	stop()
	# Keep approved directional anatomy. Down uses the generated pressure pose;
	# other directions use the matching planted heavy-cleave anticipation/release.
	animation = "unbroken_vow_down" if _action_direction == "down" else "heavy_cleave_"+_action_direction
	position = _base_position
	var first: int = [0,4,5][clampi(phase-1,0,2)]
	var last: int = [3,4,7][clampi(phase-1,0,2)]
	frame = first
	_attack_phase_tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	_attack_phase_tween.tween_method(_set_attack_frame,float(first),float(last),seconds)
