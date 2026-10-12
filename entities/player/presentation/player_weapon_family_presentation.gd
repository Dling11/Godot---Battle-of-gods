extends Node

## Production adapter for authored family directions. Missing directions and
## skill/reaction actions retain existing body art; gameplay stays in Player.
const Presenter = preload("res://gameplay/presentation/weapon_family_pose_presenter.gd")
const BladeTrail = preload("res://gameplay/presentation/greatsword_blade_trail.gd")
const SwingTrail = preload("res://gameplay/presentation/axe_swing_trail.gd")
const FollowThrough = preload("res://gameplay/presentation/weapon_return_follow_through.gd")
const StepMotion = preload("res://gameplay/movement/melee_step_motion.gd")
const Impact = preload("res://gameplay/presentation/weapon_impact_presenter.gd")
const Sounds := [preload("res://assets/audio/sfx/player/greatsword/cut.wav"), preload("res://assets/audio/sfx/player/greatsword/return.wav"), preload("res://assets/audio/sfx/player/greatsword/cleave.wav")]
var actor: Player
var profile: WeaponFamilyPresentationDefinition
var presenter: Presenter
var trail: SwingTrail
var steps: StepMotion
var impacts: Impact
var follow_through: FollowThrough
var _audio: AudioStreamPlayer2D
var _interaction_active := false
var _last_position := Vector2.ZERO
var _side := 1.0
var _plant_marker: Node2D

func _ready() -> void:
	actor = get_parent() as Player
	set_physics_process(false)
	actor.ready.connect(_bind)

func _bind() -> void:
	actor.weapon_definition_changed.connect(_equip)
	actor.attack_component.phase_changed.connect(_phase)
	actor.attack_component.attack_finished.connect(_finished)
	actor.interaction_started.connect(func() -> void: _interaction_active = true; _sync())
	actor.interaction_finished.connect(func() -> void: _interaction_active = false; _sync())
	actor.facing_changed.connect(func(_direction: Vector2) -> void: _sync())
	actor.evade_component.evade_started.connect(func(_direction: Vector2) -> void: _sync())
	actor.hit_recovery_started.connect(func(_seconds: float) -> void: _sync())
	actor.defeated.connect(_sync)
	for ability in actor.get_all_ability_components():
		# ability_started precedes its committed WIND_UP state. Observe the
		# phase itself so a fast render frame cannot show both bodies.
		ability.phase_changed.connect(func(_phase: int,_seconds: float) -> void: _sync())
		ability.ability_finished.connect(_sync)
	_equip(actor.attack_component.weapon)

func _equip(weapon: WeaponDefinition) -> void:
	_clear_rig()
	profile = weapon.family_presentation
	if profile == null:
		set_physics_process(false)
		return
	assert(profile.is_valid_profile())
	presenter = Presenter.new()
	presenter.name = "FamilyBody"
	presenter.position = Vector2(0, -16)
	presenter.scale = Vector2.ONE * 0.5
	presenter.continuation_requested = _has_pending_cut
	presenter.continuation_pending = _has_pending_cut
	assert(presenter.configure(profile.attack_poses, actor.attack_component, false))
	assert(presenter.configure_idle(profile.idle_poses))
	actor.get_node("VisualRoot").add_child(presenter)
	presenter.pose_changed.connect(_plant)
	trail = profile.swing_scene.instantiate() if profile.swing_scene!=null else (BladeTrail.new() if profile.uses_meteor_trail else SwingTrail.new())
	trail.configure(actor.attack_component, profile.swing_atlas)
	if trail.has_method("bind_pose_presenter"): trail.bind_pose_presenter(presenter)
	trail.rows = profile.swing_rows
	trail.origins = profile.swing_origins
	trail.world_pixels_per_texel = profile.swing_texel_scale
	trail.full_frame_rows = profile.swing_full_frame_rows
	trail.world_origin = Vector2(0,-16)
	trail.edge_feather_pixels = 3
	trail.rotate_vertical_sampling = true
	if trail is BladeTrail:
		trail.meteor_clip = profile.attack_poses.follow_up_clips[1]
		trail.pose_presenter = presenter
		trail.modulate.a = .85
	actor.add_child(trail)
	# At equal Z an upward arc must paint before the elevated body. Keeping
	# both on the actor's layer also preserves terrain/entity depth ordering.
	actor.move_child(trail,actor.get_node("VisualRoot").get_index())
	if profile.return_follow_through_step > 0:
		var follow := FollowThrough.new()
		follow_through = follow
		follow.presenter = presenter
		follow.attack = actor.attack_component
		follow.return_clip = profile.attack_poses.follow_up_clips[profile.return_follow_through_step-1]
		follow.atlas = profile.swing_atlas
		presenter.add_child(follow)
	if not profile.step_distances.is_empty():
		steps = StepMotion.new()
		steps.actor = actor
		steps.attack = actor.attack_component
		steps.step_distances = profile.step_distances
		actor.add_child(steps)
	if profile.impact_atlas != null:
		impacts = Impact.new()
		impacts.attack = actor.attack_component
		impacts.atlas = profile.impact_atlas
		impacts.ground_step = profile.ground_impact_step
		impacts.mirror_horizontal_landing = true
		impacts.ground_position_provider = func() -> Vector2:
			return actor.to_local(presenter.get_parent().to_global(presenter.get_contact_tip_in_parent()))
		actor.add_child(impacts)
	_audio = AudioStreamPlayer2D.new()
	_audio.bus = &"SFX"
	_audio.volume_db = -12
	add_child(_audio)
	_last_position = actor.global_position
	set_physics_process(true)
	_sync()

