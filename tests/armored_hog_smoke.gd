extends SceneTree

const HogScene = preload("res://entities/enemies/armored_hog/armored_hog.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	var target := CharacterBody2D.new()
	target.position = Vector2(180.0, 0.0)
	root.add_child(target)
	var hog := HogScene.instantiate() as ArmoredHog
	hog.target = target
	root.add_child(hog)
	await process_frame

	if hog.definition == null or hog.definition.crowd_control_tier != EnemyDefinition.CrowdControlTier.ELITE:
		_fail("The Armored Hog did not load its Elite combat definition.")
		return
	if hog.definition.front_guard_half_angle_degrees != 55.0 or hog.definition.braced_front_damage_multiplier != 0.35:
		_fail("The Armored Hog lost its authored frontal brace contract.")
		return
	var body := hog.get_node("VisualPivot/Body") as AnimatedSprite2D
	var expected_counts := {
		"idle": 1,
		"walk": 4,
		"brace": 3,
		"charge": 2,
		"crash": 1,
		"hurt": 2,
		"dazed": 1,
		"dead": 3,
	}
	for direction in ["down", "left", "right", "up"]:
		for action: String in expected_counts:
			var animation := StringName(action + "_" + direction)
			if (
				not body.sprite_frames.has_animation(animation)
				or body.sprite_frames.get_frame_count(animation) != expected_counts[action]
			):
				_fail("The Armored Hog animation %s is missing authored frames." % animation)
				return
	if body.sprite_frames.get_animation_names().size() != 32:
		_fail("The Armored Hog does not expose its complete 32-animation runtime set.")
		return

	var hurtbox := hog.get_node("Hurtbox") as HurtboxComponent
	var source := Node2D.new()
	root.add_child(source)
	hog.state = ArmoredHog.State.BRACE
	hog.facing_direction = Vector2.RIGHT
	source.position = Vector2.RIGHT * 100.0
	var before := hog.health_component.current_health
	hurtbox.receive_hit(DamageInfo.new(40.0, source, Vector2.RIGHT))
	if not is_equal_approx(before - hog.health_component.current_health, 14.0):
		_fail("The living-bark forehead did not reduce a frontal hit to 35 percent.")
		return
	if hog.state != ArmoredHog.State.BRACE:
		_fail("A normal hit canceled the Hog's committed charge warning.")
		return
	hog.health_component.current_health = before
	source.position = Vector2.LEFT * 100.0
	hurtbox.receive_hit(DamageInfo.new(40.0, source, Vector2.RIGHT))
	if not is_equal_approx(before - hog.health_component.current_health, 40.0):
		_fail("The Armored Hog's rear weak side incorrectly reduced damage.")
		return

	var sfx := hog.get_node("ActionSfx")
	for player_name in ["Hoof", "Brace", "Snort", "Crash"]:
		var audio := sfx.get_node(player_name) as AudioStreamPlayer2D
		if audio == null or audio.stream == null:
			_fail("The Armored Hog is missing its %s sound." % player_name)
			return

	hog.state = ArmoredHog.State.CHASE
	hog.global_position = Vector2.ZERO
	target.global_position = Vector2(180.0, 0.0)
	await physics_frame
	await physics_frame
	if hog.state != ArmoredHog.State.BRACE or hog.facing_direction.dot(Vector2.RIGHT) < 0.99:
		_fail(
			"The Armored Hog did not snapshot a readable charge lane (state=%s facing=%s clear=%s)."
			% [hog.state, hog.facing_direction, hog._has_clear_charge_line()]
		)
		return
	target.global_position = Vector2(180.0, 120.0)
	await create_timer(hog.definition.wind_up_seconds + 0.05).timeout
	if hog.state != ArmoredHog.State.CHARGE or hog.facing_direction.dot(Vector2.RIGHT) < 0.99:
		_fail("The Armored Hog retargeted after committing its charge warning.")
		return
	var charge_deadline := Time.get_ticks_msec() + 1500
	while hog.state == ArmoredHog.State.CHARGE and Time.get_ticks_msec() < charge_deadline:
		await physics_frame
	if hog.state != ArmoredHog.State.DAZED:
		_fail("The Armored Hog charge did not resolve into its punishable daze.")
		return

	print("Armored Hog art, guard, charge, reaction, and audio smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
