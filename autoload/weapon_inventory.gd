extends Node

## Weapon ownership and per-character equipped choices. SaveService may snapshot
## this data, but WeaponInventory does not perform file I/O.

signal weapon_acquired(item_id: StringName)
signal weapon_equipped(character_id: StringName, item_id: StringName)
signal inventory_reset

const KingCatalog: WeaponCatalogDefinition = preload("res://data/items/king_weapon_catalog.tres")
const SNAPSHOT_VERSION := 2
const RETIRED_GREATSWORD_ID := &"weapon_king_royal_greatsword"
const CURRENT_GREATSWORD_ID := &"weapon_king_royal_greatsword_v2"

var _owned_weapon_ids: Dictionary = {}
var _equipped_weapon_ids: Dictionary = {}


func _ready() -> void:
	reset_inventory()


func reset_inventory() -> void:
	_owned_weapon_ids.clear()
	_equipped_weapon_ids.clear()
	_register_default(&"king", KingCatalog)
	inventory_reset.emit()


func owns_weapon(item_id: StringName) -> bool:
	return _owned_weapon_ids.has(item_id)


func acquire_weapon(item: EquipmentDefinition) -> bool:
	if item == null or item.item_id == RETIRED_GREATSWORD_ID or not item.is_equippable_weapon() or owns_weapon(item.item_id):
		return false
	_owned_weapon_ids[item.item_id] = true
	weapon_acquired.emit(item.item_id)
	return true


func get_equipped_weapon_id(character_id: StringName, fallback_item_id: StringName) -> StringName:
	var item_id: StringName = _equipped_weapon_ids.get(character_id, fallback_item_id)
	return item_id if owns_weapon(item_id) else fallback_item_id


func create_snapshot() -> Dictionary:
	var equipped_ids := {}
	var character_ids: PackedStringArray = []
	for raw_character_id: Variant in _equipped_weapon_ids:
		character_ids.append(String(raw_character_id))
	character_ids.sort()
	for character_id: String in character_ids:
		equipped_ids[character_id] = String(
			_equipped_weapon_ids.get(StringName(character_id), &"")
		)
	return {
		"version": SNAPSHOT_VERSION,
		"owned_weapon_ids": _sorted_owned_ids(),
		"equipped_weapon_ids": equipped_ids,
	}


func can_restore_snapshot(snapshot: Dictionary) -> bool:
	var version := int(snapshot.get("version", -1))
	if version not in [1, SNAPSHOT_VERSION]:
		return false
	var raw_owned: Variant = snapshot.get("owned_weapon_ids", [])
	var raw_equipped: Variant = snapshot.get("equipped_weapon_ids", {})
	if not (raw_owned is Array or raw_owned is PackedStringArray):
		return false
	if not (raw_equipped is Dictionary):
		return false

	var restored_owned := {}
	for raw_item_id: Variant in raw_owned:
		var item_id := _canonical_weapon_id(StringName(String(raw_item_id)))
		if item_id.is_empty():
			return false
		if _find_weapon(item_id) != null:
			restored_owned[item_id] = true
		elif version == SNAPSHOT_VERSION:
			return false
	if version == SNAPSHOT_VERSION and not restored_owned.has(KingCatalog.default_weapon.item_id):
		return false

	for raw_character_id: Variant in raw_equipped:
		var character_id := StringName(String(raw_character_id))
		var item_id := _canonical_weapon_id(StringName(String(raw_equipped[raw_character_id])))
		if character_id.is_empty():
			return false
		if version == SNAPSHOT_VERSION and (
			not restored_owned.has(item_id) or _find_weapon(item_id) == null
		):
			return false
	return true


func restore_snapshot(snapshot: Dictionary) -> bool:
	if not can_restore_snapshot(snapshot):
		return false
	reset_inventory()
	for raw_item_id: Variant in snapshot["owned_weapon_ids"]:
		var item_id := _canonical_weapon_id(StringName(String(raw_item_id)))
		if _find_weapon(item_id) != null:
			_owned_weapon_ids[item_id] = true
	var raw_equipped: Dictionary = snapshot["equipped_weapon_ids"]
	for raw_character_id: Variant in raw_equipped:
		var character_id := StringName(String(raw_character_id))
		var item_id := _canonical_weapon_id(StringName(String(raw_equipped[raw_character_id])))
		if character_id == &"king" and _owned_weapon_ids.has(item_id) and _find_weapon(item_id) != null:
			_equipped_weapon_ids[character_id] = item_id
	inventory_reset.emit()
	for raw_character_id: Variant in _equipped_weapon_ids:
		weapon_equipped.emit(
			StringName(String(raw_character_id)),
			StringName(_equipped_weapon_ids[raw_character_id])
		)
	return true


func try_purchase_weapon(
	item: EquipmentDefinition,
	character_class_id: StringName,
	progression: PlayerProgressionComponent
) -> bool:
	if (
		item == null
		or item.item_id == RETIRED_GREATSWORD_ID
		or progression == null
		or not item.is_equippable_weapon()
		or item.purchase_price <= 0
		or owns_weapon(item.item_id)
		or not item.is_compatible_with(character_class_id)
	):
		return false
	# Reserve ownership before spending because coins_changed listeners run
	# synchronously and may refresh or retry the shop during this transaction.
	_owned_weapon_ids[item.item_id] = true
	if not progression.spend_coins(item.purchase_price):
		_owned_weapon_ids.erase(item.item_id)
		return false
	weapon_acquired.emit(item.item_id)
	return true


func equip_weapon(
	character_id: StringName,
	character_class_id: StringName,
	item: EquipmentDefinition
) -> bool:
	if (
		item == null
		or not item.is_equippable_weapon()
		or not owns_weapon(item.item_id)
		or not item.is_compatible_with(character_class_id)
	):
		return false
	_equipped_weapon_ids[character_id] = item.item_id
	weapon_equipped.emit(character_id, item.item_id)
	return true


func _register_default(character_id: StringName, catalog: WeaponCatalogDefinition) -> void:
	if catalog == null or not catalog.has_valid_layout():
		push_error("WeaponInventory requires a valid default weapon catalog.")
		return
	_owned_weapon_ids[catalog.default_weapon.item_id] = true
	_equipped_weapon_ids[character_id] = catalog.default_weapon.item_id


func _sorted_owned_ids() -> PackedStringArray:
	var result := PackedStringArray()
	for raw_item_id: Variant in _owned_weapon_ids:
		result.append(String(raw_item_id))
	result.sort()
	return result


func _find_weapon(item_id: StringName) -> EquipmentDefinition:
	return KingCatalog.find_weapon(item_id)


func _canonical_weapon_id(item_id: StringName) -> StringName:
	# Version 1 and 2 saves may own/equip the retired five-cut comparison item.
	# Migrate both references together; all other unknown IDs keep their existing
	# validation rules. Snapshots written afterward contain only the live ID.
	return CURRENT_GREATSWORD_ID if item_id == RETIRED_GREATSWORD_ID else item_id
