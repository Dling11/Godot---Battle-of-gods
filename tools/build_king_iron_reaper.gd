extends "res://tools/build_king_iron_reaper_preview.gd"

## Offline whole-actor registration. Uses the preview's extraction helpers;
## no reference anatomy, heads or steel are transplanted into generated poses.
const SOURCE := "res://art_source/generated/characters/king/iron_reaper_complete_2026_10_14/"
const OUTPUT := "res://assets/characters/playable/king/iron_reaper/"
var recipe: Dictionary
var cels: Dictionary = {}


func _initialize() -> void:
	source_folder = SOURCE
	call_deferred("_build")


func _build() -> void:
	# One production entry point. The current whole-actor pass keeps approved
	# running exact and never publishes the superseded mixed-identity actions.
	var output := []
	var status := OS.execute(OS.get_executable_path(),["--headless","--path",ProjectSettings.globalize_path("res://"),"--script","res://tools/build_king_iron_reaper_unified.gd"],output,true)
	var verified := false
	for line: String in output:
		print(line)
		if line.contains("IRON_REAPER_UNIFIED_BUILD") and line.contains("failures=0"): verified = true
	quit(0 if status==0 and verified else 1)


func _trace_board(name_key: String) -> void:
	var board: Dictionary = recipe.boards[name_key]
	var path: String = SOURCE + str(board.source)
	_check(FileAccess.get_sha256(path) == board.sha256, name_key + " source hash")
	if failures: return
	var source := Image.load_from_file(path)
	var parts := _components(source, recipe.alpha_threshold)
	_check(parts.size() == 8, name_key + " eight complete connected actors")
	if failures: return
	var published: Array[Image] = []
	var density: float = board.density
	for key in 8:
		var info: Dictionary = board.keys[key]
		var selected: Dictionary = {}
		for part in parts:
			if part.bounds == _rect(info.source_bounds): selected = part; break
		_check(not selected.is_empty(), name_key + " complete source ownership " + str(key))
		if failures: return
		_check(selected.pixels.size() == int(info.component_pixels), name_key + " source pixel count " + str(key))
		var cel := _extract(source, selected)
		var offset := Vector2(cell.x * 0.5 - float(info.anchor_x) * density, foot_plane - float(info.source_sole) * density)
		var result := Image.create(cell.x, cell.y, false, Image.FORMAT_RGBA8)
		for y in cell.y:
			for x in cell.x:
				var point := Vector2i(((Vector2(x, y) - offset) / density).round())
				if not Rect2i(Vector2i.ZERO, cel.get_size()).has_point(point): continue
				var color := cel.get_pixelv(point)
				if color.a * 255 < recipe.alpha_threshold: continue
				result.set_pixel(x, y, Color(roundf(color.r * 31) / 31, roundf(color.g * 31) / 31, roundf(color.b * 31) / 31, 1))
		var bounds := result.get_used_rect()
		_check(Rect2i(4, 4, cell.x - 8, cell.y - 8).encloses(bounds), name_key + " complete blade/actor gutter " + str(key))
		_check(is_equal_approx((foot_plane - cell.y * 0.5) * 0.5 - 16, -1.0), name_key + " unchanged world sole")
		published.append(result)
		records.append({"board": name_key, "key": key, "density": density, "bounds": [bounds.position.x, bounds.position.y, bounds.size.x, bounds.size.y], "source_bounds": info.source_bounds, "head_width": float(info.head_bounds[2]) * density})
	cels[name_key] = published


func _publish_clip(direction: String, action: String) -> void:
	var is_attack := action not in ["idle", "run"]
	var pose_count := 13 if is_attack else 8
	var atlas := Image.create(cell.x * 4, cell.y * ceili(pose_count / 4.0), false, Image.FORMAT_RGBA8)
	var empty_hands := Image.create(atlas.get_width(), atlas.get_height(), false, Image.FORMAT_RGBA8)
	var source_order := [0, 1, 2, 3, 4, 5, 7, 6] if action == "reap" and direction == "side" else range(8)
	var order := [-1, 0, 1, 2, 3, 4, 5, 6, 7, -1, -1, 6, 7] if is_attack else range(8)
	for key in pose_count:
		var source_key: int = order[key]
		var image: Image = cels[direction + "-idle"][0] if source_key < 0 else cels[direction + "-" + action][source_order[source_key]]
		atlas.blit_rect(image, Rect2i(Vector2i.ZERO, cell), Vector2i(key % 4 * cell.x, key / 4 * cell.y))
	var prefix := OUTPUT + direction + "/" + action
	_check(atlas.save_png(prefix + "_body.png") == OK, direction + " " + action + " saved")
	_check(empty_hands.save_png(OUTPUT + ("attack_hands.png" if is_attack else "locomotion_hands.png")) == OK, direction + " " + action + " shared transparent hand atlas saved")
	FileAccess.open(prefix + ".tres", FileAccess.WRITE).store_string(_clip_resource(direction, action, pose_count, is_attack))


