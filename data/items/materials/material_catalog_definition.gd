class_name MaterialCatalogDefinition
extends Resource

## Stable lookup boundary for every material accepted by MaterialInventory.

@export var materials: Array[MaterialDefinition] = []


func has_valid_layout() -> bool:
	var seen_ids := {}
	for material: MaterialDefinition in materials:
		if material == null or not material.is_valid() or seen_ids.has(material.material_id):
			return false
		seen_ids[material.material_id] = true
	return not materials.is_empty()


func find_material(material_id: StringName) -> MaterialDefinition:
	for material: MaterialDefinition in materials:
		if material != null and material.material_id == material_id:
			return material
	return null


func has_material(material_id: StringName) -> bool:
	return find_material(material_id) != null
