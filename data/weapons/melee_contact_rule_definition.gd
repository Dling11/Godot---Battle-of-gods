class_name MeleeContactRuleDefinition
extends Resource

## Optional per-cut rules. Evaluate target HP before defenses and before this hit.
## Displacement is consumed by the target's collision-aware knockback component.
@export_range(0.0, 64.0, 1.0) var light_pull_distance := 0.0
@export_range(0.0, 64.0, 1.0) var pull_standoff_distance := 28.0
@export_range(0.0, 1.0, 0.01) var wounded_health_ratio := 0.0
@export_range(1.0, 3.0, 0.05) var wounded_damage_multiplier := 1.0


func apply_to_hit(info: DamageInfo, target: HurtboxComponent) -> void:
	var health := target.health_component
	if health != null and health.current_health > 0.0 and health.current_health < health.maximum_health * wounded_health_ratio:
		info.amount *= wounded_damage_multiplier
	info.light_pull_distance = light_pull_distance
	info.pull_standoff_distance = pull_standoff_distance
