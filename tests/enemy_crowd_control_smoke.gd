extends SceneTree

const PlayerScene = preload("res://entities/player/player.tscn")
const ThrallScene = preload("res://entities/enemies/forsaken_thrall/forsaken_thrall.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	root.get_node("SaveService").configure_storage_path_for_testing("user://enemy_crowd_control_smoke.json")
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	var player := PlayerScene.instantiate() as Player
	var thrall := ThrallScene.instantiate() as ForsakenThrall
	thrall.target = player
	root.add_child(player)
	root.add_child(thrall)
	player.global_position = Vector2(120.0, 180.0)
	thrall.global_position = Vector2(174.0, 180.0)
	player._set_facing_direction(Vector2.RIGHT)
	await process_frame
	thrall._finish_spawn()
	thrall._enter_state(ForsakenThrall.State.WIND_UP, 0.7)

	var f9_event := InputEventAction.new()
	f9_event.action = "debug_max_progression"
	f9_event.pressed = true
	player._unhandled_input(f9_event)
	await process_frame
	var ability := player.ability_2_component
	if not ability.request_cast(Vector2.RIGHT, player.attack_component.weapon.damage):
		_fail("Rapid Consecutive Thrust could not begin against a Light enemy.")
		return

	for frame in range(35):
		await physics_frame
		if thrall.state == ForsakenThrall.State.STAGGER:
			break
	if thrall.state != ForsakenThrall.State.STAGGER or not thrall.stagger_component.is_staggered():
		_fail("Rapid Consecutive Thrust did not stagger the Light Forsaken Thrall.")
		return
	if thrall.attack_hitbox.monitoring:
		_fail("A staggered Light enemy retained an active attack hitbox.")
		return

	for frame in range(100):
		await physics_frame
	if ability.is_casting() or thrall.stagger_component.is_staggered():
		_fail("Rapid stagger did not expire after the completed technique.")
		return

	var boss_host := Node.new()
	var boss_health := HealthComponent.new()
	boss_health.maximum_health = 999.0
	var boss_knockback := KnockbackComponent.new()
	boss_knockback.health_component = boss_health
	var boss_stagger := StaggerComponent.new()
	boss_stagger.health_component = boss_health
	boss_host.add_child(boss_health)
	boss_host.add_child(boss_knockback)
	boss_host.add_child(boss_stagger)
	root.add_child(boss_host)
	await process_frame
	var boss_definition := EnemyDefinition.new()
	boss_definition.crowd_control_tier = EnemyDefinition.CrowdControlTier.BOSS
	boss_knockback.configure(boss_definition)
	boss_stagger.configure(boss_definition)
	boss_health.apply_damage(DamageInfo.new(1.0, player, Vector2.RIGHT, 150.0, 0.42))
	await physics_frame
	if not boss_knockback.velocity.is_zero_approx() or boss_stagger.is_staggered():
		_fail("Boss control tier accepted knockback or rapid-stagger damage.")
		return
	if not is_equal_approx(boss_definition.knockback_multiplier(), 0.0) or not is_equal_approx(boss_definition.stagger_multiplier(), 0.0):
		_fail("Boss control tier does not resolve complete crowd-control resistance.")
		return
	print("Enemy Light stagger and Boss crowd-control resistance smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
