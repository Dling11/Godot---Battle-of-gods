class_name EncounterSpawnEntryDefinition
extends Resource

## One reusable enemy scene/count pair inside a data-authored encounter wave.

@export var enemy_scene: PackedScene
@export_range(1, 40, 1) var count := 1


func is_valid() -> bool:
	return enemy_scene != null and count > 0
