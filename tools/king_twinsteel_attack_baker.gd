extends RefCounted

## Offline complete-pose generation importer. Never copies reference anatomy
## into an action; reference images supply dimensions only. Steel stays rigid.
const Native = preload("res://tools/king_native_identity.gd")
const SOURCE := "res://art_source/generated/characters/king/twinsteel_attacks_complete_2026_10_14/"
const TARGET := "res://assets/characters/playable/king/shared_bodies/dual_carry_v3/"
const CELL := Vector2i(192,192)
const FOOT := 126
const ACTIONS := ["diagonal","return","rising_cross","hop_spin","cross_finish"]
const KEYS := [-1,0,1,2,3,4,5,6,7,-1,-1,6,7]
var native := Native.new()
var records: Array[Dictionary] = []
var anatomy: Dictionary = {}
var source_cells: Dictionary = {}

func make_recipe(profile: Resource,actions: Array=ACTIONS) -> Dictionary:
	var recipe := {"version":1,"mode":"generated_complete_attack_cels","cell_size":[192,192],"foot_plane":FOOT,"runtime_scale":.5,"alpha_threshold":180,"boards":{}}
	for view in ["side","up","down"]:
		var direction := Vector2.RIGHT if view=="side" else (Vector2.UP if view=="up" else Vector2.DOWN)
		var ready: Resource=profile.idle_for(direction)
		var reference_head: Rect2i=ready.body_atlas.get_image().get_region(Rect2i(ready.identity_regions[0])).get_used_rect()
		for action in actions:
			var path: String=SOURCE+view+"-"+action+".png"
			var cells := _cells(path)
			var spans: Array[float]=[]
			var descriptions: Array[Dictionary]=[]
			for cell in cells:
				var socket := native.neck(cell.image)
				var top := _head_top(cell.image,socket)
				spans.append(socket.y-top+1)
				var primary := _guide(cell,cell.blade,socket)
				var secondary := _guide(cell,cell.shaft,socket,primary)
				descriptions.append({"socket":[socket.x,socket.y],"head_top":top,"source_sole":_solid_bounds(cell.image).end.y-1,"primary":primary,"secondary":secondary})
			spans.sort()
			var span: float=(spans[3]+spans[4])*.5
			recipe.boards[view+"/"+action]={"source":path,"sha256":FileAccess.get_sha256(path),"density":reference_head.size.y/span,"target_head_span":reference_head.size.y,"source_head_span":span,"keys":descriptions}
	return recipe

