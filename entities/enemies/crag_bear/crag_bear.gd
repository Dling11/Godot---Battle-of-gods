class_name CragBear
extends CharacterBody2D

enum State {
	SPAWNING,
	CHASE,
	BASIC_WIND_UP,
	BASIC_ACTIVE,
	BASIC_RECOVERY,
	SLAM_WIND_UP,
	SLAM_ACTIVE,
	SLAM_RECOVERY,
	STAGGER,
	DEAD,
}

signal state_changed(state: State, duration_seconds: float)
signal facing_changed(direction: Vector2)

const MovementScript = preload(
	"res://entities/enemies/components/enemy_movement_component.gd"
)
const SeparationScene = preload(
	"res://entities/enemies/components/enemy_separation_component.tscn"
)
const EnemyFootprint = preload(
	"res://entities/enemies/components/enemy_footprint_system.gd"
)

@export var definition: CragBearDefinition
@export var target: CharacterBody2D

@onready var movement_component: MovementScript = %MovementComponent
@onready var basic_hitbox: MeleeHitbox = %BasicHitbox
@onready var ground_slam_hitbox: MeleeHitbox = %GroundSlamHitbox
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
var _ground_slam_cooldown_remaining := 0.0
var _applied_knockback_velocity := Vector2.ZERO


func _ready() -> void:
	if definition == null:
		push_error("CragBear requires a CragBearDefinition.")
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
	_ground_slam_cooldown_remaining = definition.initial_ground_slam_delay
	_begin_spawn()


func _ensure_separation_component() -> EnemySeparationComponent:
	var existing := get_node_or_null(
		"EnemySeparationComponent"
	) as EnemySeparationComponent
	if existing != null:
		return existing
	var component := SeparationScene.instantiate() as EnemySeparationComponent
	add_child(component)
	return component


func _physics_process(delta: float) -> void:
	velocity -= _applied_knockback_velocity
	_applied_knockback_velocity = Vector2.ZERO
	_ground_slam_cooldown_remaining = maxf(
		_ground_slam_cooldown_remaining - delta, 0.0
	)
	if state in [State.DEAD, State.SPAWNING] or not is_instance_valid(target):
		velocity = Vector2.ZERO
		return
	if state == State.CHASE:
		_process_chase(delta)
	elif state == State.STAGGER:
		_process_stagger(delta)
	else:
		_process_attack_state(delta)


func _process_chase(delta: float) -> void:
	var to_target := target.global_position - global_position
	if (
		_ground_slam_cooldown_remaining <= 0.0
		and to_target.length() <= definition.ground_slam_range
		and _has_clear_attack_line()
	):
		velocity = Vector2.ZERO
		_set_facing(to_target)
		_enter(State.SLAM_WIND_UP, definition.ground_slam_wind_up_seconds)
		return
	if to_target.length() <= definition.attack_range and _has_clear_attack_line():
		velocity = Vector2.ZERO
		_set_facing(to_target)
		_enter(State.BASIC_WIND_UP, definition.wind_up_seconds)
		return
	_repath_time_remaining -= delta
	if _repath_time_remaining <= 0.0:
		navigation_agent.target_position = target.global_position
		_repath_time_remaining = 0.2
	var steering := navigation_agent.get_next_path_position() - global_position
	if navigation_agent.is_navigation_finished() or steering.is_zero_approx():
		steering = to_target if _has_clear_attack_line() else Vector2.ZERO
	steering = separation_component.blend_direction(self, steering)
	_set_facing(steering)
	velocity = movement_component.calculate_velocity(
		velocity, steering, definition.move_speed, definition.acceleration, delta
	)
	_apply_knockback()
	move_and_slide()


func _process_attack_state(delta: float) -> void:
	velocity = movement_component.calculate_velocity(
		velocity, Vector2.ZERO, definition.move_speed, definition.acceleration, delta
	)
	_apply_knockback()
	move_and_slide()
	_state_time_remaining -= delta
	if _state_time_remaining > 0.0:
		return
	match state:
		State.BASIC_WIND_UP:
			basic_hitbox.activate(
				definition.attack_damage,
				self,
				facing_direction,
				definition.basic_knockback_strength,
				definition.basic_stagger_seconds
			)
			_enter(State.BASIC_ACTIVE, definition.active_seconds)
		State.BASIC_ACTIVE:
			basic_hitbox.deactivate()
			_enter(State.BASIC_RECOVERY, definition.recovery_seconds)
		State.BASIC_RECOVERY:
			_enter(State.CHASE, 0.0)
		State.SLAM_WIND_UP:
			ground_slam_hitbox.activate_radial(
				definition.ground_slam_damage,
				self,
				ground_slam_hitbox.global_position,
				definition.ground_slam_knockback_strength,
				definition.ground_slam_stagger_seconds
			)
			_ground_slam_cooldown_remaining = (
				definition.ground_slam_cooldown_seconds
			)
			_enter(
				State.SLAM_ACTIVE, definition.ground_slam_active_seconds
			)
		State.SLAM_ACTIVE:
			ground_slam_hitbox.deactivate()
			_enter(
				State.SLAM_RECOVERY, definition.ground_slam_recovery_seconds
			)
		State.SLAM_RECOVERY:
			_enter(State.CHASE, 0.0)


func _process_stagger(delta: float) -> void:
	velocity = movement_component.calculate_velocity(
		velocity, Vector2.ZERO, definition.move_speed, definition.acceleration, delta
	)
	_apply_knockback()
	move_and_slide()
	if not stagger_component.is_staggered():
		_enter(State.CHASE, 0.0)


func _has_clear_attack_line() -> bool:
	if not is_instance_valid(target):
		return false
	var query := PhysicsRayQueryParameters2D.create(
		global_position, target.global_position, 1
	)
	query.exclude = [get_rid()]
	return get_world_2d().direct_space_state.intersect_ray(query).is_empty()


func _apply_knockback() -> void:
	_applied_knockback_velocity = knockback_component.velocity
	velocity += _applied_knockback_velocity


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


func _set_facing(direction: Vector2) -> void:
	if direction.is_zero_approx():
		return
	var normalized := direction.normalized()
	if facing_direction.dot(normalized) > 0.9999:
		return
	facing_direction = normalized
	facing_changed.emit(facing_direction)


func _enter(next_state: State, duration_seconds: float) -> void:
	state = next_state
	_state_time_remaining = duration_seconds
	state_changed.emit(state, duration_seconds)


func _on_stagger_started(duration_seconds: float) -> void:
	if state in [State.DEAD, State.SPAWNING]:
		return
	basic_hitbox.deactivate()
	ground_slam_hitbox.deactivate()
	_enter(State.STAGGER, duration_seconds)


func _on_died() -> void:
	state = State.DEAD
	velocity = Vector2.ZERO
	basic_hitbox.deactivate()
	ground_slam_hitbox.deactivate()
	collision_layer = 0
	collision_mask = 0
	state_changed.emit(state, 0.65)
	set_physics_process(false)
	get_tree().create_timer(0.65).timeout.connect(queue_free)
