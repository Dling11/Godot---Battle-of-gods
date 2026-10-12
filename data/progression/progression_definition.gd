class_name ProgressionDefinition
extends Resource

## Immutable session-progression curve for the introductory character.

@export_range(1, 99, 1) var maximum_level := 10
@export var total_experience_by_level := PackedInt32Array([0, 20, 50, 90, 140, 200, 270, 350, 440, 540])
@export var initial_level_cap := 0
@export var cap_unlock_flags: Array[StringName] = []
@export var unlocked_level_caps := PackedInt32Array()
@export var cap_unlock_names := PackedStringArray()

func next_cap_requirement(story: Node, minimum_cap := 0) -> Dictionary:
	var current := maxi(minimum_cap,unlocked_cap(story))
	for index in mini(cap_unlock_flags.size(),unlocked_level_caps.size()):
		if unlocked_level_caps[index] > current:
			return {"name":cap_unlock_names[index] if index < cap_unlock_names.size() else "the next expedition", "cap":unlocked_level_caps[index], "flag":cap_unlock_flags[index]}
	return {}

func unlocked_cap(story: Node) -> int:
	var cap := initial_level_cap if initial_level_cap > 0 else maximum_level
	if story != null:
		for index in mini(cap_unlock_flags.size(), unlocked_level_caps.size()):
			if story.has_story_flag(cap_unlock_flags[index]):
				cap = maxi(cap, unlocked_level_caps[index])
	return clampi(cap, 1, maximum_level)


func get_level_for_total_experience(total_experience: int) -> int:
	var resolved_level := 1
	while (
		resolved_level < maximum_level
		and resolved_level < total_experience_by_level.size()
		and total_experience >= total_experience_by_level[resolved_level]
	):
		resolved_level += 1
	return resolved_level
