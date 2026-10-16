extends SceneTree

## Native preview of the same presenter/resources verified in the real Lab.
## Plain backdrop keeps all four huge blades readable and the GIF compact.
const Presenter = preload("res://gameplay/presentation/weapon_family_pose_presenter.gd")
const Profile = preload("res://data/weapons/families/royal_greatsword/presentation.tres")
var output := "res://tmp/review/greatsword_shoulder_idle_2026_10_16/clean-native/"

func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--output="): output=arg.trim_prefix("--output=").trim_suffix("/")+"/"
	_run.call_deferred()

func _run() -> void:
	root.size=Vector2i(960,640)
	root.content_scale_size=Vector2i(960,640)
	root.content_scale_mode=Window.CONTENT_SCALE_MODE_DISABLED
	RenderingServer.set_default_clear_color(Color("1b262c"))
	var world:=Node2D.new()
	root.add_child(world)
	var actors: Array[Node2D]=[]
	var directions: Array[Vector2]=[Vector2.RIGHT,Vector2.LEFT,Vector2.UP,Vector2.DOWN]
	for i in 4:
		var attack:=MeleeAttackComponent.new()
		world.add_child(attack)
		var rig:=Presenter.new()
		assert(rig.configure(Profile.attack_for(directions[i]),attack,false))
		assert(rig.configure_idle(Profile.idle_for(directions[i])))
		rig.position=Vector2(240+(i%2)*480,205+(i/2)*320)
		rig.scale=Vector2(-1.5 if i==1 else 1.5,1.5)
		world.add_child(rig)
		rig._rest_timer.stop()
		actors.append(rig)
		var label:=Label.new()
		label.text=["RIGHT","LEFT","UP / BACK","DOWN / FRONT"][i]
		label.position=Vector2(18+(i%2)*480,14+(i/2)*320)
		label.add_theme_color_override("font_color",Color("b5c9ce"))
		world.add_child(label)
		var floor:=Line2D.new()
		floor.width=1
		floor.default_color=Color("34464c")
		floor.points=PackedVector2Array([Vector2(40+(i%2)*480,251+(i/2)*320),Vector2(440+(i%2)*480,251+(i/2)*320)])
		world.add_child(floor)
	await process_frame
	DirAccess.make_dir_recursive_absolute(output)
	var started:=Time.get_ticks_msec()
	var resting:=false
	var timeline: Array[Dictionary]=[]
	while Time.get_ticks_msec()-started<6500:
		if not resting and Time.get_ticks_msec()-started>=200:
			for actor in actors: actor._rest()
			resting=true
		await create_timer(.05).timeout
		await RenderingServer.frame_post_draw
		var file:="frame_%03d.png"%timeline.size()
		var image:=root.get_texture().get_image()
		assert(image.get_size()==Vector2i(960,640),"Preview viewport must include both complete rows")
		assert(image.save_png(output+file)==OK)
		timeline.append({"file":file,"elapsed_ms":Time.get_ticks_msec()-started,"poses":actors.map(func(rig: Node2D) -> int: return rig.pose_index)})
	FileAccess.open(output+"timeline.json",FileAccess.WRITE).store_string(JSON.stringify(timeline,"\t")+"\n")
	world.queue_free()
	await process_frame
	await process_frame
	print("GREATSWORD_SHOULDER_PREVIEW frames=",timeline.size()," source=live_family_presenter")
	quit()
