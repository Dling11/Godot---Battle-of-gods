class_name PlayerVitalityDefinition
extends Resource

## Immutable character vitality growth. Armor and other equipment bonuses are
## aggregated separately so level growth never depends on presentation or UI.

@export_range(1.0, 99999.0, 1.0) var base_maximum_health: float = 100.0
@export_range(0.0, 9999.0, 1.0) var health_per_level: float = 8.0
@export_range(0.0, 1000.0, 0.1, "suffix:HP/s") var base_health_regeneration_per_second := 1.0
@export_range(0.0, 60.0, 0.1, "suffix:s") var regeneration_delay_seconds := 5.0
@export_range(0.05, 5.0, 0.05, "suffix:s") var regeneration_tick_seconds := 1.0


func get_maximum_health(level: int, flat_equipment_bonus := 0.0) -> float:
	return maxf(
		base_maximum_health
		+ float(maxi(level - 1, 0)) * health_per_level
		+ flat_equipment_bonus,
		1.0
	)
