class_name Mireling
extends CharacterBody2D

const SeparationComponentScene = preload("res://entities/enemies/components/enemy_separation_component.tscn")
const EnemyFootprint = preload("res://entities/enemies/components/enemy_footprint_system.gd")

enum State { SPAWNING, CHASE, WIND_UP, LEAP, ACTIVE, RECOVERY, STAGGER, DEAD }

signal state_changed(state: State, duration_seconds: float)
signal facing_changed(direction: Vector2)
signal leap_targeted(global_target: Vector2, duration_seconds: float)

@export var definition: EnemyDefinition
@export var target: CharacterBody2D

@onready var health_component: HealthComponent = %HealthComponent
@onready var attack_hitbox: MeleeHitbox = %AttackHitbox
@onready var navigation_agent: NavigationAgent2D = %NavigationAgent2D
@onready var body_collision: CollisionShape2D = $BodyCollision
@onready var knockback_component: KnockbackComponent = %KnockbackComponent
@onready var stagger_component: StaggerComponent = %StaggerComponent
var separation_component: EnemySeparationComponent

var state := State.SPAWNING
var facing_direction := Vector2.DOWN
var _state_time := 0.0
var _repath_time := 0.0
var _leap_origin := Vector2.ZERO
var _leap_target := Vector2.ZERO
var _leap_elapsed := 0.0
var _applied_knockback_velocity := Vector2.ZERO

@export var leap_seconds := 0.42


func _ready() -> void:
	if definition == null:
		push_error("Mireling requires an EnemyDefinition.")
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
	get_tree().create_timer(definition.spawn_seconds).timeout.connect(func() -> void: _enter(State.CHASE, 0.0))


func _ensure_separation_component() -> EnemySeparationComponent:
	var existing := get_node_or_null("EnemySeparationComponent") as EnemySeparationComponent
	if existing != null: return existing
	var component := SeparationComponentScene.instantiate() as EnemySeparationComponent
	component.separation_weight = 1.0
	add_child(component)
	return component


func _physics_process(delta: float) -> void:
	velocity -= _applied_knockback_velocity
	_applied_knockback_velocity = Vector2.ZERO
	if state == State.DEAD or state == State.SPAWNING or not is_instance_valid(target):
		velocity = Vector2.ZERO
		return
	if state == State.STAGGER:
		_process_stagger(delta)
		return
	var offset := target.global_position - global_position
	if state == State.CHASE:
		if offset.length() <= definition.attack_range and _has_clear_line():
			_set_facing(offset)
			_leap_target = _navigation_safe_target(target.global_position)
			leap_targeted.emit(_leap_target, definition.wind_up_seconds)
			_enter(State.WIND_UP, definition.wind_up_seconds)
			return
		_repath_time -= delta
		if _repath_time <= 0.0:
			navigation_agent.target_position = target.global_position
			_repath_time = 0.25
		var direction := offset
		var next_path_position := navigation_agent.get_next_path_position()
		if not navigation_agent.is_navigation_finished() and not next_path_position.is_zero_approx():
			direction = next_path_position - global_position
		elif not _has_clear_line():
			direction = Vector2.ZERO
		direction = separation_component.blend_direction(self, direction)
		_set_facing(direction)
		velocity = velocity.move_toward(direction.normalized() * definition.move_speed, definition.acceleration * delta)
		_apply_knockback_velocity()
		move_and_slide()
		return
	if state == State.LEAP:
		_leap_elapsed += delta
		var progress := minf(_leap_elapsed / leap_seconds, 1.0)
		var desired := _leap_origin.lerp(_leap_target, progress)
		velocity = (desired - global_position) / maxf(delta, 0.001)
		move_and_slide()
		if progress >= 1.0:
			velocity = Vector2.ZERO
			_enter(State.ACTIVE, definition.active_seconds)
			attack_hitbox.activate(definition.attack_damage, self, facing_direction)
		return
	velocity = velocity.move_toward(Vector2.ZERO, definition.acceleration * delta)
	_apply_knockback_velocity()
	move_and_slide()
	_state_time -= delta
	if _state_time > 0.0:
		return
	match state:
		State.WIND_UP:
			_leap_origin = global_position
			_leap_elapsed = 0.0
			_enter(State.LEAP, leap_seconds)
		State.ACTIVE:
			attack_hitbox.deactivate()
			_enter(State.RECOVERY, definition.recovery_seconds)
		State.RECOVERY:
			_enter(State.CHASE, 0.0)


func _apply_knockback_velocity() -> void:
	_applied_knockback_velocity = knockback_component.velocity
	velocity += _applied_knockback_velocity


func _process_stagger(delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, definition.acceleration * delta)
	_apply_knockback_velocity()
	move_and_slide()
	if not stagger_component.is_staggered():
		_enter(State.CHASE, 0.0)


func _enter(next_state: State, duration: float) -> void:
	state = next_state
	_state_time = duration
	state_changed.emit(state, duration)


func _has_clear_line() -> bool:
	var query := PhysicsRayQueryParameters2D.create(global_position, target.global_position, 1)
	query.exclude = [get_rid()]
	return get_world_2d().direct_space_state.intersect_ray(query).is_empty()


func _navigation_safe_target(requested: Vector2) -> Vector2:
	var map := navigation_agent.get_navigation_map()
	if not map.is_valid() or NavigationServer2D.map_get_iteration_id(map) == 0: return requested
	var safe := NavigationServer2D.map_get_closest_point(map, requested)
	return requested if safe.distance_to(requested) > 64.0 else safe


func _set_facing(direction: Vector2) -> void:
	if direction.is_zero_approx(): return
	facing_direction = direction.normalized()
	facing_changed.emit(facing_direction)


func _on_stagger_started(duration_seconds: float) -> void:
	if state == State.DEAD or state == State.SPAWNING:
		return
	attack_hitbox.deactivate()
	if state != State.STAGGER:
		_enter(State.STAGGER, duration_seconds)


func _die() -> void:
	state = State.DEAD
	attack_hitbox.deactivate()
	velocity = Vector2.ZERO
	set_physics_process(false)
	collision_layer = 0
	collision_mask = 0
	state_changed.emit(State.DEAD, 0.35)
	get_tree().create_timer(0.35).timeout.connect(queue_free)
