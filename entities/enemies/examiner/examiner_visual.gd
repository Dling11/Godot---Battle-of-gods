extends Node2D

@export var body: AnimatedSprite2D
@export var shadow: Polygon2D

var _direction := "down"
var _state := Examiner.State.SPAWNING
var _moving := false
var _base_position := Vector2(0.0, -48.0)
var _tween: Tween
var _impact_tween: Tween
var _charge_elapsed := 0.0
var _charge_duration := 1.0


func _process(delta: float) -> void:
	if _state not in [Examiner.State.ORB_CHARGE, Examiner.State.FIRMAMENT_CHARGE]:
		return
	_charge_elapsed += delta
	var progress := clampf(_charge_elapsed / _charge_duration, 0, 1)
	# Brace around the feet: the approved body stays at native scale.
	var angle := sin(_charge_elapsed * 5.0) * (0.008 + progress * 0.018)
	body.rotation = angle
	body.position = _base_position.rotated(angle)


func _ready() -> void:
	body.position = _base_position
	body.play(&"idle_down")


func set_facing(direction: Vector2) -> void:
	var next_direction := _direction_name(direction)
	if next_direction == _direction:
		return
	var previous_direction := _direction
	_direction = next_direction
	# Bounded controller tracking may cross a cardinal during anticipation.
	# Retarget the same pose without restarting its authored phase clock.
	if (_state == Examiner.State.APPROACH and _moving) or _state in [Examiner.State.COMBO_WIND_UP, Examiner.State.SWEEP_WIND_UP, Examiner.State.CHARGE_WIND_UP, Examiner.State.SLAM_WIND_UP]:
		var key := String(body.animation).trim_suffix("_" + previous_direction) + "_" + _direction
		if body.sprite_frames.has_animation(key):
			var saved_frame := body.frame
			var saved_progress := body.frame_progress
			body.play(key)
			body.set_frame_and_progress(saved_frame, saved_progress)
	_restore()


func set_moving(value: bool) -> void:
	_moving = value
	if _state == Examiner.State.APPROACH:
		_restore()


