extends "res://tests/sanctuary_test_base.gd"

const LAB = preload("res://levels/combat_lab/combat_lab.tscn")
const ITEM = preload("res://data/items/equipment/king_iron_reaper.tres")

func _run() -> void:
	root.get_node("SaveService").configure_storage_path_for_testing("user://iron_reaper_idle_smoke.json")
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	var lab := LAB.instantiate()
	root.add_child(lab)
	current_scene = lab
	await process_frame
	lab.clear_simulation()
	lab._set_examiner_arena(false)
	var actor: Player = lab.player
	actor.set_physics_process(false)
	actor.apply_debug_testing_preset()
	actor.set_weapon_definition(ITEM.weapon_definition)
	var family: Node = actor.get_node("WeaponFamilyPresentation")
	for direction in [Vector2.RIGHT,Vector2.LEFT,Vector2.UP,Vector2.DOWN]:
		actor._set_facing_direction(direction)
		await physics_frame
		var presenter: Node2D = family.presenter
		presenter._rest()
		var peak := 0.0
		var unit_scale := true
		var phase_idle := true
		for tick in 100:
			await physics_frame
			var expected: Transform2D = presenter._weapon_basis_for(presenter.pose_index)
			peak = maxf(peak, expected.origin.y-presenter.weapon_rig.position.y)
			unit_scale = unit_scale and is_equal_approx(presenter.weapon_rig.transform.x.length(),1) and is_equal_approx(presenter.weapon_rig.transform.y.length(),1)
			phase_idle = phase_idle and actor.attack_component.phase==MeleeAttackComponent.Phase.IDLE
		check(peak>25,"Idle steel never rises above the palm")
		check(unit_scale,"Idle stretches or shrinks the straight scythe")
		check(phase_idle and get_nodes_in_group("returning_weapon_attacks").is_empty(),"Cosmetic toss starts a damage attack")
		check(not family.trail._idle_toss_active,"Idle keeps orbiting after its single catch")
		check(presenter.weapon_rig.transform.is_equal_approx(presenter._weapon_basis_for(presenter.pose_index)),"Caught weapon fails to reattach to the hand")
		presenter.cancel_presentation_transition()
		presenter._rest()
		while presenter.pose_index<3: await physics_frame
		check(actor.request_primary_attack(),"Toss blocks attack input")
		await create_timer(0.35).timeout
		check(not family.trail._idle_toss_active and actor.attack_component.phase!=MeleeAttackComponent.Phase.IDLE,"Attack cannot retrieve the tossed weapon")
		actor.attack_component.cancel_attack()
		actor._clear_buffered_action()
		presenter.cancel_presentation_transition()
		await physics_frame
	lab.queue_free()
	current_scene = null
	await process_frame
	print("IRON_REAPER_IDLE_SMOKE checks=",checks," failures=",failures)
	quit(1 if failures else 0)
