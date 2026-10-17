extends Node

## Atomic crafting authority. Immutable recipes describe costs and output;
## inventories own mutation; SaveService owns durable commit.

signal craft_completed(recipe_id: StringName, output_id: StringName)
signal craft_failed(recipe_id: StringName, reason: StringName)
var transaction_active := false

const Stage5CoreEquipment: EquipmentCatalogDefinition = preload(
	"res://data/items/equipment/forest/stage_5_core_catalog.tres"
)


func get_recipe_status(recipe: RecipeDefinition) -> Dictionary:
	if not _is_authored_recipe(recipe):
		return _failure(&"invalid_recipe", "INVALID RECIPE")
	if not is_recipe_unlocked(recipe):
		return _failure(&"recipe_sealed", "BLUEPRINT SEALED")
	if recipe.requires_sanctuary_station and not _at_sanctuary_forge():
		return _failure(&"station_required", "VISIT NEMA'S SANCTUARY FORGE")
	if not _has_required_seal(recipe):
		return _failure(&"seal_missing", _required_seal_text(recipe))
	var output := resolve_output(recipe)
	if output == null or recipe.output_kind != RecipeDefinition.OutputKind.EQUIPMENT:
		return _failure(&"unsupported_output", "OUTPUT NOT SUPPORTED")
	if _owns_output(output):
		return _failure(&"already_owned", "ALREADY OWNED")
	var costs := _ingredient_costs(recipe)
	if not MaterialInventory.can_remove_material_batch(costs):
		return _failure(&"missing_materials", "MISSING MATERIALS")
	if not RunSession.can_spend_coins(recipe.gold_cost):
		return _failure(&"missing_gold", "GOLD %d / %d" % [RunSession.coins, recipe.gold_cost])
	return {
		"success": true,
		"reason": &"ready",
		"message": "READY TO CRAFT",
		"output": output,
		"costs": costs,
		"gold_cost": recipe.gold_cost,
	}


func try_craft(recipe: RecipeDefinition) -> Dictionary:
	if transaction_active: return _failure(&"busy","FORGE BUSY")
	var status := get_recipe_status(recipe)
	if not status["success"]:
		craft_failed.emit(recipe.recipe_id if recipe != null else &"", status["reason"])
		return status
	var output := status["output"] as EquipmentDefinition
	var costs: Dictionary = status["costs"]
	var material_snapshot := MaterialInventory.create_snapshot()
	var run_snapshot := RunSession.create_snapshot()
	var output_inventory: Node = WeaponInventory if output.slot == EquipmentDefinition.Slot.WEAPON else GearInventory
	var output_snapshot: Dictionary = output_inventory.create_snapshot()
	transaction_active = true
	if not _acquire_output(output):
		transaction_active = false
		var failed := _failure(&"output_failed", "COULD NOT GRANT OUTPUT")
		craft_failed.emit(recipe.recipe_id, failed["reason"])
		return failed
	if not MaterialInventory.remove_material_batch(costs):
		output_inventory.restore_snapshot(output_snapshot)
		transaction_active = false
		var failed := _failure(&"material_spend_failed", "MATERIAL SPEND FAILED")
		craft_failed.emit(recipe.recipe_id, failed["reason"])
		return failed
	if recipe.gold_cost > 0 and not RunSession.spend_coins(recipe.gold_cost):
		MaterialInventory.restore_snapshot(material_snapshot)
		output_inventory.restore_snapshot(output_snapshot)
		transaction_active = false
		var failed := _failure(&"gold_spend_failed", "GOLD SPEND FAILED")
		craft_failed.emit(recipe.recipe_id, failed["reason"])
		return failed
	if not SaveService.save_profile():
		MaterialInventory.restore_snapshot(material_snapshot)
		output_inventory.restore_snapshot(output_snapshot)
		RunSession.restore_snapshot(run_snapshot)
		transaction_active = false
		var failed := _failure(&"save_failed", "CRAFT FAILED TO SAVE")
		craft_failed.emit(recipe.recipe_id, failed["reason"])
		return failed
	transaction_active = false
	craft_completed.emit(recipe.recipe_id, output.item_id)
	return {
		"success": true,
		"reason": &"crafted",
		"message": "CRAFTED %s • SAVED" % output.display_name.to_upper(),
		"output": output,
	}


func _is_authored_recipe(recipe: RecipeDefinition) -> bool:
	return (
		recipe != null
		and recipe.is_valid()
		and RecipeDiscovery.RecipeCatalog.find_recipe(recipe.recipe_id) == recipe
		and recipe.output_quantity == 1
	)


func is_recipe_unlocked(recipe: RecipeDefinition) -> bool:
	if recipe.unlock_id == &"axe_cyclone_proof":
		return get_node("/root/WeaponTraining").has_technique(&"axe_war_cyclone")
	return (
		RecipeDiscovery.is_recipe_discovered(recipe.recipe_id)
		or StoryState.has_discovery(recipe.unlock_id)
	)


func _has_required_seal(recipe: RecipeDefinition) -> bool:
	if recipe.unlock_id == &"axe_cyclone_proof": return is_recipe_unlocked(recipe)
	if recipe.unlock_id == &"forest_core_gear_crafting":
		return StoryState.has_key_item(&"forest_core_gear_seal")
	return false


func _required_seal_text(recipe: RecipeDefinition) -> String:
	if recipe.unlock_id == &"axe_cyclone_proof": return "COMPLETE VEYR'S AXE LESSON"
	if recipe.category == RecipeDefinition.CraftingCategory.ACCESSORY:
		return "STAGE VIII ACCESSORY SEAL REQUIRED"
	return "STAGE V CORE GEAR SEAL REQUIRED"

func resolve_output(recipe: RecipeDefinition) -> EquipmentDefinition:
	if recipe == null: return null
	var output := Stage5CoreEquipment.find_item(recipe.output_id)
	return output if output != null else WeaponInventory.KingCatalog.find_weapon(recipe.output_id)

func _at_sanctuary_forge() -> bool:
	var scene := get_tree().current_scene
	if scene == null or scene.scene_file_path != "res://levels/sanctuary/sanctuary.tscn": return false
	var actor := scene.get_node_or_null("World/Actors/Player") as Node2D
	var forge := scene.get_node_or_null("World/Actors/Rootweaver") as Node2D
	return actor != null and forge != null and not actor.get_meta(&"weapon_lesson_active",false) and actor.global_position.distance_to(forge.global_position) <= 72


func _ingredient_costs(recipe: RecipeDefinition) -> Dictionary:
	var costs := {}
	for ingredient: MaterialStackDefinition in recipe.ingredients:
		costs[ingredient.material.material_id] = ingredient.quantity
	return costs


func _owns_output(output: EquipmentDefinition) -> bool:
	if output.slot == EquipmentDefinition.Slot.WEAPON:
		return WeaponInventory.owns_weapon(output.item_id)
	return GearInventory.owns_item(output.item_id)


func _acquire_output(output: EquipmentDefinition) -> bool:
	if output.slot == EquipmentDefinition.Slot.WEAPON:
		return WeaponInventory.acquire_weapon(output)
	return GearInventory.acquire_item(output)


func _failure(reason: StringName, message: String) -> Dictionary:
	return {"success": false, "reason": reason, "message": message}
