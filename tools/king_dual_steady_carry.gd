extends RefCounted

## Offline only: bake complete cels around the approved complete carry upper
## body. Runtime still draws one body atlas, two rigid blades and native masks.
const Native=preload("res://tools/king_native_identity.gd")
const SOURCE="res://art_source/generated/characters/king/dual_carry_gait_2026_10_12/gait_source.png"
const LIB="res://assets/characters/playable/king/body_library/v1/"
const SEAM=81
const VERTICAL_KEYS=[0,1,3,4]
var source_rows:Array[Array]
var records:Array[Dictionary]=[]

func _init() -> void:
	source_rows=Native.new().sheet_cells(Image.load_from_file(SOURCE),3,8)

func prepare_idle(view:String,original:Resource)->Resource:
	var idle:Resource=original.duplicate(true)
	# Only the ready key changes its blade orientation/depth. Every body and
	# all seven planting/folded/glance keys remain the original approved art.
	for field in ["secondary_hands","weapon_behind_body"]: idle.set(field,idle.get(field).duplicate())
	for field in ["axes","behind_body"]: idle.offhand.set(field,idle.offhand.get(field).duplicate())
	var near:Vector2=idle.primary_hands[0]
	var far:Vector2=idle.offhand.hands[0]
	var near_angle:=10.0 if view=="side" else 165.0
	var far_angle:=-6.0 if view=="side" else 15.0
	idle.secondary_hands[0]=near-Vector2.from_angle(deg_to_rad(near_angle))*7
	idle.offhand.axes[0]=far-Vector2.from_angle(deg_to_rad(far_angle))*7
	idle.weapon_behind_body[0]=1 if view=="up" else 0
	idle.offhand.behind_body[0]=0 if view=="down" else 1
	var masks:Image=original.hand_atlas.get_image().duplicate()
	masks.fill_rect(Rect2i(0,0,192,128),Color.TRANSPARENT)
	var body:Image=original.body_atlas.get_image().get_region(Rect2i(0,0,192,128))
	for grip in [near,far]:
		var box:=glove_box(grip); masks.blit_rect(body,box,box.position)
	idle.hand_atlas=ImageTexture.create_from_image(masks)
	return idle

func build_run(view:String,old:Resource,idle:Resource)->Resource:
	var clip:Resource=old.duplicate(true)
	var master:Image=idle.body_atlas.get_image().get_region(Rect2i(0,0,192,128))
	var canonical:Resource=load(LIB+view+"_run.tres")
	var atlas:=Image.create(768,256,false,Image.FORMAT_RGBA8)
	var masks:=Image.create(768,256,false,Image.FORMAT_RGBA8)
	var near:Vector2=idle.primary_hands[0]
	var far:Vector2=idle.offhand.hands[0]
	var target_x:=pelvis_center(master)
	var palette:=leg_palette(canonical.body_atlas.get_image())
	var row_index:int=1 if view=="down" else 2
	var source_legs:Array[Dictionary]=[]
	var density:=1.0
	if view!="side":
		var maximum_height:=0
		for source_key in VERTICAL_KEYS:
			var raw:Image=source_rows[row_index][source_key].image
			var waist:=waist_line(raw)
			var part:=raw.get_region(Rect2i(0,waist+1,raw.get_width(),raw.get_height()-waist-1))
			maximum_height=maxi(maximum_height,part.get_used_rect().end.y)
			source_legs.append({"image":part,"pivot":waist_center(raw,waist),"source_key":source_key,"waist":waist})
		density=float(95-SEAM)/maximum_height
	for field in ["primary_hands","secondary_hands","lift_pixels","weapon_behind_body","single_hand_poses","stowed_poses"]: clip.set(field,clip.get(field).duplicate())
	for field in ["hands","axes","behind_body","visible_poses"]: clip.offhand.set(field,clip.offhand.get(field).duplicate())
	clip.identity_regions.clear()
	for key in 8:
		var body:=Image.create(192,128,false,Image.FORMAT_RGBA8)
		var leg_shift:=Vector2i.ZERO
		if view=="side":
			var original:Image=canonical.body_atlas.get_image().get_region(Rect2i(key%4*192,key/4*128,192,128))
			leg_shift.x=roundi(target_x-pelvis_center(original))
			body.blit_rect(original,Rect2i(0,SEAM,192,128-SEAM),Vector2i(leg_shift.x,SEAM))
		else:
			var source:Dictionary=source_legs[key%4]
			var legs:Image=source.image.duplicate()
			legs.resize(maxi(1,roundi(legs.get_width()*density)),maxi(1,roundi(legs.get_height()*density)),Image.INTERPOLATE_NEAREST)
			quantize(legs,palette)
			var pivot:float=source.pivot*density
			if key>=4:
				legs.flip_x(); pivot=legs.get_width()-1-pivot
			leg_shift=Vector2i(roundi(target_x-pivot),SEAM)
			body.blit_rect(legs,Rect2i(Vector2i.ZERO,legs.get_size()),leg_shift)
			assert(body.get_used_rect().end.y<=95,"Leg source exceeds the approved sole plane")
		# A complete connected upper carry cel includes the native head, scarf,
		# chest, sleeves, fists and waist. There is no detached head/arm rig.
		body.blit_rect(master,Rect2i(0,0,192,SEAM),Vector2i.ZERO)
		var origin:=Vector2i(key%4*192,key/4*128)
		atlas.blit_rect(body,Rect2i(0,0,192,128),origin)
		for grip in [near,far]:
			var box:=glove_box(grip); masks.blit_rect(body,box,origin+box.position)
		clip.primary_hands[key]=near; clip.secondary_hands[key]=idle.secondary_hands[0]
		clip.offhand.hands[key]=far; clip.offhand.axes[key]=idle.offhand.axes[0]
		clip.offhand.behind_body[key]=idle.offhand.behind_body[0]; clip.offhand.visible_poses[key]=1
		clip.weapon_behind_body[key]=idle.weapon_behind_body[0]
		clip.lift_pixels[key]=0; clip.single_hand_poses[key]=1; clip.stowed_poses[key]=0
		clip.identity_regions.append(idle.identity_regions[0])
		records.append({"view":view,"key":key,"source_key":key if view=="side" else VERTICAL_KEYS[key%4],"mirrored_legs":view!="side" and key>=4,"leg_shift":var_to_str(leg_shift),"density":density,"seam":SEAM,"target_pelvis_x":target_x})
	clip.identity_source_region=idle.identity_regions[0]
	clip.body_atlas=ImageTexture.create_from_image(atlas); clip.hand_atlas=ImageTexture.create_from_image(masks)
	clip.allow_rest=false; clip.interpolate_weapon=false; clip.interpolate_blade_angles=false
	return clip

