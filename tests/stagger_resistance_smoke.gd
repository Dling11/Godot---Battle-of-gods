extends SceneTree

const PlayerScene = preload("res://entities/player/player.tscn")

var _damage_source: Node


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_damage_source = Node.new()
	root.add_child(_damage_source)
	_validate_profile_data()
	await _validate_enemy_stagger_chains()
	await _validate_player_charge_interruption()
	print("STAGGER_RESISTANCE_SMOKE_PASSED")
	quit(0)


func _validate_profile_data() -> void:
	var hog := load("res://data/enemies/armored_hog.tres") as ArmoredHogDefinition
	var bear := load("res://data/enemies/crag_bear.tres") as CragBearDefinition
	assert(hog.stagger_interrupt_limit == 3)
	assert(is_equal_approx(hog.stagger_resistance_seconds, 0.8))
	assert(hog.charge_knockback_strength == 175.0)
	assert(is_equal_approx(hog.charge_stagger_seconds, 0.24))
	assert(bear.crowd_control_tier == EnemyDefinition.CrowdControlTier.HEAVY)
	assert(bear.stagger_interrupt_limit == 4)
	assert(is_equal_approx(bear.stagger_resistance_seconds, 1.05))
	assert(is_equal_approx(bear.stagger_multiplier(), 0.3))
	assert(is_equal_approx(bear.knockback_multiplier(), 0.2))


func _validate_enemy_stagger_chains() -> void:
	var light_definition := EnemyDefinition.new()
	var hog_definition := load("res://data/enemies/armored_hog.tres") as EnemyDefinition
	var bear_definition := load("res://data/enemies/crag_bear.tres") as EnemyDefinition
	var boss_definition := EnemyDefinition.new()
	boss_definition.crowd_control_tier = EnemyDefinition.CrowdControlTier.BOSS

	var light := await _make_stagger_fixture(light_definition)
	for hit in range(7):
		light.health.apply_damage(DamageInfo.new(1.0, _damage_source, Vector2.RIGHT, 0.0, 0.11))
	assert(light.stagger.is_staggered())
	assert(not light.stagger.is_resisting_stagger())

	var hog := await _make_stagger_fixture(hog_definition)
	for hit in range(2):
		hog.health.apply_damage(DamageInfo.new(1.0, _damage_source, Vector2.RIGHT, 0.0, 0.11))
	assert(hog.stagger.is_staggered())
	assert(hog.stagger.get_chain_interrupt_count() == 2)
	var hog_health_before_breakout: float = hog.health.current_health
	hog.health.apply_damage(DamageInfo.new(1.0, _damage_source, Vector2.RIGHT, 0.0, 0.11))
	assert(hog.health.current_health < hog_health_before_breakout)
	assert(not hog.stagger.is_staggered())
	assert(hog.stagger.is_resisting_stagger())
	var hog_health_during_resistance: float = hog.health.current_health
	hog.health.apply_damage(DamageInfo.new(1.0, _damage_source, Vector2.RIGHT, 0.0, 0.78))
	assert(hog.health.current_health < hog_health_during_resistance)
	assert(not hog.stagger.is_staggered())
	await create_timer(0.85).timeout
	assert(not hog.stagger.is_resisting_stagger())
	hog.health.apply_damage(DamageInfo.new(1.0, _damage_source, Vector2.RIGHT, 0.0, 0.78))
	assert(hog.stagger.is_staggered())
	assert(is_equal_approx(hog.stagger.remaining_seconds, 0.78 * 0.45))

	var bear := await _make_stagger_fixture(bear_definition)
	bear.health.apply_damage(DamageInfo.new(1.0, _damage_source, Vector2.RIGHT, 0.0, 0.42))
	var skill_1_duration: float = bear.stagger.remaining_seconds
	bear.stagger.remaining_seconds = 0.0
	bear.health.apply_damage(DamageInfo.new(1.0, _damage_source, Vector2.RIGHT, 0.0, 0.78))
	var skill_3_duration: float = bear.stagger.remaining_seconds
	assert(skill_3_duration > skill_1_duration)
	assert(is_equal_approx(skill_3_duration, 0.78 * 0.3))
	for hit in range(2):
		bear.health.apply_damage(DamageInfo.new(1.0, _damage_source, Vector2.RIGHT, 0.0, 0.11))
	assert(bear.stagger.is_resisting_stagger())
	assert(not bear.stagger.is_staggered())

	var boss := await _make_stagger_fixture(boss_definition)
	boss.health.apply_damage(DamageInfo.new(1.0, _damage_source, Vector2.RIGHT, 0.0, 0.78))
	assert(not boss.stagger.is_staggered())
	boss.health.apply_damage(DamageInfo.new(1.0, _damage_source, Vector2.RIGHT, 0.0, 0.0, false, .8))
	assert(not boss.stagger.is_stunned())
	hog.stagger.clear()
	hog.health.apply_damage(DamageInfo.new(1.0, _damage_source, Vector2.RIGHT, 0.0, 0.0, false, .8))
	assert(hog.stagger.is_stunned())
	assert(is_equal_approx(hog.stagger.stun_remaining_seconds, .8 * .45))
	for hit in 2:
		hog.health.apply_damage(DamageInfo.new(1.0, _damage_source, Vector2.RIGHT, 0.0, .11))
	assert(hog.stagger.is_resisting_stagger() and not hog.stagger.is_stunned())

	for fixture in [light, hog, bear, boss]:
		fixture.host.queue_free()
	await process_frame