func build(view: String,action: String,old: Resource,ready: Resource,recipe: Dictionary) -> Resource:
	var board: Dictionary=recipe.boards[view+"/"+action]
	assert(FileAccess.get_sha256(board.source)==board.sha256,"Generated attack source changed")
	var cells := _cells(board.source)
	var steel: Image=ready.weapon_texture.get_image()
	var atlas := Image.create(CELL.x*4,CELL.y*4,false,Image.FORMAT_RGBA8)
	var hands := Image.create(CELL.x*4,CELL.y*4,false,Image.FORMAT_RGBA8)
	var clip: Resource=old.duplicate(true)
	clip.cell_size=CELL
	clip.pose_count=KEYS.size()
	clip.pose_order=PackedInt32Array()
	clip.identity_regions.clear()
	clip.primary_hands=PackedVector2Array()
	clip.secondary_hands=PackedVector2Array()
	clip.primary_visible_poses=PackedByteArray()
	clip.weapon_behind_body=PackedByteArray()
	clip.lift_pixels=PackedFloat32Array()
	clip.single_hand_poses=PackedByteArray()
	clip.stowed_poses=PackedByteArray()
	clip.released_poses=PackedByteArray()
	clip.ground_clipped_poses=PackedByteArray()
	clip.occluded_hand_poses=PackedByteArray()
	clip.offhand.hands=PackedVector2Array()
	clip.offhand.axes=PackedVector2Array()
	clip.offhand.behind_body=PackedByteArray()
	clip.offhand.visible_poses=PackedByteArray()
	clip.offhand.texture=ready.offhand.texture
	clip.weapon_texture=ready.weapon_texture
	clip.follow_up_clips.clear()
	clip.phase_windows=PackedVector2Array([Vector2(0,2),Vector2(3,7),Vector2(8,10)])
	clip.queued_recovery_window=Vector2(11,12)
	clip.pose_weights=PackedFloat32Array([.5,1,1,1,1,1,1,1,1,.5,.5,1,1])
	clip.interpolate_weapon=false
	clip.interpolate_blade_angles=false
	clip.allow_rest=false
	clip.linked_recovery_pose=-1
	clip.identity_source_region=Rect2()
	var ready_origin := Vector2i(0,32)
	var ready_body: Image=ready.body_atlas.get_image().get_region(Rect2i(Vector2i.ZERO,ready.cell_size))
	var ready_mask: Image=ready.hand_atlas.get_image().get_region(Rect2i(Vector2i.ZERO,ready.cell_size))
	for key in KEYS.size():
		var body := Image.create(CELL.x,CELL.y,false,Image.FORMAT_RGBA8)
		var mask := Image.create(CELL.x,CELL.y,false,Image.FORMAT_RGBA8)
		var near: Vector2
		var far: Vector2
		var near_axis: Vector2
		var far_axis: Vector2
		var head: Rect2
		var generated: int=KEYS[key]
		if generated<0:
			body.blit_rect(ready_body,Rect2i(Vector2i.ZERO,ready.cell_size),ready_origin)
			mask.blit_rect(ready_mask,Rect2i(Vector2i.ZERO,ready.cell_size),ready_origin)
			near=ready.primary_hands[0]+Vector2(ready_origin)
			far=ready.offhand.hands[0]+Vector2(ready_origin)
			near_axis=ready.secondary_hands[0]+Vector2(ready_origin)
			far_axis=ready.offhand.axes[0]+Vector2(ready_origin)
			head=Rect2(ready.identity_regions[0].position+Vector2(ready_origin),ready.identity_regions[0].size)
		else:
			var cell: Dictionary=cells[generated]
			var item: Dictionary=board.keys[generated]
			var density: float=board.density
			var offset := Vector2(96-item.socket[0]*density,FOOT-item.source_sole*density)
			for y in CELL.y:
				for x in CELL.x:
					var source_point := Vector2i(((Vector2(x,y)-offset)/density).round())
					if not Rect2i(Vector2i.ZERO,cell.image.get_size()).has_point(source_point): continue
					var color: Color=cell.image.get_pixelv(source_point)
					if color.a*255<recipe.alpha_threshold or native.guide(color): continue
					body.set_pixel(x,y,Color(roundf(color.r*31)/31,roundf(color.g*31)/31,roundf(color.b*31)/31,1))
			var sole_shift := FOOT+1-body.get_used_rect().end.y
			if sole_shift:
				var registered := Image.create(CELL.x,CELL.y,false,Image.FORMAT_RGBA8)
				registered.blit_rect(body,Rect2i(Vector2i.ZERO,CELL),Vector2i(0,sole_shift))
				body=registered
				offset.y+=sole_shift
			near=_snap_palm(body,Vector2(item.primary.grip[0],item.primary.grip[1])*density+offset)
			far=_snap_palm(body,Vector2(item.secondary.grip[0],item.secondary.grip[1])*density+offset,near)
			var nd := Vector2(item.primary.direction[0],item.primary.direction[1]).normalized()
			var fd := Vector2(item.secondary.direction[0],item.secondary.direction[1]).normalized()
			near_axis=near-nd*7
			far_axis=far-fd*7
			head=Rect2(Vector2(82,item.head_top*density+offset.y),Vector2(29,roundi((item.socket[1]-item.head_top+1)*density)))
			anatomy[view+"/"+action+"/"+str(generated)]=body.duplicate()
			var composed := Image.create(CELL.x,CELL.y,false,Image.FORMAT_RGBA8)
			_bake_weapon(composed,steel,near,nd,ready.weapon_primary_grip)
			_bake_weapon(composed,steel,far,fd,ready.offhand.grip)
			composed.blend_rect(body,Rect2i(Vector2i.ZERO,CELL),Vector2i.ZERO)
			body=composed
			var used := body.get_used_rect()
			assert(Rect2i(2,2,188,188).encloses(used),"Attack or rigid blade touches atlas boundary: "+view+"/"+action+"/"+str(generated))
		var origin := Vector2i(key%4*CELL.x,key/4*CELL.y)
		atlas.blit_rect(body,Rect2i(Vector2i.ZERO,CELL),origin)
		hands.blit_rect(mask,Rect2i(Vector2i.ZERO,CELL),origin)
		clip.pose_order.append(key)
		clip.primary_hands.append(near)
		clip.secondary_hands.append(near_axis)
		clip.offhand.hands.append(far)
		clip.offhand.axes.append(far_axis)
		clip.identity_regions.append(head)
		clip.lift_pixels.append(_lift(generated) if action=="hop_spin" and generated>=0 else 0)
		clip.single_hand_poses.append(1)
		clip.stowed_poses.append(0)
		clip.released_poses.append(0)
		clip.ground_clipped_poses.append(0)
		clip.weapon_behind_body.append(ready.weapon_behind_body[0] if generated<0 else 1)
		clip.offhand.behind_body.append(ready.offhand.behind_body[0] if generated<0 else 1)
		clip.primary_visible_poses.append(1 if generated<0 else 0)
		clip.offhand.visible_poses.append(1 if generated<0 else 0)
		records.append({"view":view,"action":action,"key":key,"source_pose":generated,"source":board.source,"source_sha256":board.sha256,"density":board.density,"whole_anatomy":true,"baked_steel":generated>=0,"head":var_to_str(head),"bounds":var_to_str(body.get_used_rect())})
	clip.body_atlas=ImageTexture.create_from_image(atlas)
	clip.hand_atlas=ImageTexture.create_from_image(hands)
	assert(clip.has_valid_layout(),"Invalid generated attack layout")
	return clip

