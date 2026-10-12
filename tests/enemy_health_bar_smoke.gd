extends SceneTree

const ThrallScene = preload("res://entities/enemies/forsaken_thrall/forsaken_thrall.tscn")
const MirelingScene = preload("res://entities/enemies/mireling/mireling.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var enemy_scenes: Array[PackedScene] = [ThrallScene, MirelingScene]
	for enemy_scene: PackedScene in enemy_scenes:
		var enemy: Node = enemy_scene.instantiate()
		root.add_child(enemy)
		var health := enemy.get_node("HealthComponent") as HealthComponent
		var bar := enemy.get_node("EnemyHealthBar") as EnemyHealthBar
		await process_frame
		if not bar.has_node("Frame"):
			_fail("Enemy health bar is missing its contrast frame.")
			return
		if bar.visible:
			_fail("Enemy health bar must begin hidden at full health.")
			return
		var hit := DamageInfo.new(5.0, null, Vector2.RIGHT)
		health.apply_damage(hit)
		if not bar.visible or not is_equal_approx(bar.progress_bar.value, health.current_health):
			_fail("Enemy damage did not reveal and update its health bar.")
			return
		bar._on_hide_timer_timeout()
		if bar.visible:
			_fail("Enemy health bar did not hide after its visibility window.")
			return
		health.apply_damage(DamageInfo.new(health.current_health, null, Vector2.RIGHT))
		if bar.visible:
			_fail("Enemy health bar remained visible after death.")
			return
		enemy.queue_free()
		await process_frame
	print("Enemy health bar smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
