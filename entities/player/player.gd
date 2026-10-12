class_name Player
extends CharacterBody2D

## Coordinates player intent, movement authority, and outward-facing state.

signal facing_changed(direction: Vector2)
signal movement_changed(direction: Vector2, is_moving: bool)
signal interaction_started
signal interaction_finished
signal defeated
signal testing_preset_applied(level: int, coins: int)
signal equipment_stats_changed
signal weapon_definition_changed(weapon: WeaponDefinition)
signal skill_loadout_changed
signal selected_skill_changed(slot_number: int)
signal restraint_started(source: Node, total_break_points: int)
signal restraint_progress(source: Node, remaining_break_points: int, total_break_points: int)
signal restraint_ended(source: Node, escaped: bool)
signal action_denied(action: StringName)
signal auto_combat_changed(auto_farm_enabled: bool, auto_skills_enabled: bool)
signal hit_recovery_started(duration_seconds: float)
signal hit_recovery_kind_changed(duration_seconds: float)
signal hit_recovery_finished

enum BufferedAction { NONE, PRIMARY_ATTACK, EVADE, ABILITY }

const ACTION_BUFFER_WINDOW_SECONDS := 0.8
const PRIMARY_CLICK_ENGAGE_WINDOW_MSEC := 520
const PRIMARY_CLICK_REPEAT_RADIUS := 14.0

const PlayerInputSourceScript = preload("res://entities/player/components/player_input_source.gd")
const HeldAttackScript = preload("res://entities/player/components/player_held_attack_component.gd")
const PlayerMovementComponentScript = preload("res://entities/player/components/player_movement_component.gd")
const MeleeAttackComponentScript = preload("res://entities/player/components/melee_attack_component.gd")
const EvadeComponentScript = preload("res://entities/player/components/evade_component.gd")
const AbilityComponentScript = preload("res://gameplay/abilities/ability_component.gd")
const DirectionalWedgeTargetingScript = preload("res://gameplay/abilities/targeting/directional_wedge_targeting.gd")
const GroundPointTargetingScript = preload("res://gameplay/abilities/targeting/ground_point_targeting.gd")
const CombatTargetingScript = preload("res://entities/player/components/player_combat_targeting_component.gd")
@export var movement_bounds := Rect2(56.0, 56.0, 528.0, 248.0)
@export var character_id: StringName = &"king"
@export var character_class_id: StringName = &"warrior"
@export var skill_loadout: SkillLoadoutDefinition
@export var debug_test_skill_loadout: SkillLoadoutDefinition
@export var weapon_catalog: WeaponCatalogDefinition

@onready var input_source: PlayerInputSourceScript = %InputSource
@onready var movement_component: PlayerMovementComponentScript = %MovementComponent
@onready var attack_component: MeleeAttackComponentScript = %MeleeAttackComponent
@onready var evade_component: EvadeComponentScript = %EvadeComponent
@onready var ability_1_component: AbilityComponentScript = %Ability1Component
@onready var ability_2_component: AbilityComponentScript = %Ability2Component
@onready var ability_3_component: AbilityComponentScript = %Ability3Component
@onready var ability_4_component: AbilityComponentScript = %Ability4Component
@onready var directional_wedge_targeting: DirectionalWedgeTargetingScript = %DirectionalWedgeTargeting
@onready var ground_point_targeting: GroundPointTargetingScript = %GroundPointTargeting
@onready var combat_targeting: CombatTargetingScript = %CombatTargetingComponent
@onready var auto_combat: PlayerAutoCombatComponent = %AutoCombatComponent
@onready var health_component: HealthComponent = %HealthComponent
@onready var knockback_component: KnockbackComponent = %KnockbackComponent
@onready var stagger_component: StaggerComponent = %StaggerComponent
@onready var progression_component: PlayerProgressionComponent = %ProgressionComponent
@onready var vitality_component: PlayerVitalityComponent = %VitalityComponent
@onready var health_regeneration_component: PlayerHealthRegenerationComponent = %HealthRegenerationComponent
@onready var weapon_visual: PlayerWeaponVisual = $VisualRoot/WeaponVisual
@onready var action_buffer_timer: Timer = %ActionBufferTimer

var facing_direction := Vector2.DOWN
var selected_skill_slot := 1
var is_defeated := false
var _was_moving := false
var _buffered_action := BufferedAction.NONE
var _buffered_action_direction := Vector2.DOWN
var _buffered_ability_slot := 0
var _pending_weapon_definition: WeaponDefinition
var _debug_unlimited_skills := false
var _restraint_source: Node
var _restraint_break_points := 0
var _restraint_total_break_points := 0
var _last_primary_target_id := 0
var _last_primary_click_msec := -PRIMARY_CLICK_ENGAGE_WINDOW_MSEC
var _last_primary_click_world_position := Vector2.ZERO
var _applied_knockback_velocity := Vector2.ZERO
var _was_ability_movement_active := false
var _cinematic_locked := false
var held_attack: PlayerHeldAttackComponent
var _buffered_primary_from_hold := false


