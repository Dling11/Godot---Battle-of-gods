extends "res://tests/sanctuary_test_base.gd"

const Gallery = preload("res://tools/stage_presentation_gallery.gd")
const Title = preload("res://ui/screens/title/title_screen.tscn")
const Portal = preload("res://gameplay/encounters/stage_portal.tscn")
const PlayerScene = preload("res://entities/player/player.tscn")
const EVIDENCE := "res://tmp/review/ui/stage_presentation_2026_10_03/"
var _seal_changes := 0
var _king_changes := 0
var _progress: Array[float] = []

func _run() -> void:
	root.size = Vector2i(960,540)
	if DisplayServer.get_name() != "headless":
		root.mode = Window.MODE_WINDOWED
	var save := root.get_node("SaveService")
	check(save.configure_storage_path_for_testing("user://stage_transition_presentation_smoke.json"), "Cannot isolate presentation profile")
	save.delete_profile()
	save.suppress_autosave_for_debug_session()
	var service := root.get_node("SceneTransition")
	var loading: QuietLoadingView = service._loading_view
	check(not loading.visible and not service.is_input_blocking(), "Idle loading screen blocks menu")
	check(loading.progress_bar.size.y <= 18, "Default theme enlarges the slim loading bar")
	loading.set_loading_progress(.373)
	check(is_equal_approx(loading.progress_bar.value,.373) and loading.progress_label.text.contains("37%"), "Loading bar rounds the resource fraction to an integer before rendering")
	loading.set_loading_progress(0)
	var title := Title.instantiate() as TitleScreen
	root.add_child(title)
	current_scene = title
	await create_timer(.65).timeout
	await capture("title.png")
	var failure_resource := "user://presentation_wrong_type.tres"
	FileAccess.open(failure_resource,FileAccess.WRITE).store_string("[gd_resource type=\"Resource\" format=3]\n\n[resource]\n")
	title._transitioning = true
	title._set_main_buttons_disabled(true)
	paused = true
	var rejected: bool = await service.transition_to(failure_resource)
	check(not rejected and current_scene == title, "Failed load replaced the old scene")
	check(paused and not service.is_input_blocking() and not loading.visible, "Failed load lost previous pause/input state")
	check(not title._transitioning and not title.start_button.disabled, "Failed load left title controls disabled")
	paused = false
	DirAccess.remove_absolute(ProjectSettings.globalize_path(failure_resource))
	current_scene = null
	title.free()
	var world := Node2D.new()
	root.add_child(world)
	current_scene = world
	var player := PlayerScene.instantiate() as Player
	var portal := Portal.instantiate() as StagePortal
	portal.target_scene_path = "res://missing_destination.tscn"
	world.add_child(player)
	world.add_child(portal)
	for camera in player.find_children("*","Camera2D"):
		camera.enabled = false
	player.set_physics_process(false)
	player.global_position = Vector2(240,300)
	portal.global_position = player.global_position
	for frame in 3: await physics_frame
	check(portal._player_inside, "Real portal proximity is missing before failed travel")
	var prompt := {"visible":true}
	portal.proximity_changed.connect(func(visible: bool, _text: String, _icon: Texture2D) -> void: prompt.visible = visible)
	var interact := InputEventAction.new()
	interact.action = "player_interact"
	interact.pressed = true
	portal._unhandled_input(interact)
	check(portal._travel_started and not prompt.visible, "F did not start departure")
	await create_timer(.65).timeout
	check(not portal._travel_started and portal._player_inside and prompt.visible, "Failed travel does not restore the nearby F prompt")
	check(player.is_physics_processing() and player.is_processing_unhandled_input() and player.modulate.a == 1 and player.scale == Vector2.ONE, "Failed travel leaves King invisible or disabled")
	current_scene = null
	world.free()
	var gallery := Control.new()
	gallery.set_script(Gallery)
	root.add_child(gallery)
	current_scene = gallery
	for index in 6:
		gallery.show_portal(index)
		await create_timer(.7).timeout
		var art: AnimatedSprite2D = gallery.selected_portal.portal_visual
		check(art.is_playing() and art.sprite_frames.get_frame_count(&"active") == 8, "Portal variant has no live eight-pose animation")
		check(absf(art.position.y+71.0*art.scale.y)<.01, "Portal feet drift off the ground anchor")
		check(art.modulate.r > .85 and art.modulate.b > .85, "Colored art is incorrectly double-tinted")
		check(gallery.selected_portal.portal_fx.z_index > 0 and gallery.selected_portal.portal_fx.z_index < art.z_index, "Lightning is hidden by terrain or covers the portal body")
		await capture("portal_%d.png" % (index+1))
	gallery.show_loading()
	await create_timer(.35).timeout
	await capture("loading_motion_preview.png")
	gallery._loading.finish()
	gallery._loading.hide()
	loading.seal.frame_changed.connect(func() -> void: _seal_changes += 1)
	loading.king.frame_changed.connect(func() -> void: _king_changes += 1)
	service.loading_progress_changed.connect(func(value: float) -> void: _progress.append(value))
	service.transition_started.connect(_check_started, CONNECT_ONE_SHOT)
	var success: bool = await service.transition_to("res://levels/test_arena/test_arena.tscn")
	check(success and current_scene.scene_file_path.ends_with("/test_arena.tscn"), "Real resource loading did not install Stage I")
	check(_seal_changes >= 2 and _king_changes >= 2, "Seal/King freeze during real paused transition")
	check(not _progress.is_empty() and _progress[-1] == 1.0, "Loading never reports the actual completed resource")
	for value in _progress:
		check(value >= 0 and value <= 1, "Loading progress is outside the valid range")
	check(not paused and not service.is_input_blocking() and not loading.visible, "Completed transition leaves the game paused or blocked")
	await capture("arrived_stage_1.png")
	current_scene.queue_free()
	current_scene = null
	await process_frame
	await process_frame
	save.delete_profile()
	print("STAGE_PRESENTATION: %d checks, %d failures; real loading seal/King frames %d/%d" % [checks,failures,_seal_changes,_king_changes])
	quit(1 if failures else 0)

func _check_started(_target: String) -> void:
	check(paused and root.get_node("SceneTransition").is_input_blocking(), "Travel does not own pause/input during loading")
	check(not await root.get_node("SceneTransition").transition_to("res://levels/stage_2/stage_2.tscn"), "Concurrent travel is accepted")
	if DisplayServer.get_name() != "headless":
		await create_timer(.27).timeout
		await capture("loading_real_transition.png")

func capture(file: String) -> void:
	if DisplayServer.get_name() == "headless": return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(EVIDENCE))
	await RenderingServer.frame_post_draw
	check(root.get_texture().get_image().save_png(EVIDENCE+file) == OK, "Cannot save rendered presentation evidence")
