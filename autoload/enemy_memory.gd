extends Node

## Durable defeat knowledge used by material reconstruction. This service does
## not know any material names; definitions connect a source enemy to Umi.

signal enemy_defeat_recorded(enemy_id: StringName, total_defeats: int)
signal memory_charge_spent(enemy_id: StringName, total_spent: int)
signal memory_reset

const SNAPSHOT_VERSION := 1

var _defeats: Dictionary = {}
var _spent_memory_charges: Dictionary = {}


func reset_memory() -> void:
	_defeats.clear()
	_spent_memory_charges.clear()
	memory_reset.emit()


func record_defeat(enemy_id: StringName) -> bool:
	if enemy_id.is_empty():
		return false
	var total := get_defeat_count(enemy_id) + 1
	_defeats[enemy_id] = total
	enemy_defeat_recorded.emit(enemy_id, total)
	return true


func get_defeat_count(enemy_id: StringName) -> int:
	return int(_defeats.get(enemy_id, 0))


func get_available_memory_charges(enemy_id: StringName, interval: int = 10) -> int:
	if enemy_id.is_empty() or interval <= 0:
		return 0
	return maxi(get_defeat_count(enemy_id) / interval - int(_spent_memory_charges.get(enemy_id, 0)), 0)


func spend_memory_charge(enemy_id: StringName, interval: int = 10) -> bool:
	if get_available_memory_charges(enemy_id, interval) <= 0:
		return false
	var spent := int(_spent_memory_charges.get(enemy_id, 0)) + 1
	_spent_memory_charges[enemy_id] = spent
	memory_charge_spent.emit(enemy_id, spent)
	return true


func create_snapshot() -> Dictionary:
	return {
		"version": SNAPSHOT_VERSION,
		"defeats": _sorted_positive_copy(_defeats),
		"spent_memory_charges": _sorted_positive_copy(_spent_memory_charges),
	}


func can_restore_snapshot(snapshot: Dictionary) -> bool:
	if snapshot.get("version", -1) != SNAPSHOT_VERSION:
		return false
	for section_name: String in ["defeats", "spent_memory_charges"]:
		var section: Variant = snapshot.get(section_name)
		if not (section is Dictionary):
			return false
		for raw_id: Variant in section:
			if not (raw_id is String or raw_id is StringName):
				return false
			var value: Variant = section[raw_id]
			if String(raw_id).is_empty() or not (value is int or value is float):
				return false
			if float(value) < 0.0 or float(value) != floor(float(value)):
				return false
	return true


func restore_snapshot(snapshot: Dictionary) -> bool:
	if not can_restore_snapshot(snapshot):
		return false
	_defeats = _restore_section(snapshot["defeats"])
	_spent_memory_charges = _restore_section(snapshot["spent_memory_charges"])
	memory_reset.emit()
	return true


func _sorted_positive_copy(source: Dictionary) -> Dictionary:
	var result := {}
	var ids := PackedStringArray()
	for raw_id: Variant in source:
		ids.append(String(raw_id))
	ids.sort()
	for raw_id: String in ids:
		var value := int(source.get(StringName(raw_id), source.get(raw_id, 0)))
		if value > 0:
			result[raw_id] = value
	return result


func _restore_section(source: Dictionary) -> Dictionary:
	var result := {}
	for raw_id: Variant in source:
		var value := int(source[raw_id])
		if value > 0:
			result[StringName(String(raw_id))] = value
	return result
