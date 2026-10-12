class_name DropProfileDefinition
extends Resource

## Immutable ecology-linked drops for one enemy archetype.

@export var profile_id: StringName
@export var source_enemy_id: StringName
@export var region_id: StringName
@export var is_boss_profile := false
@export var common_drops: Array[MaterialDropEntryDefinition] = []
@export var optional_secondary: Array[MaterialDropEntryDefinition] = []
@export var rare_drops: Array[MaterialDropEntryDefinition] = []
@export var boss_guarantees: Array[MaterialDropEntryDefinition] = []


func has_valid_layout() -> bool:
	if profile_id.is_empty() or source_enemy_id.is_empty() or region_id.is_empty():
		return false
	if is_boss_profile != (not boss_guarantees.is_empty()):
		return false
	var seen_material_ids := {}
	if not _validate_entries(common_drops, false, seen_material_ids):
		return false
	if not _validate_entries(optional_secondary, false, seen_material_ids):
		return false
	if not _validate_entries(rare_drops, false, seen_material_ids):
		return false
	if not _validate_entries(boss_guarantees, true, seen_material_ids):
		return false
	return not (
		common_drops.is_empty()
		and optional_secondary.is_empty()
		and rare_drops.is_empty()
		and boss_guarantees.is_empty()
	)


func _validate_entries(
	entries: Array[MaterialDropEntryDefinition],
	require_guaranteed: bool,
	seen_material_ids: Dictionary
) -> bool:
	for entry: MaterialDropEntryDefinition in entries:
		if (
			entry == null
			or not entry.is_valid()
			or entry.is_guaranteed() != require_guaranteed
			or seen_material_ids.has(entry.material.material_id)
		):
			return false
		seen_material_ids[entry.material.material_id] = true
	return true
