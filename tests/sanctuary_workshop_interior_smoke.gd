extends "res://tests/sanctuary_test_base.gd"

const EVIDENCE := "res://tmp/review/environment/sanctuary_closeout_2026_10_02/workshop/"

func _run() -> void:
	root.size = Vector2i(960,540)
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	var hub: Node = HUB.instantiate()
	root.add_child(hub)
	current_scene = hub
	await process_frame
	var study: Node = hub.get_node("SanctuaryTown")
	study.enable_test_controls()
	var selected_destination: String = study.town_map.selected_id
	var visit: Node = study.workshop_visit
	var player: Player = hub.player
	var bounds: Rect2 = player.movement_bounds
	var camera: Camera2D = player.get_node("Camera2D")
	var old_path_tolerance: float = player.combat_targeting.navigation_agent.path_desired_distance
	check(not visit.inside and not visit.room.visible and not visit.room.navigation.enabled,"Inactive workshop remains visible/navigable")
	study.visit_workshop()
	await create_timer(.2).timeout
	check(visit._target == "enter" and hub.combat_hud.interaction_panel.visible,"Workshop doorway has no entry prompt")
	await capture("doorway_native.png")
	var approach: Vector2 = player.global_position
	check(not visit.inside,"Workshop door button enters before reaching the doorstep")
	player.position = approach+Vector2(40,-20)
	visit._refresh()
	check(visit._target.is_empty() and not visit.enter(),"Workshop admits entry beside the doorway instead of in front")
	player.position = approach+Vector2(0,100)
	visit._refresh()
	check(visit._target.is_empty() and not visit.enter(),"Workshop admits entry too far from the door")
	player.position = approach
	visit._refresh()
	study.town_map.select_destination("eira")
	# Walking all the way to the door must keep F available without entering.
	Input.action_press("player_move_up")
	await create_timer(.3).timeout
	Input.action_release("player_move_up")
	await create_timer(.2).timeout
	check(not visit.inside and not visit.room.visible and not visit.room.navigation.enabled,"Walking to the doorstep enters without F")
	check(visit._target == "enter" and visit._prompt == "PRESS F · ENTER WORKSHOP" and hub.combat_hud.interaction_panel.visible,"F prompt disappears close to the door")
	await capture("close_door_prompt.png")
	await press_interact()
	check(visit.inside and visit.room.visible and visit.room.navigation.enabled,"Physical F at the doorstep fails to enter")
	check(visit.Room.FLOOR.has_point(player.global_position-visit.ROOM_ORIGIN),"F entry does not place King on the interior floor")
	check(player.movement_bounds != bounds and not player.is_cinematic_locked(),"Entry fails to give room bounds and player control")
	check(not study.town_map.mini.visible and not study._panel.visible and visit.title.visible,"Outdoor overlays cover workshop")
	study.town_map.toggle()
	check(not study.town_map.panel.visible,"Outdoor map opens indoors")
	await create_timer(.2).timeout
	var space := player.get_world_2d().direct_space_state
	for point in [Vector2(20,120),Vector2(460,120),Vector2(240,60),Vector2(240,180),Vector2(240,107),Vector2(396,112),Vector2(93,98)]:
		check(_blocked(space,visit.ROOM_ORIGIN+point),"Workshop wall/furniture is not solid: "+str(point))
	check(not _blocked(space,player.global_position),"Entry spawns King in collision")
	await capture("room_native.png")
	var review_position := player.position
	player.position = visit.ROOM_ORIGIN+Vector2(296,114)
	await capture("furniture_scale_native.png")
	player.position = review_position
	# Exercise Player's real movement and solid workbench, not only a shape query.
	Input.action_press("player_move_up")
	await create_timer(.7).timeout
	Input.action_release("player_move_up")
	check(player.position.y < visit.ROOM_ORIGIN.y+140 and player.position.y > visit.ROOM_ORIGIN.y+114,"Walking glides through the workbench or cannot move")
	player.position = visit.ROOM_ORIGIN+Vector2(160,103)
	await physics_frame
	await physics_frame
	var target: Vector2 = visit.ROOM_ORIGIN+Vector2(320,103)
	var path := NavigationServer2D.map_get_path(player.get_world_2d().navigation_map,player.global_position,target,true)
	check(path.size()>2,"Room navigation does not route around the bench")
	var mouse := InputEventMouseButton.new()
	mouse.button_index = MOUSE_BUTTON_RIGHT
	mouse.pressed = true
	mouse.position = player.get_global_transform_with_canvas()*player.to_local(target)
	# Player resolves world intent from the actual pointer, so move it as well as dispatching input.
	if DisplayServer.get_name() == "headless":
		player.combat_targeting.request_click_move(target)
	else:
		root.warp_mouse(mouse.position)
		await process_frame
		root.push_input(mouse)
	await create_timer(2.5).timeout
	check(player.global_position.distance_to(target)<16,"Actual mouse movement gets stuck on workshop furniture: "+str(player.global_position-visit.ROOM_ORIGIN)+" target="+str(player.combat_targeting._click_move_target-visit.ROOM_ORIGIN))
	player.combat_targeting.cancel_click_move()
	for recipe in [[Vector2(240,132),"THE WORKBENCH","bench_inspection.png"],[Vector2(396,139),"THE FORGE","forge_inspection.png"],[Vector2(93,121),"THE WEAPON RACK","rack_inspection.png"]]:
		player.position = visit.ROOM_ORIGIN+recipe[0]
		await create_timer(.2).timeout
		await press_interact()
		check(hub.dialogue_panel.visible and hub.dialogue_panel.speaker_label.text == recipe[1],"Furniture inspection fails: "+recipe[1])
		check(not visit.title.visible and not study._panel.visible,"Interior title/study controls obscure inspection")
		await capture(recipe[2])
		hub.dialogue_panel.close_dialogue(false)
		await create_timer(.2).timeout
		check(visit.inside and visit.title.visible and not study._panel.visible and not study.town_map.mini.visible,"Closing inspection restores outdoor overlays indoors")
	hub.character_menu.open_menu()
	await process_frame
	check(not visit.title.visible,"Interior title covers inventory")
	hub.character_menu.close_menu()
	await create_timer(.2).timeout
	check(visit.title.visible and visit.inside,"Closing inventory leaves workshop")
	# Clear a stale click destination at both transition boundaries.
	player.position = visit.ROOM_ORIGIN+visit.Room.EXIT
	player.combat_targeting.request_click_move(player.position+Vector2(0,1))
	await press_interact()
	check(not visit.inside and not visit.room.visible and not visit.room.navigation.enabled,"Real F fails to leave workshop")
	check(player.movement_bounds == bounds and player.position == study.orren_review.workshop.get_node("ReturnPoint").global_position,"Exit fails to restore bounds/courtyard return")
	check(not player.combat_targeting._click_move_active,"Room click movement leaks into town")
	check(player.combat_targeting.navigation_agent.path_desired_distance == old_path_tolerance,"Indoor path tolerance leaks into the town")
	check(not camera.is_set_as_top_level() and camera.zoom == Vector2.ONE and camera.limit_right == 1152,"Exit fails to restore courtyard camera")
	await create_timer(.2).timeout
	check(not visit.inside,"Courtyard return immediately re-enters workshop")
	check(not study.town_map.enabled and not study.town_map.mini.visible and study.town_map.selected_id == selected_destination and study._panel.visible,"Exit must preserve the withdrawn map and restore town controls")
	await capture("courtyard_return.png")
	study.visit_workshop()
	await create_timer(.2).timeout
	await press_interact()
	check(visit.inside,"Physical F entry no longer works from the lower approach")
	visit.leave()
	study.visit_workshop()
	player.position = study.orren_review.workshop.get_node("Doorway").global_position+Vector2(0,10)
	await press_interact()
	check(visit.inside,"Pressing F close to the door fails to enter or exits in the same event")
	visit.leave()
	study.visit_workshop()
	player.request_evade(Vector2.LEFT)
	check(not visit.enter(),"Doorway transfers during an active dash")
	player.evade_component.cancel_evade()
	check(visit.enter(),"Re-entry fails after dash ends")
	visit.leave()
	check(not visit.inside and player.movement_bounds == bounds,"Leaving strands King indoors")
	check(not _blocked(space,visit.ROOM_ORIGIN+Vector2(240,107)),"Hidden room retains collision")
	study.visit_workshop()
	await create_timer(.2).timeout
	check(visit.enter(),"Workshop cannot reopen after leaving")
	study.visit_eira()
	await create_timer(.2).timeout
	check(not visit.inside and player.position.distance_to(study.eira_review.APPROACH)<2,"Visit button strands player/camera indoors")
	await press_interact()
	check(hub.dialogue_panel.visible and hub.dialogue_panel.speaker_label.text == hub.skillkeeper.speaker_name,"Workshop input steals Eira service F")
	hub.dialogue_panel.close_dialogue(true)
	await process_frame
	check(hub.character_menu.visible,"Existing Eira skill service broke after workshop visit")
	hub.character_menu.close_menu()
	check(root.get_node("SaveService").is_autosave_suppressed_for_debug(),"Interior review permits saving")
	mouse = null
	hub.queue_free()
	current_scene = null
	await process_frame
	await process_frame
	print("SANCTUARY_WORKSHOP_INTERIOR: ",checks," checks, ",failures," failures")
	quit(1 if failures else 0)

func press_interact() -> void:
	var event := InputEventKey.new()
	event.physical_keycode = KEY_F
	event.keycode = KEY_F
	event.pressed = true
	root.push_input(event)
	event = event.duplicate()
	event.pressed = false
	root.push_input(event)
	await process_frame

func capture(file: String) -> void:
	if DisplayServer.get_name() == "headless": return
	await process_frame
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(EVIDENCE)
	check(root.get_texture().get_image().save_png(EVIDENCE+file) == OK,"Capture failed")
