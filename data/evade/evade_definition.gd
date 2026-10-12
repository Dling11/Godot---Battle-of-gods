class_name EvadeDefinition
extends Resource

## Shared tuning for an evade presentation/runtime pair.

@export_range(1.0, 2000.0, 1.0, "suffix:px/s") var speed: float = 320.0
@export_range(0.01, 2.0, 0.01, "suffix:s") var dash_seconds: float = 0.15
@export_range(0.0, 3.0, 0.01, "suffix:s") var recovery_seconds: float = 0.25
@export_range(0.0, 5.0, 0.05, "suffix:s") var cooldown_seconds: float = 0.85


func get_distance() -> float:
	return speed * dash_seconds
