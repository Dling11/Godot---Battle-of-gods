class_name WarCycloneComponent
extends AbilityComponent

## Combat authority for the first Axe technique. No mastery XP/save authority.
signal availability_changed
signal guarded_hit(info: DamageInfo)
signal channel_reaffirmed
const GUARD_KEY := &"axe_war_cyclone"
var actor: Player
var enabled_for_review := false
var borrowed_for_lesson := false
var turn_period := 0.48
var active_elapsed := 0.0
var _next_turn := 0.0
var _pulse_count := 10
var _query := PhysicsShapeQueryParameters2D.new()

func _ready() -> void:
	super._ready()
	_query.shape = definition.hitbox_shape
	_query.collision_mask = hitbox.collision_mask
	_query.collide_with_areas = true
	_query.collide_with_bodies = false
	actor = get_parent() as Player
	actor.ready.connect(_bind)

func _bind() -> void:
	get_node("/root/WeaponTraining").training_changed.connect(func() -> void: availability_changed.emit())
	actor.testing_preset_applied.connect(func(_level: int, _coins: int) -> void: enable_review())
	actor.weapon_definition_changed.connect(func(_weapon: WeaponDefinition) -> void: availability_changed.emit())
	actor.interaction_started.connect(_cancel_for_interaction)
	ability_finished.connect(_clear_guard)

func has_guard() -> bool:
	return phase == Phase.ACTIVE

func _enter_phase(next_phase: Phase, duration_seconds: float) -> void:
	if is_instance_valid(actor) and is_instance_valid(actor.health_component):
		if next_phase == Phase.ACTIVE:
			actor.health_component.set_incoming_damage_modifier(GUARD_KEY,_guard_damage)
		else: _clear_guard()
	super._enter_phase(next_phase,duration_seconds)

func _guard_damage(info: DamageInfo) -> void:
	if not has_guard(): return
	var tuning := definition as WarCycloneDefinition
	info.amount *= 1.0-clampf(tuning.damage_reduction_ratio,0.0,.90)
	if tuning.ignores_incoming_hit_control:
		info.stun_seconds = 0.0
		info.stagger_seconds = 0.0
	guarded_hit.emit(info)

func _clear_guard() -> void:
	if is_instance_valid(actor) and is_instance_valid(actor.health_component):
		actor.health_component.remove_incoming_damage_modifier(GUARD_KEY)

func _exit_tree() -> void:
	_clear_guard()

func _cancel_for_interaction() -> void:
	if not is_casting(): return
	actor._clear_buffered_action()
	cancel_cast()

func enable_review() -> void:
	if not OS.is_debug_build() or enabled_for_review: return
	enabled_for_review = true
	availability_changed.emit()

func is_available() -> bool:
	var tuning := definition as WarCycloneDefinition
	return (enabled_for_review or borrowed_for_lesson or get_node("/root/WeaponTraining").has_technique(&"axe_war_cyclone")) and tuning != null and is_instance_valid(actor) and tuning.supports(actor.attack_component.weapon)

func set_lesson_loan(value: bool) -> void:
	borrowed_for_lesson = value
	availability_changed.emit()

func can_queue_cast() -> bool:
	return is_available() and super.can_queue_cast()

func is_ready() -> bool:
	return is_available() and super.is_ready()

func request_cast(direction: Vector2, equipped_weapon_damage := 0.0) -> bool:
	if not is_ready() or actor.is_defeated or actor.is_restrained() or actor.is_in_hit_recovery() or actor.is_cinematic_locked() or actor.is_targeting_any_ability() or actor.is_any_ability_casting() or actor.attack_component.phase != MeleeAttackComponent.Phase.IDLE or not actor.evade_component.is_ready():
		return false
	var tuning := definition as WarCycloneDefinition
	var turns := tuning.pulse_count_for(actor.attack_component.get_attack_speed_multiplier())
	_pulse_count = turns
	turn_period = definition.active_seconds / turns
	active_elapsed = 0.0
	_next_turn = turn_period
	return super.request_cast(direction, equipped_weapon_damage)

func owns_contact_feedback() -> bool:
	# One shared contact sound per turn; no global hitstop per horde member.
	return true

func owns_body_presentation() -> bool:
	return is_casting()

func owns_incoming_feedback() -> bool:
	return has_guard()

func get_manual_movement_ratio() -> float:
	return (definition as WarCycloneDefinition).movement_ratio if phase == Phase.ACTIVE else 0.0

func reaffirm_channel() -> bool:
	# Repeating F1 acknowledges use without cancelling/restarting damage or time.
	if not is_casting(): return false
	channel_reaffirmed.emit()
	return true

func _advance_active_strikes(delta: float) -> void:
	active_elapsed += minf(delta, maxf(_phase_time_remaining, 0.0))
	while active_elapsed >= _next_turn and _next_turn < definition.active_seconds - 0.0001:
		_current_strike_index += 1
		_next_turn += turn_period
		_start_current_strike()

func _start_current_strike() -> void:
	_strike_time_remaining = turn_period
	strike_started.emit(_current_strike_index, _pulse_count, turn_period)
	hitbox.activate_radial(
		definition.resolve_damage(_equipped_weapon_damage) / float(_pulse_count), actor, actor.global_position,
		definition.knockback_strength, 0.0, _critical_chance_ratio,
		_critical_damage_multiplier, 0.0, definition.damage_type
	)
	# Explicit shape query per revolution, with the usual per-hitbox ledger.
	# No persistent overlap delivery or per-target scan between revolutions.
	hitbox.set_physics_process(false)
	hitbox.set_deferred("monitoring", false)
	# The component is a plain Node; its child Area is only a damage ledger.
	# Resolve world contact from the actor, never from an unparented canvas.
	_query.transform = actor.global_transform
	for result in actor.get_world_2d().direct_space_state.intersect_shape(_query, 256):
		hitbox._try_hit(result.collider)
	hitbox.deactivate()
