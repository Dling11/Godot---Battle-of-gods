extends SceneTree

const PlayerScene = preload("res://entities/player/player.tscn")
const MirelingScene = preload("res://entities/enemies/mireling/mireling.tscn")
const HudScene = preload("res://ui/combat_hud.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var run_session := root.get_node("RunSession")
	run_session.reset_run()
	root.get_node("StoryState").reset_story()
	var player := PlayerScene.instantiate() as Player
	var hud := HudScene.instantiate() as CombatHUD
	root.add_child(player)
	root.add_child(hud)
	player.set_physics_process(false)
	hud.bind_player(player)
	var progression := player.progression_component
	if progression.level != 1 or progression.coins != 0 or progression.definition.maximum_level != 10:
		_fail("Player progression did not begin as a level-one, zero-coin, level-ten-cap session.")
		return

	progression.grant_rewards(149, 2)
	if progression.level != 1 or progression.total_experience != 149 or progression.coins != 2:
		_fail("XP or coin rewards did not update session state correctly.")
		return
	if hud.level_label.text != "LV. 1":
		_fail("Progression HUD did not display the current level.")
		return
	if not progression.spend_coins(1) or progression.coins != 1 or progression.spend_coins(2):
		_fail("Coin spending did not deduct valid purchases or reject insufficient funds.")
		return
	progression.grant_rewards(1, 0)
	var level_up_visual := player.get_node("LevelUpVisual") as PlayerLevelUpVisual
	if (
		progression.level != 2
		or not is_equal_approx(player.health_component.maximum_health, 152.0)
		or not level_up_visual.level_label.visible
		or level_up_visual.level_label.text != "LEVEL 2"
	):
		_fail("Level 2 did not grant +12 maximum health and show compact overhead feedback.")
		return
	progression.grant_rewards(154, 0)
	if (
		progression.total_experience != 304
		or progression.level != 2
		or not is_equal_approx(player.health_component.maximum_health, 152.0)
	):
		_fail("Stage I's 304 XP should finish at Level 2 with 152 maximum health.")
		return
	progression.grant_rewards(96, 0)
	if progression.level != 3 or not is_equal_approx(player.health_component.maximum_health, 164.0):
		_fail("The 400-XP threshold did not unlock Level 3 and 164 maximum health.")
		return
	progression.grant_rewards(9999, 3)
	if progression.level != 3 or progression.total_experience != 400 or progression.coins != 4:
		_fail("Stage cap must discard excess XP while preserving coin rewards.")
		return
	if not hud.experience_label.text.begins_with("STAGE CAP") or not hud.experience_label.tooltip_text.contains("Stage I"):
		_fail("Stage cap needs distinct HUD feedback.")
		return
	for index in progression.definition.cap_unlock_flags.size():
		root.get_node("StoryState").remember_story(progression.definition.cap_unlock_flags[index])
		var cap: int = progression.definition.unlocked_level_caps[index]
		if progression.get_current_level_cap() != cap:
			_fail("Stage-clear cap did not unlock immediately.")
			return
		progression.grant_rewards(9999, 0)
		if progression.level != cap or progression.total_experience != progression.definition.total_experience_by_level[cap-1]:
			_fail("XP banked beyond the unlocked stage cap.")
			return
	root.get_node("StoryState").reset_story()
	if progression.get_current_level_cap() != 10:
		_fail("Legacy earned levels were taken away by a new gate.")
		return
	if progression.level != 10 or not is_equal_approx(player.health_component.maximum_health, 248.0):
		_fail("Progression or level-scaled vitality failed to reach the Level-10 cap.")
		return
	if hud.experience_label.text != "MAX LEVEL":
		_fail("Progression HUD did not show maximum-level state.")
		return

	run_session.reset_run()
	root.get_node("StoryState").reset_story()
	var reward_player := PlayerScene.instantiate() as Player
	var mireling := MirelingScene.instantiate() as Mireling
	mireling.target = reward_player
	root.add_child(reward_player)
	root.add_child(mireling)
	reward_player.set_physics_process(false)
	var health := mireling.get_node("HealthComponent") as HealthComponent
	health.apply_damage(DamageInfo.new(999.0, reward_player, Vector2.RIGHT))
	await process_frame
	if reward_player.progression_component.total_experience != 8 or reward_player.progression_component.coins != 1:
		_fail("Mireling death did not grant its data-defined 8 XP and 1 coin reward.")
		return

	print("Player progression smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
