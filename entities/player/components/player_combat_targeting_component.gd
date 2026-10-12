class_name PlayerCombatTargetingComponent
extends Node

## Owns one explicit assisted-combat target. It supplies movement intent but
## never overrides manual input, dash, skills, or Player's action authority.

signal target_changed(actor: Node2D, health: HealthComponent, display_name: String)
signal target_health_changed(current: float, maximum: float)
signal click_move_changed(world_position: Vector2, active: bool)

const ENEMY_HURTBOX_MASK := 1 << 4
const ENEMY_FOOTPRINT_MASK := 1 << 2
const PLAYER_FOOTPRINT_RADIUS := 6.0
const ATTACK_APPROACH_PADDING := 8.0
const TARGET_REPATH_SECONDS := 0.12

@export var player: Player
@export var navigation_agent: NavigationAgent2D
@export_range(32.0, 600.0, 1.0, "suffix:px") var attack_button_assist_radius := 260.0

var target_actor: Node2D
var target_health: HealthComponent
var auto_attack_enabled := false
var _target_hurtbox: HurtboxComponent
var _repath_remaining := 0.0
var _click_move_target := Vector2.ZERO
var _click_move_active := false


func _ready() -> void:
	if player == null or navigation_agent == null:
		push_error("PlayerCombatTargetingComponent requires Player and NavigationAgent2D references.")


func select_at_world_position(world_position: Vector2, enable_assistance := false) -> bool:
	if player == null or not player.is_inside_tree():
		return false
	## The point query reaches both the authored hurtbox and the physical foot
	## circle. This lets the player click the readable underfoot aura without
	## making that presentation node damage authority.
	var pick_shape := CircleShape2D.new()
	pick_shape.radius = 8.0
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = pick_shape
	query.transform = Transform2D(0.0, world_position)
	query.collision_mask = ENEMY_HURTBOX_MASK
	query.collide_with_areas = true
	query.collide_with_bodies = false
	var results := player.get_world_2d().direct_space_state.intersect_shape(query, 16)
	var best_hurtbox: HurtboxComponent
	var best_distance := INF
	for result: Dictionary in results:
		var hurtbox := result.get("collider") as HurtboxComponent
		if not _is_selectable_hurtbox(hurtbox):
			continue
		var distance := hurtbox.global_position.distance_squared_to(world_position)
		if distance < best_distance:
			best_distance = distance
			best_hurtbox = hurtbox
	if best_hurtbox == null:
		query.collision_mask = ENEMY_FOOTPRINT_MASK
		query.collide_with_areas = false
		query.collide_with_bodies = true
		for result: Dictionary in player.get_world_2d().direct_space_state.intersect_shape(query, 16):
			var actor := result.get("collider") as Node2D
			var footprint_hurtbox := _get_actor_hurtbox(actor)
			if not _is_selectable_hurtbox(footprint_hurtbox):
				continue
			var footprint_distance := actor.global_position.distance_squared_to(world_position)
			if footprint_distance < best_distance:
				best_distance = footprint_distance
				best_hurtbox = footprint_hurtbox
	if best_hurtbox == null:
		return false
	return select_hurtbox(best_hurtbox, enable_assistance)


func select_hurtbox(hurtbox: HurtboxComponent, enable_assistance := false) -> bool:
	if not _is_selectable_hurtbox(hurtbox):
		return false
	var actor := hurtbox.get_parent() as Node2D
	cancel_click_move()
	if actor == target_actor:
		auto_attack_enabled = enable_assistance
		return true
	_disconnect_target()
	_target_hurtbox = hurtbox
	target_actor = actor
	target_health = hurtbox.health_component
	auto_attack_enabled = enable_assistance
	_repath_remaining = 0.0
	target_health.health_changed.connect(_on_target_health_changed)
	target_health.died.connect(_on_target_died)
	target_actor.tree_exiting.connect(_on_target_tree_exiting)
	target_changed.emit(target_actor, target_health, _resolve_display_name(target_actor))
	_set_combat_cursor_selected(true)
	target_health_changed.emit(target_health.current_health, target_health.maximum_health)
	return true


