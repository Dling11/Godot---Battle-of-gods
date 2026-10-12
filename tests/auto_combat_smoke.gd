extends SceneTree

const PlayerScene = preload("res://entities/player/player.tscn")
const HudScene = preload("res://ui/combat_hud.tscn")
const MirelingScene = preload("res://entities/enemies/mireling/mireling.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	root.get_node("RunSession").reset_run()
	var player := PlayerScene.instantiate() as Player
	var first := MirelingScene.instantiate() as Mireling
	var second := MirelingScene.instantiate() as Mireling
	var hud := HudScene.instantiate() as CombatHUD
	first.target = player
	second.target = player
	root.add_child(player)
	root.add_child(first)
	root.add_child(second)
	root.add_child(hud)
	hud.bind_player(player)
	player.global_position = Vector2(100.0, 100.0)
	first.global_position = Vector2(120.0, 100.0)
	second.global_position = Vector2(160.0, 100.0)
	await process_frame
	await physics_frame

	if hud.auto_farm_button.icon == null or hud.auto_skill_button.icon == null:
		_fail("Auto roster controls do not expose their custom themed icons.")
		return
	player.set_auto_farm_enabled(true)
	if not player.auto_combat.auto_farm_enabled or not player.combat_targeting.auto_attack_enabled:
		_fail("AUTO ALL did not select and engage a live roster enemy.")
		return
	var first_target := player.combat_targeting.target_actor
	player.set_auto_skills_enabled(true)
	for frame_index in range(60):
		await physics_frame
		if player.is_any_ability_casting() or player.ability_1_component.cooldown_remaining > 0.0:
			break
	if not player.is_any_ability_casting() and player.ability_1_component.cooldown_remaining <= 0.0:
		_fail("AUTO SKILL did not use the first ready skill against an in-range target.")
		return
	first_target.health_component.apply_damage(DamageInfo.new(999.0, player, Vector2.RIGHT))
	await process_frame
	await physics_frame
	if not player.combat_targeting.has_valid_target() or player.combat_targeting.target_actor == first_target:
		_fail("AUTO ALL did not continue to the next living roster enemy.")
		return
	player.set_auto_farm_enabled(false)
	if player.auto_combat.auto_farm_enabled or player.auto_combat.auto_skills_enabled:
		_fail("Disabling AUTO ALL did not stop both attack and skill automation.")
		return

	print("Directional attack and optional auto-combat smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
