class_name EchoingSeverDefinition
extends AbilityDefinition

## King-specific timing and targeting data for Echoing Sever. Combat authority
## reads this resource; previews and VFX only present the same authored values.

@export_range(0.01, 0.5, 0.01, "suffix:s") var strike_window_seconds := 0.08
@export_range(0.0, 1.0, 0.01, "suffix:s") var echo_delay_seconds := 0.30
@export_range(16.0, 256.0, 1.0, "suffix:px") var targeting_reach_pixels := 130.0
@export_range(10.0, 90.0, 1.0, "suffix:deg") var targeting_half_angle_degrees := 50.0
