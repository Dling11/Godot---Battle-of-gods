class_name CragBearDefinition
extends EnemyDefinition

## Immutable tuning for the Stage VI armored bear's single ground-slam skill.

@export_range(0.0, 500.0, 5.0, "suffix:px/s") var basic_knockback_strength := 70.0
@export_range(0.0, 1.0, 0.01, "suffix:s") var basic_stagger_seconds := 0.08

@export_range(24.0, 128.0, 1.0, "suffix:px") var ground_slam_range := 72.0
@export_range(1.0, 9999.0, 1.0) var ground_slam_damage := 34.0
@export_range(0.1, 2.0, 0.05, "suffix:s") var ground_slam_wind_up_seconds := 0.8
@export_range(0.05, 1.0, 0.05, "suffix:s") var ground_slam_active_seconds := 0.15
@export_range(0.1, 3.0, 0.05, "suffix:s") var ground_slam_recovery_seconds := 1.0
@export_range(1.0, 20.0, 0.25, "suffix:s") var ground_slam_cooldown_seconds := 5.5
@export_range(0.0, 10.0, 0.25, "suffix:s") var initial_ground_slam_delay := 2.5
@export_range(0.0, 500.0, 5.0) var ground_slam_knockback_strength := 180.0
@export_range(0.0, 1.0, 0.01, "suffix:s") var ground_slam_stagger_seconds := 0.14
