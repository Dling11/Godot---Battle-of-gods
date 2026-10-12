extends SceneTree

const PlayerScene = preload("res://entities/player/player.tscn")
const MirelingScene = preload("res://entities/enemies/mireling/mireling.tscn")
const DamageNumberScene = preload("res://ui/world/damage_number.tscn")
const HitBurstScene = preload("res://gameplay/presentation/hit_burst.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var player := PlayerScene.instantiate() as Player
	var effects := Node2D.new()
	var camera := Camera2D.new()
	var feedback := CombatFeedbackPresenter.new()
	feedback.player = player
	feedback.effects_parent = effects
	feedback.camera = camera
	feedback.damage_number_scene = DamageNumberScene
	feedback.hit_burst_scene = HitBurstScene
	root.add_child(player)
	player.add_child(camera)
	root.add_child(effects)
	root.add_child(feedback)
	await process_frame
	if (
		not is_equal_approx(feedback._resolve_basic_hitstop(10.0), 0.026)
		or not is_equal_approx(feedback._resolve_basic_hitstop(999.0), 0.034)
		or not is_equal_approx(
			feedback._resolve_ability_hitstop(player.ability_1_component),
			CombatFeedbackPresenter.HEAVY_HITSTOP_SECONDS
		)
		or not is_equal_approx(
			feedback._resolve_ability_hitstop(player.ability_2_component),
			CombatFeedbackPresenter.HEAVY_HITSTOP_SECONDS
		)
		or not is_equal_approx(
			feedback._resolve_ability_hitstop(player.ability_3_component),
			CombatFeedbackPresenter.MEDIUM_HITSTOP_SECONDS
		)
	):
		_fail("Ability impact weights did not resolve to their authored hitstop tiers.")
		return
	player.ability_4_component._current_strike_index = 1
	if not is_equal_approx(
		feedback._resolve_ability_hitstop(player.ability_4_component),
		CombatFeedbackPresenter.DEVASTATING_HITSTOP_SECONDS
	):
		_fail("King Skill 4's final strike did not resolve the devastating hitstop tier.")
		return
	player.ability_4_component._current_strike_index = 0
	if (
		not is_equal_approx(
			feedback._resolve_incoming_hitstop(8.0),
			CombatFeedbackPresenter.LIGHT_HITSTOP_SECONDS
		)
		or not is_equal_approx(
			feedback._resolve_incoming_hitstop(12.0),
			CombatFeedbackPresenter.MEDIUM_HITSTOP_SECONDS
		)
		or not is_equal_approx(
			feedback._resolve_incoming_hitstop(22.0),
			CombatFeedbackPresenter.HEAVY_HITSTOP_SECONDS
		)
		or not is_equal_approx(
			feedback._resolve_incoming_hitstop(30.0),
			CombatFeedbackPresenter.DEVASTATING_HITSTOP_SECONDS
		)
	):
		_fail("Incoming damage did not resolve to the authored player-hitstop tiers.")
		return

	player.health_component.apply_damage(DamageInfo.new(7.0, null, Vector2.LEFT))
	if effects.get_child_count() != 2:
		_fail("Accepted player damage did not create a number and hit burst.")
		return
	if not paused:
		_fail("Accepted player damage did not start incoming hitstop.")
		return
	await create_timer(0.08, true, false, true).timeout
	if paused:
		_fail("Incoming hitstop did not restore gameplay after its real-time window.")
		return
	for effect in effects.get_children():
		effect.queue_free()
	await process_frame

	var mirelings: Array[Mireling] = []
	for target_index in 4:
		var target := MirelingScene.instantiate() as Mireling
		target.position = Vector2(float(target_index * 20), 0.0)
		root.add_child(target)
		mirelings.append(target)
	await process_frame
	player.attack_component.attack_started.emit()
	player.attack_component.hit_landed.emit(
		mirelings[0].get_node("Hurtbox") as HurtboxComponent,
		DamageInfo.new(25.0, player, Vector2.RIGHT)
	)
	var shared_camera_tween := feedback._camera_tween
	for target_index in range(1, mirelings.size()):
		player.attack_component.hit_landed.emit(
			mirelings[target_index].get_node("Hurtbox") as HurtboxComponent,
			DamageInfo.new(25.0, player, Vector2.RIGHT)
		)
	var numbers := effects.get_children().filter(func(node: Node) -> bool: return node is DamageNumber)
	var bursts := effects.get_children().filter(func(node: Node) -> bool: return node is HitBurst)
	if numbers.size() != 4 or bursts.size() != 4:
		_fail("Clustered sword hit did not preserve one number and burst per target.")
		return
	var hit_audio := effects.get_children().filter(func(node: Node) -> bool: return node is AudioStreamPlayer2D)
	var expected_audio := 0 if DisplayServer.get_name() == "headless" else 1
	if hit_audio.size() != expected_audio:
		_fail("Clustered sword contact did not share exactly one native impact sound.")
		return
	var mireling_body := mirelings[0].get_node("Visual/Body") as AnimatedSprite2D
	if not mireling_body.material is ShaderMaterial:
		_fail("Accepted player hit did not apply the reusable enemy hit-flash material.")
		return
	if feedback._camera_tween != shared_camera_tween:
		_fail("One clustered sword swing rebuilt shared camera feedback for every target.")
		return
	if not paused:
		_fail("Accepted player hit did not start hitstop.")
		return
	await create_timer(0.12, true, false, true).timeout
	if paused:
		_fail("Hitstop did not restore gameplay after its short real-time window.")
		return
	if mireling_body.material != null:
		_fail("Enemy hit flash did not restore the original material.")
		return
	await process_frame
	await create_timer(0.7).timeout
	if effects.get_child_count() != 0:
		_fail("Combat feedback did not clean up its transient effects.")
		return
	print("Combat feedback smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
