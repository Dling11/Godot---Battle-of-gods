extends Node2D

signal pose_changed(index: int)

## Fixed raster follows authored hand positions; it cannot issue attacks/damage.
const Definition = preload("res://data/weapons/weapon_family_pose_definition.gd")
var _queued_recovery_active := false
var _authored_entry: Dictionary = {}
var definition: Definition
var _default_definition: Definition
var pose_index := 0
var body_sprite: Sprite2D
var hand_sprite: Sprite2D
var weapon_rig: Node2D
var weapon_sprite: Sprite2D
var offhand_rig: Node2D
var offhand_sprite: Sprite2D
var _attack: MeleeAttackComponent
var _pose_tween: Tween
var _body_frame: AtlasTexture
var _hand_frame: AtlasTexture
var _observe_melee := true
var _base_position := Vector2.ZERO
var idle_definition: Definition
var _rest_timer: Timer
var _resting := false
var _drawing := false
var _running := false
var _locomotion_distance := 0.0
var _stride_pixels := 48.0
var _ground_material: ShaderMaterial
## Optional controller query: hold follow-through only for a queued cut.
var continuation_requested: Callable
## Query before recovery begins; the input controller still owns the buffer.
var continuation_pending: Callable

func face_horizontal(direction: float) -> void:
	scale.x = absf(scale.x)*(-1.0 if direction<0 else 1.0)

func play_locomotion(poses: Definition,cycle_seconds := 0.36, distance_driven := false) -> bool:
	if poses==null or not poses.has_valid_layout() or _attack.phase!=MeleeAttackComponent.Phase.IDLE or _drawing: return false
	_stop_tween()
	if _rest_timer!=null: _rest_timer.stop()
	_resting = false
	_running = true
	select_clip(poses)
	set_pose(0)
	_locomotion_distance = 0.0
	if distance_driven: return true
	_pose_tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS).set_loops()
	_pose_tween.tween_method(_advance_pose,0.0,7.999,maxf(cycle_seconds,0.18))
	return true

func advance_locomotion(travel: float) -> void:
	if not _running or travel<=0.0001: return
	_locomotion_distance = fposmod(_locomotion_distance+travel,_stride_pixels)
	var next_pose := int(_locomotion_distance/_stride_pixels*8.0)
	if next_pose!=pose_index: set_pose(next_pose)

func stop_locomotion() -> void:
	if not _running: return
	_running = false
	_stop_tween()
	if _attack.phase==MeleeAttackComponent.Phase.IDLE:
		if idle_definition!=null: _carry()
		else:
			select_clip(_default_definition)
			set_pose(0)

func retrieve_from_rest(ready: Callable) -> bool:
	if not _resting or _drawing or idle_definition==null: return false
	_stop_tween()
	_rest_timer.stop()
	_drawing = true
	_pose_tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	_pose_tween.tween_method(_advance_pose,float(idle_definition.pose_count-1),float(idle_definition.retrieval_end_pose)+0.001,0.28)
	_pose_tween.tween_callback(func() -> void:
		_drawing = false
		_resting = false
		set_pose(0)
		if ready.is_valid(): ready.call()
	)
	return true

func cancel_presentation_transition() -> void:
	_stop_tween()
	_drawing = false
	_running = false
	if _attack.phase==MeleeAttackComponent.Phase.IDLE:
		if idle_definition!=null: _carry()
		else:
			select_clip(_default_definition)
			set_pose(0)

func configure_idle(poses: Definition, rest_seconds := 4.0) -> bool:
	if is_inside_tree() or poses==null or not poses.has_valid_layout(): return false
	idle_definition = poses
	_rest_timer = Timer.new()
	_rest_timer.one_shot = true
	_rest_timer.wait_time = maxf(rest_seconds,0.1)
	_rest_timer.timeout.connect(_rest)
	add_child(_rest_timer)
	return true

func configure(poses: Definition, attack: MeleeAttackComponent, observe_melee := true) -> bool:
	if is_inside_tree() or poses == null or not poses.has_valid_layout() or attack == null:
		return false
	definition = poses
	_default_definition = poses
	_attack = attack
	_observe_melee = observe_melee
	return true

