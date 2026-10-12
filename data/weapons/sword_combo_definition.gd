class_name SwordComboDefinition
extends Resource

## One immutable, character-authored chain. The attack component owns progress.
@export var animation_keys := PackedStringArray(["attack", "return_cut", "heavy_cleave"])
@export var windups := PackedFloat32Array([0.19, 0.15, 0.26])
@export var contacts := PackedFloat32Array([0.12, 0.12, 0.14])
@export var recoveries := PackedFloat32Array([0.30, 0.27, 0.36])
@export var damage_multipliers := PackedFloat32Array([1.0, 1.15, 1.65])
@export var knockback_multipliers := PackedFloat32Array([1.0, 1.15, 2.0])
@export var continue_seconds := 0.9
## Optional contact geometry per cut; empty entries retain the weapon default.
@export var hitbox_shapes: Array[Shape2D] = []
## Radial steps push each accepted target away from the wielder.
@export var radial_steps := PackedByteArray()

func hitbox_shape(step: int, fallback: Shape2D) -> Shape2D:
	return hitbox_shapes[step] if step>=0 and step<hitbox_shapes.size() and hitbox_shapes[step]!=null else fallback

func is_radial(step: int) -> bool:
	return step>=0 and step<radial_steps.size() and radial_steps[step]!=0

func step_count() -> int:
	return mini(animation_keys.size(), mini(windups.size(), mini(contacts.size(), mini(recoveries.size(), mini(damage_multipliers.size(), knockback_multipliers.size())))))
