extends SceneTree

const TitleScene = preload("res://ui/screens/title/title_screen.tscn")
const VarkuunEdge: EquipmentDefinition = preload(
	"res://data/items/equipment/forest/stage_5_core/varkuun_edge_essence.tres"
)
const SANCTUARY := "res://levels/sanctuary/sanctuary.tscn"
const TEST_PROFILE_PATH := "user://battle_of_gods_title_continue_smoke.json"

var _save_service: Node


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_save_service = root.get_node("SaveService")
	if not _save_service.configure_storage_path_for_testing(TEST_PROFILE_PATH):
		_fail("SaveService refused the isolated title Continue path.")
		return
	_save_service.delete_profile()

	var run_session := root.get_node("RunSession")
	var story_state := root.get_node("StoryState")
	var weapon_inventory := root.get_node("WeaponInventory")
	var material_inventory := root.get_node("MaterialInventory")
	var recipe_discovery := root.get_node("RecipeDiscovery")
	run_session.reset_run()
	story_state.reset_story()
	weapon_inventory.reset_inventory()
	material_inventory.reset_inventory()
	recipe_discovery.reset_discoveries()
	run_session.update_progression(725, 113)
	run_session.update_player_health(92.0)
	story_state.remember_story(&"forgotten_grove_completed")
	weapon_inventory.acquire_weapon(VarkuunEdge)
	weapon_inventory.equip_weapon(&"king", &"warrior", VarkuunEdge)
	material_inventory.add_material(&"forest_mire_resin", 6)
	recipe_discovery.discover_recipe(&"forest_mireward_charm")
	if not _save_service.save_profile():
		_fail("The title Continue fixture could not save its profile.")
		return

	run_session.reset_run()
	story_state.reset_story()
	weapon_inventory.reset_inventory()
	material_inventory.reset_inventory()
	recipe_discovery.reset_discoveries()
	var title := TitleScene.instantiate() as TitleScreen
	root.add_child(title)
	current_scene = title
	await process_frame
	await process_frame
	if title.continue_button.disabled or title.continue_button.text != "CONTINUE":
		_fail("Title Continue was not enabled for a valid profile.")
		return
	if root.gui_get_focus_owner() != title.continue_button:
		_fail("A valid profile did not receive initial Continue focus.")
		return
	title.start_button.pressed.emit()
	if not title.new_journey_confirmation.visible or not _save_service.has_valid_profile():
		_fail("New Journey did not protect the existing autosave with confirmation.")
		return
	title.new_journey_confirmation.hide()

	var transition_service := root.get_node("SceneTransition")
	var transition_state := {
		"finished": false,
		"started": false,
		"requested": "",
	}
	title.journey_requested.connect(
		func(destination: String) -> void: transition_state.requested = destination
	)
	transition_service.transition_finished.connect(
		func(_destination: String) -> void: transition_state.finished = true,
		CONNECT_ONE_SHOT
	)
	transition_service.transition_started.connect(
		func(_destination: String) -> void: transition_state.started = true,
		CONNECT_ONE_SHOT
	)
	title.continue_button.pressed.emit()
	var timeout := create_timer(3.0, true, true)
	while not transition_state.finished and timeout.time_left > 0.0:
		await process_frame
	if not transition_state.finished:
		_fail(
			"Title Continue transition timed out (started=%s, requested=%s, current=%s, paused=%s)."
			% [
				transition_state.started,
				transition_state.requested,
				current_scene.scene_file_path if current_scene != null else "none",
				paused,
			]
		)
		return
	if transition_state.requested != SANCTUARY:
		_fail("Continue did not request the saved Sanctuary destination.")
		return
	if current_scene == null or current_scene.scene_file_path != SANCTUARY:
		_fail("Continue did not enter the saved Sanctuary scene.")
		return
	var sanctuary_player := current_scene.get_node("World/Actors/Player") as Player
	if (
		not is_equal_approx(
			sanctuary_player.health_component.current_health,
			sanctuary_player.health_component.maximum_health
		)
		or not is_equal_approx(
			run_session.player_current_health,
			sanctuary_player.health_component.maximum_health
		)
	):
		_fail("Continue did not restore full health at the Sanctuary recovery checkpoint.")
		return
	if (
		run_session.total_experience != 725
		or run_session.coins != 113
		or not story_state.has_story_flag(&"forgotten_grove_completed")
		or not weapon_inventory.owns_weapon(VarkuunEdge.item_id)
		or material_inventory.get_quantity(&"forest_mire_resin") != 6
		or not recipe_discovery.is_recipe_discovered(&"forest_mireward_charm")
	):
		_fail("Continue transitioned without restoring the saved profile.")
		return

	_cleanup()
	print("Title Continue smoke test passed.")
	quit(0)


func _cleanup() -> void:
	if _save_service != null:
		_save_service.delete_profile()
		_save_service.reset_storage_path_after_testing()


func _fail(message: String) -> void:
	_cleanup()
	push_error(message)
	quit(1)
