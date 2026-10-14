extends "res://tools/build_king_iron_reaper_returning.gd"

## The owner's chosen running identity is the appearance reference. Complete
## generated actors use a common palette, head/torso calibration and collar
## registration; one unchanged rigid weapon serves every action.
const STYLE := "res://art_source/generated/characters/king/iron_reaper_style_unified_2026_10_14/"
var style_recipe: Dictionary
var motion_recipe: Dictionary
var _palette: Array[Color] = []
var _color_cache: Dictionary = {}
var _ground_anchors: Dictionary = {}
var _glove_corrections: Dictionary

func _build() -> void:
	style_recipe = JSON.parse_string(FileAccess.get_file_as_string(STYLE + "registration-recipe.json"))
	motion_recipe = JSON.parse_string(FileAccess.get_file_as_string(STYLE + "motion-authoring.json"))
	_glove_corrections = JSON.parse_string(FileAccess.get_file_as_string(STYLE + "glove-continuity.json"))
	_check(FileAccess.get_sha256(STYLE+str(_glove_corrections.generated_color_reference))==_glove_corrections.reference_sha256,"Generated glove color reference preserved")
	rework = JSON.parse_string(FileAccess.get_file_as_string(REWORK + "registration-recipe.json"))
	recipe = JSON.parse_string(FileAccess.get_file_as_string(SOURCE + "registration-recipe.json"))
	cell = Vector2i(256,256)
	foot_plane = 158
	_read_palette()
	for direction in ["side","up","down"]:
		# Reproduce the approved running byte for byte, including its resources.
		_register(direction + "-run")
		for action in ["idle","sweep","return","throw","reap"]: _register_style(direction,action)
	if failures: quit(1); return
	for direction in ["side","up","down"]:
		_publish_new(direction,"run")
		for action in ["idle","sweep","return","throw","reap"]: _publish_style(direction,action)
	_check(preload("res://tools/build_iron_reaper_fx.gd").build()==OK,"24 complete generated ribbons published")
	_publish_ribbon_layout()
	_verify_current()
	FileAccess.open(STYLE + "registration.json",FileAccess.WRITE).store_string(JSON.stringify({"appearance":"approved SIDE running", "records":records,"checks":checks,"failures":failures},"\t")+"\n")
	print("IRON_REAPER_UNIFIED_BUILD checks=",checks," failures=",failures)
	quit(1 if failures else 0)

func _read_palette() -> void:
	var known := {}
	for direction in ["side","up","down"]:
		var image := Image.load_from_file(OUTPUT+direction+"/run_body.png")
		for y in image.get_height():
			for x in image.get_width():
				var color := image.get_pixel(x,y)
				if color.a<0.95: continue
				var key := color.to_rgba32()
				if not known.has(key): _palette.append(color); known[key] = true
	_check(not _palette.is_empty(),"Approved running palette available")

func _matched_color(color: Color) -> Color:
	var quantized := Color(roundf(color.r*31)/31,roundf(color.g*31)/31,roundf(color.b*31)/31,1)
	var key := quantized.to_rgba32()
	if _color_cache.has(key): return _color_cache[key]
	var closest := _palette[0]
	var distance := INF
	for candidate in _palette:
		var next := Vector3(candidate.r-quantized.r,candidate.g-quantized.g,candidate.b-quantized.b).length_squared()
		if next<distance: distance=next; closest=candidate
	_color_cache[key] = closest
	return closest

