extends Resource

const PlantingDefinition = preload("res://data/weapons/weapon_planting_definition.gd")
const OffhandDefinition = preload("res://data/weapons/offhand_pose_definition.gd")

## Presentation data only. MeleeAttackComponent owns contact and timing.
@export var body_atlas: Texture2D
@export var hand_atlas: Texture2D
@export var weapon_texture: Texture2D
@export var offhand: OffhandDefinition
@export var cell_size := Vector2i(192, 128)
@export var columns := 4
## Older clips retain eight keys; longer attacks declare their own atlas rows.
@export_range(2,64) var pose_count := 8
## Reuse authored cells for a reverse cut without mirroring King's facing.
@export var pose_order := PackedInt32Array([0,1,2,3,4,5,6,7])
@export var primary_hands := PackedVector2Array()
@export var secondary_hands := PackedVector2Array()
@export var weapon_primary_grip := Vector2.ZERO
@export var weapon_handle_axis := Vector2.DOWN
## Tip landmark is weapon-specific; the shared action uses it to solve burial.
@export var weapon_tip := Vector2(-1,-1)
@export var planting: PlantingDefinition
## Handedness is independent of shaft alignment: the edge must lead the cut.
@export var mirror_cutting_edge := true
@export var lift_pixels := PackedFloat32Array([0,0,0,0,0,0,0,0])
@export_range(0,96) var maximum_lift_pixels := 24.0
@export var weapon_behind_body := PackedByteArray([0,0,0,0,0,0,0,0])
## Optional true whole-blade occlusion in complete turning/rear cels.
@export var primary_visible_poses := PackedByteArray()
## Rear-facing cels can occlude both front grips behind an authored torso.
## The hand atlas retains source-palm registration; it is hidden in these keys.
@export var occluded_hand_poses := PackedByteArray()
## In a one-hand pose the secondary anchor gives shaft direction, not a grip.
@export var single_hand_poses := PackedByteArray([0,0,0,0,0,0,0,0])
## Stowed frames use back attachment anchors and no foreground hand mask.
@export var stowed_poses := PackedByteArray([0,0,0,0,0,0,0,0])
## Detached planted weapon: anchors belong to its ground attachment, not hands.
@export var released_poses := PackedByteArray([0,0,0,0,0,0,0,0])
## Planted poses hide steel below the registered foot plane; no weapon rescaling.
@export var ground_clipped_poses := PackedByteArray([0,0,0,0,0,0,0,0])
@export var follow_up_clips: Array[Resource] = []
@export var phase_windows := PackedVector2Array([Vector2(0, 3), Vector2(4, 5), Vector2(6, 7)])
## Optional complete drawn recovery branch for a buffered cut. Its final cel
## becomes the next cut's opening, while released attacks recover to carry.
@export var queued_recovery_window := Vector2(-1,-1)
## Optional relative exposure within each phase, independent of drawing count.
@export var pose_weights := PackedFloat32Array()
## Registered weapon/hand overlays can move between crisp body cels.
@export var interpolate_weapon := false
## Rotate rigid blades around their current drawn grips; keep both glove
## overlays fixed on the whole body. Safe for independent dual weapons.
@export var interpolate_blade_angles := false
@export var allow_rest := true
## Optional authored idle action. Defaults preserve existing planted idles.
@export var rest_start_pose := 4
## Stop entry before glance keys; -1 retains the existing last-pose endpoint.
@export_range(-1,63) var rest_transition_end_pose := -1
@export var rest_transition_seconds := 0.48
@export var rest_loop_window := Vector2(-1,-1)
@export var rest_loop_seconds := 3.0
@export var retrieval_end_pose := 3
## Optional provenance regions for native identity checks; no per-frame use.
@export var identity_regions: Array[Rect2] = []
## The same complete head may follow different drawn neck sockets per pose.
@export var identity_source_region := Rect2()
## Queued continuation can retain the contact endpoint instead of resetting guard.
@export_range(-1,63) var linked_recovery_pose := -1

