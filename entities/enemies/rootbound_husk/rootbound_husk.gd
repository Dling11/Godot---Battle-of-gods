class_name RootboundHusk
extends CharacterBody2D

const AttackProfile = preload("res://data/enemies/rootbound_husk_attack_profile.gd")
const EnemyFootprint = preload("res://entities/enemies/components/enemy_footprint_system.gd")

enum State { SPAWNING, CHASE, SPEAR_WIND_UP, SPEAR_ACTIVE, TRIAD_WIND_UP, TRIAD_ACTIVE, BURST_WIND_UP, BURST_ACTIVE, RECOVERY, DEAD }

signal state_changed(state: State, duration_seconds: float)
signal facing_changed(direction: Vector2)
signal movement_changed(is_moving: bool)
signal root_attack_telegraphed(directions: Array[Vector2], duration_seconds: float)
signal root_attack_erupted(directions: Array[Vector2])
signal root_attack_started
signal root_burst_telegraphed(duration_seconds: float)
signal root_burst_erupted

@export var definition: EnemyDefinition
@export var attack_profile: AttackProfile
@export var target: CharacterBody2D

@onready var health_component: HealthComponent = %HealthComponent
@onready var navigation_agent: NavigationAgent2D = %NavigationAgent2D
@onready var body_collision: CollisionShape2D = $BodyCollision
@onready var knockback_component: KnockbackComponent = %KnockbackComponent
@onready var center_hitbox: MeleeHitbox = %CenterHitbox
@onready var left_hitbox: MeleeHitbox = %LeftHitbox
@onready var right_hitbox: MeleeHitbox = %RightHitbox
@onready var burst_hitbox: MeleeHitbox = %BurstHitbox
@onready var center_pivot: Node2D = %CenterPivot
@onready var left_pivot: Node2D = %LeftPivot
@onready var right_pivot: Node2D = %RightPivot

var state := State.SPAWNING
var facing_direction := Vector2.DOWN
var _state_time_remaining := 0.0
var _repath_time_remaining := 0.0
var _locked_directions: Array[Vector2] = []
var _applied_knockback_velocity := Vector2.ZERO
var _is_moving := false
var _attack_count := 0
var _current_attack_is_triad := false
var _current_recovery_seconds := 0.0
var _triad_sides_pending := false
var _triad_side_time_remaining := 0.0


func _ready() -> void:
	if definition == null:
		push_error("RootboundHusk requires an EnemyDefinition.")
		set_physics_process(false)
		return
	if attack_profile == null:
		push_error("RootboundHusk requires a RootboundHuskAttackProfile.")
		set_physics_process(false)
		return
	if not EnemyFootprint.configure(definition, body_collision, navigation_agent):
		set_physics_process(false)
		return
	health_component.maximum_health = definition.maximum_health
	health_component.current_health = definition.maximum_health
	health_component.armor_rating = definition.armor_rating
	health_component.magic_resistance_rating = definition.magic_resistance_rating
	health_component.died.connect(_die)
	knockback_component.configure(definition)
	state_changed.emit(State.SPAWNING, definition.spawn_seconds)
	get_tree().create_timer(definition.spawn_seconds).timeout.connect(_finish_spawn)


func _physics_process(delta: float) -> void:
	velocity -= _applied_knockback_velocity
	_applied_knockback_velocity = Vector2.ZERO
	if state == State.DEAD or state == State.SPAWNING or not is_instance_valid(target):
		velocity = Vector2.ZERO
		_set_moving(false)
		return
	if state == State.CHASE:
		_process_chase(delta)
		return
	velocity = velocity.move_toward(Vector2.ZERO, definition.acceleration * delta)
	_apply_knockback_velocity()
	move_and_slide()
	_set_moving(false)
	_tick_attack(delta)


func _process_chase(delta: float) -> void:
	var offset := target.global_position - global_position
	if offset.length() <= attack_profile.burst_trigger_range and _has_clear_line():
		_begin_root_burst(offset.normalized())
		return
	if offset.length() <= definition.attack_range and _has_clear_line():
		_begin_root_attack(offset.normalized())
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
	_set_facing(direction)
	velocity = velocity.move_toward(direction.normalized() * definition.move_speed, definition.acceleration * delta)
	_apply_knockback_velocity()
	move_and_slide()
	_set_moving(not velocity.is_zero_approx())


func _begin_root_burst(direction: Vector2) -> void:
	_locked_directions = [direction if not direction.is_zero_approx() else facing_direction]
	_set_facing(_locked_directions[0])
	_current_attack_is_triad = false
	_current_recovery_seconds = attack_profile.burst_recovery_seconds
	root_burst_telegraphed.emit(attack_profile.burst_wind_up_seconds)
	_enter(State.BURST_WIND_UP, attack_profile.burst_wind_up_seconds)