func _ready() -> void:
	assert(definition != null and _attack != null)
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_base_position = position
	_body_frame = AtlasTexture.new()
	_body_frame.filter_clip = true
	_body_frame.atlas = definition.body_atlas
	body_sprite = Sprite2D.new()
	body_sprite.texture = _body_frame
	add_child(body_sprite)
	weapon_rig = Node2D.new()
	add_child(weapon_rig)
	weapon_sprite = Sprite2D.new()
	weapon_sprite.texture = definition.weapon_texture
	weapon_sprite.centered = false
	weapon_sprite.position = -definition.weapon_primary_grip
	_ground_material = ShaderMaterial.new()
	_ground_material.shader = preload("res://gameplay/presentation/planted_weapon.gdshader")
	weapon_sprite.material = _ground_material
	weapon_rig.add_child(weapon_sprite)
	_configure_offhand()
	_hand_frame = AtlasTexture.new()
	_hand_frame.filter_clip = true
	_hand_frame.atlas = definition.hand_atlas
	hand_sprite = Sprite2D.new()
	hand_sprite.texture = _hand_frame
	add_child(hand_sprite)
	_bind_attack()
	set_process(false)
	set_physics_process(false)
	set_pose(0)
	if idle_definition!=null: _carry()

func _enter_tree() -> void:
	# Reattaching an already-built idle presentation must restore observers.
	if body_sprite != null:
		_bind_attack()
		if idle_definition!=null: call_deferred("_resume_idle")

func _resume_idle() -> void:
	if is_inside_tree() and is_instance_valid(_attack) and _attack.phase==MeleeAttackComponent.Phase.IDLE:
		_stop_tween()
		_carry()

func _bind_attack() -> void:
	if _observe_melee and is_instance_valid(_attack):
		if not _attack.phase_changed.is_connected(_on_phase):
			_attack.phase_changed.connect(_on_phase)
		if not _attack.attack_finished.is_connected(_on_finished):
			_attack.attack_finished.connect(_on_finished)

func set_pose(index: int) -> void:
	var previous := pose_index
	pose_index = clampi(index, 0, definition.pose_count-1)
	var atlas_pose: int = definition.pose_order[pose_index]
	var cell := Vector2i(atlas_pose % definition.columns, atlas_pose / definition.columns)
	var region := Rect2(Vector2(cell * definition.cell_size), Vector2(definition.cell_size))
	_body_frame.region = region
	_hand_frame.region = region
	body_sprite.texture = _body_frame
	hand_sprite.texture = _hand_frame
	position = _base_position + Vector2(0,definition.lift_pixels[pose_index]*scale.y)
	body_sprite.position = Vector2.ZERO
	hand_sprite.position = Vector2.ZERO
	hand_sprite.transform = Transform2D.IDENTITY
	var basis := _weapon_basis_for(pose_index)
	weapon_sprite.texture = definition.weapon_texture
	weapon_sprite.position = -definition.weapon_primary_grip
	weapon_rig.visible = definition.primary_visible_poses.is_empty() or definition.primary_visible_poses[pose_index]>0
	if definition.offhand!=null:
		offhand_sprite.texture = definition.offhand.texture
		offhand_sprite.position = -definition.offhand.grip
	weapon_rig.transform = basis
	_update_ground_material(basis)
	# Local draw order: negative global Z can put the axe under terrain/backdrops.
	# Timers/optional rig children must not shift the body's painter order.
	move_child(body_sprite,0)
	move_child(weapon_rig,0 if definition.weapon_behind_body[pose_index]>0 else 1)
	move_child(hand_sprite,get_child_count()-1)
	_apply_offhand_pose(pose_index)
	if previous!=pose_index: pose_changed.emit(pose_index)
	hand_sprite.visible = not definition.hands_are_occluded(pose_index)
	if pose_index==0 and definition.queued_recovery_window.x>=0 and not _authored_entry.is_empty():
		# Standalone/late inputs inherit the actual complete rendered pose.
		body_sprite.texture = _authored_entry.body
		hand_sprite.texture = _authored_entry.hand
		hand_sprite.visible = _authored_entry.get("hand_visible",true)
		weapon_rig.transform = _authored_entry.weapon
		weapon_rig.visible = _authored_entry.get("weapon_visible",true)
		weapon_sprite.texture = _authored_entry.get("weapon_texture",definition.weapon_texture)
		weapon_sprite.position = _authored_entry.get("weapon_offset",weapon_sprite.position)
		position = _authored_entry.position
		move_child(weapon_rig,0 if _authored_entry.behind else 1)
		_update_ground_material(weapon_rig.transform)
		if definition.offhand!=null and _authored_entry.has("offhand"):
			offhand_rig.transform = _authored_entry.offhand
			offhand_sprite.texture = _authored_entry.get("offhand_texture",definition.offhand.texture)
			offhand_sprite.position = _authored_entry.get("offhand_offset",offhand_sprite.position)
			offhand_rig.visible = _authored_entry.offhand_visible
			_sort_blades(_authored_entry.behind,_authored_entry.offhand_behind)

