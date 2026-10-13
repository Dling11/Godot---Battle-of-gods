extends "res://tests/sanctuary_test_base.gd"

## Native rendering of real Player contact phases at their production clock.
const PLAYER=preload("res://entities/player/player.tscn")
const ITEM=preload("res://data/items/equipment/king_twinsteel.tres")
const OUT="res://tmp/review/twinsteel_attacks_2026_10_14/native/"
const DIRECTIONS=[Vector2.RIGHT,Vector2.LEFT,Vector2.UP,Vector2.DOWN]
const NAMES=["RIGHT","LEFT","UP / BACK","DOWN / FRONT"]
var actors: Array[Player]=[]
var labels: Array[Label]=[]
var saw: Array[Dictionary]=[{}, {}, {}, {}]
var next_frame:=0

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	root.get_node("RunSession").reset_run()
	root.size=Vector2i(960,640); root.content_scale_size=root.size
	Engine.max_fps=60
	# PNG writes can delay a rendered frame. Keep one fixed physics step per
	# render so a 60fps GIF retains the production combo durations.
	Engine.max_physics_steps_per_frame=1
	RenderingServer.set_default_clear_color(Color("243038"))
	_title("TWINSTEEL / FRESH COMPLETE ATTACKS / ACTUAL COMBO SPEED",Vector2(18,10))
	for index in 4:
		var actor: Player=PLAYER.instantiate()
		actor.movement_bounds=Rect2(-5000,-5000,10000,10000)
		actor.position=Vector2(240+480*(index%2),210+310*(index/2)); actor.scale=Vector2.ONE*2.5
		root.add_child(actor); actor.apply_debug_testing_preset()
		actor.set_physics_process(false); actor.set_process_unhandled_input(false)
		check(actor.equip_owned_weapon(ITEM),"Cannot equip current Twinsteel")
		actor._set_facing_direction(DIRECTIONS[index])
		actors.append(actor)
		labels.append(_title(NAMES[index],Vector2(18+480*(index%2),55+310*(index/2))))
		actor.get_node("WeaponFamilyPresentation").presenter._rest_timer.stop()
	await physics_frame
	physics_frame.connect(_tick)
	for frame in 186:
		await physics_frame
		await RenderingServer.frame_post_draw
		check(root.get_texture().get_image().save_png(OUT+"frame_%03d.png"%frame)==OK,"Native attack capture failed")
	physics_frame.disconnect(_tick)
	for index in 4: check(saw[index].size()==5,"Native review skipped a combo step")
	FileAccess.open(OUT+"validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"frames":186,"playback_fps":60,"scope":"Actual equipped Player four-facing five-cut chain, released settle and rendering"},"\t")+"\n")
	for actor in actors: actor.queue_free()
	await process_frame
	print("KING_TWINSTEEL_ATTACK_REVIEW checks=",checks," failures=",failures)
	quit(1 if failures else 0)

func _tick() -> void:
	for index in 4:
		var actor: Player=actors[index]
		var attack:=actor.attack_component
		if next_frame==18: check(actor.request_primary_attack(),"Native chain cannot begin")
		if attack.phase!=MeleeAttackComponent.Phase.IDLE:
			saw[index][attack.combo_step]=true
			labels[index].text=NAMES[index]+" / CUT "+str(attack.combo_step+1)
			if attack.combo_step<4: actor.request_primary_attack()
		else: labels[index].text=NAMES[index]+" / READY"
	next_frame+=1

func _title(value: String,spot: Vector2) -> Label:
	var label:=Label.new(); label.text=value; label.position=spot; root.add_child(label)
	return label
