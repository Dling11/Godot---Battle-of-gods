class_name WarCycloneDefinition
extends AbilityDefinition

## Prototype tuning; learning, earning and the mentor are separate systems.
@export var required_weapon_ids: Array[StringName] = [&"weapon_king_iron_beard_axe"]
@export_range(0.2, 1.0, 0.01) var turn_seconds := 0.5
@export_range(0.1, 1.0, 0.01) var minimum_turn_seconds := 0.28
@export_range(0.0, 1.0, 0.05) var movement_ratio := 0.90
@export_range(0.0, 0.90, 0.05) var damage_reduction_ratio := 0.50
@export var ignores_incoming_hit_control := true
## Presentation revolutions do not create extra damage queries or hitstop.
@export_range(0.12, 1.0, 0.01) var visual_turn_seconds := 0.32
@export_range(1.0, 3.0, 0.1) var outer_speed_multiplier := 1.6
@export_range(0.08, 0.3, 0.01) var minimum_visual_turn_seconds := 0.12
## One paired body/cut sequence: sixteen256px cels on a4x4 atlas.
@export var motion_atlas: Texture2D
@export var ground_atlas: Texture2D
@export var wind_color := Color(0.24, 0.66, 1.0)
@export var spin_poses: Array[Resource] = []
@export var outer_atlas: Texture2D
@export var swing_sound: AudioStream
@export var activation_sound: AudioStream
@export var finish_sound: AudioStream

func pulse_count_for(attack_speed: float) -> int:
	var period := maxf(minimum_turn_seconds,turn_seconds/maxf(attack_speed,.1))
	return clampi(roundi(active_seconds/period),1,maxi(1,floori(active_seconds/minimum_turn_seconds)))

func supports(weapon: WeaponDefinition) -> bool:
	return weapon != null and weapon.weapon_id in required_weapon_ids

func spin_for(direction: Vector2) -> Resource:
	if spin_poses.size() != 3: return null
	return spin_poses[1 if direction.y < 0 else 2] if absf(direction.y) >= absf(direction.x) else spin_poses[0]
