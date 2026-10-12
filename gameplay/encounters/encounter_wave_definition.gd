class_name EncounterWaveDefinition
extends Resource

@export var title := "Wave"
@export var spawn_entries: Array[EncounterSpawnEntryDefinition] = []
## Legacy count fields remain readable for implemented Stage I-IV resources.
## New content should use spawn_entries so adding an enemy does not change this schema.
@export_range(0, 20, 1) var mireling_count := 0
@export_range(0, 20, 1) var rootling_count := 0
@export_range(0, 20, 1) var thrall_count := 0
@export_range(0, 20, 1) var bramble_spitter_count := 0
@export_range(0, 20, 1) var armored_hog_count := 0
@export_range(0, 4, 1) var rootbound_husk_count := 0
@export_range(0.1, 5.0, 0.1, "suffix:s") var spawn_interval := 0.8
@export_range(0.25, 5.0, 0.05, "suffix:s") var reinforcement_delay := 0.8


func total_enemy_count() -> int:
	var total := (
		mireling_count
		+ rootling_count
		+ thrall_count
		+ bramble_spitter_count
		+ armored_hog_count
		+ rootbound_husk_count
	)
	for entry: EncounterSpawnEntryDefinition in spawn_entries:
		if entry != null and entry.is_valid():
			total += entry.count
	return total


func append_spawn_scenes(target: Array[PackedScene]) -> void:
	for entry: EncounterSpawnEntryDefinition in spawn_entries:
		if entry == null or not entry.is_valid():
			continue
		for _count in entry.count:
			target.append(entry.enemy_scene)
