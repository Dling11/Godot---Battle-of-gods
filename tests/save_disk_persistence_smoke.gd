extends SceneTree

const VarkuunEdge: EquipmentDefinition = preload(
	"res://data/items/equipment/forest/stage_5_core/varkuun_edge_essence.tres"
)
const TEST_PROFILE_PATH := "user://battle_of_gods_save_disk_smoke.json"

var _save_service: Node


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_save_service = root.get_node("SaveService")
	if not _save_service.configure_storage_path_for_testing(TEST_PROFILE_PATH):
		_fail("SaveService refused the isolated debug storage path.")
		return
	_save_service.delete_profile()

	_set_profile_a()
	if not _save_service.save_profile():
		_fail("The first atomic profile write failed.")
		return
	if not FileAccess.file_exists(TEST_PROFILE_PATH):
		_fail("The committed primary profile file does not exist.")
		return

	_set_profile_b()
	if not _save_service.save_profile():
		_fail("The second atomic profile write failed.")
		return
	if not FileAccess.file_exists("%s.bak" % TEST_PROFILE_PATH):
		_fail("Replacing a valid profile did not rotate a backup.")
		return

	_reset_live_state()
	if _save_service.load_profile() != _save_service.DEFAULT_SAFE_SCENE:
		_fail("The current primary profile did not load its safe destination.")
		return
	if not _matches_profile_b():
		_fail("The current primary profile did not restore its latest state.")
		return

	var corrupt_file := FileAccess.open(TEST_PROFILE_PATH, FileAccess.WRITE)
	if corrupt_file == null:
		_fail("The smoke test could not create a controlled corrupt primary.")
		return
	corrupt_file.store_string("{ definitely-not-valid-json")
	corrupt_file.close()
	_reset_live_state()
	if _save_service.load_profile() != _save_service.DEFAULT_SAFE_SCENE:
		_fail("A valid backup did not recover a corrupt primary profile.")
		return
	if not _matches_profile_a():
		_fail("Backup recovery did not restore the previous valid state.")
		return

	# Recovery must repair the primary, not depend forever on the backup.
	DirAccess.remove_absolute(
		ProjectSettings.globalize_path("%s.bak" % TEST_PROFILE_PATH)
	)
	_reset_live_state()
	if _save_service.load_profile() != _save_service.DEFAULT_SAFE_SCENE:
		_fail("Backup recovery did not repair the primary profile.")
		return
	if not _matches_profile_a():
		_fail("The repaired primary profile changed recovered state.")
		return

	_set_profile_b()
	_save_service.suppress_autosave_for_debug_session()
	if not _save_service.save_profile():
		_fail("Debug autosave suppression did not remain a successful no-op.")
		return
	_reset_live_state()
	if _save_service.load_profile() != _save_service.DEFAULT_SAFE_SCENE:
		_fail("Loading the last real checkpoint failed after debug suppression.")
		return
	if not _matches_profile_a():
		_fail("A debug testing preset overwrote the last real checkpoint.")
		return

	if not _save_service.delete_profile():
		_fail("SaveService could not delete its isolated profile files.")
		return
	if (
		FileAccess.file_exists(TEST_PROFILE_PATH)
		or FileAccess.file_exists("%s.tmp" % TEST_PROFILE_PATH)
		or FileAccess.file_exists("%s.bak" % TEST_PROFILE_PATH)
	):
		_fail("Deleting a profile left a primary, temporary, or backup file.")
		return

	_cleanup()
	print("Save disk persistence smoke test passed.")
	quit(0)


func _set_profile_a() -> void:
	_reset_live_state()
	root.get_node("RunSession").update_progression(120, 14)
	root.get_node("RunSession").update_player_health(101.0)
	root.get_node("StoryState").remember_story(&"profile_a")
	root.get_node("MaterialInventory").add_material(&"forest_root_fiber", 2)
	root.get_node("RecipeDiscovery").discover_recipe(&"forest_stage_5_rootfiber_gloves")
	root.get_node("LootState").claim_first_clear(&"forest_stage_1_first_clear_claim")
	root.get_node("LootState").record_bad_luck_result(&"profile_a_misses", false)


