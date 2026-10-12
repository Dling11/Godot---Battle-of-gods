extends Node

## Non-weapon equipment ownership and per-character slot authority.

signal gear_acquired(item_id: StringName)
signal gear_equipped(character_id: StringName, slot: int, item_id: StringName)
signal inventory_reset

const Stage5Catalog: EquipmentCatalogDefinition = preload(
	"res://data/items/equipment/forest/stage_5_core_catalog.tres"
)
const SNAPSHOT_VERSION := 1

var _owned_item_ids: Dictionary = {}
var _equipped_by_character: Dictionary = {}


func reset_inventory() -> void:
	_owned_item_ids.clear()
	_equipped_by_character.clear()
	inventory_reset.emit()


func owns_item(item_id: StringName) -> bool:
	return _owned_item_ids.has(item_id)


func acquire_item(item: EquipmentDefinition) -> bool:
	if item == null or not item.is_equippable_gear() or owns_item(item.item_id):
		return false
	if Stage5Catalog.find_item(item.item_id) != item:
		return false
	_owned_item_ids[item.item_id] = true
	gear_acquired.emit(item.item_id)
	return true


func equip_item(
	character_id: StringName,
	character_class_id: StringName,
	item: EquipmentDefinition
) -> bool:
	if (
		character_id.is_empty()
		or item == null
		or not item.is_equippable_gear()
		or not owns_item(item.item_id)
		or not item.is_compatible_with(character_class_id)
	):
		return false
	var slots: Dictionary = _equipped_by_character.get(character_id, {})
	slots[String.num_int64(item.slot)] = item.item_id
	_equipped_by_character[character_id] = slots
	gear_equipped.emit(character_id, item.slot, item.item_id)
	return true


func get_equipped_item(character_id: StringName, slot: EquipmentDefinition.Slot) -> EquipmentDefinition:
	var slots: Dictionary = _equipped_by_character.get(character_id, {})
	var item_id := StringName(String(slots.get(String.num_int64(slot), "")))
	var item := Stage5Catalog.find_item(item_id)
	return item if item != null and item.slot == slot and owns_item(item_id) else null


func get_owned_items() -> Array[EquipmentDefinition]:
	var result: Array[EquipmentDefinition] = []
	for item: EquipmentDefinition in Stage5Catalog.items:
		if item != null and item.slot != EquipmentDefinition.Slot.WEAPON and owns_item(item.item_id):
			result.append(item)
	return result


func apply_debug_testing_preset() -> void:
	if not OS.is_debug_build():
		return
	for item: EquipmentDefinition in Stage5Catalog.items:
		if item != null and item.slot != EquipmentDefinition.Slot.WEAPON:
			acquire_item(item)


func create_snapshot() -> Dictionary:
	var owned := PackedStringArray()
	for raw_item_id: Variant in _owned_item_ids:
		owned.append(String(raw_item_id))
	owned.sort()
	var equipped := {}
	var character_ids := PackedStringArray()
	for raw_character_id: Variant in _equipped_by_character:
		character_ids.append(String(raw_character_id))
	character_ids.sort()
	for character_id: String in character_ids:
		var saved_slots := {}
		var slots: Dictionary = _equipped_by_character[StringName(character_id)]
		for raw_slot: Variant in slots:
			saved_slots[String(raw_slot)] = String(slots[raw_slot])
		equipped[character_id] = saved_slots
	return {
		"version": SNAPSHOT_VERSION,
		"owned_item_ids": owned,
		"equipped_by_character": equipped,
	}


func can_restore_snapshot(snapshot: Dictionary) -> bool:
	if snapshot.get("version", -1) != SNAPSHOT_VERSION:
		return false
	var raw_owned: Variant = snapshot.get("owned_item_ids", [])
	var raw_equipped: Variant = snapshot.get("equipped_by_character", {})
	if not (raw_owned is Array or raw_owned is PackedStringArray) or not (raw_equipped is Dictionary):
		return false
	var owned := {}
	for raw_item_id: Variant in raw_owned:
		var item_id := StringName(String(raw_item_id))
		var item := Stage5Catalog.find_item(item_id)
		if item == null or not item.is_equippable_gear() or owned.has(item_id):
			return false
		owned[item_id] = true
	for raw_character_id: Variant in raw_equipped:
		if String(raw_character_id).is_empty() or not (raw_equipped[raw_character_id] is Dictionary):
			return false
		var seen_slots := {}
		for raw_slot: Variant in raw_equipped[raw_character_id]:
			if not String(raw_slot).is_valid_int():
				return false
			var slot := int(String(raw_slot))
			var item_id := StringName(String(raw_equipped[raw_character_id][raw_slot]))
			var item := Stage5Catalog.find_item(item_id)
			if item == null or item.slot != slot or not owned.has(item_id) or seen_slots.has(slot):
				return false
			seen_slots[slot] = true
	return true


func restore_snapshot(snapshot: Dictionary) -> bool:
	if not can_restore_snapshot(snapshot):
		return false
	_owned_item_ids.clear()
	_equipped_by_character.clear()
	for raw_item_id: Variant in snapshot["owned_item_ids"]:
		_owned_item_ids[StringName(String(raw_item_id))] = true
	var raw_equipped: Dictionary = snapshot["equipped_by_character"]
	for raw_character_id: Variant in raw_equipped:
		var slots := {}
		for raw_slot: Variant in raw_equipped[raw_character_id]:
			slots[String(raw_slot)] = StringName(String(raw_equipped[raw_character_id][raw_slot]))
		_equipped_by_character[StringName(String(raw_character_id))] = slots
	inventory_reset.emit()
	for raw_character_id: Variant in _equipped_by_character:
		for raw_slot: Variant in _equipped_by_character[raw_character_id]:
			gear_equipped.emit(
				StringName(String(raw_character_id)),
				int(String(raw_slot)),
				StringName(_equipped_by_character[raw_character_id][raw_slot])
			)
	return true
