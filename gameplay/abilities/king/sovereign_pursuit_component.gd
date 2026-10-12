class_name SovereignPursuitComponent
extends AbilityComponent

## Moves the player toward one validated ground point, then resolves one radial
## contact at the actual collision-safe landing position.

var _target_global_position := Vector2.ZERO
const Landing = preload("res://gameplay/abilities/king/pursuit_landing.gd")
var _world_collision_before_jump := true
var _last_safe_position := Vector2.ZERO
var _jump_in_progress := false
signal charges_changed(available: int, maximum: int)
var charges_available := 1


func _ready() -> void:
	super._ready()
	charges_available = get_max_charges()


func get_max_charges() -> int:
	var pursuit := definition as SovereignPursuitDefinition
	return pursuit.max_charges if pursuit != null else 1


func is_ready() -> bool:
	return phase == Phase.IDLE and charges_available > 0


func can_queue_cast() -> bool:
	return charges_available > 0


func clear_cooldown() -> void:
	charges_available = get_max_charges()
	super.clear_cooldown()
	charges_changed.emit(charges_available, get_max_charges())


func apply_rank(value: int) -> void:
	if value < SovereignPursuitDefinition.Rank.FOUNDATION or value > SovereignPursuitDefinition.Rank.MATURE:
		return
	var current := definition as SovereignPursuitDefinition
	if current == null or phase != Phase.IDLE:
		return
	var previous_capacity := current.max_charges
	var upgraded := current.duplicate(true) as SovereignPursuitDefinition
	upgraded.configure_rank(value)
	definition = upgraded
	charges_available = mini(charges_available + maxi(upgraded.max_charges - previous_capacity, 0), upgraded.max_charges)
	if charges_available >= upgraded.max_charges:
		cooldown_remaining = 0.0
	elif cooldown_remaining <= 0.0:
		cooldown_remaining = upgraded.cooldown_seconds
	_update_processing()
	charges_changed.emit(charges_available, upgraded.max_charges)


func _start_cooldown() -> void:
	charges_available -= 1
	if cooldown_remaining <= 0.0:
		cooldown_remaining = definition.cooldown_seconds
	cooldown_started.emit(cooldown_remaining)
	charges_changed.emit(charges_available, get_max_charges())


func _on_cooldown_elapsed() -> void:
	charges_available = mini(charges_available + 1, get_max_charges())
	if charges_available < get_max_charges():
		cooldown_remaining = definition.cooldown_seconds
	cooldown_finished.emit()
	charges_changed.emit(charges_available, get_max_charges())


func request_cast_at(target_global_position: Vector2, equipped_weapon_damage := 0.0) -> bool:
	var pursuit := definition as SovereignPursuitDefinition
	if pursuit == null or owner == null or not is_ready():
		return false
	var actor := owner as Player
	if actor == null:
		return false
	var origin: Vector2 = actor.global_position
	var offset := target_global_position - origin
	if offset.length() > pursuit.target_range_pixels:
		offset = offset.normalized() * pursuit.target_range_pixels
	_target_global_position = resolve_ground_target(origin + offset)
	offset = _target_global_position - origin
	return request_cast(offset, equipped_weapon_damage)


func resolve_ground_target(point: Vector2) -> Vector2:
	var actor := owner as Player
	return Landing.resolve(actor, point, get_target_range_pixels()) if actor != null else point


func supports_ground_targeting() -> bool:
	return true


func get_target_range_pixels() -> float:
	var pursuit := definition as SovereignPursuitDefinition
	return pursuit.target_range_pixels if pursuit != null else 0.0


func get_target_radius_pixels() -> float:
	var pursuit := definition as SovereignPursuitDefinition
	return pursuit.landing_radius_pixels if pursuit != null else 0.0


func get_target_center_offset() -> Vector2:
	return Vector2(0.0, (definition as SovereignPursuitDefinition).ground_center_offset_y)


func get_active_velocity() -> Vector2:
	if phase != Phase.ACTIVE or owner == null:
		return Vector2.ZERO
	var actor := owner as Player
	if actor == null:
		return Vector2.ZERO
	if Landing.is_clear(actor, actor.global_position):
		_last_safe_position = actor.global_position
	var remaining: Vector2 = _target_global_position - actor.global_position
	if remaining.length_squared() <= 4.0:
		return Vector2.ZERO
	return remaining.normalized() * minf(remaining.length() / maxf(_phase_time_remaining, 0.016), 1000.0)


func has_active_movement() -> bool:
	return phase == Phase.ACTIVE


func cancel_cast() -> void:
	if phase == Phase.ACTIVE:
		invulnerability_changed.emit(false)
	_finish_jump()
	_reset_hitbox_position()
	super.cancel_cast()


func _exit_tree() -> void:
	_finish_jump()


func _start_jump() -> void:
	var actor := owner as Player
	_jump_in_progress = true
	_last_safe_position = actor.global_position
	_world_collision_before_jump = actor.get_collision_mask_value(1)
	actor.set_collision_mask_value(1, false)


func _finish_jump() -> void:
	var actor := owner as Player
	if is_instance_valid(actor) and actor.is_inside_tree() and _jump_in_progress:
		if not Landing.is_clear(actor, actor.global_position):
			actor.global_position = _last_safe_position
	if is_instance_valid(actor) and _jump_in_progress:
		actor.set_collision_mask_value(1, _world_collision_before_jump)
	_jump_in_progress = false


func _advance_phase() -> void:
	match phase:
		Phase.WIND_UP:
			# Revalidate after wind-up in case a world obstacle changed.
			_target_global_position = resolve_ground_target(_target_global_position)
			_start_jump()
			_enter_phase(Phase.ACTIVE, definition.active_seconds)
			invulnerability_changed.emit(true)
		Phase.ACTIVE:
			invulnerability_changed.emit(false)
			_finish_jump()
			_land()
			_enter_phase(Phase.RECOVERY, definition.recovery_seconds)
		Phase.RECOVERY:
			if hitbox != null:
				hitbox.deactivate()
			_reset_hitbox_position()
			phase = Phase.IDLE
			ability_finished.emit()


func _land() -> void:
	var pursuit := definition as SovereignPursuitDefinition
	if pursuit == null or hitbox == null:
		return
	_current_strike_index = 0
	# AbilityPivot rotates for directional skills. Pursuit is a world-space landing
	# circle, so place it explicitly at King's feet instead of inheriting that turn.
	hitbox.global_position = (owner as Node2D).global_position + Vector2(0.0, pursuit.ground_center_offset_y)
	hitbox.activate_radial(
		definition.resolve_strike_damage(_equipped_weapon_damage, 0),
		owner,
		hitbox.global_position,
		definition.resolve_strike_knockback(0),
		definition.resolve_strike_stagger(0),
		_critical_chance_ratio,
		_critical_damage_multiplier,
		definition.resolve_strike_stun(0),
		definition.damage_type
	)
	strike_started.emit(0, 1, definition.recovery_seconds)


func _reset_hitbox_position() -> void:
	if hitbox != null:
		hitbox.position = Vector2.ZERO