func _begin_root_attack(direction: Vector2) -> void:
	_current_attack_is_triad = _should_use_triad()
	_attack_count += 1
	var phase_two := _is_phase_two()
	var timing_scale := attack_profile.phase_two_timing_scale if phase_two else 1.0
	_locked_directions.clear()
	_locked_directions.append(direction)
	if _current_attack_is_triad:
		var half_angle := (
			attack_profile.phase_two_triad_half_angle_radians
			if phase_two
			else attack_profile.triad_half_angle_radians
		)
		_locked_directions = [
			direction,
			direction.rotated(-half_angle).normalized(),
			direction.rotated(half_angle).normalized(),
		]
	_set_facing(direction)
	_set_attack_pivots()
	var wind_up_seconds := (
		attack_profile.triad_wind_up_seconds
		if _current_attack_is_triad
		else attack_profile.spear_wind_up_seconds
	) * timing_scale
	_current_recovery_seconds = (
		attack_profile.triad_recovery_seconds
		if _current_attack_is_triad
		else attack_profile.spear_recovery_seconds
	) * timing_scale
	root_attack_telegraphed.emit(_locked_directions, wind_up_seconds)
	_enter(
		State.TRIAD_WIND_UP if _current_attack_is_triad else State.SPEAR_WIND_UP,
		wind_up_seconds
	)


func _tick_attack(delta: float) -> void:
	if state == State.TRIAD_ACTIVE and _triad_sides_pending:
		_triad_side_time_remaining -= delta
		if _triad_side_time_remaining <= 0.0:
			_erupt_triad_sides()
	_state_time_remaining -= delta
	if _state_time_remaining > 0.0:
		return
	match state:
		State.SPEAR_WIND_UP:
			_enter(State.SPEAR_ACTIVE, attack_profile.spear_active_seconds)
			_erupt_center_lane()
		State.TRIAD_WIND_UP:
			_triad_sides_pending = true
			_triad_side_time_remaining = attack_profile.triad_side_delay_seconds
			_enter(
				State.TRIAD_ACTIVE,
				attack_profile.triad_side_delay_seconds + attack_profile.triad_side_active_seconds
			)
			_erupt_center_lane()
		State.BURST_WIND_UP:
			_enter(State.BURST_ACTIVE, attack_profile.burst_active_seconds)
			root_attack_started.emit()
			root_burst_erupted.emit()
			burst_hitbox.activate(
				definition.attack_damage * attack_profile.burst_damage_multiplier,
				self,
				_locked_directions[0]
			)
		State.SPEAR_ACTIVE, State.TRIAD_ACTIVE, State.BURST_ACTIVE:
			_deactivate_root_hitboxes()
			_enter(State.RECOVERY, _current_recovery_seconds)
		State.RECOVERY:
			_enter(State.CHASE, 0.0)


func _erupt_center_lane() -> void:
	root_attack_started.emit()
	var center_direction: Array[Vector2] = [_locked_directions[0]]
	root_attack_erupted.emit(center_direction)
	center_hitbox.activate(definition.attack_damage, self, _locked_directions[0])


func _erupt_triad_sides() -> void:
	_triad_sides_pending = false
	center_hitbox.deactivate()
	left_hitbox.activate(definition.attack_damage, self, _locked_directions[1])
	right_hitbox.activate(definition.attack_damage, self, _locked_directions[2])
	var side_directions: Array[Vector2] = [_locked_directions[1], _locked_directions[2]]
	root_attack_erupted.emit(side_directions)


func _should_use_triad() -> bool:
	var cycle_index := _attack_count % 3
	return cycle_index != 1 if _is_phase_two() else cycle_index == 1


func _is_phase_two() -> bool:
	return health_component.current_health <= health_component.maximum_health * attack_profile.phase_two_health_ratio


func _set_attack_pivots() -> void:
	center_pivot.rotation = _locked_directions[0].angle()
	if _locked_directions.size() < 3:
		return
	left_pivot.rotation = _locked_directions[1].angle()
	right_pivot.rotation = _locked_directions[2].angle()


func _deactivate_root_hitboxes() -> void:
	_triad_sides_pending = false
	center_hitbox.deactivate()
	left_hitbox.deactivate()
	right_hitbox.deactivate()
	burst_hitbox.deactivate()


func _finish_spawn() -> void:
	if state == State.SPAWNING:
		_enter(State.CHASE, 0.0)


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


func _set_moving(is_moving: bool) -> void:
	if _is_moving == is_moving:
		return
	_is_moving = is_moving
	movement_changed.emit(_is_moving)


func _enter(next_state: State, duration_seconds: float) -> void:
	state = next_state
	_state_time_remaining = duration_seconds
	if next_state != State.CHASE:
		_set_moving(false)
	state_changed.emit(state, duration_seconds)


func _die() -> void:
	state = State.DEAD
	_deactivate_root_hitboxes()
	velocity = Vector2.ZERO
	set_physics_process(false)
	collision_layer = 0
	collision_mask = 0
	state_changed.emit(State.DEAD, 0.6)
	get_tree().create_timer(0.6).timeout.connect(queue_free)
