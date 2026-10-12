extends "res://tests/king_art_test_base.gd"

## Check the new authored carry separately from the immutable reuse gate.
const CURRENT="res://data/weapons/families/twinsteel_v2/presentation.tres"
const OUT="res://tmp/review/combat/king_dual_carry_motion_2026_10_12/"
const Carry=preload("res://tools/king_dual_steady_carry.gd")
const VIEWS=["side","up","down"]
const CARRY_DIRECTIONS=[Vector2.RIGHT,Vector2.UP,Vector2.DOWN]

func _run()->void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	var current:Resource=load(CURRENT)
	var records:Array=JSON.parse_string(FileAccess.get_file_as_string(Carry.SOURCE.get_base_dir()+"/registration.json"))
	check(records.size()==24,"Incomplete 24-cel registration record")
	for index in 3:
		var view:String=VIEWS[index]
		var gait:Resource=current.run_for(CARRY_DIRECTIONS[index])
		var ready:Resource=current.idle_for(CARRY_DIRECTIONS[index])
		var canonical:Resource=load("res://assets/characters/playable/king/body_library/v1/"+view+"_run.tres")
		var master:Image=_cel(ready,0)
		var distinct:Dictionary={}
		for key in 8:
			var body:Image=_cel(gait,key)
			var upper:Image=body.get_region(Rect2i(0,0,192,81))
			check(same_opaque(upper,master.get_region(Rect2i(0,0,192,81))),"Head/chest/scarf/arms wobble or change from ready: "+view+str(key))
			check(anatomy_connected(body,Vector2i(gait.primary_hands[key]),Rect2i(gait.identity_regions[key])),"Disconnected head, waist or feet: "+view+str(key))
			var used:Rect2i=body.get_used_rect()
			var sole_limit:int=_cel(canonical,key).get_used_rect().end.y if view=="side" else 95
			check(used.position.x>4 and used.end.x<188 and used.position.y>4 and used.end.y<=sole_limit,"Cropped body or oversized leg extent: "+view+str(key)+" "+str(used))
			check(gait.primary_hands[key]==ready.primary_hands[0] and gait.secondary_hands[key]==ready.secondary_hands[0] and gait.offhand.hands[key]==ready.offhand.hands[0] and gait.offhand.axes[key]==ready.offhand.axes[0],"Blade jumps at idle/walk seam")
			check(gait.identity_regions[key]==ready.identity_regions[0] and gait.lift_pixels[key]==0,"Head origin/lift changes in locomotion")
			var lower:Image=body.get_region(Rect2i(0,81,192,47))
			distinct[lower.get_data()]=true
			if view!="side" and key>=4:
				var partner:Image=_cel(gait,key-4)
				check(_mirrored_legs_match(partner,body,float(records[index*8+key].target_pelvis_x)),"Second half stride does not alternate foot lanes")
			check(float(records[index*8+key].density)==float(records[index*8].density),"Per-frame leg resizing introduced")
			if view!="side":
				for grip in [gait.primary_hands[key],gait.offhand.hands[key]]:
					# The blade extends 50 source pixels at scale .9 from its palm.
					check(grip.y+sin(deg_to_rad(15))*45<95,"Vertical blade drags beneath soles")
		check(distinct.size()>=6,"Stepping cycle repeats too few poses")
		var cuts:Resource=current.attack_for(CARRY_DIRECTIONS[index])
		var chain:Array=[cuts]+Array(cuts.follow_up_clips)
		for step in 5:
			var clip:Resource=chain[step]
			check(clip.has_valid_layout(),"Attack clip layout invalid")
			for key in clip.pose_count:
				var endpoint:bool=(step==0 and key==0) or key==int(clip.phase_windows[2].y) or (step==4 and key==clip.pose_count-1)
				if not endpoint: continue
				var source:Resource=ready
				var source_key:int=0 if endpoint else key
				check(same_opaque(_cel(clip,key),_cel(source,source_key)),"Accepted attack pixels changed beyond carry endpoints")
				check(same_opaque(_mask(clip,key),_mask(source,source_key)),"Attack palms differ from endpoint/source")
				for property in ["primary_hands","secondary_hands","lift_pixels","weapon_behind_body","stowed_poses","identity_regions"]:
					check(clip.get(property)[key]==source.get(property)[source_key],"Attack source metadata changed")
				check(clip.offhand.hands[key]==source.offhand.hands[source_key] and clip.offhand.axes[key]==source.offhand.axes[source_key],"Attack second grip changed")
	FileAccess.open(OUT+"carry_checks.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"scope":"Fixed complete native upper carry, connected anatomy/legs, distinct alternating gait poses, uniform density/sole plane, exact ready/rest and current carry endpoints"},"\t")+"\n")
	print("KING_DUAL_STEADY_CARRY checks=",checks," failures=",failures)
	quit(1 if failures else 0)

func _cel(clip:Resource,key:int)->Image:
	return clip.body_atlas.get_image().get_region(Rect2i(key%4*192,key/4*128,192,128))

func _mask(clip:Resource,key:int)->Image:
	return clip.hand_atlas.get_image().get_region(Rect2i(key%4*192,key/4*128,192,128))

func _mirrored_legs_match(first:Image,second:Image,pivot:float)->bool:
	# Integer resampling can move the reflected pivot by at most one texel.
	for offset in [-1,0,1]:
		var matched:=true
		for y in range(81,128):
			for x in range(60,135):
				var mirrored_x:int=roundi(2*pivot)-x+offset
				if first.get_pixel(x,y)!=second.get_pixel(mirrored_x,y): matched=false
		if matched: return true
	return false
