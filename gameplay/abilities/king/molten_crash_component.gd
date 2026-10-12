class_name MoltenCrashComponent
extends RiftbreakComponent

## Local, single-contact authority. Effects may outlive Player recovery.
const Visual = preload("res://gameplay/abilities/king/molten_crash_visual.gd")
const Aftershock = preload("res://gameplay/abilities/king/molten_crash_aftershock.gd")
var _visual: Node2D
var contact_position := Vector2.ZERO

func request_cast(direction: Vector2, equipped_weapon_damage := 0.0) -> bool:
	if not super.request_cast(direction,equipped_weapon_damage):
		return false
	_visual = Visual.new()
	_visual.source = owner
	_visual.component = self
	_visual.radius = definition.effect_radius_pixels
	_visual.form = (definition as MoltenCrashDefinition).form
	(owner as Node).get_parent().add_child(_visual)
	_visual.global_position = (owner as Node2D).global_position
	return true

func _start_current_strike() -> void:
	var actor := owner as Player
	if actor.is_defeated:
		cancel_cast()
		return
	contact_position = actor.global_position
	var tuning := definition as MoltenCrashDefinition
	_current_strike_index = 0
	_strike_time_remaining = definition.active_seconds
	hitbox.global_position = contact_position
	hitbox.set("stun_core_radius",tuning.stun_core_radius_pixels)
	hitbox.set("damage_core_radius",tuning.damage_core_radius_pixels)
	hitbox.set("outer_damage_ratio",tuning.outer_damage_ratio)
	var total_damage := definition.resolve_damage(_equipped_weapon_damage)
	hitbox.activate_radial(total_damage*(1.0-tuning.aftershock_damage_share),actor,contact_position,definition.knockback_strength,definition.stagger_seconds,_critical_chance_ratio,_critical_damage_multiplier,definition.stun_seconds,definition.damage_type)
	# One explicit pulse: no persistent Area overlap or hidden aftermath damage.
	hitbox.set_physics_process(false)
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = definition.hitbox_shape
	query.transform = Transform2D(0,contact_position)
	query.collision_mask = 16
	query.collide_with_areas = true
	query.collide_with_bodies = false
	var space := actor.get_world_2d().direct_space_state
	for result in space.intersect_shape(query,128):
		var hurtbox := result.collider as HurtboxComponent
		if hurtbox == null:
			continue
		var foot: Vector2 = hurtbox.owner.global_position if hurtbox.owner is CharacterBody2D else hurtbox.global_position
		if foot.distance_to(contact_position) > definition.effect_radius_pixels:
			continue
		var ray := PhysicsRayQueryParameters2D.create(contact_position,foot,1,[actor.get_rid()])
		if not space.intersect_ray(ray).is_empty():
			continue
		hitbox._try_hit(hurtbox)
	hitbox.deactivate()
	if is_instance_valid(_visual):
		_visual.global_position = contact_position
		_visual.release()
	if tuning.aftershock_damage_share > 0.0:
		var pulse := Aftershock.new()
		pulse.source = actor
		pulse.component = self
		pulse.visual = _visual
		pulse.delay_seconds = tuning.aftershock_delay_seconds
		pulse.radius = tuning.aftershock_radius_pixels
		pulse.damage = total_damage*tuning.aftershock_damage_share
		pulse.critical_chance = _critical_chance_ratio
		pulse.critical_multiplier = _critical_damage_multiplier
		pulse.damage_type = definition.damage_type
		actor.get_parent().add_child(pulse)
		pulse.global_position = contact_position
	strike_started.emit(0,1,definition.active_seconds)

func cancel_cast() -> void:
	if phase == Phase.WIND_UP and is_instance_valid(_visual):
		_visual.queue_free()
	super.cancel_cast()
