extends Node

## In-memory narrative authority for route access. Snapshot data is deliberately
## versioned, but disk persistence remains a separate future decision.

signal story_state_changed

const SNAPSHOT_VERSION := 1

var _story_flags: Dictionary = {}
var _boss_victories: Dictionary = {}
var _discoveries: Dictionary = {}
var _key_items: Dictionary = {}


func reset_story() -> void:
	_story_flags.clear()
	_boss_victories.clear()
	_discoveries.clear()
	_key_items.clear()
	story_state_changed.emit()


func remember_story(flag_id: StringName) -> void:
	_record(_story_flags, flag_id)


func record_boss_victory(boss_id: StringName) -> void:
	_record(_boss_victories, boss_id)


func record_discovery(discovery_id: StringName) -> void:
	_record(_discoveries, discovery_id)


func grant_key_item(item_id: StringName) -> void:
	_record(_key_items, item_id)


func apply_debug_expedition_unlocks() -> bool:
	if not OS.is_debug_build():
		return false
	remember_story(&"awakened_in_sanctuary")
	remember_story(&"forgotten_grove_stage_1_cleared")
	remember_story(&"forgotten_grove_completed")
	record_boss_victory(&"thornbound_warden")
	grant_key_item(&"cinder_sigil")
	remember_story(&"rootbound_hollow_completed")
	record_boss_victory(&"rootbound_husk")
	record_discovery(&"rootbound_hollow")
	remember_story(&"forest_stage_4_cleared")
	record_discovery(&"eastern_rot")
	remember_story(&"forest_stage_5_cleared")
	record_boss_victory(&"stage_5_boss")
	record_discovery(&"dead_forest")
	return true


func has_story_flag(flag_id: StringName) -> bool:
	return _story_flags.has(flag_id)


func has_boss_victory(boss_id: StringName) -> bool:
	return _boss_victories.has(boss_id)


func has_discovery(discovery_id: StringName) -> bool:
	return _discoveries.has(discovery_id)


func has_key_item(item_id: StringName) -> bool:
	return _key_items.has(item_id)


func create_snapshot() -> Dictionary:
	return {
		"version": SNAPSHOT_VERSION,
		"story_flags": _sorted_ids(_story_flags),
		"boss_victories": _sorted_ids(_boss_victories),
		"discoveries": _sorted_ids(_discoveries),
		"key_items": _sorted_ids(_key_items),
	}


func can_restore_snapshot(snapshot: Dictionary) -> bool:
	if snapshot.get("version", -1) != SNAPSHOT_VERSION:
		return false
	for collection_name: String in [
		"story_flags",
		"boss_victories",
		"discoveries",
		"key_items",
	]:
		var entries: Variant = snapshot.get(collection_name)
		if not (entries is Array or entries is PackedStringArray):
			return false
		for entry: Variant in entries:
			if not (entry is String or entry is StringName) or String(entry).is_empty():
				return false
	return true


func restore_snapshot(snapshot: Dictionary) -> bool:
	if not can_restore_snapshot(snapshot):
		return false
	_story_flags = _dictionary_from_ids(snapshot.get("story_flags", []))
	_boss_victories = _dictionary_from_ids(snapshot.get("boss_victories", []))
	_discoveries = _dictionary_from_ids(snapshot.get("discoveries", []))
	_key_items = _dictionary_from_ids(snapshot.get("key_items", []))
	story_state_changed.emit()
	return true


func _record(collection: Dictionary, entry_id: StringName) -> void:
	if entry_id.is_empty() or collection.has(entry_id):
		return
	collection[entry_id] = true
	story_state_changed.emit()


func _sorted_ids(collection: Dictionary) -> PackedStringArray:
	var result := PackedStringArray()
	for entry_id: StringName in collection:
		result.append(String(entry_id))
	result.sort()
	return result


func _dictionary_from_ids(entries: Variant) -> Dictionary:
	var result := {}
	if entries is Array or entries is PackedStringArray:
		for entry: Variant in entries:
			var entry_id := StringName(String(entry))
			if not entry_id.is_empty():
				result[entry_id] = true
	return result
