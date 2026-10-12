class_name SovereignPursuitDefinition
extends AbilityDefinition

## Immutable authority values for King's aimed leap and landing strike.

@export_range(64.0, 320.0, 1.0, "suffix:px") var target_range_pixels := 220.0
enum Rank { FOUNDATION, ADVANCED, MATURE }
@export var rank: Rank = Rank.FOUNDATION
@export_range(1, 3, 1) var max_charges := 1
@export_range(24.0, 120.0, 1.0, "suffix:px") var landing_radius_pixels := 52.0
# This is a world-space offset from the actor's feet, not AbilityPivot's local
# compensation. The C body and collision-safe target both use the actor origin.
@export_range(-32.0, 32.0, 1.0, "suffix:px") var ground_center_offset_y := 0.0


func configure_rank(value: Rank) -> void:
	rank = value
	target_range_pixels = [220.0, 250.0, 280.0][rank]
	max_charges = [1, 2, 3][rank]
	description = "Aim each leap separately. %d stored %s, %d px range, 52 px landing radius, 125%% weapon damage per landing. A landed Pursuit can link into Molten Crash." % [max_charges, "use" if max_charges == 1 else "uses", int(target_range_pixels)]