func get_selectable_targets() -> Array[Dictionary]:
	## The roster is a UI convenience only. Physics hurtboxes remain the shared
	## source of truth, so dead/despawned enemies cannot leave stale cards.
	var targets: Array[Dictionary] = []
	if player == null or not player.is_inside_tree():
		return targets
	var query := PhysicsShapeQueryParameters2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 2000.0
	query.shape = shape
	query.transform = Transform2D(0.0, player.global_position)
	query.collision_mask = ENEMY_HURTBOX_MASK
	query.collide_with_areas = true
	query.collide_with_bodies = false
	var seen: Dictionary = {}
	for result: Dictionary in player.get_world_2d().direct_space_state.intersect_shape(query, 64):
		var hurtbox := result.get("collider") as HurtboxComponent
		if not _is_selectable_hurtbox(hurtbox):
			continue
		var actor := hurtbox.get_parent() as Node2D
		if seen.has(actor):
			continue
		seen[actor] = true
		targets.append({
			"actor": actor,
			"hurtbox": hurtbox,
			"health": hurtbox.health_component,
			"definition": actor.get("definition"),
			"distance": player.global_position.distance_squared_to(actor.global_position),
		})
	targets.sort_custom(func(left: Dictionary, right: Dictionary) -> bool:
		var left_definition: Variant = left.get("definition")
		var right_definition: Variant = right.get("definition")
		var left_tier: int = (left_definition as EnemyDefinition).crowd_control_tier if left_definition is EnemyDefinition else EnemyDefinition.CrowdControlTier.LIGHT
		var right_tier: int = (right_definition as EnemyDefinition).crowd_control_tier if right_definition is EnemyDefinition else EnemyDefinition.CrowdControlTier.LIGHT
		if left_tier != right_tier:
			return left_tier > right_tier
		return float(left.get("distance", INF)) < float(right.get("distance", INF))
	)
	return targets


func select_nearest_target() -> bool:
	if player == null or not player.is_inside_tree():
		return false
	var shape := CircleShape2D.new()
	shape.radius = attack_button_assist_radius
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.transform = Transform2D(0.0, player.global_position)
	query.collision_mask = ENEMY_HURTBOX_MASK
	query.collide_with_areas = true
	query.collide_with_bodies = false
	var results := player.get_world_2d().direct_space_state.intersect_shape(query, 64)
	var best_hurtbox: HurtboxComponent
	var best_distance := INF
	for result: Dictionary in results:
		var hurtbox := result.get("collider") as HurtboxComponent
		if not _is_selectable_hurtbox(hurtbox):
			continue
		var distance := player.global_position.distance_squared_to(hurtbox.get_parent().global_position)
		if distance < best_distance:
			best_distance = distance
			best_hurtbox = hurtbox
	return select_hurtbox(best_hurtbox) if best_hurtbox != null else false


func engage_next_roster_target() -> bool:
	for target: Dictionary in get_selectable_targets():
		var hurtbox := target.get("hurtbox") as HurtboxComponent
		if select_hurtbox(hurtbox, true):
			return true
	return false


func clear_target() -> void:
	if target_actor == null and target_health == null:
		return
	_disconnect_target()
	_set_combat_cursor_selected(false)
	target_changed.emit(null, null, "")


func _set_combat_cursor_selected(selected: bool) -> void:
	var cursor_service := get_node_or_null("/root/CursorService")
	if cursor_service != null and cursor_service.has_method("set_combat_target_selected"):
		cursor_service.set_combat_target_selected(selected)


func has_valid_target() -> bool:
	return (
		is_instance_valid(target_actor)
		and is_instance_valid(target_health)
		and target_health.current_health > 0.0
		and target_actor.is_inside_tree()
	)


func get_direction_to_target() -> Vector2:
	if not has_valid_target():
		return Vector2.ZERO
	return (target_actor.global_position - player.global_position).normalized()


func get_assisted_move_direction(delta: float) -> Vector2:
	if not auto_attack_enabled or not has_valid_target() or is_target_in_attack_range():
		return Vector2.ZERO
	_repath_remaining -= delta
	if _repath_remaining <= 0.0:
		navigation_agent.target_desired_distance = get_target_approach_distance()
		navigation_agent.target_position = target_actor.global_position
		_repath_remaining = TARGET_REPATH_SECONDS
	var steering := navigation_agent.get_next_path_position() - player.global_position
	if navigation_agent.is_navigation_finished() or steering.is_zero_approx():
		steering = target_actor.global_position - player.global_position
	return steering.normalized()


