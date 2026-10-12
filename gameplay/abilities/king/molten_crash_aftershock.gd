extends Node2D

## A released, world-fixed pulse. The visual observes it; this node owns damage.
var source: Player
var component: RiftbreakComponent
var visual: Node2D
var delay_seconds := .34
var radius := 86.0
var damage := 0.0
var critical_chance := 0.0
var critical_multiplier := 1.5
var damage_type := DamageInfo.DamageType.PHYSICAL
var _age := 0.0
var _prepared := false
var _hitbox: MeleeHitbox

func _ready() -> void:
	add_to_group("molten_crash_pulses")
	_hitbox = MeleeHitbox.new()
	add_child(_hitbox)
	_hitbox.hit_landed.connect(func(target: HurtboxComponent, info: DamageInfo) -> void:
		if is_instance_valid(component):
			component.hit_landed.emit(target,info)
	)

func _physics_process(delta: float) -> void:
	if not is_instance_valid(source) or source.is_defeated or not is_instance_valid(component):
		queue_free()
		return
	_age += delta
	if not _prepared and _age >= delay_seconds-.12:
		_prepared = true
		if is_instance_valid(visual):
			visual.prepare_aftershock()
	if _age < delay_seconds:
		return
	if is_instance_valid(visual):
		visual.release_aftershock()
	_pulse()
	queue_free()

func _pulse() -> void:
	_hitbox.activate_radial(damage,source,global_position,20.0,0.0,critical_chance,critical_multiplier,0.0,damage_type)
	_hitbox.set_physics_process(false)
	var circle := CircleShape2D.new()
	circle.radius = radius
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = circle
	query.transform = Transform2D(0,global_position)
	query.collision_mask = 16
	query.collide_with_areas = true
	query.collide_with_bodies = false
	var space := source.get_world_2d().direct_space_state
	for result in space.intersect_shape(query,128):
		var hurtbox := result.collider as HurtboxComponent
		if hurtbox == null:
			continue
		var foot: Vector2 = hurtbox.owner.global_position if hurtbox.owner is CharacterBody2D else hurtbox.global_position
		if foot.distance_to(global_position) > radius:
			continue
		var ray := PhysicsRayQueryParameters2D.create(global_position,foot,1,[source.get_rid()])
		if space.intersect_ray(ray).is_empty():
			_hitbox._try_hit(hurtbox)
	_hitbox.deactivate()
