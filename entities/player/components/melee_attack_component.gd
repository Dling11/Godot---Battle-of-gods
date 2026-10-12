class_name MeleeAttackComponent
extends Node

enum Phase { IDLE, WIND_UP, ACTIVE, RECOVERY }

signal attack_started
signal phase_changed(phase: Phase, duration_seconds: float)
signal attack_finished
signal hit_landed(target: HurtboxComponent, info: DamageInfo)

@export var weapon: WeaponDefinition
@export var hitbox: MeleeHitbox
@export var collision_shape: CollisionShape2D

var phase := Phase.IDLE
var _phase_time_remaining: float
var _attack_direction := Vector2.RIGHT
var _random := RandomNumberGenerator.new()
var _attack_speed_bonus_ratio := 0.0
var combo_step := 0
var _next_combo_step := 0
var _combo_timer: Timer
var committed_damage_multiplier := 1.0
var committed_animation_key := ""
var committed_vow_finisher := false
var committed_damage_type := DamageInfo.DamageType.PHYSICAL
var committed_perfect_counter := false


func _ready() -> void:
	_random.randomize()
	_combo_timer = Timer.new()
	_combo_timer.one_shot = true
	_combo_timer.timeout.connect(reset_combo)
	add_child(_combo_timer)
	set_physics_process(false)
	if hitbox != null:
		hitbox.hit_landed.connect(_on_hit_landed)
	if weapon != null and weapon.melee_hitbox_shape != null and collision_shape != null:
		collision_shape.shape = weapon.melee_hitbox_shape


func set_weapon_definition(next_weapon: WeaponDefinition) -> bool:
	if (
		next_weapon == null
		or next_weapon.melee_hitbox_shape == null
		or collision_shape == null
	):
		return false
	weapon = next_weapon
	reset_combo()
	collision_shape.shape = next_weapon.melee_hitbox_shape
	return true


func request_attack(direction: Vector2) -> bool:
	if (
		phase != Phase.IDLE
		or weapon == null
		or weapon.melee_hitbox_shape == null
		or hitbox == null
		or collision_shape == null
	):
		return false
	_attack_direction = direction.normalized() if not direction.is_zero_approx() else Vector2.RIGHT
	combo_step = _next_combo_step
	collision_shape.shape = weapon.combo.hitbox_shape(combo_step,weapon.melee_hitbox_shape) if _has_combo() else weapon.melee_hitbox_shape
	_combo_timer.stop()
	committed_damage_multiplier = 1.0
	committed_animation_key = ""
	committed_vow_finisher = false
	committed_damage_type = weapon.damage_type
	committed_perfect_counter = false
	attack_started.emit()
	_enter_phase(Phase.WIND_UP, _scaled_duration(_step_duration(Phase.WIND_UP)))
	set_physics_process(true)
	return true


func get_attack_direction() -> Vector2:
	## The accepted direction remains immutable until this attack finishes.
	return _attack_direction


func cancel_attack() -> void:
	reset_combo()
	if hitbox != null:
		hitbox.deactivate()
	phase = Phase.IDLE
	_phase_time_remaining = 0.0
	set_physics_process(false)
	attack_finished.emit()


func _physics_process(delta: float) -> void:
	_phase_time_remaining -= delta
	while _phase_time_remaining <= 0.0 and phase != Phase.IDLE:
		var overflow := -_phase_time_remaining
		_advance_phase()
		_phase_time_remaining -= overflow


func _advance_phase() -> void:
	match phase:
		Phase.WIND_UP:
			_enter_phase(Phase.ACTIVE, _scaled_duration(_step_duration(Phase.ACTIVE)))
			var damage := weapon.roll_basic_damage(_random) * committed_damage_multiplier * (weapon.combo.damage_multipliers[combo_step] if _has_combo() else 1.0)
			var knockback := weapon.knockback_strength * (weapon.combo.knockback_multipliers[combo_step] if _has_combo() else 1.0)
			if _has_combo() and weapon.combo.is_radial(combo_step):
				hitbox.activate_radial(damage,owner,(owner as Node2D).global_position,knockback,weapon.basic_stagger_seconds,weapon.critical_chance_ratio,weapon.critical_damage_multiplier,0.0,committed_damage_type)
			else:
				hitbox.activate(
					damage, owner, _attack_direction, knockback,
					weapon.basic_stagger_seconds, weapon.critical_chance_ratio,
					weapon.critical_damage_multiplier, 0.0, committed_damage_type
				)
		Phase.ACTIVE:
			hitbox.deactivate()
			_enter_phase(Phase.RECOVERY, _scaled_duration(_step_duration(Phase.RECOVERY)))
		Phase.RECOVERY:
			phase = Phase.IDLE
			set_physics_process(false)
			if _has_combo():
				_next_combo_step = (combo_step + 1) % weapon.combo.step_count()
				_combo_timer.start(weapon.combo.continue_seconds)
			attack_finished.emit()


func _enter_phase(next_phase: Phase, duration_seconds: float) -> void:
	phase = next_phase
	_phase_time_remaining = maxf(duration_seconds, 0.0001)
	phase_changed.emit(phase, duration_seconds)


func _on_hit_landed(target: HurtboxComponent, info: DamageInfo) -> void:
	hit_landed.emit(target, info)


func configure_random_seed_for_testing(seed: int) -> void:
	_random.seed = seed


func set_equipment_attack_speed_bonus(bonus_ratio: float) -> void:
	_attack_speed_bonus_ratio = clampf(bonus_ratio, 0.0, 0.5)


func _scaled_duration(base_duration: float) -> float:
	return base_duration / (1.0 + _attack_speed_bonus_ratio)


func reset_combo() -> void:
	_next_combo_step = 0
	if _combo_timer != null:
		_combo_timer.stop()


func get_remaining_attack_seconds() -> float:
	if phase == Phase.IDLE:
		return 0.0
	var remaining := maxf(_phase_time_remaining, 0.0)
	for next_phase in range(phase + 1, Phase.RECOVERY + 1):
		remaining += _scaled_duration(_step_duration(next_phase))
	return remaining


func get_animation_key() -> String:
	if not committed_animation_key.is_empty():
		return committed_animation_key
	return weapon.combo.animation_keys[combo_step] if _has_combo() else "attack"


func _has_combo() -> bool:
	return weapon != null and weapon.combo != null and weapon.combo.step_count() > combo_step


func _step_duration(attack_phase: Phase) -> float:
	if _has_combo():
		match attack_phase:
			Phase.WIND_UP: return weapon.combo.windups[combo_step]
			Phase.ACTIVE: return weapon.combo.contacts[combo_step]
			Phase.RECOVERY: return weapon.combo.recoveries[combo_step]
	match attack_phase:
		Phase.WIND_UP: return weapon.wind_up_seconds
		Phase.ACTIVE: return weapon.active_seconds
	return weapon.recovery_seconds
