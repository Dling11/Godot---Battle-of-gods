extends "res://tests/sanctuary_test_base.gd"

const Loading = preload("res://ui/transitions/quiet_loading_view.tscn")
const OUTPUT := "res://tmp/review/ui/quiet_ui_stability_2026_10_03/"

func _run() -> void:
	var save := root.get_node("SaveService")
	check(save.configure_storage_path_for_testing("user://quiet_ui_stability_smoke.json"), "Cannot isolate UI stability profile")
	save.suppress_autosave_for_debug_session()
	_audit_source()
	if DisplayServer.get_name() == "headless":
		push_error("UI stability requires native rendering.")
		quit(1)
		return
	root.size = Vector2i(960, 540)
	var viewport := SubViewport.new()
	viewport.size = Vector2i(960, 540)
	viewport.transparent_bg = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	root.add_child(viewport)
	var report: Dictionary = {}
	var previous_material: ShaderMaterial = root.get_node("SceneTransition")._loading_view.seal.material
	for key: String in ["loading"]:
		var view: Control = Loading.instantiate()
		viewport.add_child(view)
		view.begin("res://levels/test_arena/test_arena.tscn", {})
		view.set_loading_progress(.373)
		var seal: AnimatedSprite2D = view.seal
		await create_timer(.7).timeout
		var material := seal.material as ShaderMaterial
		check(material != null, "Actual UI seal has no stable surface: " + key)
		check(material != previous_material, "Loading instances share mutable phase material")
		previous_material = material
		var hidden: Array[CanvasItem] = []
		_hide_except_seal(view, seal, hidden)
		seal.pause()
		seal.set_process(false)
		var origin := seal.position
		var rect := Rect2i(Vector2i(seal.global_position) - Vector2i(56, 56), Vector2i(112, 112))
		var first: Image
		var motion := 0
		var alpha_changes := 0
		for frame in 8:
			seal.frame = frame
			material.set_shader_parameter("animation_phase", float(frame) * TAU / 8.0)
			await RenderingServer.frame_post_draw
			var image := viewport.get_texture().get_image().get_region(rect)
			check(seal.position == origin and seal.scale == Vector2.ONE, "UI emblem transform moves: " + key)
			if frame == 0:
				first = image
				check(first.get_used_rect().has_area(), "Stable emblem rendered empty")
			else:
				alpha_changes += _alpha_changes(first, image)
				motion += _color_changes(first, image)
			image.save_png(OUTPUT + key + "_seal_%d.png" % frame)
			material.set_shader_parameter("animation_phase", (float(frame) + .5) * TAU / 8.0)
			await RenderingServer.frame_post_draw
			var half := viewport.get_texture().get_image().get_region(rect)
			check(_alpha_changes(first, half) == 0, "Halfway light changes engraving geometry: " + key)
		check(alpha_changes == 0, "UI seal still changes silhouette: " + key)
		check(motion > 100, "Stable UI engraving has no moving light: " + key)
		material.set_shader_parameter("animation_phase", TAU)
		await RenderingServer.frame_post_draw
		check(first.get_data() == viewport.get_texture().get_image().get_region(rect).get_data(), "UI seal loop seam jumps: " + key)
		for item in hidden:
			item.show()
		seal.set_process(true)
		seal.play(&"active")
		paused = true
		var held_phase: float = material.get_shader_parameter("animation_phase")
		await create_timer(.12, true, false, true).timeout
		check(material.get_shader_parameter("animation_phase") != held_phase, "UI seal freezes during paused loading/menu: " + key)
		paused = false
		if key == "loading":
			check(is_equal_approx(view.progress_bar.value, .373) and view.progress_label.text.contains("37%"), "Stable seal changed actual loading percentage")
			var held_king_frame: int = view.king.frame
			await create_timer(.13).timeout
			check(view.king.frame != held_king_frame, "Loading King lost his walk animation")
			view.progress_label.text = "MOTION PREVIEW • 37%"
		DirAccess.make_dir_recursive_absolute(OUTPUT + key + "_frames/")
		for index in 24:
			await RenderingServer.frame_post_draw
			viewport.get_texture().get_image().save_png(OUTPUT + key + "_frames/frame_%02d.png" % index)
			await create_timer(.1).timeout
		if key == "loading":
			view.finish()
		else:
			seal.stop()
		view.hide()
		var stopped_phase: float = material.get_shader_parameter("animation_phase")
		await create_timer(.15).timeout
		check(not seal.is_playing() and not seal.is_processing() and material.get_shader_parameter("animation_phase") == stopped_phase, "Hidden/stopped UI light keeps advancing: " + key)
		report[key] = {"changed_silhouette_pixels": alpha_changes, "moving_light_pixels": motion, "used": str(first.get_used_rect())}
		view.free()
	viewport.free()
	FileAccess.open(OUTPUT + "rendered_geometry.json", FileAccess.WRITE).store_string(JSON.stringify(report, "\t"))
	print("QUIET_UI_STABILITY: %d checks, %d failures; " % [checks, failures] + JSON.stringify(report))
	quit(1 if failures else 0)

func _hide_except_seal(node: Node, seal: AnimatedSprite2D, hidden: Array[CanvasItem]) -> void:
	for child in node.get_children():
		if child == seal:
			continue
		if child.is_ancestor_of(seal):
			_hide_except_seal(child, seal, hidden)
		elif child is CanvasItem and child.visible:
			hidden.append(child)
			child.hide()

func _alpha_changes(first: Image, current: Image) -> int:
	var count := 0
	for y in first.get_height():
		for x in first.get_width():
			if first.get_pixel(x, y).a != current.get_pixel(x, y).a:
				count += 1
	return count

func _color_changes(first: Image, current: Image) -> int:
	var count := 0
	for y in first.get_height():
		for x in first.get_width():
			if first.get_pixel(x, y).a > .9 and first.get_pixel(x, y) != current.get_pixel(x, y):
				count += 1
	return count

func _audit_source() -> void:
	DirAccess.make_dir_recursive_absolute(OUTPUT)
	var sheet := Image.load_from_file(ProjectSettings.globalize_path("res://assets/ui/quiet_transition/seal.png"))
	var first := sheet.get_region(Rect2i(0, 0, 112, 112))
	var report: Array[Dictionary] = []
	for frame in 8:
		var image := sheet.get_region(Rect2i(frame * 112, 0, 112, 112))
		report.append({"frame": frame, "used": str(image.get_used_rect()), "changed_silhouette_pixels": _alpha_changes(first, image)})
	FileAccess.open(OUTPUT + "source_geometry.json", FileAccess.WRITE).store_string(JSON.stringify(report, "\t"))
	print("QUIET_SEAL_SOURCE: ", JSON.stringify(report))
