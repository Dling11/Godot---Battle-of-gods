extends "res://tests/sanctuary_test_base.gd"

## Actual Player idle timing, held steel, interruption and normal equipment.
const LAB=preload("res://levels/combat_lab/combat_lab.tscn")
const ITEM=preload("res://data/items/equipment/king_twinsteel.tres")
const GREAT=preload("res://data/items/equipment/king_royal_greatsword.tres")
var output:="res://tmp/review/twinsteel_unified_2026_10_16/idle/"

func _initialize() -> void:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--output="): output=argument.trim_prefix("--output=").trim_suffix("/")+"/"
	super._initialize()

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(output)
	root.get_node("SaveService").configure_storage_path_for_testing("user://twinsteel_idle_smoke.json")
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	root.get_node("WeaponInventory").reset_inventory()
	root.get_node("RunSession").reset_run()
	var lab:=LAB.instantiate()
	root.add_child(lab)
	current_scene=lab
	await process_frame
	await process_frame
	lab.clear_simulation()
	var actor: Player=lab.player
	actor.apply_debug_testing_preset()
	actor.set_physics_process(false)
	actor.set_process_unhandled_input(false)
	actor.position=Vector2(350,300)
	check(actor.equip_owned_weapon(ITEM),"Normal Twinsteel equip failed")
	var family:=actor.get_node("WeaponFamilyPresentation")
	for direction in [Vector2.LEFT,Vector2.RIGHT,Vector2.UP,Vector2.DOWN]:
		actor.velocity=Vector2.ZERO
		actor._set_facing_direction(direction)
		await physics_frame
		var rig: Node2D=family.presenter
		var idle: Resource=rig.idle_definition
		check(idle.pose_count==16 and idle.rest_start_pose==4 and idle.rest_transition_end_pose==10,"New flourish is not routed in this facing")
		check(idle.rest_loop_window==Vector2(10,15) and idle.retrieval_start_pose==10,"Rest retrieval includes slow head-glance keys")
		check_ready_pair(rig)
		rig._rest_timer.wait_time=.05
		rig._rest_timer.start()
		await create_timer(1.25).timeout
		check(rig._resting and rig.pose_index==10,"Flourish fails to settle into neutral guard")
		check(actor.attack_component.phase==MeleeAttackComponent.Phase.IDLE,"Idle accidentally issues an attack")
		check(not rig.weapon_rig.visible and not rig.offhand_rig.visible,"Held idle duplicates the baked swords")
		check(idle.released_poses[rig.pose_index]==0 and idle.planting==null,"New held guard uses the old planting mechanic")
		for pair in [[rig.weapon_sprite,idle.weapon_primary_grip,idle.weapon_tip],[rig.offhand_sprite,idle.offhand.grip,idle.offhand.tip]]:
			var sprite: Sprite2D=pair[0]
			check(is_equal_approx(sprite.to_global(pair[1]).distance_to(sprite.to_global(pair[2])),28),"Idle rescales canonical steel")
		await create_timer(1.5).timeout
		check(rig._resting and rig.pose_index>=10 and rig.pose_index<=11,"Initial glance rushes through the quiet loop")
		var first: int=rig.pose_index
		await create_timer(.35).timeout
		check(rig.pose_index==first,"A quiet glance is only a flick")
		if DisplayServer.get_name()!="headless":
			await process_frame
			await RenderingServer.frame_post_draw
			check(root.get_texture().get_image().save_png(output+"rest_"+str(direction)+".png")==OK,"Native idle capture failed")
		var requested:=Time.get_ticks_msec()
		check(actor.request_primary_attack() and rig._drawing,"Primary input cannot retrieve from rest")
		var deadline:=requested+1200
		while actor.attack_component.phase!=MeleeAttackComponent.Phase.ACTIVE and Time.get_ticks_msec()<deadline: await physics_frame
		check(actor.attack_component.phase==MeleeAttackComponent.Phase.ACTIVE and not rig._drawing and not rig._resting,"Retrieval blocks the attack")
		check(Time.get_ticks_msec()-requested<800,"Slow glance frames delay retrieval")
		actor._clear_buffered_action()
		actor.attack_component.cancel_attack()
		await physics_frame
		rig._rest_timer.wait_time=4.0
		actor.velocity=direction*100
		actor.global_position+=direction*12
		await physics_frame
		check(rig._running and not rig._resting,"Walking cannot interrupt the flourish")
		actor.velocity=Vector2.ZERO
		await physics_frame
		check(not rig._running and rig.definition==rig.idle_definition,"Walking does not restore ready")
		check_ready_pair(rig)
	var rig: Node2D=family.presenter
	rig._rest_timer.wait_time=.05
	rig._rest_timer.start()
	await create_timer(.35).timeout
	check(rig._resting,"Entry cancellation fixture did not start")
	rig._rest_timer.wait_time=4.0
	actor.velocity=Vector2.DOWN*100
	actor.global_position+=Vector2.DOWN*12
	await physics_frame
	await physics_frame
	check(rig._running and not rig._resting,"Movement did not cancel the actual idle entry")
	actor.velocity=Vector2.ZERO
	await physics_frame
	await physics_frame
	await create_timer(1.4).timeout
	check(not rig._resting and rig.pose_index==0,"Delayed idle loop reappears after movement cancels it")
	check(actor.equip_owned_weapon(GREAT),"Greatsword regression equip failed")
	await process_frame
	check(family.presenter.idle_definition.rest_start_pose==4 and family.presenter.idle_definition.rest_transition_end_pose==11 and family.presenter.idle_definition.planting==null,"Twinsteel changes accepted Greatsword rest")
	check(actor.equip_owned_weapon(ITEM),"Returning to Twinsteel failed")
	await process_frame
	check(family.profile==ITEM.weapon_definition.family_presentation,"Swap retains wrong family")
	FileAccess.open(output+"validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"scope":"Actual four-direction Player ready/flourish/slow guard/retrieve, travel cancellation and swaps"},"\t")+"\n")
	lab.queue_free()
	await process_frame
	await process_frame
	print("TWINSTEEL_IDLE checks=",checks," failures=",failures)
	quit(1 if failures else 0)

func check_ready_pair(rig: Node2D) -> void:
	check(rig.definition==rig.idle_definition and rig.pose_index==0,"Ready-pair check is not on ready")
	var near_grip: Vector2=rig.weapon_sprite.to_global(rig.definition.weapon_primary_grip)
	var near_tip: Vector2=rig.weapon_sprite.to_global(rig.definition.weapon_tip)
	var far_grip: Vector2=rig.offhand_sprite.to_global(rig.definition.offhand.grip)
	var far_tip: Vector2=rig.offhand_sprite.to_global(rig.definition.offhand.tip)
	check(Geometry2D.segment_intersects_segment(near_grip,near_tip,far_grip,far_tip)==null,"Post-travel ready blades cross")
	check(near_tip.distance_to(far_tip)>8,"Ready sword tips merge")
