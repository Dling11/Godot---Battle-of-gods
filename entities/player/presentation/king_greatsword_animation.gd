extends "res://entities/player/presentation/player_animation.gd"

@export var attack_component: MeleeAttackComponent
@export var ability_4_component: AbilityComponent

func _ready() -> void:
	super._ready()
	var actor := owner as Player
	if actor != null:
		actor.ready.connect(func() -> void: actor.equipment_stats_changed.connect(_refresh_stride))
		actor.ready.connect(func() -> void:
			actor.movement_component.speed_changed.connect(func(_speed: float) -> void: _refresh_stride()))

func _refresh_stride() -> void:
	if not _action_locked:
		_play_locomotion()

func _play_action_phase(phase: int, duration_seconds: float) -> void:
	speed_scale = 1.0
	_kill_recoil_tween()
	if phase == MeleeAttackComponent.Phase.WIND_UP:
		_action_direction = _direction
	_action_locked = true
	_kill_attack_phase_tween()
	stop()
	var key := attack_component.get_animation_key()
	var first := [0,3,5]
	var last := [2,4,7]
	if _is_sovereign_pursuit_casting():
		key = "sovereign_pursuit"
		first = [0,2,5]
		last = [1,4,7]
	elif _is_riftbreak_casting():
		key = "riftbreak"
		first = [0,4,5]
		last = [3,4,7]
	elif ability_4_component != null and ability_4_component.is_casting():
		key = "worldsplitter"
		first = [0,4,6]
		last = [3,5,7]
	elif ability_component != null and ability_component.is_casting():
		key = "echoing_sever"
	animation = key + "_" + _action_direction
	var phase_index := clampi(phase-1,0,2)
	frame = first[phase_index]
	position = _base_position
	_attack_phase_tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	_attack_phase_tween.tween_method(_set_attack_frame,float(first[phase_index]),float(last[phase_index]),maxf(duration_seconds,.01))
	if key == "sovereign_pursuit" and phase == AbilityComponent.Phase.ACTIVE:
		_attack_phase_tween.parallel().tween_method(_set_hop,0.0,1.0,duration_seconds)

func _set_hop(progress: float) -> void:
	position = _base_position + Vector2(0,-13*sin(progress*PI))

# Movement-equipment cadence must not leak into reactions or the evade pose.
func play_dash(direction: Vector2) -> void:
	speed_scale = 1.0
	super.play_dash(direction)

func play_hurt(info: DamageInfo) -> void:
	if not _action_locked:
		speed_scale = 1.0
	super.play_hurt(info)

func play_hit_recovery(duration_seconds: float) -> void:
	speed_scale = 1.0
	super.play_hit_recovery(duration_seconds)

func play_interaction() -> void:
	speed_scale = 1.0
	super.play_interaction()

func play_defeat() -> void:
	speed_scale = 1.0
	super.play_defeat()

func _set_attack_frame(value: float) -> void:
	frame = clampi(roundi(value),0,sprite_frames.get_frame_count(animation)-1)

func _play_locomotion() -> void:
	var actor := owner as Player
	speed_scale = actor.movement_component.max_speed / actor.movement_component._base_max_speed if _is_moving and actor != null and actor.movement_component != null else 1.0
	var next := ("walk_" if _is_moving else "idle_") + _direction
	if animation == next and is_playing():
		return
	var retain_stride := String(animation).begins_with("walk_") and next.begins_with("walk_")
	var previous_frame := frame
	var previous_progress := frame_progress
	play(next)
	if retain_stride:
		set_frame_and_progress(previous_frame % sprite_frames.get_frame_count(next),previous_progress)

func resume_locomotion() -> void:
	# A buffered next action can start while the previous finish signal dispatches.
	if attack_component != null and attack_component.phase != MeleeAttackComponent.Phase.IDLE:
		return
	for ability in (owner as Player).get_all_ability_components():
		if ability != null and ability.is_casting():
			return
	super.resume_locomotion()
