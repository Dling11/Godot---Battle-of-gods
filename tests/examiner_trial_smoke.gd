extends SceneTree

const LabScene = preload("res://levels/combat_lab/combat_lab.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var lab := LabScene.instantiate()
	root.add_child(lab)
	await process_frame
	await process_frame
	await physics_frame

	if lab.get_live_enemy_count() != 1 or lab._active_enemies.is_empty():
		_fail("Examiner trial did not create its opening actor.")
		return
	var examiner := lab._active_enemies[0] as Examiner
	if examiner == null:
		_fail("Combat Lab opening actor is not the Examiner.")
		return
	if examiner.definition.maximum_health != 1800.0 or examiner.definition.axiom_damage != 90.0 or examiner.definition.ground_judgment_damage != 110.0:
		_fail("Examiner did not receive its data-driven trial tuning.")
		return
	var body := examiner.get_node("Visual/Body") as AnimatedSprite2D
	if not is_equal_approx(body.position.y, -48.0):
		_fail("Examiner lost its normalized visual origin.")
		return
	if (
		body.sprite_frames.resource_path != "res://assets/characters/enemies/examiner/examiner_sprite_frames.tres"
		or body.sprite_frames.get_animation_names().size() != 116
	):
		_fail("Examiner must expose its complete saved SpriteFrames library in the scene and editor.")
		return
	var walk_right := body.sprite_frames.get_frame_texture(&"walk_right", 0) as AtlasTexture
	var walk_left := body.sprite_frames.get_frame_texture(&"walk_left", 0) as AtlasTexture
	var thrust_right := body.sprite_frames.get_frame_texture(&"thrust_right", 0) as AtlasTexture
	var thrust_left := body.sprite_frames.get_frame_texture(&"thrust_left", 0) as AtlasTexture
	if (
		walk_right == null
		or walk_left == null
		or thrust_right == null
		or thrust_left == null
		or walk_right.region.position.y != 160.0
		or walk_left.region.position.y != 320.0
		or thrust_right.region.position.y != 160.0
		or thrust_left.region.position.y != 320.0
	):
		_fail("Examiner rework lost its normalized right/left row mappings.")
		return
	var expected_frames := {
		&"idle_down": 2,
		&"walk_right": 4,
		&"thrust_down": 3,
		&"thrust_strike_down": 2,
		&"thrust_recovery_up": 3,
		&"sweep_wind_up_left": 3,
		&"sweep_strike_right": 3,
		&"charge_wind_up_down": 3,
		&"charge_travel_right": 2,
		&"slam_wind_up_up": 3,
		&"slam_contact_left": 2,
		&"slam_recovery_down": 3,
		&"refutation_active_down": 2,
		&"hurt_up": 3,
		&"withdrawal_left": 5,
		&"axiom_wind_up_up": 2,
		&"axiom_cut_one_down": 2,
		&"axiom_cut_two_right": 2,
		&"axiom_dash_left": 2,
		&"descent_prepare_down": 3,
		&"descent_launch_right": 5,
		&"descent_fall_up": 2,
		&"descent_impact_left": 2,
		&"descent_recovery_down": 4,
	}
	for animation: StringName in expected_frames:
		if not body.sprite_frames.has_animation(animation) or body.sprite_frames.get_frame_count(animation) != expected_frames[animation]:
			_fail("Examiner lost required animation %s." % animation)
			return
		for frame_index in body.sprite_frames.get_frame_count(animation):
			var frame_texture := body.sprite_frames.get_frame_texture(animation, frame_index) as AtlasTexture
			if frame_texture == null or frame_texture.region.size != Vector2(192.0, 160.0):
				_fail("Examiner animation %s lost its padded 192x160 frame grid." % animation)
				return
	var axiom_down_contact := body.sprite_frames.get_frame_texture(&"axiom_cut_one_down", 0) as AtlasTexture
	var axiom_up_contact := body.sprite_frames.get_frame_texture(&"axiom_cut_one_up", 0) as AtlasTexture
	var axiom_second_contact := body.sprite_frames.get_frame_texture(&"axiom_cut_two_down", 0) as AtlasTexture
	var axiom_up_second_contact := body.sprite_frames.get_frame_texture(&"axiom_cut_two_up", 0) as AtlasTexture
	if (
		axiom_down_contact == null
		or axiom_up_contact == null
		or axiom_second_contact == null
		or axiom_up_second_contact == null
		or not axiom_down_contact.atlas.resource_path.ends_with("examiner_axiom_divide_sheet_192x160.png")
		or axiom_down_contact.region.position != Vector2(384.0, 0.0)
		or axiom_up_contact.region.position != Vector2(384.0, 480.0)
		or axiom_second_contact.region.position != Vector2(768.0, 0.0)
		or axiom_up_second_contact.region.position != Vector2(768.0, 480.0)
	):
		_fail("Axiom Divide lost its dedicated cardinal First/Second Measure contact frames.")
		return
	var down_axiom_contacts: Array[AtlasTexture] = [
		axiom_down_contact,
		axiom_second_contact,
	]
	for contact: AtlasTexture in down_axiom_contacts:
		var opaque_bounds := _opaque_bounds(contact)
		var opaque_center_x := float(opaque_bounds.position.x) + float(opaque_bounds.size.x) * 0.5
		var weapon_tip_center_x := _bottom_opaque_center_x(contact, opaque_bounds)
		if (
			opaque_bounds.size.x > 70
			or absf(opaque_center_x - 96.0) > 18.0
			or opaque_bounds.end.y < 132
			or absf(weapon_tip_center_x - 96.0) > 12.0
		):
			_fail(
				"Axiom Divide down contacts stopped thrusting through the body toward screen-bottom center: bounds=%s, center=%.1f, tip=%.1f."
				% [opaque_bounds, opaque_center_x, weapon_tip_center_x]
			)
			return
	var up_axiom_contacts: Array[AtlasTexture] = [
		axiom_up_contact,
		axiom_up_second_contact,
	]
	for contact: AtlasTexture in up_axiom_contacts:
		var opaque_bounds := _opaque_bounds(contact)
		var opaque_center_x := float(opaque_bounds.position.x) + float(opaque_bounds.size.x) * 0.5
		if opaque_bounds.size.x > 60 or absf(opaque_center_x - 96.0) > 14.0:
			_fail("Axiom Divide up contacts became diagonal or drifted away from the body centerline.")
			return
	if examiner.get_node_or_null("CombatPresentation") == null or examiner.get_node_or_null("ActionSfx") == null:
		_fail("Examiner lost its readable telegraph/VFX or action-audio presenter.")
		return
	var action_player := examiner.get_node("ActionSfx/ActionPlayer") as AudioStreamPlayer2D
	var impact_player := examiner.get_node("ActionSfx/ImpactPlayer") as AudioStreamPlayer2D
	if action_player.bus != &"SFX" or impact_player.bus != &"SFX" or body.autoplay != "idle_down":
		_fail("Examiner scene lost its authored SFX routing or editor-safe idle preview.")
		return
	if not ResourceLoader.exists("res://assets/environment/arenas/divine_order/court_of_first_measure/examiner_divine_descent_circle_512.png"):
		_fail("Divine Descent lost its identity-owned arena seal.")
		return
	if not ResourceLoader.exists("res://assets/audio/music/boss/examiner/examiner_ethereal_vocal_loop.mp3"):
		_fail("Examiner lost its single phase-aware music foundation.")
		return
	var director := lab.get_node("Services/ExaminerEncounterDirector") as ExaminerEncounterDirector
	if director == null or director.get_child_count() == 0:
		_fail("Examiner lost its encounter-owned music lifecycle.")
		return
	var music_players := director.find_children("*", "AudioStreamPlayer", true, false)
	if music_players.size() != 1:
		_fail("Examiner encounter must own exactly one complete music foundation, not overlapping songs.")
		return
	director.bind(examiner)
	director.bind(examiner)
	if director.find_children("*", "AudioStreamPlayer", true, false).size() != 1:
		_fail("Repeated Examiner binding duplicated the encounter music player.")
		return
	if examiner.get_node_or_null("SlamHitbox") == null:
		_fail("Ground Judgment lost its authoritative radial hitbox.")
		return

	await create_timer(examiner.definition.spawn_seconds + 0.05).timeout
	examiner._enter(Examiner.State.APPROACH, 0.0)
	examiner._axiom_cooldown = 99.0
	examiner._charge_cooldown = 99.0
	examiner._slam_cooldown = 99.0
	examiner._refutation_cooldown = 99.0
	examiner.global_position = Vector2(320.0, 220.0)
	examiner.target.global_position = Vector2(620.0, 220.0)
	examiner.velocity = Vector2(-80.0, 0.0)
	examiner._process_approach(0.016)
	if examiner.facing_direction.x >= 0.0:
		_fail("Examiner facing followed desired input instead of his actual travel velocity.")
		return
	examiner.velocity = Vector2.ZERO
	var charge_offset := examiner.target.global_position - examiner.global_position
	examiner._begin_judgment_charge(charge_offset)
	if examiner.state != Examiner.State.CHARGE_WIND_UP or examiner.judgment_charge_endpoint().is_equal_approx(examiner.global_position):
		_fail("Judgment Charge did not snapshot a real, telegraphed travel lane.")
		return
	examiner._state_remaining = 0.0
	examiner._tick_state(0.0)
	if examiner.state != Examiner.State.CHARGE_TRAVEL:
		_fail("Judgment Charge warning did not resolve into its physical dash state.")
		return
	examiner.dash_hitbox.deactivate()
	examiner._enter(Examiner.State.APPROACH, 0.0)
	examiner._begin_ground_judgment(charge_offset)
	if examiner.state != Examiner.State.SLAM_WIND_UP:
		_fail("Ground Judgment did not expose its dedicated anticipation state.")
		return
	examiner._state_remaining = 0.0
	examiner._tick_state(0.0)
	if examiner.state != Examiner.State.SLAM_ACTIVE:
		_fail("Ground Judgment did not synchronize damage with the contact pose.")
		return
	examiner.slam_hitbox.deactivate()
	examiner._enter(Examiner.State.APPROACH, 0.0)
	var effects_before_axiom: int = lab.effects.get_child_count()
	examiner._axiom_cooldown = 0.0
	examiner._physics_process(0.016)
	if examiner.state != Examiner.State.AXIOM_WIND_UP:
		_fail("Examiner did not enter Axiom Divide when the signature became ready.")
		return
	if lab.effects.get_child_count() != effects_before_axiom + 3:
		_fail("Axiom Divide did not create three independent readable lane warnings.")
		return
	if examiner.health_component.is_invulnerable:
		_fail("Axiom Divide incorrectly made the Examiner invulnerable.")
		return

	examiner._enter(Examiner.State.APPROACH, 0.0)
	if not director.force_divine_descent() or examiner.state != Examiner.State.PHASE_STANCE or not examiner.health_component.is_invulnerable:
		_fail("Examiner phase threshold did not create a safe cinematic hold.")
		return
	if director.force_divine_descent():
		_fail("Repeated force-phase input restarted an active Divine Descent transition.")
		return
	if not lab.player.is_cinematic_locked():
		_fail("Phase dialogue did not temporarily lock King before the launch.")
		return
	await create_timer(0.50).timeout
	var dialogue := lab.get_node("UI/DialoguePanel") as DialoguePanel
	if not dialogue.visible:
		_fail("Examiner phase transition did not present its short calm dialogue.")
		return
	dialogue.close_dialogue(true)
	await create_timer(0.30).timeout
	if examiner.state != Examiner.State.TRIAL_CHANNEL or lab.player.is_cinematic_locked():
		_fail("Dialogue completion did not release King into the damage trial.")
		return
	examiner.trial._physics_process(examiner.definition.trial_duration_seconds + 0.1)
	examiner._state_remaining = 0.0
	examiner._process_divine_descent(0.0)
	if examiner.state != Examiner.State.DESCENT_LAUNCH:
		_fail("Divine Descent preparation did not enter its launch movement.")
		return
	if Examiner.DESCENT_LAUNCH_SECONDS > 0.18 or examiner._descent_destination.y > examiner.arena_bounds.position.y - 128.0:
		_fail("Divine Descent launch is no longer an immediate complete offscreen exit.")
		return
	examiner._state_remaining = 0.0
	examiner._process_divine_descent(0.0)
	if examiner.state != Examiner.State.DESCENT_ABSENT or examiner.visible:
		_fail("Divine Descent did not leave a real player-controlled cover window.")
		return
	if Examiner.DESCENT_FALL_SECONDS > 0.16:
		_fail("Divine Descent meteor fall became floaty again.")
		return
	# Court protection remains a reusable API; the failed seal grants none.
	if not lab.court_arena.active_wards.is_empty():
		_fail("Failed seal granted a sanctuary.")
		return
	var pylon: Vector2 = CourtOfFirstMeasure.PYLON_POINTS[0]
	lab.court_arena.set_sanctuary(true, pylon)
	if not lab.court_arena.is_position_protected(pylon) or lab.court_arena.is_position_protected(Vector2(365.0, 287.0)):
		_fail("Court protection geometry does not match the four visible pylons.")
		return
	lab.set_player_invincible(false)
	lab.player.health_component.set_current_health(lab.player.health_component.maximum_health)
	lab.player.global_position = pylon
	var protected_health: float = lab.player.health_component.current_health
	if not lab.court_arena.resolve_divine_descent(lab.player, 260.0, examiner) or not is_equal_approx(lab.player.health_component.current_health, protected_health):
		_fail("A correctly occupied pylon zone did not fully protect King.")
		return
	lab.player.global_position = Vector2(365.0, 287.0)
	if lab.court_arena.resolve_divine_descent(lab.player, 260.0, examiner) or lab.player.health_component.current_health >= protected_health:
		_fail("An exposed King did not receive finite Divine Descent damage.")
		return

	await create_timer(0.80).timeout
	lab.queue_free()
	await process_frame
	await process_frame
	print("Examiner physical attacks, facing, Divine Descent phases, exact pylon cover, finite damage, presentation/audio, court, and Axiom lanes passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)


func _opaque_bounds(frame_texture: AtlasTexture) -> Rect2i:
	var atlas_image := frame_texture.atlas.get_image()
	var region := Rect2i(
		Vector2i(frame_texture.region.position),
		Vector2i(frame_texture.region.size)
	)
	var minimum := region.size
	var maximum := Vector2i(-1, -1)
	for local_y in region.size.y:
		for local_x in region.size.x:
			var atlas_position := region.position + Vector2i(local_x, local_y)
			if atlas_image.get_pixelv(atlas_position).a <= 0.0:
				continue
			minimum.x = mini(minimum.x, local_x)
			minimum.y = mini(minimum.y, local_y)
			maximum.x = maxi(maximum.x, local_x)
			maximum.y = maxi(maximum.y, local_y)
	if maximum.x < minimum.x or maximum.y < minimum.y:
		return Rect2i()
	return Rect2i(minimum, maximum - minimum + Vector2i.ONE)


func _bottom_opaque_center_x(frame_texture: AtlasTexture, opaque_bounds: Rect2i) -> float:
	var atlas_image := frame_texture.atlas.get_image()
	var region_position := Vector2i(frame_texture.region.position)
	var first_y := maxi(opaque_bounds.position.y, opaque_bounds.end.y - 4)
	var minimum_x := opaque_bounds.end.x
	var maximum_x := opaque_bounds.position.x - 1
	for local_y in range(first_y, opaque_bounds.end.y):
		for local_x in range(opaque_bounds.position.x, opaque_bounds.end.x):
			if atlas_image.get_pixelv(region_position + Vector2i(local_x, local_y)).a <= 0.0:
				continue
			minimum_x = mini(minimum_x, local_x)
			maximum_x = maxi(maximum_x, local_x)
	if maximum_x < minimum_x:
		return -1.0
	return float(minimum_x + maximum_x) * 0.5
