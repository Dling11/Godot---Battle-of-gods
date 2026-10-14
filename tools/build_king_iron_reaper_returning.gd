extends "res://tools/build_king_iron_reaper.gd"

## Registers complete newly generated actors using the crown/upper body,
## not a different planted boot on every cel. Steel stays a rigid sprite.
const REWORK := "res://art_source/generated/characters/king/iron_reaper_returning_2026_10_14/"
var rework: Dictionary
var anchors: Dictionary = {}

func _build() -> void:
	# Compatibility entry; current whole-family style is authoritative.
	super._build()


func _register(key: String) -> void:
	var board: Dictionary = rework.boards[key]
	var path := REWORK + str(board.source)
	_check(FileAccess.get_sha256(path) == board.sha256, key + " original source hash")
	var source := Image.load_from_file(path)
	var parts := _components(source, 240)
	_check(parts.size() == 8, key + " eight complete actors")
	var images: Array[Image] = []
	var grips := []
	for index in 8:
		var info: Dictionary = board.keys[index]
		var selected: Dictionary = {}
		for part in parts:
			if part.bounds == _rect(info.source_bounds): selected = part; break
		_check(not selected.is_empty(), key + " source ownership " + str(index))
		if selected.is_empty(): return
		var original := _extract(source, selected)
		var density: float = board.density
		var bob: int = [0, -1, -2, -1, 0, -1, -2, -1][index] if key.ends_with("run") else 0
		var offset := Vector2(128 - float(info.anchor_x) * density, 101 + bob)
		var image := Image.create(256, 256, false, Image.FORMAT_RGBA8)
		for y in 256:
			for x in 256:
				var point := Vector2i(((Vector2(x, y) - offset) / density).round())
				if not Rect2i(Vector2i.ZERO, original.get_size()).has_point(point): continue
				var color := original.get_pixelv(point)
				if color.a * 255 < 240: continue
				image.set_pixel(x, y, Color(roundf(color.r * 31) / 31, roundf(color.g * 31) / 31, roundf(color.b * 31) / 31, 1))
		var bounds := image.get_used_rect()
		_check(Rect2i(4,4,248,248).encloses(bounds), key + " uncut complete cel " + str(index))
		_check(bounds.size.y>=48 and bounds.size.y<=66,key + " complete anatomy scale " + str(index))
		images.append(image)
		var main := offset + Vector2(info.primary[0], info.primary[1]) * density
		var other := offset + Vector2(info.secondary[0], info.secondary[1]) * density
		grips.append([main.round(), other.round()])
		records.append({"board":key, "key":index, "density":density, "bounds":[bounds.position.x,bounds.position.y,bounds.size.x,bounds.size.y], "primary":[main.x,main.y], "secondary":[other.x,other.y]})
	cels[key] = images
	anchors[key] = grips

func _publish_new(direction: String, action: String) -> void:
	var attack := action == "throw"
	var count := 13 if attack else 8
	var order := [-1,0,1,1,2,3,5,6,7,-1,-1,6,7] if attack else range(8)
	var atlas := Image.create(1024,1024 if attack else 512,false,Image.FORMAT_RGBA8)
	var primary := []
	var secondary := []
	var visible := []
	for index in count:
		var source_key: int = order[index]
		var name_key := direction + "-" + ("idle" if source_key < 0 else action)
		var source_index := maxi(source_key,0)
		atlas.blit_rect(cels[name_key][source_index],Rect2i(0,0,256,256),Vector2i(index%4*256,index/4*256))
		var pair: Array = anchors[name_key][source_index]
		primary.append_array([pair[0].x,pair[0].y])
		secondary.append_array([pair[1].x,pair[1].y])
		visible.append(0 if attack and index in [4,5,6] else 1)
	_check(atlas.save_png(OUTPUT + direction + "/" + action + "_body.png") == OK, direction + " " + action + " saved")
	var text := _clip_resource(direction,action,count,attack)
	text = _with_rig(text,primary,secondary,visible)
	if not attack:
		text = text.replace("rest_transition_end_pose = 4","rest_transition_end_pose = 2").replace("rest_loop_window = Vector2(5, 7)","rest_loop_window = Vector2(2, 7)").replace("rest_loop_seconds = 3.6","rest_loop_seconds = 3.6")
	FileAccess.open(OUTPUT + direction + "/" + action + ".tres",FileAccess.WRITE).store_string(text)

