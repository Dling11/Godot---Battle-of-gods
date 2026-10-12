extends Node

## Versioned single-profile persistence. Gameplay authorities own their state;
## this service validates, stores, recovers, and restores their snapshots.

signal profile_saved(profile_path: String)
signal profile_restored(safe_scene_path: String)
signal profile_error(message: String)

const PROFILE_VERSION := 1
const DEFAULT_SAFE_SCENE := "res://levels/sanctuary/sanctuary.tscn"
const DEFAULT_PROFILE_PATH := "user://battle_of_gods_profile.json"

var _profile_path := DEFAULT_PROFILE_PATH
var _testing_storage_override := false
var _debug_autosave_suppressed := false


func create_profile_snapshot(safe_scene_path: String = DEFAULT_SAFE_SCENE) -> Dictionary:
	if not _has_core_authorities():
		_report_error("SaveService requires every profile-backed progression authority.")
		return {}
	if safe_scene_path != DEFAULT_SAFE_SCENE or not ResourceLoader.exists(safe_scene_path):
		_report_error("SaveService currently supports only the Sanctuary safe scene.")
		return {}
	var loot_state := get_node("/root/LootState")
	return {
		"version": PROFILE_VERSION,
		"safe_scene_path": safe_scene_path,
		"run_session": RunSession.create_snapshot(),
		"story_state": StoryState.create_snapshot(),
		"weapon_inventory": WeaponInventory.create_snapshot(),
		"extensions": {
			"gear_inventory": GearInventory.create_snapshot(),
			"material_inventory": MaterialInventory.create_snapshot(),
			"recipe_discovery": RecipeDiscovery.create_snapshot(),
			"enemy_memory": EnemyMemory.create_snapshot(),
			"stage_claims": loot_state.create_snapshot(),
			"regional_progress": {},
		},
	}


func save_profile(safe_scene_path: String = DEFAULT_SAFE_SCENE) -> bool:
	if _disk_access_suppressed() or _debug_autosave_suppressed:
		return true
	var snapshot := create_profile_snapshot(safe_scene_path)
	if snapshot.is_empty():
		return false
	return _commit_snapshot(snapshot, true)


func has_valid_profile() -> bool:
	if _disk_access_suppressed():
		return false
	return (
		not _read_valid_snapshot(_profile_path).is_empty()
		or not _read_valid_snapshot(_backup_path()).is_empty()
	)


func load_profile() -> String:
	if _disk_access_suppressed():
		return ""
	_debug_autosave_suppressed = false
	var snapshot := _read_valid_snapshot(_profile_path)
	var recovered_from_backup := false
	if snapshot.is_empty():
		snapshot = _read_valid_snapshot(_backup_path())
		recovered_from_backup = not snapshot.is_empty()
	if snapshot.is_empty() or not restore_profile(snapshot):
		_report_error("No compatible Battle of Gods profile could be loaded.")
		return ""
	if recovered_from_backup:
		_repair_primary_from_snapshot(snapshot)
	return String(snapshot["safe_scene_path"])


func delete_profile() -> bool:
	if _disk_access_suppressed():
		return true
	_debug_autosave_suppressed = false
	var success := true
	for path: String in [_profile_path, _temporary_path(), _backup_path()]:
		if FileAccess.file_exists(path):
			var error := DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
			success = success and error == OK
	return success


