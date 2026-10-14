class_name ReturningWeaponDefinition
extends Resource

## Optional released basic-attack step. Flight shares the ACTIVE phase clock;
## damage shares sum to one, so the normal combo readout remains truthful.
@export var reach := 124.0
@export var contact_radius := 38.0
@export_range(0.2, 0.8) var outbound_fraction := 0.5
@export_range(0.0, 0.6) var linger_fraction := 0.0
@export_range(0.0, 1.0) var outward_damage_share := 0.65
@export var presentation: PackedScene

func is_valid_definition() -> bool:
	return is_finite(reach) and reach > 0 and is_finite(contact_radius) and contact_radius > 0 and outbound_fraction >= 0.2 and outbound_fraction <= 0.8 and linger_fraction >= 0 and linger_fraction <= 0.6 and outbound_fraction + linger_fraction <= 0.8 and outward_damage_share >= 0 and outward_damage_share <= 1
