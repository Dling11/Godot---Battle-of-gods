class_name Stage5Boss
extends CharacterBody2D

const EnemyFootprint = preload("res://entities/enemies/components/enemy_footprint_system.gd")
const ImpactScene = preload("res://entities/enemies/stage_5_boss/stage_5_boss_jump_impact.tscn")
const MarkerScene = preload("res://entities/enemies/stage_5_boss/stage_5_boss_jump_marker.tscn")
const RootPrisonScene = preload("res://entities/enemies/stage_5_boss/stage_5_boss_root_prison.tscn")

enum State { SPAWNING, CHASE, LUNGE_WIND_UP, LUNGE_ACTIVE, LUNGE_RECOVERY, SLAP_WIND_UP, SLAP_ACTIVE, SLAP_RECOVERY, JUMP_WIND_UP, JUMP_TRAVEL, JUMP_LAND, JUMP_RECOVERY, ROOT_WIND_UP, ROOT_TRACK, ROOT_CHANNEL, ROOT_EXECUTION, ROOT_RECOVERY, DEAD }
enum JumpTier { SINGLE, MULTI, DESPERATION }

signal state_changed(state: State, duration_seconds: float)
signal facing_changed(direction: Vector2)
signal movement_changed(is_moving: bool)
signal jump_height_changed(height_pixels: float)
signal jump_target_locked(target_position: Vector2)
signal landed(position: Vector2)
signal slap_landed(position: Vector2)
signal root_locked(position: Vector2, captured_player: bool)
signal root_executed(position: Vector2, hit_player: bool)
signal desperation_started

@export var definition: EnemyDefinition
@export var target: CharacterBody2D
@export var arena_bounds := Rect2(64.0, 80.0, 832.0, 400.0)
@export_range(1.0, 100.0, 1.0) var jump_damage := 36.0
@export_range(32.0, 160.0, 1.0) var jump_radius := 72.0
@export_range(0.1, 3.0, 0.05) var jump_wind_up_seconds := 0.72
@export_range(0.1, 3.0, 0.05) var jump_travel_seconds := 0.9
@export_range(0.1, 3.0, 0.05) var jump_recovery_seconds := 1.05
@export_range(1.0, 100.0, 1.0) var slap_damage := 42.0
@export_range(0.1, 3.0, 0.05) var slap_wind_up_seconds := 0.60
@export_range(0.05, 1.0, 0.05) var slap_active_seconds := 0.12
@export_range(0.1, 3.0, 0.05) var slap_recovery_seconds := 0.54
@export_range(1.0, 100.0, 1.0) var root_capture_damage := 12.0
@export_range(100.0, 999.0, 1.0) var root_execution_damage := 300.0
@export_range(0.1, 2.0, 0.05) var root_wind_up_seconds := 0.72
@export_range(0.1, 2.0, 0.05) var root_tracking_seconds := 0.55
@export_range(1.0, 5.0, 0.05) var root_escape_seconds := 2.2
@export_range(0.1, 2.0, 0.05) var root_execution_seconds := 0.9
@export_range(0.1, 3.0, 0.05) var root_recovery_seconds := 1.15
@export_range(8.0, 80.0, 1.0) var root_capture_radius := 34.0
@export_range(1, 10, 1) var root_break_points := 5
@export_range(0.5, 0.95, 0.01) var multi_jump_health_ratio := 0.80
@export_range(0.1, 0.5, 0.01) var desperation_health_ratio := 0.30
@export_range(0.1, 1.0, 0.01) var multi_first_warning_seconds := 0.48
@export_range(0.1, 1.0, 0.01) var multi_repeat_warning_seconds := 0.34
@export_range(0.1, 1.0, 0.01) var multi_final_warning_seconds := 0.42
@export_range(0.1, 1.0, 0.01) var multi_travel_seconds := 0.58
@export_range(0.05, 0.5, 0.01) var multi_between_jump_seconds := 0.18
@export_range(0.1, 1.5, 0.01) var multi_final_recovery_seconds := 0.75
@export_range(1.0, 2.0, 0.05) var multi_final_damage_multiplier := 1.2
@export_range(0.1, 1.0, 0.01) var desperation_first_warning_seconds := 0.38
@export_range(0.1, 1.0, 0.01) var desperation_repeat_warning_seconds := 0.24
@export_range(0.1, 1.0, 0.01) var desperation_final_warning_seconds := 0.32
@export_range(0.1, 1.0, 0.01) var desperation_travel_seconds := 0.42
@export_range(0.05, 0.5, 0.01) var desperation_between_jump_seconds := 0.10
@export_range(0.1, 1.5, 0.01) var desperation_final_recovery_seconds := 0.55
@export_range(0.1, 1.0, 0.01) var desperation_root_wind_up_seconds := 0.45
@export_range(0.1, 1.0, 0.01) var desperation_root_tracking_seconds := 0.35
@export_range(1.0, 2.0, 0.05) var desperation_final_damage_multiplier := 1.5
@export_range(0.1, 10.0, 0.1) var single_jump_reuse_seconds := 4.6
@export_range(0.1, 10.0, 0.1) var multi_jump_reuse_seconds := 3.8
@export_range(0.1, 10.0, 0.1) var desperation_jump_reuse_seconds := 2.6
@export_range(96.0, 600.0, 1.0, "suffix:px") var desperation_anti_kite_distance := 190.0
@export_range(0.1, 2.0, 0.05, "suffix:s") var desperation_anti_kite_hold_seconds := 0.55
@export_range(0.05, 1.0, 0.05, "suffix:s") var navigation_repath_seconds := 0.20
@export_range(0.2, 1.5, 0.05, "suffix:s") var obstacle_detour_seconds := 0.75