func _ready() -> void:
	held_attack = HeldAttackScript.new()
	held_attack.actor = self
	held_attack.name = "HeldAttackIntent"
	add_child(held_attack)
	interaction_started.connect(held_attack.cancel)
	_restore_run_health()
	health_component.health_changed.connect(_sync_run_health)
	health_component.died.connect(_on_died)
	stagger_component.stagger_started.connect(_on_hit_recovery_started)
	stagger_component.stagger_finished.connect(_on_hit_recovery_finished)
	stagger_component.stun_changed.connect(_on_hit_recovery_kind_changed)
	evade_component.phase_changed.connect(_on_evade_phase_changed)
	attack_component.phase_changed.connect(_on_attack_phase_changed)
	attack_component.attack_finished.connect(_on_attack_finished)
	for component in get_all_ability_components():
		component.ability_finished.connect(_on_ability_finished)
	action_buffer_timer.timeout.connect(_clear_buffered_action)
	auto_combat.mode_changed.connect(_on_auto_combat_mode_changed)
	directional_wedge_targeting.targeting_confirmed.connect(_on_directional_targeting_confirmed)
	ground_point_targeting.targeting_confirmed.connect(_on_ground_targeting_confirmed)
	_apply_inventory_weapon()
	var gear_inventory := get_node_or_null("/root/GearInventory")
	if gear_inventory != null:
		gear_inventory.gear_equipped.connect(_on_gear_equipped)
		gear_inventory.inventory_reset.connect(_apply_equipment_stats)
	_apply_equipment_stats()
	facing_changed.emit(facing_direction)


func _restore_run_health() -> void:
	var run_session := get_node_or_null("/root/RunSession")
	if run_session == null:
		return
	if run_session.has_player_health_state():
		health_component.set_current_health(
			clampf(
				run_session.player_current_health,
				1.0,
				health_component.maximum_health
			)
		)
	else:
		run_session.update_player_health(health_component.current_health)


func _sync_run_health(current: float, _maximum: float) -> void:
	var run_session := get_node_or_null("/root/RunSession")
	if run_session != null:
		run_session.update_player_health(current)


func _physics_process(delta: float) -> void:
	velocity -= _applied_knockback_velocity
	_applied_knockback_velocity = Vector2.ZERO
	if _cinematic_locked:
		velocity = Vector2.ZERO
		if _was_moving:
			_was_moving = false
			movement_changed.emit(Vector2.ZERO, false)
		return
	_try_apply_pending_weapon()
	if not is_in_hit_recovery():
		auto_combat.update_auto_combat(delta)
	var manual_move_direction := input_source.get_move_direction()
	var move_direction := manual_move_direction
	if (
		move_direction.is_zero_approx()
		and not is_restrained()
		and not is_in_hit_recovery()
		and not evade_component.is_dashing()
		and not is_any_ability_casting()
	):
		move_direction = combat_targeting.get_assisted_move_direction(delta)
		if move_direction.is_zero_approx():
			move_direction = combat_targeting.get_click_move_direction(delta)
	if directional_wedge_targeting.is_targeting():
		directional_wedge_targeting.update_aim(
			get_global_mouse_position() - directional_wedge_targeting.global_position,
			input_source.get_aim_direction()
		)
	if not manual_move_direction.is_zero_approx() and not is_restrained() and not is_in_hit_recovery():
		_cancel_combat_intent_for_manual_movement()
	if not move_direction.is_zero_approx() and not is_restrained() and not is_in_hit_recovery():
		_set_movement_facing_direction(move_direction)
	elif combat_targeting.has_valid_target() and not is_restrained():
		_set_movement_facing_direction(combat_targeting.get_direction_to_target())
	if input_source.is_evade_just_pressed():
		## A stationary dodge is a defensive backstep, not an accidental forward lunge.
		var evade_direction := move_direction if not move_direction.is_zero_approx() else -facing_direction
		request_evade(evade_direction)
	if input_source.is_ability_1_just_pressed():
		request_ability_1()
	if input_source.is_ability_2_just_pressed():
		request_ability(2)
	if input_source.is_ability_3_just_pressed():
		request_ability(3)
	if input_source.is_ability_4_just_pressed():
		request_ability(4)
	for slot_number in range(5, SkillLoadoutDefinition.SLOT_COUNT + 1):
		if Input.is_action_just_pressed("player_skill_%d" % slot_number):
			request_ability(slot_number)
	if Input.is_action_just_pressed("player_skill_previous") or Input.is_action_just_pressed("player_skill_next"):
		var step := -1 if Input.is_action_just_pressed("player_skill_previous") else 1
		selected_skill_slot = posmod(selected_skill_slot - 1 + step, SkillLoadoutDefinition.SLOT_COUNT) + 1
		selected_skill_changed.emit(selected_skill_slot)
	if Input.is_action_just_pressed("player_skill_selected"):
		request_ability(selected_skill_slot)
	_try_assisted_primary_attack()
	var active_ability := get_active_ability_component()
	var ability_movement_active := active_ability != null and active_ability.has_active_movement()
	# A mobility skill's travel speed is authored movement, not walking momentum.
	# Discard it on landing/cancel before normal deceleration can produce a slide.
	if _was_ability_movement_active and not ability_movement_active:
		velocity = Vector2.ZERO
	_was_ability_movement_active = ability_movement_active

	if is_restrained():
		velocity = movement_component.calculate_velocity(velocity, Vector2.ZERO, delta)
	elif is_in_hit_recovery():
		velocity = movement_component.calculate_velocity(velocity, Vector2.ZERO, delta)
	elif evade_component.is_dashing():
		velocity = evade_component.get_dash_velocity()
	elif is_any_ability_casting():
		if ability_movement_active:
			velocity = active_ability.get_active_velocity()
		else:
			velocity = movement_component.calculate_velocity(velocity, Vector2.ZERO, delta)
	else:
		var attack_walk_ratio := attack_component.weapon.get_attack_movement_ratio(attack_component.phase) if attack_component.weapon != null else 1.0
		velocity = movement_component.calculate_velocity(velocity, move_direction, delta, attack_walk_ratio)
	_apply_incoming_knockback()
	var is_moving := (
		not move_direction.is_zero_approx()
		and velocity.length_squared() > 0.01
		and not is_restrained()
		and not is_in_hit_recovery()
		and not evade_component.is_dashing()
		and not is_any_ability_casting()
	)
	if is_moving != _was_moving:
		_was_moving = is_moving
		movement_changed.emit(move_direction, is_moving)
	move_and_slide()
	global_position = global_position.clamp(
		movement_bounds.position,
		movement_bounds.end
	)

