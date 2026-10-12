extends SceneTree

const HuskScene = preload("res://entities/enemies/rootbound_husk/rootbound_husk.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var actors := Node2D.new()
	root.add_child(actors)
	var target := CharacterBody2D.new()
	actors.add_child(target)
	target.global_position = Vector2(0.0, 120.0)
	var husk := HuskScene.instantiate()
	husk.target = target
	actors.add_child(husk)
	var attacks: Array[Array] = []
	var attack_durations: Array[float] = []
	var eruptions: Array[Array] = []
	var attack_starts: Array[bool] = []
	husk.root_attack_telegraphed.connect(func(directions: Array[Vector2], duration: float) -> void:
		attacks.append(directions.duplicate())
		attack_durations.append(duration)
		if attacks.size() == 1:
			target.global_position = Vector2(-120.0, 0.0)
	)
	husk.root_attack_erupted.connect(func(directions: Array[Vector2]) -> void:
		eruptions.append(directions.duplicate())
	)
	husk.root_attack_started.connect(func() -> void:
		attack_starts.append(true)
	)
	await create_timer(4.0).timeout
	if (
		husk.definition.display_name != "Rootbound Husk"
		or husk.definition.maximum_health != 280.0
		or not is_equal_approx(husk.definition.attack_damage, 18.0)
	):
		_fail("Rootbound Husk must use the compact first-mini-boss tuning.")
		return
	if husk.attack_profile == null:
		_fail("Rootbound Husk must use its dedicated attack profile.")
		return
	var root_creak_sfx := husk.get_node("ActionSfx/RootCreak") as AudioStreamPlayer2D
	var root_eruption_sfx := husk.get_node("ActionSfx/RootEruption") as AudioStreamPlayer2D
	if (
		root_creak_sfx == null
		or root_creak_sfx.stream == null
		or root_creak_sfx.bus != &"SFX"
		or root_eruption_sfx == null
		or root_eruption_sfx.stream == null
		or root_eruption_sfx.bus != &"SFX"
		or root_creak_sfx.stream == root_eruption_sfx.stream
	):
		_fail("Rootbound Husk attacks must separate woody telegraph and root-eruption SFX cues.")
		return
	var ground_rumble_sfx := husk.get_node("ActionSfx/GroundRumble") as AudioStreamPlayer2D
	if ground_rumble_sfx == null or ground_rumble_sfx.stream == null or ground_rumble_sfx.pitch_scale >= 0.8:
		_fail("Rootbound Husk attacks must layer a low ground-rumble cue.")
		return
	if husk.definition.crowd_control_tier != EnemyDefinition.CrowdControlTier.BOSS:
		_fail("Rootbound Husk must use Boss crowd-control resistance.")
		return
	if attacks.size() < 2 or attacks[0].size() != 1 or attacks[1].size() != 3:
		_fail("Rootbound Husk must open with a spear before its three-lane root fan.")
		return
	if attack_durations[0] >= attack_durations[1]:
		_fail("Rootbound Husk spear must commit faster than its wider root fan.")
		return
	if eruptions.size() < 3 or eruptions[0].size() != 1 or eruptions[1].size() != 1 or eruptions[2].size() != 2:
		_fail("Rootbound Husk root fan must erupt center first, then its two side lanes.")
		return
	if attack_starts.size() != 2:
		_fail("Rootbound Husk must emit one audio start per attack, not per eruption wave.")
		return
	var center_pivot := husk.get_node("CenterPivot") as Node2D
	if absf(angle_difference(center_pivot.rotation, (attacks[1][0] as Vector2).angle())) > 0.01:
		_fail("Rootbound Husk rotated a committed root lane after its telegraph.")
		return
	var hitbox := husk.get_node("CenterPivot/CenterHitbox") as MeleeHitbox
	var shape := hitbox.get_node("CollisionShape2D").shape as RectangleShape2D
	if shape.size != Vector2(112.0, 20.0):
		_fail("Rootbound Husk Root Spear lane changed from its authored 112x20 size.")
		return
	if husk.definition.attack_range > 120.0:
		_fail("Rootbound Husk begins rooted attacks beyond its authored spear reach.")
		return
	var burst_shape := husk.get_node("BurstHitbox/CollisionShape2D").shape as CircleShape2D
	if burst_shape == null or burst_shape.radius < husk.attack_profile.burst_trigger_range:
		_fail("Rootbound Husk point-blank burst does not cover its trigger range.")
		return
	var visual_husk := HuskScene.instantiate() as RootboundHusk
	actors.add_child(visual_husk)
	await process_frame
	var visual := visual_husk.get_node("Visual")
	var body := visual_husk.get_node("Visual/Body") as AnimatedSprite2D
	var health_bar := visual_husk.get_node("EnemyHealthBar") as EnemyHealthBar
	if body == null or body.sprite_frames == null:
		_fail("Rootbound Husk must use an AnimatedSprite2D body with native SpriteFrames.")
		return
	if health_bar.position.y > -32.0:
		_fail("Rootbound Husk health bar must sit above its antlered silhouette.")
		return
	var expected_action_counts := {
		&"idle": 1,
		&"walk": 4,
		&"root_attack_wind_up": 4,
		&"root_attack_active": 2,
		&"root_attack_recovery": 2,
		&"hurt": 2,
		&"dead": 4,
	}
	if body.sprite_frames.get_animation_names().size() != expected_action_counts.size() * 4:
		_fail("Rootbound Husk SpriteFrames contains stale or missing animation groups.")
		return
	for action_name in expected_action_counts:
		for direction_name in [&"down", &"left", &"right", &"up"]:
			var animation_name := StringName("%s_%s" % [action_name, direction_name])
			if not body.sprite_frames.has_animation(animation_name):
				_fail("Rootbound Husk is missing native animation %s." % animation_name)
				return
			if body.sprite_frames.get_frame_count(animation_name) != expected_action_counts[action_name]:
				_fail("Rootbound Husk animation %s has stale frame assignments." % animation_name)
				return
	if body.sprite_frames.get_frame_count(&"walk_left") != 4 or body.sprite_frames.get_frame_count(&"walk_right") != 4:
		_fail("Rootbound Husk side walks must keep four authored contact/passing frames.")
		return
	var left_walk_frame := body.sprite_frames.get_frame_texture(&"walk_left", 0) as AtlasTexture
	if left_walk_frame == null or left_walk_frame.region.size != Vector2(72.0, 64.0):
		_fail("Rootbound Husk walk frames must use the non-clipping 72x64 cell contract.")
		return
	var left_walk_frame_b := body.sprite_frames.get_frame_texture(&"walk_left", 1)
	if _frame_image(left_walk_frame).get_data() == _frame_image(left_walk_frame_b as AtlasTexture).get_data():
		_fail("Rootbound Husk left walk still duplicates frames and reads as gliding.")
		return
	var left_opposite_contact := body.sprite_frames.get_frame_texture(&"walk_left", 2) as AtlasTexture
	if _frame_image(left_walk_frame).get_data() == _frame_image(left_opposite_contact).get_data():
		_fail("Rootbound Husk side contact frames do not exchange the gait pose.")
		return
	for frame_index in 4:
		var left_frame := body.sprite_frames.get_frame_texture(&"walk_left", frame_index) as AtlasTexture
		var right_frame := body.sprite_frames.get_frame_texture(&"walk_right", frame_index) as AtlasTexture
		if (
			left_frame == null
			or right_frame == null
			or left_frame.atlas != right_frame.atlas
			or left_frame.region.position != Vector2(frame_index * 72.0, 64.0)
			or right_frame.region.position != Vector2(frame_index * 72.0, 128.0)
		):
			_fail("Rootbound Husk side walks must use the canonical mirrored atlas rows.")
			return
		if _frame_image(left_frame).get_used_rect().size.y != 56:
			_fail("Rootbound Husk side walk frame %d changes the fixed 56-pixel body height." % frame_index)
			return
		var up_frame := body.sprite_frames.get_frame_texture(&"walk_up", frame_index) as AtlasTexture
		if up_frame == null or _top_opaque_pixel_count(_frame_image(up_frame)) > 4:
			_fail("Rootbound Husk walk-up frame %d still has a flat clipped crown." % frame_index)
			return
	var active_down_frame := body.sprite_frames.get_frame_texture(&"root_attack_active_down", 0) as AtlasTexture
	if (
		active_down_frame == null
		or active_down_frame.atlas.resource_path
		!= "res://assets/characters/enemies/rootbound_husk/rootbound_husk_root_attack_body_sheet_96x64.png"
		or active_down_frame.region != Rect2(288.0, 0.0, 96.0, 64.0)
		or _frame_image(active_down_frame).get_used_rect().size.y != 56
	):
		_fail("Rootbound Husk root_attack_active_down does not use the approved root-attack body frame.")
		return
	for frame_index in 2:
		var down_active_frame := body.sprite_frames.get_frame_texture(
			&"root_attack_active_down",
			frame_index
		) as AtlasTexture
		if down_active_frame == null or _alpha_symmetry_ratio(_frame_image(down_active_frame)) < 0.65:
			_fail("Rootbound Husk root_attack_active_down frame %d turns into a side-facing pose." % frame_index)
			return
	for direction_name in [&"down", &"left", &"right", &"up"]:
		var hurt_name := StringName("hurt_%s" % direction_name)
		for frame_index in body.sprite_frames.get_frame_count(hurt_name):
			var hurt_frame := body.sprite_frames.get_frame_texture(hurt_name, frame_index) as AtlasTexture
			if (
				hurt_frame == null
				or hurt_frame.atlas.resource_path
				!= "res://assets/characters/enemies/rootbound_husk/rootbound_husk_root_attack_body_sheet_96x64.png"
				or hurt_frame.region.size != Vector2(96.0, 64.0)
			):
				_fail("Rootbound Husk %s must use the approved root-attack body sheet." % hurt_name)
				return
		var dead_name := StringName("dead_%s" % direction_name)
		if body.sprite_frames.get_animation_loop(dead_name):
			_fail("Rootbound Husk %s must stop on its collapsed final frame." % dead_name)
			return
		for frame_index in body.sprite_frames.get_frame_count(dead_name):
			var dead_frame := body.sprite_frames.get_frame_texture(dead_name, frame_index) as AtlasTexture
			if (
				dead_frame == null
				or dead_frame.atlas.resource_path
				!= "res://assets/characters/enemies/rootbound_husk/rootbound_husk_reaction_sheet_64x64.png"
				or dead_frame.region.size != Vector2(64.0, 64.0)
			):
				_fail("Rootbound Husk %s must use the authored four-frame death sheet." % dead_name)
				return
	for action_name in [&"walk", &"root_attack_wind_up", &"root_attack_active", &"root_attack_recovery", &"hurt", &"dead"]:
		var left_animation := StringName("%s_left" % action_name)
		var right_animation := StringName("%s_right" % action_name)
		if body.sprite_frames.get_frame_count(left_animation) != body.sprite_frames.get_frame_count(right_animation):
			_fail("Rootbound Husk side animation counts differ for %s." % action_name)
			return
		for frame_index in body.sprite_frames.get_frame_count(left_animation):
			var left_texture := body.sprite_frames.get_frame_texture(left_animation, frame_index) as AtlasTexture
			var right_texture := body.sprite_frames.get_frame_texture(right_animation, frame_index) as AtlasTexture
			if (
				left_texture == null
				or right_texture == null
				or left_texture.atlas != right_texture.atlas
				or left_texture.region.position.x != right_texture.region.position.x
				or left_texture.region.position.y + 64.0 != right_texture.region.position.y
			):
				_fail(
					"Rootbound Husk %s side frame %d does not use the canonical mirrored atlas rows."
					% [action_name, frame_index]
				)
				return
	visual.play_state(RootboundHusk.State.CHASE, 0.0)
	visual.set_moving(false)
	if body.animation != &"idle_down":
		_fail("Rootbound Husk does not hold its planted walk frame while stationary.")
		return
	visual.play_state(RootboundHusk.State.SPEAR_WIND_UP, 0.82)
	if body.scale != Vector2.ONE or body.position != Vector2(0.0, -32.0):
		_fail("Rootbound Husk wind-up changes body scale or loses its attack foot baseline.")
		return
	visual.play_state(RootboundHusk.State.DEAD, 0.6)
	if body.animation != &"dead_down" or body.speed_scale < 6.0:
		_fail("Rootbound Husk death does not fit all four authored frames into its cleanup window.")
		return
	var test_directions: Array[Vector2] = [Vector2.RIGHT]
	visual.show_root_attack_telegraph(test_directions, 0.1)
	var root_vfx := visual_husk.get_node("Visual/RootSpearVfx") as AnimatedSprite2D
	if root_vfx.position != Vector2(64.0, -4.0) or not is_zero_approx(root_vfx.rotation):
		_fail("Rootbound Husk root VFX must erupt from the ground plane ahead of the boss.")
		return
	if root_vfx.sprite_frames.get_frame_count(&"telegraph") != 3 or root_vfx.sprite_frames.get_frame_count(&"erupt") != 3:
		_fail("Rootbound Husk ground attack must keep its six-beat crack-to-collapse flow.")
		return
	if root_vfx.z_index >= body.z_index:
		_fail("Rootbound Husk ground telegraph must render beneath the boss body.")
		return
	var triad_directions: Array[Vector2] = [
		Vector2.RIGHT,
		Vector2.RIGHT.rotated(-0.34),
		Vector2.RIGHT.rotated(0.34),
	]
	visual.show_root_attack_telegraph(triad_directions, 0.4)
	var center_direction: Array[Vector2] = [triad_directions[0]]
	visual.play_root_attack(center_direction)
	var left_vfx := visual_husk.get_node("Visual/LeftRootSpearVfx") as AnimatedSprite2D
	var right_vfx := visual_husk.get_node("Visual/RightRootSpearVfx") as AnimatedSprite2D
	if left_vfx.animation != &"telegraph" or right_vfx.animation != &"telegraph" or not left_vfx.visible or not right_vfx.visible:
		_fail("Rootbound Husk side warnings disappear before the staged fan eruption.")
		return
	var side_directions: Array[Vector2] = [triad_directions[1], triad_directions[2]]
	visual.play_root_attack(side_directions)
	if left_vfx.animation != &"erupt" or right_vfx.animation != &"erupt":
		_fail("Rootbound Husk staged side lanes do not enter their eruption animation.")
		return
	var close_target := CharacterBody2D.new()
	close_target.global_position = Vector2(0.0, 18.0)
	actors.add_child(close_target)
	var close_husk := HuskScene.instantiate() as RootboundHusk
	close_husk.target = close_target
	var burst_telegraphs: Array[bool] = []
	var burst_eruptions: Array[bool] = []
	close_husk.root_burst_telegraphed.connect(func(_duration: float) -> void: burst_telegraphs.append(true))
	close_husk.root_burst_erupted.connect(func() -> void: burst_eruptions.append(true))
	actors.add_child(close_husk)
	await create_timer(1.5).timeout
	if burst_telegraphs.is_empty() or burst_eruptions.is_empty():
		_fail("Rootbound Husk does not answer point-blank body overlap with its root burst.")
		return
	var phase_target := CharacterBody2D.new()
	phase_target.global_position = Vector2(0.0, 120.0)
	actors.add_child(phase_target)
	var phase_husk := HuskScene.instantiate() as RootboundHusk
	phase_husk.target = phase_target
	var phase_attacks: Array[Array] = []
	var phase_durations: Array[float] = []
	phase_husk.root_attack_telegraphed.connect(func(directions: Array[Vector2], duration: float) -> void:
		phase_attacks.append(directions.duplicate())
		phase_durations.append(duration)
	)
	actors.add_child(phase_husk)
	phase_husk.health_component.current_health = phase_husk.health_component.maximum_health * 0.4
	await create_timer(1.1).timeout
	if phase_attacks.is_empty() or phase_attacks[0].size() != 3:
		_fail("Rootbound Husk second phase must open with the wider root fan cadence.")
		return
	if phase_durations[0] >= phase_husk.attack_profile.triad_wind_up_seconds:
		_fail("Rootbound Husk second phase does not apply its authored timing scale.")
		return
	print("Rootbound Husk mini-boss behavior smoke test passed.")
	quit(0)


func _frame_image(texture: AtlasTexture) -> Image:
	return texture.atlas.get_image().get_region(Rect2i(texture.region))


func _top_opaque_pixel_count(image: Image) -> int:
	var used_rect := image.get_used_rect()
	var count := 0
	for x in range(used_rect.position.x, used_rect.end.x):
		if image.get_pixel(x, used_rect.position.y).a >= 0.5:
			count += 1
	return count


func _alpha_symmetry_ratio(image: Image) -> float:
	var intersection := 0
	var union := 0
	for y in image.get_height():
		for x in image.get_width():
			var opaque := image.get_pixel(x, y).a >= 0.5
			var mirrored_opaque := image.get_pixel(image.get_width() - 1 - x, y).a >= 0.5
			if opaque or mirrored_opaque:
				union += 1
			if opaque and mirrored_opaque:
				intersection += 1
	return float(intersection) / float(maxi(union, 1))


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
