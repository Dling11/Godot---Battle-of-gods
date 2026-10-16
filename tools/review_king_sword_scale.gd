extends SceneTree

## Actual equipment presenters, one camera and one scale for every direction.
const PLAYER=preload("res://entities/player/player.tscn")
const ITEMS=[preload("res://data/items/equipment/king_iron_reaper.tres"),preload("res://data/items/equipment/king_signature_sword.tres")]
const DIRECTIONS=[Vector2.RIGHT,Vector2.LEFT,Vector2.UP,Vector2.DOWN]
const OUTPUT="res://tmp/review/sword_unified_2026_10_16/comparison/"

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	root.size=Vector2i(1056,640)
	root.content_scale_size=root.size
	root.content_scale_mode=Window.CONTENT_SCALE_MODE_DISABLED
	RenderingServer.set_default_clear_color(Color("243038"))
	root.get_node("SaveService").configure_storage_path_for_testing("user://sword_scale_review.json")
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	root.get_node("RunSession").reset_run()
	var actors: Array[Player]=[]
	for row in 2:
		_title(["SCYTHE / ACCEPTED REFERENCE","SWORD / NEW / SAME CAMERA AND SCALE"][row],Vector2(20,12+row*320))
		for column in 4:
			var actor: Player=PLAYER.instantiate()
			actor.position=Vector2(132+264*column,218+320*row)
			actor.scale=Vector2.ONE*3
			root.add_child(actor)
			actor.apply_debug_testing_preset()
			actor.set_physics_process(false)
			actor.set_process_unhandled_input(false)
			assert(actor.equip_owned_weapon(ITEMS[row]))
			actor._set_facing_direction(DIRECTIONS[column])
			var family:=actor.get_node("WeaponFamilyPresentation")
			family.set_physics_process(false)
			family.presenter._rest_timer.stop()
			actors.append(actor)
			_title(["RIGHT","LEFT","UP / BACK","DOWN / FRONT"][column],Vector2(20+264*column,50+320*row))
	DirAccess.make_dir_recursive_absolute(OUTPUT)
	var timeline: Array[Dictionary]=[]
	var start:=Time.get_ticks_msec()
	var previous:=start
	var mode:=0
	while Time.get_ticks_msec()-start<6000:
		var now:=Time.get_ticks_msec()
		var elapsed:=now-start
		var delta:=(now-previous)/1000.0
		previous=now
		if mode==0 and elapsed>1100:
			mode=1
			for index in actors.size():
				var family:=actors[index].get_node("WeaponFamilyPresentation")
				family.presenter.play_locomotion(family.profile.run_for(DIRECTIONS[index%4]),.36,true)
		if mode==1:
			for actor in actors: actor.get_node("WeaponFamilyPresentation").presenter.advance_locomotion(105*delta)
		if mode==1 and elapsed>4600:
			mode=2
			for actor in actors:
				actor.get_node("WeaponFamilyPresentation").presenter.stop_locomotion()
				actor.get_node("WeaponFamilyPresentation").presenter._rest_timer.stop()
		await create_timer(.035).timeout
		await RenderingServer.frame_post_draw
		var file:="frame_%03d.png"%timeline.size()
		assert(root.get_texture().get_image().save_png(OUTPUT+file)==OK)
		timeline.append({"file":file,"elapsed_ms":Time.get_ticks_msec()-start,"mode":mode})
	FileAccess.open(OUTPUT+"timeline.json",FileAccess.WRITE).store_string(JSON.stringify(timeline,"\t")+"\n")
	for actor in actors: actor.queue_free()
	await process_frame
	print("SWORD_SCYTHE_SCALE frames=",timeline.size()," same_actor_scale=3")
	quit()

func _title(value: String,spot: Vector2) -> void:
	var label:=Label.new()
	label.text=value
	label.position=spot
	root.add_child(label)