func _with_rig(text: String, primary: Array, secondary: Array, visible: Array) -> String:
	var count := visible.size()
	text = text.replace("../weapon.png","../rigid_weapon.png")
	text = _property(text,"primary_hands","PackedVector2Array(%s)" % _numbers(primary))
	text = _property(text,"secondary_hands","PackedVector2Array(%s)" % _numbers(secondary))
	text = _property(text,"weapon_primary_grip","Vector2(40, 112)")
	text = _property(text,"weapon_handle_axis","Vector2(0, -1)")
	text = _property(text,"weapon_tip","Vector2(90, 82)")
	text = _property(text,"weapon_behind_body","PackedByteArray(%s)" % _numbers(_repeat(count,1)))
	text = _property(text,"primary_visible_poses","PackedByteArray(%s)" % _numbers(visible))
	text = _property(text,"lift_pixels","PackedFloat32Array(%s)" % _numbers(_repeat(count,0)))
	return text

func _property(text: String, property: String, value: String) -> String:
	var lines := text.split("\n")
	for index in lines.size():
		if lines[index].begins_with(property + " = "): lines[index] = property + " = " + value
	return "\n".join(lines)


func _weapon() -> void:
	var source := Image.load_from_file(REWORK + "weapon-source.png")
	var output := Image.create(128,192,false,Image.FORMAT_RGBA8)
	var density: float = rework.weapon.density
	for y in 192:
		for x in 128:
			var point := Vector2i((Vector2(x,y) - Vector2(40,112)) / density + Vector2(364,880))
			if not Rect2i(Vector2i.ZERO,source.get_size()).has_point(point): continue
			var color := source.get_pixelv(point)
			if color.a * 255 >= 240: output.set_pixel(x,y,Color(color.r,color.g,color.b,1))
	_check(output.save_png(OUTPUT + "rigid_weapon.png") == OK,"Straight complete rigid scythe")
	_check(Rect2i(4,4,120,184).encloses(output.get_used_rect()),"Whole rigid weapon has safe transparent gutters")
	for source_y in range(320,1430,8):
		var y := roundi(112 + (source_y-880)*density)
		_check(output.get_pixel(40,y).a>0.95,"Unbroken straight shaft row " + str(y))

func _orbit() -> void:
	var source := Image.load_from_file(REWORK + "orbit-source.png")
	var source_cell := Vector2i(source.get_width()/4,source.get_height()/2)
	var output := Image.create(512,256,false,Image.FORMAT_RGBA8)
	for key in 8:
		var frame := source.get_region(Rect2i(Vector2i(key%4,key/4)*source_cell,source_cell))
		frame.resize(128,128,Image.INTERPOLATE_NEAREST)
		for y in 128:
			for x in 128:
				var color := frame.get_pixel(x,y)
				if color.a*255 < 220: frame.set_pixel(x,y,Color.TRANSPARENT)
		output.blit_rect(frame,Rect2i(0,0,128,128),Vector2i(key%4,key/4)*128)
	_check(output.save_png(OUTPUT + "orbit.png") == OK,"Eight complete spinning white crescents")

func _sparks() -> void:
	var source := Image.load_from_file(REWORK + "sparks-source.png")
	var source_cell := Vector2i(source.get_width()/4,source.get_height()/2)
	var output := Image.create(256,128,false,Image.FORMAT_RGBA8)
	for key in 8:
		var frame := source.get_region(Rect2i(Vector2i(key%4,key/4)*source_cell,source_cell))
		frame.resize(64,64,Image.INTERPOLATE_NEAREST)
		for y in 64:
			for x in 64:
				var color := frame.get_pixel(x,y)
				if color.a*255 < 190: frame.set_pixel(x,y,Color.TRANSPARENT)
		output.blit_rect(frame,Rect2i(0,0,64,64),Vector2i(key%4,key/4)*64)
	_check(output.save_png(OUTPUT + "sparks.png") == OK,"Eight ground metal spark frames")

func _compact_slashes() -> void:
	var path := OUTPUT + "slash.png"
	var source := Image.load_from_file(path)
	if source.get_height()==768: return # Idempotent re-registration.
	_check(source.get_size()==Vector2i(1024,1024),"Original white ribbon layout")
	var compact := Image.create(1024,768,false,Image.FORMAT_RGBA8)
	for row in 3:
		compact.blit_rect(source,Rect2i(0,(3 if row==2 else row)*256,1024,256),Vector2i(0,row*256))
	_check(compact.save_png(path)==OK,"Retired local-spin ribbon row removed")