func play_state(state: Examiner.State, duration_seconds: float) -> void:
	_state = state
	_charge_elapsed = 0.0
	_charge_duration = maxf(duration_seconds, 0.01)
	body.rotation = 0.0
	if _tween != null and _tween.is_valid():
		_tween.kill()
	if _impact_tween != null and _impact_tween.is_valid():
		_impact_tween.kill()
	body.position = _base_position
	body.modulate = Color.WHITE
	match state:
		Examiner.State.SPAWNING:
			body.play("idle_down")
			body.modulate.a = 0.0
			_tween = create_tween()
			_tween.tween_property(body, "modulate:a", 1.0, duration_seconds)
		Examiner.State.APPROACH:
			_restore()
		Examiner.State.COMBO_WIND_UP:
			_play_fit("thrust_" + _direction, duration_seconds)
		Examiner.State.THRUST_ACTIVE:
			_play_fit("thrust_strike_" + _direction, duration_seconds)
		Examiner.State.COMBO_GAP:
			_play_fit("thrust_recovery_" + _direction, duration_seconds)
		Examiner.State.SWEEP_WIND_UP:
			_play_fit("sweep_wind_up_" + _direction, duration_seconds)
		Examiner.State.SWEEP_ACTIVE:
			_play_fit("sweep_strike_" + _direction, duration_seconds)
		Examiner.State.COMBO_RECOVERY:
			_play_fit("sweep_recovery_" + _direction, duration_seconds)
		Examiner.State.CHARGE_WIND_UP, Examiner.State.PURSUIT_WIND_UP:
			_play_fit("charge_wind_up_" + _direction, duration_seconds)
		Examiner.State.CHARGE_TRAVEL, Examiner.State.PURSUIT_TRAVEL:
			_play_fit("charge_travel_" + _direction, duration_seconds)
		Examiner.State.CHARGE_IMPACT:
			_hold("charge_travel_" + _direction, 2)
		Examiner.State.CHARGE_RECOVERY, Examiner.State.PURSUIT_RECOVERY:
			_play_fit("charge_recovery_" + _direction, duration_seconds)
		Examiner.State.SLAM_WIND_UP:
			_play_fit("slam_wind_up_" + _direction, duration_seconds)
		Examiner.State.HELD_JUDGMENT:
			# Raise promptly, then hold the complete overhead anticipation pose.
			_play_fit("slam_wind_up_" + _direction, 0.38)
		Examiner.State.SLAM_ACTIVE:
			_play_fit("slam_contact_" + _direction, duration_seconds)
		Examiner.State.SLAM_RECOVERY:
			_play_fit("slam_recovery_" + _direction, duration_seconds)
		Examiner.State.REFUTATION_WIND_UP:
			_play_fit("refutation_wind_up_" + _direction, duration_seconds)
		Examiner.State.REFUTATION_ACTIVE:
			_play_fit("refutation_active_" + _direction, duration_seconds)
		Examiner.State.REFUTATION_RECOVERY:
			_play_fit("refutation_recovery_" + _direction, duration_seconds)
		Examiner.State.AXIOM_WIND_UP:
			_play_fit("axiom_wind_up_" + _direction, duration_seconds)
		Examiner.State.AXIOM_CUT_ONE:
			_play_fit("axiom_cut_one_" + _direction, duration_seconds)
		Examiner.State.AXIOM_CUT_TWO:
			_play_fit("axiom_cut_two_" + _direction, duration_seconds)
		Examiner.State.AXIOM_DASH:
			_play_fit("axiom_dash_" + _direction, duration_seconds)
		Examiner.State.AXIOM_RECOVERY:
			_play_fit("axiom_recovery_" + _direction, duration_seconds)
		Examiner.State.TRIAL_CHANNEL:
			_play_fit("refutation_wind_up_" + _direction, 0.4)
		Examiner.State.ORB_CHARGE, Examiner.State.CROWNFALL, Examiner.State.BERSERK_AWAKEN, Examiner.State.FIRMAMENT_CHARGE:
			_play_fit("slam_wind_up_" + _direction, 0.55)
		Examiner.State.FIRMAMENT_BARRAGE:
			_play_fit("slam_contact_" + _direction, 0.2)
			_tween = create_tween()
			_tween.tween_interval(0.2)
			_tween.tween_callback(func() -> void: _play_fit("slam_recovery_" + _direction, 0.35))
			_tween.tween_interval(0.35)
			_tween.tween_callback(func() -> void: _hold("refutation_active_" + _direction, 1))
		Examiner.State.ORB_RELEASE:
			_play_fit("thrust_strike_" + _direction, duration_seconds)
		Examiner.State.ORB_RECOVERY:
			_play_fit("thrust_recovery_" + _direction, duration_seconds)
		Examiner.State.GUARD_BROKEN:
			_play_fit("descent_impact_" + _direction, 0.22)
			body.modulate = Color(1.3, 1.15, 0.9)
			_tween = create_tween()
			_tween.tween_property(body, "modulate", Color.WHITE, 0.18)
		Examiner.State.GUARD_RECOVERY:
			_play_fit("descent_recovery_" + _direction, duration_seconds)
		Examiner.State.VICTORY_KNEEL:
			_play_fit("descent_impact_" + _direction, 0.28)
		Examiner.State.VICTORY_RISE:
			_play_fit("descent_recovery_" + _direction, duration_seconds)
		Examiner.State.VICTORY_HOLD:
			body.play("idle_" + _direction)
			body.speed_scale = 1.0
		Examiner.State.PHASE_STANCE:
			body.play("idle_" + _direction)
		Examiner.State.DESCENT_PREPARE:
			_play_fit("descent_prepare_" + _direction, duration_seconds)
		Examiner.State.DESCENT_LAUNCH:
			_play_fit("descent_launch_" + _direction, duration_seconds)
		Examiner.State.DESCENT_ABSENT:
			_hold("descent_launch_" + _direction, 3)
		Examiner.State.DESCENT_FALL:
			_play_fit("descent_fall_" + _direction, duration_seconds)
		Examiner.State.DESCENT_IMPACT:
			_play_fit("descent_impact_" + _direction, duration_seconds)
			_play_divine_descent_impact_accent()
		Examiner.State.DESCENT_RECOVERY:
			_play_fit("descent_recovery_" + _direction, duration_seconds)
		Examiner.State.WITHDRAWAL:
			_play_fit("withdrawal_" + _direction, duration_seconds)
			_tween = create_tween()
			_tween.tween_interval(maxf(duration_seconds - 0.55, 0.05))
			_tween.tween_property(body, "modulate:a", 0.0, 0.55)


func play_hurt(_info: DamageInfo) -> void:
	if _state != Examiner.State.APPROACH:
		return
	_play_fit("hurt_" + _direction, 0.18)


func play_refutation_flash() -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	body.modulate = Color(1.35, 1.22, 0.72, 1.0)
	_tween = create_tween()
	_tween.tween_property(body, "modulate", Color.WHITE, 0.18)


func _restore() -> void:
	if _state == Examiner.State.APPROACH:
		body.speed_scale = 1.0
		body.play(("walk_" if _moving else "idle_") + _direction)


func _play_fit(animation: String, duration_seconds: float) -> void:
	body.stop()
	body.speed_scale = 1.0
	var frames := body.sprite_frames
	var count := frames.get_frame_count(animation)
	if duration_seconds > 0.0 and count > 0:
		var authored := float(count) / maxf(frames.get_animation_speed(animation), 0.01)
		body.speed_scale = authored / maxf(duration_seconds, 0.01)
	body.play(animation)


func _hold(animation: String, frame_index: int) -> void:
	body.speed_scale = 1.0
	body.play(animation)
	body.set_frame_and_progress(mini(frame_index, body.sprite_frames.get_frame_count(animation) - 1), 0.0)
	body.pause()


func _play_divine_descent_impact_accent() -> void:
	# A three-frame silhouette accent uses the actual moving body. The old
	# fixed-position red eyes floated above crouched/reversed landing poses.
	body.modulate = Color(0.018, 0.012, 0.022, 1.0)
	_impact_tween = create_tween()
	_impact_tween.tween_interval(0.055)
	_impact_tween.tween_callback(func() -> void:
		body.modulate = Color.WHITE
	)


func _direction_name(direction: Vector2) -> String:
	if absf(direction.x) > absf(direction.y):
		return "right" if direction.x > 0.0 else "left"
	return "down" if direction.y > 0.0 else "up"