func _configure_offhand() -> void:
	if definition.offhand==null:
		if is_instance_valid(offhand_rig): offhand_rig.hide()
		return
	# Ordinary one-blade profiles allocate no extra rig or texture node.
	if not is_instance_valid(offhand_rig):
		offhand_rig = Node2D.new()
		offhand_rig.name = "OffhandBlade"
		add_child(offhand_rig)
		offhand_sprite = Sprite2D.new()
		offhand_sprite.centered = false
		offhand_rig.add_child(offhand_sprite)
	offhand_sprite.texture = definition.offhand.texture
	offhand_sprite.position = -definition.offhand.grip

func _apply_offhand_pose(index: int) -> void:
	if definition.offhand==null: return
	offhand_rig.transform = definition.offhand.basis_for(index,definition.cell_size)
	offhand_rig.visible = definition.offhand.visible_poses[index]>0
	_sort_blades(definition.weapon_behind_body[index]>0,definition.offhand.behind_body[index]>0)

func _sort_blades(main_behind: bool, off_behind: bool) -> void:
	# Explicit local order: rear blades, connected body, front blades, fingers.
	var order: Array[Node] = []
	if main_behind: order.append(weapon_rig)
	if off_behind: order.append(offhand_rig)
	order.append(body_sprite)
	if not off_behind: order.append(offhand_rig)
	if not main_behind: order.append(weapon_rig)
	order.append(hand_sprite)
	for child in order: move_child(child,get_child_count()-1)

func _weapon_basis_for(index: int) -> Transform2D:
	var grip_position: Vector2 = definition.primary_hands[index] - Vector2(definition.cell_size) * 0.5
	var hand_axis: Vector2 = definition.secondary_hands[index] - definition.primary_hands[index]
	var angle: float = hand_axis.angle()-definition.weapon_handle_axis.angle()
	var basis := Transform2D(angle,Vector2.ZERO)
	if definition.mirror_cutting_edge:
		var axis: Vector2 = definition.weapon_handle_axis.normalized()
		# Reflection about the SHAFT, rather than screen X, keeps both grips fixed.
		var reflection := Transform2D(Vector2(2*axis.x*axis.x-1,2*axis.x*axis.y),Vector2(2*axis.x*axis.y,2*axis.y*axis.y-1),Vector2.ZERO)
		basis = basis * reflection
	basis.origin = grip_position
	if definition.planting!=null and index>=definition.planting.release_pose:
		basis = _planted_basis()
	return basis

func _update_ground_material(basis: Transform2D) -> void:
	_ground_material.set_shader_parameter("buried",definition.ground_clipped_poses[pose_index]>0)
	_ground_material.set_shader_parameter("ground_axis",Vector2(basis.x.y,basis.y.y))
	_ground_material.set_shader_parameter("ground_offset",(basis*weapon_sprite.position).y)
	var floor_y: float = definition.planting.ground_anchor.y-definition.cell_size.y*0.5 if definition.planting!=null else definition.cell_size.y*0.25
	_ground_material.set_shader_parameter("foot_y",floor_y)

func _planted_basis(clearance := false) -> Transform2D:
	var stance := definition.planting
	var center := Vector2(definition.cell_size)*0.5
	var tip_delta := definition.weapon_tip-definition.weapon_primary_grip
	var basis := Transform2D(Vector2.DOWN.angle()-tip_delta.angle(),Vector2.ZERO)
	var depth: float = -stance.preparation_clearance_pixels if clearance else stance.burial_depth_pixels
	var tip := stance.ground_anchor-center+Vector2(0,depth)
	basis.origin = tip-basis.basis_xform(tip_delta)
	return basis

func get_plant_ground_position() -> Vector2:
	if definition.planting==null: return Vector2.ZERO
	return definition.planting.ground_anchor-Vector2(definition.cell_size)*0.5

func get_contact_tip_in_parent() -> Vector2:
	var index := int(definition.phase_windows[1].x)
	var tip := _weapon_basis_for(index)*(definition.weapon_tip-definition.weapon_primary_grip)
	return _base_position+Vector2(0,definition.lift_pixels[index]*scale.y)+transform.basis_xform(tip)

