extends "res://tests/king_art_test_base.gd"

const Baker=preload("res://tools/king_twinsteel_attack_baker.gd")
const Slash=preload("res://tools/king_twinsteel_slash_baker.gd")
const PROFILE=preload("res://data/weapons/families/twinsteel_v2/presentation.tres")
const OUT="res://tmp/review/twinsteel_attacks_2026_10_14/"

func _run() -> void:
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	var recipe: Dictionary=JSON.parse_string(FileAccess.get_file_as_string(Baker.SOURCE+"bake_recipe.json"))
	var protected_assets: Dictionary=JSON.parse_string(FileAccess.get_file_as_string(Baker.SOURCE+"protected_assets.json"))
	for path in protected_assets:
		check(FileAccess.get_sha256(path)==protected_assets[path],"Approved running/idle was modified: "+path)
	var baker:=Baker.new()
	for view in ["side","up","down"]:
		var direction:=Vector2.RIGHT if view=="side" else (Vector2.UP if view=="up" else Vector2.DOWN)
		var ready: Resource=PROFILE.idle_for(direction)
		var first: Resource=PROFILE.attack_for(direction)
		var clips: Array=[first]+Array(first.follow_up_clips)
		for step in 5:
			var action: String=Baker.ACTIONS[step]
			var clip: Resource=clips[step]
			var board: Dictionary=recipe.boards[view+"/"+action]
			check(FileAccess.get_sha256(board.source)==board.sha256,"Fresh source provenance drift")
			check(clip.has_valid_layout() and clip.cell_size==Baker.CELL,"Invalid padded action layout")
			check(clip.identity_source_region==Rect2() and not clip.interpolate_weapon,"Action reuses detached identity/rig interpolation")
			var rebuilt: Resource=baker.build(view,action,clip,ready,recipe)
			check(rebuilt!=null and same_opaque(rebuilt.body_atlas.get_image(),clip.body_atlas.get_image()),"Published action differs from whole generated input")
			var distinct: Dictionary={}
			for generated in 8:
				var key:=generated+1
				var body:=_cel(clip,key)
				var anatomy: Image=baker.anatomy[view+"/"+action+"/"+str(generated)]
				check(anatomy.get_used_rect().end.y==Baker.FOOT+1,"Source feet drift relative to standing")
				var preserved:=true
				var binary:=true
				var colored_guide:=false
				for y in Baker.CELL.y:
					for x in Baker.CELL.x:
						var original:=anatomy.get_pixel(x,y)
						var color:=body.get_pixel(x,y)
						if original.a>.9 and color!=original: preserved=false
						if color.a not in [0.0,1.0]: binary=false
						if baker.native.guide(color): colored_guide=true
				check(preserved and binary and not colored_guide,"Steel composition edits anatomy or retains guide/glow")
				check(clip.primary_visible_poses[key]==0 and clip.offhand.visible_poses[key]==0 and clip.hand_atlas.get_image().get_region(Rect2i(Vector2i(key%4,key/4)*Baker.CELL,Baker.CELL)).is_invisible(),"Duplicate rigs or pasted hand fragments")
				check(Rect2i(2,2,188,188).encloses(body.get_used_rect()),"Action/steel is cut at a frame edge")
				for pair in [[clip.primary_hands[key],clip.secondary_hands[key]],[clip.offhand.hands[key],clip.offhand.axes[key]]]:
					var hand: Vector2=pair[0]
					check(anatomy_connected(anatomy,Vector2i(hand),Rect2i(clip.identity_regions[key])),"Detached head/chest/arm/waist/boots: "+view+"/"+action+"/"+str(generated))
					var tip: Vector2=hand+(hand-Vector2(pair[1])).normalized()*50
					check(_steel_near(body,tip),"Fixed standing-length blade tip is hidden or missing: "+view+"/"+action+"/"+str(generated)+" "+str(hand)+" -> "+str(tip))
					var steel:=Image.create(192,192,false,Image.FORMAT_RGBA8)
					baker._bake_weapon(steel,clip.weapon_texture.get_image(),hand,(hand-Vector2(pair[1])).normalized(),clip.weapon_primary_grip)
					var visible:=0
					for y in 192:
						for x in 192:
							if steel.get_pixel(x,y).a>.9 and anatomy.get_pixel(x,y).a<.1 and body.get_pixel(x,y).a>.9: visible+=1
					check(visible>=45,"A held blade disappears under the body: "+view+"/"+action+"/"+str(generated))
				distinct[anatomy.get_data()]=true
			check(distinct.size()==8,"Action lacks distinct complete motion poses")
			var padded:=Image.create(192,192,false,Image.FORMAT_RGBA8)
			padded.blit_rect(_cel(ready,0),Rect2i(0,0,192,128),Vector2i(0,32))
			check(same_opaque(_cel(clip,10),padded),"Release does not settle to unchanged standing anatomy")
			check((Baker.FOOT-clip.cell_size.y*.5)*.5-16==-1,"Padding changes the actual world foot plane")
	var atlas:=Slash.new().build()
	check(same_opaque(atlas,load(Slash.DEST).get_image()),"Runtime slash differs from generated effect strips")
	for row in 5:
		var frames: Dictionary={}
		for frame in 4:
			var cell:=atlas.get_region(Rect2i(frame*192,row*192,192,192))
			check(not cell.is_invisible() and Rect2i(32,32,128,128).encloses(cell.get_used_rect()),"Empty or clipped white slash")
			frames[cell.get_data()]=true
		check(frames.size()==4,"Slash repeats a held frame")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	FileAccess.open(OUT+"attack_checks.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"scope":"Fresh whole anatomy/source rebuilds, held rigid-size blades, connections, padding, safe gutters, release and all generated slashes"},"\t")+"\n")
	print("KING_TWINSTEEL_ATTACKS_SMOKE checks=",checks," failures=",failures)
	quit(1 if failures else 0)

func _cel(clip: Resource,key: int) -> Image:
	return clip.body_atlas.get_image().get_region(Rect2i(Vector2i(key%4,key/4)*clip.cell_size,clip.cell_size))

func _steel_near(body: Image,tip: Vector2) -> bool:
	for y in range(roundi(tip.y)-2,roundi(tip.y)+3):
		for x in range(roundi(tip.x)-2,roundi(tip.x)+3):
			if not Rect2i(Vector2i.ZERO,body.get_size()).has_point(Vector2i(x,y)): continue
			var c:=body.get_pixel(x,y)
			# Canonical tip texels are dark outlines; rear swords can also be
			# genuinely occluded by the torso. Check visible steel separately.
			if c.a>.9: return true
	return false