@onready var health_component: HealthComponent = %HealthComponent
@onready var body_collision: CollisionShape2D = $BodyCollision
@onready var navigation_agent: NavigationAgent2D = %NavigationAgent2D
@onready var knockback_component: KnockbackComponent = %KnockbackComponent
@onready var lunge_pivot: Node2D = %LungePivot
@onready var lunge_hitbox: MeleeHitbox = %LungeHitbox
@onready var slap_pivot: Node2D = %SlapPivot
@onready var slap_hitbox: MeleeHitbox = %SlapHitbox
@onready var jump_hitbox: MeleeHitbox = %JumpHitbox

var state := State.SPAWNING
var facing_direction := Vector2.DOWN
var _state_remaining := 0.0
var _jump_cooldown := 2.2
var _attacks_since_jump := 0
var _jump_start := Vector2.ZERO
var _jump_target := Vector2.ZERO
var _jump_elapsed := 0.0
var _marker: Node2D
var _is_moving := false
var _next_melee_is_slap := false
var _root_ready := false
var _root_effect: Stage5BossRootPrison
var _root_target_position := Vector2.ZERO
var _low_phase_pending := false
var _low_phase_entered := false
var _rapid_jump_active := false
var _rapid_jump_index := -1
var _rapid_jumps_remaining := 0
var _active_jump_chain_count := 1
var _active_jump_tier := JumpTier.SINGLE
var _multi_chain_step := 0
var _desperation_chain_step := 0
var _active_jump_travel_seconds := 0.9
var _active_jump_recovery_seconds := 1.05
var _active_jump_damage := 36.0
var _active_root_wind_up_seconds := 0.72
var _active_root_tracking_seconds := 0.55
var _landing_feedback_strength := 5.0
var _desperation_kite_elapsed := 0.0
var _navigation_repath_remaining := 0.0
var _obstacle_detour_remaining := 0.0
var _obstacle_detour_direction := Vector2.ZERO


func _ready() -> void:
	if definition == null:
		push_error("Stage5Boss requires an EnemyDefinition.")
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
	health_component.health_changed.connect(_on_health_changed)
	knockback_component.configure(definition)
	_enter(State.SPAWNING, definition.spawn_seconds)
	get_tree().create_timer(definition.spawn_seconds).timeout.connect(_finish_spawn)


