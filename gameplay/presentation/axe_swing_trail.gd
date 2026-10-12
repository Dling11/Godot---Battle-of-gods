extends Node2D

## Generated raster sequence; melee alone owns contact/damage.
var atlas: Texture2D
var _attack: MeleeAttackComponent
var _frame := -1
var _row := 0
var _tween: Tween
var _points := PackedVector2Array()
const ORIGINS := [Vector2(48,48),Vector2(48,64),Vector2(48,48)]
var origins := PackedVector2Array(ORIGINS)
var world_pixels_per_texel := 1.0
var rows := 3
var world_origin := Vector2.ZERO
## Clipped rows fade inward; complete raster rows use their painted alpha edge.
var edge_feather_pixels := 0.0
var _mesh_frames: Array[ArrayMesh] = []
## Optional registered actor-to-cell samples; geometry/damage remain unchanged.
var frame_sample_transforms: Array[Transform2D] = []
## Ordinary atlas samples mirror with side-facing contact; registered maps own it.
var _sampling_facing := 1.0
var reverse_steps := PackedByteArray()
var rotate_vertical_sampling := false
## Explicit family opt-in: preserve the complete painted crescent, instead
## of cropping it to a fan. Other families retain their existing clipping.
var full_frame_rows := PackedByteArray()

func _sample_uv(point: Vector2,frame: int,cell: Vector2) -> Vector2:
	var delta := point-world_origin
	if rotate_vertical_sampling and absf(_attack.get_attack_direction().y) >= absf(_attack.get_attack_direction().x):
		delta = delta.rotated(-_attack.get_attack_direction().angle())
	else:
		delta.x *= _sampling_facing
	var sample_point := origins[_row]+delta/world_pixels_per_texel
	if frame_sample_transforms.size()==4:
		sample_point = frame_sample_transforms[frame]*point
	return (Vector2(frame*cell.x,_row*cell.y)+sample_point)/atlas.get_size()

func configure(attack: MeleeAttackComponent, texture: Texture2D) -> void:
	_attack = attack
	atlas = texture

func _ready() -> void:
	assert(_attack!=null and atlas!=null)
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	z_index = 3
	_attack.phase_changed.connect(_phase)
	_attack.attack_finished.connect(_finished)
	set_process(false)
	set_physics_process(false)

func _phase(phase: int,duration: float) -> void:
	clear()
	if phase!=MeleeAttackComponent.Phase.ACTIVE: return
	_sampling_facing = -1.0 if _attack.get_attack_direction().x<0 else 1.0
	if not _prepare_contact_shape(): return
	_row = clampi(_attack.combo_step,0,rows-1)
	prepare_edge_feather()
	_set_frame(0)
	_tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	_tween.tween_method(_set_frame,0.0,3.999,maxf(duration,0.0001))

func _prepare_contact_shape() -> bool:
	var shape: Shape2D = _attack.collision_shape.shape
	_points.clear()
	var actor := _attack.owner as Node2D
	if actor==null: return false
	var transform := actor.global_transform.affine_inverse()*_attack.collision_shape.global_transform
	if shape is ConvexPolygonShape2D:
		for point in shape.points: _points.append(transform*point)
	elif shape is CircleShape2D:
		for index in 64: _points.append(transform*(Vector2.from_angle(index*TAU/64.0)*shape.radius))
	else: return false
	return true

func _set_frame(value: float) -> void:
	_frame = clampi(int(value),0,3)
	if _attack.combo_step<reverse_steps.size() and reverse_steps[_attack.combo_step]>0: _frame = 3-_frame
	queue_redraw()

func _draw() -> void:
	if _frame<0 or _points.is_empty(): return
	if _mesh_frames.size()==4:
		draw_mesh(_mesh_frames[_frame],atlas)
		return
	var uvs := PackedVector2Array()
	var cell := Vector2(atlas.get_width()/4.0,atlas.get_height()/float(rows))
	for point in _points:
		# Registered origin and scale keep wider contact inside its own atlas cell.
		uvs.append(_sample_uv(point,_frame,cell))
	draw_polygon(_points,PackedColorArray([Color(1,1,1,0.92)]),uvs,atlas)