func _unhandled_input(event: InputEvent) -> void:
	if _cinematic_locked:
		get_viewport().set_input_as_handled()
		return
	if _is_targeting_any_ability():
		var is_left_mouse_confirm: bool = (
			event is InputEventMouseButton
			and event.button_index == MOUSE_BUTTON_LEFT
			and event.pressed
		)
		var is_non_mouse_confirm: bool = (
			not (event is InputEventMouseButton)
			and event.is_action_pressed("player_attack_primary")
		)
		if is_left_mouse_confirm or is_non_mouse_confirm:
			if directional_wedge_targeting.is_targeting():
				directional_wedge_targeting.confirm_targeting()
			else:
				ground_point_targeting.update_aim(get_global_mouse_position(), input_source.get_aim_direction())
				ground_point_targeting.confirm_targeting()
			get_viewport().set_input_as_handled()
			return
		if (
			event.is_action_pressed("ui_cancel")
			or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed)
		):
			_cancel_all_targeting()
			get_viewport().set_input_as_handled()
			return
	if event.is_action_pressed("ui_cancel") and combat_targeting.has_valid_target():
		auto_combat.set_auto_farm_enabled(false)
		combat_targeting.clear_target()
		get_viewport().set_input_as_handled()
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		auto_combat.set_auto_farm_enabled(false)
		_clear_primary_click_sequence()
		combat_targeting.request_click_move(get_global_mouse_position())
		get_viewport().set_input_as_handled()
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if request_world_primary_click(get_global_mouse_position(), event.double_click):
			held_attack.begin_world_press()
			get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("player_attack_primary"):
		var attack_requested := false
		if event is InputEventMouseButton:
			attack_requested = request_directional_primary_attack(get_global_mouse_position())
		else:
			attack_requested = request_primary_attack()
		if attack_requested:
			get_viewport().set_input_as_handled()
		return
	if not event.is_action_pressed("debug_max_progression"):
		return
	apply_debug_testing_preset()
	get_viewport().set_input_as_handled()


func set_cinematic_locked(value: bool) -> void:
	if _cinematic_locked == value:
		return
	_cinematic_locked = value
	if not value:
		return
	held_attack.cancel()
	_clear_buffered_action()
	_cancel_all_targeting()
	combat_targeting.clear_target()
	auto_combat.set_auto_farm_enabled(false)
	attack_component.cancel_attack()
	evade_component.cancel_evade()
	for component in get_all_ability_components():
		component.cancel_cast()
	knockback_component.clear()
	stagger_component.clear()
	velocity = Vector2.ZERO


func is_cinematic_locked() -> bool:
	return _cinematic_locked


func apply_debug_testing_preset() -> void:
	if not OS.is_debug_build():
		return
	progression_component.apply_debug_testing_preset()
	var save_service := get_node_or_null("/root/SaveService")
	if save_service != null:
		save_service.suppress_autosave_for_debug_session()
	_unlock_debug_test_equipment()
	_unlock_debug_test_materials()
	_enable_debug_test_loadout()
	_enable_debug_unlimited_skills()
	_unlock_debug_test_expeditions()
	_enable_debug_admin_tools()
	testing_preset_applied.emit(
		progression_component.level,
		progression_component.coins
	)


func enable_debug_combat_tools() -> void:
	if not OS.is_debug_build():
		return
	var save_service := get_node_or_null("/root/SaveService")
	if save_service != null:
		save_service.suppress_autosave_for_debug_session()
	_enable_debug_test_loadout()
	_enable_debug_unlimited_skills()


func try_begin_root_restraint(source: Node, break_points: int) -> bool:
	if source == null or break_points <= 0 or is_defeated or is_restrained():
		return false
	## Only the real movement dodge avoids the capture boundary. Ability-granted
	## invulnerability is deliberately cancelled and cannot bypass this mechanic.
	if evade_component.is_dashing():
		return false
	held_attack.cancel()
	_clear_buffered_action()
	_cancel_all_targeting()
	attack_component.cancel_attack()
	evade_component.cancel_evade()
	for component in get_all_ability_components():
		component.cancel_cast()
	_restraint_source = source
	_restraint_break_points = break_points
	_restraint_total_break_points = break_points
	velocity = Vector2.ZERO
	if _was_moving:
		_was_moving = false
		movement_changed.emit(Vector2.ZERO, false)
	restraint_started.emit(source, break_points)
	restraint_progress.emit(source, break_points, break_points)
	return true