func _physics_process(delta: float) -> void:
	_jump_cooldown = maxf(_jump_cooldown - delta, 0.0)
	if state in [State.DEAD, State.SPAWNING] or not is_instance_valid(target):
		velocity = Vector2.ZERO
		_set_moving(false)
		return
	if state == State.CHASE:
		_process_chase(delta)
	elif state == State.JUMP_TRAVEL:
		_process_jump_travel(delta)
	else:
		velocity = Vector2.ZERO
		_set_moving(false)
		_tick_state(delta)


func _process_chase(delta: float) -> void:
	var offset := target.global_position - global_position
	var distance := offset.length()
	if _root_ready:
		_desperation_kite_elapsed = 0.0
		_begin_root_prison(offset)
		return
	if _low_phase_pending:
		_low_phase_pending = false
		_desperation_kite_elapsed = 0.0
		_begin_jump_sequence(offset)
		return
	var jump_tier := _jump_tier()
	if jump_tier == JumpTier.DESPERATION and distance >= desperation_anti_kite_distance:
		_desperation_kite_elapsed += delta
	else:
		_desperation_kite_elapsed = 0.0
	var attacks_before_jump := 1 if jump_tier == JumpTier.DESPERATION else 2
	var anti_kite_jump_ready := (
		jump_tier == JumpTier.DESPERATION
		and _desperation_kite_elapsed >= desperation_anti_kite_hold_seconds
	)
	if _jump_cooldown <= 0.0 and (
		_attacks_since_jump >= attacks_before_jump or anti_kite_jump_ready
	):
		_desperation_kite_elapsed = 0.0
		_begin_jump_sequence(offset)
		return
	if distance <= definition.attack_range:
		_begin_melee(offset)
		return
	var chase_direction := _navigation_chase_direction(delta, offset)
	_set_facing(chase_direction)
	velocity = velocity.move_toward(chase_direction.normalized() * definition.move_speed, definition.acceleration * delta)
	move_and_slide()
	_capture_obstacle_detour()
	global_position = global_position.clamp(arena_bounds.position, arena_bounds.end)
	_set_moving(not velocity.is_zero_approx())


func _begin_melee(offset: Vector2) -> void:
	var direction := offset.normalized() if not offset.is_zero_approx() else facing_direction
	_set_facing(direction)
	lunge_pivot.rotation = direction.angle()
	slap_pivot.rotation = direction.angle()
	_attacks_since_jump += 1
	if _next_melee_is_slap:
		_next_melee_is_slap = false
		_enter(State.SLAP_WIND_UP, slap_wind_up_seconds)
	else:
		_next_melee_is_slap = true
		_enter(State.LUNGE_WIND_UP, definition.wind_up_seconds)


func _begin_jump_sequence(offset: Vector2) -> void:
	_active_jump_tier = _jump_tier()
	_active_jump_chain_count = _next_jump_chain_count(_active_jump_tier)
	_rapid_jump_active = _active_jump_chain_count > 1
	_rapid_jumps_remaining = _active_jump_chain_count
	_begin_jump(offset, _rapid_jump_active)
	if _active_jump_tier == JumpTier.DESPERATION:
		desperation_started.emit()


