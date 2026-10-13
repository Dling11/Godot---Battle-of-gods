extends RefCounted

## Offline normalization of freshly generated COMPLETE running cels. Heads,
## necks, bodies and hands remain one authored image throughout. Vertical
## blades are composed offline at the same fixed dimensions as standing.
## No canonical body pixels, limb replacement or per-frame scaling.
const SOURCE := "res://art_source/generated/characters/king/twinsteel_running_complete_2026_10_13/"
const REGISTRATION := "res://assets/characters/playable/king/shared_bodies/dual_carry_v3/walk_registration.json"
var records: Array[Dictionary] = []
var protected_cels: Dictionary = {}

func build_run(view: String, old: Resource, idle: Resource) -> Resource:
	var recipe: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(SOURCE+"bake_recipe.json"))
	var lane: Dictionary = recipe.lanes[view]
	assert(FileAccess.get_sha256(lane.source)==lane.sha256,"Running source changed; review the complete-cel recipe first")
	var source := Image.load_from_file(lane.source)
	var clip: Resource = old.duplicate(true)
	var atlas := Image.create(768,256,false,Image.FORMAT_RGBA8)
	var masks := Image.create(768,256,false,Image.FORMAT_RGBA8)
	clip.identity_regions.clear()
	clip.primary_visible_poses=PackedByteArray([0,0,0,0,0,0,0,0])
	clip.offhand.visible_poses=PackedByteArray([0,0,0,0,0,0,0,0])
	clip.occluded_hand_poses=PackedByteArray()
	var density: float = lane.density
	var removal: Image
	var steel: Image
	if lane.has("weapon_removal_mask"):
		assert(FileAccess.get_sha256(lane.weapon_removal_mask.path)==lane.weapon_removal_mask.sha256,"Weapon removal mask changed")
		assert(FileAccess.get_sha256(recipe.weapon_scale_contract.texture)==recipe.weapon_scale_contract.sha256,"Canonical Twinsteel changed")
		removal=Image.load_from_file(lane.weapon_removal_mask.path)
		steel=(load(recipe.weapon_scale_contract.texture) as Texture2D).get_image()
	assert(lane.keys.size()==8 and is_finite(density) and density>0,"Invalid complete running lane")
	# Reference pixels are measured only, never copied. Full-pose height is
	# affected by extended running legs and cannot establish anatomical size.
	var reference_head: Rect2i = idle.body_atlas.get_image().get_region(Rect2i(idle.identity_regions[0])).get_used_rect()
	var calibration: Dictionary = lane.normalization
	assert(calibration.mode=="standing_head_landmark" and reference_head.size.y==calibration.standing_head_height,"Standing anatomy changed; review whole-lane normalization")
	assert(is_equal_approx(density,reference_head.size.y/float(calibration.source_head_span)),"Running density does not match the standing anatomy landmark")
	for key in 8:
		var item: Dictionary = lane.keys[key]
		var b: Array = item.bounds
		var bounds := Rect2i(int(b[0]),int(b[1]),int(b[2]-b[0]),int(b[3]-b[1]))
		var body := Image.create(192,128,false,Image.FORMAT_RGBA8)
		# The WHOLE owned sprite uses one pixel grid and one isotropic density
		# throughout its lane; never adjust head, torso or individual keys.
		for y in 128:
			for x in 192:
				var point := Vector2i(roundi(item.head_center_x+(x-96)/density),roundi(bounds.end.y-1+(y-recipe.foot_plane)/density))
				if not bounds.has_point(point): continue
				var color := source.get_pixelv(point)
				if color.a*255<recipe.alpha_threshold: continue
				# Common quantization and binary alpha remove source glow while
				# preserving complete silhouettes and connected drawn joints.
				color=Color(roundf(color.r*31)/31,roundf(color.g*31)/31,roundf(color.b*31)/31,1)
				body.set_pixel(x,y,color)
		# The source boot's last edge can fall between native sample columns.
		# Register the resulting WHOLE cel to the sole plane after sampling.
		var sole_shift: int = int(recipe.foot_plane)+1-body.get_used_rect().end.y
		if sole_shift!=0:
			var registered := Image.create(192,128,false,Image.FORMAT_RGBA8)
			registered.blit_rect(body,Rect2i(0,0,192,128),Vector2i(0,sole_shift))
			body=registered
		var top := roundi(recipe.foot_plane-(bounds.size.y-1)*density)+sole_shift
		var used := body.get_used_rect()
		assert(_sha256(body)==item.accepted_complete_cel_sha256,"Accepted complete running body changed")
		assert(used.size.y>=calibration.body_height_range[0] and used.size.y<=calibration.body_height_range[1] and Rect2i(5,5,182,118).encloses(used),"Whole running cel changes anatomical density or clips the atlas")
		clip.identity_regions.append(Rect2(82,top,29,roundi(bounds.size.y*density*item.head_fraction)))
		var near := _palm(body,Vector2(84,top+32))
		var far := _palm(body,Vector2(103,top+28) if view=="side" else Vector2(110,top+32))
		clip.primary_hands[key]=near
		clip.secondary_hands[key]=near+Vector2(7,0)
		clip.offhand.hands[key]=far
		clip.offhand.axes[key]=far+Vector2(-7,0)
		var anatomy_bounds := body.get_used_rect()
		var protected := body.duplicate()
		if removal!=null:
			var cutout := body.duplicate()
			var mask := removal.get_region(Rect2i(key%4*192,key/4*128,192,128))
			for y in 128:
				for x in 192:
					if mask.get_pixel(x,y).a>.9: cutout.set_pixel(x,y,Color(0,0,0,0))
			assert(_sha256(cutout)==item.protected_anatomy_sha256,"Weapon removal changes protected anatomy")
			protected=cutout
			var near_direction := Vector2(lane.blade_directions[0][0],lane.blade_directions[0][1]).normalized()
			var far_direction := Vector2(lane.blade_directions[1][0],lane.blade_directions[1][1]).normalized()
			clip.secondary_hands[key]=near-near_direction*7
			clip.offhand.axes[key]=far-far_direction*7
			var composed := Image.create(192,128,false,Image.FORMAT_RGBA8)
			_bake_steel(composed,steel,near,near_direction,clip.weapon_primary_grip)
			_bake_steel(composed,steel,far,far_direction,clip.offhand.grip)
			# Original connected anatomy covers handles at both closed fists.
			# No colors or body pixels from the generated removal plate are used.
			composed.blend_rect(cutout,Rect2i(0,0,192,128),Vector2i.ZERO)
			body=composed
		protected_cels[view+str(key)]=protected
		clip.weapon_behind_body[key]=0
		clip.offhand.behind_body[key]=0
		clip.lift_pixels[key]=0
		clip.single_hand_poses[key]=1
		clip.stowed_poses[key]=0
		var origin := Vector2i(key%4*192,key/4*128)
		atlas.blit_rect(body,Rect2i(0,0,192,128),origin)
		records.append({"view":view,"key":key,"mode":recipe.mode,"source":lane.source,"source_sha256":lane.sha256,"source_bounds":b,"density":density,"normalization":calibration,"integrated_weapons":true,"head_center_x":item.head_center_x,"body_bounds":var_to_str(anatomy_bounds),"composite_bounds":var_to_str(body.get_used_rect()),"fixed_weapon_scale":removal!=null,"weapon_length":50 if removal!=null else 0})
	clip.identity_source_region=Rect2()
	clip.body_atlas=ImageTexture.create_from_image(atlas)
	clip.hand_atlas=ImageTexture.create_from_image(masks)
	clip.allow_rest=false
	clip.interpolate_weapon=false
	clip.interpolate_blade_angles=false
	return clip

