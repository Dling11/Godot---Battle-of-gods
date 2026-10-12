extends SceneTree

const Lab = preload("res://levels/combat_lab/combat_lab.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var lab := Lab.instantiate()
	root.add_child(lab)
	await create_timer(.85).timeout
	var boss := lab._active_enemies[0] as Examiner
	boss.set_physics_process(false)
	var body := boss.get_node("Visual/Body") as AnimatedSprite2D
	boss._enter(Examiner.State.APPROACH, 0)
	boss._set_facing(Vector2.RIGHT)
	boss._set_moving(true)
	body.set_frame_and_progress(2, .4)
	boss._set_facing(Vector2.LEFT)
	if body.animation != &"walk_left" or body.frame != 2 or not is_equal_approx(body.frame_progress, .4):
		_fail("Turning restarted the alternating walk cycle.")
		return
	boss._set_moving(false)
	# Verify the player's readable contract, not just the existence of names:
	# a wind-up cannot display the texture used when damage first becomes live.
	for pair: Array in [["thrust", "thrust_strike"], ["sweep_wind_up", "sweep_strike"], ["slam_wind_up", "slam_contact"], ["charge_wind_up", "charge_travel"]]:
		for direction in ["down", "right", "left", "up"]:
			var wind_up: String = pair[0] + "_" + direction
			var contact: String = pair[1] + "_" + direction
			var contact_texture := body.sprite_frames.get_frame_texture(contact, 0) as AtlasTexture
			for frame in body.sprite_frames.get_frame_count(wind_up):
				var anticipation := body.sprite_frames.get_frame_texture(wind_up, frame) as AtlasTexture
				if anticipation.atlas == contact_texture.atlas and anticipation.region == contact_texture.region:
					_fail("Contact pose appears before damage in " + wind_up)
					return
	boss.global_position = Vector2(310, 250)
	lab.player.global_position = Vector2(600, 250)
	boss._begin_combo(Vector2.RIGHT)
	body.set_frame_and_progress(1, .5)
	boss._set_facing(Vector2.LEFT)
	if body.animation != &"thrust_left" or body.frame != 1 or not is_equal_approx(body.frame_progress, .5):
		_fail("Anticipation retargeting restarted or failed to turn the body.")
		return
	boss._state_remaining = 0
	boss._tick_state(0)
	if body.animation != &"thrust_strike_left" or body.frame != 0 or not body.is_playing():
		_fail("Thrust did not begin its animated contact at the damage boundary.")
		return
	boss._deactivate_hitboxes()
	# A real physics obstacle must stop a grounded dash before its far endpoint.
	var wall := StaticBody2D.new()
	wall.collision_layer = 1
	var collider := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(12, 150)
	collider.shape = shape
	wall.add_child(collider)
	lab.get_node("World").add_child(wall)
	wall.global_position = Vector2(390, 250)
	await physics_frame
	await physics_frame
	boss._begin_judgment_charge(Vector2(290, 0))
	boss._state_remaining = 0
	boss._tick_state(0)
	boss._process_travel(1.0)
	if boss.global_position.x > 375 or boss.state != Examiner.State.CHARGE_IMPACT:
		_fail("Judgment Charge tunneled through a real collision obstacle.")
		return
	wall.queue_free()
	# At 75% HP the legacy shared HUD used to falsely announce Phase II.
	lab.boss_hud.set_phase_status("FIRST MEASURE")
	boss.health_component.set_current_health(boss.health_component.maximum_health * .75)
	if lab.boss_hud.phase_label.text != "FIRST MEASURE":
		_fail("Shared health bands overrode Examiner-owned phase presentation.")
		return
	for point: Vector2 in lab.court_arena.protection_points():
		lab.court_arena.set_sanctuary(true, point)
		if not lab.court_arena.is_position_protected(point + Vector2(53, 0)) or lab.court_arena.is_position_protected(point + Vector2(55, 0)):
			_fail("Visible ward radius and safe-zone authority diverged.")
			return
	var panel := lab.get_node("UI/LabPanel") as Control
	if panel.get_global_rect().end.x > 960.1:
		_fail("Combat review controls overflow the logical viewport.")
		return
	lab.clear_simulation()
	lab.queue_free()
	await process_frame
	await process_frame
	print("Examiner rework: contact timing, directional continuity, physical charge collision, phase HUD, exact wards, and UI fit passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
