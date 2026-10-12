extends SceneTree

const PlayerScene = preload("res://entities/player/player.tscn")
const HudScene = preload("res://ui/combat_hud.tscn")
const MirelingScene = preload("res://entities/enemies/mireling/mireling.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	root.get_node("RunSession").reset_run()
	var player := PlayerScene.instantiate() as Player
	var hud := HudScene.instantiate() as CombatHUD
	var first := MirelingScene.instantiate() as Mireling
	var second := MirelingScene.instantiate() as Mireling
	first.target = player
	second.target = player
	root.add_child(player)
	root.add_child(first)
	root.add_child(second)
	root.add_child(hud)
	first.set_physics_process(false)
	second.set_physics_process(false)
	hud.bind_player(player)
	player.global_position = Vector2(100.0, 100.0)
	first.global_position = Vector2(240.0, 100.0)
	second.global_position = Vector2(100.0, 220.0)
	await process_frame
	await physics_frame

	var first_hurtbox := first.get_node("Hurtbox") as HurtboxComponent
	if not player.combat_targeting.select_at_world_position(first_hurtbox.global_position):
		_fail("Click-position picking could not select an alive enemy hurtbox.")
		return
	if player.combat_targeting.target_actor != first or player.combat_targeting.auto_attack_enabled:
		_fail("World clicking did not establish one selected-but-idle target.")
		return
	if not hud.target_panel.visible or hud.target_name_label.text != "MIRELING":
		_fail("The left target panel did not present the selected enemy name and health.")
		return
	if not hud.target_portrait.visible or not hud.enemy_roster_panel.visible:
		_fail("Selected-target portrait or top-right enemy roster did not appear.")
		return
	hud.attack_button.pressed.emit()
	if not player.combat_targeting.auto_attack_enabled:
		_fail("BASIC ATTACK did not explicitly enable selected-target assistance.")
		return
	if player.combat_targeting.get_assisted_move_direction(0.2).dot(Vector2.RIGHT) < 0.9:
		_fail("BASIC ATTACK did not steer toward the selected target.")
		return

	Input.action_press("player_move_left")
	await physics_frame
	Input.action_release("player_move_left")
	if player.velocity.x >= 0.0:
		_fail("Manual WASD did not override assisted pursuit while held.")
		return
	if player.combat_targeting.has_valid_target() or player.combat_targeting.auto_attack_enabled:
		_fail("Manual WASD did not cancel selection and assisted combat intent.")
		return
	if not player.combat_targeting.select_hurtbox(first_hurtbox, true):
		_fail("The first target could not be re-engaged after manual movement.")
		return

	player.global_position = Vector2(220.0, 100.0)
	player.velocity = Vector2.ZERO
	await physics_frame
	if (
		player.facing_direction != Vector2.RIGHT
		or player.attack_component.phase == MeleeAttackComponent.Phase.IDLE
		or not is_equal_approx(player.combat_targeting.get_target_approach_distance(), 20.0)
	):
		_fail("King did not enter attack on the selected enemy's foot-circle boundary.")
		return

	if not player.combat_targeting.select_hurtbox(second.get_node("Hurtbox") as HurtboxComponent):
		_fail("A second enemy could not replace the first target.")
		return
	if player.combat_targeting.target_actor != second:
		_fail("Multiple enemies created ambiguous target authority instead of replacing it.")
		return
	second.health_component.apply_damage(DamageInfo.new(999.0, player, Vector2.DOWN))
	await process_frame
	if player.combat_targeting.has_valid_target() or hud.target_panel.visible:
		_fail("Dead target cleanup did not clear targeting and its HUD presentation.")
		return
	player.attack_component.cancel_attack()
	player.combat_targeting.request_click_move(Vector2(300.0, 100.0))
	if player.combat_targeting.get_click_move_direction(0.2).dot(Vector2.RIGHT) < 0.9:
		_fail("An empty right-click destination did not produce movement intent.")
		return
	await physics_frame
	if player.facing_direction != Vector2.RIGHT:
		_fail("Click-to-move did not face King along the actual ground path direction.")
		return
	if not player.request_world_primary_click(Vector2(100.0, 180.0)):
		_fail("A ground left click did not request its directional air swing.")
		return
	if not player.combat_targeting.get_click_move_direction(0.2).is_zero_approx():
		_fail("A ground left-click attack did not cancel active right-click movement.")
		return

	if hud.attack_button.size != Vector2(54.0, 44.0) or (hud.attack_button.get_parent().get_node("AttackLabel") as Label).text != "ATK" or (hud.attack_button.get_parent().get_node("AttackIcon") as TextureRect).texture == null:
		_fail("The compact unnumbered Attack fallback does not retain its authored footprint or label.")
		return
	player.attack_component.cancel_attack()
	hud.attack_button.pressed.emit()
	await physics_frame
	if player.combat_targeting.has_valid_target() or player.attack_component.phase == MeleeAttackComponent.Phase.IDLE:
		_fail("Attack with no selection did not swing freely without auto-acquiring an enemy.")
		return

	player.attack_component.cancel_attack()
	first.global_position = Vector2(600.0, 100.0)
	if not player.combat_targeting.select_hurtbox(first.get_node("Hurtbox") as HurtboxComponent):
		_fail("The distant target could not be selected for the assist-radius check.")
		return
	hud.attack_button.pressed.emit()
	if player.combat_targeting.auto_attack_enabled or player.attack_component.phase == MeleeAttackComponent.Phase.IDLE:
		_fail("A distant selected enemy forced pathing instead of allowing a free swing.")
		return

	player.attack_component.cancel_attack()
	first.global_position = Vector2(240.0, 100.0)
	player.combat_targeting.clear_target()
	var footprint_pick := first.global_position + Vector2(0.0, 9.0)
	if not player.request_world_primary_click(footprint_pick):
		_fail("A single left click could not select the enemy through its foot circle.")
		return
	if player.combat_targeting.target_actor != first or player.combat_targeting.auto_attack_enabled:
		_fail("A single enemy left click did not remain selected-but-idle.")
		return
	if not player.request_world_primary_click(footprint_pick):
		_fail("A repeated left click could not engage the selected enemy.")
		return
	if not player.combat_targeting.auto_attack_enabled:
		_fail("A double enemy left click did not enable approach-and-attack.")
		return
	var health_before := first.health_component.current_health
	for frame_index in range(120):
		await physics_frame
		if first.health_component.current_health < health_before:
			break
	if first.health_component.current_health >= health_before:
		_fail("Assisted combat approached the foot circle but never landed a real melee hit.")
		return
	if player.global_position.distance_to(first.global_position) > 24.0:
		_fail("Assisted combat attacked before reaching the target's foot-circle boundary.")
		return
	player.combat_targeting.request_click_move(Vector2(320.0, 100.0))
	if player.combat_targeting.has_valid_target() or player.combat_targeting.auto_attack_enabled:
		_fail("Ground clicking did not clear selection and auto attack.")
		return

	print("Assisted combat targeting smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	Input.action_release("player_move_left")
	push_error(message)
	quit(1)
