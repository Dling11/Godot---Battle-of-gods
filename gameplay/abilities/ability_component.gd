class_name AbilityComponent
extends Node

enum Phase { IDLE, WIND_UP, ACTIVE, RECOVERY }

signal ability_started
signal phase_changed(phase: Phase, duration_seconds: float)
signal ability_finished
signal cooldown_started(duration_seconds: float)
signal cooldown_finished
signal strike_started(strike_index: int, strike_count: int, duration_seconds: float)
signal hit_landed(target: HurtboxComponent, info: DamageInfo)
signal invulnerability_changed(is_invulnerable: bool)

@export var definition: AbilityDefinition
@export var hitbox: MeleeHitbox
@export var collision_shape: CollisionShape2D

var phase := Phase.IDLE
var cooldown_remaining := 0.0
var _phase_time_remaining := 0.0
var _cast_direction := Vector2.RIGHT
var _equipped_weapon_damage := 0.0
var _critical_chance_ratio := 0.0
var _critical_damage_multiplier := 1.5
var _resolved_damage := 0.0
var _current_strike_index := 0
var _strike_time_remaining := 0.0
var cast_power_multiplier := 1.0


func _ready() -> void:
	set_physics_process(false)
	if hitbox != null:
		hitbox.hit_landed.connect(_on_hit_landed)


func is_ready() -> bool:
	return phase == Phase.IDLE and cooldown_remaining <= 0.0


func owns_contact_feedback() -> bool:
	## Released sequences can supply bounded shared feedback independently of contacts.
	return false


func can_queue_cast() -> bool:
	return cooldown_remaining <= 0.0


func is_casting() -> bool:
	return phase != Phase.IDLE


func clear_cooldown() -> void:
	var had_cooldown := cooldown_remaining > 0.0
	cooldown_remaining = 0.0
	if had_cooldown:
		cooldown_finished.emit()
	_update_processing()


func get_cast_direction() -> Vector2:
	## The cast direction is immutable from wind-up through recovery. Presentation
	## pivots use this instead of live movement-facing input during a technique.
	return _cast_direction


func get_current_strike_index() -> int:
	return _current_strike_index


func is_current_strike_final() -> bool:
	return definition != null and _current_strike_index >= definition.strike_count() - 1


func request_cast(direction: Vector2, equipped_weapon_damage := 0.0) -> bool:
	if (
		not is_ready()
		or definition == null
		or hitbox == null
		or collision_shape == null
		or definition.hitbox_shape == null
	):
		return false
	_cast_direction = direction.normalized() if not direction.is_zero_approx() else Vector2.RIGHT
	_equipped_weapon_damage = equipped_weapon_damage
	cast_power_multiplier = 1.0
	_resolved_damage = definition.resolve_damage(equipped_weapon_damage)
	collision_shape.shape = definition.hitbox_shape
	ability_started.emit()
	if definition.grants_invulnerability:
		invulnerability_changed.emit(true)
	_start_cooldown()
	_enter_phase(Phase.WIND_UP, definition.wind_up_seconds)
	set_physics_process(true)
	return true


func amplify_committed_cast(multiplier: float) -> void:
	## Called by a combat modifier at ability_started, before any strike resolves.
	## Never mutates the shared definition or the equipped weapon resource.
	cast_power_multiplier *= maxf(multiplier, 0.0)
	_equipped_weapon_damage *= maxf(multiplier, 0.0)
	_resolved_damage = definition.resolve_damage(_equipped_weapon_damage)


func get_active_velocity() -> Vector2:
	if phase != Phase.ACTIVE or definition == null:
		return Vector2.ZERO
	return _cast_direction * definition.active_movement_speed


func has_active_movement() -> bool:
	return definition != null and definition.active_movement_speed > 0.0


func get_resolved_damage() -> float:
	return _resolved_damage


func set_critical_profile(chance_ratio: float, damage_multiplier: float) -> void:
	_critical_chance_ratio = clampf(chance_ratio, 0.0, 0.5)
	_critical_damage_multiplier = maxf(damage_multiplier, 1.0)


