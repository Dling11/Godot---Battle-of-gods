class_name RecipeCatalogDefinition
extends Resource

## Stable lookup and duplicate-ID validation for authored recipes.

@export var recipes: Array[RecipeDefinition] = []


func has_valid_layout() -> bool:
	var seen_ids := {}
	for recipe: RecipeDefinition in recipes:
		if recipe == null or not recipe.is_valid() or seen_ids.has(recipe.recipe_id):
			return false
		seen_ids[recipe.recipe_id] = true
	return not recipes.is_empty()


func find_recipe(recipe_id: StringName) -> RecipeDefinition:
	for recipe: RecipeDefinition in recipes:
		if recipe != null and recipe.recipe_id == recipe_id:
			return recipe
	return null


func has_recipe(recipe_id: StringName) -> bool:
	return find_recipe(recipe_id) != null
