extends SceneTree

const TEST_PROFILE_PATH := "user://material_exchange_service_smoke_profile.json"
const MaterialCatalog: MaterialCatalogDefinition = preload("res://data/items/materials/material_catalog.tres")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var save_service := root.get_node("SaveService")
	var inventory := root.get_node("MaterialInventory")
	var memory := root.get_node("EnemyMemory")
	var exchange := root.get_node("MaterialExchangeService")
	var session := root.get_node("RunSession")
	save_service.configure_storage_path_for_testing(TEST_PROFILE_PATH)
	save_service.delete_profile()
	inventory.reset_inventory()
	memory.reset_memory()
	session.reset_run()
	root.get_node("StoryState").reset_story()
	root.get_node("WeaponInventory").reset_inventory()
	root.get_node("GearInventory").reset_inventory()
	root.get_node("RecipeDiscovery").reset_discoveries()
	root.get_node("LootState").reset_state()

	var resin := MaterialCatalog.find_material(&"forest_mire_resin")
	var fiber := MaterialCatalog.find_material(&"forest_root_fiber")
	var uncommon := MaterialCatalog.find_material(&"forest_living_bark_plate")
	var rare := MaterialCatalog.find_material(&"forest_husk_heartwood")
	var boss_core := MaterialCatalog.find_material(&"forest_rootbound_core")
	if resin == null or fiber == null or uncommon == null or rare == null or boss_core == null:
		_fail("Exchange fixtures are missing.")
		return
	if exchange.get_transmutation_status(resin, {fiber.material_id: 25})["reason"] != &"invalid_target":
		_fail("A Common material appeared as a reconstruction target.")
		return
	if exchange.get_transmutation_status(uncommon, {fiber.material_id: 100})["reason"] != &"memory_locked":
		_fail("An unseen material source bypassed defeat memory.")
		return
	for _index in 10:
		memory.record_defeat(&"armored_hog")
	inventory.add_material(fiber.material_id, 100)
	inventory.add_material(resin.material_id, 1)
	session.update_progression(0, 100)
	var uncommon_result: Dictionary = exchange.try_transmute(uncommon, {fiber.material_id: 100})
	if not uncommon_result["success"] or inventory.get_quantity(uncommon.material_id) != 1 or session.coins != 25:
		_fail("Uncommon reconstruction did not atomically spend meld and gold.")
		return
	var sale_result: Dictionary = exchange.try_sell(resin, 1)
	if not sale_result["success"] or inventory.get_quantity(resin.material_id) != 0 or session.coins != 26:
		_fail("Material selling did not atomically grant the metadata-owned gold value.")
		return
	if (
		not inventory.add_material(
			uncommon.material_id,
			inventory.MAX_MATERIAL_QUANTITY - 1
		)
		or exchange.get_transmutation_status(uncommon, {fiber.material_id: 1})["reason"]
			!= &"stack_full"
	):
		_fail("Umi allowed reconstruction spending against a full output stack.")
		return
	inventory.remove_material(uncommon.material_id, inventory.MAX_MATERIAL_QUANTITY)

	for _index in 10:
		memory.record_defeat(&"rootbound_husk")
	inventory.add_material(rare.material_id, 4)
	inventory.add_material(fiber.material_id, 1360)
	session.update_progression(0, 1000)
	var boss_fuel := {rare.material_id: 4, fiber.material_id: 1360}
	var boss_result: Dictionary = exchange.try_transmute(boss_core, boss_fuel)
	if not boss_result["success"] or inventory.get_quantity(boss_core.material_id) != 1:
		_fail("Protected boss reconstruction rejected a valid victory charge and rare catalyst.")
		return
	if memory.get_available_memory_charges(&"rootbound_husk") != 0:
		_fail("Boss reconstruction did not consume exactly one earned memory charge.")
		return
	if exchange.get_sell_status(boss_core, 1)["reason"] != &"protected_material":
		_fail("A boss material became sellable.")
		return
	if not save_service.has_valid_profile():
		_fail("Exchange transaction did not commit a compatible safe profile.")
		return
	save_service.delete_profile()
	save_service.reset_storage_path_after_testing()
	print("Metadata-driven material exchange service smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	var save_service := root.get_node_or_null("SaveService")
	if save_service != null:
		save_service.delete_profile()
		save_service.reset_storage_path_after_testing()
	push_error(message)
	quit(1)