func _clip_resource(direction: String, action: String, count: int, is_attack: bool) -> String:
	var text := "[gd_resource type=\"Resource\" load_steps=%d format=3]\n" % (8 if action == "sweep" else 5)
	text += "[ext_resource type=\"Script\" path=\"res://data/weapons/weapon_family_pose_definition.gd\" id=\"1\"]\n"
	for entry in [["Texture2D", action + "_body.png", "2"], ["Texture2D", "../attack_hands.png" if is_attack else "../locomotion_hands.png", "3"], ["Texture2D", "../weapon.png", "4"]]:
		text += "[ext_resource type=\"%s\" path=\"%s\" id=\"%s\"]\n" % [entry[0], OUTPUT + direction + "/" + entry[1], entry[2]]
	if action == "sweep":
		for index in 3: text += "[ext_resource type=\"Resource\" path=\"%s%s/%s.tres\" id=\"%d\"]\n" % [OUTPUT, direction, ["return","throw","reap"][index], index + 5]
	text += "[resource]\nscript = ExtResource(\"1\")\nbody_atlas = ExtResource(\"2\")\nhand_atlas = ExtResource(\"3\")\nweapon_texture = ExtResource(\"4\")\n"
	text += "cell_size = Vector2i(%d, %d)\ncolumns = 4\npose_count = %d\n" % [cell.x, cell.y, count]
	text += "pose_order = PackedInt32Array(%s)\n" % _numbers(range(count))
	# Template anchors are replaced by the complete-pose baker's traced palms.
	# They are inert defaults, not claims of contact with generated artwork.
	text += "primary_hands = PackedVector2Array(%s)\nsecondary_hands = PackedVector2Array(%s)\n" % [_numbers(_repeat_pair(count, 128, 132)), _numbers(_repeat_pair(count, 135, 132))]
	text += "weapon_primary_grip = Vector2(32, 96)\nweapon_handle_axis = Vector2(0, 1)\nweapon_tip = Vector2(32, 0)\nmirror_cutting_edge = false\n"
	var lifts := []
	for index in count:
		var key := index - 1
		lifts.append([0.0,0.0,-10.0,-14.0,-2.0,0.0,0.0,0.0][key] if is_attack and key>=0 and key<8 and action=="reap" else 0.0)
	text += "lift_pixels = PackedFloat32Array(%s)\n" % _numbers(lifts)
	for property in ["weapon_behind_body", "primary_visible_poses", "stowed_poses", "released_poses", "ground_clipped_poses"]:
		text += "%s = PackedByteArray(%s)\n" % [property, _numbers(_repeat(count, 0))]
	text += "single_hand_poses = PackedByteArray(%s)\n" % _numbers(_repeat(count, 1))
	text += "phase_windows = PackedVector2Array(0, 3, 4, 6, 7, 10)\nqueued_recovery_window = Vector2(11, 12)\n" if is_attack else "phase_windows = PackedVector2Array(0, 3, 4, 5, 6, 7)\n"
	text += "pose_weights = PackedFloat32Array(%s)\n" % _numbers([0.35, 0.65, 1, 1, 1, 1, 1, 1, 1, 0.4, 0.4, 1, 1] if is_attack else _repeat(count, 1))
	text += "allow_rest = %s\nrest_start_pose = 1\nrest_transition_end_pose = 4\nrest_transition_seconds = 1.1\nrest_loop_window = Vector2(5, 7)\nrest_loop_seconds = 3.6\nretrieval_end_pose = 0\n" % ("true" if action == "idle" else "false")
	if action == "sweep": text += "follow_up_clips = Array[Resource]([ExtResource(\"5\"), ExtResource(\"6\"), ExtResource(\"7\")])\n"
	return text


func _icon() -> void:
	var board: Dictionary = recipe.icon
	_check(FileAccess.get_sha256(SOURCE + str(board.source)) == board.sha256, "Inventory icon source hash")
	var image := Image.load_from_file(SOURCE + str(board.source))
	for y in image.get_height():
		for x in image.get_width():
			var color := image.get_pixel(x, y)
			if color.a * 255 < 240: image.set_pixel(x, y, Color.TRANSPARENT)
	var region := image.get_region(image.get_used_rect())
	var density := minf(120.0 / region.get_width(), 152.0 / region.get_height())
	region.resize(roundi(region.get_width() * density), roundi(region.get_height() * density), Image.INTERPOLATE_NEAREST)
	var icon := Image.create(128, 160, false, Image.FORMAT_RGBA8)
	icon.blit_rect(region, Rect2i(Vector2i.ZERO, region.get_size()), (icon.get_size() - region.get_size()) / 2)
	_check(icon.save_png(OUTPUT + "weapon.png") == OK, "Full scythe icon saved")


func _numbers(values: Array) -> String:
	var result := PackedStringArray()
	for value in values: result.append(str(value))
	return ", ".join(result)


func _repeat(count: int, value: int) -> Array:
	var values := []
	for index in count: values.append(value)
	return values


func _repeat_pair(count: int, x: int, y: int) -> Array:
	var values := []
	for index in count: values.append_array([x, y])
	return values
