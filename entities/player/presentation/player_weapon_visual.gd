class_name PlayerWeaponVisual
extends Node2D

## Presentation-only detached weapon orbit for characters that use modular weapons. It
## observes authoritative combat phases; SwordPivot/MeleeHitbox own reach/damage.

@export var weapon: WeaponDefinition
@export var weapon_sprite: Sprite2D
@export var swing_trail: Line2D
@export var swing_smoke: Line2D
@export var ability_component: AbilityComponent
@export var ability_2_component: AbilityComponent
@export var ability_3_component: AbilityComponent
@export var ability_4_component: AbilityComponent
@export var show_weapon_sprite := true

var _direction := &"down"
var _action_direction := &"down"
var _action_locked := false
var _pose_tween: Tween
var _trail_tween: Tween
var _accent_tween: Tween
var _base_weapon_scale := Vector2.ONE
var _fallback_attack_style := SwordAttackStyleDefinition.new()
var _normal_swing_sequence_index := -1
var _normal_swing_variant_index := 0

func _ready() -> void:
	if not set_weapon_definition(weapon):
		push_error("PlayerWeaponVisual requires a weapon with world art and a Sprite2D.")
		visible = false
		return
	_apply_idle_pose()


func set_weapon_definition(next_weapon: WeaponDefinition) -> bool:
	## Changes only the detached weapon presentation. Player coordinates this
	## with MeleeAttackComponent so gameplay and art always use the same data.
	if (
		next_weapon == null
		or weapon_sprite == null
		or (next_weapon.world_texture == null and not next_weapon.uses_integrated_visual)
	):
		return false
	_kill_pose_tween()
	_kill_accent_tween()
	_hide_swing_trail()
	weapon = next_weapon
	_normal_swing_sequence_index = -1
	_normal_swing_variant_index = 0
	visible = true
	weapon_sprite.visible = show_weapon_sprite and not weapon.uses_integrated_visual
	weapon_sprite.texture = weapon.world_texture
	weapon_sprite.position = weapon.sprite_offset_from_grip
	_base_weapon_scale = Vector2.ONE * weapon.world_visual_scale
	weapon_sprite.scale = _base_weapon_scale
	weapon_sprite.modulate = Color.WHITE
	var style := _attack_style()
	if swing_trail != null:
		swing_trail.visible = false
		swing_trail.width = style.trail_width
		swing_trail.default_color = style.trail_color
	if swing_smoke != null:
		swing_smoke.visible = false
		swing_smoke.width = style.trail_width + 5.0
		swing_smoke.default_color = Color(0.82, 0.9, 1.0, 0.34)
	if is_node_ready() and not _action_locked:
		_apply_idle_pose()
	return true


func set_facing_direction(direction: Vector2) -> void:
	_direction = _direction_name(direction)
	if not _action_locked:
		_apply_idle_pose()


func play_attack_phase(phase: int, duration_seconds: float) -> void:
	if weapon != null and weapon.combo != null:
		_hide_swing_trail()
		return
	_play_action_phase(phase, duration_seconds, false)


func play_ability_phase(phase: int, duration_seconds: float) -> void:
	var active_ability := _get_casting_ability()
	if (
		active_ability != null
		and active_ability.definition != null
		and active_ability.definition.ability_id in [&"echoing_sever", &"riftbreak", &"sovereign_pursuit", &"king_skill_4"]
	):
		_play_integrated_weapon_ability_phase(phase)
		return
	if (
		active_ability != null
		and active_ability.definition != null
		and active_ability.definition.presentation_style
			== AbilityDefinition.PresentationStyle.THRUST
	):
		_play_thrust_phase(phase, duration_seconds)
		return
	_play_action_phase(phase, duration_seconds, true)


func _play_integrated_weapon_ability_phase(phase: int) -> void:
	## King carries his sword inside the body atlas and Echoing Sever owns a
	## dedicated VFX sprite. The shared detached-weapon trail is modular presentation
	## and would otherwise create a second normal slash behind King's skill.
	if phase == AbilityComponent.Phase.WIND_UP:
		_action_locked = true
		_action_direction = _direction
	_kill_pose_tween()
	_kill_accent_tween()
	_hide_swing_trail()
	if weapon_sprite != null:
		weapon_sprite.visible = false


