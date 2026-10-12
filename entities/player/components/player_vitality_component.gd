class_name PlayerVitalityComponent
extends Node

## Player-only vitality aggregation. Level growth is active now; future armor
## may inject one flat bonus without moving health authority out of HealthComponent.

signal vitality_changed(maximum_health: float, level_bonus: float, equipment_bonus: float)

@export var definition: PlayerVitalityDefinition
@export var progression_component: PlayerProgressionComponent
@export var health_component: HealthComponent

var equipment_health_bonus := 0.0


func _ready() -> void:
	if definition == null or progression_component == null or health_component == null:
		push_error("PlayerVitalityComponent requires vitality, progression, and health references.")
		return
	progression_component.progression_changed.connect(_on_progression_changed)
	_apply_vitality()


func get_level_health_bonus() -> float:
	return definition.health_per_level if definition != null else 0.0


func get_maximum_health() -> float:
	if definition == null or progression_component == null:
		return 1.0
	return definition.get_maximum_health(
		progression_component.level,
		equipment_health_bonus
	)


func set_equipment_health_bonus(flat_bonus: float) -> void:
	equipment_health_bonus = maxf(flat_bonus, 0.0)
	_apply_vitality()


func _on_progression_changed(
	_new_level: int,
	_total_experience: int,
	_next_level_experience: int
) -> void:
	_apply_vitality()


func _apply_vitality() -> void:
	if definition == null or progression_component == null or health_component == null:
		return
	var level_bonus := (
		float(maxi(progression_component.level - 1, 0))
		* definition.health_per_level
	)
	health_component.set_maximum_health(get_maximum_health(), true)
	vitality_changed.emit(
		health_component.maximum_health,
		level_bonus,
		equipment_health_bonus
	)
