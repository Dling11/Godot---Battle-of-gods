extends Node2D

## Gameplay authority for a released cut. One swept contact per target per leg.
## Outbound respects solid terrain; recall follows its owner and cannot be lost.
signal hit_landed(target: HurtboxComponent, info: DamageInfo)
signal caught
var source: Node2D
var tuning: ReturningWeaponDefinition
var direction := Vector2.RIGHT
var duration := 0.64
var damage := 0.0
var knockback := 0.0
var stagger := 0.0
var critical_chance := 0.0
var critical_multiplier := 1.5
var damage_type := DamageInfo.DamageType.PHYSICAL
var progress := 0.0
var returning := false
var _origin := Vector2.ZERO
var _turn := Vector2.ZERO
var _elapsed := 0.0
var _ended := false
var _contact: MeleeHitbox
var _query: PhysicsShapeQueryParameters2D
var _capsule: CapsuleShape2D

func _ready() -> void:
	assert(is_instance_valid(source) and tuning != null and tuning.is_valid_definition())
	add_to_group("returning_weapon_attacks")
	_origin = source.global_position
	global_position = _origin
	_turn = _origin + direction * tuning.reach
	# A narrow shaft core stops at terrain; the broad spinning blade still has
	# its authored hurt radius. Recall ignores terrain rather than stranding gear.
	var wall_query := PhysicsShapeQueryParameters2D.new()
	var core := CircleShape2D.new()
	core.radius = 5.0
	wall_query.shape = core
	wall_query.collision_mask = 1
	wall_query.transform = Transform2D(0, _origin)
	wall_query.motion = _turn - _origin
	var travel := get_world_2d().direct_space_state.cast_motion(wall_query)
	if not travel.is_empty(): _turn = _origin.lerp(_turn, travel[0])
	_contact = MeleeHitbox.new()
	_contact.collision_layer = 0
	_contact.collision_mask = 0
	add_child(_contact)
	_contact.hit_landed.connect(func(target: HurtboxComponent, info: DamageInfo) -> void: hit_landed.emit(target, info))
	_capsule = CapsuleShape2D.new()
	_capsule.radius = tuning.contact_radius
	_capsule.height = tuning.contact_radius * 2
	_query = PhysicsShapeQueryParameters2D.new()
	_query.shape = _capsule
	_query.collision_mask = 16
	_query.collide_with_areas = true
	_query.collide_with_bodies = false
	_begin_leg(tuning.outward_damage_share)
	if tuning.presentation != null: add_child(tuning.presentation.instantiate())

func _begin_leg(share: float) -> void:
	_contact.activate(damage * share, source, direction, knockback, stagger, critical_chance, critical_multiplier, 0, damage_type)
	_contact.set_physics_process(false)
	_contact.set_deferred("monitoring", false)
	_contact._direction = -direction if returning else direction

func _physics_process(delta: float) -> void:
	if not is_instance_valid(source) or source.is_queued_for_deletion(): cancel(); return
	var old_progress := progress
	_elapsed += delta
	progress = clampf(_elapsed / maxf(duration, 0.001), 0, 1)
	var split := tuning.outbound_fraction
	var recall := split + tuning.linger_fraction
	if not returning and progress >= recall:
		_sweep(global_position, _turn)
		global_position = _turn
		returning = true
		_begin_leg(1.0 - tuning.outward_damage_share)
	var point: Vector2
	if returning:
		point = _turn.lerp(source.global_position, (progress - recall) / (1.0 - recall))
	elif progress >= split:
		point = _turn
	else:
		point = _origin.lerp(_turn, 1.0 - pow(1.0 - progress / split, 2))
	if progress > old_progress: _sweep(global_position, point)
	global_position = point
	if progress >= 1:
		caught.emit()
		cancel()

func _sweep(from: Vector2, to: Vector2) -> void:
	_capsule.height = tuning.contact_radius * 2 + from.distance_to(to)
	_query.transform = Transform2D((to - from).angle() + PI * 0.5, (from + to) * 0.5)
	for result in get_world_2d().direct_space_state.intersect_shape(_query, 128): _contact._try_hit(result.collider)

func cancel() -> void:
	if _ended: return
	_ended = true
	if is_instance_valid(_contact): _contact.deactivate()
	set_physics_process(false)
	queue_free()