func _get_casting_ability() -> AbilityComponent:
	for component in [ability_component, ability_2_component, ability_3_component, ability_4_component]:
		if component != null and component.is_casting():
			return component
	return null


func resume_locomotion() -> void:
	_kill_pose_tween()
	_kill_accent_tween()
	_hide_swing_trail()
	_action_locked = false
	_apply_idle_pose()


func play_defeat() -> void:
	_kill_pose_tween()
	_kill_accent_tween()
	_hide_swing_trail()
	_action_locked = true
	z_index = 2
	_pose_tween = create_tween().set_parallel(true)
	_pose_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	_pose_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_pose_tween.tween_property(self, "position", position + Vector2(3.0, 9.0), 0.55)
	_pose_tween.tween_property(self, "rotation", rotation + 1.15, 0.55)


func _play_action_phase(phase: int, duration_seconds: float, is_ability: bool) -> void:
	if weapon_sprite == null or not visible:
		return
	if phase == MeleeAttackComponent.Phase.WIND_UP:
		_action_locked = true
		_action_direction = _direction
		if not is_ability:
			_normal_swing_sequence_index = posmod(
				_normal_swing_sequence_index + 1,
				_attack_style().normal_variant_count()
			)
			_normal_swing_variant_index = _normal_swing_sequence_index
	_set_depth(_action_direction)
	var style := _attack_style()
	var wind_up_arc := (
		style.ability_wind_up_arc
		if is_ability
		else style.normal_variant_wind_up_arc(_normal_swing_variant_index)
	)
	var strike_arc := (
		style.ability_strike_arc
		if is_ability
		else style.normal_variant_strike_arc(_normal_swing_variant_index)
	)
	var swing_direction := (
		1.0
		if is_ability
		else style.normal_variant_direction(_normal_swing_variant_index)
	)
	var rotations := _attack_rotations(
		_action_direction,
		wind_up_arc,
		strike_arc,
		swing_direction
	)
	var wind_up_position := _attack_anchor(_action_direction, MeleeAttackComponent.Phase.WIND_UP, is_ability)
	var active_position := _attack_anchor(_action_direction, MeleeAttackComponent.Phase.ACTIVE, is_ability)
	match phase:
		MeleeAttackComponent.Phase.WIND_UP:
			_hide_swing_trail()
			_tween_pose(wind_up_position, rotations.x, duration_seconds, false)
		MeleeAttackComponent.Phase.ACTIVE:
			_tween_pose(active_position, rotations.y, duration_seconds, true)
			_play_strike_accent(duration_seconds)
			_show_swing_trail(
				rotations.x,
				rotations.y,
				(wind_up_position + active_position) * 0.5,
				duration_seconds
			)
		MeleeAttackComponent.Phase.RECOVERY:
			var idle: Transform2D = _idle_transform(_action_direction)
			_tween_pose(idle.origin, idle.get_rotation(), duration_seconds, false)


func _play_thrust_phase(phase: int, duration_seconds: float) -> void:
	if weapon_sprite == null or not visible:
		return
	if phase == AbilityComponent.Phase.WIND_UP:
		_action_locked = true
		_action_direction = _direction
	_set_depth(_action_direction)
	_hide_swing_trail()
	var forward_rotation := Vector2.UP.angle_to(_direction_vector(_action_direction))
	match phase:
		AbilityComponent.Phase.WIND_UP:
			_tween_pose(
				_thrust_anchor(_action_direction, false),
				forward_rotation,
				duration_seconds,
				false
			)
		AbilityComponent.Phase.ACTIVE:
			_tween_pose(
				_thrust_anchor(_action_direction, true),
				forward_rotation,
				duration_seconds,
				true
			)
			_play_strike_accent(duration_seconds)
		AbilityComponent.Phase.RECOVERY:
			var idle := _idle_transform(_action_direction)
			_tween_pose(idle.origin, idle.get_rotation(), duration_seconds, false)


func _thrust_anchor(direction: StringName, is_active: bool) -> Vector2:
	match direction:
		&"left":
			return Vector2(-17.0, -9.0) if is_active else Vector2(-7.0, -9.0)
		&"right":
			return Vector2(17.0, -9.0) if is_active else Vector2(7.0, -9.0)
		&"up":
			return Vector2(-2.0, -19.0) if is_active else Vector2(-2.0, -8.0)
	return Vector2(2.0, 1.0) if is_active else Vector2(2.0, -12.0)