func _register_style(direction: String, action: String) -> void:
	var key := direction + "-" + action
	var board: Dictionary = style_recipe.boards[key]
	var path := STYLE + str(board.source)
	_check(FileAccess.get_sha256(path)==board.sha256,key+" complete source ownership")
	var source := Image.load_from_file(path)
	var parts := _components(source,240)
	_check(parts.size()==8,key+" eight connected actors")
	var images: Array[Image] = []
	var grips := []
	var ground_anchors := []
	var density: float = board.density
	for index in 8:
		var info: Dictionary = board.keys[index]
		var selected: Dictionary = {}
		for part in parts:
			if part.bounds==_rect(info.source_bounds): selected=part; break
		_check(not selected.is_empty(),key+" actor component "+str(index))
		if selected.is_empty(): return
		var original := _extract(source,selected)
		var collar := Vector2(info.collar[0],info.collar[1])
		var origin := Vector2(128,style_recipe.collar_y[direction])-collar*density
		if action!="idle": ground_anchors.append(origin+Vector2(info.ground_anchor[0],info.ground_anchor[1])*density)
		var image := Image.create(256,256,false,Image.FORMAT_RGBA8)
		for y in 256:
			for x in 256:
				var point := Vector2i(((Vector2(x,y)-origin)/density).round())
				if not Rect2i(Vector2i.ZERO,original.get_size()).has_point(point): continue
				var color := original.get_pixelv(point)
				if color.a*255>=240: image.set_pixel(x,y,_glove_color(key,index,Vector2(point),color))
		var used := image.get_used_rect()
		_check(Rect2i(4,4,248,248).encloses(used),key+" complete cel gutter "+str(index))
		var head_span: float = info.head_bounds[2]*density
		# Overhead gloves hide the hair's sides; keep the same whole-pose density
		# instead of inflating the actor to compensate for that visible occlusion.
		var minimum_head := 17.0 if info.get("head_occluded",false) else 20.0
		_check(head_span>=minimum_head and head_span<=28,key+" running-sized head "+str(index))
		var main := origin+Vector2(info.primary[0],info.primary[1])*density
		var other := origin+Vector2(info.secondary[0],info.secondary[1])*density
		var palm_occupied := false
		for dy in range(-2,3):
			for dx in range(-2,3):
				var point := Vector2i(main.round())+Vector2i(dx,dy)
				if Rect2i(0,0,256,256).has_point(point) and image.get_pixelv(point).a>0.95: palm_occupied=true
		_check(palm_occupied,key+" steel pivot touches the complete actor's palm "+str(index))
		grips.append([main.round(),other.round()])
		images.append(image)
		records.append({"board":key,"key":index,"density":density,"head_span":head_span,"bounds":[used.position.x,used.position.y,used.size.x,used.size.y],"collar_y":style_recipe.collar_y[direction],"primary":[main.x,main.y],"secondary":[other.x,other.y],"palm_occupied":palm_occupied})
	cels[key] = images
	anchors[key] = grips
	_ground_anchors[key] = ground_anchors

func _glove_color(board: String, key: int, point: Vector2, color: Color) -> Color:
	var mask: Dictionary = _glove_corrections.boards.get(board,{}).get(str(key),{})
	# Only peach exposed hand pixels inside authored local polygons change.
	# Clothing whites, forearms, outline, alpha and all geometry stay exact.
	if mask.is_empty() or color.r<0.65 or color.r-color.g<0.10 or color.g-color.b<0.08: return _matched_color(color)
	for vertices: Array in mask.polygons:
		var polygon := PackedVector2Array()
		for vertex: Array in vertices: polygon.append(Vector2(vertex[0],vertex[1]))
		if Geometry2D.is_point_in_polygon(point,polygon):
			var value := clampf((color.r+color.g+color.b-1.0)/1.4,0,1)
			var ramp: Array = _glove_corrections.brown_ramp
			var brown: Array = ramp[roundi(value*(ramp.size()-1))]
			return _matched_color(Color8(brown[0],brown[1],brown[2]))
	return _matched_color(color)

