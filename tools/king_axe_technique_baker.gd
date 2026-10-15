extends RefCounted
## Offline only. Complete generated bodies, ONE fixed steel asset in every cel.
const SOURCE := "res://art_source/generated/characters/king/iron_beard_motion_2026_10_15/"
const Pose = preload("res://data/weapons/weapon_family_pose_definition.gd")
var _owner: SceneTree
var _recipe: Dictionary
var _steel: Image
var _frames: Dictionary = {}
var _records: Array[Dictionary] = []
var _colors: Dictionary = {}
var _weapon_palette: Array[Color] = []

func bake(builder: SceneTree) -> bool:
	_owner=builder
	_recipe=JSON.parse_string(FileAccess.get_file_as_string(SOURCE+"registration-recipe.json"))
	_owner._check(FileAccess.get_sha256("res://data/weapons/families/iron_beard/combo.tres")==_recipe.combat_sha256,"Canonical axe retains combat clocks")
	_publish_weapon()
	for view in ["side","up","down","turn"]: _register_board(view)
	for view in ["side","up","down"]:
		_idle(view)
		_run(view)
		for action in ["chop","rise","thrust","slam","spin"]: _attack(view,action)
	FileAccess.open(SOURCE+"registration.json",FileAccess.WRITE).store_string(JSON.stringify({"count":_records.size(),"actors":_records,"weapon_sha256":FileAccess.get_sha256("res://"+_recipe.weapon.output),"cell":[256,256],"sole":[128,158],"scale":0.5},"\t")+"\n")
	return _owner.failures==0 and _owner._clips.has("down-spin")

func _publish_weapon() -> void:
	var data: Dictionary=_recipe.weapon
	_owner._check(FileAccess.get_sha256(_source_path(data.source))==data.source_sha256,"Generated canonical axe source")
	var source:=Image.load_from_file(_source_path(data.source))
	var palette:=Image.load_from_file("res://assets/characters/playable/king/iron_beard_unified/iron_beard_slim.png")
	for y in palette.get_height():
		for x in palette.get_width():
			var color:=palette.get_pixel(x,y)
			if color.a>.95 and not _weapon_palette.has(color): _weapon_palette.append(color)
	_steel=Image.create(80,96,false,Image.FORMAT_RGBA8)
	var grip:=Vector2(data.grip[0],data.grip[1])
	for y in 96:
		for x in 80:
			var point:=Vector2i(((Vector2(x,y)-grip)/float(data.density)+Vector2(data.source_grip[0],data.source_grip[1])).round())
			if not Rect2i(0,0,source.get_width(),source.get_height()).has_point(point): continue
			var color:=source.get_pixelv(point)
			if color.a*255>=240: _steel.set_pixel(x,y,_color(color,true))
	_owner._check(Rect2i(5,5,70,86).encloses(_steel.get_used_rect()),"Full canonical axe has safe padding")
	var path: String="res://"+data.output
	_owner._check(_steel.save_png(path)==OK,"Publish compact single-bit axe")
	_owner._axe=_texture(_steel,path)
	var icon:=Image.create(64,64,false,Image.FORMAT_RGBA8)
	var raster:=_steel.get_region(_steel.get_used_rect())
	raster.resize(roundi(raster.get_width()*52.0/raster.get_height()),52,Image.INTERPOLATE_NEAREST)
	icon.blit_rect(raster,Rect2i(Vector2i.ZERO,raster.get_size()),(Vector2i(64,64)-raster.get_size())/2)
	_owner._check(icon.save_png("res://"+data.icon)==OK,"Bag icon uses the same canonical axe")

