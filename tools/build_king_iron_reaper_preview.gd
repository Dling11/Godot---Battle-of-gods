extends SceneTree

## Offline preview only. Whole generated actors include their held scythe.
## Reference anatomy is never copied; production equipment stays unchanged.
const DEFAULT_SOURCE := "res://art_source/generated/characters/king/iron_reaper_side_preview_2026_10_14/"
const ACTIONS := ["sweep", "return", "spin", "reap"]
var cell := Vector2i(256, 224)
var foot_plane := 164
var source_folder := DEFAULT_SOURCE
var checks := 0
var failures := 0
var records: Array[Dictionary] = []

func _initialize() -> void:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--source="): source_folder = argument.trim_prefix("--source=").trim_suffix("/") + "/"
	if not source_folder.begins_with("res://art_source/generated/characters/king/iron_reaper_"):
		push_error("Iron Reaper source must stay in its project art-source folder")
		quit(1)
		return
	call_deferred("_build")

func _build() -> void:
	var recipe: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(source_folder + "registration-recipe.json"))
	cell = Vector2i(recipe.cell_size[0], recipe.cell_size[1])
	foot_plane = int(recipe.foot_plane)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(source_folder + "preview/"))
	for action in ACTIONS:
		var board: Dictionary = recipe.boards[action]
		var path: String = source_folder + board.source
		_check(FileAccess.get_sha256(path) == board.sha256, action + " source hash")
		if failures: break
		var source := Image.load_from_file(path)
		if board.has("calibration"):
			var calibration: Dictionary = board.calibration
			_check(absf(float(calibration.source_crown_to_sole) * float(board.density) - float(calibration.target_crown_to_sole)) < .01, action + " complete standing anatomy calibration")
		var parts := _components(source, recipe.alpha_threshold)
		_check(parts.size() == 8, action + " has eight complete connected source actors")
		if failures: break
		var atlas := Image.create(cell.x * 4, cell.y * 2, false, Image.FORMAT_RGBA8)
		for key in 8:
			var info: Dictionary = board.keys[key]
			var bounds := _rect(info.source_bounds)
			var selected: Dictionary = {}
			for part in parts:
				if part.bounds == bounds: selected = part; break
			_check(not selected.is_empty(), action + " source ownership " + str(key))
			if failures: break
			_check(selected.pixels.size() == int(info.component_pixels), action + " complete source count " + str(key))
			var cel := _extract(source, selected)
			var density: float = board.density
			var offset := Vector2(cell.x * .5 - float(info.anchor_x) * density, foot_plane - float(info.source_sole) * density)
			var result := Image.create(cell.x, cell.y, false, Image.FORMAT_RGBA8)
			for y in cell.y:
				for x in cell.x:
					var point := Vector2i(((Vector2(x, y) - offset) / density).round())
					if not Rect2i(Vector2i.ZERO, cel.get_size()).has_point(point): continue
					var c := cel.get_pixelv(point)
					if c.a * 255 < recipe.alpha_threshold: continue
					result.set_pixel(x, y, Color(roundf(c.r * 31) / 31, roundf(c.g * 31) / 31, roundf(c.b * 31) / 31, 1))
			var used := result.get_used_rect()
			_check(Rect2i(4, 4, cell.x - 8, cell.y - 8).encloses(used), action + " full actor/scythe gutter " + str(key))
			_check(absf(foot_plane - (float(info.source_sole) * density + offset.y)) < .01, action + " sole registration " + str(key))
			var head: Array = info.head_bounds
			_check(float(head[2]) * density >= 21 and float(head[2]) * density <= 29, action + " standing-calibrated head width " + str(key))
			atlas.blit_rect(result, Rect2i(Vector2i.ZERO, cell), Vector2i(key % 4 * cell.x, key / 4 * cell.y))
			records.append({"action": action, "key": key, "density": density, "bounds": [used.position.x, used.position.y, used.size.x, used.size.y], "source_bounds": info.source_bounds, "sole": foot_plane, "head_width": float(head[2]) * density})
		if failures: break
		_check(atlas.save_png(source_folder + "preview/" + action + ".png") == OK, action + " atlas saved")
	if failures == 0: _effects(recipe.effects)
	var protected: Array = JSON.parse_string(FileAccess.get_file_as_string(source_folder + "protected-assets.json"))
	for info in protected:
		_check(FileAccess.get_sha256("res://" + info.path) == info.sha256, "Existing King asset preserved: " + str(info.path))
	if FileAccess.file_exists(source_folder + "original-study-hashes.json"):
		var original: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(source_folder + "original-study-hashes.json"))
		for path in original:
			_check(FileAccess.get_sha256(DEFAULT_SOURCE + path) == original[path], "Original scythe study preserved: " + str(path))
	FileAccess.open(source_folder + "preview/registration.json", FileAccess.WRITE).store_string(JSON.stringify({"cell": [cell.x, cell.y], "sole": foot_plane, "scale": .5, "scope": "motion preview only", "poses": records, "checks": checks, "failures": failures}, "\t") + "\n")
	print("IRON_REAPER_PREVIEW_BUILD checks=", checks, " failures=", failures, " complete_poses=", records.size())
	quit(1 if failures else 0)

