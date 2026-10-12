class_name MeleeHitbox
extends Area2D

signal hit_landed(target: HurtboxComponent, info: DamageInfo)

var _damage: float
var _direction := Vector2.RIGHT
var _source: Node
var _knockback_strength := 0.0
var _stagger_seconds := 0.0
var _stun_seconds := 0.0
var _is_critical := false
var _damage_type := DamageInfo.DamageType.PHYSICAL
var _hit_targets: Dictionary = {}
var _enabled := false
var _uses_radial_direction := false
var _radial_origin := Vector2.ZERO
var _random := RandomNumberGenerator.new()


func _ready() -> void:
	_random.randomize()
	area_entered.connect(_on_area_entered)
	_set_enabled(false)
	set_physics_process(false)


func _physics_process(_delta: float) -> void:
	if not monitoring:
		return
	for area in get_overlapping_areas():
		_try_hit(area)


func activate(
	damage: float,
	source: Node,
	direction: Vector2,
	knockback_strength := 0.0,
	stagger_seconds := 0.0,
	critical_chance_ratio := 0.0,
	critical_damage_multiplier := 1.5,
	stun_seconds := 0.0,
	damage_type := DamageInfo.DamageType.PHYSICAL
) -> void:
	_resolve_damage_roll(damage, critical_chance_ratio, critical_damage_multiplier)
	_source = source
	_direction = direction.normalized()
	_knockback_strength = maxf(knockback_strength, 0.0)
	_stagger_seconds = maxf(stagger_seconds, 0.0)
	_stun_seconds = maxf(stun_seconds, 0.0)
	_damage_type = DamageInfo.normalize_type(damage_type)
	_uses_radial_direction = false
	_hit_targets.clear()
	_set_enabled(true)
	set_physics_process(true)


func activate_radial(
	damage: float,
	source: Node,
	origin: Vector2,
	knockback_strength := 0.0,
	stagger_seconds := 0.0,
	critical_chance_ratio := 0.0,
	critical_damage_multiplier := 1.5,
	stun_seconds := 0.0,
	damage_type := DamageInfo.DamageType.PHYSICAL
) -> void:
	_resolve_damage_roll(damage, critical_chance_ratio, critical_damage_multiplier)
	_source = source
	_direction = Vector2.DOWN
	_knockback_strength = maxf(knockback_strength, 0.0)
	_stagger_seconds = maxf(stagger_seconds, 0.0)
	_stun_seconds = maxf(stun_seconds, 0.0)
	_damage_type = DamageInfo.normalize_type(damage_type)
	_uses_radial_direction = true
	_radial_origin = origin
	_hit_targets.clear()
	_set_enabled(true)
	set_physics_process(true)


func deactivate() -> void:
	_set_enabled(false)
	set_physics_process(false)


func _set_enabled(enabled: bool) -> void:
	_enabled = enabled
	set_deferred("monitoring", enabled)
	set_deferred("monitorable", false)


func _on_area_entered(area: Area2D) -> void:
	_try_hit(area)


func _try_hit(area: Area2D) -> void:
	if not _enabled:
		return
	if not area is HurtboxComponent:
		return
	var hurtbox := area as HurtboxComponent
	if _hit_targets.has(hurtbox):
		return
	_hit_targets[hurtbox] = true
	var hit_direction := _direction
	if _uses_radial_direction:
		hit_direction = (hurtbox.global_position - _radial_origin).normalized()
		if hit_direction.is_zero_approx():
			hit_direction = Vector2.DOWN
	var info := DamageInfo.new(
		_damage,
		_source,
		hit_direction,
		_knockback_strength,
		_stagger_seconds,
		_is_critical,
		_stun_seconds,
		_damage_type
	)
	if hurtbox.receive_hit(info):
		hit_landed.emit(hurtbox, info)


func configure_random_seed_for_testing(seed: int) -> void:
	_random.seed = seed


func _resolve_damage_roll(
	base_damage: float,
	critical_chance_ratio: float,
	critical_damage_multiplier: float
) -> void:
	var chance := clampf(critical_chance_ratio, 0.0, 0.5)
	_is_critical = chance > 0.0 and _random.randf() < chance
	_damage = base_damage * (maxf(critical_damage_multiplier, 1.0) if _is_critical else 1.0)
