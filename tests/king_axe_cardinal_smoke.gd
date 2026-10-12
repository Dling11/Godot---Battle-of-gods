extends "res://tests/king_art_test_base.gd"

const PLAYER = preload("res://entities/player/player.tscn")
var WEAPON: WeaponDefinition = preload("res://data/weapons/king_iron_beard_axe.tres")
var PROFILE: Resource = preload("res://data/weapons/families/iron_beard/presentation.tres")
const Presenter = preload("res://gameplay/presentation/weapon_family_pose_presenter.gd")
const AXE = preload("res://assets/characters/playable/king/axe_proof/iron_beard.png")
const DIRECTIONS := [Vector2.UP,Vector2.DOWN,Vector2.RIGHT,Vector2.LEFT,Vector2.UP,Vector2.DOWN]
const LOCATIONS := [Vector2(235,250),Vector2(780,250),Vector2(235,650),Vector2(780,650),Vector2(105,940),Vector2(205,940)]
var output := "res://tmp/review/combat/king_axe_head_thrust_2026_10_06/"
var actors: Array[Player] = []
var starts: Array[Array] = [[],[],[],[],[],[]]
var timeline: Array[Dictionary] = []
var images: Array[Image] = []
var verified_slashes: Array[int] = []
var verified_thrust := false
var verified_fresh_contacts: Array[int] = []

func _initialize() -> void:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--output=res://tmp/review/"): output=argument.trim_prefix("--output=").trim_suffix("/")+"/"
		if argument.begins_with("--profile=res://"):
			PROFILE = load(argument.trim_prefix("--profile="))
			WEAPON = WEAPON.duplicate(true)
			WEAPON.family_presentation = PROFILE
	super._initialize()