func uses_side_clip() -> bool:
	if profile == null or actor == null:
		return false
	var direction := actor.attack_component.get_attack_direction() if actor.attack_component.phase != MeleeAttackComponent.Phase.IDLE else actor.facing_direction
	return absf(direction.x) > absf(direction.y)

func uses_family_clip() -> bool:
	if profile == null or actor == null: return false
	var direction := actor.attack_component.get_attack_direction() if actor.attack_component.phase != MeleeAttackComponent.Phase.IDLE else actor.facing_direction
	return profile.attack_for(direction) != null

func _has_pending_cut() -> bool:
	return actor._buffered_action == Player.BufferedAction.PRIMARY_ATTACK

func prepare_primary_attack() -> bool:
	if not is_instance_valid(presenter) or not presenter.visible:
		return false
	if presenter._drawing:
		return true # Repeated/assisted input coalesces into the pending retrieval.
	return presenter.retrieve_from_rest(func() -> void:
		if not _blocked(): actor.request_primary_attack()
	)

func _blocked() -> bool:
	return actor.is_defeated or actor.is_restrained() or actor.is_in_hit_recovery() or actor.is_cinematic_locked() or actor.is_any_ability_casting() or actor.evade_component.is_dashing() or actor.evade_component.is_recovering() or _interaction_active

func _sync() -> void:
	if not is_instance_valid(presenter): return
	var direction := actor.attack_component.get_attack_direction() if actor.attack_component.phase != MeleeAttackComponent.Phase.IDLE else actor.facing_direction
	var shown := uses_family_clip() and not _blocked()
	trail.z_index = 0 if direction.y < 0 and absf(direction.y) >= absf(direction.x) else 3
	var next_root := profile.attack_for(direction)
	if next_root != null and presenter._default_definition != next_root:
		presenter.cancel_presentation_transition()
		presenter._default_definition = next_root
		presenter.idle_definition = profile.idle_for(direction)
		if actor.attack_component.phase == MeleeAttackComponent.Phase.IDLE: presenter._carry()
		if trail is BladeTrail: trail.meteor_clip = next_root.follow_up_clips[1]
		if is_instance_valid(follow_through): follow_through.return_clip = next_root.follow_up_clips[profile.return_follow_through_step-1]
		_clear_plant()
	if is_instance_valid(impacts):
		impacts.mirror_horizontal_landing = uses_side_clip()
		impacts.ground_offset = Vector2(46,32) if uses_side_clip() else Vector2(46,0)
	actor.get_node("VisualRoot/Body").visible = not shown
	trail.visible = shown
	if is_instance_valid(impacts): impacts.visible = shown
	if shown != presenter.visible:
		presenter.cancel_presentation_transition()
		_clear_plant()
	presenter.visible = shown
	if not shown:
		presenter._rest_timer.stop()
		return
	_side = signf(direction.x) if uses_side_clip() else 1.0
	presenter.face_horizontal(_side)

func _physics_process(_delta: float) -> void:
	_sync()
	var travel := actor.global_position.distance_to(_last_position)
	_last_position = actor.global_position
	if not presenter.visible or actor.attack_component.phase != MeleeAttackComponent.Phase.IDLE or presenter._drawing: return
	if actor.velocity.length() > 5:
		if not presenter._running:
			presenter.play_locomotion(profile.run_for(actor.facing_direction), 0.36, true)
			_clear_plant()
		presenter.advance_locomotion(travel)
	else:
		presenter.stop_locomotion()

func _phase(phase: int, duration: float) -> void:
	if profile == null or phase != actor.attack_component.phase: return
	_sync()
	if not presenter.visible: return
	_clear_plant()
	presenter._on_phase(phase, duration)
	if phase == MeleeAttackComponent.Phase.ACTIVE and DisplayServer.get_name() != "headless":
		_audio.stream = Sounds[profile.sound_index(actor.attack_component.combo_step)]
		_audio.pitch_scale = profile.sound_pitch(actor.attack_component.combo_step)
		_audio.play()

func _finished() -> void:
	if is_instance_valid(presenter):
		presenter._on_finished()
		_sync()

func _plant(pose: int) -> void:
	var idle := presenter.idle_definition
	if idle == null or idle.planting == null: return
	if presenter.definition != idle or presenter._drawing or pose < 5:
		_clear_plant()
	if pose != 5 or presenter.definition != idle or not presenter._resting or presenter._drawing or not presenter.visible: return
	var point := presenter.get_plant_ground_position() * 0.5 + Vector2(0,-16)
	point.x *= _side
	impacts._spawn(1,point,0.28,0.24)
	_plant_marker = Impact.Burst.new()
	_plant_marker.atlas = profile.impact_atlas
	_plant_marker.row = 1
	_plant_marker.frame = 3
	_plant_marker.animate = false
	_plant_marker.position = point
	_plant_marker.scale = Vector2.ONE * 0.18
	actor.add_child(_plant_marker)

func _clear_plant() -> void:
	if is_instance_valid(_plant_marker):
		_plant_marker.get_parent().remove_child(_plant_marker)
		_plant_marker.queue_free()
	_plant_marker = null

func _clear_rig() -> void:
	_clear_plant()
	for node in [presenter,trail,steps,impacts,_audio]:
		if is_instance_valid(node):
			node.get_parent().remove_child(node)
			node.queue_free()
	presenter = null
	trail = null
	steps = null
	impacts = null
	_audio = null
	follow_through = null
	if actor != null: actor.get_node("VisualRoot/Body").show()

func _exit_tree() -> void:
	# Scene destruction owns removal order; never detach siblings while the
	# parent is recursively removing its children.
	for node in [presenter,trail,steps,impacts,_audio,_plant_marker]:
		if is_instance_valid(node): node.queue_free()
