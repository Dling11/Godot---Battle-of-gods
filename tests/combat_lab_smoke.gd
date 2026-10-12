extends SceneTree

const LabScene = preload("res://levels/combat_lab/combat_lab.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if not _action_has_key("debug_combat_lab", KEY_F7) or not _action_has_key("debug_toggle_admin", KEY_F10):
		_fail("Combat Lab/Admin Mode lost the physical F7/F10 debug bindings.")
		return
	var lab := LabScene.instantiate()
	root.add_child(lab)
	await process_frame
	await process_frame
	await physics_frame

	var admin_state := root.get_node_or_null("DebugAdminState")
	if admin_state == null or not bool(admin_state.get("enabled")):
		_fail("Opening the debug Combat Lab did not enable session Admin Mode.")
		return
	if lab.enemy_selector.item_count != 9:
		_fail("Combat Lab roster must expose all nine current enemy archetypes and trials.")
		return
	if lab.enemy_selector.selected != 8 or lab.get_live_enemy_count() != 1:
		_fail("Combat Lab did not open on one visible Examiner trial proof.")
		return
	if not lab.boss_hud.visible or lab.boss_hud.health_component == null:
		_fail("Combat Lab did not bind its top-screen HUD to the opening Examiner trial.")
		return
	if not lab.court_arena.visible or lab.base_arena.visible or lab.base_arena_border.visible:
		_fail("Combat Lab did not switch the opening Examiner proof to the divine court.")
		return
	var admin_controls: Array[Control] = [
		lab.enemy_selector,
		lab.spawn_one_button,
		lab.spawn_four_button,
		lab.spawn_eight_button,
		lab.ai_toggle,
		lab.invincible_toggle,
		lab.combat_tools_button,
		lab.force_phase_button,
		lab.clear_button,
		lab.reset_button,
		lab.exit_button,
	]
	for control: Control in admin_controls:
		if control.focus_mode != Control.FOCUS_NONE:
			_fail("Combat Lab control %s can retain Space/accept focus during gameplay." % control.name)
			return
	if not _enemies_are_rewardless(lab):
		_fail("Combat Lab enemy retained production reward authority.")
		return
	if not lab.force_phase_button.visible or lab.force_phase_button.disabled:
		_fail("Combat Lab did not expose the Examiner-only Divine Descent force control.")
		return

	lab.set_enemy_ai_enabled(false)
	for enemy in lab._active_enemies:
		if is_instance_valid(enemy) and enemy.get("target") != null:
			_fail("Combat Lab AI pause did not clear an enemy target.")
			return
	lab.set_enemy_ai_enabled(true)
	for enemy in lab._active_enemies:
		if is_instance_valid(enemy) and enemy.get("target") != lab.player:
			_fail("Combat Lab AI resume did not restore the real player target.")
			return

	lab.clear_simulation()
	await process_frame
	if lab.get_live_enemy_count() != 0:
		_fail("Combat Lab clear did not remove the active simulation.")
		return
	if lab.boss_hud.visible or lab.boss_hud.health_component != null:
		_fail("Combat Lab clear did not remove the active boss HUD binding.")
		return

	for roster_index in range(9):
		lab.enemy_selector.select(roster_index)
		lab.spawn_selected(1)
		await physics_frame
		if lab.get_live_enemy_count() != 1 or not _enemies_are_rewardless(lab):
			_fail("Combat Lab could not safely instantiate roster entry %d." % roster_index)
			return
		if roster_index == 7 and not lab.boss_hud.visible:
			_fail("Combat Lab did not restore boss presentation when respawning the Stage 5 boss.")
			return
		if roster_index == 8 and (not lab.boss_hud.visible or not lab.court_arena.visible):
			_fail("Combat Lab did not restore the Examiner boss presentation and divine court.")
			return
		lab.clear_simulation()
		await process_frame

	lab.enemy_selector.select(0)
	lab.spawn_selected(4)
	await physics_frame
	if lab.get_live_enemy_count() != 4:
		_fail("Combat Lab x4 crowd control did not spawn four actors.")
		return
	lab.clear_simulation()
	await process_frame
	lab.enemy_selector.select(1)
	lab.spawn_selected(8)
	await physics_frame
	if lab.get_live_enemy_count() != 8:
		_fail("Combat Lab x8 crowd control did not spawn eight actors.")
		return

	lab.set_player_invincible(false)
	if lab.player.health_component.is_invulnerable:
		_fail("Combat Lab could not return King to vulnerable testing.")
		return
	lab.set_player_invincible(true)
	if not lab.player.health_component.is_invulnerable:
		_fail("Combat Lab could not restore King invincibility.")
		return

	print("Combat Lab admin boundary, complete roster including Examiner trial, reward stripping, arena switching, AI, x1/x4/x8 spawning, clear, and invincibility passed.")
	quit(0)


func _enemies_are_rewardless(lab: Node) -> bool:
	for enemy in lab._active_enemies:
		if is_instance_valid(enemy) and enemy.get_node_or_null("EnemyRewardComponent") != null:
			return false
	return true


func _action_has_key(action: StringName, keycode: Key) -> bool:
	if not InputMap.has_action(action):
		return false
	for event: InputEvent in InputMap.action_get_events(action):
		if event is InputEventKey and event.physical_keycode == keycode:
			return true
	return false


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
