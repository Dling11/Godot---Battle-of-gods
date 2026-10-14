extends "res://gameplay/presentation/axe_swing_trail.gd"

const RIBBON_LAYOUT = preload("res://data/weapons/families/iron_reaper/ribbon_layout.tres")
const FRAME_COUNT := 8
## Full generated white ribbons, observed from authoritative contact windows.
## Vertical arcs are projected onto the floor; no collision or damage here.
var pose_presenter: Node2D
var slash_sprite: Sprite2D
var contact_mask: ShaderMaterial
var _contact_origin := Vector2.ZERO
var _idle_toss_active := false
var _idle_toss_from := Transform2D.IDENTITY
var _idle_toss: Tween


func bind_pose_presenter(presenter: Node2D) -> void:
	pose_presenter = presenter


func _ready() -> void:
	super._ready()
	assert(RIBBON_LAYOUT.is_valid_layout())
	slash_sprite = Sprite2D.new()
	var frame := AtlasTexture.new()
	frame.atlas = atlas
	frame.filter_clip = true
	slash_sprite.texture = frame
	slash_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	slash_sprite.modulate.a = 0.9
	contact_mask = ShaderMaterial.new()
	contact_mask.shader = preload("res://gameplay/presentation/weapon_contact_mask.gdshader")
	slash_sprite.material = contact_mask
	slash_sprite.hide()
	add_child(slash_sprite)
	pose_presenter.pose_changed.connect(_pose_changed)


func _phase(phase: int, duration: float) -> void:
	clear()
	if phase != MeleeAttackComponent.Phase.ACTIVE: return
	if _attack.weapon.combo.returning_attack(_attack.combo_step) != null: return
	if not _prepare_contact_shape(): return
	_configure_contact_mask()
	_row = 2 if _attack.combo_step==3 else _attack.combo_step
	_set_frame(0)
	_tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	_tween.tween_method(_set_frame, 0.0, FRAME_COUNT - 0.001, maxf(duration, 0.0001))
	_tween.tween_callback(slash_sprite.hide)


func _set_frame(value: float) -> void:
	_frame = clampi(int(value), 0, FRAME_COUNT - 1)
	if not is_instance_valid(slash_sprite): return
	var cell := Vector2(atlas.get_width() / float(FRAME_COUNT), atlas.get_height() / float(rows))
	(slash_sprite.texture as AtlasTexture).region = Rect2(Vector2(_frame, _row) * cell, cell)
	slash_sprite.show()
	_update_anchor()


func _update_anchor() -> void:
	var direction := _attack.get_attack_direction()
	# The entire painted stroke fits the actual floor contact polygon. Body
	# jump/recoil must not push it upward into that polygon's clipping edge.
	slash_sprite.transform = RIBBON_LAYOUT.for_attack(direction,_row)
	slash_sprite.position += _contact_origin
	contact_mask.set_shader_parameter("actor_origin", slash_sprite.transform.origin)
	contact_mask.set_shader_parameter("actor_axis_x", slash_sprite.transform.x)
	contact_mask.set_shader_parameter("actor_axis_y", slash_sprite.transform.y)


func _configure_contact_mask() -> void:
	var actor := _attack.owner as Node2D
	_contact_origin = actor.to_local(_attack.collision_shape.global_position)
	var area := 0.0
	for index in _points.size(): area += _points[index].cross(_points[(index + 1) % _points.size()])
	var winding := 1.0 if area > 0 else -1.0
	var normals := PackedVector2Array()
	var distances := PackedFloat32Array()
	for index in _points.size():
		var edge := _points[(index + 1) % _points.size()] - _points[index]
		var normal := Vector2(-edge.y, edge.x).normalized() * winding
		normals.append(normal)
		distances.append(normal.dot(_points[index]))
	normals.resize(64)
	distances.resize(64)
	contact_mask.set_shader_parameter("edge_count", _points.size())
	contact_mask.set_shader_parameter("edge_normals", normals)
	contact_mask.set_shader_parameter("edge_distances", distances)


func _pose_changed(_pose: int) -> void:
	if is_instance_valid(slash_sprite) and slash_sprite.visible: _update_anchor()
	var resting: bool = pose_presenter._resting and not pose_presenter._drawing and pose_presenter.definition == pose_presenter.idle_definition
	if resting and _pose==3:
		_stop_idle_toss()
		_idle_toss_from = pose_presenter._weapon_basis_for(2)
		_idle_toss_active = true
		# This tween is created after the actor's pose tween, so the whole-cel
		# update cannot overwrite the released steel before it is rendered.
		_idle_toss = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
		_idle_toss.tween_method(_toss_progress,0.0,1.0,pose_presenter.definition.rest_transition_seconds/7.0*2.0)
	elif not resting or _pose>=5 or _pose==0:
		_stop_idle_toss()

func _toss_progress(progress: float) -> void:
	if not _idle_toss_active or not is_instance_valid(pose_presenter) or not pose_presenter.visible or not pose_presenter._resting or pose_presenter._drawing:
		if is_instance_valid(pose_presenter): pose_presenter.weapon_rig.transform = pose_presenter._weapon_basis_for(pose_presenter.pose_index)
		_stop_idle_toss()
		return
	var catch_basis: Transform2D = pose_presenter._weapon_basis_for(5)
	var angle := lerp_angle(_idle_toss_from.get_rotation(),catch_basis.get_rotation(),progress)
	var origin := _idle_toss_from.origin.lerp(catch_basis.origin,progress)
	# A small vertical toss. Unit-scale steel keeps its full shape; no orbit,
	# repeated spinning or gameplay query belongs to this quiet idle action.
	origin.y -= 44.0 * 4.0 * progress * (1.0-progress)
	pose_presenter.weapon_rig.transform = Transform2D(angle,origin)

func _stop_idle_toss() -> void:
	_idle_toss_active = false
	if _idle_toss!=null and _idle_toss.is_valid(): _idle_toss.kill()

func _draw() -> void:
	pass


func clear() -> void:
	super.clear()
	if is_instance_valid(slash_sprite): slash_sprite.hide()


func _exit_tree() -> void:
	_stop_idle_toss()
	if is_instance_valid(pose_presenter) and pose_presenter.pose_changed.is_connected(_pose_changed):
		pose_presenter.pose_changed.disconnect(_pose_changed)
	super._exit_tree()
