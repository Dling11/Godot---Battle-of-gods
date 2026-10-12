extends SceneTree

const PlayerScene = preload("res://entities/player/player.tscn")
const SpitterScene = preload("res://entities/enemies/bramble_spitter/bramble_spitter.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var world := Node2D.new()
	var projectiles := Node2D.new()
	var player := PlayerScene.instantiate()
	var spitter := SpitterScene.instantiate() as BrambleSpitter
	world.add_child(projectiles)
	world.add_child(player)
	spitter.target = player
	spitter.set_projectile_parent(projectiles)
	world.add_child(spitter)
	root.add_child(world)
	player.global_position = Vector2(140.0, 200.0)
	spitter.global_position = Vector2(80.0, 200.0)
	player.set_physics_process(false)
	var body := spitter.get_node("Visual/Body") as AnimatedSprite2D
	if body.sprite_frames.get_frame_texture(&"idle_down", 0) == null:
		_fail("Bramble Spitter body animation has no atlas texture.")
		return
	for direction in [&"down", &"left", &"right", &"up"]:
		if body.sprite_frames.get_frame_count(&"attack_%s" % direction) != 8:
			_fail("Bramble Spitter attack must contain eight physical action poses.")
			return
		if body.sprite_frames.get_frame_count(&"walk_%s" % direction) != 4:
			_fail("Bramble Spitter walk must contain four authored locomotion poses.")
			return
		if body.sprite_frames.get_frame_count(&"hurt_%s" % direction) != 1:
			_fail("Bramble Spitter hurt pose is missing.")
			return
		if body.sprite_frames.get_frame_count(&"dead_%s" % direction) != 1:
			_fail("Bramble Spitter collapse pose is missing.")
			return
		var idle_direction_bounds := _opaque_bounds(
			body.sprite_frames.get_frame_texture(&"idle_%s" % direction, 0)
		)
		var attack_entry_bounds := _opaque_bounds(
			body.sprite_frames.get_frame_texture(&"attack_%s" % direction, 0)
		)
		var actor_area_ratio := (
			float(attack_entry_bounds.size.x * attack_entry_bounds.size.y)
			/ float(idle_direction_bounds.size.x * idle_direction_bounds.size.y)
		)
		if actor_area_ratio < 0.85 or actor_area_ratio > 1.15:
			_fail(
				"Bramble Spitter changed actor mass on attack entry (%s %.2f)."
				% [direction, actor_area_ratio]
			)
			return
	var idle_bounds := _opaque_bounds(
		body.sprite_frames.get_frame_texture(&"idle_down", 0)
	)
	var attack_bounds := _opaque_bounds(
		body.sprite_frames.get_frame_texture(&"attack_down", 4)
	)
	if idle_bounds.size.x > 32.0 or idle_bounds.size.y > 30.0:
		_fail("Bramble Spitter locomotion raster remains heavy-enemy sized.")
		return
	if attack_bounds.size.x > 38.0 or attack_bounds.size.y > 29.0:
		_fail("Bramble Spitter attack raster exceeds its authored extension budget.")
		return
	var projectile_frames := load(
		"res://assets/characters/enemies/bramble_spitter/bramble_thorn_seed_sprite_frames.tres"
	) as SpriteFrames
	if (
		projectile_frames == null
		or projectile_frames.get_frame_count(&"flight") != 4
		or projectile_frames.get_frame_count(&"impact") != 3
	):
		_fail("Bramble thorn-seed must end on the third clean explosion frame.")
		return
	var final_impact := projectile_frames.get_frame_texture(&"impact", 2) as AtlasTexture
	if final_impact == null or final_impact.region.position.x != 144.0:
		_fail("Bramble impact still routes to the rejected spent-seed remnant.")
		return

	var telegraph := {"seen": false, "target": Vector2.ZERO, "visible": false}
	spitter.shot_telegraphed.connect(func(global_target: Vector2, _duration: float) -> void:
		telegraph.seen = true
		telegraph.target = global_target
		telegraph.visible = spitter.get_node("TargetMarker").visible
	)
	var firing_feedback := {"seen": false, "flash_visible": false}
	spitter.shot_fired.connect(func(_direction: Vector2) -> void:
		firing_feedback.seen = true
		firing_feedback.flash_visible = spitter.get_node("MuzzleFlash").visible
	)
	var close_retreat_seen := false
	for frame in range(300):
		await physics_frame
		var offset: Vector2 = player.global_position - spitter.global_position
		if spitter.state == BrambleSpitter.State.POSITIONING and offset.length() < spitter.minimum_attack_range and spitter.velocity.length() > 1.0:
			close_retreat_seen = true
			if spitter.facing_direction.dot(offset.normalized()) < 0.8:
				_fail("Bramble Spitter faced away from the player while creating ranged space.")
				return
		if telegraph.seen:
			break
	if not telegraph.seen:
		_fail("Bramble Spitter did not telegraph its first shot (state=%s, distance=%.2f)." % [spitter.State.keys()[spitter.state], spitter.global_position.distance_to(player.global_position)])
		return
	if not close_retreat_seen:
		_fail("Bramble Spitter close-range retreat regression was not exercised.")
		return
	if spitter.global_position.distance_to(Vector2(80.0, 200.0)) > 90.0:
		_fail("Bramble Spitter exceeded its bounded retreat burst before committing.")
		return
	if telegraph.target.distance_to(player.global_position) > 0.1:
		_fail("Bramble Spitter did not snapshot the player's target position.")
		return
	if not telegraph.visible:
		_fail("Bramble Spitter red ground target marker was not visible.")
		return

	# Moving after the tell must not redirect the already committed shot.
	player.global_position.y -= 60.0
	for frame in range(85):
		await physics_frame
	var player_health := player.get_node("HealthComponent") as HealthComponent
	if player_health.current_health < player_health.maximum_health:
		_fail("A perpendicular dodge did not evade the committed seed shot.")
		return
	if spitter.state == BrambleSpitter.State.WIND_UP:
		_fail("Bramble Spitter never left its wind-up state.")
		return
	if not firing_feedback.seen or not firing_feedback.flash_visible:
		_fail("Bramble Spitter firing event did not show its muzzle flash.")
		return

	spitter.set_physics_process(false)
	var impact_seen := {"value": false}
	projectiles.child_entered_tree.connect(func(child: Node) -> void:
		if child.name == "BrambleSeedImpact":
			impact_seen.value = true
	)
	var projectile := spitter.projectile_scene.instantiate() as HostileProjectile
	projectiles.add_child(projectile)
	projectile.global_position = player.global_position - Vector2(45.0, 0.0)
	projectile.launch(Vector2.RIGHT, spitter.definition.attack_damage, spitter)
	for frame in range(35):
		await physics_frame
	if not is_equal_approx(
		player_health.current_health,
		player_health.maximum_health - spitter.definition.attack_damage
	):
		_fail("Bramble seed projectile did not apply its balanced definition damage.")
		return
	if not impact_seen.value:
		_fail("Bramble seed did not create its impact feedback.")
		return

	var countered_projectile := spitter.projectile_scene.instantiate() as CounterableHostileProjectile
	projectiles.add_child(countered_projectile)
	countered_projectile.global_position = Vector2(300.0, 300.0)
	countered_projectile.launch(Vector2.RIGHT, 3.0, spitter)
	var projectile_hurtbox := countered_projectile.get_node("Hurtbox") as HurtboxComponent
	if projectile_hurtbox.selectable_as_combat_target:
		_fail("Counterable projectile leaked into assisted enemy targeting.")
		return
	var counter_seen := {"value": false}
	countered_projectile.countered.connect(func() -> void: counter_seen.value = true)
	projectile_hurtbox.receive_hit(DamageInfo.new(1.0, player, Vector2.RIGHT))
	await process_frame
	if not counter_seen.value or is_instance_valid(countered_projectile):
		_fail("Player damage did not destroy the counterable thorn-seed cleanly.")
		return

	# A fired seed must remain valid after Skill 4 or another attack frees its
	# shooter. The impact becomes source-less instead of passing a freed Object
	# into DamageInfo's typed constructor.
	var freed_source := Node2D.new()
	root.add_child(freed_source)
	var orphaned_projectile := spitter.projectile_scene.instantiate() as HostileProjectile
	projectiles.add_child(orphaned_projectile)
	orphaned_projectile.launch(Vector2.RIGHT, 3.0, freed_source)
	freed_source.queue_free()
	await process_frame
	var health_before_orphaned_hit := player_health.current_health
	orphaned_projectile._on_area_entered(player.get_node("Hurtbox") as HurtboxComponent)
	if not is_equal_approx(player_health.current_health, health_before_orphaned_hit - 3.0):
		_fail("A projectile whose shooter was freed did not resolve safely.")
		return

	# Killing the shooter during wind-up must cancel the state authority before
	# its delayed presentation/timers can create a projectile.
	var dying_target := CharacterBody2D.new()
	dying_target.global_position = Vector2(600.0, 400.0)
	world.add_child(dying_target)
	var dying_spitter := SpitterScene.instantiate() as BrambleSpitter
	dying_spitter.definition = dying_spitter.definition.duplicate(true) as EnemyDefinition
	dying_spitter.definition.spawn_seconds = 0.05
	dying_spitter.target = dying_target
	dying_spitter.set_projectile_parent(projectiles)
	dying_spitter.global_position = Vector2(470.0, 400.0)
	world.add_child(dying_spitter)
	for frame in range(90):
		await physics_frame
		if dying_spitter.state == BrambleSpitter.State.WIND_UP:
			break
	if dying_spitter.state != BrambleSpitter.State.WIND_UP:
		_fail("Stability audit could not place the Spitter in wind-up.")
		return
	var projectile_count_before_death := _count_projectiles(projectiles)
	(dying_spitter.get_node("HealthComponent") as HealthComponent).apply_damage(
		DamageInfo.new(999.0, player, Vector2.RIGHT)
	)
	await create_timer(0.9).timeout
	if _count_projectiles(projectiles) != projectile_count_before_death:
		_fail("A dead Spitter completed a cancelled wind-up and spawned a seed.")
		return

	# Losing the player/target and unloading a scene with an active projectile
	# must both cleanly stop ownership without a stale-reference callback.
	var targetless_spitter := SpitterScene.instantiate() as BrambleSpitter
	var temporary_target := CharacterBody2D.new()
	world.add_child(temporary_target)
	targetless_spitter.target = temporary_target
	world.add_child(targetless_spitter)
	temporary_target.queue_free()
	await process_frame
	await physics_frame
	if targetless_spitter.velocity.length() > 0.1:
		_fail("Bramble Spitter kept moving after its target was freed.")
		return
	var transition_world := Node2D.new()
	root.add_child(transition_world)
	var transition_projectile := spitter.projectile_scene.instantiate() as HostileProjectile
	transition_world.add_child(transition_projectile)
	transition_projectile.launch(Vector2.RIGHT, 3.0, null)
	transition_world.queue_free()
	await process_frame
	await process_frame
	if is_instance_valid(transition_projectile):
		_fail("Scene unload left an active Bramble projectile alive.")
		return
	print("Bramble Spitter smoke test passed.")
	quit(0)


func _count_projectiles(parent: Node) -> int:
	var count := 0
	for child in parent.get_children():
		if child is HostileProjectile:
			count += 1
	return count


func _fail(message: String) -> void:
	push_error(message)
	quit(1)


func _opaque_bounds(texture: Texture2D) -> Rect2i:
	var image := texture.get_image()
	var minimum := Vector2i(image.get_width(), image.get_height())
	var maximum := Vector2i(-1, -1)
	for y in image.get_height():
		for x in image.get_width():
			if image.get_pixel(x, y).a < 0.5:
				continue
			minimum.x = mini(minimum.x, x)
			minimum.y = mini(minimum.y, y)
			maximum.x = maxi(maximum.x, x)
			maximum.y = maxi(maximum.y, y)
	if maximum.x < 0:
		return Rect2i()
	return Rect2i(minimum, maximum - minimum + Vector2i.ONE)
