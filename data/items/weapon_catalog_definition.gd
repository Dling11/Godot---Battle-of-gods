class_name WeaponCatalogDefinition
extends Resource

## Authored weapon stock for one playable character. Ownership and the current
## equipped choice are runtime state owned by WeaponInventory.

@export var default_weapon: EquipmentDefinition
@export var weapons: Array[EquipmentDefinition] = []


func has_valid_layout() -> bool:
	if default_weapon == null or not default_weapon.is_equippable_weapon():
		return false
	if weapons.is_empty() or not weapons.has(default_weapon):
		return false
	var seen_ids: Dictionary = {}
	for item: EquipmentDefinition in weapons:
		if item == null or not item.is_equippable_weapon() or seen_ids.has(item.item_id):
			return false
		seen_ids[item.item_id] = true
	return true


func find_weapon(item_id: StringName) -> EquipmentDefinition:
	for item: EquipmentDefinition in weapons:
		if item != null and item.item_id == item_id:
			return item
	return null
