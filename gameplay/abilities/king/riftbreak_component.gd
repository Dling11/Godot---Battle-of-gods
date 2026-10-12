class_name RiftbreakComponent
extends AbilityComponent

## One radial contact: campaign self-area, or an explicitly configured ground target.
## MeleeHitbox still owns per-target deduplication and accepted damage delivery.
var _target_global_position := Vector2.ZERO


func supports_ground_targeting() -> bool:
	return definition is RiftbreakDefinition and definition.target_range_pixels > 0.0


func get_target_range_pixels() -> float:
	return (definition as RiftbreakDefinition).target_range_pixels


func get_target_radius_pixels() -> float:
	return (definition as RiftbreakDefinition).effect_radius_pixels


func get_target_core_radius_pixels() -> float:
	return (definition as RiftbreakDefinition).stun_core_radius_pixels


func get_target_global_position() -> Vector2:
	return _target_global_position if supports_ground_targeting() else (owner as Node2D).global_position


func request_cast_at(target_global_position: Vector2, equipped_weapon_damage := 0.0) -> bool:
	if not supports_ground_targeting() or not is_ready() or not owner is Node2D:
		return false
	var actor := owner as Node2D
	var offset := (target_global_position - actor.global_position).limit_length(get_target_range_pixels())
	var target := actor.global_position + offset
	if not offset.is_zero_approx():
		var query := PhysicsRayQueryParameters2D.create(actor.global_position, target, 1)
		query.exclude = [actor.get_rid()]
		var obstacle := actor.get_world_2d().direct_space_state.intersect_ray(query)
		if not obstacle.is_empty():
			target = obstacle.position + obstacle.normal * 2.0
	_target_global_position = target
	return request_cast(target - actor.global_position, equipped_weapon_damage)


func _start_current_strike() -> void:
	var riftbreak_definition := definition as RiftbreakDefinition
	if riftbreak_definition == null:
		super._start_current_strike()
		return
	_current_strike_index = 0
	_strike_time_remaining = definition.active_seconds
	if supports_ground_targeting():
		hitbox.global_position = _target_global_position
	else:
		hitbox.position = Vector2(0.0, riftbreak_definition.ground_center_offset_y)
	hitbox.set("stun_core_radius", riftbreak_definition.stun_core_radius_pixels)
	hitbox.set("outer_damage_ratio", riftbreak_definition.outer_damage_ratio)
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
	strike_started.emit(0, 1, definition.active_seconds)


func cancel_cast() -> void:
	_reset_hitbox_position()
	super.cancel_cast()


func _advance_phase() -> void:
	var was_active := phase == Phase.ACTIVE
	super._advance_phase()
	if was_active:
		_reset_hitbox_position()


func _reset_hitbox_position() -> void:
	if hitbox != null:
		hitbox.position = Vector2.ZERO
