extends AnimatedSprite2D

@export var ability_component: AbilityComponent
@export var ability_2_component: AbilityComponent
@export var ability_3_component: AbilityComponent

var _direction := "down"
var _action_direction := "down"
var _is_moving := false
var _action_locked := false
var _base_position: Vector2
var _attack_phase_tween: Tween
var _recoil_tween: Tween


func _ready() -> void:
	_base_position = position
	animation_finished.connect(_on_animation_finished)
	_play_locomotion()


func set_facing_direction(direction: Vector2) -> void:
	_direction = _direction_name(direction)
	if not _action_locked:
		_play_locomotion()


func set_movement(_direction_vector: Vector2, is_moving: bool) -> void:
	if _is_moving == is_moving:
		return
	_is_moving = is_moving
	if not _action_locked:
		_play_locomotion()


func play_attack_phase(phase: MeleeAttackComponent.Phase, duration_seconds: float) -> void:
	_play_action_phase(phase, duration_seconds)


func play_ability_phase(phase: AbilityComponent.Phase, duration_seconds: float) -> void:
	_play_action_phase(phase, duration_seconds)


func play_ability_strike(strike_index: int, _strike_count: int, _duration_seconds: float) -> void:
	if (
		strike_index != 0
		or ability_component == null
		or ability_component.definition == null
		or ability_component.definition.ability_id != &"echoing_sever"
	):
		return
	_kill_recoil_tween()
	var forward := _direction_vector(_action_direction)
	var recoil := -forward * 2.0
	recoil = Vector2(roundf(recoil.x), roundf(recoil.y))
	_recoil_tween = create_tween()
	_recoil_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	_recoil_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_recoil_tween.tween_property(self, "position", _base_position + recoil, 0.035)
	_recoil_tween.tween_property(self, "position", _base_position, 0.075)


func _play_action_phase(phase: int, duration_seconds: float) -> void:
	_kill_recoil_tween()
	if phase == MeleeAttackComponent.Phase.WIND_UP:
		_action_direction = _direction
	_action_locked = true
	_kill_attack_phase_tween()
	stop()
	var is_riftbreak := _is_riftbreak_casting()
	var is_pursuit := _is_sovereign_pursuit_casting()
	animation = ("sovereign_pursuit_" if is_pursuit else ("riftbreak_" if is_riftbreak else "attack_")) + _action_direction
	var phase_index := clampi(int(phase) - 1, 0, 2)
	var attack_frame_count := sprite_frames.get_frame_count(animation)
	if is_pursuit and attack_frame_count >= 6:
		var first_frame: int = [0, 2, 4][phase_index]
		var last_frame: int = [1, 3, 5][phase_index]
		frame = first_frame
		_attack_phase_tween = create_tween()
		_attack_phase_tween.set_trans(Tween.TRANS_LINEAR)
		_attack_phase_tween.tween_method(_set_attack_frame, float(first_frame), float(last_frame), maxf(duration_seconds, 0.01))
		if phase == AbilityComponent.Phase.ACTIVE:
			_attack_phase_tween.parallel().tween_property(self, "position", _base_position + Vector2(0, -10), duration_seconds * 0.5)
			_attack_phase_tween.tween_property(self, "position", _base_position, duration_seconds * 0.5)
	elif is_riftbreak and attack_frame_count >= 6:
		# Riftbreak has three anticipation drawings, one exact contact drawing,
		# and two recovery drawings. Damage begins on the grounded fourth frame.
		var first_frame: int = [0, 3, 4][phase_index]
		var last_frame: int = [2, 3, 5][phase_index]
		frame = first_frame
		if first_frame != last_frame:
			_attack_phase_tween = create_tween()
			_attack_phase_tween.set_trans(Tween.TRANS_LINEAR)
			_attack_phase_tween.tween_method(
				_set_attack_frame,
				float(first_frame),
				float(last_frame),
				maxf(duration_seconds, 0.01)
			)
	elif attack_frame_count >= 6:
		# King's six-frame proof spends two readable body frames on each
		# authoritative combat phase: anticipation, contact, then recovery.
		var first_frame := phase_index * 2
		var last_frame := first_frame + 1
		frame = first_frame
		_attack_phase_tween = create_tween()
		_attack_phase_tween.set_trans(Tween.TRANS_LINEAR)
		_attack_phase_tween.tween_method(_set_attack_frame, float(first_frame), float(last_frame), maxf(duration_seconds, 0.01))
	else:
		# Existing three-frame characters keep their one-pose-per-phase contract.
		frame = clampi(phase_index, 0, attack_frame_count - 1)
	position = _base_position