func supports_ground_targeting() -> bool:
	return false


func get_target_range_pixels() -> float:
	return 0.0


func get_target_radius_pixels() -> float:
	return 0.0


func resolve_ground_target(point: Vector2) -> Vector2:
	return point

func get_target_core_radius_pixels() -> float:
	return 0.0


func get_target_center_offset() -> Vector2:
	return Vector2.ZERO


func is_fixed_length_line_targeted() -> bool:
	return false


func get_target_lane_preview(_point: Vector2) -> Dictionary:
	return {}


func request_cast_at(_target_global_position: Vector2, _equipped_weapon_damage := 0.0) -> bool:
	return false


func cancel_cast() -> void:
	if hitbox != null:
		hitbox.deactivate()
	if phase != Phase.IDLE:
		phase = Phase.IDLE
		_phase_time_remaining = 0.0
		if definition != null and definition.grants_invulnerability:
			invulnerability_changed.emit(false)
		ability_finished.emit()
	_update_processing()


func _physics_process(delta: float) -> void:
	if cooldown_remaining > 0.0:
		cooldown_remaining = maxf(cooldown_remaining - delta, 0.0)
		if cooldown_remaining <= 0.0:
			_on_cooldown_elapsed()
	if phase != Phase.IDLE:
		if phase == Phase.ACTIVE:
			_advance_active_strikes(delta)
		_phase_time_remaining -= delta
		while _phase_time_remaining <= 0.0 and phase != Phase.IDLE:
			var overflow := -_phase_time_remaining
			_advance_phase()
			_phase_time_remaining -= overflow
	_update_processing()


func _start_cooldown() -> void:
	cooldown_remaining = definition.cooldown_seconds
	cooldown_started.emit(definition.cooldown_seconds)


func _on_cooldown_elapsed() -> void:
	cooldown_finished.emit()


func _advance_phase() -> void:
	match phase:
		Phase.WIND_UP:
			_enter_phase(Phase.ACTIVE, definition.active_seconds)
			_current_strike_index = 0
			_start_current_strike()
		Phase.ACTIVE:
			hitbox.deactivate()
			_enter_phase(Phase.RECOVERY, definition.recovery_seconds)
		Phase.RECOVERY:
			phase = Phase.IDLE
			if definition.grants_invulnerability:
				invulnerability_changed.emit(false)
			ability_finished.emit()


func _enter_phase(next_phase: Phase, duration_seconds: float) -> void:
	phase = next_phase
	_phase_time_remaining = maxf(duration_seconds, 0.0001)
	phase_changed.emit(phase, duration_seconds)


func _advance_active_strikes(delta: float) -> void:
	if definition == null or definition.strike_count() <= 1:
		return
	_strike_time_remaining -= delta
	while _strike_time_remaining <= 0.0 and _current_strike_index < definition.strike_count() - 1:
		_current_strike_index += 1
		_start_current_strike()


func _start_current_strike() -> void:
	if definition == null or hitbox == null:
		return
	var strike_count := definition.strike_count()
	_strike_time_remaining = definition.active_seconds / float(strike_count)
	hitbox.activate(
		definition.resolve_strike_damage(_equipped_weapon_damage, _current_strike_index),
		owner,
		_cast_direction,
		definition.resolve_strike_knockback(_current_strike_index),
		definition.resolve_strike_stagger(_current_strike_index),
		_critical_chance_ratio,
		_critical_damage_multiplier,
		definition.resolve_strike_stun(_current_strike_index),
		definition.damage_type
	)
	strike_started.emit(_current_strike_index, strike_count, _strike_time_remaining)


func _update_processing() -> void:
	set_physics_process(phase != Phase.IDLE or cooldown_remaining > 0.0)


func _on_hit_landed(target: HurtboxComponent, info: DamageInfo) -> void:
	hit_landed.emit(target, info)
