class_name HealthComponent
extends Node

signal health_changed(current: float, maximum: float)
signal damaged(info: DamageInfo)
signal damage_blocked(info: DamageInfo)
signal damage_absorbed(info: DamageInfo)
signal died
signal shield_changed(current: float, maximum: float)
signal shield_hit(absorbed: float)

var shield_health := 0.0
var shield_maximum := 0.0

@export_range(1.0, 999999.0, 1.0) var maximum_health: float = 100.0
## Positive armor uses diminishing returns: 100 armor halves accepted damage.
## Keeping mitigation here makes the same rule available to enemies, players,
## and future equipment without coupling damage sources to armor ownership.
@export_range(0.0, 9999.0, 1.0) var armor_rating: float = 0.0
@export_range(0.0, 9999.0, 1.0) var magic_resistance_rating: float = 0.0
## Universal ward follows physical/magic resistance. Pure damage bypasses it.
@export_range(0.0, 0.75, 0.01) var ward_reduction_ratio: float = 0.0

var current_health: float
var is_invulnerable := false
## Debug/cinematic immunity is separate from temporary combat i-frames.
var is_damage_immune := false
## Optional guard authority consumes a mitigated hit before it reaches HP.
## Return true only when the entire hit was absorbed (including a breaking hit).
var damage_absorber: Callable


func _ready() -> void:
	current_health = maximum_health


func set_maximum_health(next_maximum: float, preserve_missing_health := true) -> void:
	var previous_maximum := maximum_health
	var missing_health := maxf(previous_maximum - current_health, 0.0)
	maximum_health = maxf(next_maximum, 1.0)
	if preserve_missing_health:
		current_health = clampf(maximum_health - missing_health, 0.0, maximum_health)
	else:
		current_health = minf(current_health, maximum_health)
	health_changed.emit(current_health, maximum_health)


func set_current_health(next_current: float) -> void:
	current_health = clampf(next_current, 0.0, maximum_health)
	health_changed.emit(current_health, maximum_health)


func heal(amount: float) -> float:
	if current_health <= 0.0 or amount <= 0.0 or current_health >= maximum_health:
		return 0.0
	var previous_health := current_health
	current_health = minf(current_health + amount, maximum_health)
	health_changed.emit(current_health, maximum_health)
	return current_health - previous_health


func apply_damage(info: DamageInfo) -> bool:
	if current_health <= 0.0 or info.amount <= 0.0:
		return false
	if is_damage_immune or (is_invulnerable and not info.ignores_invulnerability):
		damage_blocked.emit(info)
		return false

	info.raw_amount = info.amount
	info.amount = resolve_damage(info.amount, info.damage_type)
	if damage_absorber.is_valid() and damage_absorber.call(info):
		damage_absorbed.emit(info)
		return true
	if shield_health > 0.0:
		var absorbed := minf(info.amount, shield_health)
		shield_health -= absorbed
		info.amount -= absorbed
		shield_hit.emit(absorbed)
		shield_changed.emit(shield_health, shield_maximum)
		if info.amount <= 0.0:
			damage_absorbed.emit(info)
			return true
	current_health = maxf(current_health - info.amount, 0.0)
	damaged.emit(info)
	health_changed.emit(current_health, maximum_health)
	if current_health <= 0.0:
		died.emit()
	return true


func set_invulnerable(value: bool) -> void:
	is_invulnerable = value


func set_temporary_shield(amount: float) -> void:
	shield_maximum = maxf(amount, 0.0)
	shield_health = shield_maximum
	shield_changed.emit(shield_health, shield_maximum)


func resolve_damage(raw_damage: float, damage_type := DamageInfo.DamageType.PHYSICAL) -> float:
	if raw_damage <= 0.0:
		return 0.0
	var kind := DamageInfo.normalize_type(damage_type)
	if kind == DamageInfo.DamageType.PURE:
		return raw_damage
	var resistance := magic_resistance_rating if kind == DamageInfo.DamageType.MAGIC else armor_rating
	var after_resistance := raw_damage * 100.0 / (100.0 + maxf(resistance, 0.0))
	return after_resistance * (1.0 - clampf(ward_reduction_ratio, 0.0, 0.75))


func get_armor_reduction_ratio() -> float:
	return 1.0 - 100.0 / (100.0 + maxf(armor_rating, 0.0))


func set_equipment_defenses(armor: float, ward_ratio: float, magic_resistance := 0.0) -> void:
	armor_rating = maxf(armor, 0.0)
	magic_resistance_rating = maxf(magic_resistance, 0.0)
	ward_reduction_ratio = clampf(ward_ratio, 0.0, 0.75)
