class_name ArmoredHog
extends CharacterBody2D

enum State { SPAWNING, CHASE, BRACE, CHARGE, DAZED, STAGGER, DEAD }

signal state_changed(state: State, duration_seconds: float)
signal facing_changed(direction: Vector2)
signal hoofbeat
signal charge_started
signal crashed

const MovementScript = preload("res://entities/enemies/components/enemy_movement_component.gd")
const SeparationScene = preload("res://entities/enemies/components/enemy_separation_component.tscn")
const EnemyFootprint = preload("res://entities/enemies/components/enemy_footprint_system.gd")

@export var definition: ArmoredHogDefinition
@export var target: CharacterBody2D

@onready var movement_component: MovementScript = %MovementComponent
@onready var attack_hitbox: MeleeHitbox = %AttackHitbox
@onready var health_component: HealthComponent = %HealthComponent
@onready var navigation_agent: NavigationAgent2D = %NavigationAgent2D
@onready var body_collision: CollisionShape2D = $BodyCollision
@onready var knockback_component: KnockbackComponent = %KnockbackComponent
@onready var stagger_component: StaggerComponent = %StaggerComponent

var state := State.SPAWNING
var facing_direction := Vector2.DOWN
var separation_component: EnemySeparationComponent
var _state_time_remaining := 0.0
var _repath_time_remaining := 0.0
var _charge_direction := Vector2.DOWN
var _charge_remaining := 0.0
var _applied_knockback_velocity := Vector2.ZERO
var _hoofbeat_remaining := 0.0


func _ready() -> void:
	if definition == null:
		push_error("ArmoredHog requires an ArmoredHogDefinition.")
		set_physics_process(false)
		return
	separation_component = _ensure_separation_component()
	if not EnemyFootprint.configure(definition, body_collision, navigation_agent, separation_component):
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
	if existing != null:
		return existing
	var component := SeparationScene.instantiate() as EnemySeparationComponent
	add_child(component)
	return component


func _physics_process(delta: float) -> void:
	velocity -= _applied_knockback_velocity
	_applied_knockback_velocity = Vector2.ZERO
	if state in [State.DEAD, State.SPAWNING] or not is_instance_valid(target):
		velocity = Vector2.ZERO
		return
	if state == State.CHASE:
		_process_chase(delta)
	elif state == State.BRACE:
		velocity = Vector2.ZERO
		_tick_state(delta)
	elif state == State.CHARGE:
		_process_charge(delta)
	elif state == State.DAZED:
		velocity = Vector2.ZERO
		_tick_state(delta)
	elif state == State.STAGGER:
		_process_stagger(delta)


func _process_chase(delta: float) -> void:
	var to_target := target.global_position - global_position
	if to_target.length() <= definition.charge_trigger_range and _has_clear_charge_line():
		_charge_direction = to_target.normalized()
		_set_facing(_charge_direction)
		_enter(State.BRACE, definition.wind_up_seconds)
		return
	_repath_time_remaining -= delta
	if _repath_time_remaining <= 0.0:
		navigation_agent.target_position = target.global_position
		_repath_time_remaining = 0.2
	var steering := navigation_agent.get_next_path_position() - global_position
	if navigation_agent.is_navigation_finished() or steering.is_zero_approx():
		steering = to_target
	steering = separation_component.blend_direction(self, steering)
	_set_facing(steering)
	velocity = movement_component.calculate_velocity(velocity, steering, definition.move_speed, definition.acceleration, delta)
	_apply_knockback()
	move_and_slide()
	_hoofbeat_remaining -= delta
	if _hoofbeat_remaining <= 0.0:
		hoofbeat.emit()
		_hoofbeat_remaining = 0.38


func _process_charge(delta: float) -> void:
	var previous_position := global_position
	velocity = _charge_direction * definition.charge_speed
	move_and_slide()
	_charge_remaining -= previous_position.distance_to(global_position)
	_hoofbeat_remaining -= delta
	if _hoofbeat_remaining <= 0.0:
		hoofbeat.emit()
		_hoofbeat_remaining = 0.15
	if get_slide_collision_count() > 0 or _charge_remaining <= 0.0:
		attack_hitbox.deactivate()
		crashed.emit()
		_enter(State.DAZED, definition.dazed_seconds)


func _process_stagger(delta: float) -> void:
	velocity = movement_component.calculate_velocity(velocity, Vector2.ZERO, definition.move_speed, definition.acceleration, delta)
	_apply_knockback()
	move_and_slide()
	if not stagger_component.is_staggered():
		_enter(State.CHASE, 0.0)


func _tick_state(delta: float) -> void:
	_state_time_remaining -= delta
	if _state_time_remaining > 0.0:
		return
	if state == State.BRACE:
		_charge_remaining = definition.charge_distance
		_hoofbeat_remaining = 0.0
		attack_hitbox.activate(
			definition.attack_damage,
			self,
			_charge_direction,
			definition.charge_knockback_strength,
			definition.charge_stagger_seconds
		)
		charge_started.emit()
		_enter(State.CHARGE, definition.active_seconds)
	elif state == State.DAZED:
		_enter(State.CHASE, 0.0)


func _enter(next_state: State, duration_seconds: float) -> void:
	state = next_state
	_state_time_remaining = duration_seconds
	state_changed.emit(state, duration_seconds)


func _begin_spawn() -> void:
	set_collision_layer_value(3, false)
	set_collision_mask_value(1, false)
	_enter(State.SPAWNING, definition.spawn_seconds)
	get_tree().create_timer(definition.spawn_seconds).timeout.connect(_finish_spawn)


func _finish_spawn() -> void:
	if state != State.SPAWNING:
		return
	set_collision_layer_value(3, true)
	set_collision_mask_value(1, true)
	_enter(State.CHASE, 0.0)


func _has_clear_charge_line() -> bool:
	var end := global_position + (target.global_position - global_position).limit_length(definition.charge_distance)
	var query := PhysicsRayQueryParameters2D.create(global_position, end, 1)
	query.exclude = [get_rid()]
	return get_world_2d().direct_space_state.intersect_ray(query).is_empty()


func _set_facing(direction: Vector2) -> void:
	if direction.is_zero_approx():
		return
	var normalized := direction.normalized()
	if facing_direction.dot(normalized) > 0.9999:
		return
	facing_direction = normalized
	facing_changed.emit(facing_direction)


func _apply_knockback() -> void:
	_applied_knockback_velocity = knockback_component.velocity
	velocity += _applied_knockback_velocity


func _on_stagger_started(duration_seconds: float) -> void:
	## Once the warning lane appears, the charge is committed. Repeated basic
	## hits may still deal guarded damage and show hurt feedback, but cannot keep
	## restarting the wind-up forever. The intended punish window remains DAZED.
	if state in [State.DEAD, State.SPAWNING, State.BRACE, State.CHARGE]:
		return
	attack_hitbox.deactivate()
	_enter(State.STAGGER, duration_seconds)


func _on_died() -> void:
	state = State.DEAD
	velocity = Vector2.ZERO
	attack_hitbox.deactivate()
	collision_layer = 0
	collision_mask = 0
	state_changed.emit(state, 0.65)
	set_physics_process(false)
	get_tree().create_timer(0.65).timeout.connect(queue_free)
