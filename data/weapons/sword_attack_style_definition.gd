class_name SwordAttackStyleDefinition
extends Resource

## Immutable presentation tuning for a sword's detached swing. Authoritative
## timing, damage, knockback, and hitboxes remain on WeaponDefinition/combat.

@export var style_id: StringName = &"balanced_slash"
@export var display_name: String = "Balanced Slash"
@export_range(0.1, 3.0, 0.01, "suffix:rad") var normal_wind_up_arc: float = 1.68
@export_range(0.1, 3.0, 0.01, "suffix:rad") var normal_strike_arc: float = 1.36
@export_range(0.0, 8.0, 0.25, "suffix:px") var normal_active_extension: float = 1.0
## Normal attacks cycle through these presentation variants. A direction of -1
## reverses the visible sweep; multipliers and extension offsets shape its
## weight without changing authoritative timing, reach, or damage.
@export var normal_swing_directions := PackedInt32Array([1, -1, 1])
@export var normal_wind_up_multipliers := PackedFloat32Array([1.0, 0.88, 0.98])
@export var normal_strike_multipliers := PackedFloat32Array([1.0, 0.94, 1.05])
@export var normal_extension_offsets := PackedFloat32Array([0.0, 0.5, 2.0])
@export_range(0.1, 3.0, 0.01, "suffix:rad") var ability_wind_up_arc: float = 1.82
@export_range(0.1, 3.0, 0.01, "suffix:rad") var ability_strike_arc: float = 1.48
@export_range(0.0, 12.0, 0.25, "suffix:px") var ability_active_extension: float = 3.0
@export_range(5, 21, 1) var trail_point_count: int = 13
@export_range(1.0, 8.0, 0.25, "suffix:px") var trail_width: float = 4.0
@export var trail_color := Color(1.0, 0.96, 0.82, 1.0)
@export_range(0.0, 0.3, 0.01, "suffix:s") var trail_fade_padding_seconds: float = 0.06
@export_range(1.0, 1.5, 0.01) var strike_scale_multiplier: float = 1.12
@export var strike_tint := Color(1.24, 1.12, 0.82, 1.0)


func is_valid_style() -> bool:
	return (
		not style_id.is_empty()
		and normal_wind_up_arc > 0.0
		and normal_strike_arc > 0.0
		and ability_wind_up_arc > 0.0
		and ability_strike_arc > 0.0
		and trail_point_count >= 5
		and trail_width > 0.0
		and strike_scale_multiplier >= 1.0
		and _has_valid_normal_variants()
	)


func normal_variant_count() -> int:
	return normal_swing_directions.size()


func normal_variant_direction(variant_index: int) -> float:
	return float(normal_swing_directions[_normalized_variant_index(variant_index)])


func normal_variant_wind_up_arc(variant_index: int) -> float:
	return normal_wind_up_arc * normal_wind_up_multipliers[_normalized_variant_index(variant_index)]


func normal_variant_strike_arc(variant_index: int) -> float:
	return normal_strike_arc * normal_strike_multipliers[_normalized_variant_index(variant_index)]


func normal_variant_active_extension(variant_index: int) -> float:
	return normal_active_extension + normal_extension_offsets[_normalized_variant_index(variant_index)]


func _normalized_variant_index(variant_index: int) -> int:
	return posmod(variant_index, maxi(normal_variant_count(), 1))


func _has_valid_normal_variants() -> bool:
	var count := normal_variant_count()
	if (
		count == 0
		or normal_wind_up_multipliers.size() != count
		or normal_strike_multipliers.size() != count
		or normal_extension_offsets.size() != count
	):
		return false
	for variant_index in count:
		if (
			absi(normal_swing_directions[variant_index]) != 1
			or normal_wind_up_multipliers[variant_index] <= 0.0
			or normal_strike_multipliers[variant_index] <= 0.0
			or normal_extension_offsets[variant_index] < 0.0
		):
			return false
	return true
