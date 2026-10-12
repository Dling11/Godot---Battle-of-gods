extends SceneTree

const Lab = preload("res://levels/combat_lab/combat_lab.tscn")
var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	if not ok:
		failures.append(message)

func run() -> void:
	var lab := Lab.instantiate()
	root.add_child(lab)
	await create_timer(.8).timeout
	var boss := lab._active_enemies[0] as Examiner
	boss.set_physics_process(false)
	lab.player.set_physics_process(false)
	boss._deactivate_hitboxes()
	boss._axiom_cooldown = 0
	boss._charge_cooldown = 0
	boss._slam_cooldown = 0
	boss._refutation_cooldown = 0
	boss._orb_cooldown = 0
	boss._close_exchange_count = 2
	boss.tactics.random.seed = 2026
	var previous: StringName = &""
	var distinct := {}
	for pick in 100:
		var action := boss.tactics.choose(boss, 60)
		check(action != previous, "Tactics repeated an action despite legal alternatives")
		check(action not in [&"firmament", &"crownfall", &"charge"], "Tactics selected illegal range/phase action")
		distinct[action] = true
		previous = action
	check(distinct.size() >= 4, "Tactics did not vary the opening kit")
	boss._phase_two = true
	boss._phase_transition_requested = true
	boss._axiom_count = 1
	boss.global_position = Vector2(300,280)
	lab.player.global_position = Vector2(480,280)
	boss._set_facing(Vector2.RIGHT)
	boss._enter(Examiner.State.AXIOM_RECOVERY, 0)
	boss._tick_state(.01)
	check(boss.state == Examiner.State.PURSUIT_WIND_UP and not boss.dash_hitbox._enabled, "Axiom follow-up lacked a fresh warning")
	var endpoint := boss.judgment_charge_endpoint()
	lab.player.global_position += Vector2(0,100)
	boss._track_target_before_commit()
	check(boss.judgment_charge_endpoint() == endpoint, "Linked follow-up tracked after commit")
	# Three actual seal breaks build the reaction counter without draining HP.
	for count in 3:
		boss._begin_orb()
		boss.health_component.apply_damage(DamageInfo.new(400,lab.player,Vector2.UP))
	check(boss.seals_broken == 3 and boss.seals_attempted == 3, "Seal reactions did not track completed breaks")
	# Real lethal damage owns the result; pending effects must disappear first.
	boss._spawn_sun(Vector2(365,280),48,100,.9,true)
	var completed := [0]
	boss.encounter_completed.connect(func() -> void: completed[0] += 1)
	boss.health_component.apply_damage(DamageInfo.new(5000,lab.player,Vector2.UP))
	check(boss.state == Examiner.State.VICTORY_KNEEL and lab.player.is_cinematic_locked(), "Lethal damage skipped victory kneel/input lock")
	check(boss._owned_suns.is_empty() and not boss.firmament.active and not boss.trial.active, "Victory retained hazard authority")
	await create_timer(1.8).timeout
	check(boss.state == Examiner.State.VICTORY_HOLD and lab.examiner_director.dialogue.visible, "Victory did not recover into dialogue")
	lab.examiner_director.dialogue.close_dialogue(false)
	await create_timer(.45).timeout
	check(completed[0] == 1 and not lab.player.is_cinematic_locked(), "Skipping victory did not complete once and release King")
	await create_timer(1.1).timeout
	check(not is_instance_valid(boss), "Completed Examiner did not withdraw")
	# Reset during the kneel cannot open stale dialogue over a replacement boss.
	lab.spawn_selected(1)
	await create_timer(.8).timeout
	boss = lab._active_enemies[0] as Examiner
	boss.health_component.apply_damage(DamageInfo.new(5000,lab.player,Vector2.UP))
	lab.clear_simulation()
	lab.spawn_selected(1)
	await create_timer(1.8).timeout
	check(not lab.examiner_director.dialogue.visible and not lab.player.is_cinematic_locked(), "Old outro leaked into replacement encounter")
	lab.clear_simulation()
	lab.queue_free()
	await process_frame
	for message in failures:
		push_error(message)
	print("Examiner tactics/victory: eligible variety, committed link, seal reactions, lethal outro, skip/once, reset lifecycle: ", "PASS" if failures.is_empty() else "FAIL")
	quit(0 if failures.is_empty() else 1)