func can_restore_profile(snapshot: Dictionary) -> bool:
	if not _has_core_authorities() or snapshot.get("version", -1) != PROFILE_VERSION:
		return false
	var safe_scene_path: Variant = snapshot.get("safe_scene_path")
	var run_snapshot: Variant = snapshot.get("run_session")
	var story_snapshot: Variant = snapshot.get("story_state")
	var weapon_snapshot: Variant = snapshot.get("weapon_inventory")
	var extensions: Variant = snapshot.get("extensions", {})
	var material_snapshot: Variant = (
		extensions.get("material_inventory", {}) if extensions is Dictionary else {}
	)
	var gear_snapshot: Variant = (
		extensions.get("gear_inventory", {}) if extensions is Dictionary else {}
	)
	var recipe_snapshot: Variant = (
		extensions.get("recipe_discovery", {}) if extensions is Dictionary else {}
	)
	var stage_claim_snapshot: Variant = (
		extensions.get("stage_claims", {}) if extensions is Dictionary else {}
	)
	var enemy_memory_snapshot: Variant = (
		extensions.get("enemy_memory", {}) if extensions is Dictionary else {}
	)
	return (
		safe_scene_path is String
		and String(safe_scene_path) == DEFAULT_SAFE_SCENE
		and ResourceLoader.exists(DEFAULT_SAFE_SCENE)
		and run_snapshot is Dictionary
		and story_snapshot is Dictionary
		and weapon_snapshot is Dictionary
		and _has_valid_extensions(extensions)
		and RunSession.can_restore_snapshot(run_snapshot)
		and StoryState.can_restore_snapshot(story_snapshot)
		and WeaponInventory.can_restore_snapshot(weapon_snapshot)
		and _can_restore_gear_extension(gear_snapshot)
		and _can_restore_material_extension(material_snapshot)
		and _can_restore_recipe_extension(recipe_snapshot)
		and _can_restore_enemy_memory_extension(enemy_memory_snapshot)
		and _can_restore_stage_claim_extension(stage_claim_snapshot)
	)


func restore_profile(snapshot: Dictionary) -> bool:
	if not can_restore_profile(snapshot):
		return false
	# All sections validate before mutation, preventing partial restoration.
	StoryState.restore_snapshot(snapshot["story_state"])
	WeaponInventory.restore_snapshot(snapshot["weapon_inventory"])
	var extensions: Dictionary = snapshot["extensions"]
	var gear_snapshot: Dictionary = extensions.get("gear_inventory", {})
	var material_snapshot: Dictionary = extensions["material_inventory"]
	var recipe_snapshot: Dictionary = extensions["recipe_discovery"]
	var enemy_memory_snapshot: Dictionary = extensions.get("enemy_memory", {})
	var stage_claim_snapshot: Dictionary = extensions["stage_claims"]
	var loot_state := get_node("/root/LootState")
	if gear_snapshot.is_empty():
		GearInventory.reset_inventory()
	else:
		GearInventory.restore_snapshot(gear_snapshot)
	# Gear signals may refresh the still-live player's vitality. Restore the
	# authoritative run snapshot afterward so saved XP, coins, and HP win last.
	RunSession.restore_snapshot(snapshot["run_session"])
	if material_snapshot.is_empty():
		MaterialInventory.reset_inventory()
	else:
		MaterialInventory.restore_snapshot(material_snapshot)
	if recipe_snapshot.is_empty():
		RecipeDiscovery.reset_discoveries()
	else:
		RecipeDiscovery.restore_snapshot(recipe_snapshot)
	if enemy_memory_snapshot.is_empty():
		EnemyMemory.reset_memory()
	else:
		EnemyMemory.restore_snapshot(enemy_memory_snapshot)
	if stage_claim_snapshot.is_empty():
		loot_state.reset_state()
	else:
		loot_state.restore_snapshot(stage_claim_snapshot)
	var loot_service := get_node_or_null("/root/LootService")
	if loot_service != null:
		loot_service.reset_expedition_tracking()
	var safe_scene_path := String(snapshot["safe_scene_path"])
	profile_restored.emit(safe_scene_path)
	return true


func configure_storage_path_for_testing(profile_path: String) -> bool:
	if not OS.is_debug_build() or not profile_path.begins_with("user://"):
		return false
	_profile_path = profile_path
	_testing_storage_override = true
	return true


func reset_storage_path_after_testing() -> void:
	_profile_path = DEFAULT_PROFILE_PATH
	_testing_storage_override = false


func get_profile_path() -> String:
	return _profile_path


func suppress_autosave_for_debug_session() -> void:
	if OS.is_debug_build():
		_debug_autosave_suppressed = true


func is_autosave_suppressed_for_debug() -> bool:
	return _debug_autosave_suppressed


