extends "res://gameplay/presentation/axe_swing_trail.gd"

## Phase-driven full raster frames. No damage, fitting or pixel scans at runtime.
@export var layout: Resource
const FRAME_COUNT := 8
var pose_presenter: Node2D
var slash_sprite: Sprite2D
var contact_mask: ShaderMaterial
var _contact_origin := Vector2.ZERO

func bind_pose_presenter(presenter: Node2D) -> void:
	pose_presenter = presenter

func _ready() -> void:
	super._ready()
	assert(layout!=null and layout.is_valid_layout())
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

func _phase(phase: int,duration: float) -> void:
	clear()
	if phase!=MeleeAttackComponent.Phase.ACTIVE or not _prepare_contact_shape(): return
	_row = _attack.combo_step
	var actor := _attack.owner as Node2D
	_contact_origin = actor.to_local(_attack.collision_shape.global_position)
	_configure_contact_mask()
	_set_frame(0)
	_tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	_tween.tween_method(_set_frame,0.0,FRAME_COUNT-0.001,maxf(duration,0.0001))
	_tween.tween_callback(slash_sprite.hide)

func _set_frame(value: float) -> void:
	_frame = clampi(int(value),0,FRAME_COUNT-1)
	if not is_instance_valid(slash_sprite): return
	var cell := Vector2(atlas.get_width()/float(FRAME_COUNT),atlas.get_height()/float(rows))
	(slash_sprite.texture as AtlasTexture).region = Rect2(Vector2(_frame,_row)*cell,cell)
	slash_sprite.transform = layout.for_attack(_attack.get_attack_direction(),_row)
	slash_sprite.position += _contact_origin
	contact_mask.set_shader_parameter("actor_origin",slash_sprite.transform.origin)
	contact_mask.set_shader_parameter("actor_axis_x",slash_sprite.transform.x)
	contact_mask.set_shader_parameter("actor_axis_y",slash_sprite.transform.y)
	slash_sprite.show()

func _configure_contact_mask() -> void:
	var area := 0.0
	for index in _points.size(): area+=_points[index].cross(_points[(index+1)%_points.size()])
	var normals := PackedVector2Array()
	var distances := PackedFloat32Array()
	for index in _points.size():
		var edge := _points[(index+1)%_points.size()]-_points[index]
		var normal := Vector2(-edge.y,edge.x).normalized()*(1.0 if area>0 else -1.0)
		normals.append(normal)
		distances.append(normal.dot(_points[index]))
	normals.resize(64)
	distances.resize(64)
	contact_mask.set_shader_parameter("edge_count",_points.size())
	contact_mask.set_shader_parameter("edge_normals",normals)
	contact_mask.set_shader_parameter("edge_distances",distances)

func clear() -> void:
	super.clear()
	if is_instance_valid(slash_sprite): slash_sprite.hide()

func _draw() -> void:
	pass
