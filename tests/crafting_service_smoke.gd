extends SceneTree

const TEST_PROFILE_PATH := "user://crafting_service_smoke_profile.json"
const RECIPE_ID := &"forest_stage_5_old_bark_helm"


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var save_service := root.get_node("SaveService")
	var crafting_service := root.get_node("CraftingService")
	var story_state := root.get_node("StoryState")
	var recipe_discovery := root.get_node("RecipeDiscovery")
	var material_inventory := root.get_node("MaterialInventory")
	var gear_inventory := root.get_node("GearInventory")
	save_service.configure_storage_path_for_testing(TEST_PROFILE_PATH)
	save_service.delete_profile()
	root.get_node("RunSession").reset_run()
	root.get_node("StoryState").reset_story()
	root.get_node("WeaponInventory").reset_inventory()
	root.get_node("GearInventory").reset_inventory()
	root.get_node("MaterialInventory").reset_inventory()
	root.get_node("RecipeDiscovery").reset_discoveries()
	root.get_node("LootState").reset_state()
	var recipe: RecipeDefinition = recipe_discovery.RecipeCatalog.find_recipe(RECIPE_ID)
	if recipe == null:
		_fail("The atomic crafting test recipe is missing.")
		return
	var status: Dictionary = crafting_service.get_recipe_status(recipe)
	if status["reason"] != &"recipe_sealed":
		_fail("A Stage V recipe was craftable before its milestone discovery.")
		return
	story_state.record_discovery(&"forest_core_gear_crafting")
	story_state.grant_key_item(&"forest_core_gear_seal")
	status = crafting_service.get_recipe_status(recipe)
	if status["reason"] != &"missing_materials":
		_fail("An unlocked recipe did not report its missing materials.")
		return
	var seeded_quantities := {}
	var expected_remaining := {}
	for ingredient: MaterialStackDefinition in recipe.ingredients:
		seeded_quantities[ingredient.material.material_id] = ingredient.quantity + 2
		expected_remaining[ingredient.material.material_id] = 2
	if not material_inventory.add_material_batch(seeded_quantities):
		_fail("Could not seed exact crafting ingredients.")
		return
	root.get_node("RunSession").update_progression(0, recipe.gold_cost + 50)
	status = crafting_service.get_recipe_status(recipe)
	if not status["success"]:
		_fail("A discovered, sealed, fully funded recipe was not ready to craft.")
		return
	var result: Dictionary = crafting_service.try_craft(recipe)
	if not result["success"] or not gear_inventory.owns_item(recipe.output_id):
		_fail("Atomic crafting did not grant the authored equipment output.")
		return
	if root.get_node("RunSession").coins != 50:
		_fail("Atomic crafting did not spend the authored gold fee exactly once.")
		return
	for raw_material_id: Variant in expected_remaining:
		var material_id := StringName(String(raw_material_id))
		if material_inventory.get_quantity(material_id) != int(expected_remaining[raw_material_id]):
			_fail("Atomic crafting did not spend an ingredient exactly once: %s" % material_id)
			return
	var material_after_first_craft: Dictionary = material_inventory.create_snapshot()
	var duplicate_result: Dictionary = crafting_service.try_craft(recipe)
	if (
		duplicate_result["reason"] != &"already_owned"
		or material_inventory.create_snapshot() != material_after_first_craft
	):
		_fail("A duplicate craft consumed materials or bypassed unique ownership.")
		return
	if not save_service.has_valid_profile():
		_fail("A successful craft did not commit the safe-point profile.")
		return
	gear_inventory.reset_inventory()
	material_inventory.reset_inventory()
	if save_service.load_profile().is_empty() or not gear_inventory.owns_item(recipe.output_id):
		_fail("The crafted output did not survive profile restoration.")
		return
	for raw_material_id: Variant in expected_remaining:
		var material_id := StringName(String(raw_material_id))
		if material_inventory.get_quantity(material_id) != int(expected_remaining[raw_material_id]):
			_fail("Restored crafting ingredients do not match the committed transaction.")
			return
	save_service.delete_profile()
	save_service.reset_storage_path_after_testing()
	print("Atomic crafting service smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	var save_service := root.get_node_or_null("SaveService")
	if save_service != null:
		save_service.delete_profile()
		save_service.reset_storage_path_after_testing()
	push_error(message)
	quit(1)