func play_dash(direction: Vector2) -> void:
	_kill_recoil_tween()
	_kill_attack_phase_tween()
	_direction = _direction_name(direction)
	_action_locked = true
	position = _base_position
	play("dash_" + _direction)


func play_interaction() -> void:
	_kill_recoil_tween()
	_kill_attack_phase_tween()
	_action_direction = _direction
	_action_locked = true
	position = _base_position
	play("interact_" + _action_direction)


func play_hurt(_info: DamageInfo) -> void:
	if _action_locked:
		return
	_kill_recoil_tween()
	_kill_attack_phase_tween()
	_action_direction = _direction
	_action_locked = true
	position = _base_position
	play("hurt_" + _action_direction)


func play_hit_recovery(_duration_seconds: float) -> void:
	## Gameplay interruption may cancel an action after HealthComponent already
	## emitted damaged. Replay the authored hurt pose from the now-unlocked state
	## so a canceled attack or skill always reads clearly.
	_kill_recoil_tween()
	_kill_attack_phase_tween()
	_action_direction = _direction
	_action_locked = true
	position = _base_position
	play("hurt_" + _action_direction)


func resume_locomotion() -> void:
	_kill_recoil_tween()
	_kill_attack_phase_tween()
	_action_locked = false
	position = _base_position
	_play_locomotion()


func play_defeat() -> void:
	_kill_recoil_tween()
	_kill_attack_phase_tween()
	_action_locked = true
	position = _base_position
	play("defeat_" + _direction)


func _play_locomotion() -> void:
	play(("walk_" if _is_moving else "idle_") + _direction)


func _set_attack_frame(value: float) -> void:
	# Round at the phase midpoint so both authored poses receive visible time.
	# Flooring held on 0/2/4 until the final instant and made the slash teleport.
	frame = clampi(roundi(value), 0, 5)


func _kill_attack_phase_tween() -> void:
	if _attack_phase_tween != null and _attack_phase_tween.is_valid():
		_attack_phase_tween.kill()
	_attack_phase_tween = null


func _direction_name(direction: Vector2) -> String:
	if absf(direction.x) > absf(direction.y):
		return "right" if direction.x > 0.0 else "left"
	return "down" if direction.y > 0.0 else "up"


func _direction_vector(direction_name: String) -> Vector2:
	match direction_name:
		"left":
			return Vector2.LEFT
		"right":
			return Vector2.RIGHT
		"up":
			return Vector2.UP
	return Vector2.DOWN


func _is_riftbreak_casting() -> bool:
	return (
		ability_2_component != null
		and ability_2_component.is_casting()
		and ability_2_component.definition != null
		and ability_2_component.definition.ability_id == &"riftbreak"
	)


func _is_sovereign_pursuit_casting() -> bool:
	return (
		ability_3_component != null
		and ability_3_component.is_casting()
		and ability_3_component.definition != null
		and ability_3_component.definition.ability_id == &"sovereign_pursuit"
	)


func _kill_recoil_tween() -> void:
	if _recoil_tween != null and _recoil_tween.is_valid():
		_recoil_tween.kill()
	_recoil_tween = null
	if is_node_ready():
		position = _base_position


func _on_animation_finished() -> void:
	if String(animation).begins_with("hurt_"):
		resume_locomotion()
