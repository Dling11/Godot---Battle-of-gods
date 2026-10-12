extends SceneTree

const LAB = preload("res://levels/combat_lab/combat_lab.tscn")
const OUT := "res://tmp/review/ui/combat_lab_tabs_2026_09_27/"
var failures := 0
var checks := 0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	var session := root.get_node("RunSession")
	# A sparse custom campaign loadout must neither hide tests nor be overwritten.
	var saved := ["", "", "", "", "", "", "", "", "", "sovereign_pursuit"]
	session.king_skill_slots = saved.duplicate()
	session.king_pursuit_rank = 1
	var lab: Node = LAB.instantiate()
	root.add_child(lab)
	current_scene = lab
	await process_frame
	await process_frame
	await process_frame
	var actor: Player = lab.player
	var library: KingSkillLibrary = actor.get_node("KingSkillLibrary")
	var review: Node = lab.get_node("KingCombatReview")
	check(library.current_ids().slice(0, 5) == KingSkillCatalog.IDS, "Lab entry must equip every authored skill")
	check(session.king_skill_slots == saved, "Lab entry overwrote the saved loadout")
	check(actor.skill_loadout.get_slot(3).ability == actor.ability_3_component.definition, "Test kit lost trained Pursuit resource binding")
	check(lab.review_tabs.get_tab_count() == 3 and lab.review_tabs.current_tab == 0, "AI / Skills / Weapons tabs not initialized")
	check(lab.ai_toggle.is_visible_in_tree() and not review._panel.is_visible_in_tree(), "AI and Skills controls overlap")
	check(lab.review_tabs.get_tab_bar().focus_mode == Control.FOCUS_NONE, "Tabs can swallow Space after clicking")
	check(lab.get_node("UI/LabPanel").get_global_rect().end.y <= 438.0, "Sidebar intrudes on the action bar")
	check(lab.get_node("UI/LabPanel").get_global_rect().end.x <= 950.0, "Sidebar expands past viewport")
	await capture("01_ai.png")
	lab.clear_simulation()
	review.open_review()
	await process_frame
	await process_frame
	check(review._panel.is_visible_in_tree() and not lab.ai_toggle.is_visible_in_tree(), "Skills did not replace AI controls")
	# Exercise selector signals, including rejection during an actual cast lock.
	review._earth_form.select(1)
	review._earth_form.item_selected.emit(1)
	review._molten_form.select(3)
	review._molten_form.item_selected.emit(3)
	review._pursuit_rank.select(2)
	review._pursuit_rank.item_selected.emit(2)
	check(actor.ability_1_component.definition.form == 1 and actor.ability_2_component.definition.form == 3, "Upgrade selectors did not apply forms")
	check(actor.ability_3_component.definition.rank == 2, "Three-use upgrade did not apply")
	actor.set_cinematic_locked(true)
	review._earth_form.select(0)
	review._earth_form.item_selected.emit(0)
	check(review._earth_form.selected == 1 and actor.ability_1_component.definition.form == 1, "Rejected selector displayed an unapplied upgrade")
	actor.set_cinematic_locked(false)
	check(library.equip("", 1), "Could not prepare an empty test slot")
	var preset_key := InputEventKey.new()
	preset_key.physical_keycode = KEY_F9
	preset_key.keycode = KEY_F9
	preset_key.pressed = true
	Input.parse_input_event(preset_key)
	await process_frame
	preset_key.pressed = false
	Input.parse_input_event(preset_key)
	await process_frame
	check(library.current_ids().slice(0, 5) == KingSkillCatalog.IDS, "F9 did not restore all authored skills")
	check(actor.skill_loadout.get_slot(1).ability == actor.ability_1_component.definition and actor.skill_loadout.get_slot(3).ability == actor.ability_3_component.definition, "F9 discarded selected upgrade bindings")
	check(lab.review_tabs.current_tab == 1 and actor.ability_3_component.definition.rank == 2, "F9 lost the Skills page or selected rank")
	check(session.king_skill_slots == saved and session.king_pursuit_rank == 1, "Lab upgrades modified campaign training or slots")
	await capture("02_skills.png")
	lab.review_tabs.get_child(1).scroll_vertical = 10000
	await process_frame
	await capture("03_skills_lower.png")
	check(review.buff_test.open(), "Buff preview did not open inside Skills")
	await process_frame
	await process_frame
	check(review.buff_test._panel.is_visible_in_tree() and not review._panel.visible, "Buff controls overlap skill selectors")
	check(review.buff_test.play_preview(), "Buff replay unavailable")
	review.buff_test.set_physics_process(false)
	review.buff_test.advance(.17)
	await capture("04_buff.png")
	lab.review_tabs.current_tab = 0
	await process_frame
	check(not review.buff_test.opened and not actor.is_cinematic_locked() and actor.get_node("VisualRoot/Body").visible, "Changing tabs stranded preview state")
	check(lab._ai_enabled and lab.review_tabs.current_tab == 0, "Changing tabs did not restore AI or retained the wrong tab")
	lab.set_enemy_ai_enabled(false)
	check(review.buff_test.open(), "Could not reopen preview with AI already paused")
	lab.review_tabs.current_tab = 0
	check(not lab._ai_enabled, "Leaving preview enabled previously paused AI")
	check(library.equip("", 2), "Could not prepare another empty slot")
	lab.combat_tools_button.pressed.emit()
	check(library.current_ids().slice(0, 5) == KingSkillCatalog.IDS, "Sidebar refill did not restore the complete kit")
	lab.queue_free()
	current_scene = null
	await process_frame
	await process_frame
	print("COMBAT_LAB_SIDEBAR: ", checks, " checks, ", failures, " failures")
	quit(1 if failures else 0)

func capture(file: String) -> void:
	if DisplayServer.get_name() == "headless":
		return
	await process_frame
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(OUT)
	check(root.get_texture().get_image().save_png(OUT + file) == OK, "GPU capture failed")

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
