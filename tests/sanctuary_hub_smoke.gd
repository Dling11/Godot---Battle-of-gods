extends "res://tests/sanctuary_test_base.gd"

const PROFILE := "user://sanctuary_closeout_smoke.json"
const EVIDENCE := "res://tmp/review/environment/sanctuary_paperdoll_2026_10_02/"

func _run() -> void:
	root.size = Vector2i(960,540)
	var save: Node = root.get_node("SaveService")
	check(save.configure_storage_path_for_testing(PROFILE),"Cannot isolate closeout save")
	save.delete_profile()
	for reset in [["RunSession","reset_run"],["StoryState","reset_story"],["MaterialInventory","reset_inventory"],["GearInventory","reset_inventory"],["WeaponInventory","reset_inventory"],["RecipeDiscovery","reset_discoveries"],["LootState","reset_state"]]:
		root.get_node(reset[0]).call(reset[1])
	root.get_node("RunSession").update_progression(100,175)
	var hub: Node = HUB.instantiate()
	root.add_child(hub)
	current_scene = hub
	await create_timer(.2).timeout
	var town: Node = hub.get_node("SanctuaryTown")
	check(not save.is_autosave_suppressed_for_debug(),"Normal Sanctuary disables progression saves")
	check(save.has_valid_profile(),"Normal Sanctuary no longer writes a recovery checkpoint")
	check(not town.test_controls_enabled and not town._panel.visible,"Normal town exposes review controls")
	check(town.ground.get_used_cells().size() == 36*24,"Current ground does not cover Sanctuary")
	check(not town.town_map.enabled and not town.town_map.mini.visible and not town.town_map.panel.visible and town.town_map._timer.is_stopped(),"Withdrawn map is visible or still polling")
	town.town_map.set_enabled(true)
	town.town_map.toggle()
	town.town_map.select_destination("eira")
	check(not town.town_map.enabled and not town.town_map.panel.visible and town.town_map.selected_id.is_empty(),"Activation or selection revives the withdrawn map")
	check(town.dressing.trees.size() == 6 and town.dressing.buildings.size() == 2,"Current town dressing missing")
	check(town.beacons.size() == 4,"NPC discovery markers missing")
	for obsolete in ["ArmskeeperCart","SkillkeeperLodge","ArmskeeperWorkshop","TreeWest","LivingRootforge","EchoCrucible"]:
		check(not hub.has_node("World/Actors/"+obsolete),"Old town content still instantiated: "+obsolete)
	check(not town.has_method("set_review_enabled"),"Retired old/new toggle remains callable")
	check(hub.combat_hud.get_node("CompactSanctuaryFrame").visible,"Normal Sanctuary lacks compact action frame")
	check(hub.player.health_component.current_health == hub.player.health_component.maximum_health,"Sanctuary does not heal on entry")
	var space: PhysicsDirectSpaceState2D = hub.player.get_world_2d().direct_space_state
	check(not _blocked(space,hub.player.position),"Normal spawn is blocked")
	for building in [town.lodge,town.orren_review.workshop]+town.dressing.buildings:
		var approach: Vector2 = building.get_node("Approach").global_position
		check(not _blocked(space,approach),"Building approach is obstructed")
	for npc: DialogueNpc in [hub.weapon_merchant,hub.skillkeeper,hub.rootweaver,hub.echo_melder]:
		var sprite: AnimatedSprite2D = npc.get_node("Sprite")
		check(sprite.sprite_frames.resource_path.ends_with("renewal/sprite_frames.tres"),"Actor does not load current authored poses")
		check(sprite.sprite_frames.get_frame_count(sprite.animation)==8 and sprite.is_playing(),"Actor work animation missing")
		check(not npc.has_node("IdleBreath") and not npc.has_node("WorkIdle"),"Retired idle helper remains active")
		check(npc.dialogue_portrait.resource_path.ends_with("renewal/portrait.png"),"Dialogue uses a retired portrait")
	# Each service remains accessible through a real F input at its authored approach.
	for recipe in [["visit_orren",hub.weapon_merchant,null],["visit_eira",hub.skillkeeper,hub.character_menu],["visit_nema",hub.rootweaver,hub.rootforge_menu],["visit_umi",hub.echo_melder,hub.umi_exchange_menu]]:
		town.call(recipe[0])
		await create_timer(.2).timeout
		await press_f()
		check(hub.dialogue_panel.visible,"F fails at "+str(recipe[0]))
		check(not town.town_map.mini.visible,"Map covers dialogue")
		hub.dialogue_panel.close_dialogue(true)
		await process_frame
		if recipe[2] != null:
			check(recipe[2].visible,"Service menu no longer opens")
			check(recipe[2].get_node("Panel").get_theme_stylebox("panel") is StyleBoxTexture,"Service lacks current theme")
			recipe[2].close_menu()
		check(not paused,"Service leaves gameplay paused")
	# Normal saving still commits/reloads progression; presentation adds no fixture rewards.
	check(root.get_node("RunSession").coins == 175,"Town grants debug gold during normal play")
	check(save.save_profile(),"Normal-play profile save fails")
	root.get_node("RunSession").update_progression(0,0)
	check(save.load_profile()=="res://levels/sanctuary/sanctuary.tscn","Normal Continue route changed")
	check(root.get_node("RunSession").coins==175,"Normal profile loses progression")
	town.visit_workshop()
	await create_timer(.2).timeout
	check(not town.workshop_visit.inside,"Walking near a door enters automatically")
	await press_f()
	check(town.workshop_visit.inside,"F cannot enter the current workshop")
	town.workshop_visit.leave()
	check(not town.workshop_visit.inside and not town._panel.visible,"Leaving exposes debug UI")
	town.visit_eira()
	await create_timer(.2).timeout
	await capture("normal_town.png")
	# Debug entry reuses the same town and suppresses saves before test controls appear.
	root.get_node("DebugAdminState").set_enabled(true)
	hub._open_sanctuary_study()
	check(hub.get_node("SanctuaryTown")==town and hub._mount_town()==town,"Debug entry duplicates runtime town")
	check(save.is_autosave_suppressed_for_debug() and town.test_controls_enabled,"Debug preview no longer protects the profile")
	var checkpoint := FileAccess.get_md5(PROFILE)
	save.save_profile()
	check(FileAccess.get_md5(PROFILE)==checkpoint,"Debug preview writes normal progression")
	hub.queue_free()
	current_scene = null
	await process_frame
	await process_frame
	save.delete_profile()
	save.reset_storage_path_after_testing()
	print("SANCTUARY_CLOSEOUT: ",checks," checks, ",failures," failures")
	quit(1 if failures else 0)

func press_f() -> void:
	var event := InputEventAction.new()
	event.action = &"player_interact"
	event.pressed = true
	root.push_input(event)
	await process_frame
	event = InputEventAction.new()
	event.action = &"player_interact"
	root.push_input(event)
	await process_frame

func capture(file: String) -> void:
	if DisplayServer.get_name()=="headless": return
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(EVIDENCE)
	check(root.get_texture().get_image().save_png(EVIDENCE+file)==OK,"Native capture failed")