func _bake_steel(canvas: Image,steel: Image,palm: Vector2,direction: Vector2,grip: Vector2) -> void:
	# Rigid unit-size raster, inverse sampled on the native pixel grid. Only
	# translation/rotation vary; no direction or frame can shrink the blade.
	var basis := Transform2D(direction.angle()-Vector2.UP.angle(),palm)
	var inverse := basis.affine_inverse()
	for y in canvas.get_height():
		for x in canvas.get_width():
			var texel := Vector2i((inverse*Vector2(x,y)+grip).round())
			if not Rect2i(Vector2i.ZERO,steel.get_size()).has_point(texel): continue
			var color := steel.get_pixelv(texel)
			if color.a>.9:
				color.a=1
				canvas.set_pixel(x,y,color)

func _sha256(image: Image) -> String:
	var hash := HashingContext.new()
	hash.start(HashingContext.HASH_SHA256)
	hash.update(image.get_data())
	return hash.finish().hex_encode()

func _palm(body: Image, expected: Vector2) -> Vector2:
	var best := expected
	var distance := INF
	for y in range(int(expected.y)-6,int(expected.y)+7):
		for x in range(int(expected.x)-6,int(expected.x)+7):
			var color := body.get_pixel(x,y)
			if color.a<.9 or color.r<.18 or color.r>.65 or color.r<color.g*1.3 or color.g<color.b*1.2: continue
			var candidate := Vector2(x,y)
			if candidate.distance_squared_to(expected)<distance:
				distance=candidate.distance_squared_to(expected)
				best=candidate
	assert(distance<INF,"No connected leather fist near reviewed landmark")
	return best