func _animate_plant(value: float) -> void:
	var stance := definition.planting
	if stance==null or pose_index<stance.preparation_pose or pose_index>stance.release_pose: return
	var ready := _planted_basis(true)
	var authored_hand := definition.primary_hands[stance.preparation_pose]-Vector2(definition.cell_size)*0.5
	var lift := ready.origin-authored_hand
	var progress := smoothstep(0.0,1.0,fposmod(value,1.0))
	if pose_index==stance.preparation_pose:
		body_sprite.position = lift*progress
		hand_sprite.position = body_sprite.position
		var carried := weapon_rig.transform
		var basis := Transform2D(lerp_angle(carried.get_rotation(),ready.get_rotation(),progress),Vector2.ZERO)
		basis.origin = authored_hand+body_sprite.position
		weapon_rig.transform = basis
		_update_ground_material(basis)
	else:
		body_sprite.position = lift*(1.0-progress)
		hand_sprite.position = body_sprite.position

func select_clip(clip: Definition) -> void:
	definition = clip
	_body_frame.atlas = clip.body_atlas
	_hand_frame.atlas = clip.hand_atlas
	weapon_sprite.texture = clip.weapon_texture
	weapon_sprite.position = -clip.weapon_primary_grip
	_configure_offhand()

func _on_phase(phase: int, duration: float) -> void:
	_stop_tween()
	_drawing = false
	_running = false
	if _rest_timer!=null: _rest_timer.stop()
	_resting = false
	if phase < MeleeAttackComponent.Phase.WIND_UP or phase > MeleeAttackComponent.Phase.RECOVERY:
		return
	if phase == MeleeAttackComponent.Phase.WIND_UP:
		_queued_recovery_active = false
		# Carry can use another grip or an occluded-handle texture. Preserve
		# the complete rendered blade until the attack leaves its entry cel.
		var entry := {"body":body_sprite.texture.duplicate(),"hand":hand_sprite.texture.duplicate(),"hand_visible":hand_sprite.visible,"weapon":weapon_rig.transform,"weapon_visible":weapon_rig.visible,"weapon_texture":weapon_sprite.texture,"weapon_offset":weapon_sprite.position,"position":position,"behind":weapon_rig.get_index()<body_sprite.get_index()}
		if is_instance_valid(offhand_rig) and definition.offhand!=null:
			entry.offhand = offhand_rig.transform
			entry.offhand_texture = offhand_sprite.texture
			entry.offhand_offset = offhand_sprite.position
			entry.offhand_visible = offhand_rig.visible
			entry.offhand_behind = offhand_rig.get_index()<body_sprite.get_index()
		var step: int = _attack.combo_step
		select_clip(_default_definition.follow_up_clips[step-1] if step>0 and step<=_default_definition.follow_up_clips.size() else _default_definition)
		_authored_entry = entry if definition.queued_recovery_window.x>=0 else {}
	if phase == MeleeAttackComponent.Phase.RECOVERY and definition.linked_recovery_pose>=0 and continuation_pending.is_valid() and continuation_pending.call():
		set_pose(definition.linked_recovery_pose)
		return
	var window: Vector2 = definition.phase_windows[phase - 1]
	if phase==MeleeAttackComponent.Phase.RECOVERY and definition.queued_recovery_window.x>=0 and continuation_pending.is_valid() and continuation_pending.call():
		window = definition.queued_recovery_window
		_queued_recovery_active = true
	set_pose(int(window.x))
	_pose_tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	if definition.pose_weights.is_empty():
		_pose_tween.tween_method(_advance_pose, window.x, window.y + 0.999, maxf(duration, 0.0001))
	else:
		_pose_tween.tween_method(_advance_weighted_pose.bind(window), 0.0, 1.0, maxf(duration, 0.0001))

func _advance_weighted_pose(progress: float, window: Vector2) -> void:
	var total := 0.0
	for index in range(int(window.x),int(window.y)+1): total += definition.pose_weights[index]
	var remaining := clampf(progress,0,1)*total
	for index in range(int(window.x),int(window.y)+1):
		var weight := definition.pose_weights[index]
		if remaining < weight or index == int(window.y):
			_advance_pose(index+minf(remaining/weight,0.999))
			return
		remaining -= weight