func _commit_snapshot(snapshot: Dictionary, rotate_backup: bool) -> bool:
	if not can_restore_profile(snapshot):
		_report_error("SaveService refused to write an invalid profile snapshot.")
		return false
	var temporary_path := _temporary_path()
	if not _write_snapshot(temporary_path, snapshot):
		_report_error("SaveService could not write a validated temporary profile.")
		return false

	var absolute_profile := ProjectSettings.globalize_path(_profile_path)
	var absolute_temporary := ProjectSettings.globalize_path(temporary_path)
	var absolute_backup := ProjectSettings.globalize_path(_backup_path())
	if rotate_backup and not _read_valid_snapshot(_profile_path).is_empty():
		if FileAccess.file_exists(_backup_path()):
			DirAccess.remove_absolute(absolute_backup)
		var backup_error := DirAccess.copy_absolute(absolute_profile, absolute_backup)
		if backup_error != OK:
			DirAccess.remove_absolute(absolute_temporary)
			_report_error("SaveService could not rotate the profile backup.")
			return false
	if FileAccess.file_exists(_profile_path):
		var remove_error := DirAccess.remove_absolute(absolute_profile)
		if remove_error != OK:
			DirAccess.remove_absolute(absolute_temporary)
			_report_error("SaveService could not replace the existing profile.")
			return false
	var rename_error := DirAccess.rename_absolute(absolute_temporary, absolute_profile)
	if rename_error != OK:
		if FileAccess.file_exists(_backup_path()):
			DirAccess.copy_absolute(absolute_backup, absolute_profile)
		_report_error("SaveService could not commit the temporary profile.")
		return false
	profile_saved.emit(_profile_path)
	return true


func _repair_primary_from_snapshot(snapshot: Dictionary) -> bool:
	return _commit_snapshot(snapshot, false)


func _write_snapshot(path: String, snapshot: Dictionary) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(snapshot, "\t"))
	file.flush()
	file.close()
	return not _read_valid_snapshot(path).is_empty()


func _read_valid_snapshot(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var json := JSON.new()
	var parse_error := json.parse(file.get_as_text())
	file.close()
	if parse_error != OK:
		return {}
	var parsed: Variant = json.data
	if not (parsed is Dictionary):
		return {}
	var snapshot: Dictionary = parsed
	return snapshot if can_restore_profile(snapshot) else {}


func _temporary_path() -> String:
	return "%s.tmp" % _profile_path


func _backup_path() -> String:
	return "%s.bak" % _profile_path


func _report_error(message: String) -> void:
	push_error(message)
	profile_error.emit(message)


func _disk_access_suppressed() -> bool:
	return DisplayServer.get_name() == "headless" and not _testing_storage_override


func _has_valid_extensions(extensions: Variant) -> bool:
	if not (extensions is Dictionary):
		return false
	for section_name: String in [
		"material_inventory",
		"recipe_discovery",
		"stage_claims",
		"regional_progress",
	]:
		if not extensions.has(section_name) or not (extensions[section_name] is Dictionary):
			return false
	return true


func _has_core_authorities() -> bool:
	return (
		get_node_or_null("/root/RunSession") != null
		and get_node_or_null("/root/StoryState") != null
		and get_node_or_null("/root/WeaponInventory") != null
		and get_node_or_null("/root/GearInventory") != null
		and get_node_or_null("/root/MaterialInventory") != null
		and get_node_or_null("/root/RecipeDiscovery") != null
		and get_node_or_null("/root/EnemyMemory") != null
		and get_node_or_null("/root/LootState") != null
	)


func _can_restore_material_extension(snapshot: Variant) -> bool:
	return (
		snapshot is Dictionary
		and (snapshot.is_empty() or MaterialInventory.can_restore_snapshot(snapshot))
	)


func _can_restore_gear_extension(snapshot: Variant) -> bool:
	return (
		snapshot is Dictionary
		and (snapshot.is_empty() or GearInventory.can_restore_snapshot(snapshot))
	)


func _can_restore_recipe_extension(snapshot: Variant) -> bool:
	return (
		snapshot is Dictionary
		and (snapshot.is_empty() or RecipeDiscovery.can_restore_snapshot(snapshot))
	)


func _can_restore_enemy_memory_extension(snapshot: Variant) -> bool:
	return (
		snapshot is Dictionary
		and (snapshot.is_empty() or EnemyMemory.can_restore_snapshot(snapshot))
	)


func _can_restore_stage_claim_extension(snapshot: Variant) -> bool:
	var loot_state := get_node_or_null("/root/LootState")
	return (
		snapshot is Dictionary
		and loot_state != null
		and (snapshot.is_empty() or loot_state.can_restore_snapshot(snapshot))
	)