func is_restrained() -> bool:
	return is_instance_valid(_restraint_source) and _restraint_break_points > 0


func is_restrained_by(source: Node) -> bool:
	return is_restrained() and _restraint_source == source


func release_root_restraint(source: Node, escaped: bool) -> bool:
	## The final struggle press reaches zero before this release call. Ownership,
	## not remaining points, decides whether the source may end its restraint.
	if not is_instance_valid(source) or _restraint_source != source:
		return false
	var previous_source := _restraint_source
	_restraint_source = null
	_restraint_break_points = 0
	_restraint_total_break_points = 0
	restraint_ended.emit(previous_source, escaped)
	return true


func _struggle_against_restraint() -> bool:
	if not is_restrained():
		return false
	_restraint_break_points = maxi(_restraint_break_points - 1, 0)
	var source := _restraint_source
	restraint_progress.emit(source, _restraint_break_points, _restraint_total_break_points)
	if _restraint_break_points <= 0:
		release_root_restraint(source, true)
	return true


func request_primary_attack() -> bool:
	if is_defeated or is_restrained() or is_in_hit_recovery() or _is_targeting_any_ability():
		return false
	if is_any_ability_casting():
		return _buffer_action(BufferedAction.PRIMARY_ATTACK, facing_direction)
	if attack_component.phase != attack_component.Phase.IDLE:
		_buffer_action(BufferedAction.PRIMARY_ATTACK, facing_direction)
		return true
	if evade_component.is_dashing():
		return _buffer_action(BufferedAction.PRIMARY_ATTACK, facing_direction)
	if evade_component.is_recovering():
		var attack_direction := facing_direction
		if not evade_component.cancel_recovery():
			return false
		return attack_component.request_attack(attack_direction)
	if not evade_component.is_ready():
		return false
	var family := get_node_or_null("WeaponFamilyPresentation")
	if family != null and family.prepare_primary_attack():
		return true
	return attack_component.request_attack(facing_direction)


func request_directional_primary_attack(world_position: Vector2) -> bool:
	var attack_direction := world_position - global_position
	if not attack_direction.is_zero_approx():
		_set_movement_facing_direction(attack_direction)
	return request_primary_attack()


func request_held_primary_attack(world_position: Vector2) -> bool:
	# Coalesce repeated intent into one normal cut, without replacing a skill,
	# dodge or deliberate click already in the single action buffer.
	if _buffered_action != BufferedAction.NONE:
		return false
	var accepted := request_directional_primary_attack(world_position)
	if accepted and _buffered_action == BufferedAction.PRIMARY_ATTACK:
		_buffered_primary_from_hold = true
	return accepted


func request_world_primary_click(world_position: Vector2, native_multi_click := false) -> bool:
	## World left click is manual authority. End both ground movement and
	## assisted pursuit before either selecting an enemy or swinging at air.
	## One enemy click selects only; repeated clicks on that same enemy engage.
	auto_combat.set_auto_farm_enabled(false)
	combat_targeting.cancel_click_move()
	combat_targeting.suspend_auto_attack()
	if combat_targeting.select_at_world_position(world_position, false):
		var selected_actor := combat_targeting.target_actor
		var selected_id := selected_actor.get_instance_id() if is_instance_valid(selected_actor) else 0
		var now_msec := Time.get_ticks_msec()
		var is_repeated_target_click := (
			selected_id != 0
			and selected_id == _last_primary_target_id
			and now_msec - _last_primary_click_msec <= PRIMARY_CLICK_ENGAGE_WINDOW_MSEC
			and world_position.distance_to(_last_primary_click_world_position)
			<= PRIMARY_CLICK_REPEAT_RADIUS
		)
		_last_primary_target_id = selected_id
		_last_primary_click_msec = now_msec
		_last_primary_click_world_position = world_position
		if native_multi_click or is_repeated_target_click:
			combat_targeting.resume_auto_attack()
		return true
	_clear_primary_click_sequence()
	return request_directional_primary_attack(world_position)


func request_roster_target(hurtbox: HurtboxComponent, engage := false) -> bool:
	## Roster interaction follows the same select-first, engage-on-repeat rule as
	## world clicks without pretending the UI click has a world-space position.
	auto_combat.set_auto_farm_enabled(false)
	combat_targeting.cancel_click_move()
	combat_targeting.suspend_auto_attack()
	if not combat_targeting.select_hurtbox(hurtbox, false):
		return false
	if engage:
		return combat_targeting.resume_auto_attack()
	return true


func _cancel_combat_intent_for_manual_movement() -> void:
	## WASD and right-click movement are explicit authority changes. Selection,
	## pursuit, and automation must not survive behind that movement command.
	auto_combat.set_auto_farm_enabled(false)
	combat_targeting.cancel_click_move()
	combat_targeting.clear_target()
	_clear_primary_click_sequence()


func _clear_primary_click_sequence() -> void:
	_last_primary_target_id = 0
	_last_primary_click_msec = -PRIMARY_CLICK_ENGAGE_WINDOW_MSEC
	_last_primary_click_world_position = Vector2.ZERO