func has_valid_layout() -> bool:
	if not primary_visible_poses.is_empty():
		if primary_visible_poses.size()!=pose_count: return false
		for flag in primary_visible_poses:
			if flag>1: return false
	if allow_rest:
		if rest_start_pose<0 or rest_start_pose>=pose_count or retrieval_end_pose<0 or retrieval_end_pose>=pose_count or not is_finite(rest_transition_seconds) or rest_transition_seconds<=0: return false
		if rest_transition_end_pose < -1 or rest_transition_end_pose >= pose_count or (rest_transition_end_pose>=0 and rest_transition_end_pose<rest_start_pose): return false
		if rest_loop_window!=Vector2(-1,-1):
			if not rest_loop_window.is_finite() or rest_loop_window.x<0 or rest_loop_window.y<rest_loop_window.x or rest_loop_window.y>=pose_count or rest_loop_window.x!=floorf(rest_loop_window.x) or rest_loop_window.y!=floorf(rest_loop_window.y) or not is_finite(rest_loop_seconds) or rest_loop_seconds<=0: return false
	if not occluded_hand_poses.is_empty() and occluded_hand_poses.size()!=pose_count: return false
	if interpolate_weapon and interpolate_blade_angles: return false
	# Two gloves share one foreground cel. Rotating that cel around one hilt
	# would detach the other glove; dual clips use authored crisp cels instead.
	if offhand!=null and (interpolate_weapon or not offhand.has_valid_layout(pose_count,cell_size)): return false
	if not identity_regions.is_empty() and identity_regions.size()!=pose_count: return false
	if not pose_weights.is_empty():
		if pose_weights.size() != pose_count: return false
		for weight in pose_weights:
			if not is_finite(weight) or weight <= 0: return false
	if pose_count<2 or pose_count>64 or linked_recovery_pose < -1 or linked_recovery_pose >= pose_count: return false
	if body_atlas == null or hand_atlas == null or weapon_texture == null:
		return false
	if columns != 4 or cell_size.x <= 0 or cell_size.y <= 0 or primary_hands.size() != pose_count or secondary_hands.size() != pose_count or phase_windows.size() != 3 or lift_pixels.size() != pose_count or weapon_behind_body.size()!=pose_count or single_hand_poses.size()!=pose_count or stowed_poses.size()!=pose_count or released_poses.size()!=pose_count:
		return false
	if not weapon_handle_axis.is_finite() or weapon_handle_axis.is_zero_approx() or not Rect2(Vector2.ZERO,weapon_texture.get_size()).has_point(weapon_primary_grip):
		return false
	if ground_clipped_poses.size()!=pose_count: return false
	if pose_order.size()!=pose_count: return false
	var used_poses := {}
	for pose in pose_order:
		if pose<0 or pose>=pose_count or used_poses.has(pose): return false
		used_poses[pose] = true
	if planting!=null:
		if not planting.is_valid(cell_size) or not Rect2(Vector2.ZERO,weapon_texture.get_size()).has_point(weapon_tip) or weapon_tip.distance_to(weapon_primary_grip)<=planting.burial_depth_pixels: return false
	var first := 0
	if not is_finite(maximum_lift_pixels) or maximum_lift_pixels<0 or maximum_lift_pixels>96: return false
	for window in phase_windows:
		if not window.is_finite() or window.x != first or window.y != floorf(window.y) or window.y < window.x or window.y >= pose_count:
			return false
		first = int(window.y)+1
	if queued_recovery_window==Vector2(-1,-1):
		if first != pose_count: return false
	else:
		if not queued_recovery_window.is_finite() or queued_recovery_window.x!=first or queued_recovery_window.y!=pose_count-1 or queued_recovery_window.x!=floorf(queued_recovery_window.x) or queued_recovery_window.y<queued_recovery_window.x: return false
	for index in pose_count:
		if hands_are_occluded(index) and (weapon_behind_body[index]==0 or single_hand_poses[index]>0 or stowed_poses[index]>0 or released_poses[index]>0): return false
		if not is_finite(lift_pixels[index]) or lift_pixels[index]>0 or lift_pixels[index]<-maximum_lift_pixels:
			return false
		if not Rect2(Vector2.ZERO,Vector2(cell_size)).has_point(primary_hands[index]) or not Rect2(Vector2.ZERO,Vector2(cell_size)).has_point(secondary_hands[index]) or primary_hands[index].distance_to(secondary_hands[index]) < 1.0:
			return false
	for clip in follow_up_clips:
		if clip == null or clip.get_script()!=get_script() or not clip.follow_up_clips.is_empty() or not clip.has_valid_layout(): return false
	return body_atlas.get_size() == Vector2(cell_size.x * columns, cell_size.y * ceili(pose_count/float(columns))) and hand_atlas.get_size() == body_atlas.get_size()

func hands_are_occluded(index: int) -> bool:
	return index>=0 and index<occluded_hand_poses.size() and occluded_hand_poses[index]>0