func _apply_idle_pose() -> void:
	var idle: Transform2D = _idle_transform(_direction)
	position = idle.origin
	rotation = idle.get_rotation()
	_set_depth(_direction)


func _idle_transform(direction: StringName) -> Transform2D:
	match direction:
		&"left":
			return Transform2D(-1.72, _weapon_anchor(direction))
		&"right":
			return Transform2D(1.72, _weapon_anchor(direction))
		&"up":
			return Transform2D(-0.35, _weapon_anchor(direction))
	# The down-facing hilt begins against the torso while the blade rises
	# outward toward screen-left, away from the character's head. This keeps the detached
	# weapon visibly controlled without crossing the face.
	return Transform2D(-0.45, _weapon_anchor(direction))


func _weapon_anchor(direction: StringName) -> Vector2:
	match direction:
		&"left":
			return Vector2(-9.0, -11.0)
		&"right":
			return Vector2(9.0, -11.0)
		&"up":
			return Vector2(10.0, -12.0)
	# Place the hilt near the left torso edge; rotation sends the tip outward.
	return Vector2(-6.0, -10.0)


func _attack_anchor(direction: StringName, phase: int, is_ability: bool) -> Vector2:
	var style := _attack_style()
	var active_extension := style.ability_active_extension if is_ability else (
		style.normal_variant_active_extension(_normal_swing_variant_index)
	)
	match direction:
		&"left":
			return Vector2(-10.0, -13.0) if phase == MeleeAttackComponent.Phase.WIND_UP else Vector2(-13.0 - active_extension, -8.0)
		&"right":
			return Vector2(10.0, -13.0) if phase == MeleeAttackComponent.Phase.WIND_UP else Vector2(13.0 + active_extension, -8.0)
		&"up":
			return Vector2(8.0, -12.0) if phase == MeleeAttackComponent.Phase.WIND_UP else Vector2(5.0, -17.0 - active_extension)
	return Vector2(-8.0, -12.0) if phase == MeleeAttackComponent.Phase.WIND_UP else Vector2(-5.0, -5.0 + active_extension)


func _attack_rotations(
	direction: StringName,
	wind_up_arc: float,
	strike_arc: float,
	swing_direction: float = 1.0
) -> Vector2:
	# Side attacks are true screen-space mirrors. Using the direction's
	# perpendicular vector inverted the left arc vertically and made it look like
	# a different swing rather than the right attack's mirrored counterpart.
	if direction == &"left":
		var right_forward_rotation := Vector2.UP.angle_to(Vector2.RIGHT)
		return Vector2(
			-(right_forward_rotation - wind_up_arc * swing_direction),
			-(right_forward_rotation + strike_arc * swing_direction)
		)
	var forward_rotation := Vector2.UP.angle_to(_direction_vector(direction))
	return Vector2(
		forward_rotation - wind_up_arc * swing_direction,
		forward_rotation + strike_arc * swing_direction
	)


func _set_depth(direction: StringName) -> void:
	z_index = -1 if direction == &"up" else 2


func _tween_pose(
	target_position: Vector2,
	target_rotation: float,
	duration_seconds: float,
	is_strike: bool
) -> void:
	_kill_pose_tween()
	var closest_target := rotation + wrapf(target_rotation - rotation, -PI, PI)
	_pose_tween = create_tween().set_parallel(true)
	_pose_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	_pose_tween.set_trans(Tween.TRANS_EXPO if is_strike else Tween.TRANS_QUAD)
	_pose_tween.set_ease(Tween.EASE_OUT)
	var duration := maxf(duration_seconds, 0.001)
	_pose_tween.tween_property(self, "position", target_position, duration)
	_pose_tween.tween_property(self, "rotation", closest_target, duration)