func _begin_jump(offset: Vector2, rapid_jump := false) -> void:
	var direction := offset.normalized() if not offset.is_zero_approx() else facing_direction
	_set_facing(direction)
	_jump_start = global_position
	if rapid_jump:
		_rapid_jump_index = _active_jump_chain_count - _rapid_jumps_remaining
		_rapid_jumps_remaining -= 1
		_jump_target = _pursuit_target(_rapid_jump_index, _rapid_jumps_remaining == 0)
	else:
		_rapid_jump_index = -1
		_jump_target = target.global_position
	_jump_target = _jump_target.clamp(arena_bounds.position + Vector2(24.0, 24.0), arena_bounds.end - Vector2(24.0, 24.0))
	_jump_target = resolve_navigation_safe_position(_jump_target)
	_jump_elapsed = 0.0
	_attacks_since_jump = 0
	var is_low_health_chain := _active_jump_tier == JumpTier.DESPERATION
	_active_jump_travel_seconds = desperation_travel_seconds if is_low_health_chain else multi_travel_seconds if rapid_jump else jump_travel_seconds
	_active_jump_recovery_seconds = (
		(desperation_final_recovery_seconds if is_low_health_chain else multi_final_recovery_seconds)
		if rapid_jump and _rapid_jumps_remaining == 0 else
		(desperation_between_jump_seconds if is_low_health_chain else multi_between_jump_seconds)
		if rapid_jump else jump_recovery_seconds
	)
	var final_multiplier := desperation_final_damage_multiplier if is_low_health_chain else multi_final_damage_multiplier
	_active_jump_damage = jump_damage * final_multiplier if rapid_jump and _rapid_jumps_remaining == 0 else jump_damage
	_landing_feedback_strength = (8.0 if is_low_health_chain else 6.5) if rapid_jump and _rapid_jumps_remaining == 0 else 4.0 + float(maxi(_rapid_jump_index, 0)) * 0.7 if rapid_jump else 5.0
	var final_scale := 1.22 if is_low_health_chain else 1.10
	jump_hitbox.scale = Vector2.ONE * (final_scale if rapid_jump and _rapid_jumps_remaining == 0 else 1.0)
	_spawn_marker(_jump_target)
	if rapid_jump and _rapid_jumps_remaining == 0 and is_instance_valid(_marker):
		_marker.scale = Vector2.ONE * final_scale
	jump_target_locked.emit(_jump_target)
	var warning_seconds := jump_wind_up_seconds
	if rapid_jump:
		if is_low_health_chain:
			warning_seconds = desperation_first_warning_seconds if _rapid_jump_index == 0 else desperation_final_warning_seconds if _rapid_jumps_remaining == 0 else desperation_repeat_warning_seconds
		else:
			warning_seconds = multi_first_warning_seconds if _rapid_jump_index == 0 else multi_final_warning_seconds if _rapid_jumps_remaining == 0 else multi_repeat_warning_seconds
	_enter(State.JUMP_WIND_UP, warning_seconds)


func _begin_root_prison(offset: Vector2) -> void:
	_root_ready = false
	var is_low_health := _jump_tier() == JumpTier.DESPERATION
	_active_root_wind_up_seconds = desperation_root_wind_up_seconds if is_low_health else root_wind_up_seconds
	_active_root_tracking_seconds = desperation_root_tracking_seconds if is_low_health else root_tracking_seconds
	_set_facing(offset.normalized() if not offset.is_zero_approx() else facing_direction)
	_enter(State.ROOT_WIND_UP, _active_root_wind_up_seconds)


func _process_jump_travel(delta: float) -> void:
	_jump_elapsed += delta
	var progress := clampf(_jump_elapsed / _active_jump_travel_seconds, 0.0, 1.0)
	var eased := progress * progress * (3.0 - 2.0 * progress)
	global_position = _jump_start.lerp(_jump_target, eased)
	jump_height_changed.emit(sin(progress * PI) * 96.0)
	if progress < 1.0:
		return
	global_position = _jump_target
	jump_height_changed.emit(0.0)
	health_component.set_invulnerable(false)
	_set_collision_enabled(true)
	_clear_marker()
	var final_impact_scale := 1.18 if _active_jump_tier == JumpTier.DESPERATION else 1.08
	_spawn_impact(final_impact_scale if _rapid_jump_active and _rapid_jumps_remaining == 0 else 1.0)
	jump_hitbox.activate_radial(_active_jump_damage, self, global_position, 180.0, 0.0)
	landed.emit(global_position)
	_enter(State.JUMP_LAND, definition.active_seconds)


