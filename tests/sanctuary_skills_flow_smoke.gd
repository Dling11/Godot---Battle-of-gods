extends "res://tests/sanctuary_test_base.gd"

const EVIDENCE := "res://tmp/review/ui/eira_training_v2_2026_10_02/"

func _run() -> void:
	root.size = Vector2i(960,540)
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	var hub: Node = HUB.instantiate()
	root.add_child(hub)
	current_scene = hub
	await process_frame
	var study: Node = hub.get_node("SanctuaryTown")
	study.enable_test_controls()
	study.visit_eira()
	await create_timer(.2).timeout
	var eira: DialogueNpc = hub.skillkeeper
	var books: Sprite2D = study.dressing.stations[1].get_node("Art")
	var book_rect: Rect2 = books.global_transform*books.get_rect()
	check(eira.position.x > book_rect.end.x+20,"Eira is not beside the right of her workstation")
	check(absf(eira.position.y-study.dressing.stations[1].position.y)<1,"Eira is below the books instead of directly beside their right edge")
	var name_label: Label = study.eira_review.nameplate._name_label
	var font: Font = name_label.get_theme_font("font")
	var width: float = font.get_string_size(name_label.text,HORIZONTAL_ALIGNMENT_LEFT,-1,name_label.get_theme_font_size("font_size")).x
	var glyph_rect := Rect2(Vector2(name_label.get_global_rect().get_center().x-width/2,name_label.global_position.y),Vector2(width,name_label.size.y)).grow(3)
	check(not glyph_rect.intersects(book_rect),"Eira name still merges with the books")
	check(not _blocked(eira.get_world_2d().direct_space_state,hub.player.position),"Eira visit point is blocked")
	check(eira._player_inside and eira.prompt_text.contains("TRAIN"),"Eira approach lacks the skill-training interaction")
	await capture("eira_workstation.png")
	await key(KEY_F)
	check(hub.dialogue_panel.visible,"Physical F does not reach Eira")
	check(eira.dialogue_lines[0].contains("Unbroken Vow") and eira.dialogue_lines[0].contains("Molten Crash"),"Eira still describes retired skills")
	hub.dialogue_panel.close_dialogue(true)
	await process_frame
	var menu: CharacterMenu = hub.character_menu
	check(menu.visible and menu._skillkeeper_access and menu.collection_button.text == "TRAIN & ARRANGE","Eira training context is missing")
	var library: KingSkillLibrary = hub.player.get_node("KingSkillLibrary")
	var collection: Node = library._collection
	check(is_instance_valid(collection) and collection.trainer_access and collection._training_mode,"Eira does not open her dedicated training screen directly")
	await capture("eira_training_direct.png")
	await key(KEY_ESCAPE)
	check(not menu.visible and not paused,"Closing direct Eira training leaves another modal or pause behind")
	menu.open_menu()
	menu._show_page(&"skills",false)
	check(menu.skills_container.columns == 5 and menu._skill_cards.size() == 10,"Combat slots are not arranged as two rows of five")
	for card: SkillSlotCard in menu._skill_cards:
		check(card.size.y <= 60 and card.get_theme_constant("icon_max_width") == 24,"Skill art stretches a combat slot")
	check(menu._future_skill_cards[0].get_parent() != menu.skills_container,"Future tiers compete with usable combat slots")
	menu._skill_cards[0].grab_focus()
	await key(KEY_DOWN)
	check(root.gui_get_focus_owner() == menu._skill_cards[5],"Down-arrow does not follow the visible slot grid")
	await capture("eira_skills.png")
	await click(menu.collection_button.get_global_rect().get_center())
	collection = library._collection
	check(is_instance_valid(collection) and not collection.trainer_access,"Ordinary arranging gains trainer access")
	await process_frame
	check(Rect2(Vector2.ZERO,Vector2(960,540)).encloses(collection._panel.get_global_rect()),"Training panel exceeds native viewport")
	check(String(collection._list.get_child(3).name) == "Technique_unbroken_vow","Technique list disagrees with the core hotkey order")
	var pursuit_button: Button = collection._list.get_node("Technique_sovereign_pursuit")
	await click(pursuit_button.get_global_rect().get_center())
	collection.trainer_access = true # Exercise a valid trainer context without an extra dialogue round.
	await click(collection._training_tab.get_global_rect().get_center())
	check(collection._upgrade_button.disabled and collection._upgrade_button.text == "Requires Level 5","Locked training lacks its exact requirement")
	check(collection._detail.text.contains("current Level 1") and collection._detail.text.contains("2 aimed uses"),"Training does not explain the next rank and current level")
	await capture("eira_training_requirements.png")
	await click(collection._loadout_tab.get_global_rect().get_center())
	check(collection._slots.visible and not collection._upgrade_button.visible,"Training controls interfere with loadout arrangement")
	var before := library.current_ids()
	await click(collection._slots.get_child(0).get_global_rect().get_center())
	check(library.current_ids()[0] == "sovereign_pursuit" and library.current_ids()[2] == before[0],"Assigning into an occupied slot loses rather than swaps the other technique")
	check(collection._status.text.contains("assigned to [1]"),"Slot assignment has no visible result")
	check(root.gui_get_focus_owner() == collection._slots.get_child(0),"Rebuilding slots loses keyboard focus")
	check(menu._skill_cards[0].slot_definition.ability.ability_id == &"sovereign_pursuit","Character menu does not reflect rearranged skills")
	check(hub.combat_hud.get_skill_slot(1).slot_definition.ability.ability_id == &"sovereign_pursuit","Live action bar does not reflect rearranged skills")
	await capture("skill_swap.png")
	await click(collection._clear_button.get_global_rect().get_center())
	check(library.current_ids()[0] == "" and collection._status.text.contains("cleared"),"Clear-slot button is not functional")
	await click(collection._slots.get_child(2).get_global_rect().get_center(),MOUSE_BUTTON_RIGHT)
	check(library.current_ids()[2] == "","Right-click does not clear an occupied slot")
	await click(collection._core_button.get_global_rect().get_center())
	check(library.current_ids() == before and collection._status.text.contains("restored"),"Restore core layout does not restore the playable kit")
	await key(KEY_ESCAPE)
	check(not is_instance_valid(library._collection) and paused and menu.visible,"Esc from collection does not return to the paused skill menu")
	await key(KEY_ESCAPE)
	check(not menu.visible and not paused,"Esc from Eira skills fails to resume gameplay")
	menu.open_menu()
	menu._show_page(&"skills",false)
	check(not menu._skillkeeper_access and menu.collection_button.text == "ARRANGE SKILLS","Trainer access leaks into ordinary inventory")
	await click(menu.collection_button.get_global_rect().get_center())
	collection = library._collection
	await click(collection._list.get_node("Technique_unbroken_vow").get_global_rect().get_center())
	await click(collection._training_tab.get_global_rect().get_center())
	check(collection._upgrade_button.disabled and collection._upgrade_button.text == "Visit Eira to train","Ordinary loadout grants remote NPC training")
	await capture("ordinary_skill_loadout.png")
	await key(KEY_ESCAPE)
	await key(KEY_ESCAPE)
	root.get_node("StoryState").remember_story(&"forest_stage_5_cleared")
	root.get_node("RunSession").update_progression(4950,0)
	menu.open_skillkeeper_menu()
	await process_frame
	collection = library._collection
	for id: String in KingSkillCatalog.IDS:
		await click(collection._list.get_node("Technique_"+id).get_global_rect().get_center())
		var course := library.training_info(id)
		for index in course.levels.size():
			check(not collection._upgrade_button.disabled,"Eligible training is not available through the real modal")
			await click(collection._upgrade_button.get_global_rect().get_center())
			check(library.training_info(id).rank == index+1 and collection._status.text.contains("trained"),"Real training click did not update the rank and feedback")
		check(collection._upgrade_button.disabled and collection._upgrade_button.text == "Fully trained","Completed course still offers another purchase")
		check(Rect2(Vector2.ZERO,Vector2(960,540)).encloses(collection._panel.get_global_rect()),"Eligible rank ladder exceeds native viewport")
		await capture("trained_"+id+".png")
	await key(KEY_ESCAPE)
	check(not paused and not menu.visible,"Eligible training leaves gameplay paused")
	check(root.get_node("SaveService").is_autosave_suppressed_for_debug(),"Functional review permits profile writes")
	hub.queue_free()
	current_scene = null
	await process_frame
	await process_frame
	print("SANCTUARY_SKILLS_FLOW: ",checks," checks, ",failures," failures")
	quit(1 if failures else 0)

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

func click(point: Vector2, button: MouseButton = MOUSE_BUTTON_LEFT) -> void:
	var event := InputEventMouseButton.new()
	event.position = point
	event.button_index = button
	event.pressed = true
	root.push_input(event)
	event = event.duplicate()
	event.pressed = false
	root.push_input(event)
	await process_frame
	await process_frame

func capture(file: String) -> void:
	if DisplayServer.get_name() == "headless": return
	await process_frame
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(EVIDENCE)
	check(root.get_texture().get_image().save_png(EVIDENCE+file) == OK,"Capture failed")