func request_assisted_primary_attack() -> bool:
	## The HUD/controller Basic Attack remains a normal free swing unless the player
	## has explicitly selected an enemy close enough to reasonably approach.
	if not combat_targeting.is_target_within_assist_radius():
		combat_targeting.suspend_auto_attack()
		return request_primary_attack()
	if not combat_targeting.resume_auto_attack():
		return request_primary_attack()
	if combat_targeting.is_target_in_attack_range():
		_set_movement_facing_direction(combat_targeting.get_direction_to_target())
		if attack_component.phase == attack_component.Phase.IDLE:
			return request_primary_attack()
	return true


func _try_assisted_primary_attack() -> void:
	if (
		not combat_targeting.auto_attack_enabled
		or not combat_targeting.is_target_in_attack_range()
		or attack_component.phase != attack_component.Phase.IDLE
		or evade_component.is_dashing()
		or is_any_ability_casting()
		or is_restrained()
		or is_defeated
	):
		return
	_set_movement_facing_direction(combat_targeting.get_direction_to_target())
	request_primary_attack()


func request_evade(direction: Vector2) -> bool:
	held_attack.cancel()
	if is_defeated or is_in_hit_recovery():
		return false
	if is_restrained():
		return _struggle_against_restraint()
	if direction.is_zero_approx():
		return false
	_cancel_all_targeting()
	if evade_component.get_cooldown_remaining() > 0.0:
		action_denied.emit(&"dash_cooldown")
		return false
	var active_ability := get_active_ability_component()
	if active_ability != null:
		if not evade_component.is_evade_available():
			return false
		if active_ability.definition != null and active_ability.definition.dash_cancelable:
			_clear_buffered_action()
			active_ability.cancel_cast()
		else:
			return _buffer_action(BufferedAction.EVADE, direction)
	if attack_component.phase != attack_component.Phase.IDLE:
		if not evade_component.is_evade_available():
			return false
		_buffer_action(BufferedAction.EVADE, direction)
		if attack_component.phase == attack_component.Phase.RECOVERY:
			return _try_execute_buffered_action()
		return true
	if not evade_component.is_evade_available():
		return false
	return evade_component.request_evade(direction)


func request_ability_1() -> bool:
	return request_ability(1)


func request_ability(slot_number: int) -> bool:
	held_attack.cancel()
	var component := get_ability_component_for_slot(slot_number)
	var direction := facing_direction
	if is_restrained() or is_in_hit_recovery():
		return false
	if _is_targeting_any_ability():
		## Repeating the skill key is intentionally consumed but never confirms.
		## Confirmation belongs only to primary attack/right trigger.
		return directional_wedge_targeting.get_target_component() == component or ground_point_targeting.get_target_component() == component
	if component != null and not component.can_queue_cast():
		action_denied.emit(&"skill_cooldown")
		return false
	if (
		component == null
		or is_defeated
	):
		return false
	if is_any_ability_casting():
		return _buffer_action(BufferedAction.ABILITY, direction, slot_number)
	if not component.is_ready():
		return false
	if attack_component.phase != attack_component.Phase.IDLE:
		_buffer_action(BufferedAction.ABILITY, direction, slot_number)
		if attack_component.phase == attack_component.Phase.RECOVERY:
			return _try_execute_buffered_action()
		return true
	if evade_component.is_dashing():
		return _buffer_action(BufferedAction.ABILITY, direction, slot_number)
	if evade_component.is_recovering():
		_buffer_action(BufferedAction.ABILITY, direction, slot_number)
		return _try_execute_buffered_action()
	if not evade_component.is_ready():
		return false
	return _begin_ability_input(component, direction)


func set_auto_farm_enabled(enabled: bool) -> void:
	auto_combat.set_auto_farm_enabled(enabled)


func set_auto_skills_enabled(enabled: bool) -> void:
	auto_combat.set_auto_skills_enabled(enabled)


func is_targeting_any_ability() -> bool:
	return _is_targeting_any_ability()


func _on_auto_combat_mode_changed(auto_farm_enabled: bool, auto_skills_enabled: bool) -> void:
	auto_combat_changed.emit(auto_farm_enabled, auto_skills_enabled)


func set_weapon_definition(next_weapon: WeaponDefinition) -> bool:
	## Swapping is intentionally idle-only and never changes character-owned
	## body SpriteFrames. Ownership is validated by equip_owned_weapon().
	if (
		next_weapon == null
		or (next_weapon.world_texture == null and not next_weapon.uses_integrated_visual)
		or next_weapon.melee_hitbox_shape == null
		or is_defeated
		or attack_component.phase != attack_component.Phase.IDLE
		or is_any_ability_casting()
		or _is_targeting_any_ability()
		or evade_component.is_dashing()
	):
		return false
	if not weapon_visual.set_weapon_definition(next_weapon):
		return false
	if not attack_component.set_weapon_definition(next_weapon):
		return false
	weapon_definition_changed.emit(next_weapon)
	return true


func get_equipped_weapon_item() -> EquipmentDefinition:
	if weapon_catalog == null or not weapon_catalog.has_valid_layout():
		return null
	var inventory := get_node_or_null("/root/WeaponInventory")
	if inventory == null:
		return weapon_catalog.default_weapon
	var item_id: StringName = inventory.get_equipped_weapon_id(
		character_id,
		weapon_catalog.default_weapon.item_id
	)
	return weapon_catalog.find_weapon(item_id)