func _tick_state(delta: float) -> void:
	_state_remaining -= delta
	if _state_remaining > 0.0:
		return
	match state:
		State.LUNGE_WIND_UP:
			lunge_hitbox.activate(definition.attack_damage, self, facing_direction, 120.0, 0.0)
			_enter(State.LUNGE_ACTIVE, definition.active_seconds)
		State.LUNGE_ACTIVE:
			lunge_hitbox.deactivate()
			_enter(State.LUNGE_RECOVERY, definition.recovery_seconds)
		State.LUNGE_RECOVERY:
			_enter(State.CHASE, 0.0)
		State.SLAP_WIND_UP:
			slap_hitbox.activate(slap_damage, self, facing_direction, 185.0, 0.0)
			slap_landed.emit(global_position + facing_direction * 36.0)
			_enter(State.SLAP_ACTIVE, slap_active_seconds)
		State.SLAP_ACTIVE:
			slap_hitbox.deactivate()
			_enter(State.SLAP_RECOVERY, slap_recovery_seconds)
		State.SLAP_RECOVERY:
			_enter(State.CHASE, 0.0)
		State.JUMP_WIND_UP:
			health_component.set_invulnerable(true)
			_set_collision_enabled(false)
			_enter(State.JUMP_TRAVEL, _active_jump_travel_seconds)
		State.JUMP_LAND:
			jump_hitbox.deactivate()
			jump_hitbox.scale = Vector2.ONE
			_enter(State.JUMP_RECOVERY, _active_jump_recovery_seconds)
		State.JUMP_RECOVERY:
			if _rapid_jump_active and _rapid_jumps_remaining > 0:
				_begin_jump(target.global_position - global_position, true)
			else:
				_rapid_jump_active = false
				_root_ready = true
				_enter(State.CHASE, 0.0)
		State.ROOT_WIND_UP:
			_spawn_root_prison()
			_enter(State.ROOT_TRACK, _active_root_tracking_seconds)
		State.ROOT_TRACK:
			_lock_root_prison()
			_enter(State.ROOT_CHANNEL, root_escape_seconds)
		State.ROOT_CHANNEL:
			_execute_root_prison()
			_enter(State.ROOT_EXECUTION, root_execution_seconds)
		State.ROOT_EXECUTION:
			_enter(State.ROOT_RECOVERY, root_recovery_seconds)
		State.ROOT_RECOVERY:
			_jump_cooldown = _jump_reuse_seconds()
			_enter(State.CHASE, 0.0)


func _enter(next_state: State, duration_seconds: float) -> void:
	state = next_state
	_state_remaining = duration_seconds
	if next_state != State.CHASE:
		_set_moving(false)
	state_changed.emit(state, duration_seconds)


func _finish_spawn() -> void:
	if state == State.SPAWNING:
		_enter(State.CHASE, 0.0)


func _set_facing(direction: Vector2) -> void:
	if direction.is_zero_approx():
		return
	facing_direction = direction.normalized()
	facing_changed.emit(facing_direction)


func _set_moving(value: bool) -> void:
	if _is_moving == value:
		return
	_is_moving = value
	movement_changed.emit(value)


func _set_collision_enabled(enabled: bool) -> void:
	body_collision.set_deferred("disabled", not enabled)
	set_collision_layer_value(3, enabled)
	set_collision_mask_value(1, enabled)


func _spawn_marker(position: Vector2) -> void:
	_clear_marker()
	_marker = MarkerScene.instantiate() as Node2D
	_effects_parent().add_child(_marker)
	_marker.global_position = position


func _clear_marker() -> void:
	if is_instance_valid(_marker):
		_marker.queue_free()
	_marker = null


func _spawn_impact(scale_multiplier := 1.0) -> void:
	var impact := ImpactScene.instantiate() as Node2D
	_effects_parent().add_child(impact)
	impact.global_position = global_position
	impact.scale = Vector2.ONE * scale_multiplier


