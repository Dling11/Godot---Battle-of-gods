class_name Rootling
extends CharacterBody2D

## A compact forest melee foe. Unlike the Thrall, it anchors before its attack
## and never retargets the short root-jab lane after that telegraph begins.

const SeparationComponentScene = preload("res://entities/enemies/components/enemy_separation_component.tscn")
const EnemyFootprint = preload("res://entities/enemies/components/enemy_footprint_system.gd")

enum State { SPAWNING, CHASE, WIND_UP, ACTIVE, RECOVERY, STAGGER, DEAD }

signal state_changed(state: State, duration_seconds: float)
signal facing_changed(direction: Vector2)
signal root_jab_telegraphed(direction: Vector2, duration_seconds: float)
signal root_jab_erupted(direction: Vector2)

@export var definition: EnemyDefinition
@export var target: CharacterBody2D

@onready var health_component: HealthComponent = %HealthComponent
@onready var attack_hitbox: MeleeHitbox = %AttackHitbox
@onready var attack_pivot: Node2D = %AttackPivot
@onready var navigation_agent: NavigationAgent2D = %NavigationAgent2D
@onready var body_collision: CollisionShape2D = $BodyCollision
@onready var knockback_component: KnockbackComponent = %KnockbackComponent
@onready var stagger_component: StaggerComponent = %StaggerComponent

var state := State.SPAWNING
var facing_direction := Vector2.DOWN
var separation_component: EnemySeparationComponent
var _state_time_remaining := 0.0
var _repath_time_remaining := 0.0
var _locked_jab_direction := Vector2.DOWN
var _applied_knockback_velocity := Vector2.ZERO


func _ready() -> void:
	if definition == null:
		push_error("Rootling requires an EnemyDefinition.")
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


func _ensure_separation_component() -> EnemySeparationComponent:
	var existing := get_node_or_null("EnemySeparationComponent") as EnemySeparationComponent
	if existing != null:
		return existing
	var component := SeparationComponentScene.instantiate() as EnemySeparationComponent
	component.separation_weight = 1.05
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
	if state == State.CHASE:
		_process_chase(delta)
		return

	velocity = velocity.move_toward(Vector2.ZERO, definition.acceleration * delta)
	_apply_knockback_velocity()
	move_and_slide()
	_tick_attack(delta)


func _process_chase(delta: float) -> void:
	var offset := target.global_position - global_position
	if offset.length() <= definition.attack_range and _has_clear_line():
		_locked_jab_direction = offset.normalized()
		_set_facing(_locked_jab_direction)
		attack_pivot.rotation = _locked_jab_direction.angle()
		root_jab_telegraphed.emit(_locked_jab_direction, definition.wind_up_seconds)
		_enter(State.WIND_UP, definition.wind_up_seconds)
		return
	_repath_time_remaining -= delta
	if _repath_time_remaining <= 0.0:
		navigation_agent.target_position = target.global_position
		_repath_time_remaining = 0.25
	var direction := target.global_position - global_position
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


func _tick_attack(delta: float) -> void:
	_state_time_remaining -= delta
	if _state_time_remaining > 0.0:
		return
	match state:
		State.WIND_UP:
			# Direction is deliberately snapshotted during the warning. Movement,
			# target motion, and knockback cannot rotate this attack behind the player.
			root_jab_erupted.emit(_locked_jab_direction)
			attack_hitbox.activate(definition.attack_damage, self, _locked_jab_direction)
			_enter(State.ACTIVE, definition.active_seconds)
		State.ACTIVE:
			attack_hitbox.deactivate()
			_enter(State.RECOVERY, definition.recovery_seconds)
		State.RECOVERY:
			_enter(State.CHASE, 0.0)


func _process_stagger(delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, definition.acceleration * delta)
	_apply_knockback_velocity()
	move_and_slide()
	if not stagger_component.is_staggered():
		_enter(State.CHASE, 0.0)


func _finish_spawn() -> void:
	if state == State.SPAWNING:
		_enter(State.CHASE, 0.0)


func _enter(next_state: State, duration_seconds: float) -> void:
	state = next_state
	_state_time_remaining = duration_seconds
	state_changed.emit(state, duration_seconds)


func _has_clear_line() -> bool:
	var query := PhysicsRayQueryParameters2D.create(global_position, target.global_position, 1)
	query.exclude = [get_rid()]
	return get_world_2d().direct_space_state.intersect_ray(query).is_empty()


func _apply_knockback_velocity() -> void:
	_applied_knockback_velocity = knockback_component.velocity
	velocity += _applied_knockback_velocity


func _set_facing(direction: Vector2) -> void:
	if direction.is_zero_approx():
		return
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
	state_changed.emit(State.DEAD, 0.42)
	get_tree().create_timer(0.42).timeout.connect(queue_free)
