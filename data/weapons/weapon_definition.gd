class_name WeaponDefinition
extends Resource

## Immutable tuning shared by weapon runtime instances.

@export var weapon_id: StringName
@export var display_name: String = "Weapon"
@export var world_texture: Texture2D
## Character-authored signature weapons may be drawn inside body action frames
## instead of requiring a second detached world sprite.
@export var uses_integrated_visual := false
@export var family_presentation: WeaponFamilyPresentationDefinition
## Optional accepted-hit layer; null preserves the legacy sound exactly.
@export var hit_audio: WeaponHitAudioDefinition
## Optional per-cut contact profiles. Null/missing entries use hit_audio.
@export var combo_hit_audio: Array[WeaponHitAudioDefinition] = []
## Authoritative right-facing melee contact area. The player's combat pivot
## rotates this shape for the other directions; VFX may read its bounds.
@export var melee_hitbox_shape: Shape2D
## Multiple sword grades may share one style/body animation. Short swords,
## greatswords, axes, scythes, and other families can each reference their own
## reviewed shape and style without changing player code.
@export var attack_style: SwordAttackStyleDefinition
@export var combo: SwordComboDefinition
## Walk speed during WIND_UP, ACTIVE and RECOVERY. Damage/presentation do not
## own locomotion. Defaults preserve unrestricted legacy weapon movement.
@export var attack_movement_ratios := PackedFloat32Array([1.0, 1.0, 1.0])
@export var damage_type := DamageInfo.DamageType.PHYSICAL
## Local Sprite2D offset that places the texture's authored grip on the
## WeaponVisual pivot. This keeps short swords and future greatswords on the
## same hand-driven swing rig without assuming their texture centers match.
@export var sprite_offset_from_grip := Vector2.ZERO
@export_range(0.25, 4.0, 0.05) var world_visual_scale: float = 1.0
@export_range(4.0, 48.0, 0.5, "suffix:px") var swing_visual_radius: float = 12.0
@export_range(0.0, 9999.0, 1.0) var damage: float = 10.0
## Normal attacks roll independently from skill power. Zero keeps legacy
## weapons compatible by falling back to `damage`.
@export_range(0.0, 9999.0, 1.0) var basic_damage_minimum: float = 0.0
@export_range(0.0, 9999.0, 1.0) var basic_damage_maximum: float = 0.0
## Critical chance applies once per accepted swing or skill strike so one broad
## contact produces one coherent result across every target it reaches.
@export_range(0.0, 0.5, 0.01, "suffix:%") var critical_chance_ratio := 0.0
@export_range(1.0, 3.0, 0.05, "suffix:x") var critical_damage_multiplier := 1.5
@export_range(0.0, 500.0, 1.0, "suffix:px/s") var knockback_strength: float = 0.0
## A normal sword hit is a brief flinch, never a long crowd-control lock.
@export_range(0.0, 1.0, 0.01, "suffix:s") var basic_stagger_seconds: float = 0.0
@export_range(0.0, 2.0, 0.01, "suffix:s") var wind_up_seconds: float = 0.1
@export_range(0.01, 2.0, 0.01, "suffix:s") var active_seconds: float = 0.1
@export_range(0.0, 3.0, 0.01, "suffix:s") var recovery_seconds: float = 0.2


func get_hit_audio_for_step(step: int) -> WeaponHitAudioDefinition:
	if step >= 0 and step < combo_hit_audio.size() and combo_hit_audio[step] != null:
		return combo_hit_audio[step]
	return hit_audio


func get_attack_movement_ratio(phase: int) -> float:
	if phase < 1 or phase > 3 or attack_movement_ratios.size() != 3:
		return 1.0
	return clampf(attack_movement_ratios[phase - 1], 0.0, 1.0)


func get_melee_forward_reach_pixels() -> float:
	if melee_hitbox_shape is ConvexPolygonShape2D:
		var reach := 0.0
		for point: Vector2 in (melee_hitbox_shape as ConvexPolygonShape2D).points:
			reach = maxf(reach, point.x)
		return reach
	if melee_hitbox_shape is RectangleShape2D:
		return (melee_hitbox_shape as RectangleShape2D).size.x * 0.5
	if melee_hitbox_shape is CapsuleShape2D:
		return (melee_hitbox_shape as CapsuleShape2D).height * 0.5
	return 0.0


func roll_basic_damage(random: RandomNumberGenerator) -> float:
	if basic_damage_minimum <= 0.0 or basic_damage_maximum < basic_damage_minimum:
		return damage
	return float(random.randi_range(roundi(basic_damage_minimum), roundi(basic_damage_maximum)))


func get_melee_half_width_pixels() -> float:
	if melee_hitbox_shape is ConvexPolygonShape2D:
		var half_width := 0.0
		for point: Vector2 in (melee_hitbox_shape as ConvexPolygonShape2D).points:
			half_width = maxf(half_width, absf(point.y))
		return half_width
	if melee_hitbox_shape is RectangleShape2D:
		return (melee_hitbox_shape as RectangleShape2D).size.y * 0.5
	if melee_hitbox_shape is CapsuleShape2D:
		return (melee_hitbox_shape as CapsuleShape2D).radius
	return 0.0
