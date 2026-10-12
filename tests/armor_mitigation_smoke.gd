extends SceneTree

const BossScene = preload("res://entities/enemies/stage_5_boss/stage_5_boss.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	var boss := BossScene.instantiate() as Stage5Boss
	root.add_child(boss)
	await process_frame
	if not is_equal_approx(boss.health_component.armor_rating, 30.0):
		_fail("Varkuun did not receive his authored 30 armor from EnemyDefinition.")
		return
	var hit := DamageInfo.new(130.0, null, Vector2.RIGHT)
	var health_before := boss.health_component.current_health
	if not boss.health_component.apply_damage(hit):
		_fail("A valid armored hit was incorrectly rejected.")
		return
	if (
		not is_equal_approx(hit.raw_amount, 130.0)
		or not is_equal_approx(hit.amount, 100.0)
		or not is_equal_approx(boss.health_component.current_health, health_before - 100.0)
	):
		_fail("Thirty armor did not resolve 130 raw damage into 100 accepted damage.")
		return
	var unarmored := HealthComponent.new()
	unarmored.maximum_health = 200.0
	root.add_child(unarmored)
	await process_frame
	var plain_hit := DamageInfo.new(12.0, null, Vector2.ZERO)
	unarmored.apply_damage(plain_hit)
	if not is_equal_approx(plain_hit.amount, 12.0) or not is_equal_approx(unarmored.current_health, 188.0):
		_fail("Zero armor changed legacy damage behavior.")
		return
	var warded := HealthComponent.new()
	warded.maximum_health = 200.0
	warded.armor_rating = 25.0
	warded.ward_reduction_ratio = 0.10
	root.add_child(warded)
	await process_frame
	var warded_hit := DamageInfo.new(100.0, null, Vector2.ZERO)
	warded.apply_damage(warded_hit)
	if not is_equal_approx(warded_hit.amount, 72.0):
		_fail("Armor followed by Ward did not reduce 100 raw damage to 72 accepted damage.")
		return
	print("Reusable armor mitigation and Varkuun armor smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