static func glove_box(grip:Vector2)->Rect2i:
	return Rect2i(Vector2i(grip.round())-Vector2i(5,5),Vector2i(11,11))

static func pelvis_center(body:Image)->float:
	# The immediate pants seam is below both palms; do not rank leather blobs.
	var total:=0.0; var count:=0
	for y in range(SEAM-2,SEAM):
		for x in range(80,119):
			var color:=body.get_pixel(x,y)
			if color.a>.65 and (color.b>=color.r*.95 or color.v<.20): total+=x; count+=1
	assert(count>0,"Carry source has no connected pants seam")
	return total/count

static func waist_line(raw:Image)->int:
	var best:=-1
	for y in range(roundi(raw.get_height()*.45),roundi(raw.get_height()*.80)):
		var count:=0
		for x in range(raw.get_width()/4,raw.get_width()*3/4):
			var c:=raw.get_pixel(x,y)
			if c.a>.65 and c.v>.60 and c.s<.25: count+=1
		if count>=4: best=y
	assert(best>=0,"Generated lower-body source lacks a clear waist seam")
	return best

static func waist_center(raw:Image,row:int)->float:
	var total:=0.0; var count:=0
	for x in raw.get_width():
		var c:=raw.get_pixel(x,row)
		if c.a>.65 and c.v>.60 and c.s<.25: total+=x; count+=1
	assert(count>0); return total/count

static func leg_palette(atlas:Image)->Array[Color]:
	var colors:Array[Color]=[]
	for key in 8:
		var origin:=Vector2i(key%4*192,key/4*128)
		for y in range(SEAM,95):
			for x in range(60,135):
				var c:=atlas.get_pixelv(origin+Vector2i(x,y))
				if c.a>.65 and c not in colors: colors.append(c)
	return colors

static func quantize(image:Image,palette:Array[Color])->void:
	for y in image.get_height():
		for x in image.get_width():
			var c:=image.get_pixel(x,y)
			if c.a<.65: image.set_pixel(x,y,Color.TRANSPARENT); continue
			var nearest:=palette[0]; var score:=INF
			for candidate in palette:
				var distance:float=Vector3(c.r-candidate.r,c.g-candidate.g,c.b-candidate.b).length_squared()
				if distance<score: score=distance; nearest=candidate
			image.set_pixel(x,y,nearest)
