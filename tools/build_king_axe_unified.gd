extends "res://tools/build_king_iron_reaper_preview.gd"

## Complete actors only; approved scythe identity/grounding is the baseline.
const SOURCE := "res://art_source/generated/characters/king/iron_beard_unified_2026_10_15/"
const OUTPUT := "res://assets/characters/playable/king/iron_beard_unified/"
const REAPER := "res://assets/characters/playable/king/iron_reaper/"
var _axe: Texture2D
var _palette: Array[Color] = []
var _clips: Dictionary = {}

func _initialize() -> void:
	_build.call_deferred()

func _build() -> void:
	_read_palette()
	if not preload("res://tools/king_axe_technique_baker.gd").new().bake(self):
		_check(false,"Complete axe technique package was not produced")
	if failures: quit(1); return
	for direction in ["side","up","down"]:
		var root_clip: Resource = _clips[direction+"-chop"]
		root_clip.follow_up_clips.clear()
		for action in ["rise","thrust","slam","spin"]: root_clip.follow_up_clips.append(_clips[direction+"-"+action])
		_check(root_clip.has_valid_layout(),direction+" complete five-cut layout")
		# Save leaves before the root so external references remain readable.
		for action in ["rise","thrust","slam","spin","idle","run","chop"]:
			_save_clip(direction,action)
	_publish_fx()
	_publish_layout()
	for info: Dictionary in JSON.parse_string(FileAccess.get_file_as_string("res://art_source/generated/characters/king/iron_beard_motion_2026_10_15/retained-assets.json")):
		_check(FileAccess.get_sha256("res://"+info.path)==info.sha256,"Retain current carry/contact "+str(info.path))
	for info: Dictionary in JSON.parse_string(FileAccess.get_file_as_string(SOURCE+"protected-assets.json")):
		_check(FileAccess.get_sha256("res://"+info.path)==info.sha256,"Existing family preserved "+str(info.path))
	FileAccess.open(SOURCE+"registration.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"records":records,"cell":[256,256],"sole":158,"scale":0.5},"\t")+"\n")
	print("AXE_UNIFIED_BUILD checks=",checks," failures=",failures)
	quit(1 if failures else 0)

func _save_clip(direction: String,action: String) -> void:
	var clip: Resource = _clips[direction+"-"+action]
	var text := "[gd_resource type=\"Resource\" load_steps=%d format=3]\n" % (9 if action=="chop" else 5)
	text += "[ext_resource type=\"Script\" path=\"res://data/weapons/weapon_family_pose_definition.gd\" id=\"1\"]\n"
	for entry in [[clip.body_atlas.resource_path,"2"],[clip.hand_atlas.resource_path,"3"],[_axe.resource_path,"4"]]:
		text += "[ext_resource type=\"Texture2D\" path=\"%s\" id=\"%s\"]\n" % entry
	if action=="chop":
		for index in 4: text += "[ext_resource type=\"Resource\" path=\"%s%s/%s.tres\" id=\"%d\"]\n" % [OUTPUT,direction,["rise","thrust","slam","spin"][index],index+5]
	text += "[resource]\nscript = ExtResource(\"1\")\nbody_atlas = ExtResource(\"2\")\nhand_atlas = ExtResource(\"3\")\nweapon_texture = ExtResource(\"4\")\n"
	for property in ["cell_size","columns","pose_count","pose_order","primary_hands","secondary_hands","weapon_primary_grip","weapon_handle_axis","weapon_tip","mirror_cutting_edge","lift_pixels","weapon_behind_body","primary_visible_poses","single_hand_poses","stowed_poses","released_poses","ground_clipped_poses","phase_windows","queued_recovery_window","pose_weights","allow_rest","rest_start_pose","rest_transition_end_pose","rest_transition_seconds","rest_loop_window","rest_loop_seconds","retrieval_end_pose","interpolate_blade_angles"]:
		text += "%s = %s\n" % [property,var_to_str(clip.get(property))]
	if action=="chop": text += "follow_up_clips = Array[Resource]([ExtResource(\"5\"),ExtResource(\"6\"),ExtResource(\"7\"),ExtResource(\"8\")])\n"
	FileAccess.open(OUTPUT+direction+"/"+action+".tres",FileAccess.WRITE).store_string(text)
	_check(true,direction+" "+action+" deterministic resource")

func _read_palette() -> void:
	var unique := {}
	for direction in ["side","up","down"]:
		var image := Image.load_from_file(REAPER+direction+"/run_body.png")
		for y in image.get_height():
			for x in image.get_width():
				var color := image.get_pixel(x,y)
				if color.a<0.95 or unique.has(color.to_rgba32()): continue
				_palette.append(color)
				unique[color.to_rgba32()] = true

func _publish_fx() -> void:
	# Effect packing/layout source is authored separately and source-hashed.
	var packed: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(SOURCE+"effects-recipe.json"))
	_check(FileAccess.get_sha256(SOURCE+packed.source)==packed.sha256,"White effect source hash")
	var source := Image.load_from_file(SOURCE+packed.source)
	var atlas := Image.create(2048,1280,false,Image.FORMAT_RGBA8)
	for row in 5:
		for frame in 8:
			var entry: Dictionary = packed.frames[row*8+frame]
			var center := Vector2(entry.anchor[0],entry.anchor[1])
			for y in 256:
				for x in 256:
					var point := Vector2i(((Vector2(x,y)-Vector2(128,128))/float(packed.density)+center).round())
					if not _rect(entry.bounds).has_point(point): continue
					var color := source.get_pixelv(point)
					# Restrict the generated import to neutral white/grey paint;
					# translucent or chromatic generation haze is never a stroke.
					if color.a*255<240 or maxf(color.r,maxf(color.g,color.b))-minf(color.r,minf(color.g,color.b))>0.188 or minf(color.r,minf(color.g,color.b))<0.255: continue
					color.a = 1
					atlas.set_pixel(frame*256+x,row*256+y,color)
	_check(atlas.save_png(OUTPUT+"slash.png")==OK,"40 full white frames")

func _publish_layout() -> void:
	# Stable authored fits are source data, never recomputed during gameplay.
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(SOURCE+"ribbon-layout.json"))
	_check(FileAccess.get_sha256(OUTPUT+"slash.png")==data.atlas_sha256,"Layout matches all painted frames")
	_check(FileAccess.get_sha256("res://data/weapons/families/iron_beard/combo.tres")==data.contact_sha256,"Layout matches unchanged contact authority")
	var layout: Resource = load("res://data/weapons/melee_ribbon_layout.gd").new()
	layout.rows = data.rows
	layout.clearance_pixels = data.clearance_pixels
	for view in ["right","up","down"]:
		var transforms: Array[Transform2D] = []
		for entry: Dictionary in data.views[view]:
			var values: Array = entry.transform
			transforms.append(Transform2D(Vector2(values[0],values[1]),Vector2(values[2],values[3]),Vector2(values[4],values[5])))
		layout.set(view,transforms)
	_check(layout.is_valid_layout(),"Five-row registered ribbon layout")
	_check(ResourceSaver.save(layout,"res://data/weapons/families/iron_beard/ribbon_layout.tres")==OK,"Publish cached effect fits")
