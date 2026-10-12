class_name HurtboxComponent
extends Area2D

@export var health_component: HealthComponent
## Combat objects such as destructible hostile projectiles still receive
## player damage through a normal hurtbox, but should not become assisted
## movement targets or occupy the enemy roster.
@export var selectable_as_combat_target := true


func receive_hit(info: DamageInfo) -> bool:
	if health_component == null:
		push_error("HurtboxComponent requires a HealthComponent.")
		return false
	return health_component.apply_damage(info)
