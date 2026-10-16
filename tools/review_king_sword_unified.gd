extends SceneTree

## Native footage of actual equipped Players, phases and family rendering.
const PLAYER=preload("res://entities/player/player.tscn")
const ITEM=preload("res://data/items/equipment/king_signature_sword.tres")
var output:="res://tmp/review/sword_unified_2026_10_16/native/"

func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--output="): output=arg.trim_prefix("--output=").trim_suffix("/")+"/"
	_run.call_deferred()

func _run() -> void:
	root.size=Vector2i(960,640)
	root.content_scale_size=root.size
	root.content_scale_mode=Window.CONTENT_SCALE_MODE_DISABLED
	RenderingServer.set_default_clear_color(Color("1b262c"))
	root.get_node("SaveService").configure_storage_path_for_testing("user://twinsteel_motion_review.json")
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	root.get_node("RunSession").reset_run()
	var actors: Array[Player]=[]
	var directions: Array[Vector2]=[Vector2.RIGHT,Vector2.LEFT,Vector2.UP,Vector2.DOWN]
	for i in 4:
		var actor: Player=PLAYER.instantiate()
		actor.position=Vector2(240+i%2*480,235+i/2*320)
		actor.movement_bounds=Rect2(-5000,-5000,10000,10000)
		actor.scale=Vector2.ONE*3
		root.add_child(actor)
		actor.apply_debug_testing_preset()
		actor.set_physics_process(false)
		actor.set_process_unhandled_input(false)
		assert(actor.equip_owned_weapon(ITEM))
		actor._set_facing_direction(directions[i])
		var family:=actor.get_node("WeaponFamilyPresentation")
		family.set_physics_process(false)
		family.presenter._rest_timer.stop()
		actors.append(actor)
		var label:=Label.new()
		label.text=["RIGHT","LEFT","UP / BACK","DOWN / FRONT"][i]
		label.position=Vector2(18+i%2*480,14+i/2*320)
		label.add_theme_color_override("font_color",Color("b5c9ce"))
		root.add_child(label)
	DirAccess.make_dir_recursive_absolute(output)
	await process_frame
	var started:=Time.get_ticks_msec()
	var previous:=started
	var mode:=0
	var timeline: Array[Dictionary]=[]
	while Time.get_ticks_msec()-started<12000:
		var now:=Time.get_ticks_msec()
		var elapsed:=now-started
		var delta:=(now-previous)/1000.0
		previous=now
		if mode==0 and elapsed>=650:
			mode=1
			for i in 4:
				var family:=actors[i].get_node("WeaponFamilyPresentation")
				family.presenter.play_locomotion(family.profile.run_for(directions[i]),.36,true)
		if mode==1:
			for actor in actors: actor.get_node("WeaponFamilyPresentation").presenter.advance_locomotion(105*delta)
		if mode==1 and elapsed>=2500:
			mode=2
			for actor in actors:
				actor.get_node("WeaponFamilyPresentation").presenter.stop_locomotion()
				actor.get_node("WeaponFamilyPresentation").presenter._rest_timer.stop()
				assert(actor.request_primary_attack())
		if mode==2:
			for actor in actors:
				if actor.attack_component.phase==MeleeAttackComponent.Phase.ACTIVE and actor.attack_component.combo_step<2 and actor._buffered_action==Player.BufferedAction.NONE:
					assert(actor.request_primary_attack())
		if mode==2 and elapsed>5300:
			mode=3
			for actor in actors:
				assert(actor.attack_component.phase==MeleeAttackComponent.Phase.IDLE)
				var rig: Node2D=actor.get_node("WeaponFamilyPresentation").presenter
				rig._rest_timer.stop() # The preview explicitly schedules this entry.
				rig._rest()
		await create_timer(.035).timeout
		await RenderingServer.frame_post_draw
		var file:="frame_%03d.png"%timeline.size()
		var capture:=root.get_texture().get_image()
		assert(capture.get_size()==Vector2i(960,640))
		assert(capture.save_png(output+file)==OK)
		timeline.append({"file":file,"elapsed_ms":Time.get_ticks_msec()-started,"mode":mode})
	FileAccess.open(output+"timeline.json",FileAccess.WRITE).store_string(JSON.stringify(timeline,"\t")+"\n")
	for actor in actors: actor.queue_free()
	await process_frame
	await process_frame
	print("SWORD_NATIVE_PREVIEW frames=",timeline.size()," scope=actual_equipped_players")
	quit()
