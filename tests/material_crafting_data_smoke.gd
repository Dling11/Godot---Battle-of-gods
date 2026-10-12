extends SceneTree

const ForestMaterials: MaterialCatalogDefinition = preload(
	"res://data/items/materials/material_catalog.tres"
)
const ForestRecipes: RecipeCatalogDefinition = preload(
	"res://data/crafting/recipes/recipe_catalog.tres"
)
const Stage5CoreEquipment: EquipmentCatalogDefinition = preload(
	"res://data/items/equipment/forest/stage_5_core_catalog.tres"
)


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if not ForestMaterials.has_valid_layout() or ForestMaterials.materials.size() != 15:
		_fail("The Forest material catalog did not expose fifteen valid stable definitions.")
		return
	if not ForestRecipes.has_valid_layout() or ForestRecipes.recipes.size() != 8:
		_fail("The Forest recipe catalog did not expose six Stage V and two future accessory recipes.")
		return
	if not Stage5CoreEquipment.has_valid_layout() or Stage5CoreEquipment.items.size() != 6:
		_fail("The Stage V core-equipment catalog did not expose six valid unique-slot outputs.")
		return
	var expected_core_slots := [
		EquipmentDefinition.Slot.WEAPON,
		EquipmentDefinition.Slot.HEAD,
		EquipmentDefinition.Slot.PLATE,
		EquipmentDefinition.Slot.GLOVES,
		EquipmentDefinition.Slot.LEGGINGS,
		EquipmentDefinition.Slot.BOOTS,
	]
	for slot: int in expected_core_slots:
		var item := Stage5CoreEquipment.find_slot(slot)
		if item == null or item.icon.get_size() != Vector2(64, 64):
			_fail("A Stage V core slot is missing its valid 64x64 item definition.")
			return
		var image := item.icon.get_image()
		for y in image.get_height():
			for x in image.get_width():
				var alpha := image.get_pixel(x, y).a
				if alpha > 0.001 and alpha < 0.999:
					_fail("A Stage V core icon contains soft alpha.")
					return
	var plate := Stage5CoreEquipment.find_slot(EquipmentDefinition.Slot.PLATE)
	var head := Stage5CoreEquipment.find_slot(EquipmentDefinition.Slot.HEAD)
	var gloves := Stage5CoreEquipment.find_slot(EquipmentDefinition.Slot.GLOVES)
	var leggings := Stage5CoreEquipment.find_slot(EquipmentDefinition.Slot.LEGGINGS)
	var boots := Stage5CoreEquipment.find_slot(EquipmentDefinition.Slot.BOOTS)
	if (
		plate.flat_health_bonus != 0.0
		or plate.armor_bonus != 30.0
		or head.flat_health_bonus != 50.0
		or head.regeneration_bonus != 2.0
		or head.armor_bonus != 0.0
		or head.ward_reduction_ratio != 0.0
		or gloves.attack_speed_bonus_ratio != 0.15
		or leggings.flat_health_bonus != 90.0
		or leggings.armor_bonus != 0.0
		or boots.movement_speed_bonus_ratio != 0.15
	):
		_fail("The Stage V slot-focused armor stat budget drifted from its approved values.")
		return
	var plate_bounds := plate.icon.get_image().get_used_rect()
	var helm_bounds := head.icon.get_image().get_used_rect()
	if plate_bounds.size.x <= helm_bounds.size.x + 10 or helm_bounds.size.y <= helm_bounds.size.x:
		_fail("The regenerated Plate and Helm silhouettes are not immediately distinguishable.")
		return
	var stage5_recipe_count := 0
	var accessory_recipe_count := 0
	var total_varkuun_cores := 0
	var total_stage5_gold := 0
	for recipe: RecipeDefinition in ForestRecipes.recipes:
		if recipe.unlock_id == &"forest_core_gear_crafting":
			stage5_recipe_count += 1
			if Stage5CoreEquipment.find_item(recipe.output_id) == null:
				_fail("A Stage V recipe output is absent from the core-equipment catalog.")
				return
			for ingredient: MaterialStackDefinition in recipe.ingredients:
				if ingredient.material.material_id == &"forest_varkuun_core":
					total_varkuun_cores += ingredient.quantity
			total_stage5_gold += recipe.gold_cost
		elif recipe.category == RecipeDefinition.CraftingCategory.ACCESSORY:
			accessory_recipe_count += 1
	if stage5_recipe_count != 6 or accessory_recipe_count != 2 or total_varkuun_cores != 5 or total_stage5_gold != 1800:
		_fail("Stage V recipe count, future accessory count, or five-core full-set budget is invalid.")
		return

	var material_ids := {}
	for material: MaterialDefinition in ForestMaterials.materials:
		if material_ids.has(material.material_id):
			_fail("The Forest material catalog contains a duplicate stable ID.")
			return
		if (
			material.icon == null
			or material.icon.get_width() != 24
			or material.icon.get_height() != 24
		):
			_fail("%s is missing its approved 24x24 icon." % material.display_name)
			return
		if material.source_enemy_id.is_empty() or material.get_transmutation_point_cost() <= 0 or material.get_transmutation_gold_cost() < 0:
			_fail("%s is missing automatic Umi exchange metadata." % material.display_name)
			return
		if material.rarity == MaterialDefinition.MaterialRarity.BOSS and (material.get_sell_value() != 0 or material.get_meld_value() != 0):
			_fail("Boss material protection drifted from Umi's exchange rules.")
			return
		if material.rarity == MaterialDefinition.MaterialRarity.COMMON and (material.get_sell_value() != 1 or material.get_meld_value() != 1):
			_fail("Common material automatic sell or meld defaults drifted.")
			return
		material_ids[material.material_id] = true
	for expected_id: StringName in [
		&"forest_mire_resin",
		&"forest_mire_membrane",
		&"forest_root_fiber",
		&"forest_young_heartwood",
		&"forest_forsaken_cloth",
		&"forest_weathered_fittings",
		&"forest_barbed_seed",
		&"forest_thorn_sap",
		&"forest_husk_heartwood",
		&"forest_rootbound_core",
		&"forest_armored_hog_hide",
		&"forest_living_bark_plate",
		&"forest_varkuun_core",
		&"forest_crag_iron",
		&"forest_echo_claw",
	]:
		if not material_ids.has(expected_id):
			_fail("The Forest material catalog omitted %s." % expected_id)
			return

	var profile_ids := {}
	var enemy_ids := {}
	var drop_profiles: Array[DropProfileDefinition] = [
		preload("res://data/loot/forest/enemies/mireling_drop_profile.tres"),
		preload("res://data/loot/forest/enemies/rootling_drop_profile.tres"),
		preload("res://data/loot/forest/enemies/forsaken_thrall_drop_profile.tres"),
		preload("res://data/loot/forest/enemies/bramble_spitter_drop_profile.tres"),
		preload("res://data/loot/forest/enemies/rootbound_husk_drop_profile.tres"),
		preload("res://data/loot/forest/enemies/armored_hog_drop_profile.tres"),
		preload("res://data/loot/forest/enemies/crag_bear_drop_profile.tres"),
	]
	for profile: DropProfileDefinition in drop_profiles:
		if (
			not profile.has_valid_layout()
			or profile_ids.has(profile.profile_id)
			or enemy_ids.has(profile.source_enemy_id)
		):
			_fail("An enemy drop profile is invalid or duplicates a stable ID.")
			return
		profile_ids[profile.profile_id] = true
		enemy_ids[profile.source_enemy_id] = true
	var husk_profile: DropProfileDefinition = drop_profiles[4]
	var husk_guarantee_ids := {}
	for entry: MaterialDropEntryDefinition in husk_profile.boss_guarantees:
		husk_guarantee_ids[entry.material.material_id] = true
	if (
		not husk_profile.is_boss_profile
		or husk_profile.boss_guarantees.size() != 2
		or not husk_guarantee_ids.has(&"forest_husk_heartwood")
		or not husk_guarantee_ids.has(&"forest_rootbound_core")
	):
		_fail("The Rootbound Husk does not guarantee both authored boss materials.")
		return

	var loot_table_ids := {}
	var stage_ids := {}
	var loot_tables: Array[LootTableDefinition] = [
		preload("res://data/loot/forest/stages/stage_3_loot_table.tres"),
	]
	for loot_table: LootTableDefinition in loot_tables:
		if (
			not loot_table.has_valid_layout()
			or loot_table_ids.has(loot_table.loot_table_id)
			or stage_ids.has(loot_table.stage_id)
		):
			_fail("A stage loot table is invalid or duplicates a stable ID.")
			return
		loot_table_ids[loot_table.loot_table_id] = true
		stage_ids[loot_table.stage_id] = true
		for raw_recipe_id: String in loot_table.first_clear_recipe_ids:
			if not ForestRecipes.has_recipe(StringName(raw_recipe_id)):
				_fail("A stage loot table references an unknown recipe ID.")
				return
	if not loot_tables[0].first_clear_recipe_ids.is_empty():
		_fail("Stage 3's material-payout Reliquary must not unlock crafting recipes.")
		return

	var duplicate_material_catalog := MaterialCatalogDefinition.new()
	duplicate_material_catalog.materials.append(ForestMaterials.materials[0])
	duplicate_material_catalog.materials.append(ForestMaterials.materials[0])
	if duplicate_material_catalog.has_valid_layout():
		_fail("Material catalog validation accepted a duplicate stable ID.")
		return

	var invalid_stack := MaterialStackDefinition.new()
	invalid_stack.material = ForestMaterials.materials[0]
	invalid_stack.quantity = 0
	if invalid_stack.is_valid():
		_fail("Material stack validation accepted a zero quantity.")
		return

	var invalid_recipe := ForestRecipes.recipes[0].duplicate(true) as RecipeDefinition
	invalid_recipe.ingredients.append(invalid_recipe.ingredients[0])
	if invalid_recipe.is_valid():
		_fail("Recipe validation accepted a duplicate material cost.")
		return

	var duplicate_recipe_catalog := RecipeCatalogDefinition.new()
	duplicate_recipe_catalog.recipes.append(ForestRecipes.recipes[0])
	duplicate_recipe_catalog.recipes.append(ForestRecipes.recipes[0])
	if duplicate_recipe_catalog.has_valid_layout():
		_fail("Recipe catalog validation accepted a duplicate stable ID.")
		return

	print("Material and crafting data smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
