class_name KingMasteryDefinition
extends Resource

@export var resolve_hits := 3
@export var resolve_multiplier := 1.25
@export var resolve_retention_seconds := 8.0
@export var skill_bonus_per_level := 0.02
@export var maximum_skill_level_bonus := 0.18
@export var pursuit_rift_window_seconds := 1.2
@export var pursuit_rift_multiplier := 1.15

func level_multiplier(level: int) -> float:
	return 1.0 + minf(maxf(level - 1,0) * skill_bonus_per_level, maximum_skill_level_bonus)
