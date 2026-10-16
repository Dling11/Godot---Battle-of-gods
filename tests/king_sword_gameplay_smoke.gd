extends "res://tests/sanctuary_test_base.gd"

const LAB = preload("res://levels/combat_lab/combat_lab.tscn")
const ITEM = preload("res://data/items/equipment/king_signature_sword.tres")
const AXE = preload("res://data/items/equipment/king_iron_beard_axe.tres")
const GREAT = preload("res://data/items/equipment/king_royal_greatsword.tres")
const TARGET = preload("res://entities/training/training_target.tscn")
const OUT := "res://tmp/review/sword_unified_2026_10_16/gameplay/"
var evidence_path := OUT
var starts: Array[int] = []
var contacts: Array[Dictionary] = []
var ribbon_rows: Array[Dictionary] = []

func _initialize() -> void:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--output=res://tmp/review/"):
			evidence_path=argument.trim_prefix("--output=").trim_suffix("/")+"/"
	super._initialize()

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(evidence_path))
	root.size=Vector2i(1280,720)
	root.content_scale_size=root.size # Native pixel probes use this viewport's canvas coordinates.
	root.get_node("SaveService").configure_storage_path_for_testing("user://sword_gameplay_smoke.json")
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	var inventory := root.get_node("WeaponInventory")
	inventory.reset_inventory()
	root.get_node("RunSession").reset_run()
	var old_snapshot: Dictionary = inventory.create_snapshot()
	var lab := LAB.instantiate()
	root.add_child(lab)
	current_scene=lab
	await process_frame
	await process_frame
	lab.clear_simulation()
	await process_frame
	var actor: Player = lab.player
	actor.position=Vector2(350,300)
	check(inventory.owns_weapon(ITEM.item_id),"Fresh campaign lost its starter sword")
	await key(KEY_F9)
	check(inventory.owns_weapon(ITEM.item_id),"Normal F9 cannot grant Sword")
	check(root.get_node("SaveService")._debug_autosave_suppressed,"F9 no longer suppresses test-kit autosaving")
	actor.set_process_unhandled_input(false)
	actor.set_physics_process(false)
	var menu: CharacterMenu = lab.get_node("UI/CharacterMenu")
	await key(KEY_TAB)
	check(menu.is_visible_in_tree() and paused,"Training Tab does not open the visible Bag")
	menu._on_equipment_selected(ITEM)
	menu.equipment_detail_panel.equip_requested.emit(ITEM)
	check(actor.get_equipped_weapon_item()==ITEM and actor.attack_component.weapon==ITEM.weapon_definition,"Normal Bag cannot equip Sword")
	check(is_instance_valid(menu._family_portrait) and menu._family_portrait.offhand_rig==null,"Paper doll should show one equipped sword")
	await capture("training_bag.png")
	await key(KEY_ESCAPE)
	check(not paused and not menu.visible,"Closing Sword Bag leaves controls blocked")
	var attack := actor.attack_component
	var family := actor.get_node("WeaponFamilyPresentation")
	attack.attack_started.connect(func() -> void: starts.append(attack.combo_step))
	attack.hit_landed.connect(func(target: HurtboxComponent,_info: DamageInfo) -> void:
		contacts.append({"target":target.get_parent().get_instance_id(),"step":attack.combo_step})
	)
	for direction in [Vector2.RIGHT,Vector2.LEFT,Vector2.UP,Vector2.DOWN]:
		actor._set_facing_direction(direction)
		await physics_frame
		check(family.presenter.visible and not actor.get_node("VisualRoot/Body").visible,"Equipped pair draws two bodies")
		actor.velocity=direction*100
		await physics_frame
		var old_pose: int = family.presenter.pose_index
		actor.global_position+=direction*18
		await physics_frame
		check(family.presenter._running and family.presenter.definition==family.profile.run_for(direction) and family.presenter.pose_index!=old_pose,"Normal Player glides or uses the wrong running view")
		if absf(direction.x)>0:
			var main_guard: Vector2 = family.presenter.weapon_sprite.to_global(Vector2(10,55))

			var main_texture: Texture2D = family.presenter.weapon_sprite.texture

			check(main_texture.get_size()==Vector2(20,80),"Running substitutes or shrinks the new fixed-size blades")
			await capture("training_run_right.png" if direction.x>0 else "training_run_left.png")
			check(actor.request_primary_attack(),"Attack from side running rejected")
			check(family.presenter.weapon_sprite.to_global(Vector2(10,55)).distance_to(main_guard)<.01,"Run-to-attack entry changes the held blade offsets")
			check(family.presenter.weapon_sprite.texture==main_texture,"Run-to-attack opening changes canonical steel")
			await until_active(attack)
			check(family.presenter.weapon_sprite.texture==family.presenter.definition.weapon_texture and family.presenter.offhand_rig==null and not family.presenter.weapon_sprite.texture.get_image().get_region(Rect2i(0,59,20,21)).is_invisible(),"Attack loses the complete single sword after carry entry")
			actor._clear_buffered_action()
			attack.cancel_attack()
		actor.velocity=Vector2.ZERO
		await physics_frame
		check(family.presenter.definition==family.profile.idle_for(direction),"Running does not settle to the sword ready stance")
		attack.reset_combo()
		starts.clear()
		check(actor.request_primary_attack(),"Normal Sword primary input rejected")
		for step in 3:
			await until_active(attack)
			check(attack.combo_step==step and attack.get_attack_direction()==direction,"Buffered Sword chain changes step/facing")
			var root_clip: Resource = family.profile.attack_for(direction)
			check(family.presenter.definition==(root_clip if step==0 else root_clip.follow_up_clips[step-1]),"Normal chain misses its authored directional cel")
			check(family.trail.z_index==(0 if direction==Vector2.UP else 3),"Upward white arcs obscure the body")
			if direction==Vector2.RIGHT and step==2: await capture("training_finish.png")
			if DisplayServer.get_name()!="headless":
				await physics_frame
				await physics_frame
				await verify_slash(family,direction,step)
			if step<2:
				check(actor.request_primary_attack(),"Normal input cannot buffer the next Sword cut")
				await until_step(attack,step+1)
		await until_idle(attack)
		check(starts==[0,1,2] and actor._buffered_action==Player.BufferedAction.NONE,"Normal three-cut chain drops/repeats input")
	await verify_afterimage(actor,family)
	await verify_travel_and_rest(actor,family)
	actor._set_facing_direction(Vector2.RIGHT)
	var front := make_target(lab,actor.global_position+Vector2(52,0))
	var rear := make_target(lab,actor.global_position+Vector2(-45,0))
	var outside := make_target(lab,actor.global_position+Vector2(140,0))
	await physics_frame
	contacts.clear()
	attack.reset_combo()
	actor.request_primary_attack()
	for step in 3:
		await until_active(attack)
		if step<2:
			actor.request_primary_attack()
			await until_step(attack,step+1)
	await until_idle(attack)
	var unique := {}
	var rear_steps: Array[int] = []
	for hit in contacts:
		var id := "%d/%d"%[hit.target,hit.step]
		check(not unique.has(id),"One sword cut applies repeated damage to a target")
		unique[id]=true
		if hit.target==rear.get_instance_id(): rear_steps.append(hit.step)
	check(rear_steps.is_empty(),"Rear contact occurs outside the sword front-facing cuts")
	check(front.get_node("HealthComponent").current_health<10000 and outside.get_node("HealthComponent").current_health==10000,"Production contact ignores the reviewed reach")
	for target in [front,rear,outside]: target.queue_free()
	await process_frame
	# Use the normal skill inputs and their confirmation paths, then cancel.
	for slot in range(1,6):
		var ability := actor.get_ability_component_for_slot(slot)
		check(actor.request_ability(slot),"Equipped pair blocks skill input %d"%slot)
		if slot==1: actor._on_directional_targeting_confirmed(ability,Vector2.RIGHT)
		elif slot in [3,5]: actor._on_ground_targeting_confirmed(ability,actor.global_position+Vector2(24,0))
		await process_frame
		check(not family.presenter.visible and actor.get_node("VisualRoot/Body").visible,"Skill %d leaves duplicated weapon/body art"%slot)
		ability.cancel_cast()
		actor._cancel_all_targeting()
		await physics_frame
		await physics_frame
		check(not actor.is_any_ability_casting() and not actor.is_cinematic_locked() and family.presenter.visible,"Skill %d cannot return to the pair"%slot)
	check(actor.request_evade(Vector2.LEFT),"Sword blocks the normal dash")
	await process_frame
	check(not family.presenter.visible and actor.get_node("VisualRoot/Body").visible,"Dash duplicates the family body")
	actor.evade_component.cancel_evade()
	await physics_frame
	lab.set_player_invincible(false)
	actor.health_component.set_temporary_shield(0.0)
	check(actor.health_component.apply_damage(DamageInfo.new(1.0,lab,Vector2.RIGHT,0.0,.08)),"Training hit cannot reach the player health pipeline")
	await process_frame
	check(not family.presenter.visible,"Hit reaction does not hide the family body")
	var reaction_deadline := Time.get_ticks_msec()+1000
	while (actor.is_in_hit_recovery() or not family.presenter.visible) and Time.get_ticks_msec()<reaction_deadline:
		await physics_frame
	check(not actor.is_in_hit_recovery() and family.presenter.visible,"Hit recovery cannot restore Sword")
	lab.set_player_invincible(true)
	for item in [AXE,GREAT,ITEM,actor.weapon_catalog.default_weapon,ITEM]:
		check(actor.equip_owned_weapon(item),"Weapon switching rejected "+item.display_name)
		await process_frame
		check(family.profile==item.weapon_definition.family_presentation,"Weapon switch retains the previous family")
		var count := 0
		for child in actor.get_node("VisualRoot").get_children():
			if child.name=="FamilyBody": count+=1
		check(count==(0 if item.weapon_definition.family_presentation==null else 1),"Weapon switch leaks duplicate family nodes")
	var sword_snapshot: Dictionary = inventory.create_snapshot()
	check(inventory.can_restore_snapshot(sword_snapshot) and inventory.restore_snapshot(sword_snapshot),"Sword cannot round-trip an inventory snapshot")
	check(inventory.get_equipped_weapon_id(&"king",&"")==ITEM.item_id,"Snapshot loses equipped Sword")
	await capture("training_equipped.png")
	lab.queue_free()
	await process_frame
	await process_frame
	var stage := preload("res://levels/test_arena/test_arena.tscn").instantiate()
	root.add_child(stage)
	current_scene=stage
	await process_frame
	stage.player.set_physics_process(false)
	stage.player.set_process_unhandled_input(false)
	stage.player._set_facing_direction(Vector2.RIGHT)
	check(stage.player.attack_component.weapon==ITEM.weapon_definition and stage.player.get_node("WeaponFamilyPresentation").presenter.visible,"Normal Stage I loses the equipped pair")
	check(stage.player.request_primary_attack(),"Normal Stage I cannot use Sword")
	await until_active(stage.player.attack_component)
	await capture("stage_1_equipped.png")
	stage.player._clear_buffered_action()
	stage.player.attack_component.cancel_attack()
	stage.queue_free()
	await process_frame
	check(inventory.can_restore_snapshot(old_snapshot) and inventory.restore_snapshot(old_snapshot),"Pre-Sword inventory snapshots stopped restoring")
	FileAccess.open(evidence_path+"validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"training":true,"normal_stage":1,"skills":5,"art_modified_by_test":false,"ribbons":ribbon_rows},"\t")+"\n")
	print("SWORD_GAMEPLAY checks=%d failures=%d"%[checks,failures])
	quit(1 if failures else 0)

func make_target(lab: Node,point: Vector2) -> Node2D:
	var target: Node2D = TARGET.instantiate()
	lab.actors.add_child(target)
	target.global_position=point
	target.get_node("HealthComponent").set_maximum_health(10000,false)
	target.get_node("HealthComponent").set_current_health(10000)
	return target

func until_active(attack: MeleeAttackComponent) -> void:
	var deadline := Time.get_ticks_msec()+4000
	while attack.phase!=MeleeAttackComponent.Phase.ACTIVE and Time.get_ticks_msec()<deadline: await physics_frame
	check(attack.phase==MeleeAttackComponent.Phase.ACTIVE,"Timed out before contact")

func until_step(attack: MeleeAttackComponent,step: int) -> void:
	var deadline := Time.get_ticks_msec()+4000
	while (attack.combo_step!=step or attack.phase==MeleeAttackComponent.Phase.IDLE) and Time.get_ticks_msec()<deadline: await physics_frame
	check(attack.combo_step==step and attack.phase!=MeleeAttackComponent.Phase.IDLE,"Buffered continuation timed out")

func until_idle(attack: MeleeAttackComponent) -> void:
	var deadline := Time.get_ticks_msec()+4000
	while attack.phase!=MeleeAttackComponent.Phase.IDLE and Time.get_ticks_msec()<deadline: await physics_frame
	check(attack.phase==MeleeAttackComponent.Phase.IDLE,"Sword does not settle")

func key(code: Key) -> void:
	var event := InputEventKey.new()
	event.physical_keycode=code
	event.keycode=code
	event.pressed=true
	root.push_input(event)
	await process_frame
	event=event.duplicate()
	event.pressed=false
	root.push_input(event)
	await process_frame

func capture(file: String) -> void:
	if DisplayServer.get_name()=="headless": return
	await process_frame
	await RenderingServer.frame_post_draw
	check(root.get_texture().get_image().save_png(evidence_path+file)==OK,"Native capture failed")

func verify_travel_and_rest(actor: Player,family: Node) -> void:
	var directions: Array[Vector2]=[Vector2.LEFT,Vector2.RIGHT,Vector2.UP,Vector2.DOWN]
	var actions: Array[StringName]=[&"player_move_left",&"player_move_right",&"player_move_up",&"player_move_down"]
	actor.movement_bounds=Rect2(-5000,-5000,10000,10000)
	for index in 4:
		actor.position=Vector2(350,300)
		actor.velocity=Vector2.ZERO
		actor._set_facing_direction(directions[index])
		actor.set_physics_process(true)
		var seen: Dictionary={}
		Input.action_press(actions[index])
		for tick in 65:
			await physics_frame
			var rig: Node2D=family.presenter
			if rig._running and rig.definition==family.profile.run_for(directions[index]):
				seen[rig.pose_index]=true
				check(not rig.weapon_rig.visible and rig.offhand_rig==null,"Walking draws duplicate or extra steel")
				# Measure fixed points on the steel; a different grasp must not
				# change the material's size or be mistaken for rescaling.
				check(is_equal_approx(rig.weapon_sprite.to_global(Vector2(10,0)).distance_to(rig.weapon_sprite.to_global(Vector2(10,66))),33),"Running shrinks the canonical blade")
		check(seen.size()==8,"Actual movement skips whole run keys")
		Input.action_release(actions[index])
		actor.set_physics_process(false)
		actor.velocity=Vector2.ZERO
		var rig: Node2D=family.presenter
		var body: Image=rig.body_sprite.texture.get_image()
		check(actor.request_primary_attack(),"Run cannot enter a sword cut")
		check(rig.body_sprite.texture.get_image().get_data()==body.get_data(),"Run-to-attack entry flashes different anatomy")
		actor._clear_buffered_action()
		actor.attack_component.cancel_attack()
		await physics_frame
		await physics_frame
		var wall:=StaticBody2D.new()
		wall.collision_layer=1
		wall.collision_mask=0
		wall.position=actor.position+directions[index]*35
		var collider:=CollisionShape2D.new()
		var shape:=RectangleShape2D.new()
		shape.size=Vector2(4,160) if index<2 else Vector2(160,4)
		collider.shape=shape
		wall.add_child(collider)
		root.add_child(wall)
		await physics_frame
		actor.set_physics_process(true)
		Input.action_press(actions[index])
		for tick in 55: await physics_frame
		var origin:=actor.position
		var pose: int=rig.pose_index
		for tick in 10: await physics_frame
		check(actor.position.distance_to(origin)<.01 and actor.get_slide_collision_count()>0,"Real wall fixture did not block movement")
		check(rig.pose_index==pose,"Feet glide against a blocked wall")
		Input.action_release(actions[index])
		actor.velocity=Vector2.ZERO
		wall.queue_free()
		await physics_frame
		await physics_frame
		actor.set_physics_process(false)
		check(not rig._running and rig.definition==family.profile.idle_for(directions[index]),"Release fails to settle into same-size ready")
		rig._rest_timer.stop()
		rig._rest()
		await create_timer(1.15).timeout
		check(rig._resting and rig.pose_index>=10 and rig.pose_index<=11,"Sword inspection does not settle into a quiet guard")
		check(actor.request_primary_attack() and rig._drawing,"Idle cannot retrieve the held sword")
		await until_active(actor.attack_component)
		check(not rig._drawing and not rig._resting,"Quiet idle blocks normal input")
		actor._clear_buffered_action()
		actor.attack_component.cancel_attack()
		await physics_frame
		await physics_frame

func verify_afterimage(actor: Player,family: Node) -> void:
	var attack:=actor.attack_component
	for bonus in [0.0,.5]:
		attack.set_equipment_attack_speed_bonus(bonus)
		for direction in [Vector2.RIGHT,Vector2.LEFT,Vector2.UP,Vector2.DOWN]:
			actor._set_facing_direction(direction)
			attack.reset_combo()
			check(actor.request_primary_attack(),"Released afterimage attack cannot start")
			await until_active(attack)
			var deadline:=Time.get_ticks_msec()+1500
			while attack.phase==MeleeAttackComponent.Phase.ACTIVE and Time.get_ticks_msec()<deadline: await physics_frame
			check(attack.phase==MeleeAttackComponent.Phase.RECOVERY and family.trail.slash_sprite.visible,"Paint disappears at the contact boundary instead of following through")
			await create_timer(.085).timeout
			check(not family.trail.slash_sprite.visible,"Residual white stroke persists into released guard")
			await until_idle(attack)
			check(actor.request_primary_attack(),"Cancellation sample cannot start")
			await until_active(attack)
			actor._clear_buffered_action()
			attack.cancel_attack()
			check(not family.trail.slash_sprite.visible,"Cancelled cut leaves a frozen afterimage")
			await physics_frame
	attack.set_equipment_attack_speed_bonus(0.0)

func verify_slash(family: Node,direction: Vector2,step: int) -> void:
	if DisplayServer.get_name()=="headless": return
	var label := "right" if direction==Vector2.RIGHT else ("left" if direction==Vector2.LEFT else ("up" if direction==Vector2.UP else "down"))
	paused=true
	var trail: Node2D=family.trail
	var peak_white:=0
	for frame in 12:
		trail._set_frame(frame)
		await process_frame
		await RenderingServer.frame_post_draw
		var masked:=root.get_texture().get_image()
		trail.slash_sprite.material=null
		await process_frame
		await RenderingServer.frame_post_draw
		var raw:=root.get_texture().get_image()
		trail.slash_sprite.material=trail.contact_mask
		trail.hide()
		await process_frame
		await RenderingServer.frame_post_draw
		var none:=root.get_texture().get_image()
		var bright:=0
		var outside:=0
		var clipped:=0
		var inverse:=trail.get_global_transform_with_canvas().affine_inverse()
		var area:=Rect2()
		var transform: Transform2D=trail.slash_sprite.get_global_transform_with_canvas()
		for corner in [Vector2(-128,-128),Vector2(128,-128),Vector2(-128,128),Vector2(128,128)]:
			var point: Vector2=transform*corner
			area=Rect2(point,Vector2.ONE) if area.size==Vector2.ZERO else area.expand(point)
		var scan:=Rect2i(area.grow(2)).intersection(Rect2i(Vector2i.ZERO,masked.get_size()))
		for y in range(scan.position.y,scan.end.y):
			for x in range(scan.position.x,scan.end.x):
				var a:=masked.get_pixel(x,y)
				var b:=none.get_pixel(x,y)
				var c:=raw.get_pixel(x,y)
				if minf(a.r,minf(a.g,a.b))>.55 and a.r+a.g+a.b-b.r-b.g-b.b>.4:
					bright+=1
					if not Geometry2D.is_point_in_polygon(inverse*Vector2(x+.5,y+.5),trail._points): outside+=1
				if c.r+c.g+c.b-b.r-b.g-b.b>.4 and c.r+c.g+c.b-a.r-a.g-a.b>.2: clipped+=1
		check(bright>0,"Missing Sword painted stroke %s/%d/%d"%[label,step,frame])
		check(outside==0,"Sword stroke exceeds real contact")
		check(clipped==0,"Sword contact mask cuts painted stroke")
		if frame>=3 and frame<=6: peak_white=maxi(peak_white,bright)
		ribbon_rows.append({"view":label,"cut":step,"frame":frame,"bright":bright,"outside":outside,"clipped":clipped})
		trail.show()
	check(peak_white>=180,"Sword has no substantial bright contact frame in "+label)
	print("SWORD_RIBBONS ",label," cut=",step," frames=12")
	paused=false
