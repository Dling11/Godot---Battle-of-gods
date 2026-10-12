extends MeleeHitbox

## One accepted hit per target; only a deliberately aimed core carries stun.
var stun_core_radius := 0.0
var outer_damage_ratio := 1.0
var damage_core_radius := 0.0


func _try_hit(area: Area2D) -> void:
	if not area is HurtboxComponent or not _enabled or _hit_targets.has(area):
		return
	var ground := area.global_position
	if area.owner is CharacterBody2D:
		ground = (area.owner as Node2D).global_position
	var distance := ground.distance_to(_radial_origin)
	var outside_core := stun_core_radius > 0.0 and distance > stun_core_radius
	var outside_damage_core := damage_core_radius > 0.0 and distance > damage_core_radius
	var saved_stun := _stun_seconds
	var saved_damage := _damage
	if outside_core:
		_stun_seconds = 0.0
	if outside_core or outside_damage_core:
		_damage *= outer_damage_ratio
	super._try_hit(area)
	_stun_seconds = saved_stun
	_damage = saved_damage