func _register_board(view: String) -> void:
	var board: Dictionary=_recipe.boards[view]
	_owner._check(FileAccess.get_sha256(_source_path(board.source))==board.sha256,"Complete body-only guide source "+view)
	var image:=Image.load_from_file(_source_path(board.source))
	for info: Dictionary in board.keys:
		var frame:=_body(image,info,float(board.density))
		var rig: Dictionary=info.rig
		var axis:=Vector2(rig.axis[0],rig.axis[1]).normalized()
		frame.angle=axis.angle()-PI/2
		frame.primary=frame.origin+(Vector2(rig.primary[0],rig.primary[1])-Vector2(frame.bounds.position))*float(board.density)
		frame.secondary=frame.origin+(Vector2(rig.secondary[0],rig.secondary[1])-Vector2(frame.bounds.position))*float(board.density)
		# Source-owned grip order already identifies the real head and butt.
		# A camera direction must never flip an axe during an overhead chop.
		frame.primary=frame.primary.round()
		frame.secondary=frame.secondary.round()
		if frame.secondary.distance_to(frame.primary)<1: frame.secondary=frame.primary+axis*2
		frame.hand_radius=clampf(float(rig.hand_radius)*float(board.density)*1.3,2.0,4.0)
		frame.view=view
		frame.index=int(info.index)
		frame.head_bounds=Rect2(info.head[0],info.head[1],info.head[2],info.head[3])
		frame.occluded=bool(rig.get("occluded",false))
		_frames[view+"-"+str(int(info.index))]=frame
	# Consistent edge handedness within each cut prevents head flips between keys.
	for action: String in board.actions:
		var indices: Array=board.actions[action]
		var score:=0.0
		var contact_keys: Array=[2] if indices.size()<=4 else [3,4,5]
		if action=="spin": contact_keys=[0,1,2,3,4,5,6,7]
		for key: int in contact_keys:
			var current: Dictionary=_frames[view+"-"+str(int(indices[key]))]
			var before: Dictionary=_frames[view+"-"+str(int(indices[maxi(0,key-1)]))]
			var after: Dictionary=_frames[view+"-"+str(int(indices[mini(indices.size()-1,key+1)]))]
			var velocity: Vector2=(after.primary+Vector2(0,-23).rotated(after.angle))-(before.primary+Vector2(0,-23).rotated(before.angle))
			if action=="thrust": velocity=Vector2.RIGHT if view=="side" else (Vector2.UP if view=="up" else Vector2.DOWN)
			if velocity.length()>.1: score+=Vector2.LEFT.rotated(current.angle).dot(velocity.normalized())
		for index: Variant in indices:
			var frame: Dictionary=_frames[view+"-"+str(int(index))]
			frame.edge_mirrored=bool(_recipe.edge_mirrored.get(view,{}).get(action,score<0))
			_compose(frame)

func _body(source: Image,info: Dictionary,density: float) -> Dictionary:
	var bounds:=Rect2i(info.bounds[0],info.bounds[1],info.bounds[2],info.bounds[3])
	var ground:=Vector2(info.ground[0],info.ground[1])-Vector2(bounds.position)
	var origin:=Vector2(128,158)-ground*density
	var isolated:=_isolate(source,bounds,int(info.component_pixels))
	var body:=Image.create(256,256,false,Image.FORMAT_RGBA8)
	var low:=Vector2i(origin.floor()).clamp(Vector2i.ZERO,Vector2i(255,255))
	var high:=Vector2i((origin+Vector2(bounds.size)*density+Vector2.ONE).ceil()).clamp(Vector2i.ZERO,Vector2i(256,256))
	for y in range(low.y,high.y):
		for x in range(low.x,high.x):
			var point:=Vector2i(((Vector2(x,y)-origin)/density).round())
			if not Rect2i(Vector2i.ZERO,isolated.get_size()).has_point(point): continue
			var color:=isolated.get_pixelv(point)
			if color.a*255<240 or _guide(color): continue
			# Clear only black guide outlines directly touching guide paint.
			if maxf(color.r,maxf(color.g,color.b))<.12 and _near_guide(isolated,point): continue
			body.set_pixel(x,y,_color(color,false))
	_owner._check(Rect2i(8,8,240,240).encloses(body.get_used_rect()),"Complete body padding")
	return {"body":body,"bounds":bounds,"origin":origin,"density":density,"source":source}

