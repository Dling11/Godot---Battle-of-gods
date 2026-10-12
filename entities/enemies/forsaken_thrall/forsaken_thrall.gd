class_name ForsakenThrall
extends CharacterBody2D

enum State { SPAWNING, CHASE, WIND_UP, ACTIVE, RECOVERY, STAGGER, DEAD }

signal state_changed(state: State, duration_seconds: float)
signal facing_changed(direction: Vector2)

const EnemyMovementComponentScript = preload("res://entities/enemies/components/enemy_movement_component.gd")
const SeparationComponentScene = preload("res://entities/enemies/components/enemy_separation_component.tscn")
const EnemyFootprint = preload("res://entities/enemies/components/enemy_footprint_system.gd")

@export var definition: EnemyDefinition
@export var target: CharacterBody2D

@onready var movement_component: EnemyMovementComponentScript = %MovementComponent
@onready var attack_hitbox: MeleeHitbox = %AttackHitbox
@onready var health_component: HealthComponent = %HealthComponent
@onready var navigation_agent: NavigationAgent2D = %NavigationAgent2D
@onready var body_collision: CollisionShape2D = $BodyCollision
@onready var knockback_component: KnockbackComponent = %KnockbackComponent
@onready var stagger_component: StaggerComponent = %StaggerComponent
var separation_component: EnemySeparationComponent

var state := State.CHASE
var facing_direction := Vector2.DOWN
var _state_time_remaining: float
var _repath_time_remaining: float
var _applied_knockback_velocity := Vector2.ZERO


func _ready() -> void:
	if definition == null:
		push_error("ForsakenThrall requires an EnemyDefinition.")
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
	health_component.died.connect(_on_died)
	knockback_component.configure(definition)
	stagger_component.configure(definition)
	stagger_component.stagger_started.connect(_on_stagger_started)
	_begin_spawn()


func _ensure_separation_component() -> EnemySeparationComponent:
	var existing := get_node_or_null("EnemySeparationComponent") as EnemySeparationComponent
	if existing != null: return existing
	var component := SeparationComponentScene.instantiate() as EnemySeparationComponent
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

	var to_target := target.global_position - global_position

	match state:
		State.SPAWNING:
			velocity = Vector2.ZERO
		State.CHASE:
			_process_chase(to_target, delta)
		State.WIND_UP, State.ACTIVE, State.RECOVERY:
			velocity = movement_component.calculate_velocity(
				velocity, Vector2.ZERO, definition.move_speed, definition.acceleration, delta
			)
			_apply_knockback_velocity()
			move_and_slide()
			_tick_attack_state(delta)


func _process_chase(to_target: Vector2, delta: float) -> void:
	if to_target.length() <= definition.attack_range and _has_clear_attack_line():
		velocity = Vector2.ZERO
		_set_facing_direction(to_target)
		_enter_state(State.WIND_UP, definition.wind_up_seconds)
		return
	_repath_time_remaining -= delta
	if _repath_time_remaining <= 0.0:
		navigation_agent.target_position = target.global_position
		_repath_time_remaining = 0.2
	var next_path_position := navigation_agent.get_next_path_position()
	var steering_direction := Vector2.ZERO
	if not navigation_agent.is_navigation_finished() and not next_path_position.is_zero_approx():
		steering_direction = next_path_position - global_position
	elif _has_clear_attack_line():
		steering_direction = to_target
	steering_direction = separation_component.blend_direction(self, steering_direction)
	_set_facing_direction(steering_direction)
	velocity = movement_component.calculate_velocity(
		velocity, steering_direction, definition.move_speed, definition.acceleration, delta
	)
	_apply_knockback_velocity()
	move_and_slide()


func _process_stagger(delta: float) -> void:
	velocity = movement_component.calculate_velocity(
		velocity, Vector2.ZERO, definition.move_speed, definition.acceleration, delta
	)
	_apply_knockback_velocity()
	move_and_slide()
	if not stagger_component.is_staggered():
		_enter_state(State.CHASE, 0.0)


func _apply_knockback_velocity() -> void:
	_applied_knockback_velocity = knockback_component.velocity
	velocity += _applied_knockback_velocity


func _has_clear_attack_line() -> bool:
	if not is_instance_valid(target): return false
	var query := PhysicsRayQueryParameters2D.create(global_position, target.global_position, 1)
	query.exclude = [get_rid()]
	return get_world_2d().direct_space_state.intersect_ray(query).is_empty()


func _begin_spawn() -> void:
	state = State.SPAWNING
	set_collision_layer_value(3, false)
	set_collision_mask_value(1, false)
	state_changed.emit(state, definition.spawn_seconds)
	get_tree().create_timer(definition.spawn_seconds).timeout.connect(_finish_spawn)


func _finish_spawn() -> void:
	if state != State.SPAWNING:
		return
	set_collision_layer_value(3, true)
	set_collision_mask_value(1, true)
	_enter_state(State.CHASE, 0.0)


func _tick_attack_state(delta: float) -> void:
	_state_time_remaining -= delta
	if _state_time_remaining > 0.0:
		return
	match state:
		State.WIND_UP:
			_enter_state(State.ACTIVE, definition.active_seconds)
			attack_hitbox.activate(definition.attack_damage, self, facing_direction)
		State.ACTIVE:
			attack_hitbox.deactivate()
			_enter_state(State.RECOVERY, definition.recovery_seconds)
		State.RECOVERY:
			_enter_state(State.CHASE, 0.0)


func _enter_state(next_state: State, duration_seconds: float) -> void:
	state = next_state
	_state_time_remaining = duration_seconds
	state_changed.emit(state, duration_seconds)


func _set_facing_direction(direction: Vector2) -> void:
	if direction.is_zero_approx():
		return
	var normalized := direction.normalized()
	if facing_direction.dot(normalized) > 0.9999:
		return
	facing_direction = normalized
	facing_changed.emit(facing_direction)


func _on_stagger_started(duration_seconds: float) -> void:
	if state == State.DEAD or state == State.SPAWNING:
		return
	attack_hitbox.deactivate()
	if state != State.STAGGER:
		_enter_state(State.STAGGER, duration_seconds)


func _on_died() -> void:
	state = State.DEAD
	velocity = Vector2.ZERO
	attack_hitbox.deactivate()
	collision_layer = 0
	collision_mask = 0
	state_changed.emit(state, 0.35)
	set_physics_process(false)
	get_tree().create_timer(0.35).timeout.connect(queue_free)
