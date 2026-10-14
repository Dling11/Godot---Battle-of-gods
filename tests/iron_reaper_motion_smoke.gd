extends "res://tests/sanctuary_test_base.gd"

const LAB = preload("res://levels/combat_lab/combat_lab.tscn")
const ITEM = preload("res://data/items/equipment/king_iron_reaper.tres")

func _run() -> void:
	root.get_node("SaveService").configure_storage_path_for_testing("user://iron_reaper_motion_smoke.json")
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
	CombatFeedbackPresenter.find_for_player(actor).hitstop_enabled = false
	var family: Node = actor.get_node("WeaponFamilyPresentation")
	for direction in [Vector2.RIGHT,Vector2.LEFT,Vector2.UP,Vector2.DOWN]:
		for bonus in [0.0,0.5]:
			actor.position = Vector2(350,300)
			actor._set_facing_direction(direction)
			actor.attack_component.set_equipment_attack_speed_bonus(bonus)
			await physics_frame
			family.presenter._rest_timer.stop()
			for step in [0,1,2,3]:
				actor.attack_component.reset_combo()
				actor.attack_component._next_combo_step = step
				check(actor.request_primary_attack(),"Motion review cannot start a cut")
				var deadline := Time.get_ticks_msec()+3500
				var travel := 0.0
				var previous := 0.0
				var sampled := false
				var attached := true
				var unit_scale := true
				var flight_checked := false
				while actor.attack_component.phase!=MeleeAttackComponent.Phase.IDLE and Time.get_ticks_msec()<deadline:
					await physics_frame
					var presenter: Node2D = family.presenter
					var basis: Transform2D = presenter.weapon_rig.transform
					unit_scale = unit_scale and is_equal_approx(basis.x.length(),1) and is_equal_approx(basis.y.length(),1)
					if actor.attack_component.phase==MeleeAttackComponent.Phase.ACTIVE:
						var angle := basis.get_rotation()
						if sampled: travel += wrapf(angle-previous,-PI,PI)
						previous = angle
						sampled = true
						var grip: Vector2 = presenter.definition.primary_hands[presenter.pose_index]-Vector2(presenter.definition.cell_size)*0.5
						attached = attached and basis.origin.distance_to(grip)<0.01
						if step==2 and not flight_checked:
							var flight: Node2D = actor.attack_component.released_attack
							if is_instance_valid(flight):
								var visual: Node2D = flight.get_node("ReaperFlight")
								check(visual._has_hand_attachment,"Release loses the actor's hand reference")
								check(visual._steel_basis_for(0).is_equal_approx(visual._launch_basis),"Steel jumps away from the palm on release")
								check(visual._steel_basis_for(1).is_equal_approx(visual._hand_basis(7)),"Recall does not end at the catch hand")
								var fixed_size := true
								for progress in [0.0,0.05,0.1,0.3,0.7,0.9,0.97,1.0]:
									var steel: Transform2D = visual._steel_basis_for(progress)
									fixed_size = fixed_size and is_equal_approx(steel.x.length(),0.5) and is_equal_approx(steel.y.length(),0.5)
								check(fixed_size,"Launch or braking stretches the weapon")
								flight_checked = true
				check(actor.attack_component.phase==MeleeAttackComponent.Phase.IDLE,"Motion changes combo completion time or leaves an attack stuck")
				check(sampled and attached and unit_scale,"Swing loses its grip or deforms the weapon")
				if step in [0,3]: check(travel>deg_to_rad(65),"Downward cut has no meaningful angular travel")
				if step==1: check(travel<deg_to_rad(-65),"Return hook does not reverse the swing direction")
				if step==2: check(flight_checked,"Throw never produces its released raster")
				print("REAPER_MOTION direction=",direction," speed=",bonus," cut=",step," active_degrees=",rad_to_deg(travel))
				actor._clear_buffered_action()
				family.presenter.cancel_presentation_transition()
				family.presenter._rest_timer.stop()
	lab.queue_free()
	current_scene = null
	await process_frame
	print("IRON_REAPER_MOTION checks=",checks," failures=",failures)
	quit(1 if failures else 0)