func _cells(path: String) -> Array[Dictionary]:
	if source_cells.has(path): return source_cells[path]
	var rows := native.sheet_cells(Image.load_from_file(path),2,4)
	var cells: Array[Dictionary]=[]
	for row in rows:
		for cell in row:
			_clear_guide_core(cell,cell.blade)
			_clear_guide_core(cell,cell.shaft)
			cells.append(cell)
	assert(cells.size()==8,"Wrong generated attack grid")
	source_cells[path]=cells
	return cells

func _clear_guide_core(cell: Dictionary,points: Array) -> void:
	# Some generated colored registration rods contain a white highlight.
	# Remove that owned core as well; it is not character anatomy/armor.
	if points.size()<3: return
	var local := PackedVector2Array()
	for point in points: local.append(point-Vector2(cell.crop.position))
	var hull := Geometry2D.convex_hull(local)
	var body: Image=cell.image
	var bounds := Rect2(local[0],Vector2.ZERO)
	for point in local: bounds=bounds.expand(point)
	var area := Rect2i(bounds.grow(2)).intersection(Rect2i(Vector2i.ZERO,body.get_size()))
	for y in range(area.position.y,area.end.y):
		for x in range(area.position.x,area.end.x):
			var c:=body.get_pixel(x,y)
			if c.a<.65 or _leather(c) or (c.r>c.g*1.5 and c.r>c.b*1.5): continue
			var point:=Vector2(x,y)
			var owned:=Geometry2D.is_point_in_polygon(point,hull)
			if not owned:
				for edge in range(1,hull.size()):
					if point.distance_to(Geometry2D.get_closest_point_to_segment(point,hull[edge-1],hull[edge]))<=1.5:
						owned=true
						break
			if owned: body.set_pixel(x,y,Color(0,0,0,0))

func _solid_bounds(image: Image) -> Rect2i:
	var mask:=image.duplicate()
	for y in image.get_height():
		for x in image.get_width():
			if mask.get_pixel(x,y).a<180.0/255: mask.set_pixel(x,y,Color(0,0,0,0))
	return mask.get_used_rect()

func _head_top(image: Image,socket: Vector2) -> int:
	var rows: Array[int]=[]
	var peak := 0
	var radius := maxi(12,roundi(image.get_height()*.22))
	for y in range(0,mini(image.get_height(),roundi(socket.y))):
		var count := 0
		for x in range(maxi(0,roundi(socket.x)-radius),mini(image.get_width(),roundi(socket.x)+radius)):
			var c:=image.get_pixel(x,y)
			if c.a>.8 and c.r>=.10 and c.r<=.38 and c.g>=.08 and absf(c.r-c.g)<.08 and c.b<c.r+.04: count+=1
		rows.append(count)
		peak=maxi(peak,count)
	for y in rows.size():
		if rows[y]>=maxi(4,roundi(peak*.12)): return maxi(0,y-3)
	assert(false,"Cannot locate complete generated head")
	return 0

