extends SceneTree

## Rebuild only the current Twinsteel carry from production poses.
## Other weapon art and frozen references are read-only. No archive input.
const Native=preload("res://tools/king_native_identity.gd")
const Carry=preload("res://tools/king_dual_steady_carry.gd")
const PROFILE="res://data/weapons/families/twinsteel_v2/presentation.tres"
const FOLDER="res://assets/characters/playable/king/shared_bodies/dual_carry_v3/"
const CAMERAS={"side":Vector2.RIGHT,"up":Vector2.UP,"down":Vector2.DOWN}
const NAMES=["diagonal","return","rising_cross","hop_spin","cross_finish"]
var native=Native.new()

func _initialize()->void:
	var profile:Resource=load(PROFILE)
	var baker=Carry.new()
	for view in CAMERAS:
		var idle:Resource=baker.prepare_idle(view,profile.idle_for(CAMERAS[view]))
		var folder:String=FOLDER+view+"/"
		_write_shared(idle,folder,"idle",idle.body_atlas.resource_path)
		var gait:Resource=baker.build_run(view,profile.run_for(CAMERAS[view]),idle)
		native.save_clip(gait,folder,"run")
		var first:Resource=profile.attack_for(CAMERAS[view])
		var clips:Array=[first]+Array(first.follow_up_clips)
		for step in 5:
			var clip:Resource=clips[step].duplicate(true)
			clip.follow_up_clips.clear()
			if step==0: _copy_ready(clip,0,idle)
			_copy_ready(clip,int(clip.phase_windows[2].y),idle)
			if step==4: _copy_ready(clip,clip.pose_count-1,idle)
			native.save_clip(clip,folder,NAMES[step],NAMES.slice(1) if step==0 else [])
	FileAccess.open(Carry.SOURCE.get_base_dir()+"/registration.json",FileAccess.WRITE).store_string(JSON.stringify(baker.records,"\t")+"\n")
	print("KING_TWINSTEEL_CARRY rebuilt current complete carry cels without archive dependencies")
	quit()

func _write_shared(clip: Resource,folder: String,label: String,body_path: String) -> void:
	native.save_clip(clip,folder,label)
	var path := folder+label+".tres"
	var text := FileAccess.get_file_as_string(path).replace(folder+label+"_body.png",body_path)
	var output := FileAccess.open(path,FileAccess.WRITE)
	assert(output!=null,"Cannot write shared pose resource: "+path+" error="+str(FileAccess.get_open_error()))
	output.store_string(text)
	clip.take_over_path(path)
	# The body is shared by reference; remove only this newly-written duplicate.
	DirAccess.remove_absolute(ProjectSettings.globalize_path(folder+label+"_body.png"))

func _copy_ready(clip: Resource,key: int,ready: Resource,source_key := 0) -> void:
	var bodies: Image = clip.body_atlas.get_image().duplicate()
	var hands: Image = clip.hand_atlas.get_image().duplicate()
	var origin := Vector2i(key%4,key/4)*Vector2i(192,128)
	var rectangle := Rect2i(origin,Vector2i(192,128))
	bodies.fill_rect(rectangle,Color.TRANSPARENT); hands.fill_rect(rectangle,Color.TRANSPARENT)
	var source_box := Rect2i(source_key%4*192,source_key/4*128,192,128)
	bodies.blit_rect(ready.body_atlas.get_image(),source_box,origin)
	hands.blit_rect(ready.hand_atlas.get_image(),source_box,origin)
	clip.body_atlas=ImageTexture.create_from_image(bodies)
	clip.hand_atlas=ImageTexture.create_from_image(hands)
	for property in ["primary_hands","secondary_hands","lift_pixels","weapon_behind_body","single_hand_poses","stowed_poses","released_poses","ground_clipped_poses"]:
		var values = clip.get(property).duplicate()
		values[key]=ready.get(property)[source_key]; clip.set(property,values)
	if not clip.occluded_hand_poses.is_empty(): clip.occluded_hand_poses[key]=1 if ready.hands_are_occluded(source_key) else 0
	if not clip.identity_regions.is_empty(): clip.identity_regions[key]=ready.identity_regions[source_key]
	if clip.offhand!=null:
		for property in ["hands","axes","behind_body","visible_poses"]:
			var values = clip.offhand.get(property).duplicate()
			values[key]=ready.offhand.get(property)[source_key]; clip.offhand.set(property,values)