func _publish_style(direction: String, action: String) -> void:
	var attack := action!="idle"
	var count := 13 if attack else 8
	var order := [-1,0,1,2,3,4,5,6,7,-1,-1,6,7] if attack else range(8)
	if action=="throw": order = [-1,0,1,1,2,3,5,6,7,-1,-1,6,7]
	var atlas := Image.create(1024,1024 if attack else 512,false,Image.FORMAT_RGBA8)
	var primary := []
	var secondary := []
	var visible := []
	var motion: Dictionary = motion_recipe.cuts[action] if attack else {}
	for index in count:
		var source_index: int = order[index]
		var name_key := direction + "-" + ("idle" if source_index<0 else action)
		var source_key := maxi(source_index,0)
		var offset := Vector2i.ZERO
		if attack:
			var lane: Array = motion.body_lane[index]
			var forward := Vector2.RIGHT if direction=="side" else (Vector2.UP if direction=="up" else Vector2.DOWN)
			var effort := forward*float(lane[0])*(1.0 if direction=="side" else float(motion_recipe.depth_compression))+Vector2(0,lane[1])
			offset = Vector2i(effort.limit_length(float(style_recipe.ground_registration.maximum_weight_shift_pixels)).round())
			if source_index>=0:
				var target := Vector2(style_recipe.ground_registration.target[0],style_recipe.ground_registration.target[1])
				var stance: Vector2 = _ground_anchors[name_key][source_key]
				offset += Vector2i((target-stance).round())
				var registered := stance+Vector2(offset)
				_check(registered.distance_to(target)<=3.0,direction+" "+action+" stance stays centered "+str(index))
				records.append({"stance":direction+"-"+action,"key":index,"native_ground":[registered.x,registered.y],"target":[target.x,target.y],"error_pixels":registered.distance_to(target)})
		var complete: Image = cels[name_key][source_key]
		var shifted := Image.create(256,256,false,Image.FORMAT_RGBA8)
		shifted.blit_rect(complete,Rect2i(0,0,256,256),offset)
		_check(Rect2i(4,4,248,248).encloses(shifted.get_used_rect()),direction+" "+action+" weight shift has safe gutters "+str(index))
		var anatomy := complete.get_used_rect()
		_check(complete.get_region(anatomy).get_data()==shifted.get_region(Rect2i(anatomy.position+offset,anatomy.size)).get_data(),direction+" "+action+" approved complete anatomy remains exact "+str(index))
		atlas.blit_rect(shifted,Rect2i(0,0,256,256),Vector2i(index%4,index/4)*256)
		var pair: Array = anchors[name_key][source_key]
		var main: Vector2 = pair[0]+Vector2(offset)
		var other: Vector2 = pair[1]+Vector2(offset)
		if attack:
			# An explicit one-hand shaft direction preserves the full authored arc.
			# Folding a glove vector into the frontal half-plane erased the return
			# and made every upward contact angle identical. No extra hand is drawn.
			var degrees: float = float(motion.shaft_degrees[index])+float(motion_recipe.view_rotation[direction])
			if index==0 or (index>=9 and index<=10): degrees=-90 if index==0 else lerpf(degrees,-90,float(index-8)/2.0)
			other = main+Vector2.from_angle(deg_to_rad(degrees))*12.0
		primary.append_array([main.x,main.y])
		secondary.append_array([other.x,other.y])
		if attack: records.append({"motion":direction+"-"+action,"key":index,"body_offset":[offset.x,offset.y],"shaft_degrees":rad_to_deg((other-main).angle()),"weight":motion.weights[index]})
		visible.append(0 if action=="throw" and index in [4,5,6] else 1)
	var prefix := OUTPUT+direction+"/"+action
	_check(atlas.save_png(prefix+"_body.png")==OK,direction+" "+action+" published")
	var text := _with_rig(_clip_resource(direction,action,count,attack),primary,secondary,visible)
	if attack:
		text += "interpolate_blade_angles = true\n"
		text = _property(text,"pose_weights","PackedFloat32Array(%s)" % _numbers(motion.weights))
	if action=="reap": text = _property(text,"lift_pixels","PackedFloat32Array(%s)" % _numbers(motion.lift_pixels))
	if not attack:
		text = _property(text,"rest_transition_end_pose","7")
		text = _property(text,"rest_transition_seconds","1.4")
		text = _property(text,"rest_loop_window","Vector2(0, 0)")
		text = _property(text,"rest_loop_seconds","4.0")
		text = _property(text,"retrieval_end_pose","7")
	FileAccess.open(prefix+".tres",FileAccess.WRITE).store_string(text)

func _publish_ribbon_layout() -> void:
	var layout: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(STYLE+"ribbon-layout.json"))
	_check(FileAccess.get_sha256(OUTPUT+"slash.png")==layout.source_sha256,"Whole ribbon source matches its fit")
	_check(FileAccess.get_sha256("res://data/weapons/families/iron_reaper/combo.tres")==layout.combat_sha256,"Ribbon fit matches current contact polygons")
	var text := "[gd_resource type=\"Resource\" load_steps=2 format=3]\n[ext_resource type=\"Script\" path=\"res://data/weapons/families/iron_reaper/ribbon_layout.gd\" id=\"1\"]\n[resource]\nscript = ExtResource(\"1\")\nclearance_pixels = %s\n" % str(layout.clearance_pixels)
	for view in ["right","up","down"]:
		var transforms := PackedStringArray()
		for info in layout.views[view]: transforms.append("Transform2D(%s)" % _numbers(info.transform))
		text += "%s = Array[Transform2D]([%s])\n" % [view,", ".join(transforms)]
	FileAccess.open("res://data/weapons/families/iron_reaper/ribbon_layout.tres",FileAccess.WRITE).store_string(text)

func _verify_current() -> void:
	var protected: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(STYLE+"protected-assets.json"))
	for path: String in protected:
		_check(FileAccess.get_sha256("res://"+path)==protected[path],"Approved running/steel/rules preserved "+path)
	for info in JSON.parse_string(FileAccess.get_file_as_string(SOURCE+"protected-assets.json")):
		_check(FileAccess.get_sha256("res://"+str(info.path))==info.sha256,"Other King family preserved "+str(info.path))
