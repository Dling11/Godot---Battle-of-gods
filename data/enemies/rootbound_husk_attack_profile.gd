class_name RootboundHuskAttackProfile
extends Resource

@export_group("Root Spear")
@export_range(0.1, 2.0, 0.01) var spear_wind_up_seconds := 0.68
@export_range(0.05, 0.5, 0.01) var spear_active_seconds := 0.14
@export_range(0.1, 2.0, 0.01) var spear_recovery_seconds := 0.72

@export_group("Root Fan")
@export_range(0.1, 2.0, 0.01) var triad_wind_up_seconds := 1.0
@export_range(0.02, 0.5, 0.01) var triad_side_delay_seconds := 0.11
@export_range(0.05, 0.5, 0.01) var triad_side_active_seconds := 0.14
@export_range(0.1, 2.0, 0.01) var triad_recovery_seconds := 0.88
@export_range(0.1, 1.2, 0.01) var triad_half_angle_radians := 0.34

@export_group("Point-Blank Root Burst")
@export_range(8.0, 80.0, 1.0, "suffix:px") var burst_trigger_range := 34.0
@export_range(0.1, 2.0, 0.01) var burst_wind_up_seconds := 0.48
@export_range(0.05, 0.5, 0.01) var burst_active_seconds := 0.16
@export_range(0.1, 2.0, 0.01) var burst_recovery_seconds := 0.64
@export_range(0.1, 2.0, 0.05) var burst_damage_multiplier := 0.85

@export_group("Second Phase")
@export_range(0.1, 0.9, 0.01) var phase_two_health_ratio := 0.5
@export_range(0.5, 1.0, 0.01) var phase_two_timing_scale := 0.88
@export_range(0.1, 1.2, 0.01) var phase_two_triad_half_angle_radians := 0.42
