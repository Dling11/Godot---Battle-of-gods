class_name MaterialDropEntryDefinition
extends Resource

## One data-only material roll. Runtime loot authority is added in Segment 3.

@export var material: MaterialDefinition
@export_range(1, 999999, 1) var minimum_quantity := 1
@export_range(1, 999999, 1) var maximum_quantity := 1
@export_range(0.0, 1.0, 0.01) var chance := 1.0
@export var bad_luck_protection_key: StringName
@export_range(0, 999, 1) var guaranteed_after_misses := 0


func is_valid() -> bool:
	if (
		material == null
		or not material.is_valid()
		or minimum_quantity <= 0
		or maximum_quantity < minimum_quantity
		or chance <= 0.0
		or chance > 1.0
	):
		return false
	var has_protection_key := not bad_luck_protection_key.is_empty()
	return has_protection_key == (guaranteed_after_misses > 0)


func is_guaranteed() -> bool:
	return is_equal_approx(chance, 1.0)