func _isolate(source: Image,bounds: Rect2i,expected: int) -> Image:
	var crop:=source.get_region(bounds)
	var data:=crop.get_data()
	var width:=crop.get_width()
	var height:=crop.get_height()
	var seen:=PackedByteArray()
	seen.resize(width*height)
	var largest:=PackedInt32Array()
	for start in width*height:
		if seen[start] or data[start*4+3]<240: continue
		var queue:=PackedInt32Array([start])
		seen[start]=1
		var cursor:=0
		while cursor<queue.size():
			var current:=queue[cursor]
			cursor+=1
			var point:=Vector2i(current%width,current/width)
			for dy in range(-1,2):
				for dx in range(-1,2):
					var next:=point+Vector2i(dx,dy)
					if next.x<0 or next.y<0 or next.x>=width or next.y>=height: continue
					var index:=next.y*width+next.x
					if seen[index] or data[index*4+3]<240: continue
					seen[index]=1
					queue.append(index)
		if queue.size()>largest.size(): largest=queue
	_owner._check(largest.size()==expected,"Complete connected actor extracted without neighboring row fragments")
	var result:=Image.create(width,height,false,Image.FORMAT_RGBA8)
	for pixel in largest:
		var point:=Vector2i(pixel%width,pixel/width)
		result.set_pixelv(point,crop.get_pixelv(point))
	return result

func _compose(frame: Dictionary) -> void:
	var body: Image=frame.body
	var result:=Image.create(256,256,false,Image.FORMAT_RGBA8)
	var basis:=Transform2D(frame.angle,frame.primary)
	var attachment_grip:=Vector2(44,44)
	if frame.edge_mirrored: basis=basis*Transform2D(Vector2(-1,0),Vector2(0,1),Vector2.ZERO)
	var behind: bool=frame.view=="up" or (frame.view=="turn" and frame.index in [5,6,7])
	if not behind: result.blit_rect(body,Rect2i(0,0,256,256),Vector2i.ZERO)
	_stamp(result,basis,attachment_grip)
	if behind: result.blend_rect(body,Rect2i(0,0,256,256),Vector2i.ZERO)
	else:
		# Foreground fingers come from this SAME complete cel, at the SAME
		# coordinates. This is depth compositing, never transplanted anatomy.
		for palm: Vector2 in [frame.primary,frame.secondary]:
			var radius: float=frame.hand_radius
			for y in range(maxi(0,floori(palm.y-radius)),mini(256,ceili(palm.y+radius+1))):
				for x in range(maxi(0,floori(palm.x-radius)),mini(256,ceili(palm.x+radius+1))):
					if Vector2(x,y).distance_to(palm)>radius: continue
					var color:=body.get_pixel(x,y)
					if color.a>.95: result.set_pixel(x,y,color)
	_owner._check(is_equal_approx(absf(basis.determinant()),1),"Canonical axe never scales with view or source rod")
	_owner._check(Rect2i(5,5,246,246).encloses(result.get_used_rect()),"Full axe/head/boots stay inside cell")
	frame.rendered=result
	var hash:=HashingContext.new()
	hash.start(HashingContext.HASH_SHA256)
	hash.update(result.get_data())
	var head: Rect2=frame.head_bounds
	var head_native:=Rect2(frame.origin+(head.position-Vector2(frame.bounds.position))*float(frame.density),head.size*float(frame.density))
	_records.append({"view":frame.view,"index":frame.index,"density":frame.density,"grip":[frame.primary.x,frame.primary.y],"secondary":[frame.secondary.x,frame.secondary.y],"attachment_grip":[attachment_grip.x,attachment_grip.y],"canonical_basis":[basis.x.x,basis.x.y,basis.y.x,basis.y.y,basis.origin.x,basis.origin.y],"head_bounds":[head_native.position.x,head_native.position.y,head_native.size.x,head_native.size.y],"occluded":frame.occluded,"body_bounds":var_to_str(body.get_used_rect()),"cel_sha256":hash.finish().hex_encode()})

func _stamp(target: Image,basis: Transform2D,grip: Vector2) -> void:
	var inverse:=basis.affine_inverse()
	for y in range(maxi(0,floori(basis.origin.y-85)),mini(256,ceili(basis.origin.y+85))):
		for x in range(maxi(0,floori(basis.origin.x-85)),mini(256,ceili(basis.origin.x+85))):
			var point:=Vector2i((inverse*Vector2(x,y)+grip).round())
			if not Rect2i(0,0,80,96).has_point(point): continue
			var color:=_steel.get_pixelv(point)
			if color.a>.95: target.set_pixel(x,y,color)

