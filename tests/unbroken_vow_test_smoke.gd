extends SceneTree

const LAB = preload("res://levels/combat_lab/combat_lab.tscn")
var failures := 0
var checks := 0
var contacts := 0
var returns := 0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	var saved_slots: Array = root.get_node("RunSession").king_skill_slots.duplicate()
	var lab: Node = LAB.instantiate()
	root.add_child(lab)
	await process_frame
	await process_frame
	lab.clear_simulation()
	var actor: Player = lab.player
	var review: Node = lab.get_node("KingCombatReview")
	var test: Node = review.buff_test
	var body: AnimatedSprite2D = actor.get_node("VisualRoot/Body")
	var original_frames := body.sprite_frames
	var health := actor.health_component.current_health
	var armor := actor.health_component.armor_rating
	var speed := actor.movement_component.max_speed
	var slots: Array = actor.get_node("KingSkillLibrary").current_ids()
	var zoom: Vector2 = lab.camera.zoom
	var ai: bool = lab._ai_enabled
	test.pressure_released.connect(func() -> void: contacts += 1)
	test.control_returned.connect(func() -> void: returns += 1)
	check(test.open(), "Test did not open from KING REVIEW")
	check(not lab._ai_enabled and test._panel.visible, "Test did not pause AI/show its controls")
	check(test.play_preview(), "Replay did not start")
	test.set_physics_process(false)
	check(actor.is_cinematic_locked() and not body.visible, "Cast did not own the short control lock")
	check(test._cast.scale == body.scale and body.scale == Vector2(.5, .5), "Test changed character scale")
	check(test._cast.position + Vector2(96, 96) * test._cast.scale == Vector2.ZERO, "Cast feet are not at the real player origin")
	check(not test.play_preview(), "Reentrant replay was accepted")
	test.advance(.159)
	check(contacts == 0 and actor.is_cinematic_locked(), "Pressure/control fired before the release beat")
	test.advance(.002)
	check(contacts == 1 and test.released, "Pressure did not fire at pose five")
	test.advance(.148)
	check(contacts == 1 and actor.is_cinematic_locked(), "Repeated contact or early recovery")
	test.advance(.012)
	check(returns == 1 and not actor.is_cinematic_locked() and body.visible, "Normal cast did not return control after .32s")
	check(test.active and not test._cast.visible and test._visual.visible, "Sustain did not outlive the cast")
	check(body.sprite_frames == original_frames, "Review replaced production SpriteFrames")
	var before := actor.position
	Input.action_press("player_move_right")
	for index in 8:
		await physics_frame
	Input.action_release("player_move_right")
	await physics_frame
	check(actor.position.x > before.x + 1, "Real movement did not resume while barrier was active")
	check(test._visual.get_parent() == actor, "Barrier does not follow the real player")
	check(actor.request_evade(Vector2.RIGHT), "Real dodge was blocked by the visual sustain")
	await create_timer(.45).timeout
	check(actor.request_primary_attack(), "Real attack was blocked by the visual sustain")
	await create_timer(.65).timeout
	check(actor.health_component.current_health == health and actor.health_component.armor_rating == armor and actor.movement_component.max_speed == speed, "Visual test changed health/armor/speed")
	check(actor.get_node("KingSkillLibrary").current_ids() == slots, "Visual test changed live slots")
	test.advance(6.0)
	check(not test.active and not test._visual.visible and not actor.is_cinematic_locked(), "Timed end left visual/control behind")
	# Slow timing and interrupted cleanup use the same playback authority.
	test.slow = true
	check(test.play_preview(), "Slow replay did not start")
	test.set_physics_process(false)
	test.advance(.33)
	check(actor.is_cinematic_locked() and contacts == 1, "Slow mode used normal release timing")
	test.advance(.16)
	check(contacts == 2, "Slow pressure beat missing")
	test.advance(.48)
	check(not actor.is_cinematic_locked() and returns == 2, "Slow cast did not release at .96s")
	test.reset_preview()
	test.slow = false
	check(test.play_preview(), "Cancel case could not start")
	test.set_physics_process(false)
	test.advance(.08)
	test.close()
	check(not actor.is_cinematic_locked() and body.visible and not test.active, "Closing mid-cast left player hidden/locked")
	check(lab._ai_enabled == ai and lab.camera.zoom == zoom and not test._panel.visible, "Closing failed to restore Lab settings")
	check(root.get_node("RunSession").king_skill_slots == saved_slots, "Test changed saved loadout state")
	# Removing the test node mid-cast must release its sibling-owned visuals.
	check(test.open() and test.play_preview(), "Cleanup replay did not start")
	test.queue_free()
	await process_frame
	await process_frame
	check(not actor.is_cinematic_locked() and body.visible and actor.get_node_or_null("UnbrokenVowTestVisual") == null, "Freeing test left player state/visuals behind")
	check(lab._ai_enabled == ai and lab.camera.zoom == zoom, "Freeing test did not restore Lab settings")
	lab.queue_free()
	await process_frame
	print("UNBROKEN_VOW_TEST_CHECKS=", checks, " FAILURES=", failures)
	quit(1 if failures else 0)

func check(ok: bool, reason: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(reason)