func equip_owned_weapon(item: EquipmentDefinition) -> bool:
	if (
		item == null
		or weapon_catalog == null
		or weapon_catalog.find_weapon(item.item_id) != item
		or not item.is_compatible_with(character_class_id)
	):
		return false
	var inventory := get_node_or_null("/root/WeaponInventory")
	if inventory == null or not inventory.owns_weapon(item.item_id):
		return false
	if not inventory.equip_weapon(character_id, character_class_id, item):
		return false
	if set_weapon_definition(item.weapon_definition):
		_pending_weapon_definition = null
	else:
		_pending_weapon_definition = item.weapon_definition
	return true


func get_equipped_gear(slot: EquipmentDefinition.Slot) -> EquipmentDefinition:
	var inventory := get_node_or_null("/root/GearInventory")
	return inventory.get_equipped_item(character_id, slot) if inventory != null else null


func equip_owned_equipment(item: EquipmentDefinition) -> bool:
	if item == null:
		return false
	if item.slot == EquipmentDefinition.Slot.WEAPON:
		return equip_owned_weapon(item)
	var inventory := get_node_or_null("/root/GearInventory")
	return (
		inventory != null
		and inventory.equip_item(character_id, character_class_id, item)
	)


func _on_gear_equipped(
	equipped_character_id: StringName,
	_slot: int,
	_item_id: StringName
) -> void:
	if equipped_character_id == character_id:
		_apply_equipment_stats()


func _apply_equipment_stats() -> void:
	var health_bonus := 0.0
	var armor_bonus := 0.0
	var magic_resistance_bonus := 0.0
	var regeneration_bonus := 0.0
	var ward_bonus := 0.0
	var attack_speed_bonus := 0.0
	var movement_speed_bonus := 0.0
	for slot: EquipmentDefinition.Slot in [
		EquipmentDefinition.Slot.HEAD,
		EquipmentDefinition.Slot.PLATE,
		EquipmentDefinition.Slot.GLOVES,
		EquipmentDefinition.Slot.LEGGINGS,
		EquipmentDefinition.Slot.BOOTS,
		EquipmentDefinition.Slot.BRACER,
		EquipmentDefinition.Slot.AMULET,
		EquipmentDefinition.Slot.RING,
		EquipmentDefinition.Slot.TALISMAN,
	]:
		var item := get_equipped_gear(slot)
		if item == null:
			continue
		health_bonus += item.flat_health_bonus
		armor_bonus += item.armor_bonus
		magic_resistance_bonus += item.magic_resistance_bonus
		regeneration_bonus += item.regeneration_bonus
		ward_bonus += item.ward_reduction_ratio
		attack_speed_bonus += item.attack_speed_bonus_ratio
		movement_speed_bonus += item.movement_speed_bonus_ratio
	vitality_component.set_equipment_health_bonus(health_bonus)
	health_component.set_equipment_defenses(armor_bonus, ward_bonus, magic_resistance_bonus)
	health_regeneration_component.set_flat_regeneration_bonus(regeneration_bonus)
	attack_component.set_equipment_attack_speed_bonus(attack_speed_bonus)
	movement_component.set_equipment_speed_bonus(movement_speed_bonus)
	equipment_stats_changed.emit()


func _apply_inventory_weapon() -> void:
	var equipped_item := get_equipped_weapon_item()
	if equipped_item == null or not set_weapon_definition(equipped_item.weapon_definition):
		push_error("Player requires a valid equipped weapon from its weapon catalog.")


func _try_apply_pending_weapon() -> void:
	if _pending_weapon_definition == null:
		return
	if set_weapon_definition(_pending_weapon_definition):
		_pending_weapon_definition = null


func face_toward(world_position: Vector2) -> void:
	## Used by explicit world interactions before their modal pauses gameplay.
	## Input remains the normal owner of facing outside that interaction moment.
	_set_facing_direction(world_position - global_position)


func begin_interaction(world_position: Vector2) -> void:
	if is_defeated:
		return
	_cancel_all_targeting()
	face_toward(world_position)
	interaction_started.emit()


func finish_interaction() -> void:
	if is_defeated:
		return
	interaction_finished.emit()


func get_ability_component_for_slot(slot_number: int) -> AbilityComponent:
	if skill_loadout == null:
		return null
	var slot := skill_loadout.get_slot(slot_number)
	if slot == null or slot.ability == null:
		return null
	for child: Node in get_children():
		var component := child as AbilityComponent
		if component != null and component.definition != null and component.definition.ability_id == slot.ability.ability_id:
			return component
	return null


func get_all_ability_components() -> Array[AbilityComponent]:
	var result: Array[AbilityComponent] = []
	for child in get_children():
		if child is AbilityComponent:
			result.append(child)
	return result


func get_active_ability_component() -> AbilityComponent:
	for component in get_all_ability_components():
		if component != null and component.is_casting():
			return component
	return null


func is_any_ability_casting() -> bool:
	return get_active_ability_component() != null


func is_in_hit_recovery() -> bool:
	return stagger_component != null and stagger_component.is_staggered()


func _set_facing_direction(direction: Vector2) -> void:
	if direction.is_zero_approx():
		return

	var normalized_direction := direction.normalized()
	if facing_direction.dot(normalized_direction) > 0.9999:
		return

	facing_direction = normalized_direction
	facing_changed.emit(facing_direction)


