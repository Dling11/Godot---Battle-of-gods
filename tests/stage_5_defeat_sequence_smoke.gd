extends SceneTree

const Stage5Scene = preload("res://levels/stage_5/stage_5.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	var stage := Stage5Scene.instantiate()
	stage.review_hold_approach = true
	root.add_child(stage)
	await process_frame
	stage.call("_spawn_forward_portal")
	var portal_parent := stage.get_node("World/Effects") as Node2D
	var next_portal := portal_parent.get_child(portal_parent.get_child_count() - 1) as StagePortal
	if (
		next_portal == null
		or next_portal.target_scene_path != "res://levels/stage_6/stage_6.tscn"
		or next_portal.portal_tier != StagePortal.PortalTier.NORMAL
	):
		_fail("Claiming Varkuun's chest must open a blue Normal portal directly into Stage 6.")
		return
	next_portal.queue_free()
	await process_frame
	var dialogue := stage.get_node("UI/DialoguePanel") as DialoguePanel
	var actors := stage.get_node("World/Actors") as Node2D
	stage.call("_on_boss_died")
	await process_frame
	if not dialogue.visible:
		_fail("Varkuun's defeat did not pause on his final dialogue.")
		return
	var body := dialogue.get_node("Panel/Margin/Root/Text/BodyLabel") as Label
	if not body.text.begins_with("Impossible"):
		_fail("Varkuun's final quote lost its dramatic Impossible opening.")
		return
	if _find_reward_chest(actors) != null:
		_fail("The reward chest appeared immediately underneath the death dialogue.")
		return
	dialogue.close_dialogue(true)
	await create_timer(1.0).timeout
	if _find_reward_chest(actors) != null:
		_fail("The reward chest replaced Varkuun before his collapse could finish.")
		return
	await create_timer(1.35).timeout
	var chest := _find_reward_chest(actors)
	var defeat_position: Vector2 = stage.get("_boss_defeat_position")
	if chest == null or chest.global_position != defeat_position:
		_fail("The delayed Varkuun chest did not appear at his recorded fall position.")
		return
	root.get_node("LootService").abort_expedition_rewards()
	stage.queue_free()
	await process_frame
	print("Varkuun final quote and post-collapse delayed chest sequence passed.")
	quit(0)


func _find_reward_chest(actors: Node) -> StageRewardChest:
	for child: Node in actors.get_children():
		if child is StageRewardChest:
			return child as StageRewardChest
	return null


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
