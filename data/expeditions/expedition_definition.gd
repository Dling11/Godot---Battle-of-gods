class_name ExpeditionDefinition
extends Resource

## Immutable Sanctuary route metadata and access requirements.

@export var expedition_id: StringName
@export var route_label := "I"
@export var display_name := "UNNAMED EXPEDITION"
@export var difficulty_label := "UNKNOWN"
@export_multiline var description := ""
@export_file("*.tscn") var destination_scene := ""
@export var requirement: ExpeditionRequirement


func is_available(story_state: Node, player_level: int) -> bool:
	return not destination_scene.is_empty() and ResourceLoader.exists(destination_scene) and (
		requirement == null or requirement.is_satisfied(story_state, player_level)
	)


func get_unmet_requirements(story_state: Node, player_level: int) -> Array[String]:
	if requirement == null:
		return []
	return requirement.get_unmet_requirements(story_state, player_level)


func is_valid_definition() -> bool:
	return not expedition_id.is_empty() and not display_name.is_empty() and not route_label.is_empty()
