extends SceneTree

const ArenaScene = preload("res://levels/test_arena/test_arena.tscn")
const DamageInfoScript = preload("res://gameplay/combat/damage_info.gd")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var arena := ArenaScene.instantiate()
	root.add_child(arena)
	var player = arena.get_node("World/Actors/Player")
	var health = player.get_node("HealthComponent")
	var hud = arena.get_node("UI/CombatHUD")

	health.set_invulnerable(true)
	health.apply_damage(DamageInfoScript.new(10.0, player, Vector2.LEFT))
	await process_frame
	if not hud.blocked_label.visible or health.current_health != health.maximum_health:
		_fail("Blocked damage did not preserve health and notify the HUD.")
		return

	health.set_invulnerable(false)
	health.apply_damage(DamageInfoScript.new(999.0, player, Vector2.LEFT))
	await process_frame
	if not player.is_defeated:
		_fail("Lethal damage did not defeat the player.")
		return
	if player.request_primary_attack() or player.request_evade(Vector2.RIGHT):
		_fail("Defeated player accepted a combat request.")
		return
	if hud.health_bar.value != 0.0:
		_fail("HUD health bar did not update to zero.")
		return

	await create_timer(0.5).timeout
	if not hud.defeat_panel.visible:
		_fail("Defeat panel did not appear after the presentation delay.")
		return
	if not InputMap.has_action("arena_restart"):
		_fail("Arena restart action is missing.")
		return

	print("Player defeat flow smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)