func _components(image: Image, threshold: int) -> Array[Dictionary]:
	var data := image.get_data()
	var width := image.get_width()
	var height := image.get_height()
	var seen := PackedByteArray()
	seen.resize(width * height)
	var parts: Array[Dictionary] = []
	for start in width * height:
		if seen[start] or data[start * 4 + 3] < threshold: continue
		var queue := PackedInt32Array([start])
		seen[start] = 1
		var low := Vector2i(width, height)
		var high := Vector2i.ZERO
		var cursor := 0
		while cursor < queue.size():
			var current := queue[cursor]
			cursor += 1
			var x := current % width
			var y := current / width
			low = Vector2i(mini(low.x, x), mini(low.y, y))
			high = Vector2i(maxi(high.x, x), maxi(high.y, y))
			for dy in range(-1, 2):
				for dx in range(-1, 2):
					var nx := x + dx
					var ny := y + dy
					if nx < 0 or ny < 0 or nx >= width or ny >= height: continue
					var index := ny * width + nx
					if seen[index] or data[index * 4 + 3] < threshold: continue
					seen[index] = 1
					queue.append(index)
		if queue.size() > 15000: parts.append({"bounds": Rect2i(low, high - low + Vector2i.ONE), "pixels": queue})
	return parts

func _extract(source: Image, part: Dictionary) -> Image:
	var bounds: Rect2i = part.bounds
	var result := Image.create(bounds.size.x, bounds.size.y, false, Image.FORMAT_RGBA8)
	for pixel in part.pixels:
		var point := Vector2i(int(pixel) % source.get_width(), int(pixel) / source.get_width())
		result.set_pixelv(point - bounds.position, source.get_pixelv(point))
	return result

func _effects(board: Dictionary) -> void:
	var path: String = source_folder + board.source
	_check(FileAccess.get_sha256(path) == board.sha256, "Effect source hash")
	var source := Image.load_from_file(path)
	var atlas := Image.create(cell.x * 4, cell.y * 4, false, Image.FORMAT_RGBA8)
	var size := source.get_size() / 4
	for row in 4:
		for column in 4:
			var cel := source.get_region(Rect2i(Vector2i(column, row) * size, size))
			var used := cel.get_used_rect()
			# Threshold before measuring; discard the source's faint matte fringe.
			for y in cel.get_height():
				for x in cel.get_width():
					var c := cel.get_pixel(x, y)
					if c.a * 255 < 180: cel.set_pixel(x, y, Color.TRANSPARENT)
			used = cel.get_used_rect()
			_check(Rect2i(3, 3, size.x - 6, size.y - 6).encloses(used), "Source effect gutter " + str(row) + "/" + str(column))
			var density: float = board.density
			var result := Image.create(cell.x, cell.y, false, Image.FORMAT_RGBA8)
			var center := Vector2(used.get_center())
			for y in cell.y:
				for x in cell.x:
					var point := Vector2i(((Vector2(x, y) - Vector2(cell) * .5) / density + center).round())
					if not Rect2i(Vector2i.ZERO, size).has_point(point): continue
					var c := cel.get_pixelv(point)
					if c.a < .7: continue
					# Neutral palette: source chromatic flecks cannot become gold effects.
					var value := roundf((c.r * .3 + c.g * .59 + c.b * .11) * 15) / 15
					result.set_pixel(x, y, Color(value, value, value, 1))
			_check(Rect2i(4, 4, cell.x - 8, cell.y - 8).encloses(result.get_used_rect()), "Published effect gutter " + str(row) + "/" + str(column))
			atlas.blit_rect(result, Rect2i(Vector2i.ZERO, cell), Vector2i(column * cell.x, row * cell.y))
	_check(atlas.save_png(source_folder + "preview/slash.png") == OK, "Effects saved")

func _rect(values: Array) -> Rect2i:
	return Rect2i(values[0], values[1], values[2], values[3])

func _check(condition: bool, message: String) -> void:
	checks += 1
	if condition: return
	failures += 1
	push_error(message)
