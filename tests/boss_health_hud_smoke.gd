extends SceneTree

const BossHUDScene = preload("res://ui/boss/boss_health_hud.tscn")
const BossArenaScene = preload("res://levels/stage_5_boss_test/stage_5_boss_test.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var health := HealthComponent.new()
	health.maximum_health = 900.0
	root.add_child(health)
	var hud := BossHUDScene.instantiate() as BossHealthHUD
	root.add_child(hud)
	await process_frame
	if hud.visible:
		_fail("Unbound boss HUD was visible.")
		return

	hud.bind_boss(health, "Stage 5 Boss", "Combat Proof")
	await process_frame
	if not hud.visible or hud.name_label.text != "STAGE 5 BOSS" or hud.context_label.text != "COMBAT PROOF":
		_fail("Boss HUD did not reveal its reusable title/context presentation.")
		return
	if hud.health_label.text != "900 / 900" or hud.phase_label.text != "PHASE I":
		_fail("Boss HUD did not initialize exact health and Phase I.")
		return

	health.set_current_health(700.0)
	if hud.health_bar.value != 700.0 or hud.phase_label.text != "PHASE II":
		_fail("Boss HUD did not enter Phase II immediately below 80%.")
		return
	if hud.damage_trail.value != 900.0:
		_fail("Boss HUD damage trail did not retain the previous value before easing.")
		return
	await create_timer(0.55).timeout
	if not is_equal_approx(hud.damage_trail.value, 700.0):
		_fail("Boss HUD delayed damage trail did not settle on current health.")
		return

	health.set_current_health(270.0)
	if hud.phase_label.text != "PHASE III" or hud.health_label.text != "270 / 900":
		_fail("Boss HUD did not enter Phase III at exactly 30%.")
		return
	health.set_current_health(0.0)
	if hud.phase_label.text != "DEFEATED":
		_fail("Boss HUD did not retain a defeated state at zero health.")
		return
	hud.clear_boss()
	if hud.visible or hud.health_component != null:
		_fail("Boss HUD did not safely clear its encounter binding.")
		return

	var arena := BossArenaScene.instantiate()
	root.add_child(arena)
	await process_frame
	if arena.boss_hud == null or arena.boss_hud.health_component != arena.boss.health_component:
		_fail("Focused F8 arena did not bind the reusable boss HUD.")
		return
	if arena.boss.get_node_or_null("EnemyHealthBar") != null:
		_fail("Stage 5 boss retained a competing world-space health bar.")
		return

	print("Reusable top-screen boss HUD, delayed damage, phase thresholds, arena binding, and local-bar suppression passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
