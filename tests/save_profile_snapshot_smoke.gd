extends SceneTree

const VarkuunEdge: EquipmentDefinition = preload(
	"res://data/items/equipment/forest/stage_5_core/varkuun_edge_essence.tres"
)
const OldBarkHelm: EquipmentDefinition = preload(
	"res://data/items/equipment/forest/stage_5_core/old_bark_helm.tres"
)


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var run_session := root.get_node("RunSession")
	var story_state := root.get_node("StoryState")
	var weapon_inventory := root.get_node("WeaponInventory")
	var gear_inventory := root.get_node("GearInventory")
	var loot_state := root.get_node("LootState")
	var save_service := root.get_node("SaveService")

	run_session.reset_run()
	story_state.reset_story()
	weapon_inventory.reset_inventory()
	gear_inventory.reset_inventory()
	loot_state.reset_state()
	run_session.update_progression(725, 113)
	run_session.update_player_health(92.0)
	story_state.remember_story(&"forgotten_grove_completed")
	story_state.record_boss_victory(&"rootbound_husk")
	weapon_inventory.acquire_weapon(VarkuunEdge)
	weapon_inventory.equip_weapon(&"king", &"warrior", VarkuunEdge)
	gear_inventory.acquire_item(OldBarkHelm)
	gear_inventory.equip_item(&"king", &"warrior", OldBarkHelm)
	loot_state.claim_first_clear(&"forest_stage_3_first_clear_claim")

	var snapshot: Dictionary = save_service.create_profile_snapshot()
	if snapshot.get("version", -1) != save_service.PROFILE_VERSION:
		_fail("SaveService did not create the current versioned profile schema.")
		return
	var extensions: Dictionary = snapshot.get("extensions", {})
	for reserved_section: String in [
		"gear_inventory",
		"material_inventory",
		"recipe_discovery",
		"stage_claims",
		"regional_progress",
	]:
		if not extensions.has(reserved_section):
			_fail("Profile schema did not reserve %s." % reserved_section)
			return

	run_session.reset_run()
	story_state.reset_story()
	weapon_inventory.reset_inventory()
	gear_inventory.reset_inventory()
	loot_state.reset_state()
	if not save_service.restore_profile(snapshot):
		_fail("A valid core profile snapshot could not be restored.")
		return
	if (
		run_session.total_experience != 725
		or run_session.coins != 113
		or not is_equal_approx(run_session.player_current_health, 92.0)
	):
		_fail("RunSession did not restore XP, coins, and current health.")
		return
	if (
		not story_state.has_story_flag(&"forgotten_grove_completed")
		or not story_state.has_boss_victory(&"rootbound_husk")
	):
		_fail("StoryState did not restore its profile section.")
		return
	if (
		not weapon_inventory.owns_weapon(VarkuunEdge.item_id)
		or weapon_inventory.get_equipped_weapon_id(&"king", &"") != VarkuunEdge.item_id
	):
		_fail("WeaponInventory did not restore ownership and equipped state.")
		return
	if (
		not gear_inventory.owns_item(OldBarkHelm.item_id)
		or gear_inventory.get_equipped_item(
			&"king",
			EquipmentDefinition.Slot.HEAD
		) != OldBarkHelm
	):
		_fail("GearInventory did not restore owned and equipped armor state.")
		return
	if not loot_state.has_first_clear_claim(&"forest_stage_3_first_clear_claim"):
		_fail("LootState did not restore first-clear reward ownership.")
		return

	var invalid_snapshot := snapshot.duplicate(true)
	invalid_snapshot["run_session"]["version"] = 999
	run_session.update_progression(17, 9)
	if save_service.restore_profile(invalid_snapshot):
		_fail("SaveService accepted an incompatible nested snapshot version.")
		return
	if run_session.total_experience != 17 or run_session.coins != 9:
		_fail("Invalid profile validation partially mutated live state.")
		return

	print("Save profile snapshot smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
