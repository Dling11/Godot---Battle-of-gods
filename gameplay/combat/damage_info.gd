class_name DamageInfo
extends RefCounted

enum DamageType { PHYSICAL, MAGIC, PURE }

var amount: float
var raw_amount: float
var source: Node
var direction: Vector2
var knockback_strength: float
var stagger_seconds: float
## Explicit hard control. Ordinary flinch duration and raw damage never imply stun.
var stun_seconds: float
var is_critical: bool
var damage_type := DamageType.PHYSICAL
## Authored arena verdicts can pierce action i-frames; armor still applies.
var ignores_invulnerability := false


func _init(
	new_amount: float,
	new_source: Node,
	new_direction: Vector2,
	new_knockback_strength := 0.0,
	new_stagger_seconds := 0.0,
	new_is_critical := false,
	new_stun_seconds := 0.0,
	new_damage_type := DamageType.PHYSICAL
) -> void:
	amount = new_amount
	raw_amount = new_amount
	source = new_source
	direction = new_direction.normalized()
	knockback_strength = maxf(new_knockback_strength, 0.0)
	stagger_seconds = maxf(new_stagger_seconds, 0.0)
	stun_seconds = maxf(new_stun_seconds, 0.0)
	is_critical = new_is_critical
	damage_type = normalize_type(new_damage_type)


static func normalize_type(value: int) -> DamageType:
	match value:
		DamageType.MAGIC: return DamageType.MAGIC
		DamageType.PURE: return DamageType.PURE
	return DamageType.PHYSICAL


static func type_name(value: int) -> String:
	match normalize_type(value):
		DamageType.MAGIC: return "MAGIC"
		DamageType.PURE: return "PURE"
	return "PHYSICAL"
