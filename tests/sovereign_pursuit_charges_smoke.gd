extends SceneTree

const PlayerScene = preload("res://entities/player/player.tscn")
const SlotScene = preload("res://ui/skills/skill_bar_slot.tscn")
var failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	var session := root.get_node("RunSession")
	session.reset_run()
	var actor := PlayerScene.instantiate() as Player
	root.add_child(actor)
	actor.global_position = Vector2(200, 200)
	await process_frame
	var pursuit := actor.ability_3_component as SovereignPursuitComponent
	check(pursuit.get_max_charges() == 1 and pursuit.charges_available == 1 and pursuit.get_target_range_pixels() == 220.0, "Foundation charge/range changed")
	pursuit.apply_rank(SovereignPursuitDefinition.Rank.MATURE)
	actor.get_node("KingSkillLibrary").refresh()
	check(pursuit.get_max_charges() == 3 and pursuit.charges_available == 3 and pursuit.get_target_range_pixels() == 280.0, "Mature rank did not grant three uses and 280px")
	check(actor.get_ability_component_for_slot(3) == pursuit, "Ranked Pursuit lost its equipped hotkey/component mapping")
	check(actor.request_ability(3) and actor.ground_point_targeting.is_targeting(), "Ranked Pursuit did not open its normal targeted hotkey input")
	actor.ground_point_targeting.cancel_targeting()
	var slot := SlotScene.instantiate() as SkillBarSlot
	root.add_child(slot)
	slot.configure(actor.skill_loadout.get_slot(3))
	slot.bind_ability(pursuit)
	check(slot.state_label.text == "3/3", "HUD did not show full charge stock")
	slot.show_targeting()
	slot._on_cooldown_tick()
	check(slot.state_label.text == "AIM  RMB", "Charge HUD replaced the targeting prompt")
	slot.clear_targeting_presentation()
	var previous_recharge := 9.0
	for use in 3:
		check(pursuit.request_cast_at(actor.global_position + Vector2.RIGHT * 30.0, 20.0), "Pursuit rejected stored use %d" % use)
		check(pursuit.charges_available == 2 - use, "Pursuit spent the wrong charge count")
		var committed_target := pursuit._target_global_position
		check(not pursuit.request_cast_at(actor.global_position + Vector2.LEFT * 30.0, 20.0) and pursuit.charges_available == 2 - use and pursuit._target_global_position == committed_target, "Rejected active cast changed the committed target or spent another charge")
		if use == 0:
			check(actor.request_ability(3), "A second stored use could not enter the normal input buffer")
		check(slot.state_label.text == "%d/3" % (2 - use), "HUD stock did not follow spent use")
		if use > 0:
			check(pursuit.cooldown_remaining < previous_recharge, "Another use reset the existing recharge")
		previous_recharge = pursuit.cooldown_remaining
		var frames := 0
		var landed := false
		var landing_position := Vector2.ZERO
		while pursuit.is_casting() and frames < 100:
			await physics_frame
			await process_frame
			frames += 1
			if pursuit.phase == AbilityComponent.Phase.RECOVERY:
				if not landed:
					landed = true
					landing_position = actor.global_position
				elif use == 0:
					check(actor.global_position.distance_to(landing_position) < 0.75, "Pursuit travel velocity slid King after landing")
		check(not pursuit.is_casting(), "Pursuit did not return control after use %d" % use)
		check(landed, "Pursuit never reached landing recovery")
		if use == 0:
			check(actor.ground_point_targeting.is_targeting(), "Buffered Pursuit did not return to explicit target selection")
			actor.ground_point_targeting.cancel_targeting()
	check(not pursuit.is_ready() and not pursuit.request_cast_at(actor.global_position + Vector2.RIGHT * 30.0, 20.0), "Empty stock allowed another cast")
	for expected in [1, 2, 3]:
		pursuit._physics_process(pursuit.cooldown_remaining)
		check(pursuit.charges_available == expected, "Sequential refill failed at charge %d" % expected)
	check(pursuit.cooldown_remaining == 0.0 and slot.state_label.text == "3/3", "Full stock did not end recharge")
	pursuit.apply_rank(SovereignPursuitDefinition.Rank.ADVANCED)
	check(pursuit.get_max_charges() == 2 and pursuit.get_target_range_pixels() == 250.0, "Advanced rank values are wrong")
	pursuit.clear_cooldown()
	check(pursuit.charges_available == 2 and pursuit.cooldown_remaining == 0.0, "Debug cooldown clear did not refill stock")
	session.king_pursuit_rank = 2
	var snapshot: Dictionary = session.create_snapshot()
	check(session.can_restore_snapshot(snapshot), "Ranked run snapshot was rejected")
	snapshot.erase("king_pursuit_rank")
	check(session.can_restore_snapshot(snapshot) and session.restore_snapshot(snapshot) and session.king_pursuit_rank == 0, "Old profile without rank did not restore Foundation")
	snapshot["king_pursuit_rank"] = 3
	check(not session.can_restore_snapshot(snapshot), "Invalid saved rank was accepted")
	print("SOVEREIGN_PURSUIT_CHARGES_FAILURES=%d" % failures)
	quit(1 if failures > 0 else 0)


func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)