func _advance_pose(value: float) -> void:
	set_pose(int(value))
	if definition.interpolate_blade_angles and pose_index<definition.pose_count-1:
		var next_index := pose_index+1
		if _attack.phase==MeleeAttackComponent.Phase.ACTIVE and pose_index==int(definition.phase_windows[1].y):
			next_index=int(definition.queued_recovery_window.x) if definition.queued_recovery_window.x>=0 and continuation_pending.is_valid() and continuation_pending.call() else int(definition.phase_windows[2].x)
		if _attack.phase==MeleeAttackComponent.Phase.RECOVERY and pose_index==int(definition.phase_windows[2].y): next_index=pose_index
		var t := fposmod(value,1.0)
		# Anatomy stays on the crisp cel. Only rigid steel rotates; do not
		# rotate the two-glove overlay around one hilt or slide either grip.
		var current := weapon_rig.transform
		var following := _weapon_basis_for(next_index)
		weapon_rig.transform=Transform2D(lerp_angle(current.get_rotation(),following.get_rotation(),t),current.origin)
		if definition.offhand!=null and offhand_rig.visible:
			var off := offhand_rig.transform
			var next_off: Transform2D = definition.offhand.basis_for(next_index,definition.cell_size)
			offhand_rig.transform=Transform2D(lerp_angle(off.get_rotation(),next_off.get_rotation(),t),off.origin)
		_update_ground_material(weapon_rig.transform)
	# A linked contact endpoint must not rotate toward the unqueued recovery
	# cel and then snap back when recovery holds it for the next cut.
	var linked_endpoint := _attack.phase == MeleeAttackComponent.Phase.ACTIVE and pose_index == definition.linked_recovery_pose
	if definition.interpolate_weapon and pose_index < definition.pose_count-1 and not linked_endpoint:
		var current := _weapon_basis_for(pose_index)
		var next := _weapon_basis_for(pose_index+1)
		var blended := current.interpolate_with(next,fposmod(value,1.0))
		# The body remains a crisp cel. Keep its grip attached to that cel;
		# translating the hand overlay independently creates a second/floating hand.
		blended.origin = current.origin
		weapon_rig.transform = blended
		hand_sprite.transform = blended*current.affine_inverse()
		_update_ground_material(blended)
	_animate_plant(value)

func _on_finished() -> void:
	# An earlier listener may have already started the next buffered attack.
	if is_instance_valid(_attack) and _attack.phase != MeleeAttackComponent.Phase.IDLE: return
	_stop_tween()
	_drawing = false
	_running = false
	if continuation_requested.is_valid() and continuation_requested.call():
		set_pose(int(definition.queued_recovery_window.y) if _queued_recovery_active else (definition.linked_recovery_pose if definition.linked_recovery_pose>=0 else int(definition.phase_windows[2].y)))
		return
	if idle_definition!=null:
		_carry()
		return
	select_clip(_default_definition)
	set_pose(0)

func _carry() -> void:
	_authored_entry.clear()
	_resting = false
	select_clip(idle_definition)
	set_pose(0)
	if idle_definition.allow_rest: _rest_timer.start()
	else: _rest_timer.stop()

func _rest() -> void:
	if not is_instance_valid(_attack) or _attack.phase!=MeleeAttackComponent.Phase.IDLE: return
	_stop_tween()
	_resting = true
	select_clip(idle_definition)
	set_pose(idle_definition.rest_start_pose)
	_pose_tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	var end_pose: int = idle_definition.rest_transition_end_pose if idle_definition.rest_transition_end_pose>=0 else idle_definition.pose_count-1
	_pose_tween.tween_method(_advance_pose,float(idle_definition.rest_start_pose),float(end_pose)+0.999,idle_definition.rest_transition_seconds)
	if idle_definition.rest_loop_window!=Vector2(-1,-1):
		# Hold the settled neutral head for one normal exposure before the first glance.
		var window := idle_definition.rest_loop_window
		_pose_tween.tween_interval(idle_definition.rest_loop_seconds/(window.y-window.x+1))
		_pose_tween.tween_callback(_loop_rest)

func _loop_rest() -> void:
	if not _resting or _drawing or _running or not is_inside_tree() or _attack.phase!=MeleeAttackComponent.Phase.IDLE: return
	var window := idle_definition.rest_loop_window
	_pose_tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS).set_loops()
	var exposure := idle_definition.rest_loop_seconds/(window.y-window.x+1)
	for pose in range(int(window.x),int(window.y)+1):
		_pose_tween.tween_callback(set_pose.bind(pose))
		_pose_tween.tween_interval(exposure)

func _stop_tween() -> void:
	if _pose_tween != null and _pose_tween.is_valid():
		_pose_tween.kill()

func _exit_tree() -> void:
	_stop_tween()
	_drawing = false
	_running = false
	if _rest_timer!=null: _rest_timer.stop()
	if is_instance_valid(_attack):
		if _attack.phase_changed.is_connected(_on_phase):
			_attack.phase_changed.disconnect(_on_phase)
		if _attack.attack_finished.is_connected(_on_finished):
			_attack.attack_finished.disconnect(_on_finished)
