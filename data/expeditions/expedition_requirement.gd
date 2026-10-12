class_name ExpeditionRequirement
extends Resource

## Immutable access rules evaluated against player level and StoryState.

@export_range(1, 99, 1) var minimum_level := 1
@export var required_story_flags := PackedStringArray()
@export var required_boss_victories := PackedStringArray()
@export var required_discoveries := PackedStringArray()
@export var required_key_items := PackedStringArray()


func is_satisfied(story_state: Node, player_level: int) -> bool:
	return get_unmet_requirements(story_state, player_level).is_empty()


func get_unmet_requirements(story_state: Node, player_level: int) -> Array[String]:
	var unmet: Array[String] = []
	if player_level < minimum_level:
		unmet.append("REACH LEVEL %d" % minimum_level)
	_append_missing(unmet, story_state, required_story_flags, "has_story_flag", "STORY")
	_append_missing(unmet, story_state, required_boss_victories, "has_boss_victory", "BOSS")
	_append_missing(unmet, story_state, required_discoveries, "has_discovery", "DISCOVER")
	_append_missing(unmet, story_state, required_key_items, "has_key_item", "KEY ITEM")
	return unmet


func _append_missing(
	unmet: Array[String],
	story_state: Node,
	identifiers: PackedStringArray,
	query_method: StringName,
	label: String
) -> void:
	for identifier: String in identifiers:
		if (
			story_state == null
			or not story_state.has_method(query_method)
			or not story_state.call(query_method, StringName(identifier))
		):
			unmet.append("%s: %s" % [label, _display_identifier(identifier)])


func _display_identifier(identifier: String) -> String:
	return identifier.replace("_", " ").capitalize()
