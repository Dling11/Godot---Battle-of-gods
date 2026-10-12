extends "res://tests/sanctuary_test_base.gd"

## A moving comparison through the actual equipped Player presenter.
const PLAYER=preload("res://entities/player/player.tscn")
const ITEMS=[preload("res://data/items/equipment/king_twinsteel.tres"),preload("res://data/items/equipment/king_royal_greatsword_v2.tres")]
const OUT="res://tmp/review/combat/king_dual_carry_motion_2026_10_12/"
const DIRECTIONS=[Vector2.LEFT,Vector2.RIGHT,Vector2.UP,Vector2.DOWN]
const NAMES=["LEFT","RIGHT","UP / BACK","DOWN / FRONT"]
var variant:="current"

func _run() -> void:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--label="): variant=argument.trim_prefix("--label=")
	var output:=OUT+variant+"/"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output))
	FileAccess.open(OUT+".gdignore",FileAccess.WRITE).store_string("")
	root.get_node("SaveService").configure_storage_path_for_testing("user://king_dual_motion_review.json")
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	root.get_node("RunSession").reset_run()
	root.size=Vector2i(1056,660); root.content_scale_size=root.size
	RenderingServer.set_default_clear_color(Color("243038"))
	_title("TWINSTEEL / "+variant.to_upper()+" / IDLE - WALK - IDLE",Vector2(20,10))
	_title("APPROVED GREATSWORD / SAME ACTOR SCALE",Vector2(20,340))
	var actors:Array[Player]=[]
	for row in 2:
		for column in 4:
			var actor:Player=PLAYER.instantiate()
			actor.position=Vector2(132+264*column,200+330*row); actor.scale=Vector2.ONE*3
			root.add_child(actor); actor.apply_debug_testing_preset()
			actor.set_physics_process(false); actor.set_process_unhandled_input(false)
			check(actor.equip_owned_weapon(ITEMS[row]),"Motion viewer cannot equip weapon")
			actor._set_facing_direction(DIRECTIONS[column])
			var family:=actor.get_node("WeaponFamilyPresentation")
			family.set_physics_process(false); family.presenter._rest_timer.stop()
			actors.append(actor)
			_title(NAMES[column],Vector2(25+264*column,80+330*row))
	for frame in 62:
		for index in actors.size():
			var family:=actors[index].get_node("WeaponFamilyPresentation")
			var direction:Vector2=DIRECTIONS[index%4]
			if frame==15: family.presenter.play_locomotion(family.profile.run_for(direction),.36,true)
			elif frame>15 and frame<47: family.presenter.advance_locomotion(6)
			elif frame==47:
				family.presenter.stop_locomotion(); family.presenter._rest_timer.stop()
		await RenderingServer.frame_post_draw
		check(root.get_texture().get_image().save_png(output+"frame_%03d.png"%frame)==OK,"Motion capture failed")
	FileAccess.open(output+"validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"frames":62,"playback_fps":15,"scope":"Actual equipped four-direction idle/walk/idle comparison with unchanged Greatsword"},"\t")+"\n")
	for actor in actors: actor.queue_free()
	await process_frame
	print("KING_DUAL_MOTION checks=",checks," failures=",failures)
	quit(1 if failures else 0)

func _title(value:String,spot:Vector2)->void:
	var title:=Label.new(); title.text=value; title.position=spot; root.add_child(title)
