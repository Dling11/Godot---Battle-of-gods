extends SceneTree

const Lab = preload("res://levels/combat_lab/combat_lab.tscn")
var checks := 0
var failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)


func _run() -> void:
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	var lab := Lab.instantiate()
	root.add_child(lab)
	await process_frame
	await process_frame
	var player: Player = lab.player
	lab.clear_simulation()
	player.health_component.is_damage_immune = false
	player.health_component.set_invulnerable(false)
	var marker: StunIndicator = player.get_node("StunIndicator")
	_check(not marker.visible and not marker.is_processing(), "Idle marker must do no animation work")
	player.health_component.apply_damage(DamageInfo.new(.1, null, Vector2.ZERO, 0.0, .11))
	_check(not marker.visible, "King's short hurt must not be labelled a stun")
	await create_timer(.2).timeout
	player.health_component.apply_damage(DamageInfo.new(.1, null, Vector2.ZERO, 0.0, 0.0, false, .8))
	_check(marker.visible, "Real King stun must show overhead stars")
	var original_health := player.health_component.current_health
	await create_timer(.15).timeout
	_check(marker.visible and marker._elapsed > .05, "Stars must animate throughout accepted stun")
	player.health_component.is_damage_immune = false
	player.health_component.set_invulnerable(false)
	player.health_component.apply_damage(DamageInfo.new(0.1, null, Vector2.ZERO, 0.0, 0.0, false, 1.0))
	await create_timer(.7).timeout
	_check(marker.visible, "An extended stun must not expire at the first hit's duration")
	player.stagger_component.clear()
	await process_frame
	await process_frame
	_check(not marker.visible and not marker.is_processing(), "Silent reset must clear the indicator")
	player.health_component.set_current_health(original_health)
	player.health_component.set_invulnerable(true)
	player.health_component.apply_damage(DamageInfo.new(1.0, null, Vector2.ZERO, 0.0, 0.0, false, .8))
	_check(not marker.visible, "Blocked damage must not create a stun marker")
	player.health_component.set_invulnerable(false)
	player.health_component.apply_damage(DamageInfo.new(1.0, null, Vector2.ZERO, 0.0, .5))
	_check(not marker.visible and not player.stagger_component.is_stunned(), "Even a long flinch is not a stun")
	_check(String(player.get_node("VisualRoot/Body").animation).begins_with("hurt_"), "Flinch must use hurt body pose")
	player.health_component.apply_damage(DamageInfo.new(1.0, null, Vector2.ZERO, 0.0, 0.0, false, .15))
	_check(marker.visible, "Explicit short stun must show even below old duration heuristic")
	_check(String(player.get_node("VisualRoot/Body").animation).begins_with("stagger_"), "Stun during a flinch must update the body pose")
	await create_timer(.22).timeout
	_check(not marker.visible and player.is_in_hit_recovery(), "Flinch must not extend expired stun stars")
	_check(String(player.get_node("VisualRoot/Body").animation).begins_with("hurt_"), "Residual flinch must return to hurt pose")
	player.stagger_component.clear()

	for enemy_name in ["forsaken_thrall", "mireling", "rootling", "bramble_spitter", "crag_bear", "armored_hog", "examiner"]:
		var enemy: Node2D = load("res://entities/enemies/%s/%s.tscn" % [enemy_name, enemy_name]).instantiate()
		enemy.target = player
		lab.add_child(enemy)
		enemy.set_physics_process(false)
		var indicator: StunIndicator = enemy.get_node("StunIndicator")
		_check(not indicator.visible, enemy_name + " spawn must not show stun")
		var states: Dictionary = enemy.get_script().get_script_constant_map()["State"]
		var next_state: int = states.get("STAGGER", states.get("GUARD_BROKEN", -1))
		enemy.set("state", next_state)
		enemy.emit_signal("state_changed", next_state, .8)
		if enemy_name != "examiner":
			_check(not indicator.visible, enemy_name + " flinch state must not imply stun")
			enemy.get_node("HealthComponent").apply_damage(DamageInfo.new(1.0, player, Vector2.ZERO, 0.0, 0.0, false, .8))
		_check(indicator.visible, enemy_name + " accepted state must show shared marker")
		if enemy_name == "armored_hog":
			enemy._enter(ArmoredHog.State.CHARGE, .8)
			enemy.stagger_component.stagger_started.emit(.8)
			_check(not indicator.visible, "Hog's committed charge must not show a rejected stun")
			enemy._enter(ArmoredHog.State.DAZED, .8)
			_check(indicator.visible, "Hog's crash daze must show the same marker")
		var exit_state: int = states.get("DEAD", states.get("GUARD_RECOVERY", 0))
		enemy.set("state", exit_state)
		enemy.emit_signal("state_changed", exit_state, .2)
		_check(not indicator.visible and not indicator.is_processing(), enemy_name + " recovery/death must stop animation immediately")
		enemy.queue_free()
		await process_frame

	player.health_component.apply_damage(DamageInfo.new(0.1, null, Vector2.ZERO, 0.0, 0.0, false, .4))
	_check(marker.visible, "Stun can restart after a reset")
	await create_timer(.6).timeout
	_check(not marker.visible, "Normal stun completion must hide the indicator")
	player.health_component.apply_damage(DamageInfo.new(0.1, null, Vector2.ZERO, 0.0, 0.0, false, .8))
	player.health_component.apply_damage(DamageInfo.new(100000.0, null, Vector2.ZERO))
	_check(not marker.visible, "Defeat must immediately clear King's stars")
	lab.queue_free()
	await process_frame
	await process_frame
	Input.set_custom_mouse_cursor(null, Input.CURSOR_ARROW)
	Input.set_custom_mouse_cursor(null, Input.CURSOR_POINTING_HAND)
	print("STUN_INDICATOR_CHECKS=", checks, " FAILURES=", failures)
	quit(0 if failures == 0 else 1)