func _set_profile_b() -> void:
	_reset_live_state()
	root.get_node("RunSession").update_progression(725, 113)
	root.get_node("RunSession").update_player_health(92.0)
	root.get_node("StoryState").remember_story(&"profile_b")
	var weapon_inventory := root.get_node("WeaponInventory")
	weapon_inventory.acquire_weapon(VarkuunEdge)
	weapon_inventory.equip_weapon(&"king", &"warrior", VarkuunEdge)
	root.get_node("MaterialInventory").add_material(&"forest_thorn_sap", 4)
	root.get_node("RecipeDiscovery").discover_recipe(&"forest_thornward_clasp")
	root.get_node("LootState").claim_first_clear(&"forest_stage_2_first_clear_claim")


func _matches_profile_a() -> bool:
	return (
		root.get_node("RunSession").total_experience == 120
		and root.get_node("RunSession").coins == 14
		and is_equal_approx(root.get_node("RunSession").player_current_health, 101.0)
		and root.get_node("StoryState").has_story_flag(&"profile_a")
		and not root.get_node("WeaponInventory").owns_weapon(VarkuunEdge.item_id)
		and root.get_node("MaterialInventory").get_quantity(&"forest_root_fiber") == 2
		and root.get_node("MaterialInventory").get_quantity(&"forest_thorn_sap") == 0
		and root.get_node("RecipeDiscovery").is_recipe_discovered(
			&"forest_stage_5_rootfiber_gloves"
		)
		and not root.get_node("RecipeDiscovery").is_recipe_discovered(&"forest_thornward_clasp")
		and root.get_node("LootState").has_first_clear_claim(
			&"forest_stage_1_first_clear_claim"
		)
		and root.get_node("LootState").get_bad_luck_misses(&"profile_a_misses") == 1
	)


func _matches_profile_b() -> bool:
	return (
		root.get_node("RunSession").total_experience == 725
		and root.get_node("RunSession").coins == 113
		and is_equal_approx(root.get_node("RunSession").player_current_health, 92.0)
		and root.get_node("StoryState").has_story_flag(&"profile_b")
		and root.get_node("WeaponInventory").owns_weapon(VarkuunEdge.item_id)
		and root.get_node("WeaponInventory").get_equipped_weapon_id(&"king", &"")
		== VarkuunEdge.item_id
		and root.get_node("MaterialInventory").get_quantity(&"forest_thorn_sap") == 4
		and root.get_node("MaterialInventory").get_quantity(&"forest_root_fiber") == 0
		and root.get_node("RecipeDiscovery").is_recipe_discovered(&"forest_thornward_clasp")
		and not root.get_node("RecipeDiscovery").is_recipe_discovered(
			&"forest_stage_5_rootfiber_gloves"
		)
		and root.get_node("LootState").has_first_clear_claim(
			&"forest_stage_2_first_clear_claim"
		)
		and not root.get_node("LootState").has_first_clear_claim(
			&"forest_stage_1_first_clear_claim"
		)
	)


func _reset_live_state() -> void:
	root.get_node("RunSession").reset_run()
	root.get_node("StoryState").reset_story()
	root.get_node("WeaponInventory").reset_inventory()
	root.get_node("GearInventory").reset_inventory()
	root.get_node("MaterialInventory").reset_inventory()
	root.get_node("RecipeDiscovery").reset_discoveries()
	root.get_node("LootState").reset_state()
	root.get_node("LootService").reset_expedition_tracking()


func _cleanup() -> void:
	if _save_service != null:
		_save_service.delete_profile()
		_save_service.reset_storage_path_after_testing()


func _fail(message: String) -> void:
	_cleanup()
	push_error(message)
	quit(1)