func prepare_edge_feather() -> void:
	# Cache four meshes on a contact/gallery transition, not every rendered frame.
	_mesh_frames.clear()
	if _row<full_frame_rows.size() and full_frame_rows[_row]>0:
		_points=_full_frame_points()
		return # Source alpha/padding owns its edge; no hard fan seam.
	if edge_feather_pixels<=0 or _points.size()<3: return
	var count := _points.size()
	var area := 0.0
	for index in count: area += _points[index].cross(_points[(index+1)%count])
	var sign := 1.0 if area>0 else -1.0
	var inside := PackedVector2Array()
	for index in count:
		var point := _points[index]
		var incoming := (point-_points[(index+count-1)%count]).normalized()
		var outgoing := (_points[(index+1)%count]-point).normalized()
		var a := Vector2(-incoming.y,incoming.x)*sign
		var b := Vector2(-outgoing.y,outgoing.x)*sign
		var determinant := a.cross(b)
		if absf(determinant)<0.00001: return
		var d_a := a.dot(point)+edge_feather_pixels
		var d_b := b.dot(point)+edge_feather_pixels
		inside.append(Vector2(d_a*b.y-a.y*d_b,a.x*d_b-d_a*b.x)/determinant)
	var inner_indices := Geometry2D.triangulate_polygon(inside)
	if inner_indices.is_empty(): return
	var vertices := PackedVector3Array()
	var colors := PackedColorArray()
	for point in _points:
		vertices.append(Vector3(point.x,point.y,0))
		colors.append(Color(1,1,1,0))
	for point in inside:
		vertices.append(Vector3(point.x,point.y,0))
		colors.append(Color(1,1,1,0.92))
	var indices := PackedInt32Array()
	for index in inner_indices: indices.append(index+count)
	for index in count:
		var next := (index+1)%count
		indices.append_array(PackedInt32Array([index,next,next+count,index,next+count,index+count]))
	var cell := Vector2(atlas.get_width()/4.0,atlas.get_height()/float(rows))
	for frame in 4:
		var uvs := PackedVector2Array()
		for vertex in vertices:
			var point := Vector2(vertex.x,vertex.y)
			uvs.append(_sample_uv(point,frame,cell))
		var arrays := []
		arrays.resize(Mesh.ARRAY_MAX)
		arrays[Mesh.ARRAY_VERTEX] = vertices
		arrays[Mesh.ARRAY_COLOR] = colors
		arrays[Mesh.ARRAY_TEX_UV] = uvs
		arrays[Mesh.ARRAY_INDEX] = indices
		var mesh := ArrayMesh.new()
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
		_mesh_frames.append(mesh)

func _full_frame_points() -> PackedVector2Array:
	var cell := Vector2(atlas.get_width()/4.0,atlas.get_height()/float(rows))
	var points := PackedVector2Array()
	for texel in [Vector2.ZERO,Vector2(cell.x,0),cell,Vector2(0,cell.y)]:
		var delta: Vector2 = (texel-origins[_row])*world_pixels_per_texel
		# Invert the UV registration, including true up/down rotation and
		# side mirroring. Draw one padded raster cel, not adjacent rows.
		if rotate_vertical_sampling and absf(_attack.get_attack_direction().y)>=absf(_attack.get_attack_direction().x):
			delta=delta.rotated(_attack.get_attack_direction().angle())
		else: delta.x*=_sampling_facing
		points.append(world_origin+delta)
	return points

func _finished() -> void:
	if _attack.phase==MeleeAttackComponent.Phase.IDLE: clear()

func clear() -> void:
	if _tween!=null and _tween.is_valid(): _tween.kill()
	_frame = -1
	_mesh_frames.clear()
	queue_redraw()

func _exit_tree() -> void:
	if _tween!=null and _tween.is_valid(): _tween.kill()
	if is_instance_valid(_attack):
		if _attack.phase_changed.is_connected(_phase): _attack.phase_changed.disconnect(_phase)
		if _attack.attack_finished.is_connected(_finished): _attack.attack_finished.disconnect(_finished)
