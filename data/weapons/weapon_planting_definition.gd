extends Resource

## Shared stance geometry. Weapon tip/grip remain on the individual weapon clip.
@export var ground_anchor := Vector2(74,96)
@export_range(0,24) var burial_depth_pixels := 10.0
@export_range(0,32) var preparation_clearance_pixels := 12.0
@export_range(0,6) var preparation_pose := 4
@export_range(1,7) var release_pose := 5

func is_valid(cell_size: Vector2i) -> bool:
	return ground_anchor.is_finite() and Rect2(Vector2.ZERO,Vector2(cell_size)).has_point(ground_anchor) and is_finite(burial_depth_pixels) and burial_depth_pixels>=0 and burial_depth_pixels<=24 and is_finite(preparation_clearance_pixels) and preparation_clearance_pixels>=0 and preparation_clearance_pixels<=32 and preparation_pose>=0 and release_pose==preparation_pose+1 and release_pose<=7
