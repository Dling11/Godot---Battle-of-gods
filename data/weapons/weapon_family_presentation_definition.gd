class_name WeaponFamilyPresentationDefinition
extends Resource

## Immutable art/locomotion profile. MeleeAttackComponent still owns all hits.
const PoseDefinition = preload("res://data/weapons/weapon_family_pose_definition.gd")
@export var attack_poses: PoseDefinition
@export var idle_poses: PoseDefinition
@export var running_poses: PoseDefinition
@export var upward_attack_poses: PoseDefinition
@export var downward_attack_poses: PoseDefinition
@export var upward_idle_poses: PoseDefinition
@export var downward_idle_poses: PoseDefinition
@export var upward_running_poses: PoseDefinition
@export var downward_running_poses: PoseDefinition
@export var swing_atlas: Texture2D
## Optional family-owned raster presentation; still no contact authority.
@export var swing_scene: PackedScene
@export var impact_atlas: Texture2D
@export var ground_impact_step := 2
@export var step_distances := PackedFloat32Array()
@export var swing_rows := 4
@export var swing_origins := PackedVector2Array([Vector2(128,128),Vector2(128,128),Vector2(128,128),Vector2(128,128)])
@export var swing_texel_scale := 1.0
## Optional cosmetic full raster rows. Contact/damage still belong to melee.
@export var swing_full_frame_rows := PackedByteArray()
@export var uses_meteor_trail := false
@export var return_follow_through_step := -1
@export var sound_indices := PackedInt32Array([0,1,2,2,1])
@export var sound_pitches := PackedFloat32Array([0.88,0.88,0.78,0.88,0.88])

func sound_index(step: int) -> int:
	return clampi(sound_indices[clampi(step,0,sound_indices.size()-1)],0,2)

func sound_pitch(step: int) -> float:
	return sound_pitches[clampi(step,0,sound_pitches.size()-1)]

func attack_for(direction: Vector2) -> PoseDefinition:
	if absf(direction.y) >= absf(direction.x):
		return upward_attack_poses if direction.y < 0 else downward_attack_poses
	return attack_poses

func idle_for(direction: Vector2) -> PoseDefinition:
	if absf(direction.y) >= absf(direction.x):
		return upward_idle_poses if direction.y < 0 else downward_idle_poses
	return idle_poses

func run_for(direction: Vector2) -> PoseDefinition:
	if absf(direction.y) >= absf(direction.x):
		return upward_running_poses if direction.y < 0 else downward_running_poses
	return running_poses

func is_valid_profile() -> bool:
	if not swing_full_frame_rows.is_empty():
		if swing_full_frame_rows.size()!=swing_rows: return false
		for flag in swing_full_frame_rows:
			if flag>1: return false
	for row in [[upward_attack_poses,upward_idle_poses,upward_running_poses],[downward_attack_poses,downward_idle_poses,downward_running_poses]]:
		if row[0] == null:
			if row[1] != null or row[2] != null: return false
		else:
			for clip in row:
				if clip == null or not clip.has_valid_layout(): return false
			if row[1].planting != null and impact_atlas == null: return false
	return attack_poses != null and attack_poses.has_valid_layout() and idle_poses != null and idle_poses.has_valid_layout() and running_poses != null and running_poses.has_valid_layout() and swing_atlas != null and swing_rows > 0 and swing_origins.size() == swing_rows and swing_texel_scale > 0 and not sound_indices.is_empty() and not sound_pitches.is_empty() and (not uses_meteor_trail or attack_poses.follow_up_clips.size() >= 2) and return_follow_through_step <= attack_poses.follow_up_clips.size() and (idle_poses.planting == null or impact_atlas != null)
