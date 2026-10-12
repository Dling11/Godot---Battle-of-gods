extends SceneTree

const TitleScene = preload("res://ui/screens/title/title_screen.tscn")
const ThemeResource = preload("res://assets/ui/themes/battle_of_gods_theme.tres")
const SANCTUARY := "res://levels/sanctuary/sanctuary.tscn"
const TEST_PROFILE_PATH := "user://battle_of_gods_title_screen_smoke.json"

var _save_service: Node


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_save_service = root.get_node("SaveService")
	if not _save_service.configure_storage_path_for_testing(TEST_PROFILE_PATH):
		_fail("SaveService refused the isolated title-screen test path.")
		return
	_save_service.delete_profile()
	var title := TitleScene.instantiate() as TitleScreen
	root.add_child(title)
	current_scene = title
	await process_frame
	await process_frame
	if title.theme != ThemeResource:
		_fail("Title screen is not using the shared UI theme.")
		return
	var background := title.get_node("Background")
	for layer_name in ["Base", "Atmosphere", "Vignette"]:
		if not background.has_node(layer_name):
			_fail("Replaceable title background is missing layer: %s" % layer_name)
			return
	var base_texture := background.get_node("Base").texture as Texture2D
	if base_texture == null or base_texture.get_size() != Vector2(960, 540):
		_fail("Title base background is not the required 960x540 asset.")
		return
	if root.gui_get_focus_owner() != title.start_button:
		_fail("Title screen did not give initial keyboard/gamepad focus to Start.")
		return
	if not title.continue_button.disabled:
		_fail("Title Continue must be disabled when no valid profile exists.")
		return
	var transition_service := root.get_node("SceneTransition")
	if transition_service.is_input_blocking():
		_fail("The transparent scene-transition overlay is intercepting idle menu clicks.")
		return
	title.settings_button.pressed.emit()
	if title.main_menu_panel.visible or not title.settings_panel.visible:
		_fail("The mouse/keyboard Settings control did not replace the main menu cleanly.")
		return
	if root.gui_get_focus_owner() != title.music_button:
		_fail("Settings did not move focus to its first control.")
		return
	var music_bus := AudioServer.get_bus_index(AudioDirector.MUSIC_BUS)
	var original_music_mute := AudioServer.is_bus_mute(music_bus)
	title.music_button.pressed.emit()
	if AudioServer.is_bus_mute(music_bus) == original_music_mute:
		_fail("The mouse/keyboard Music control did not change the Music bus.")
		return
	title.music_button.pressed.emit()
	var back_button := title.get_node("Content/SettingsPanel/Margin/Root/BackButton") as Button
	back_button.pressed.emit()
	if not title.main_menu_panel.visible or title.settings_panel.visible:
		_fail("The mouse/keyboard Back control did not restore the main menu.")
		return
	if root.gui_get_focus_owner() != title.settings_button:
		_fail("Closing settings did not restore focus to its invoking button.")
		return
	var run_session := root.get_node("RunSession")
	var story_state := root.get_node("StoryState")
	var weapon_inventory := root.get_node("WeaponInventory")
	var material_inventory := root.get_node("MaterialInventory")
	var recipe_discovery := root.get_node("RecipeDiscovery")
	run_session.update_progression(80, 12)
	story_state.remember_story(&"forgotten_grove_completed")
	weapon_inventory.acquire_weapon(preload("res://data/items/equipment/forest/stage_5_core/varkuun_edge_essence.tres"))
	material_inventory.add_material(&"forest_root_fiber", 3)
	recipe_discovery.discover_recipe(&"forest_rootfiber_wraps")
	var transition_state := {"requested": "", "started": false, "finished": false}
	title.journey_requested.connect(func(destination: String) -> void: transition_state.requested = destination)
	transition_service.transition_started.connect(func(_destination: String) -> void:
		transition_state.started = true
		transition_state["blocked_during_fade"] = transition_service.is_input_blocking()
	, CONNECT_ONE_SHOT)
	transition_service.transition_finished.connect(func(_destination: String) -> void: transition_state.finished = true, CONNECT_ONE_SHOT)
	title.begin_new_journey()
	var timeout := create_timer(3.0, true, true)
	while not transition_state.finished and timeout.time_left > 0.0:
		await process_frame
	if not transition_state.finished:
		_fail("Title Start transition timed out (started=%s, current=%s)." % [transition_state.started, current_scene.scene_file_path if current_scene != null else "none"])
		return
	if not transition_state.get("blocked_during_fade", false) or transition_service.is_input_blocking():
		_fail("Scene transitions do not block clicks only for the duration of the fade.")
		return
	if transition_state.requested != SANCTUARY:
		_fail("Start did not request the configured Sanctuary destination.")
		return
	if current_scene == null or current_scene.scene_file_path != SANCTUARY:
		_fail("Title Start did not transition into the Sanctuary.")
		return
	if run_session.total_experience != 0 or run_session.coins != 0:
		_fail("A new journey did not reset the in-memory run state.")
		return
	if story_state.has_story_flag(&"forgotten_grove_completed"):
		_fail("A new journey did not reset the in-memory story state.")
		return
	if weapon_inventory.owns_weapon(&"weapon_varkuun_edge_essence"):
		_fail("A new journey did not reset purchased weapon ownership.")
		return
	if (
		material_inventory.get_quantity(&"forest_root_fiber") != 0
		or recipe_discovery.is_recipe_discovered(&"forest_rootfiber_wraps")
	):
		_fail("A new journey did not reset material and recipe progress.")
		return
	if not _save_service.has_valid_profile():
		_fail("Entering Sanctuary did not create the new journey autosave.")
		return
	_cleanup()
	print("Title screen smoke test passed.")
	quit(0)


func _cleanup() -> void:
	if _save_service != null:
		_save_service.delete_profile()
		_save_service.reset_storage_path_after_testing()


func _fail(message: String) -> void:
	_cleanup()
	push_error(message)
	quit(1)
