extends "res://tests/sanctuary_test_base.gd"

const CompletionReturn = preload("res://gameplay/expeditions/expedition_completion_return.gd")
const STAGE1 = preload("res://levels/test_arena/test_arena.tscn")
const STAGE2 = preload("res://levels/stage_2/stage_2.tscn")
const STAGE3 = preload("res://levels/stage_3/stage_3.tscn")
const STAGE4 = preload("res://levels/stage_4/stage_4.tscn")
const STAGE5 = preload("res://levels/stage_5/stage_5.tscn")
const MATERIALS = preload("res://data/items/materials/material_catalog.tres")
const PROFILE := "user://expedition_feedback_smoke.json"
const EVIDENCE := "res://tmp/review/ui/expedition_feedback_2026_10_03/"

func _run() -> void:
	root.size = Vector2i(960,540)
	if DisplayServer.get_name() != "headless":
		root.mode = Window.MODE_WINDOWED
		root.grab_focus()
	var save := root.get_node("SaveService")
	check(save.configure_storage_path_for_testing(PROFILE), "Cannot isolate expedition test profile")
	save.delete_profile()
	for pair in [["RunSession","reset_run"],["StoryState","reset_story"],["MaterialInventory","reset_inventory"],["GearInventory","reset_inventory"],["WeaponInventory","reset_inventory"],["RecipeDiscovery","reset_discoveries"],["LootState","reset_state"]]: root.get_node(pair[0]).call(pair[1])
	root.get_node("StoryState").remember_story(&"awakened_in_sanctuary")
	root.get_node("LootService").configure_seed_for_testing(122)
	var stage := await load_stage(STAGE1)
	var encounter: EncounterController = stage.encounter_controller
	var feedback: Node = stage.expedition_feedback
	var actor: Player = stage.player
	check(not CompletionReturn.request(stage), "UI can return/bank rewards before completion")
	check(not feedback.view.report_button.visible, "Unfinished encounter offers a completed reward screen")
	encounter.start_encounter()
	await create_timer(encounter.arrival_warning_seconds + .2).timeout
	check(encounter.get_progress().total == encounter.waves[0].total_enemy_count(), "Objective ignores queued reinforcements")
	var first: Node = encounter.actors.get_children().filter(func(node: Node) -> bool: return node != actor and node.get("health_component") != null)[0]
	kill(first,actor)
	await process_frame
	check(encounter.get_progress().defeated == 1, "Objective does not update on an authoritative death")
	check(feedback.receipt().gold > 0 and feedback.receipt().xp > 0, "Receipt does not observe actual enemy rewards")
	await capture("objective_wave.png")
	await clear_waves(stage)
	await create_timer(1.0).timeout
	check(CompletionReturn.can_return(stage) and not root.get_node("LootService").has_active_expedition(), "Ordinary clear did not bank loot/open the safe return")
	check(feedback.view.status.text.contains("portal"), "Completed objective does not explain F portal travel")
	check(feedback.receipt().xp == actor.progression_component.total_experience and feedback.receipt().gold == actor.progression_component.coins, "Stage receipt totals differ from the credited progression")
	check_materials(feedback.receipt(), {})
	await click(feedback.view.report_button.get_global_rect().get_center())
	check(feedback.view.report.visible and paused and not stage.character_menu.is_processing_input(), "Receipt does not own its modal/pause/input boundary")
	check_bounds(stage)
	await capture("ordinary_receipt.png")
	var snapshot: Dictionary = save.create_profile_snapshot()
	await key(KEY_ESCAPE)
	check(not paused and stage.character_menu.is_processing_input(), "Closing receipt leaves gameplay or Tab disabled")
	await click(feedback.view.report_button.get_global_rect().get_center())
	check(snapshot == save.create_profile_snapshot(), "Reopening a receipt grants rewards again")
	await click(feedback.view.return_button.get_global_rect().get_center())
	await root.get_node("SceneTransition").transition_finished
	check(current_scene.scene_file_path == CompletionReturn.SANCTUARY, "Receipt return does not reach the normal Sanctuary")
	check(root.get_node("RunSession").coins == snapshot.run_session.coins, "Victory return loses earned coins")
	check(current_scene.player.health_component.current_health == current_scene.player.health_component.maximum_health, "Victory return bypasses Sanctuary recovery")
	check(save.load_profile() == CompletionReturn.SANCTUARY, "Continue cannot load the completion/recovery save")
	stage = await load_stage(STAGE2)
	var stage_2_start_coins: int = root.get_node("RunSession").coins
	stage.encounter_controller.start_encounter()
	await clear_waves(stage)
	feedback = stage.expedition_feedback
	check(CompletionReturn.can_return(stage) and not root.get_node("LootService").has_active_expedition(), "Renewed Stage II did not bank its actual clear")
	check(feedback.receipt().gold == root.get_node("RunSession").coins-stage_2_start_coins, "Renewed Stage II receipt differs from earned coins")
	check(root.get_node("StoryState").has_story_flag(&"forgotten_grove_completed"), "Renewed Stage II lost its story milestone")
	await click(feedback.view.report_button.get_global_rect().get_center())
	check_bounds(stage)
	await click(feedback.view.return_button.get_global_rect().get_center())
	await root.get_node("SceneTransition").transition_finished
	check(current_scene.scene_file_path == CompletionReturn.SANCTUARY and save.load_profile() == CompletionReturn.SANCTUARY, "Renewed Stage II clear cannot return/save/Continue normally")
	# Near the real stage cap: only one XP can be credited before the Husk clear.
	root.get_node("RunSession").update_progression(1199,500)
	stage = await load_stage(STAGE3)
	feedback = stage.expedition_feedback
	var before_materials: Dictionary = root.get_node("MaterialInventory").create_snapshot()
	stage.encounter_controller.start_encounter()
	await clear_waves(stage)
	check(not CompletionReturn.can_return(stage) and root.get_node("LootService").has_active_expedition(), "Husk victory bypasses the unclaimed milestone chest")
	check(feedback.view.objective.text.contains("Reliquary") and not feedback.view.report_button.visible, "Milestone tracker falsely announces an open exit")
	await capture("objective_chest.png")
	await claim_chest(stage)
	await create_timer(1.0).timeout
	check(is_equal_approx(root.get_node("AudioDirector").music_player.volume_db,-17.0),"Claimed Husk clear did not soften the active boss music")
	check(is_equal_approx(stage.get_node("World/OutdoorAudio").bed.volume_db,-30.0),"Claimed Husk clear did not recover Hollow ambience")
	check(feedback.receipt().clear_kind == "FIRST CLEAR", "Reliquary receipt loses authoritative first-clear status")
	check(feedback.receipt().xp == 1, "Receipt counts XP blocked by the stage cap")
	check(root.get_node("StoryState").has_story_flag(&"rootbound_hollow_completed"), "Claim did not unlock the authored story progression")
	check_materials(feedback.receipt(), before_materials)
	await click(feedback.view.report_button.get_global_rect().get_center())
	check_bounds(stage)
	await capture("milestone_receipt.png")
	await key(KEY_TAB)
	check(not paused and not stage.character_menu.visible, "Tab opens a second modal under the receipt")
	# Replay the actual encounter; do not re-grant first-clear state.
	stage = await load_stage(STAGE3)
	stage.encounter_controller.start_encounter()
	await clear_waves(stage)
	await claim_chest(stage)
	check(stage.expedition_feedback.receipt().clear_kind == "REPLAY CLEAR", "Replay uses first-clear copy/rewards")
	stage = await load_stage(STAGE4)
	var stage_4_start_coins: int = root.get_node("RunSession").coins
	stage.encounter_controller.start_encounter()
	await clear_waves(stage)
	await create_timer(1.0).timeout
	feedback = stage.expedition_feedback
	check(CompletionReturn.can_return(stage) and not root.get_node("LootService").has_active_expedition(),"Renewed IV cannot bank its normal 50-enemy clear")
	check(root.get_node("StoryState").has_story_flag(&"forest_stage_4_cleared"),"Renewed IV lost its campaign clear flag")
	check(feedback.receipt().gold == root.get_node("RunSession").coins-stage_4_start_coins,"Renewed IV receipt differs from earned coins")
	check(is_equal_approx(stage.get_node("World/EasternRotAudio").bed.volume_db,-30.0),"IV clear did not restore its eastern ambience")
	await click(feedback.view.report_button.get_global_rect().get_center())
	check_bounds(stage)
	await capture("eastern_rot_receipt.png")
	await click(feedback.view.return_button.get_global_rect().get_center())
	await root.get_node("SceneTransition").transition_finished
	check(current_scene.scene_file_path == CompletionReturn.SANCTUARY and save.load_profile() == CompletionReturn.SANCTUARY,"Renewed IV cannot return/save/Continue normally")
	# Preceding-stage stock is a fixture; the Varkuun Core below is actually earned.
	root.get_node("MaterialInventory").add_material(&"forest_living_bark_plate",3)
	root.get_node("MaterialInventory").add_material(&"forest_rootbound_core",2)
	root.get_node("MaterialInventory").add_material(&"forest_forsaken_cloth",4)
	root.get_node("RunSession").update_progression(1750,750)
	stage = await load_stage(STAGE5)
	check(not CompletionReturn.can_return(stage), "Boss stage can return before its chest claim")
	var approach: EncounterController = stage.approach_encounter
	approach.waves = [approach.waves[0].duplicate(true)]
	approach.waves[0].spawn_interval = .05
	approach.waves[0].reinforcement_delay = .05
	approach.inter_wave_delay = .05
	approach.start_encounter()
	var approach_deadline := Time.get_ticks_msec()+6000
	while not approach._completion_spawned and Time.get_ticks_msec()<approach_deadline:
		for sentry in approach.actors.get_children():
			if sentry != stage.player and sentry != stage.boss and sentry.get("health_component") != null:
				sentry.set_physics_process(false)
				kill(sentry,stage.player)
		await process_frame
	check(approach._completion_spawned and not CompletionReturn.can_return(stage),"Guard clear skipped the required boss/chest")
	stage._on_boss_trigger_entered(stage.player)
	await create_timer(1.7).timeout
	if stage.dialogue_panel.visible: await click(stage.dialogue_panel.skip_button.get_global_rect().get_center())
	kill(stage.boss,stage.player)
	await process_frame
	if stage.dialogue_panel.visible: await click(stage.dialogue_panel.skip_button.get_global_rect().get_center())
	await create_timer(2.35).timeout
	check(not CompletionReturn.can_return(stage), "Boss death skips the Varkuun Chest requirement")
	await claim_chest(stage)
	feedback = stage.expedition_feedback
	check(stage.stage_completed and CompletionReturn.can_return(stage), "Boss claim does not enable completion return")
	check(feedback.receipt().unlocks.any(func(text: String) -> bool: return text.contains("crafting")), "Varkuun receipt omits Nema's real crafting unlock")
	await click(feedback.view.report_button.get_global_rect().get_center())
	check_bounds(stage)
	await capture("varkuun_receipt.png")
	await click(feedback.view.return_button.get_global_rect().get_center())
	await root.get_node("SceneTransition").transition_finished
	var hub: Node = current_scene
	var recipe: RecipeDefinition = hub.rootforge_menu.catalog.find_recipe(&"forest_stage_5_old_bark_helm")
	var core_before: int = root.get_node("MaterialInventory").get_quantity(&"forest_varkuun_core")
	check(core_before >= 2, "Varkuun's first-clear catalyst was not actually earned")
	hub.get_node("SanctuaryTown").visit_nema()
	await create_timer(.2).timeout
	await key(KEY_F)
	check(hub.dialogue_panel.visible, "Victory return cannot reach Nema through F")
	await finish_dialogue(hub.dialogue_panel)
	hub.rootforge_menu._select_recipe(recipe)
	await process_frame
	check(hub.rootforge_menu.visible and not hub.rootforge_menu.primary_action_button.disabled, "Earned seal/catalyst does not enable Nema's actual recipe")
	var craft_scroll := hub.rootforge_menu.primary_action_button.find_parent("BodyScroll") as ScrollContainer
	if craft_scroll != null: craft_scroll.scroll_vertical = int(craft_scroll.get_v_scroll_bar().max_value)
	await process_frame
	await capture("nema_earned_core.png")
	await click(hub.rootforge_menu.primary_action_button.get_global_rect().get_center())
	check(root.get_node("GearInventory").owns_item(recipe.output_id) and root.get_node("MaterialInventory").get_quantity(&"forest_varkuun_core") == core_before-1, "Earned catalyst cannot become real Nema equipment")
	await key(KEY_ESCAPE)
	hub.character_menu.open_menu()
	await process_frame
	await process_frame
	var card: InventorySlotButton
	for slot: InventorySlotButton in hub.character_menu._equipment_cards:
		if slot.equipment_definition.item_id == recipe.output_id: card = slot
	check(card != null, "Crafted helm is absent from the actual bag")
	if card != null:
		await click(card.get_global_rect().get_center())
		check(hub.character_menu.equipment_detail_panel.current_definition.item_id == recipe.output_id, "New helmet click does not select its real equip action")
		await click(hub.character_menu.equipment_detail_panel.equip_button.get_global_rect().get_center())
	var equipped: EquipmentDefinition = hub.player.get_equipped_gear(EquipmentDefinition.Slot.HEAD)
	check(equipped != null and equipped.item_id == recipe.output_id, "Bag does not equip the newly crafted helmet")
	await key(KEY_ESCAPE)
	hub.get_node("SanctuaryTown").visit_eira()
	await create_timer(.2).timeout
	await key(KEY_F)
	check(hub.dialogue_panel.visible, "Eira cannot be reached after the expedition/craft/equip loop")
	await finish_dialogue(hub.dialogue_panel)
	var library: KingSkillLibrary = hub.player.get_node("KingSkillLibrary")
	var collection: Node = library._collection
	check(is_instance_valid(collection) and collection.trainer_access, "Eira does not open actual trainer authority")
	if is_instance_valid(collection):
		await click(collection._list.get_node("Technique_sovereign_pursuit").get_global_rect().get_center())
		await click(collection._upgrade_button.get_global_rect().get_center())
	check(root.get_node("RunSession").king_pursuit_rank == 1, "Eligible Pursuit training does not apply from Eira")
	await key(KEY_ESCAPE)
	check(save.save_profile() and save.load_profile() == CompletionReturn.SANCTUARY, "Craft/equip state cannot save and Continue")
	equipped = root.get_node("GearInventory").get_equipped_item(hub.player.character_id,EquipmentDefinition.Slot.HEAD)
	check(equipped != null and equipped.item_id == recipe.output_id and root.get_node("RunSession").king_pursuit_rank == 1, "Continue loses equipped gear or trained rank")
	print("EXPEDITION_FEEDBACK: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)

func load_stage(scene: PackedScene) -> Node:
	if current_scene != null:
		current_scene.queue_free()
		await process_frame
		await process_frame
	root.get_node("LootService").reset_expedition_tracking()
	var stage := scene.instantiate()
	if "review_hold_encounter" in stage: stage.review_hold_encounter = true
	if "review_hold_approach" in stage: stage.review_hold_approach = true
	if "encounter_controller" in stage:
		var encounter: EncounterController = stage.encounter_controller
		encounter.auto_start = false
		encounter.inter_wave_delay = .15
		for index in encounter.waves.size():
			encounter.waves[index] = encounter.waves[index].duplicate(true)
			encounter.waves[index].spawn_interval = .1
			encounter.waves[index].reinforcement_delay = .25
	root.add_child(stage)
	current_scene = stage
	await process_frame
	await process_frame
	return stage

func clear_waves(stage: Node) -> void:
	var encounter: EncounterController = stage.encounter_controller
	var arrival_budget := 0.0
	for wave: EncounterWaveDefinition in encounter.waves:
		arrival_budget += wave.total_enemy_count() * encounter.arrival_warning_seconds
	var deadline := Time.get_ticks_msec()+20000+int(arrival_budget*1000)
	while encounter.wave_index < encounter.waves.size() and Time.get_ticks_msec() < deadline:
		if "dialogue_panel" in stage and stage.dialogue_panel.visible:
			await click(stage.dialogue_panel.skip_button.get_global_rect().get_center())
		for actor in encounter.actors.get_children():
			if actor != stage.player and actor.get("health_component") != null:
				actor.set_physics_process(false)
				kill(actor,stage.player)
		await process_frame
	check(encounter.wave_index >= encounter.waves.size(), "Authored encounter did not finish before timeout")
	await process_frame

func kill(actor: Node, player: Player) -> void:
	var health := actor.get("health_component") as HealthComponent
	if health.current_health <= 0: return
	var damage := DamageInfo.new(health.maximum_health*10,player,Vector2.ZERO)
	damage.ignores_invulnerability = true
	health.apply_damage(damage)

func claim_chest(stage: Node) -> void:
	var chest: StageRewardChest
	var parent: Node = stage.encounter_controller.actors if "encounter_controller" in stage else stage.reward_parent
	for child in parent.get_children():
		if child is StageRewardChest: chest = child
	check(chest != null, "Milestone chest was not spawned")
	if chest == null: return
	await create_timer(.4).timeout
	stage.player.combat_targeting.cancel_click_move()
	stage.player.global_position = chest.global_position+Vector2(0,-26)
	await physics_frame
	await physics_frame
	var deadline := Time.get_ticks_msec()+1000
	while not chest._player_inside and Time.get_ticks_msec() < deadline:
		await process_frame
	await key(KEY_F)
	check(chest._claimed, "Real F interaction did not claim the milestone reward")
	if not chest._claimed:
		quit(1)
	await process_frame

func check_materials(receipt: Dictionary, previous: Dictionary) -> void:
	var before: Dictionary = previous.get("quantities", {})
	for stack: Dictionary in receipt.materials:
		check(root.get_node("MaterialInventory").get_quantity(stack.material.material_id)-int(before.get(String(stack.material.material_id),0)) == stack.quantity, "Receipt quantity differs from material inventory: "+stack.material.display_name)

func check_bounds(stage: Node) -> void:
	var view: Control = stage.expedition_feedback.view
	check(Rect2(Vector2.ZERO,Vector2(960,540)).encloses(view.report.get_global_rect()), "Receipt exceeds the native viewport")
	check(not view.tracker.get_global_rect().intersects(stage.combat_hud.enemy_roster_panel.get_global_rect()), "Objective overlaps enemy roster")
	check(not view.tracker.get_global_rect().intersects(stage.combat_hud.get_node("LootToastPanel").get_global_rect()), "Objective overlaps loot notifications")
	check(not stage.combat_hud.enemy_roster_panel.get_global_rect().intersects(stage.combat_hud.get_node("LootToastPanel").get_global_rect()), "Enemy roster overlaps loot notifications")
	check(view.report.get_global_rect().encloses(view.return_button.get_global_rect()), "Sanctuary return is outside the visible receipt")

func capture(file: String) -> void:
	if DisplayServer.get_name() == "headless": return
	await process_frame
	await RenderingServer.frame_post_draw
	var evidence := "res://tmp/review/ui/expedition_feedback_stage_3_2026_10_03/" if "--stage-3-evidence" in OS.get_cmdline_user_args() else EVIDENCE
	if "--stage-4-evidence" in OS.get_cmdline_user_args(): evidence = "res://tmp/review/ui/expedition_feedback_stage_4_2026_10_03/"
	DirAccess.make_dir_recursive_absolute(evidence)
	check(root.get_texture().get_image().save_png(evidence+file) == OK, "Evidence capture failed")

func key(code: Key) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.keycode = code
	event.pressed = true
	root.push_input(event)
	event = event.duplicate()
	event.pressed = false
	root.push_input(event)
	await process_frame
	await process_frame

func click(position: Vector2) -> void:
	Input.warp_mouse(position)
	await process_frame
	var event := InputEventMouseButton.new()
	event.position = position
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	root.push_input(event)
	event = event.duplicate()
	event.pressed = false
	root.push_input(event)
	await process_frame
	await process_frame

func finish_dialogue(panel: DialoguePanel) -> void:
	var steps := 0
	while panel.visible and steps < 30:
		await click(panel.continue_button.get_global_rect().get_center())
		steps += 1
	check(not panel.visible, "Continue cannot finish the NPC conversation")