func _leather(c: Color) -> bool:
	return c.a>.8 and c.r>.20 and c.r<.70 and c.r>c.g*1.30 and c.g>c.b*1.15

func _guide(cell: Dictionary,points: Array,socket: Vector2,other: Dictionary={}) -> Dictionary:
	var body: Image=cell.image
	var center := Vector2.ZERO
	var direction := Vector2.RIGHT
	if points.size()>=3:
		for p in points: center+=p-Vector2(cell.crop.position)
		center/=points.size()
		var xx:=0.0; var yy:=0.0; var xy:=0.0
		for p in points:
			var d: Vector2=p-Vector2(cell.crop.position)-center
			xx+=d.x*d.x; yy+=d.y*d.y; xy+=d.x*d.y
		direction=Vector2.from_angle(.5*atan2(2*xy,xx-yy))
	else:
		# A genuinely occluded rear guide may be hidden by the complete body.
		# Use the opposite closed glove, never an invented/detached arm.
		center=socket+Vector2(-body.get_width()*.20,body.get_height()*.20)
		if not other.is_empty(): center=Vector2(other.grip[0],other.grip[1])+Vector2(-body.get_width()*.18,0)
	var best := INF
	var palm := center
	for y in range(0,mini(body.get_height(),roundi(socket.y+body.get_height()*.5))):
		for x in body.get_width():
			if not _leather(body.get_pixel(x,y)): continue
			var point:=Vector2(x,y)
			if not other.is_empty() and point.distance_to(Vector2(other.grip[0],other.grip[1]))<body.get_height()*.025: continue
			var score := point.distance_squared_to(center)
			if score<best: best=score; palm=point
	assert(best<INF,"No complete leather palm for source guide")
	if direction.dot(center-palm)<0: direction=-direction
	# Move from the rod boundary into the closed palm, then snap to leather.
	var target := palm-direction*4
	var closest := INF
	for y in range(maxi(0,roundi(target.y)-6),mini(body.get_height(),roundi(target.y)+7)):
		for x in range(maxi(0,roundi(target.x)-6),mini(body.get_width(),roundi(target.x)+7)):
			if not _leather(body.get_pixel(x,y)): continue
			var point:=Vector2(x,y)
			var distance:=point.distance_squared_to(target)
			if distance<closest: closest=distance; palm=point
	return {"grip":[palm.x,palm.y],"direction":[direction.x,direction.y],"guide_pixels":points.size(),"occluded_guide":points.size()<3}

func _snap_palm(body: Image,target: Vector2,other:=Vector2.INF) -> Vector2:
	var best:=INF
	var palm:=target.round()
	for y in range(maxi(0,roundi(target.y)-5),mini(body.get_height(),roundi(target.y)+6)):
		for x in range(maxi(0,roundi(target.x)-5),mini(body.get_width(),roundi(target.x)+6)):
			if not _leather(body.get_pixel(x,y)): continue
			var point:=Vector2(x,y)
			if other!=Vector2.INF and point.distance_to(other)<1.5: continue
			var distance:=point.distance_squared_to(target)
			if distance<best: best=distance; palm=point
	assert(best<INF,"Native palm disappeared at calibrated density")
	return palm

func _bake_weapon(canvas: Image,steel: Image,palm: Vector2,direction: Vector2,grip: Vector2) -> void:
	var inverse := Transform2D(direction.angle()-Vector2.UP.angle(),palm).affine_inverse()
	for y in CELL.y:
		for x in CELL.x:
			var texel := Vector2i((inverse*Vector2(x,y)+grip).round())
			if not Rect2i(Vector2i.ZERO,steel.get_size()).has_point(texel): continue
			var color:=steel.get_pixelv(texel)
			if color.a>.9:
				color.a=1
				canvas.set_pixel(x,y,color)

func _lift(key: int) -> float:
	return [0.0,-3.0,-8.0,-12.0,-9.0,-4.0,0.0,0.0][key]