func _show_swing_trail(
	start_rotation: float,
	end_rotation: float,
	center: Vector2,
	duration_seconds: float
) -> void:
	if swing_trail == null:
		return
	if _trail_tween != null and _trail_tween.is_valid():
		_trail_tween.kill()
	var style := _attack_style()
	var points := PackedVector2Array()
	var point_count := style.trail_point_count
	var cleave_radius := maxf(
		weapon.swing_visual_radius,
		maxf(
			weapon.get_melee_forward_reach_pixels() * 0.8,
			weapon.get_melee_half_width_pixels() * 0.9
		)
	)
	for point_index in range(point_count):
		var weight := float(point_index) / float(point_count - 1)
		var angle := lerp_angle(start_rotation, end_rotation, weight)
		points.append(center + Vector2.UP.rotated(angle) * cleave_radius)
	swing_trail.points = points
	swing_trail.z_index = -1 if _action_direction == &"up" else 1
	swing_trail.width = style.trail_width
	swing_trail.default_color = style.trail_color
	swing_trail.modulate.a = 0.95
	swing_trail.visible = true
	if swing_smoke != null:
		swing_smoke.points = points
		swing_smoke.z_index = -2 if _action_direction == &"up" else 0
		swing_smoke.width = style.trail_width + 5.0
		swing_smoke.default_color = Color(0.82, 0.9, 1.0, 0.34)
		swing_smoke.modulate.a = 0.8
		swing_smoke.visible = true
	_trail_tween = create_tween().set_parallel(true)
	_trail_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	_trail_tween.tween_property(
		swing_trail,
		"modulate:a",
		0.0,
		maxf(duration_seconds + style.trail_fade_padding_seconds, 0.08)
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_trail_tween.tween_property(
		swing_trail,
		"width",
		0.75,
		maxf(duration_seconds + style.trail_fade_padding_seconds, 0.08)
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if swing_smoke != null:
		_trail_tween.tween_property(
			swing_smoke,
			"modulate:a",
			0.0,
			maxf(duration_seconds + style.trail_fade_padding_seconds + 0.04, 0.12)
		).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		_trail_tween.tween_property(
			swing_smoke,
			"width",
			2.0,
			maxf(duration_seconds + style.trail_fade_padding_seconds + 0.04, 0.12)
		).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_trail_tween.chain().tween_callback(swing_trail.hide)
	if swing_smoke != null:
		_trail_tween.chain().tween_callback(swing_smoke.hide)


func _play_strike_accent(duration_seconds: float) -> void:
	_kill_accent_tween()
	var style := _attack_style()
	var peak_seconds := maxf(duration_seconds * 0.3, 0.025)
	var settle_seconds := maxf(duration_seconds - peak_seconds, 0.025)
	_accent_tween = create_tween()
	_accent_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	_accent_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_accent_tween.tween_property(
		weapon_sprite,
		"scale",
		_base_weapon_scale * style.strike_scale_multiplier,
		peak_seconds
	)
	_accent_tween.parallel().tween_property(
		weapon_sprite,
		"modulate",
		style.strike_tint,
		peak_seconds
	)
	_accent_tween.tween_property(weapon_sprite, "scale", _base_weapon_scale, settle_seconds)
	_accent_tween.parallel().tween_property(weapon_sprite, "modulate", Color.WHITE, settle_seconds)


func _hide_swing_trail() -> void:
	if _trail_tween != null and _trail_tween.is_valid():
		_trail_tween.kill()
	var style := _attack_style()
	if swing_trail != null:
		swing_trail.visible = false
		swing_trail.width = style.trail_width
		swing_trail.default_color = style.trail_color
		swing_trail.modulate.a = 1.0
	if swing_smoke != null:
		swing_smoke.visible = false
		swing_smoke.width = style.trail_width + 5.0
		swing_smoke.default_color = Color(0.82, 0.9, 1.0, 0.34)
		swing_smoke.modulate.a = 1.0


func _kill_pose_tween() -> void:
	if _pose_tween != null and _pose_tween.is_valid():
		_pose_tween.kill()


func _kill_accent_tween() -> void:
	if _accent_tween != null and _accent_tween.is_valid():
		_accent_tween.kill()
	if weapon_sprite != null:
		weapon_sprite.scale = _base_weapon_scale
		weapon_sprite.modulate = Color.WHITE


func _direction_vector(direction: StringName) -> Vector2:
	match direction:
		&"left":
			return Vector2.LEFT
		&"right":
			return Vector2.RIGHT
		&"up":
			return Vector2.UP
	return Vector2.DOWN


func _direction_name(direction: Vector2) -> StringName:
	if absf(direction.x) > absf(direction.y):
		return &"right" if direction.x > 0.0 else &"left"
	return &"down" if direction.y > 0.0 else &"up"


func _attack_style() -> SwordAttackStyleDefinition:
	if weapon != null and weapon.attack_style != null and weapon.attack_style.is_valid_style():
		return weapon.attack_style
	return _fallback_attack_style
