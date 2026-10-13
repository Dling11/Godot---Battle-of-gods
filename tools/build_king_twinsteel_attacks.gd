extends SceneTree

const Baker=preload("res://tools/king_twinsteel_attack_baker.gd")
const Native=preload("res://tools/king_native_identity.gd")
const Slashes=preload("res://tools/king_twinsteel_slash_baker.gd")
const PROFILE="res://data/weapons/families/twinsteel_v2/presentation.tres"

func _initialize() -> void:
	var profile: Resource=load(PROFILE)
	var baker:=Baker.new()
	var recipe_path: String=Baker.SOURCE+"bake_recipe.json"
	var recipe: Dictionary
	if OS.get_cmdline_user_args().has("--register"):
		recipe=baker.make_recipe(profile)
		FileAccess.open(recipe_path,FileAccess.WRITE).store_string(JSON.stringify(recipe,"\t")+"\n")
	else:
		recipe=JSON.parse_string(FileAccess.get_file_as_string(recipe_path))
	var serializer:=Native.new()
	for view in ["side","up","down"]:
		var direction:=Vector2.RIGHT if view=="side" else (Vector2.UP if view=="up" else Vector2.DOWN)
		var root_clip: Resource=profile.attack_for(direction)
		var clips: Array=[root_clip]+Array(root_clip.follow_up_clips)
		for step in 5:
			var action: String=Baker.ACTIONS[step]
			var clip: Resource=baker.build(view,action,clips[step],profile.idle_for(direction),recipe)
			if clip==null:
				push_error("Generated Twinsteel attack failed: "+view+"/"+action)
				quit(1)
				return
			serializer.save_clip(clip,Baker.TARGET+view+"/",action,Baker.ACTIONS.slice(1) if step==0 else [])
	FileAccess.open(Baker.SOURCE+"registration.json",FileAccess.WRITE).store_string(JSON.stringify(baker.records,"\t")+"\n")
	assert(Slashes.new().build().save_png(Slashes.DEST)==OK,"Cannot save complete slash atlas")
	print("KING_TWINSTEEL_ATTACKS clips=15 complete_generated_poses=120 runtime_keys=195")
	quit()