func is_target_in_attack_range() -> bool:
	if not has_valid_target() or player.attack_component.weapon == null:
		return false
	## Assisted attacks stop on the readable foot-circle boundary, then rely on
	## the real melee hitbox for damage. This avoids centre-distance hovering on
	## large actors and makes approach range match the visible footprint.
	return player.global_position.distance_to(target_actor.global_position) <= get_target_approach_distance()


func get_target_approach_distance() -> float:
	return PLAYER_FOOTPRINT_RADIUS + _get_target_footprint_radius() + ATTACK_APPROACH_PADDING


func is_target_within_assist_radius() -> bool:
	return (
		has_valid_target()
		and player.global_position.distance_to(target_actor.global_position)
		<= attack_button_assist_radius
	)


func suspend_auto_attack() -> void:
	auto_attack_enabled = false


func resume_auto_attack() -> bool:
	if not has_valid_target():
		return false
	cancel_click_move()
	auto_attack_enabled = true
	return true


func request_click_move(world_position: Vector2) -> void:
	clear_target()
	_click_move_target = world_position
	_click_move_active = true
	_repath_remaining = 0.0
	navigation_agent.target_desired_distance = 8.0
	click_move_changed.emit(_click_move_target, true)


func cancel_click_move() -> void:
	if not _click_move_active:
		return
	_click_move_active = false
	_repath_remaining = 0.0
	click_move_changed.emit(_click_move_target, false)


func get_click_move_direction(delta: float) -> Vector2:
	if not _click_move_active or player == null:
		return Vector2.ZERO
	if player.global_position.distance_to(_click_move_target) <= 8.0:
		cancel_click_move()
		return Vector2.ZERO
	_repath_remaining -= delta
	if _repath_remaining <= 0.0:
		navigation_agent.target_position = _click_move_target
		_repath_remaining = TARGET_REPATH_SECONDS
	var steering := navigation_agent.get_next_path_position() - player.global_position
	if navigation_agent.is_navigation_finished() or steering.is_zero_approx():
		steering = _click_move_target - player.global_position
	return steering.normalized()


func _is_selectable_hurtbox(hurtbox: HurtboxComponent) -> bool:
	return (
		is_instance_valid(hurtbox)
		and hurtbox.selectable_as_combat_target
		and is_instance_valid(hurtbox.health_component)
		and hurtbox.health_component.current_health > 0.0
		and hurtbox.get_parent() is Node2D
	)


func _get_actor_hurtbox(actor: Node2D) -> HurtboxComponent:
	if actor == null:
		return null
	return actor.get_node_or_null("Hurtbox") as HurtboxComponent


func _get_target_footprint_radius() -> float:
	if not is_instance_valid(target_actor):
		return PLAYER_FOOTPRINT_RADIUS
	var definition: Variant = target_actor.get("definition")
	if definition is EnemyDefinition:
		return maxf((definition as EnemyDefinition).movement_footprint_radius, 2.0)
	return PLAYER_FOOTPRINT_RADIUS


func _resolve_display_name(actor: Node) -> String:
	var definition: Variant = actor.get("definition")
	if definition is EnemyDefinition:
		return (definition as EnemyDefinition).display_name
	return actor.name.capitalize()


func _on_target_health_changed(current: float, maximum: float) -> void:
	target_health_changed.emit(current, maximum)


func _on_target_died() -> void:
	clear_target()


func _on_target_tree_exiting() -> void:
	clear_target()


func _disconnect_target() -> void:
	if is_instance_valid(target_health):
		if target_health.health_changed.is_connected(_on_target_health_changed):
			target_health.health_changed.disconnect(_on_target_health_changed)
		if target_health.died.is_connected(_on_target_died):
			target_health.died.disconnect(_on_target_died)
	if is_instance_valid(target_actor) and target_actor.tree_exiting.is_connected(_on_target_tree_exiting):
		target_actor.tree_exiting.disconnect(_on_target_tree_exiting)
	_target_hurtbox = null
	target_actor = null
	target_health = null
	auto_attack_enabled = false
	_repath_remaining = 0.0
