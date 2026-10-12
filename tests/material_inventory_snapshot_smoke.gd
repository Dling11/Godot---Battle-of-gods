extends SceneTree


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var material_inventory := root.get_node("MaterialInventory")
	var recipe_discovery := root.get_node("RecipeDiscovery")
	var run_session := root.get_node("RunSession")
	var save_service := root.get_node("SaveService")

	material_inventory.reset_inventory()
	recipe_discovery.reset_discoveries()
	run_session.reset_run()

	if (
		not material_inventory.add_material(&"forest_root_fiber", 3)
		or not material_inventory.add_material(&"forest_root_fiber", 4)
		or material_inventory.get_quantity(&"forest_root_fiber") != 7
	):
		_fail("MaterialInventory did not accumulate a known material quantity.")
		return
	if (
		material_inventory.add_material(&"unknown_material", 1)
		or material_inventory.add_material(&"forest_root_fiber", 0)
		or material_inventory.remove_material(&"forest_root_fiber", 8)
	):
		_fail("MaterialInventory accepted an unknown or invalid quantity mutation.")
		return
	if (
		not material_inventory.remove_material(&"forest_root_fiber", 2)
		or material_inventory.get_quantity(&"forest_root_fiber") != 5
	):
		_fail("MaterialInventory did not remove an owned quantity.")
		return

	if (
		not recipe_discovery.discover_recipe(&"forest_stage_5_rootfiber_gloves")
		or recipe_discovery.discover_recipe(&"forest_stage_5_rootfiber_gloves")
		or recipe_discovery.discover_recipe(&"unknown_recipe")
	):
		_fail("RecipeDiscovery did not enforce known, unique recipe IDs.")
		return

	var material_snapshot: Dictionary = material_inventory.create_snapshot()
	var recipe_snapshot: Dictionary = recipe_discovery.create_snapshot()
	material_inventory.reset_inventory()
	recipe_discovery.reset_discoveries()
	if (
		not material_inventory.restore_snapshot(material_snapshot)
		or not recipe_discovery.restore_snapshot(recipe_snapshot)
		or material_inventory.get_quantity(&"forest_root_fiber") != 5
		or not recipe_discovery.is_recipe_discovered(&"forest_stage_5_rootfiber_gloves")
	):
		_fail("Material or recipe discovery snapshot reconstruction lost state.")
		return

	if material_inventory.can_restore_snapshot({
		"version": material_inventory.SNAPSHOT_VERSION,
		"quantities": {"forest_root_fiber": 2.5},
	}):
		_fail("MaterialInventory accepted a fractional JSON quantity.")
		return
	if material_inventory.can_restore_snapshot({
		"version": material_inventory.SNAPSHOT_VERSION,
		"quantities": {"unknown_material": 1},
	}):
		_fail("MaterialInventory accepted an unknown saved material ID.")
		return
	if recipe_discovery.can_restore_snapshot({
		"version": recipe_discovery.SNAPSHOT_VERSION,
		"discovered_recipe_ids": [
			"forest_stage_5_rootfiber_gloves",
			"forest_stage_5_rootfiber_gloves",
		],
	}):
		_fail("RecipeDiscovery accepted duplicate saved recipe IDs.")
		return

	run_session.update_progression(400, 21)
	var profile_snapshot: Dictionary = save_service.create_profile_snapshot()
	var extensions: Dictionary = profile_snapshot["extensions"]
	if (
		extensions["material_inventory"].get("version", -1)
		!= material_inventory.SNAPSHOT_VERSION
		or extensions["recipe_discovery"].get("version", -1)
		!= recipe_discovery.SNAPSHOT_VERSION
	):
		_fail("SaveService did not include versioned material and recipe sections.")
		return
	material_inventory.reset_inventory()
	recipe_discovery.reset_discoveries()
	if (
		not save_service.restore_profile(profile_snapshot)
		or material_inventory.get_quantity(&"forest_root_fiber") != 5
		or not recipe_discovery.is_recipe_discovered(&"forest_stage_5_rootfiber_gloves")
	):
		_fail("SaveService did not reconstruct crafting progress.")
		return

	var legacy_profile := profile_snapshot.duplicate(true)
	legacy_profile["extensions"]["material_inventory"] = {}
	legacy_profile["extensions"]["recipe_discovery"] = {}
	if not save_service.restore_profile(legacy_profile):
		_fail("SaveService rejected a valid pre-Segment-2 reserved extension.")
		return
	if (
		material_inventory.get_quantity(&"forest_root_fiber") != 0
		or recipe_discovery.is_recipe_discovered(&"forest_stage_5_rootfiber_gloves")
	):
		_fail("A legacy empty extension did not restore clean empty crafting state.")
		return

	var invalid_profile := profile_snapshot.duplicate(true)
	invalid_profile["extensions"]["material_inventory"] = {
		"version": material_inventory.SNAPSHOT_VERSION,
		"quantities": {"unknown_material": 1},
	}
	run_session.update_progression(17, 9)
	if save_service.restore_profile(invalid_profile):
		_fail("SaveService accepted an invalid material extension.")
		return
	if run_session.total_experience != 17 or run_session.coins != 9:
		_fail("Invalid extension validation partially mutated live profile state.")
		return

	print("Material inventory snapshot smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