func _idle(view: String) -> void:
	var board: Dictionary=_recipe.boards.idle
	_owner._check(FileAccess.get_sha256(_source_path(board.source))==board.sha256,"Complete relaxed idle source "+view)
	var image:=Image.load_from_file(_source_path(board.source))
	var lane: Dictionary=board.lanes[view]
	var atlas:=Image.create(1024,512,false,Image.FORMAT_RGBA8)
	var clip:=_new_clip(8)
	var order: Array=[0,0,0,0,0,1,2,0]
	for key in 8:
		var info: Dictionary=board.keys[int(lane.keys[order[key]])]
		var frame:=_body(image,info,float(lane.density))
		atlas.blit_rect(frame.body,Rect2i(0,0,256,256),Vector2i(key%4,key/4)*256)
		var head:=Rect2(info.head[0],info.head[1],info.head[2],info.head[3])
		var crown: Vector2=frame.origin+(Vector2(head.get_center().x,head.end.y)-Vector2(frame.bounds.position))*float(lane.density)
		_back_mount(clip,view,crown+Vector2(-7 if view=="side" else 0,8),key)
	clip.body_atlas=_save_texture(atlas,view+"/idle_body.png")
	clip.hand_atlas=load(_owner.REAPER+"locomotion_hands.png")
	clip.allow_rest=true
	clip.rest_start_pose=1
	clip.rest_transition_end_pose=7
	clip.rest_transition_seconds=1.7
	clip.rest_loop_window=Vector2(5,7)
	clip.rest_loop_seconds=3.8
	clip.retrieval_end_pose=0
	_owner._clips[view+"-idle"]=clip

func _run(view: String) -> void:
	var lane: Dictionary=_recipe.running[view]
	_owner._check(FileAccess.get_sha256("res://"+lane.body)==lane.sha256,"Accepted running BODY stays exact "+view)
	var clip:=_new_clip(8)
	clip.body_atlas=load("res://"+lane.body)
	clip.hand_atlas=load(_owner.REAPER+"locomotion_hands.png")
	for key in 8: _back_mount(clip,view,Vector2(lane.anchors[key][0],lane.anchors[key][1]),key)
	_owner._clips[view+"-run"]=clip

func _back_mount(clip: Resource,view: String,anchor: Vector2,key: int) -> void:
	anchor=anchor.round()
	clip.primary_hands.append(anchor)
	clip.secondary_hands.append(anchor+Vector2.DOWN.rotated(deg_to_rad(-25))*12)
	clip.stowed_poses[key]=1
	clip.weapon_behind_body[key]=0 if view=="up" else 1

func _attack(view: String,action: String) -> void:
	var ready: Resource=_owner._clips[view+"-idle"]
	var clip:=_new_clip(16 if action=="spin" else 13)
	var order: Array=_recipe.action_sources[view].get(action,[])
	if action=="spin":
		var start: int={"side":0,"down":2,"up":6}[view]
		order=[-1,start,start,(start+1)%8,(start+2)%8,(start+3)%8,(start+4)%8,(start+5)%8,(start+6)%8,(start+7)%8,start,start,start,-1,start,-1]
	var atlas:=Image.create(1024,1024,false,Image.FORMAT_RGBA8)
	for key in clip.pose_count:
		var generated: int=order[key]
		var cel: Image
		if generated<0:
			cel=ready.body_atlas.get_image().get_region(Rect2i(0,0,256,256))
			clip.primary_hands.append(ready.primary_hands[0])
			clip.secondary_hands.append(ready.secondary_hands[0])
			clip.stowed_poses[key]=1
			clip.weapon_behind_body[key]=ready.weapon_behind_body[0]
		else:
			var frame: Dictionary=_frames[("turn" if action=="spin" else view)+"-"+str(generated)]
			cel=frame.rendered
			clip.primary_hands.append(frame.primary)
			clip.secondary_hands.append(frame.secondary)
			clip.primary_visible_poses[key]=0
			if action=="slam": clip.lift_pixels[key]=_recipe.jump_lift[key]
		atlas.blit_rect(cel,Rect2i(0,0,256,256),Vector2i(key%4,key/4)*256)
	clip.body_atlas=_save_texture(atlas,view+"/"+action+"_body.png")
	clip.hand_atlas=load(_owner.REAPER+"attack_hands.png")
	clip.phase_windows=PackedVector2Array([Vector2(0,3),Vector2(4,6),Vector2(7,10)])
	clip.queued_recovery_window=Vector2(11,12)
	clip.pose_weights=PackedFloat32Array(_recipe.weights)
	if action=="spin":
		clip.phase_windows=PackedVector2Array([Vector2(0,3),Vector2(4,10),Vector2(11,13)])
		clip.queued_recovery_window=Vector2(14,15)
		clip.pose_weights=PackedFloat32Array([.65,.75,1.15,1,.9,1,1,1,1,1,.9,.8,1,.8,1,1])
	_owner._check(clip.has_valid_layout(),"Canonical axe action layout "+view+" "+action)
	_owner._clips[view+"-"+action]=clip