func _run() -> void:
	root.get_node("SaveService").configure_storage_path_for_testing("user://axe_flow_proof.json")
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	check(PROFILE.is_valid_profile(),"Axe complete direction profile rejected")
	var edge_pixel := AXE.get_image().get_pixel(8,30)
	check(edge_pixel.a>.9 and minf(edge_pixel.r,minf(edge_pixel.g,edge_pixel.b))>.8,"Head-push landmark is not on the actual white cutting edge")
	check(PROFILE.attack_poses.resource_path.ends_with("axe_flow/side/chop.tres") or PROFILE.attack_poses.resource_path.ends_with("shared_bodies/axe/side/chop.tres"),"Axe does not start with the accepted downward chop")
	check(PROFILE.running_poses.resource_path.ends_with("greatsword_confidence_v2/axe_run.tres") or PROFILE.running_poses.body_atlas.resource_path.ends_with("body_library/v1/side_run_body.png"),"Axe gait does not use the accepted body")
	var seconds := 0.0
	for step in WEAPON.combo.step_count(): seconds+=WEAPON.combo.windups[step]+WEAPON.combo.contacts[step]+WEAPON.combo.recoveries[step]
	check(is_equal_approx(seconds,3.19),"Accepted faster five-hit axe clock changed")
	for direction in [Vector2.UP,Vector2.DOWN]: _validate_art(direction)
	if _fresh_vertical(): _validate_fresh_vertical()
	if "--art-only" in OS.get_cmdline_user_args():
		print("AXE_FLOW_ART checks=%d failures=%d"%[checks,failures])
		quit(1 if failures else 0)
		return
	root.size=Vector2i(1080,1040)
	root.content_scale_size=root.size
	var background := ColorRect.new()
	background.size=Vector2(root.size)
	background.color=Color("263339")
	root.add_child(background)
	for spec in [[Vector2(25,15),"IRON BEARD / UP - BACK"],[Vector2(565,15),"DOWN - FRONT"],[Vector2(25,415),"RIGHT"],[Vector2(565,415),"LEFT"],[Vector2(25,815),"Actual game size"],[Vector2(450,815),"Back-stowed native gait"]]:
		var label := Label.new()
		label.position=spec[0]
		label.text=spec[1]
		root.add_child(label)
	for index in 6:
		var actor: Player = PLAYER.instantiate()
		actor.position=LOCATIONS[index]
		actor.scale=Vector2.ONE*(2.2 if index<4 else 1.0)
		actor.movement_bounds=Rect2(0,0,2200,1400)
		root.add_child(actor)
		actor.set_physics_process(false)
		actor.set_process_unhandled_input(false)
		check(actor.set_weapon_definition(WEAPON),"Actual Player rejected axe")
		actor._set_facing_direction(DIRECTIONS[index])
		actor.attack_component.attack_started.connect(func() -> void: starts[index].append(actor.attack_component.combo_step))
		actors.append(actor)
	var runners: Array[Node2D] = []
	var dummy := MeleeAttackComponent.new()
	root.add_child(dummy)
	for index in 2:
		var p := Presenter.new()
		var direction: Vector2 = Vector2.UP if index==0 else Vector2.DOWN
		check(p.configure(PROFILE.run_for(direction),dummy,false),"Gait registration rejected")
		p.position=Vector2(650+index*215,940)
		p.scale=Vector2.ONE*1.8
		root.add_child(p)
		p.play_locomotion(PROFILE.run_for(direction),.36,true)
		runners.append(p)
	await physics_frame
	for index in 6:
		var family := actors[index].get_node("WeaponFamilyPresentation")
		check(family.presenter.visible and not actors[index].get_node("VisualRoot/Body").visible,"Vertical axe still falls back to original sword")
		check(family.presenter.definition==PROFILE.idle_for(DIRECTIONS[index]),"Idle uses wrong facing")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output+"motion_frames/"))
	for frame in 132:
		if frame==8:
			for actor in actors: check(actor.request_primary_attack(),"Actual primary input rejected")
		for actor in actors:
			var attack := actor.attack_component
			if attack.phase==MeleeAttackComponent.Phase.ACTIVE and attack.combo_step<WEAPON.combo.step_count()-1 and actor._buffered_action==Player.BufferedAction.NONE:
				check(actor.request_primary_attack(),"Actual next axe cut cannot buffer")
		for p in runners: p.advance_locomotion(3.6)
		await process_frame
		await process_frame
		await RenderingServer.frame_post_draw
		images.append(root.get_texture().get_image())
		var states: Array[Dictionary] = []
		for index in 6:
			var family := actors[index].get_node("WeaponFamilyPresentation")
			var attack := actors[index].attack_component
			var p: Node2D = family.presenter
			check(p.visible and p.weapon_sprite.texture==AXE,"Axe disappears or changes weapon while attacking")
			var expected: Resource = PROFILE.idle_for(DIRECTIONS[index])
			if attack.phase!=MeleeAttackComponent.Phase.IDLE:
				var clips: Resource = PROFILE.attack_for(DIRECTIONS[index])
				expected=clips if attack.combo_step==0 else clips.follow_up_clips[attack.combo_step-1]
			check(p.definition==expected,"Attack body belongs to another direction/cut")
			if attack.phase==MeleeAttackComponent.Phase.ACTIVE and PROFILE.swing_scene.resource_path.ends_with("axe_identity_lock_swing.tscn"):
				var trail: Node2D = family.trail
				if absf(DIRECTIONS[index].x)>.5 or attack.combo_step!=3:
					check(trail.world_origin==Vector2(0,-16),"Landing registration shifted an accepted non-landing effect")
			states.append({"direction":var_to_str(DIRECTIONS[index]),"step":attack.combo_step,"phase":attack.phase,"pose":p.pose_index})
		timeline.append({"frame":frame,"file":"motion_frames/frame_%03d.png"%frame,"elapsed_ms":roundi(frame*1000.0/30.0),"actors":states})
		var attack := actors[0].attack_component
		if attack.phase==MeleeAttackComponent.Phase.ACTIVE:
			var pose: int = actors[0].get_node("WeaponFamilyPresentation").presenter.pose_index
			if pose==5:
				if _fresh_vertical() and attack.combo_step not in verified_fresh_contacts:
					verified_fresh_contacts.append(attack.combo_step)
					for index in [0,1]:
						var trail: Node2D = actors[index].get_node("WeaponFamilyPresentation").trail
						var view := "up" if index==0 else "down"
						check(trail.atlas.resource_path.ends_with("axe_vertical_v2/"+view+"/swing.png") and not trail.rotate_vertical_sampling,"Fresh vertical contact reuses rotated side artwork")
						check(trail._row==attack.combo_step and trail._frame>=0,"Fresh camera effect is missing or belongs to another cut")
						if attack.combo_step==3:
							var p: Node2D = actors[index].get_node("WeaponFamilyPresentation").presenter
							var blade := actors[index].to_local(p.weapon_sprite.to_global(Vector2(8,30)))
							var raster: Image = trail.atlas.get_image().get_region(Rect2i(trail._frame*192,3*192,192,192))
							var center: Vector2 = trail.world_origin+(Vector2(raster.get_used_rect().get_center())-trail.origins[3])*trail.world_pixels_per_texel
							check(blade.dot(DIRECTIONS[index])>5 and blade.distance_to(center)<22,"Jump landing blade misses its camera-authored impact or strikes behind King")
				if attack.combo_step in [0,3] and attack.combo_step not in verified_slashes:
					verified_slashes.append(attack.combo_step)
					await _verify_complete_slashes()
				if attack.combo_step==2 and not verified_thrust:
					verified_thrust = true
					await _verify_head_thrust()
	check(verified_slashes.size()==2 and verified_thrust,"Native proof missed chop, thrust or jump contact")
	if _fresh_vertical(): check(verified_fresh_contacts.size()==5,"Fresh native preview omitted a vertical contact")
	for index in 6:
		check(starts[index]==[0,1,2,3,4],"Actual axe chain dropped or repeated a cut")
		check(actors[index].attack_component.phase==MeleeAttackComponent.Phase.IDLE,"Actual combo did not settle")
	for index in images.size(): check(images[index].save_png(output+"motion_frames/frame_%03d.png"%index)==OK,"Native animation capture failed")
	FileAccess.open(output+"motion_timeline.json",FileAccess.WRITE).store_string(JSON.stringify(timeline,"\t")+"\n")
	# Real production gait must freeze without travel, then change with travel.
	var actor := actors[0]
	var family := actor.get_node("WeaponFamilyPresentation")
	for direction in [Vector2.UP,Vector2.DOWN]:
		actor._set_facing_direction(direction)
		actor.velocity=direction*80
		await physics_frame
		var pose: int = family.presenter.pose_index
		await create_timer(.12).timeout
		check(family.presenter.pose_index==pose,"Axe gait glides while blocked")
		actor.position+=direction*12
		await physics_frame
		await physics_frame
		check(family.presenter._running and family.presenter.definition==PROFILE.run_for(direction) and family.presenter.pose_index!=pose,"Native vertical gait does not follow resolved travel")
		actor.velocity=Vector2.ZERO
		await physics_frame
		family.presenter._rest_timer.stop()
		family.presenter._rest()
		await create_timer(.65).timeout
		check(family.presenter._resting and family.presenter.definition.stowed_poses[family.presenter.pose_index]>0,"Vertical AFK axe is not back-stowed")
		check(actor.request_primary_attack() and family.presenter._drawing,"Vertical back stow does not retrieve before attacking")
		await create_timer(.34).timeout
		check(actor.attack_component.phase!=MeleeAttackComponent.Phase.IDLE,"Axe draw loses the real attack")
		actor.attack_component.cancel_attack()
		family.presenter.cancel_presentation_transition()
	for actor_node in actors: actor_node.queue_free()
	for p in runners: p.queue_free()
	dummy.queue_free()
	await process_frame
	FileAccess.open(output+"validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"frames":images.size(),"chain_seconds":seconds,"directions":4,"actual_player":true},"\t")+"\n")
	print("AXE_FLOW checks=%d failures=%d"%[checks,failures])
	quit(1 if failures else 0)

func _verify_complete_slashes() -> void:
	# Same frozen actual Player, full raster versus the previous fan crop.
	# Prove the restored white pixels render, including mirrored/vertical views.
	paused=true
	await process_frame
	await RenderingServer.frame_post_draw
	var complete := root.get_texture().get_image()
	var cut: int = actors[0].attack_component.combo_step
	complete.save_png(output+"complete_slash_%d.png"%cut)
	for actor in actors:
		var trail: Node2D = actor.get_node("WeaponFamilyPresentation").trail
		trail.full_frame_rows=PackedByteArray()
		trail._prepare_contact_shape()
		trail.prepare_edge_feather()
		trail.queue_redraw()
	await process_frame
	await RenderingServer.frame_post_draw
	var cropped := root.get_texture().get_image()
	cropped.save_png(output+"cropped_comparison_%d.png"%cut)
	var records: Array[Dictionary] = []
	for index in 4:
		var origin := Vector2i(0 if index%2==0 else 540,0 if index<2 else 400)
		var restored := 0
		for y in range(origin.y,origin.y+400):
			for x in range(origin.x,origin.x+540):
				var a := complete.get_pixel(x,y)
				var b := cropped.get_pixel(x,y)
				if minf(a.r,minf(a.g,a.b))>.55 and a.r+a.g+a.b-b.r-b.g-b.b>.4: restored+=1
		check(restored>30,"Complete white crescent still cropped: "+var_to_str(DIRECTIONS[index]))
		check(actors[index].attack_component.phase==MeleeAttackComponent.Phase.ACTIVE and cut in [0,3],"Full slash proof captures the wrong cut")
		records.append({"direction":var_to_str(DIRECTIONS[index]),"cut":cut,"restored_white_pixels":restored})
	for actor in actors:
		var trail: Node2D = actor.get_node("WeaponFamilyPresentation").trail
		trail.full_frame_rows=PROFILE.swing_full_frame_rows
		trail.prepare_edge_feather()
		trail.queue_redraw()
	FileAccess.open(output+"slash_validation_%d.json"%cut,FileAccess.WRITE).store_string(JSON.stringify(records,"\t")+"\n")
	paused=false

func _verify_head_thrust() -> void:
	paused=true
	await process_frame
	await RenderingServer.frame_post_draw
	var with_fx := root.get_texture().get_image()
	with_fx.save_png(output+"head_thrust_contact.png")
	var records: Array[Dictionary] = []
	for index in 4:
		var actor: Player = actors[index]
		var presenter: Node2D = actor.get_node("WeaponFamilyPresentation").presenter
		var edge := actor.to_local(presenter.weapon_sprite.to_global(Vector2(8,30)))
		var grip := actor.to_local(presenter.weapon_rig.global_position)
		var butt := actor.to_local(presenter.weapon_sprite.to_global(Vector2(46,62)))
		var blade_direction := (edge-grip).normalized()
		check(actor.attack_component.phase==MeleeAttackComponent.Phase.ACTIVE and actor.attack_component.combo_step==2,"Head thrust proof is not the third hit")
		check(blade_direction.dot(DIRECTIONS[index])>.99,"Axe cutting edge does not lead its forward push")
		check((edge-butt).dot(DIRECTIONS[index])>18,"Thrust presents the axe handle instead of its head")
		var body: Image = presenter.body_sprite.texture.get_image()
		var hand: Vector2i = Vector2i(presenter.definition.primary_hands[presenter.pose_index].round())
		check(body.get_pixelv(hand).a>.65,"Axe-head push lost its real glove")
		records.append({"direction":var_to_str(DIRECTIONS[index]),"blade_forward_dot":blade_direction.dot(DIRECTIONS[index]),"head_ahead_of_butt_pixels":(edge-butt).dot(DIRECTIONS[index])})
	for actor in actors: actor.get_node("WeaponFamilyPresentation").trail.hide()
	await process_frame
	await RenderingServer.frame_post_draw
	var without_fx := root.get_texture().get_image()
	without_fx.save_png(output+"head_thrust_without_fx.png")
	for index in 4:
		var origin := Vector2i(0 if index%2==0 else 540,0 if index<2 else 400)
		var bright := 0
		for y in range(origin.y,origin.y+400):
			for x in range(origin.x,origin.x+540):
				var a := with_fx.get_pixel(x,y)
				var b := without_fx.get_pixel(x,y)
				if minf(a.r,minf(a.g,a.b))>.55 and a.r+a.g+a.b-b.r-b.g-b.b>.4: bright+=1
		check(bright>1000,"Head thrust white impact is still a tiny needle: "+var_to_str(DIRECTIONS[index]))
		records[index].bright_effect_pixels=bright
	for actor in actors: actor.get_node("WeaponFamilyPresentation").trail.show()
	FileAccess.open(output+"head_thrust_validation.json",FileAccess.WRITE).store_string(JSON.stringify(records,"\t")+"\n")
	paused=false

func _validate_art(direction: Vector2) -> void:
	var attack: Resource = PROFILE.attack_for(direction)
	var all: Array[Resource] = [attack]
	all.append_array(attack.follow_up_clips)
	check(all.size()==5,"Vertical axe omitted a cut")
	for index in range(1,all.size()):
		var previous: Resource = all[index-1]
		var next: Resource = all[index]
		var endpoint_key := int(previous.queued_recovery_window.y)
		var endpoint := Rect2i(endpoint_key%4*192,endpoint_key/4*128,192,128)
		check(same_opaque(previous.body_atlas.get_image().get_region(endpoint),next.body_atlas.get_image().get_region(Rect2i(0,0,192,128))),"Queued axe body resets before its next cut")
		check(previous.primary_hands[endpoint_key]==next.primary_hands[0] and previous.secondary_hands[endpoint_key]==next.secondary_hands[0] and previous.lift_pixels[endpoint_key]==next.lift_pixels[0],"Queued axe grip/lift jumps at the next cut")
	for clip in all:
		check(clip.has_valid_layout() and clip.weapon_texture==AXE,"Vertical pose/rig invalid")
		for key in clip.pose_count:
			var body: Image = clip.body_atlas.get_image().get_region(Rect2i(key%4*192,key/4*128,192,128))
			var head: Rect2i = Rect2i(clip.identity_regions[key])
			check(body.get_used_rect().end.y==95,"Attack soles do not share the94 plane")
			check(body.get_used_rect().size.y<=78 and body.get_used_rect().size.y>=42,"Axe body has changed scale: "+clip.resource_path+" key"+str(key)+" bounds"+str(body.get_used_rect())+" head"+str(head))
			check(head.size in [Vector2i(25,24),Vector2i(27,29),Vector2i(27,27)],"Head differs from frozen camera references")
			var c := body.get_pixelv(Vector2i(clip.primary_hands[key].round()))
			var occluded: bool = clip.hands_are_occluded(key)
			check(occluded or (c.a>.65 and c.r>.18 and c.r<.80 and c.r>c.g*1.35 and c.g>c.b*1.25),"Axe hilt is not attached to a real brown glove")
			check(anatomy_connected(body,Vector2i(head.get_center()) if occluded else Vector2i(clip.primary_hands[key].round()),head),"Axe glove/head is disconnected from the torso: "+clip.resource_path+" key"+str(key))
	var idle: Resource = PROFILE.idle_for(direction)
	var ready: Image = idle.body_atlas.get_image().get_region(Rect2i(0,0,192,128))
	check(absi(ready.get_used_rect().size.y-54)<=1,"Axe ready shrinks relative to approved King baseline")
	for clip in all:
		var endpoint_key := int(clip.phase_windows[2].y)
		var endpoint := Rect2i(endpoint_key%4*192,endpoint_key/4*128,192,128)
		check(same_opaque(clip.body_atlas.get_image().get_region(endpoint),ready),"Released axe does not return to the exact registered ready body")
		check(clip.primary_hands[endpoint_key]==idle.primary_hands[0] and clip.secondary_hands[endpoint_key]==idle.secondary_hands[0],"Released grip does not meet ready grip")
	var gait: Resource = PROFILE.run_for(direction)
	var first: Image = gait.body_atlas.get_image().get_region(Rect2i(0,0,192,128))
	if PROFILE.running_poses.resource_path.contains("shared_bodies/"):
		var great: Resource = load("res://data/weapons/families/royal_greatsword_v2/presentation.tres")
		check(same_opaque(gait.body_atlas.get_image(),great.run_for(direction).body_atlas.get_image()),"Axe run differs from the complete canonical body cycle")
	else: check(absi(first.get_used_rect().size.y-54)<=1,"Axe run changes approved body baseline")
	var stride_keys := 0
	for key in 8:
		var rectangle := Rect2i(key%4*192,key/4*128,192,128)
		var cel: Image = gait.body_atlas.get_image().get_region(rectangle)
		if not same_opaque(first,cel): stride_keys += 1
		var head := Rect2i(gait.identity_regions[key])
		check(head.size==Vector2i(25,24) if direction==Vector2.UP else head.size==Vector2i(27,29),"Walking head density drifts")
		check(anatomy_connected(cel,Vector2i(head.get_center()),head),"Walking head/body disconnects")
		check(gait.stowed_poses[key]>0 and gait.weapon_behind_body[key]==(0 if direction==Vector2.UP else 1),"Back mount is on the wrong physical side")
	check(stride_keys>=6,"Axe walk lost its authored stride keys")

func _fresh_vertical() -> bool:
	return PROFILE.attack_for(Vector2.UP).resource_path.contains("axe_vertical_v2/") or PROFILE.attack_for(Vector2.UP).resource_path.contains("axe_identity_lock/") or PROFILE.attack_for(Vector2.UP).resource_path.contains("shared_bodies/axe/")

func _validate_fresh_vertical() -> void:
	check(PROFILE.swing_scene.resource_path.ends_with("axe_vertical_v2_swing.tscn") or PROFILE.swing_scene.resource_path.ends_with("axe_identity_lock_swing.tscn"),"Fresh axe profile has no camera-specific effects")
	for direction in [Vector2.UP,Vector2.DOWN]:
		var clips: Resource = PROFILE.attack_for(direction)
		var jump: Resource = clips.follow_up_clips[2]
		var spin: Resource = clips.follow_up_clips[3]
		check(jump.lift_pixels[2]<=-9 and jump.lift_pixels[3]<=-13,"Fresh jump has no visible airborne loading")
		for key in range(4,10): check(jump.lift_pixels[key]==0,"Jump impact starts before the body lands")
		var distinct: Array[Image] = []
		var rear := false
		var front := false
		for key in range(1,10):
			var cel: Image = spin.body_atlas.get_image().get_region(Rect2i(key%4*192,key/4*128,192,128))
			var new_cel := true
			for previous in distinct:
				if same_opaque(cel,previous): new_cel=false; break
			if new_cel: distinct.append(cel)
			rear = rear or spin.weapon_behind_body[key]>0
			front = front or spin.weapon_behind_body[key]==0
		check(distinct.size()>=6 and rear and front,"Spin does not turn its complete body through front/side/back")
		var view := "up" if direction==Vector2.UP else "down"
		var effect: Texture2D = load("res://assets/characters/playable/king/axe_vertical_v2/"+view+"/swing.png")
		for row in 5:
			for frame in 4:
				var bounds := effect.get_image().get_region(Rect2i(frame*192,row*192,192,192)).get_used_rect()
				check(bounds.position.x>=6 and bounds.position.y>=6 and bounds.end.x<=186 and bounds.end.y<=186,"Fresh effect touches an adjacent atlas cell")
				check(bounds.size.x>bounds.size.y and bounds.size.x>80,"Fresh vertical effect lost ground perspective or broad reach")
