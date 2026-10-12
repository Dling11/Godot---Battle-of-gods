class_name ArmoredHogDefinition
extends EnemyDefinition

## Immutable charge-specific tuning for the Stage 4 dodge-and-punish enemy.

@export_range(80.0, 480.0, 1.0, "suffix:px") var charge_trigger_range := 250.0
@export_range(80.0, 480.0, 1.0, "suffix:px") var charge_distance := 210.0
@export_range(80.0, 800.0, 1.0, "suffix:px/s") var charge_speed := 330.0
@export_range(0.0, 500.0, 5.0, "suffix:px/s") var charge_knockback_strength := 175.0
@export_range(0.0, 1.0, 0.01, "suffix:s") var charge_stagger_seconds := 0.24
@export_range(0.1, 2.0, 0.05, "suffix:s") var dazed_seconds := 1.15
@export_range(0.0, 1.0, 0.05) var braced_front_damage_multiplier := 0.35
@export_range(0.0, 90.0, 1.0, "suffix:deg") var front_guard_half_angle_degrees := 55.0