func _validate_player_charge_interruption() -> void:
	var player := PlayerScene.instantiate() as Player
	root.add_child(player)
	await process_frame
	assert(player.request_primary_attack())
	assert(player.attack_component.phase != MeleeAttackComponent.Phase.IDLE)
	var accepted := player.health_component.apply_damage(
		DamageInfo.new(22.0, _damage_source, Vector2.RIGHT, 175.0, 0.24)
	)
	assert(accepted)
	assert(player.attack_component.phase == MeleeAttackComponent.Phase.IDLE)
	assert(player.is_in_hit_recovery())
	assert(player.knockback_component.velocity.x > 0.0)
	assert(not player.request_primary_attack())
	assert(not player.request_ability(1))
	await create_timer(0.28).timeout
	assert(not player.is_in_hit_recovery())

	player.health_component.set_invulnerable(true)
	var health_before_block: float = player.health_component.current_health
	assert(
		not player.health_component.apply_damage(
			DamageInfo.new(22.0, _damage_source, Vector2.RIGHT, 175.0, 0.24)
		)
	)
	assert(player.health_component.current_health == health_before_block)
	assert(not player.is_in_hit_recovery())
	player.health_component.set_invulnerable(false)

	var armored_ability := player.ability_1_component
	armored_ability.definition = armored_ability.definition.duplicate(true)
	armored_ability.definition.grants_super_armor = true
	assert(armored_ability.request_cast(Vector2.RIGHT, 10.0))
	assert(
		player.health_component.apply_damage(
			DamageInfo.new(5.0, _damage_source, Vector2.LEFT, 0.0, 0.24)
		)
	)
	assert(armored_ability.is_casting())
	assert(not player.is_in_hit_recovery())
	player.health_component.apply_damage(DamageInfo.new(1.0, _damage_source, Vector2.LEFT, 0.0, 0.0, false, .8))
	assert(armored_ability.is_casting() and not player.stagger_component.is_stunned())
	assert(not player.get_node("StunIndicator").visible)
	armored_ability.cancel_cast()
	player.queue_free()
	await process_frame


func _make_stagger_fixture(definition: EnemyDefinition) -> Dictionary:
	var host := Node.new()
	var health := HealthComponent.new()
	health.maximum_health = 100.0
	var stagger := StaggerComponent.new()
	stagger.health_component = health
	host.add_child(health)
	host.add_child(stagger)
	root.add_child(host)
	await process_frame
	stagger.configure(definition)
	return {"host": host, "health": health, "stagger": stagger}
