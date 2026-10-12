class_name BrambleSpitter
extends CharacterBody2D

enum State { SPAWNING, POSITIONING, WIND_UP, RECOVERY, STAGGER, DEAD }

signal state_changed(state: State, duration_seconds: float)
signal facing_changed(direction: Vector2)
signal shot_telegraphed(global_target: Vector2, duration_seconds: float)
signal shot_fired(direction: Vector2)

const SeparationComponentScene = preload("res://entities/enemies/components/enemy_separation_component.tscn")
const EnemyFootprint = preload("res://entities/enemies/components/enemy_footprint_system.gd")
const RETREAT_BURST_SECONDS := 0.55
const RETREAT_COOLDOWN_SECONDS := 1.65
const RETREAT_DISTANCE := 72.0

@export var definition: EnemyDefinition
@export var target: CharacterBody2D
@export var projectile_scene: PackedScene
@export_range(1.0, 200.0, 1.0, "suffix:px") var minimum_attack_range := 95.0

@onready var health_component: HealthComponent = %HealthComponent
@onready var navigation_agent: NavigationAgent2D = %NavigationAgent2D
@onready var body_collision: CollisionShape2D = $BodyCollision
@onready var knockback_component: KnockbackComponent = %KnockbackComponent
@onready var stagger_component: StaggerComponent = %StaggerComponent

var state := State.SPAWNING
var facing_direction := Vector2.DOWN
var separation_component: EnemySeparationComponent
var _projectile_parent: Node2D
var _state_time_remaining := 0.0
var _repath_time_remaining := 0.0
var _aim_direction := Vector2.DOWN
var _aim_target := Vector2.ZERO
var _applied_knockback_velocity := Vector2.ZERO
var _retreat_time_remaining := 0.0
var _retreat_cooldown_remaining := 0.0
var _retreat_target := Vector2.ZERO


func _ready() -> void:
	if definition == null or projectile_scene == null:
		push_error("BrambleSpitter requires an EnemyDefinition and projectile scene.")
		set_physics_process(false)
		return
	separation_component = _ensure_separation_component()
	if not EnemyFootprint.configure(
		definition, body_collision, navigation_agent, separation_component
	):
		set_physics_process(false)
		return
	health_component.maximum_health = definition.maximum_health
	health_component.current_health = definition.maximum_health
	health_component.armor_rating = definition.armor_rating
	health_component.magic_resistance_rating = definition.magic_resistance_rating
	health_component.died.connect(_die)
	knockback_component.configure(definition)
	stagger_component.configure(definition)
	stagger_component.stagger_started.connect(_on_stagger_started)
	state_changed.emit(State.SPAWNING, definition.spawn_seconds)
	get_tree().create_timer(definition.spawn_seconds).timeout.connect(_finish_spawn)


func set_projectile_parent(value: Node2D) -> void:
	_projectile_parent = value


func _ensure_separation_component() -> EnemySeparationComponent:
	var existing := get_node_or_null("EnemySeparationComponent") as EnemySeparationComponent
	if existing != null:
		return existing
	var component := SeparationComponentScene.instantiate() as EnemySeparationComponent
	component.separation_weight = 1.0
	add_child(component)
	return component


func _physics_process(delta: float) -> void:
	_retreat_cooldown_remaining = maxf(_retreat_cooldown_remaining - delta, 0.0)
	velocity -= _applied_knockback_velocity
	_applied_knockback_velocity = Vector2.ZERO
	if state == State.DEAD or state == State.SPAWNING or not is_instance_valid(target):
		velocity = Vector2.ZERO
		return
	if state == State.STAGGER:
		_process_stagger(delta)
		return

	match state:
		State.POSITIONING:
			_process_positioning(delta)
		State.WIND_UP, State.RECOVERY:
			velocity = velocity.move_toward(Vector2.ZERO, definition.acceleration * delta)
			_apply_knockback_velocity()
			move_and_slide()
			_tick_attack(delta)


func _process_positioning(delta: float) -> void:
	var offset := target.global_position - global_position
	var distance := offset.length()
	if distance >= minimum_attack_range and distance <= definition.attack_range and _has_clear_shot():
		_begin_shot()
		return
	if distance < minimum_attack_range:
		if _retreat_time_remaining > 0.0:
			_retreat_time_remaining = maxf(_retreat_time_remaining - delta, 0.0)
			_process_retreat_motion(delta, offset)
			if _retreat_time_remaining <= 0.0 and _has_clear_shot():
				_begin_shot()
			return
		if _retreat_cooldown_remaining <= 0.0:
			_begin_retreat(offset)
			_process_retreat_motion(delta, offset)
			return
		# Once one retreat burst is spent, the Spitter commits to a readable
		# close shot instead of kiting forever while the player follows.
		if _has_clear_shot():
			_begin_shot()
			return

	_repath_time_remaining -= delta
	if _repath_time_remaining <= 0.0:
		var requested_target := target.global_position
		navigation_agent.target_position = _navigation_safe_target(requested_target)
		_repath_time_remaining = 0.25

	var direction := Vector2.ZERO
	var next_path_position := navigation_agent.get_next_path_position()
	var path_direction := next_path_position - global_position
	if not navigation_agent.is_navigation_finished() and not path_direction.is_zero_approx():
		direction = path_direction
	elif distance > definition.attack_range and _has_clear_shot():
		direction = offset
	direction = separation_component.blend_direction(self, direction)
	_set_facing(direction)
	velocity = velocity.move_toward(direction.normalized() * definition.move_speed, definition.acceleration * delta)
	_apply_knockback_velocity()
	move_and_slide()


