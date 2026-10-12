extends "res://tests/sanctuary_test_base.gd"

const Title := preload("res://ui/screens/title/title_screen.tscn")
const OUTPUT := "res://tmp/review/ui/title_trio_2026_10_03/"

func _run() -> void:
	root.size = Vector2i(960, 540)
	var save := root.get_node("SaveService")
	check(save.configure_storage_path_for_testing("user://title_trio_smoke.json"), "Cannot isolate title storage")
	save.suppress_autosave_for_debug_session()
	var cache_path: String = save.get_profile_path().get_basename() + "_title_art.cfg"
	var cache := ConfigFile.new()
	cache.load(cache_path)
	var previous := int(cache.get_value("title", "last", -1))
	var seen: Dictionary = {}
	for index in 12:
		var title := Title.instantiate() as TitleScreen
		root.add_child(title)
		current_scene = title
		var background := title.get_node("Background") as TitleBackground
		check(background.selected_index >= 0 and background.selected_index < 3, "Random title index is invalid")
		check(background.selected_index != previous, "Title repeats the previous launch artwork")
		previous = background.selected_index
		seen[previous] = true
		var stored := ConfigFile.new()
		check(stored.load(cache_path) == OK and int(stored.get_value("title", "last", -1)) == previous, "Title selection does not survive process exit")
		check(background.find_children("*", "AnimatedSprite2D").is_empty(), "Title contains the rejected walking King")
		check(background.base.texture.get_size() == Vector2(960, 540), "Title art is not native960x540")
		current_scene = null
		title.free()
		await process_frame
	print("TITLE_TRIO_SEQUENCE: ", seen.keys(), " last=", previous)
	var title := Title.instantiate() as TitleScreen
	root.add_child(title)
	current_scene = title
	await create_timer(.65).timeout
	check(root.gui_get_focus_owner() == title.start_button, "Left-side menu lost initial focus")
	var background := title.get_node("Background") as TitleBackground
	var viewport_size := get_root().get_visible_rect().size
	for button in [title.start_button, title.settings_button, title.quit_button]:
		check(Rect2(Vector2.ZERO, viewport_size).encloses(button.get_global_rect()), "Title button is outside the viewport")
	if DisplayServer.get_name() != "headless":
		DirAccess.make_dir_recursive_absolute(OUTPUT)
		for index in 3:
			background.select_art(index)
			await RenderingServer.frame_post_draw
			check(root.get_texture().get_image().save_png(OUTPUT + ["a", "b", "c"][index] + ".png") == OK, "Cannot capture selected title")
		root.size = Vector2i(1280, 720)
		await process_frame
		await process_frame
		for button in [title.start_button, title.settings_button, title.quit_button]:
			check(Rect2(Vector2.ZERO, root.get_visible_rect().size).encloses(button.get_global_rect()), "Resized menu clips its controls")
	check(save.get_profile_path() == "user://title_trio_smoke.json", "Artwork changed profile storage")
	current_scene = null
	title.free()
	await process_frame
	print("TITLE_TRIO: %d checks, %d failures; restart history uses isolated cosmetic config" % [checks, failures])
	quit(1 if failures else 0)