func _set_movement_facing_direction(move_direction: Vector2) -> void:
	_set_facing_direction(
		input_source.resolve_cardinal_facing(move_direction, facing_direction)
	)


func _on_evade_phase_changed(phase: int, _duration_seconds: float) -> void:
	if phase != EvadeComponent.Phase.RECOVERY:
		return
	_try_execute_buffered_action()


func _on_attack_phase_changed(phase: int, _duration_seconds: float) -> void:
	## A buffered technique never interrupts a live sword hit. It may replace only
	## the normal attack's recovery, matching the existing dash-recovery rule.
	## A repeated primary attack waits for the full recovery so button mashing
	## cannot erase the weapon's authored cadence.
	if (
		phase == MeleeAttackComponent.Phase.RECOVERY
		and _buffered_action != BufferedAction.PRIMARY_ATTACK
	):
		_try_execute_buffered_action()


func _on_attack_finished() -> void:
	if _buffered_action == BufferedAction.PRIMARY_ATTACK:
		if attack_component.weapon.family_presentation != null:
			# Let all finish observers settle before the next phase dispatch.
			_try_execute_buffered_action.call_deferred()
		else:
			_try_execute_buffered_action()


func _buffer_action(action: BufferedAction, direction: Vector2, ability_slot := 0) -> bool:
	## One latest intent survives a short window, or the current family cut's
	## remaining commitment. It never waits through cooldowns or stacks actions.
	_buffered_action = action
	_buffered_primary_from_hold = false
	_buffered_ability_slot = ability_slot
	_buffered_action_direction = (
		direction.normalized()
		if not direction.is_zero_approx()
		else facing_direction
	)
	var window := ACTION_BUFFER_WINDOW_SECONDS
	if action == BufferedAction.PRIMARY_ATTACK and attack_component.weapon.family_presentation != null:
		window = maxf(window, attack_component.get_remaining_attack_seconds() + 0.1)
	action_buffer_timer.start(window)
	return true


func _try_execute_buffered_action() -> bool:
	if (
		_buffered_action == BufferedAction.NONE
		or is_defeated
		or is_restrained()
		or is_in_hit_recovery()
		or is_any_ability_casting()
	):
		return false
	if attack_component.phase != attack_component.Phase.IDLE:
		if attack_component.phase != attack_component.Phase.RECOVERY:
			return false
		attack_component.cancel_attack()
	if evade_component.is_dashing():
		return false
	if evade_component.is_recovering() and not evade_component.cancel_recovery():
		return false
	if not evade_component.is_ready():
		return false
	var action := _buffered_action
	var action_direction := _buffered_action_direction
	var ability_slot := _buffered_ability_slot
	_clear_buffered_action()
	if action == BufferedAction.PRIMARY_ATTACK:
		_set_facing_direction(action_direction)
		return request_primary_attack()
	if action == BufferedAction.EVADE:
		return evade_component.request_evade(action_direction)
	var component := get_ability_component_for_slot(ability_slot)
	if component == null:
		return false
	_set_facing_direction(action_direction)
	return _begin_ability_input(component, action_direction)


func _clear_buffered_action() -> void:
	_buffered_action = BufferedAction.NONE
	_buffered_primary_from_hold = false
	_buffered_ability_slot = 0
	if not action_buffer_timer.is_stopped():
		action_buffer_timer.stop()


func _apply_incoming_knockback() -> void:
	_applied_knockback_velocity = knockback_component.velocity
	velocity += _applied_knockback_velocity


func _on_hit_recovery_started(duration_seconds: float) -> void:
	var active_ability := get_active_ability_component()
	if (
		active_ability != null
		and active_ability.definition != null
		and active_ability.definition.grants_super_armor
	):
		stagger_component.clear()
		return
	held_attack.cancel()
	_clear_buffered_action()
	_cancel_all_targeting()
	attack_component.cancel_attack()
	evade_component.interrupt_recovery()
	for component in get_all_ability_components():
		component.cancel_cast()
	hit_recovery_started.emit(duration_seconds)


func _on_hit_recovery_kind_changed(_stunned: bool) -> void:
	if is_in_hit_recovery() and not is_defeated:
		hit_recovery_kind_changed.emit(stagger_component.remaining_seconds)


func _on_hit_recovery_finished() -> void:
	hit_recovery_finished.emit()


func _begin_ability_input(component: AbilityComponent, direction: Vector2) -> bool:
	if component == null or component.definition == null or not component.is_ready():
		return false
	match component.definition.activation_mode:
		AbilityDefinition.ActivationMode.DIRECTIONAL_WEDGE_TARGETED:
			return directional_wedge_targeting.begin_targeting(component, direction)
		AbilityDefinition.ActivationMode.GROUND_TARGETED:
			return ground_point_targeting.begin_targeting(component, direction)
		AbilityDefinition.ActivationMode.IMMEDIATE_DIRECTIONAL, AbilityDefinition.ActivationMode.SELF_AREA:
			return _start_ability(component, direction)
	return false


func _start_ability(component: AbilityComponent, direction: Vector2) -> bool:
	var weapon_damage := (
		attack_component.weapon.damage
		if attack_component.weapon != null
		else 0.0
	)
	_configure_ability_critical_profile(component)
	return component.request_cast(direction, weapon_damage)