func _pursuit_target(jump_index: int, is_final: bool) -> Vector2:
	var target_position := target.global_position
	if is_final:
		return target_position
	var movement := target.velocity
	var pursuit := (target_position - global_position).normalized()
	if pursuit.is_zero_approx():
		pursuit = facing_direction
	match jump_index:
		1:
			# Read the current escape direction and land ahead of it.
			var lead := movement.normalized() if not movement.is_zero_approx() else pursuit
			target_position += lead * 46.0
		2:
			# Cut across the escape lane instead of repeating the same lead.
			var lane := movement.normalized() if not movement.is_zero_approx() else pursuit
			var side := Vector2(-lane.y, lane.x)
			if side.dot(target_position - global_position) < 0.0:
				side = -side
			target_position += lane * 28.0 + side * 42.0
		3:
			# A five-jump chain cuts back across the opposite side before its finisher.
			var lane := movement.normalized() if not movement.is_zero_approx() else pursuit
			var side := Vector2(lane.y, -lane.x)
			target_position += lane * 18.0 + side * 48.0
	return target_position


func _navigation_chase_direction(delta: float, direct_offset: Vector2) -> Vector2:
	_obstacle_detour_remaining = maxf(_obstacle_detour_remaining - delta, 0.0)
	if _obstacle_detour_remaining > 0.0 and not _obstacle_detour_direction.is_zero_approx():
		return _obstacle_detour_direction
	_navigation_repath_remaining -= delta
	if _navigation_repath_remaining <= 0.0:
		navigation_agent.target_position = target.global_position
		_navigation_repath_remaining = navigation_repath_seconds
	var next_path_position := navigation_agent.get_next_path_position()
	if not navigation_agent.is_navigation_finished() and not next_path_position.is_zero_approx():
		var path_offset := next_path_position - global_position
		if not path_offset.is_zero_approx():
			return path_offset
	return direct_offset


func _capture_obstacle_detour() -> void:
	if get_slide_collision_count() == 0:
		return
	var collision := get_slide_collision(0)
	if collision == null or not collision.get_collider() is StaticBody2D:
		return
	var normal := collision.get_normal().normalized()
	if normal.is_zero_approx():
		return
	var tangent := Vector2(-normal.y, normal.x)
	var alternate := -tangent
	var probe_distance := definition.movement_footprint_radius * 3.0
	var tangent_probe := global_position + tangent * probe_distance
	var alternate_probe := global_position + alternate * probe_distance
	if alternate_probe.distance_squared_to(target.global_position) < tangent_probe.distance_squared_to(target.global_position):
		tangent = alternate
	_obstacle_detour_direction = (tangent + normal * 0.12).normalized()
	_obstacle_detour_remaining = obstacle_detour_seconds


func resolve_navigation_safe_position(requested_position: Vector2) -> Vector2:
	var navigation_map := navigation_agent.get_navigation_map()
	var has_navigation := (
		navigation_map.is_valid()
		and NavigationServer2D.map_get_iteration_id(navigation_map) > 0
	)
	var candidate := (
		NavigationServer2D.map_get_closest_point(navigation_map, requested_position)
		if has_navigation else requested_position
	)
	if candidate.is_zero_approx():
		candidate = requested_position
	if _is_landing_position_clear(candidate):
		return candidate
	# A projected navigation cutout can still return its boundary for a point
	# requested inside solid scenery. Search the smallest nearby boss-sized ring
	# and re-project each option so a committed leap never reenables collision
	# while overlapping a prop.
	for radius in range(24, 105, 8):
		for angle_index in 16:
			var option := requested_position + Vector2.RIGHT.rotated(
				TAU * float(angle_index) / 16.0
			) * float(radius)
			option = option.clamp(
				arena_bounds.position + Vector2(24.0, 24.0),
				arena_bounds.end - Vector2(24.0, 24.0)
			)
			if has_navigation:
				var projected := NavigationServer2D.map_get_closest_point(navigation_map, option)
				if not projected.is_zero_approx():
					option = projected
			if _is_landing_position_clear(option):
				return option
	return candidate


func _is_landing_position_clear(position: Vector2) -> bool:
	var circle := CircleShape2D.new()
	circle.radius = definition.movement_footprint_radius + 2.0
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = circle
	query.transform = Transform2D(0.0, position)
	query.collision_mask = 1
	query.collide_with_areas = false
	query.collide_with_bodies = true
	query.exclude = [get_rid()]
	return get_world_2d().direct_space_state.intersect_shape(query, 1).is_empty()


