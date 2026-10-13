extends SceneTree

## Rebuild only Twinsteel walking from freshly generated complete poses.
## Other weapon art and frozen references are read-only. No archive input.
const Native=preload("res://tools/king_native_identity.gd")
const Carry=preload("res://tools/king_twinsteel_walk.gd")
const PROFILE="res://data/weapons/families/twinsteel_v2/presentation.tres"
const FOLDER="res://assets/characters/playable/king/shared_bodies/dual_carry_v3/"
const CAMERAS={"side":Vector2.RIGHT,"up":Vector2.UP,"down":Vector2.DOWN}
var native=Native.new()

func _initialize()->void:
	var profile:Resource=load(PROFILE)
	var baker=Carry.new()
	for view in CAMERAS:
		var folder:String=FOLDER+view+"/"
		var gait:Resource=baker.build_run(view,profile.run_for(CAMERAS[view]),profile.idle_for(CAMERAS[view]))
		if gait==null:
			push_error("Twinsteel bake failed: "+view)
			quit(1)
			return
		native.save_clip(gait,folder,"run")
	FileAccess.open(Carry.REGISTRATION,FileAccess.WRITE).store_string(JSON.stringify(baker.records,"\t")+"\n")
	print("KING_TWINSTEEL_CARRY rebuilt freshly generated whole running cels")
	quit()