func _on_directional_targeting_confirmed(component: AbilityComponent, direction: Vector2) -> void:
	if component == null or is_defeated or is_any_ability_casting():
		return
	## The hitbox/VFX preserve the exact 360-degree aim. King's current body art
	## deliberately chooses the nearest cardinal animation until diagonal sheets
	## are ever approved, and ordinary post-cast combat facing stays cardinal.
	_set_facing_direction(
		input_source.resolve_cardinal_facing(direction, facing_direction)
	)
	_start_ability(component, direction)


func _on_ground_targeting_confirmed(component: AbilityComponent, target_global_position: Vector2) -> void:
	if component == null or is_defeated or is_any_ability_casting():
		return
	var direction := target_global_position - global_position
	_set_facing_direction(input_source.resolve_cardinal_facing(direction, facing_direction))
	var weapon_damage := attack_component.weapon.damage if attack_component.weapon != null else 0.0
	_configure_ability_critical_profile(component)
	component.request_cast_at(target_global_position, weapon_damage)


func _configure_ability_critical_profile(component: AbilityComponent) -> void:
	if component == null:
		return
	var weapon := attack_component.weapon
	component.set_critical_profile(
		weapon.critical_chance_ratio if weapon != null else 0.0,
		weapon.critical_damage_multiplier if weapon != null else 1.5
	)


func _is_targeting_any_ability() -> bool:
	return directional_wedge_targeting.is_targeting() or ground_point_targeting.is_targeting()


func _cancel_all_targeting() -> void:
	directional_wedge_targeting.cancel_targeting()
	ground_point_targeting.cancel_targeting()


func _restore_ability_presentation_facing() -> void:
	## Ability pivots deliberately ignore movement-facing changes while casting.
	## Refresh them once the lock is released so idle presentation is current.
	facing_changed.emit(facing_direction)


func _on_ability_finished() -> void:
	if _debug_unlimited_skills:
		_clear_all_ability_cooldowns()
	_restore_ability_presentation_facing()
	_try_execute_buffered_action()


func _enable_debug_test_loadout() -> void:
	## F9 previews every fully authored test skill without writing Eira's normal
	## session awakening flag.
	if debug_test_skill_loadout == null or skill_loadout == debug_test_skill_loadout:
		return
	skill_loadout = debug_test_skill_loadout
	var library := get_node_or_null("KingSkillLibrary") as KingSkillLibrary
	if library != null:
		# Bind the complete debug kit to live ranked definitions, never saved slots.
		library.refresh()
	else:
		skill_loadout_changed.emit()


func _enable_debug_unlimited_skills() -> void:
	_debug_unlimited_skills = true
	_clear_all_ability_cooldowns()


func _clear_all_ability_cooldowns() -> void:
	for component in get_all_ability_components():
		if component != null:
			component.clear_cooldown()


func _unlock_debug_test_equipment() -> void:
	## Debug F9 grants every authored Stage V item and its preview gates without saving.
	if weapon_catalog == null or not weapon_catalog.has_valid_layout():
		return
	var inventory := get_node_or_null("/root/WeaponInventory")
	if inventory == null:
		return
	for item: EquipmentDefinition in weapon_catalog.weapons:
		if item != null and item.is_compatible_with(character_class_id):
			inventory.acquire_weapon(item)
	var gear_inventory := get_node_or_null("/root/GearInventory")
	if gear_inventory != null:
		gear_inventory.apply_debug_testing_preset()
	var recipe_discovery := get_node_or_null("/root/RecipeDiscovery")
	if recipe_discovery != null:
		for recipe_id: StringName in [
			&"forest_stage_5_varkuun_edge",
			&"forest_stage_5_old_bark_helm",
			&"forest_stage_5_heartwood_plate",
			&"forest_stage_5_rootfiber_gloves",
			&"forest_stage_5_mirebound_leggings",
			&"forest_stage_5_mirehide_boots",
		]:
			recipe_discovery.discover_recipe(recipe_id)
	var story_state := get_node_or_null("/root/StoryState")
	if story_state != null:
		story_state.grant_key_item(&"forest_core_gear_seal")


func _unlock_debug_test_materials() -> void:
	## Normal enemies and chests still grant no materials. This only exposes
	## the existing catalog/inventory UI for fast local inspection.
	var material_inventory := get_node_or_null("/root/MaterialInventory")
	if material_inventory != null:
		material_inventory.apply_debug_testing_preset()


func _unlock_debug_test_expeditions() -> void:
	var story_state := get_node_or_null("/root/StoryState")
	if story_state != null:
		story_state.apply_debug_expedition_unlocks()


func _enable_debug_admin_tools() -> void:
	## F9 is the one-stop non-saving review preset. Keep new debug-only review
	## destinations discoverable here instead of requiring a separate F10 setup.
	var admin_state := get_node_or_null("/root/DebugAdminState")
	if admin_state != null:
		admin_state.call("set_enabled", true)


func _on_died() -> void:
	if is_defeated:
		return
	is_defeated = true
	held_attack.cancel()
	if is_restrained():
		release_root_restraint(_restraint_source, false)
	_clear_buffered_action()
	_cancel_all_targeting()
	velocity = Vector2.ZERO
	knockback_component.clear()
	stagger_component.clear()
	attack_component.cancel_attack()
	evade_component.cancel_evade()
	for component in get_all_ability_components():
		component.cancel_cast()
	set_physics_process(false)
	defeated.emit()
