extends SceneTree


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var scene := load("res://levels/stage_6/stage_6.tscn") as PackedScene
	assert(scene != null, "Stage VI environment scene must load")
	var stage := scene.instantiate()
	root.add_child(stage)
	await process_frame
	await process_frame

	var ground := stage.get_node("World/Level/Ground") as TileMapLayer
	assert(ground != null, "Stage VI must own authored ground")
	assert(ground.map_size == Vector2i(24, 20), "Stage VI map contract drifted")
	assert(ground.get_used_cells().size() == 24 * 20, "Stage VI ground must remain continuous beneath its top-down terrace")
	assert(ground.get_cell_source_id(Vector2i(0, 0)) == 0, "Upper terrace must use playable-world ground rather than a scenic backdrop")
	assert(ground.get_cell_source_id(Vector2i(12, 19)) == 0, "Lower approach must remain playable ground")

	assert(stage.get_node_or_null("World/Backdrop") == null, "Stage VI must not reintroduce a horizon-style backdrop")
	assert(stage.get_node_or_null("World/Actors/ElderThreshold") == null, "Rejected oval threshold must stay removed")
	assert(not FileAccess.file_exists("res://assets/environment/forest/stage_6/props/elder_root_threshold_640x384.png"), "Rejected threshold runtime art must stay archived")

	var terrace := stage.get_node_or_null("World/Actors/UpperTerrace")
	assert(terrace != null, "Stage VI top-down upper terrace is missing")
	var cliff_line := terrace.get_node_or_null("CliffLine")
	assert(cliff_line != null and cliff_line.get_child_count() >= 8, "Reusable cliff boundary pieces are missing")
	var waterfall := terrace.get_node_or_null("Waterfall/AnimatedWaterfall") as AnimatedSprite2D
	assert(waterfall != null, "Upper-terrace waterfall is missing")
	assert(waterfall.sprite_frames.get_frame_count(&"flow") == 4, "Waterfall must keep its four-frame animation")
	assert(waterfall.is_playing(), "Waterfall must animate automatically")
	_assert_waterfall_frames_keep_fixed_banks()
	assert(FileAccess.file_exists("res://assets/environment/forest/stage_6/waterfall/modules/waterfall_cliff_lip_static_192x96.png"), "Reusable waterfall cliff-lip module is missing")
	assert(FileAccess.file_exists("res://assets/environment/forest/stage_6/waterfall/modules/waterfall_flow_4f_64x96.png"), "Reusable waterfall vertical-flow module is missing")
	assert(FileAccess.file_exists("res://assets/environment/forest/stage_6/waterfall/modules/waterfall_basin_static_192x96.png"), "Reusable waterfall basin module is missing")
	assert(terrace.get_node_or_null("AncientTreeWest") != null, "Upper terrace must reuse top-down ancient trees")
	assert(terrace.get_node_or_null("RockyOutcropEast") != null, "Upper terrace modular rock dressing is missing")
	assert(stage.get_node_or_null("World/VoidCollision/UpperCliffBoundary") != null, "Upper cliff collision is missing")

	stage.queue_free()
	await process_frame
	print("STAGE_6_ENVIRONMENT_SMOKE_PASSED")
	quit()


func _assert_waterfall_frames_keep_fixed_banks() -> void:
	var texture := load("res://assets/environment/forest/stage_6/waterfall/upper_terrace_waterfall_4f_192x256.png") as Texture2D
	assert(texture != null, "Waterfall texture must load through the Godot importer")
	var image := texture.get_image()
	assert(image != null and image.get_size() == Vector2i(768, 256), "Waterfall sheet must remain a 4x1 grid of 192x256 frames")
	var curtain_zone := Rect2i(69, 62, 54, 112)
	var foam_zone := Rect2i(48, 158, 97, 49)
	var changed_water_pixels := 0
	for y in range(256):
		for x in range(192):
			var first := image.get_pixel(x, y)
			for frame_index in range(1, 4):
				var current := image.get_pixel(frame_index * 192 + x, y)
				assert(is_equal_approx(first.a, current.a), "Waterfall silhouette/alpha must remain fixed across frames")
				if first.is_equal_approx(current):
					continue
				var point := Vector2i(x, y)
				assert(curtain_zone.has_point(point) or foam_zone.has_point(point), "Waterfall banks or terrain moved outside the vertical-flow/foam zones")
				changed_water_pixels += 1
	assert(changed_water_pixels > 100, "Waterfall animation must move visible water texture rather than remain static")
