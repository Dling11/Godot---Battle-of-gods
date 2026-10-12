class_name RiftbreakDefinition
extends AbilityDefinition

## Immutable authority values for King's ground impact and optional target/core.

@export_range(24.0, 160.0, 1.0, "suffix:px") var effect_radius_pixels := 84.0
@export_range(-32.0, 32.0, 1.0, "suffix:px") var ground_center_offset_y := 16.0
## Zero preserves the campaign self-area cast. The Lab review opts into targeting.
@export var target_range_pixels := 0.0
@export var stun_core_radius_pixels := 0.0
@export var outer_damage_ratio := 1.0
