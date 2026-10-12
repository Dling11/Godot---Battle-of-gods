extends SceneTree

const PlayerScene = preload("res://entities/player/player.tscn")
const DamageNumberScene = preload("res://ui/world/damage_number.tscn")
const VarkuunEdge = preload("res://data/weapons/varkuun_edge_essence.tres")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	root.get_node("SaveService").configure_storage_path_for_testing("user://critical_hit_smoke.json")
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	root.get_node("RunSession").reset_run()
	var hitbox := MeleeHitbox.new()
	var critical_seed := -1
	for seed in 10000:
		var probe := RandomNumberGenerator.new()
		probe.seed = seed
		if probe.randf() < VarkuunEdge.critical_chance_ratio:
			critical_seed = seed
			break
	if critical_seed < 0:
		_fail("Could not find a deterministic Varkuun Edge critical test seed.")
		return
	hitbox.configure_random_seed_for_testing(critical_seed)
	hitbox._resolve_damage_roll(
		20.0,
		VarkuunEdge.critical_chance_ratio,
		VarkuunEdge.critical_damage_multiplier
	)
	if not hitbox._is_critical or not is_equal_approx(hitbox._damage, 30.0):
		_fail("Varkuun Edge did not resolve its deterministic 150% critical hit.")
		return
	hitbox._resolve_damage_roll(20.0, 0.0, VarkuunEdge.critical_damage_multiplier)
	if hitbox._is_critical or not is_equal_approx(hitbox._damage, 20.0):
		_fail("Zero critical chance changed ordinary outgoing damage.")
		return

	var critical_info := DamageInfo.new(30.0, null, Vector2.RIGHT, 0.0, 0.0, true)
	if not critical_info.is_critical:
		_fail("DamageInfo did not preserve the authoritative critical result.")
		return
	var number := DamageNumberScene.instantiate() as DamageNumber
	number.configure(critical_info.amount, Color.WHITE, 24.0, critical_info.is_critical)
	root.add_child(number)
	await process_frame
	if number.label.text != "CRIT 30" or number.label.label_settings.font_size != 17:
		_fail("Critical-hit world feedback is not explicit and visually stronger.")
		return
	number.queue_free()

	var player := PlayerScene.instantiate() as Player
	root.add_child(player)
	await process_frame
	player.attack_component.set_weapon_definition(VarkuunEdge)
	player._configure_ability_critical_profile(player.ability_1_component)
	if (
		not is_equal_approx(player.ability_1_component._critical_chance_ratio, 0.08)
		or not is_equal_approx(player.ability_1_component._critical_damage_multiplier, 1.5)
	):
		_fail("King skills did not receive the equipped weapon's critical profile.")
		return
	player.attack_component.set_equipment_attack_speed_bonus(9.0)
	player.movement_component.set_equipment_speed_bonus(9.0)
	if (
		not is_equal_approx(player.attack_component._attack_speed_bonus_ratio, 0.5)
		or not is_equal_approx(player.movement_component.max_speed, 148.5)
	):
		_fail("Equipment percentage caps did not protect attack or movement speed.")
		return

	hitbox.free()
	player.queue_free()
	await process_frame
	print("Varkuun Edge critical authority, feedback, and percentage caps passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
