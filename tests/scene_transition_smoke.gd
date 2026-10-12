extends SceneTree

const Stage1Scene = preload("res://levels/test_arena/test_arena.tscn")
const STAGE_2 := "res://levels/stage_2/stage_2.tscn"


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	var stage_one := Stage1Scene.instantiate()
	var stage_one_controller := stage_one.get_node("GameplayServices/EncounterController") as EncounterController
	if (
		stage_one_controller.portal_target_scene != STAGE_2
		or stage_one_controller.portal_tier != StagePortal.PortalTier.NORMAL
	):
		stage_one.free()
		_fail("Stage 1 must lead to Stage 2 through a blue Normal portal.")
		return
	stage_one.free()
	if not ResourceLoader.exists(STAGE_2):
		_fail("Stage 2 destination scene does not exist.")
		return
	var transition_service := root.get_node_or_null("SceneTransition")
	if transition_service == null:
		_fail("SceneTransition autoload is unavailable.")
		return
	if transition_service._loading_view.seal.sprite_frames.get_frame_count(&"active") != 8:
		_fail("Quiet loading seal is missing its eight poses.")
		return
	var result: bool = await transition_service.transition_to(STAGE_2)
	if not result:
		_fail("SceneTransition rejected the valid Stage 2 destination.")
		return
	if current_scene == null or current_scene.scene_file_path != STAGE_2:
		_fail("Fade transition did not install Stage 2 as the current scene.")
		return
	var player: Player = current_scene.get_node("World/Actors/Player")
	if player.global_position != Vector2(768, 760):
		_fail("Stage 2 player did not arrive at the authored spawn point.")
		return
	var controller: EncounterController = current_scene.get_node("GameplayServices/EncounterController")
	if controller.waves.size() != 7:
		_fail("Stage 2 must contain its authored seven-wave encounter.")
		return
	var spitter_wave := controller.waves[1] as EncounterWaveDefinition
	if spitter_wave.bramble_spitter_count != 1:
		_fail("Stage 2 does not introduce exactly one Bramble Spitter in Wave 2.")
		return
	if current_scene.get_node("World/Effects").get_child_count() != 0:
		_fail("Stage 2 exit portal should not exist before its encounter is cleared.")
		return
	var story_state := root.get_node("StoryState")
	story_state.reset_story()
	controller._spawn_portal()
	await process_frame
	if (
		not story_state.has_story_flag(&"forgotten_grove_completed")
		or not story_state.has_discovery(&"remembered_thorn_shrine")
	):
		_fail("Clearing the current grove route did not record its story memories.")
		return
	var forward_portal: StagePortal = current_scene.get_node("World/Effects").get_child(0)
	if (
		forward_portal.target_scene_path != "res://levels/stage_3/stage_3.tscn"
		or forward_portal.portal_tier != StagePortal.PortalTier.MINI_BOSS
	):
		_fail("Cleared Stage 2 portal must preview Stage 3 with the purple Mini Boss tier.")
		return
	player.health_component.apply_damage(
		DamageInfo.new(37.0, player, Vector2.LEFT)
	)
	var carried_health := player.health_component.current_health
	var stage_three_result: bool = await transition_service.transition_to(
		"res://levels/stage_3/stage_3.tscn"
	)
	if not stage_three_result:
		_fail("SceneTransition rejected the valid Stage 3 destination.")
		return
	var stage_three_player := current_scene.get_node("World/Actors/Player") as Player
	if not is_equal_approx(stage_three_player.health_component.current_health, carried_health):
		_fail("Current HP was refilled instead of carrying from Stage 2 into Stage 3.")
		return
	var stage_three_controller := current_scene.get_node("GameplayServices/EncounterController") as EncounterController
	if stage_three_controller.portal_target_scene != "res://levels/stage_4/stage_4.tscn":
		_fail("Stage 3 no longer continues into Stage 4.")
		return
	if stage_three_controller.portal_tier != StagePortal.PortalTier.NORMAL:
		_fail("Stage 3 no longer returns to a blue Normal portal after its mini-boss.")
		return
	var stage_four_result: bool = await transition_service.transition_to(
		"res://levels/stage_4/stage_4.tscn"
	)
	if not stage_four_result:
		_fail("SceneTransition rejected the valid Stage 4 destination.")
		return
	var stage_four_player := current_scene.get_node("World/Actors/Player") as Player
	if not is_equal_approx(stage_four_player.health_component.current_health, carried_health):
		_fail("Current HP was refilled instead of carrying from Stage 3 into Stage 4.")
		return
	var stage_four_controller := current_scene.get_node("GameplayServices/EncounterController") as EncounterController
	if stage_four_controller.max_active_enemies != 8:
		_fail("Stage 4 did not install its eight-enemy active cap.")
		return
	if (
		stage_four_controller.portal_target_scene != "res://levels/stage_5/stage_5.tscn"
		or stage_four_controller.portal_tier != StagePortal.PortalTier.BOSS
	):
		_fail("Stage 4 must preview Stage 5 with the red Boss portal.")
		return
	print("Scene transition smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
