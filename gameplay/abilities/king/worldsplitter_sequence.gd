extends Node2D

## Released world-point authority. Player recovery does not delay the ranked contacts.
var source: Player
var component: AbilityComponent
var tuning: KingSkill4Definition
var visual: Node2D
var damage := 0.0
var critical_chance := 0.0
var critical_multiplier := 1.5
var _age := 0.0
var _next_contact := 0
var _hitbox: MeleeHitbox

func _ready() -> void:
	add_to_group("worldsplitter_sequences")
	_hitbox = MeleeHitbox.new()
	add_child(_hitbox)
	_hitbox.hit_landed.connect(func(target: HurtboxComponent, info: DamageInfo) -> void:
		if is_instance_valid(component): component.hit_landed.emit(target, info))

func _physics_process(delta: float) -> void:
	if not is_instance_valid(source) or source.is_defeated or not is_instance_valid(component):
		queue_free()
		return
	_age += delta
	while _next_contact < tuning.strike_count() and _age >= tuning.descent_seconds + _next_contact*tuning.followup_delay_seconds:
		var final := _next_contact == tuning.strike_count()-1
		# Hit feedback queries this synchronously; release was not a damage contact.
		component._current_strike_index = _next_contact
		if is_instance_valid(visual): visual.impact(_next_contact, final)
		_pulse(tuning.contact_radius(_next_contact), tuning.strike_damage_multipliers[_next_contact], tuning.stun_seconds if final else 0.0, tuning.knockback_strength if final else 8.0)
		_next_contact += 1
	if _next_contact == tuning.strike_count(): queue_free()

func _pulse(radius: float, multiplier: float, stun: float, force: float) -> void:
	_hitbox.activate_radial(damage*multiplier, source, global_position, force, .10, critical_chance, critical_multiplier, stun, tuning.damage_type)
	_hitbox.set_physics_process(false)
	var shape := CircleShape2D.new()
	shape.radius = radius
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.transform = Transform2D(0.0, global_position)
	query.collision_mask = 16
	query.collide_with_areas = true
	query.collide_with_bodies = false
	var space := get_world_2d().direct_space_state
	for result in space.intersect_shape(query, 128):
		var hurtbox := result.collider as HurtboxComponent
		if hurtbox == null: continue
		var foot: Vector2 = hurtbox.owner.global_position if hurtbox.owner is CharacterBody2D else hurtbox.global_position
		if foot.distance_to(global_position) > radius: continue
		_hitbox._try_hit(hurtbox)
	_hitbox.deactivate()