func _source_path(path: String) -> String:
	return path if path.begins_with("res://") else SOURCE+path

func _new_clip(count: int) -> Resource:
	var clip:=Pose.new()
	clip.cell_size=Vector2i(256,256)
	clip.pose_count=count
	clip.columns=4
	clip.weapon_texture=_owner._axe
	clip.weapon_primary_grip=Vector2(_recipe.weapon.grip[0],_recipe.weapon.grip[1])
	clip.weapon_handle_axis=Vector2.DOWN
	clip.weapon_tip=Vector2(29,24)
	clip.mirror_cutting_edge=false
	clip.primary_hands=PackedVector2Array()
	clip.secondary_hands=PackedVector2Array()
	clip.pose_order=PackedInt32Array()
	clip.lift_pixels=PackedFloat32Array()
	clip.weapon_behind_body=PackedByteArray()
	clip.primary_visible_poses=PackedByteArray()
	clip.single_hand_poses=PackedByteArray()
	clip.stowed_poses=PackedByteArray()
	clip.released_poses=PackedByteArray()
	clip.ground_clipped_poses=PackedByteArray()
	for key in count:
		clip.pose_order.append(key)
		clip.lift_pixels.append(0)
		clip.weapon_behind_body.append(1)
		clip.primary_visible_poses.append(1)
		clip.single_hand_poses.append(1)
		clip.stowed_poses.append(0)
		clip.released_poses.append(0)
		clip.ground_clipped_poses.append(0)
	clip.allow_rest=false
	clip.interpolate_blade_angles=false
	return clip

func _save_texture(image: Image,relative: String) -> Texture2D:
	var path: String=_owner.OUTPUT+relative
	_owner._check(image.save_png(path)==OK,"Canonical pose atlas "+relative)
	return _texture(image,path)

func _texture(image: Image,path: String) -> Texture2D:
	var texture:=ImageTexture.create_from_image(image)
	texture.take_over_path(path)
	return texture

func _guide(color: Color) -> bool:
	return (color.r>.12 and color.b>.12 and color.b>color.r*.65 and color.r>color.b*.65 and color.g<minf(color.r,color.b)*.6) or (color.g>color.r*1.5 and color.b>color.r*1.5 and minf(color.g,color.b)>.24) or (color.g>color.r*1.4 and color.g>color.b*1.3 and color.g>.24)

func _near_guide(image: Image,point: Vector2i) -> bool:
	for dy in range(-2,3):
		for dx in range(-2,3):
			var p:=point+Vector2i(dx,dy)
			if Rect2i(Vector2i.ZERO,image.get_size()).has_point(p) and _guide(image.get_pixelv(p)): return true
	return false

func _color(color: Color,weapon: bool) -> Color:
	var key:=str(color.to_rgba32())+("w" if weapon else "b")
	if _colors.has(key): return _colors[key]
	var palette: Array[Color]=_weapon_palette if weapon else _owner._palette
	var best:=palette[0]
	var distance:=INF
	for candidate in palette:
		var delta:=Vector3(color.r-candidate.r,color.g-candidate.g,color.b-candidate.b).length_squared()
		if delta<distance: best=candidate; distance=delta
	_colors[key]=best
	return best