func _jump_tier() -> JumpTier:
	var ratio := health_component.current_health / maxf(health_component.maximum_health, 1.0)
	if ratio <= desperation_health_ratio:
		return JumpTier.DESPERATION
	if ratio < multi_jump_health_ratio:
		return JumpTier.MULTI
	return JumpTier.SINGLE


func _next_jump_chain_count(tier: JumpTier) -> int:
	match tier:
		JumpTier.MULTI:
			var count := 2 + _multi_chain_step % 2
			_multi_chain_step += 1
			return count
		JumpTier.DESPERATION:
			var count := 3 + _desperation_chain_step % 3
			_desperation_chain_step += 1
			return count
	return 1


func _jump_reuse_seconds() -> float:
	match _jump_tier():
		JumpTier.MULTI:
			return multi_jump_reuse_seconds
		JumpTier.DESPERATION:
			return desperation_jump_reuse_seconds
	return single_jump_reuse_seconds


func get_landing_feedback_strength() -> float:
	return _landing_feedback_strength


func play_entrance_landing() -> void:
	_spawn_impact(1.22)
	landed.emit(global_position)


func _on_health_changed(current: float, maximum: float) -> void:
	if _low_phase_entered or current <= 0.0 or maximum <= 0.0:
		return
	if current / maximum > desperation_health_ratio:
		return
	_low_phase_entered = true
	_low_phase_pending = true


func _spawn_root_prison() -> void:
	_clear_root_prison()
	_root_effect = RootPrisonScene.instantiate() as Stage5BossRootPrison
	_effects_parent().add_child(_root_effect)
	_root_effect.global_position = target.global_position
	if target is Player:
		_root_effect.begin_tracking(target as Player, self)


func _lock_root_prison() -> void:
	if not is_instance_valid(_root_effect) or not is_instance_valid(target):
		return
	_root_target_position = _root_effect.global_position
	var captured := false
	if target is Player and target.global_position.distance_to(_root_target_position) <= root_capture_radius:
		var player := target as Player
		captured = player.try_begin_root_restraint(self, root_break_points)
		if captured:
			_root_target_position = player.global_position
			_root_effect.global_position = _root_target_position
			_root_effect.bind_restraint(player, self)
			player.health_component.apply_damage(DamageInfo.new(root_capture_damage, self, facing_direction, 0.0, 0.0))
	_root_effect.lock_target(captured, root_break_points)
	root_locked.emit(_root_target_position, captured)


func _execute_root_prison() -> void:
	var hit_player := false
	if target is Player:
		var player := target as Player
		## The restraint is one escape problem; the locked eruption is another.
		## Breaking free or dash-avoiding capture buys movement, not immunity.
		if player.global_position.distance_to(_root_target_position) <= root_capture_radius:
			hit_player = player.health_component.apply_damage(
				DamageInfo.new(root_execution_damage, self, (player.global_position - global_position).normalized(), 0.0, 0.0)
			)
		if player.is_restrained_by(self):
			player.release_root_restraint(self, false)
	if is_instance_valid(_root_effect):
		_root_effect.play_execution()
	root_executed.emit(_root_target_position, hit_player)


func _clear_root_prison() -> void:
	if target is Player:
		(target as Player).release_root_restraint(self, false)
	if is_instance_valid(_root_effect):
		_root_effect.cancel_effect()
	_root_effect = null


func _effects_parent() -> Node2D:
	var effects := get_tree().get_first_node_in_group("boss_effects") as Node2D
	return effects if effects != null else get_parent() as Node2D


func _die() -> void:
	state = State.DEAD
	velocity = Vector2.ZERO
	lunge_hitbox.deactivate()
	slap_hitbox.deactivate()
	jump_hitbox.deactivate()
	_clear_marker()
	_clear_root_prison()
	health_component.set_invulnerable(false)
	collision_layer = 0
	collision_mask = 0
	state_changed.emit(State.DEAD, 1.25)
	set_physics_process(false)