func _begin_retreat(offset: Vector2) -> void:
	var away := -offset.normalized() if not offset.is_zero_approx() else Vector2.LEFT
	_retreat_target = _navigation_safe_target(global_position + away * RETREAT_DISTANCE)
	navigation_agent.target_position = _retreat_target
	_retreat_time_remaining = RETREAT_BURST_SECONDS
	_retreat_cooldown_remaining = RETREAT_COOLDOWN_SECONDS


func _process_retreat_motion(delta: float, offset: Vector2) -> void:
	var direction := navigation_agent.get_next_path_position() - global_position
	if navigation_agent.is_navigation_finished() or direction.is_zero_approx():
		direction = _retreat_target - global_position
	if direction.length() <= 5.0:
		_retreat_time_remaining = 0.0
		direction = Vector2.ZERO
	direction = separation_component.blend_direction(self, direction)
	_set_facing(offset)
	velocity = velocity.move_toward(
		direction.normalized() * definition.move_speed,
		definition.acceleration * delta
	)
	_apply_knockback_velocity()
	move_and_slide()


func _begin_shot() -> void:
	velocity = Vector2.ZERO
	_retreat_time_remaining = 0.0
	var muzzle_origin := global_position + Vector2(0.0, -13.0)
	_aim_target = target.global_position + Vector2(0.0, -13.0)
	_aim_direction = muzzle_origin.direction_to(_aim_target)
	_set_facing(_aim_direction)
	shot_telegraphed.emit(target.global_position, definition.wind_up_seconds)
	_enter(State.WIND_UP, definition.wind_up_seconds)


func _process_stagger(delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, definition.acceleration * delta)
	_apply_knockback_velocity()
	move_and_slide()
	if not stagger_component.is_staggered():
		_enter(State.POSITIONING, 0.0)


func _tick_attack(delta: float) -> void:
	_state_time_remaining -= delta
	if _state_time_remaining > 0.0:
		return
	match state:
		State.WIND_UP:
			_fire_projectile()
			_enter(State.RECOVERY, definition.recovery_seconds)
		State.RECOVERY:
			_enter(State.POSITIONING, 0.0)


func _fire_projectile() -> void:
	if projectile_scene == null:
		return
	var projectile := projectile_scene.instantiate() as HostileProjectile
	if projectile == null:
		push_error("Bramble Spitter projectile scene must instantiate HostileProjectile.")
		return
	var parent := _projectile_parent if is_instance_valid(_projectile_parent) else get_tree().current_scene
	if not parent is Node2D:
		projectile.queue_free()
		push_warning("Bramble Spitter could not resolve a valid projectile parent.")
		return
	parent.add_child(projectile)
	projectile.global_position = global_position + Vector2(0.0, -13.0) + _aim_direction * 10.0
	projectile.launch(
		_aim_direction,
		definition.attack_damage,
		self,
		projectile.global_position.distance_to(_aim_target)
	)
	shot_fired.emit(_aim_direction)


func _has_clear_shot() -> bool:
	if not is_instance_valid(target):
		return false
	var query := PhysicsRayQueryParameters2D.create(global_position, target.global_position, 1)
	query.exclude = [get_rid()]
	return get_world_2d().direct_space_state.intersect_ray(query).is_empty()


func _navigation_safe_target(requested: Vector2) -> Vector2:
	var map := navigation_agent.get_navigation_map()
	if not map.is_valid() or NavigationServer2D.map_get_iteration_id(map) == 0:
		return requested
	return NavigationServer2D.map_get_closest_point(map, requested)


func _apply_knockback_velocity() -> void:
	_applied_knockback_velocity = knockback_component.velocity
	velocity += _applied_knockback_velocity


func _finish_spawn() -> void:
	if state == State.SPAWNING:
		_enter(State.POSITIONING, 0.0)


func _enter(next_state: State, duration_seconds: float) -> void:
	state = next_state
	_state_time_remaining = duration_seconds
	state_changed.emit(state, duration_seconds)


func _set_facing(direction: Vector2) -> void:
	if direction.is_zero_approx():
		return
	facing_direction = direction.normalized()
	facing_changed.emit(facing_direction)


func _on_stagger_started(duration_seconds: float) -> void:
	if state == State.DEAD or state == State.SPAWNING:
		return
	if state != State.STAGGER:
		_retreat_time_remaining = 0.0
		_enter(State.STAGGER, duration_seconds)


func _die() -> void:
	state = State.DEAD
	_retreat_time_remaining = 0.0
	velocity = Vector2.ZERO
	set_physics_process(false)
	collision_layer = 0
	collision_mask = 0
	state_changed.emit(State.DEAD, 0.35)
	get_tree().create_timer(0.35).timeout.connect(queue_free)
