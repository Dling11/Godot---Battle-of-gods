class_name EquipmentCatalogDefinition
extends Resource

## Immutable non-inventory lookup for one authored equipment set.

@export var catalog_id: StringName
@export var items: Array[EquipmentDefinition] = []


func has_valid_layout() -> bool:
	if catalog_id.is_empty() or items.is_empty():
		return false
	var item_ids := {}
	var slots := {}
	for item: EquipmentDefinition in items:
		if (
			item == null
			or not item.is_valid_definition()
			or item_ids.has(item.item_id)
			or slots.has(item.slot)
		):
			return false
		item_ids[item.item_id] = true
		slots[item.slot] = true
	return true


func find_item(item_id: StringName) -> EquipmentDefinition:
	for item: EquipmentDefinition in items:
		if item != null and item.item_id == item_id:
			return item
	return null


func find_slot(slot: EquipmentDefinition.Slot) -> EquipmentDefinition:
	for item: EquipmentDefinition in items:
		if item != null and item.slot == slot:
			return item
	return null
