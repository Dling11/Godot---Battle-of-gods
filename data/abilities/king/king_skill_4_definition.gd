class_name KingSkill4Definition
extends AbilityDefinition

## Immutable authority values for King's ranked, released spirit-sword plunges.

enum Rank { FOUNDATION, ADVANCED, MATURE }
@export var rank := Rank.FOUNDATION
@export var descent_seconds := .42

@export_range(96.0, 360.0, 1.0, "suffix:px") var target_range_pixels := 260.0
@export_range(24.0, 120.0, 1.0, "suffix:px") var first_impact_radius_pixels := 72.0
@export_range(48.0, 180.0, 1.0, "suffix:px") var explosion_radius_pixels := 88.0
@export var followup_delay_seconds := .28
@export var explosion_hitbox_shape: Shape2D
@export_range(-32.0, 32.0, 1.0, "suffix:px") var ground_center_offset_y := 0.0

func configure_rank(value: int) -> void:
	rank = clampi(value, Rank.FOUNDATION, Rank.MATURE)
	target_range_pixels = [260.0, 280.0, 300.0][rank]
	first_impact_radius_pixels = [72.0, 72.0, 72.0][rank]
	explosion_radius_pixels = [88.0, 96.0, 104.0][rank]
	strike_damage_multipliers = [PackedFloat32Array([5.2]), PackedFloat32Array([2.2, 3.8]), PackedFloat32Array([1.8, 2.0, 3.2])][rank]
	var core := CircleShape2D.new()
	core.radius = first_impact_radius_pixels
	hitbox_shape = core
	var outer := CircleShape2D.new()
	outer.radius = explosion_radius_pixels
	explosion_hitbox_shape = outer
	description = "Summon spectral swords over one chosen point. Each new blade plunges deep and shatters into a radial blast. Move after the short command. Only the final detonation can stun.\n%d summoned sword(s) · %d%% total weapon damage · %dpx reach · %dpx final radius\n0.32s command · 20s cooldown · %s" % [strike_count(), [520,600,700][rank], target_range_pixels, explosion_radius_pixels, ["Foundation", "Advanced", "Mature"][rank]]

func contact_radius(index: int) -> float:
	return explosion_radius_pixels if index == strike_count()-1 else first_impact_radius_pixels + index*8.0
