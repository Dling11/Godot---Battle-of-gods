class_name MaterialStackDefinition
extends Resource

## Exact immutable material quantity used by recipes and guaranteed rewards.

@export var material: MaterialDefinition
@export_range(1, 999999, 1) var quantity := 1


func is_valid() -> bool:
	return material != null and material.is_valid() and quantity > 0
