class_name LootTableDefinition
extends Resource

## Immutable authored milestone-reward plan. It does not roll or grant rewards.

@export var loot_table_id: StringName
@export var stage_id: StringName
@export var region_id: StringName
@export var first_clear_claim_id: StringName
@export var first_clear_guarantees: Array[MaterialStackDefinition] = []
@export var replay_guarantees: Array[MaterialStackDefinition] = []
@export var optional_rewards: Array[MaterialDropEntryDefinition] = []
@export var first_clear_recipe_ids := PackedStringArray()
@export var first_clear_discovery_ids := PackedStringArray()
@export var first_clear_key_item_ids := PackedStringArray()


func has_valid_layout() -> bool:
	return (
		not loot_table_id.is_empty()
		and not stage_id.is_empty()
		and not region_id.is_empty()
		and not first_clear_claim_id.is_empty()
		and _has_valid_stacks(first_clear_guarantees)
		and _has_valid_stacks(replay_guarantees)
		and _has_valid_optional_rewards()
		and _has_unique_ids(first_clear_recipe_ids)
		and _has_unique_ids(first_clear_discovery_ids)
		and _has_unique_ids(first_clear_key_item_ids)
		and not first_clear_guarantees.is_empty()
		and not replay_guarantees.is_empty()
	)


func _has_valid_stacks(stacks: Array[MaterialStackDefinition]) -> bool:
	var seen_material_ids := {}
	for stack: MaterialStackDefinition in stacks:
		if (
			stack == null
			or not stack.is_valid()
			or seen_material_ids.has(stack.material.material_id)
		):
			return false
		seen_material_ids[stack.material.material_id] = true
	return true


func _has_valid_optional_rewards() -> bool:
	var seen_material_ids := {}
	for entry: MaterialDropEntryDefinition in optional_rewards:
		if (
			entry == null
			or not entry.is_valid()
			or entry.is_guaranteed()
			or seen_material_ids.has(entry.material.material_id)
		):
			return false
		seen_material_ids[entry.material.material_id] = true
	return true


func _has_unique_ids(entries: PackedStringArray) -> bool:
	var seen_ids := {}
	for raw_id: String in entries:
		var entry_id := StringName(raw_id.strip_edges())
		if entry_id.is_empty() or seen_ids.has(entry_id):
			return false
		seen_ids[entry_id] = true
	return true
