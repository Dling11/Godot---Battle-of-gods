extends Node

## Mutable recipe unlock authority, deliberately separate from StoryState.

signal recipe_discovered(recipe_id: StringName)
signal discovery_reset

const RecipeCatalog: RecipeCatalogDefinition = preload(
	"res://data/crafting/recipes/recipe_catalog.tres"
)
const SNAPSHOT_VERSION := 1

var _discovered_recipe_ids: Dictionary = {}


func reset_discoveries() -> void:
	_discovered_recipe_ids.clear()
	discovery_reset.emit()


func is_recipe_discovered(recipe_id: StringName) -> bool:
	return _discovered_recipe_ids.has(recipe_id)


func discover_recipe(recipe_id: StringName) -> bool:
	if (
		recipe_id.is_empty()
		or not RecipeCatalog.has_recipe(recipe_id)
		or is_recipe_discovered(recipe_id)
	):
		return false
	_discovered_recipe_ids[recipe_id] = true
	recipe_discovered.emit(recipe_id)
	return true


func create_snapshot() -> Dictionary:
	var recipe_ids := PackedStringArray()
	for raw_recipe_id: Variant in _discovered_recipe_ids:
		recipe_ids.append(String(raw_recipe_id))
	recipe_ids.sort()
	return {
		"version": SNAPSHOT_VERSION,
		"discovered_recipe_ids": recipe_ids,
	}


func can_restore_snapshot(snapshot: Dictionary) -> bool:
	if snapshot.get("version", -1) != SNAPSHOT_VERSION:
		return false
	var raw_recipe_ids: Variant = snapshot.get("discovered_recipe_ids")
	if not (raw_recipe_ids is Array or raw_recipe_ids is PackedStringArray):
		return false
	var seen_ids := {}
	for raw_recipe_id: Variant in raw_recipe_ids:
		if not (raw_recipe_id is String or raw_recipe_id is StringName):
			return false
		var recipe_id := StringName(String(raw_recipe_id))
		if (
			recipe_id.is_empty()
			or seen_ids.has(recipe_id)
			or not RecipeCatalog.has_recipe(recipe_id)
		):
			return false
		seen_ids[recipe_id] = true
	return true


func restore_snapshot(snapshot: Dictionary) -> bool:
	if not can_restore_snapshot(snapshot):
		return false
	_discovered_recipe_ids.clear()
	for raw_recipe_id: Variant in snapshot["discovered_recipe_ids"]:
		_discovered_recipe_ids[StringName(String(raw_recipe_id))] = true
	discovery_reset.emit()
	for raw_recipe_id: Variant in _discovered_recipe_ids:
		recipe_discovered.emit(StringName(String(raw_recipe_id)))
	return true
