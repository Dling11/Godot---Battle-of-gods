extends "res://tests/sanctuary_test_base.gd"

## Real Player idle timers, retrieval, travel and swaps; no simulated authority.
const LAB = preload("res://levels/combat_lab/combat_lab.tscn")
const ITEM = preload("res://data/items/equipment/king_twinsteel.tres")
const GREAT = preload("res://data/items/equipment/king_royal_greatsword_v2.tres")
var output := "res://tmp/review/combat/king_dual_v2_ready_idle_2026_10_07/"

func _initialize() -> void:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--output="): output = argument.trim_prefix("--output=").trim_suffix("/")+"/"
	super._initialize()

func _run() -> void:
	root.size = Vector2i(1280,720)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output))
	root.get_node("SaveService").configure_storage_path_for_testing("user://dual_v2_idle_smoke.json")
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	root.get_node("WeaponInventory").reset_inventory()
	root.get_node("RunSession").reset_run()
	var lab := LAB.instantiate()
	root.add_child(lab)
	current_scene = lab
	await process_frame
	await process_frame
	lab.clear_simulation()
	var actor: Player = lab.player
	actor.apply_debug_testing_preset()
	actor.set_physics_process(false)
	actor.set_process_unhandled_input(false)
	actor.position = Vector2(350,300)
	check(actor.equip_owned_weapon(ITEM),"Live Twinsteel equip failed")
	var family := actor.get_node("WeaponFamilyPresentation")
	for direction in [Vector2.LEFT,Vector2.RIGHT,Vector2.UP,Vector2.DOWN]:
		actor.velocity = Vector2.ZERO
		actor._set_facing_direction(direction)
		await physics_frame
		var rig: Node2D = family.presenter
		check(rig.idle_definition.rest_start_pose==1 and rig.idle_definition.rest_transition_end_pose==4 and rig.idle_definition.rest_loop_window==Vector2(5,7),"New idle data not used in this facing")
		check_ready_pair(rig)
		rig._rest_timer.wait_time = .05
		rig._rest_timer.start()
		var deadline := Time.get_ticks_msec()+800
		while not rig._resting and Time.get_ticks_msec()<deadline: await physics_frame
		check(rig._resting,"Idle timer cannot begin dramatic rest")
		var entry_time := Time.get_ticks_msec()
		var entry_max_pose := 0
		while Time.get_ticks_msec()-entry_time<1200:
			entry_max_pose = maxi(entry_max_pose,rig.pose_index)
			await physics_frame
		check(entry_max_pose<=4,"Idle entry rushes through the head-glance cels")
		check(rig._resting and rig.pose_index==4,"Plant/fold transition does not settle facing center")
		var main_tip: Vector2 = rig.weapon_sprite.to_global(rig.definition.weapon_tip)
		var other_tip: Vector2 = rig.offhand_sprite.to_global(rig.definition.offhand.tip)
		check(absf(main_tip.y-(actor.global_position.y-1))<.1 and absf(other_tip.y-main_tip.y)<.1,"Planted pair floats or sinks below ground")
		check(absf(main_tip.x-other_tip.x)>=20,"Planted blades merge behind King")
		check(rig.definition.released_poses[rig.pose_index]>0,"Folded arms still claim sword grips")
		deadline = entry_time+6000
		while rig.pose_index==4 and Time.get_ticks_msec()<deadline: await physics_frame
		print("DUAL_IDLE_FIRST_GLANCE direction=",direction," elapsed_ms=",Time.get_ticks_msec()-entry_time," pose=",rig.pose_index)
		check(rig.pose_index==5 and Time.get_ticks_msec()-entry_time>=2400,"First head turn skips the calm center hold")
		var first: int = rig.pose_index
		await create_timer(.65).timeout
		check(rig.pose_index==first,"First glance is a fast flick instead of a slow exposure")
		await create_timer(.8).timeout
		check(rig.pose_index!=first and rig._resting,"Head does not glance during proud rest")
		check(actor.attack_component.phase==MeleeAttackComponent.Phase.IDLE,"Idle animation issues a combat attack")
		var view_name := "left" if direction==Vector2.LEFT else ("right" if direction==Vector2.RIGHT else ("up" if direction==Vector2.UP else "down"))
		await process_frame
		await RenderingServer.frame_post_draw
		check(root.get_texture().get_image().save_png(output+"idle_live_"+view_name+".png")==OK,"Native idle capture failed")
		actor.request_primary_attack()
		check(rig._drawing and not rig._running,"Attack does not retrieve the planted pair")
		deadline = Time.get_ticks_msec()+1200
		while actor.attack_component.phase!=MeleeAttackComponent.Phase.ACTIVE and Time.get_ticks_msec()<deadline: await physics_frame
		check(actor.attack_component.phase==MeleeAttackComponent.Phase.ACTIVE and not rig._drawing and not rig._resting,"Retrieval leaves primary input blocked")
		actor._clear_buffered_action()
		actor.attack_component.cancel_attack()
		await physics_frame
		rig._rest_timer.wait_time = 4.0
		actor.velocity = direction*100
		actor.global_position += direction*12
		await physics_frame
		check(rig._running and not rig._resting and not rig._rest_timer.time_left>0,"Travel leaves planted/head-loop presentation active")
		actor.velocity = Vector2.ZERO
		await physics_frame
		check(not rig._running and rig.definition==rig.idle_definition,"Movement cannot return to ready")
		check_ready_pair(rig)
		await process_frame
		await RenderingServer.frame_post_draw
		check(root.get_texture().get_image().save_png(output+"ready_live_"+view_name+".png")==OK,"Post-walk ready capture failed")
	# Cancel during the new neutral hold, before its delayed callback can start the loop.
	var resting_rig: Node2D = family.presenter
	resting_rig._rest_timer.wait_time = .05
	resting_rig._rest_timer.start()
	await create_timer(1.3).timeout
	check(resting_rig._resting and resting_rig.pose_index==4,"Neutral hold unavailable for cancellation")
	resting_rig._rest_timer.wait_time = 4.0
	actor.velocity = Vector2.DOWN*100
	actor.global_position += Vector2.DOWN*12
	await physics_frame
	await physics_frame
	check(resting_rig._running and not resting_rig._resting,"Movement does not cancel neutral hold")
	actor.velocity = Vector2.ZERO
	await physics_frame
	await physics_frame
	await create_timer(1.5).timeout
	check(not resting_rig._resting and resting_rig.pose_index==0,"Delayed head loop restarts after movement cancels idle")
	check(actor.equip_owned_weapon(GREAT),"Greatsword regression equip failed")
	await process_frame
	check(family.presenter.idle_definition.rest_start_pose==4 and family.presenter.idle_definition.rest_transition_end_pose==-1 and is_equal_approx(family.presenter.idle_definition.rest_transition_seconds,.48),"Dual rest changes accepted Greatsword idle")
	check(actor.equip_owned_weapon(ITEM),"Returning to Twinsteel fails")
	await process_frame
	check(family.profile==ITEM.weapon_definition.family_presentation,"Weapon swap retains wrong family")
	FileAccess.open(output+"idle_checks.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"scope":"Actual Player uncrossed post-walk ready, neutral idle entry, slow glance, retrieval, delayed cancellation and swap"},"\t")+"\n")
	lab.queue_free()
	await process_frame
	await process_frame
	print("DUAL_V2_IDLE checks=",checks," failures=",failures)
	quit(1 if failures else 0)

func check_ready_pair(rig: Node2D) -> void:
	check(rig.definition==rig.idle_definition and rig.pose_index==0,"Ready-pair check is not a post-travel carry pose")
	var near_grip: Vector2 = rig.weapon_sprite.to_global(rig.definition.weapon_primary_grip)
	var near_tip: Vector2 = rig.weapon_sprite.to_global(rig.definition.weapon_tip)
	var far_grip: Vector2 = rig.offhand_sprite.to_global(rig.definition.offhand.grip)
	var far_tip: Vector2 = rig.offhand_sprite.to_global(rig.definition.offhand.tip)
	check(Geometry2D.segment_intersects_segment(near_grip,near_tip,far_grip,far_tip)==null,"Ready blades cross after walking stops")
	check(near_tip.distance_to(far_tip)>near_grip.distance_to(far_grip),"Ready blades converge across King's chest")
