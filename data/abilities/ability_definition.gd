class_name AbilityDefinition
extends Resource

## Immutable tuning shared by ability runtime instances.

enum ActivationMode { IMMEDIATE_DIRECTIONAL, GROUND_TARGETED, SELF_AREA, DIRECTIONAL_WEDGE_TARGETED }
enum PresentationStyle { SWEEP, THRUST, ECHOING_SEVER }
enum ImpactWeight { LIGHT, MEDIUM, HEAVY, DEVASTATING }

@export var ability_id: StringName
@export var display_name := "Ability"
@export var hud_name := "ABILITY"
@export_multiline var description := ""
@export var icon: Texture2D
@export var activation_mode := ActivationMode.IMMEDIATE_DIRECTIONAL
@export var presentation_style := PresentationStyle.SWEEP
@export var impact_weight := ImpactWeight.MEDIUM
@export var damage_type := DamageInfo.DamageType.PHYSICAL
@export var hitbox_shape: Shape2D
@export_range(0.0, 9999.0, 1.0) var damage := 0.0
@export_range(0.0, 10.0, 0.05) var weapon_damage_multiplier := 0.0
@export_range(0.0, 500.0, 1.0, "suffix:px/s") var knockback_strength := 0.0
@export var strike_damage_multipliers := PackedFloat32Array([1.0])
@export_range(0.0, 1.0, 0.05) var non_final_knockback_multiplier := 1.0
@export_range(0.0, 3.0, 0.01, "suffix:s") var stagger_seconds := 0.0
## Opt-in stun for designated skills/heavy contacts. Zero means flinch only.
@export_range(0.0, 3.0, 0.01, "suffix:s") var stun_seconds := 0.0
@export var stun_on_final_strike_only := true
@export_range(0.0, 1.0, 0.05) var non_final_stagger_multiplier := 1.0
@export_range(0.0, 1000.0, 1.0, "suffix:px/s") var active_movement_speed := 0.0
@export_range(0.0, 2.0, 0.01, "suffix:s") var wind_up_seconds := 0.1
@export_range(0.01, 2.0, 0.01, "suffix:s") var active_seconds := 0.1
@export_range(0.0, 3.0, 0.01, "suffix:s") var recovery_seconds := 0.2
@export_range(0.0, 30.0, 0.1, "suffix:s") var cooldown_seconds := 1.0
@export var grants_invulnerability := false
## Super armor preserves the cast when accepted damage carries stagger. Damage,
## flash, audio, and hit-pause still resolve normally.
@export var grants_super_armor := false
@export var dash_cancelable := false


func get_damage_type_label() -> String:
	return DamageInfo.type_name(damage_type)+" DAMAGE" if damage > 0.0 or weapon_damage_multiplier > 0.0 else "SELF BUFF"


func get_description_with_damage_type() -> String:
	return get_damage_type_label()+"\n"+description


func resolve_damage(equipped_weapon_damage: float) -> float:
	return maxf(damage + equipped_weapon_damage * weapon_damage_multiplier, 0.0)


func strike_count() -> int:
	return maxi(strike_damage_multipliers.size(), 1)


func resolve_strike_damage(equipped_weapon_damage: float, strike_index: int) -> float:
	var multiplier := 1.0
	if not strike_damage_multipliers.is_empty():
		multiplier = strike_damage_multipliers[clampi(strike_index, 0, strike_damage_multipliers.size() - 1)]
	return resolve_damage(equipped_weapon_damage) * maxf(multiplier, 0.0)


func resolve_strike_knockback(strike_index: int) -> float:
	if strike_index >= strike_count() - 1:
		return knockback_strength
	return knockback_strength * non_final_knockback_multiplier


func resolve_strike_stagger(strike_index: int) -> float:
	if strike_index >= strike_count() - 1:
		return stagger_seconds
	return stagger_seconds * non_final_stagger_multiplier


func resolve_strike_stun(strike_index: int) -> float:
	if stun_on_final_strike_only and strike_index < strike_count() - 1:
		return 0.0
	return stun_seconds


## Returns the forward tip of a convex thrust lane in local gameplay pixels.
## Other shape styles may return zero because they do not share this contract.
func get_forward_lance_reach_pixels() -> float:
	var polygon := hitbox_shape as ConvexPolygonShape2D
	if polygon == null or presentation_style != PresentationStyle.THRUST:
		return 0.0
	var reach_pixels := 0.0
	for point in polygon.points:
		reach_pixels = maxf(reach_pixels, point.x)
	return reach_pixels


## Returns the widest half-width of a convex thrust lane in gameplay pixels.
func get_forward_lance_half_width_pixels() -> float:
	var polygon := hitbox_shape as ConvexPolygonShape2D
	if polygon == null or presentation_style != PresentationStyle.THRUST:
		return 0.0
	var half_width_pixels := 0.0
	for point in polygon.points:
		half_width_pixels = maxf(half_width_pixels, absf(point.y))
	return half_width_pixels
