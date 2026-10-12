class_name UnbrokenVowComponent
extends AbilityComponent

signal buff_started
signal buff_ended(broken: bool)
signal duration_changed(seconds: float)

var actor: Player
var active := false
var remaining := 0.0
var _duration: Timer
var _hud_tick: Timer

func _ready() -> void:
	super._ready()
	actor = get_parent() as Player
	_duration = Timer.new()
	_duration.one_shot = true
	_duration.timeout.connect(clear_buff)
	add_child(_duration)
	_hud_tick = Timer.new()
	_hud_tick.wait_time = .1
	_hud_tick.timeout.connect(func() -> void: remaining = _duration.time_left; duration_changed.emit(remaining))
	add_child(_hud_tick)
	actor.ready.connect(_bind)

func _bind() -> void:
	actor.health_component.shield_changed.connect(_on_shield_changed)
	actor.defeated.connect(clear_buff)
	actor.skill_loadout_changed.connect(_on_loadout_changed)
	var body := actor.get_node("VisualRoot/Body")
	phase_changed.connect(body.play_ability_phase)
	ability_finished.connect(body.resume_locomotion)

func apply_rank(value: int) -> void:
	clear_buff()
	var next := definition.duplicate(true) as UnbrokenVowDefinition
	next.configure_rank(value)
	definition = next
	clear_cooldown()

func request_cast(direction: Vector2, _weapon_damage := 0.0) -> bool:
	if not is_ready() or definition == null:
		return false
	_cast_direction = direction.normalized() if not direction.is_zero_approx() else actor.facing_direction
	ability_started.emit()
	_enter_phase(Phase.WIND_UP, definition.wind_up_seconds)
	set_physics_process(true)
	return true

func _advance_phase() -> void:
	match phase:
		Phase.WIND_UP:
			_enter_phase(Phase.ACTIVE, definition.active_seconds)
			_activate()
			_start_cooldown()
			strike_started.emit(0, 1, definition.active_seconds)
		Phase.ACTIVE:
			_enter_phase(Phase.RECOVERY, definition.recovery_seconds)
		Phase.RECOVERY:
			phase = Phase.IDLE
			ability_finished.emit()

func _activate() -> void:
	clear_buff()
	var tuning := definition as UnbrokenVowDefinition
	active = true
	remaining = tuning.duration_seconds
	actor.health_component.set_temporary_shield(actor.health_component.maximum_health * tuning.shield_ratio)
	actor.movement_component.set_temporary_speed_bonus(tuning.movement_bonus)
	_duration.start(tuning.duration_seconds)
	_hud_tick.start()
	_push_nearby()
	buff_started.emit()
	duration_changed.emit(remaining)

func get_damage_bonus() -> float:
	return (definition as UnbrokenVowDefinition).damage_bonus if active else 0.0

func has_mature_finisher() -> bool:
	return active and (definition as UnbrokenVowDefinition).rank == UnbrokenVowDefinition.Rank.MATURE

func clear_buff(broken := false) -> void:
	var was_active := active
	active = false
	remaining = 0.0
	if is_instance_valid(_duration):
		_duration.stop()
		_hud_tick.stop()
	if is_instance_valid(actor) and actor.is_node_ready():
		actor.health_component.set_temporary_shield(0.0)
		actor.movement_component.set_temporary_speed_bonus(0.0)
	if was_active:
		buff_ended.emit(broken)
		duration_changed.emit(0.0)

func _on_shield_changed(current: float, _maximum: float) -> void:
	if active and current <= 0.0:
		clear_buff(true)

func _on_loadout_changed() -> void:
	if not active:
		return
	var library := actor.get_node("KingSkillLibrary") as KingSkillLibrary
	if "unbroken_vow" not in library.current_ids():
		clear_buff()

func _push_nearby() -> void:
	var circle := CircleShape2D.new()
	circle.radius = 42.0
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = circle
	query.transform = Transform2D(0.0, actor.global_position)
	query.collision_mask = 16
	query.collide_with_areas = true
	query.collide_with_bodies = false
	var space := actor.get_world_2d().direct_space_state
	var seen := {}
	for result in space.intersect_shape(query, 64):
		var hurtbox := result.collider as HurtboxComponent
		if hurtbox == null or not hurtbox.owner is CharacterBody2D or seen.has(hurtbox.owner):
			continue
		seen[hurtbox.owner] = true
		var target := hurtbox.owner as CharacterBody2D
		var knockback := target.get_node_or_null("KnockbackComponent") as KnockbackComponent
		if knockback == null or not knockback.accepts_light_pressure() or target.global_position.distance_to(actor.global_position) > 42.0:
			continue
		var ray := PhysicsRayQueryParameters2D.create(actor.global_position, target.global_position, 1, [actor.get_rid()])
		if space.intersect_ray(ray).is_empty():
			knockback.apply_pressure(actor.global_position.direction_to(target.global_position), 80.0)

func _exit_tree() -> void:
	clear_buff()
