class_name RecipeDefinition
extends Resource

## One deterministic crafting result and its exact material costs.

enum OutputKind {
	EQUIPMENT,
	MATERIAL,
}

enum CraftingCategory {
	ARMOR,
	WEAPON,
	ACCESSORY,
	COMPONENT,
	CONSUMABLE,
}

@export var recipe_id: StringName
@export var display_name := ""
@export_multiline var description := ""
@export var region_id: StringName
@export_range(1, 99, 1) var tier := 1
@export var category := CraftingCategory.COMPONENT
@export var output_kind := OutputKind.EQUIPMENT
@export var output_id: StringName
@export_range(1, 999999, 1) var output_quantity := 1
@export var ingredients: Array[MaterialStackDefinition] = []
@export var unlock_id: StringName
@export_range(0, 999999, 1) var gold_cost := 0


func is_valid() -> bool:
	if (
		recipe_id.is_empty()
		or display_name.strip_edges().is_empty()
		or description.strip_edges().is_empty()
		or region_id.is_empty()
		or tier <= 0
		or category < CraftingCategory.ARMOR
		or category > CraftingCategory.CONSUMABLE
		or output_kind < OutputKind.EQUIPMENT
		or output_kind > OutputKind.MATERIAL
		or output_id.is_empty()
		or output_quantity <= 0
		or ingredients.is_empty()
		or unlock_id.is_empty()
	):
		return false
	var seen_material_ids := {}
	for ingredient: MaterialStackDefinition in ingredients:
		if (
			ingredient == null
			or not ingredient.is_valid()
			or seen_material_ids.has(ingredient.material.material_id)
		):
			return false
		if (
			output_kind == OutputKind.MATERIAL
			and ingredient.material.material_id == output_id
		):
			return false
		seen_material_ids[ingredient.material.material_id] = true
	return true
