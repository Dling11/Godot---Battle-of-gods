extends "res://tests/king_art_test_base.gd"

## Final runtime art is authoritative. Raw generation sheets are intentionally
## discarded; verify the accepted installed bytes, layout and painted frames.
func verify_production_baseline(prefixes: Array) -> void:
	var baseline: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://art_source/production-assets.json"))
	var matched := 0
	for file: Dictionary in baseline.files:
		var selected := prefixes.is_empty()
		for prefix: String in prefixes:
			if str(file.path).begins_with(prefix): selected = true
		if not selected: continue
		matched += 1
		check(FileAccess.get_sha256("res://"+str(file.path)) == file.sha256, "Accepted production asset changed: "+str(file.path))
	check(matched > 0, "Production baseline has no matching assets")

func verify_complete_clip(clip: Resource, cell_size: Vector2i, rigid_poses: Array = []) -> void:
	check(clip.has_valid_layout() and clip.cell_size == cell_size, "Invalid current clip: "+clip.resource_path)
	var image: Image = clip.body_atlas.get_image()
	var gutter := Rect2i(Vector2i(8,8),cell_size-Vector2i(16,16))
	check(clip.hand_atlas.get_image().is_invisible(), "Anatomy fragments layered over complete art")
	for key in clip.pose_count:
		var cell := image.get_region(Rect2i(Vector2i(key%clip.columns,key/clip.columns)*cell_size,cell_size))
		check(cell.get_used_rect().has_area() and gutter.encloses(cell.get_used_rect()), "Missing/cut complete actor: "+clip.resource_path+"/"+str(key))
		check(clip.primary_visible_poses[key] == (1 if key in rigid_poses else 0), "Missing ready blade or duplicate rig over baked art")

func verify_white_strokes(image: Image, columns: int, rows: int) -> void:
	check(image.get_size() == Vector2i(columns*256,rows*256), "Wrong current white-stroke atlas size")
	for row in rows:
		for key in columns:
			var cell := image.get_region(Rect2i(key*256,row*256,256,256))
			check(cell.get_used_rect().has_area() and Rect2i(8,8,240,240).encloses(cell.get_used_rect()), "Missing/cut complete white stroke")
			if columns == 12 and key >= 2 and key <= 5:
				var white := 0
				var data := cell.get_data()
				for pixel in data.size()/4:
					if data[pixel*4+3] > 220 and data[pixel*4] > 180: white += 1
				check(white > 100, "Impact frame lost its bright core")
