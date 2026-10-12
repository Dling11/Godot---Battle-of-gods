extends RefCounted

## Offline anatomy registration. Never used by gameplay or per-frame rendering.
const ROOT := "res://art_source/reference/characters/king/native_identity_v1/"
var contract: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(ROOT+"reference.json"))

func native_ref(view: String) -> Dictionary:
	if view=="side": view="right"
	var info: Dictionary = contract.views[view]
	var box: Array = info.head
	return {"image":Image.load_from_file(ROOT+view+"_body.png"),"head":Rect2i(box[0],box[1],box[2],box[3])}

func guide(c: Color) -> bool:
	return c.a>.2 and c.s>.55 and ((c.b>.5 and c.g>c.r*1.25 and c.b>c.r*1.4) or (c.r>.5 and c.b>.45 and c.r>c.g*1.4 and c.b>c.g*1.4))

func sheet_cells(sheet: Image,rows: int,columns: int) -> Array[Array]:
	# Each complete grid cel retains disconnected arms obscured by a guide.
	# Connected-component extraction alone discarded those legitimate pixels.
	var result: Array[Array] = []
	var row_cuts := PackedInt32Array([0])
	for row in range(1,rows): row_cuts.append(gutter(sheet,false,roundi(row*sheet.get_height()/float(rows)),roundi(sheet.get_height()/float(rows)*.3),Rect2i(Vector2i.ZERO,sheet.get_size())))
	row_cuts.append(sheet.get_height())
	for row in rows:
		var cells: Array = []
		var band := Rect2i(0,row_cuts[row],sheet.get_width(),row_cuts[row+1]-row_cuts[row])
		var column_cuts := PackedInt32Array([0])
		for column in range(1,columns): column_cuts.append(gutter(sheet,true,roundi(column*sheet.get_width()/float(columns)),roundi(sheet.get_width()/float(columns)*.44),band))
		column_cuts.append(sheet.get_width())
		for column in columns:
			var bounds := Rect2i(column_cuts[column],band.position.y,column_cuts[column+1]-column_cuts[column],band.size.y)
			var raw := sheet.get_region(bounds)
			var body: Image = raw.duplicate()
			var shaft: Array[Vector2] = []
			var blade: Array[Vector2] = []
			for y in raw.get_height():
				for x in raw.get_width():
					var c := raw.get_pixel(x,y)
					if c.a<.65 or guide(c): body.set_pixel(x,y,Color.TRANSPARENT)
					if c.a>.8 and guide(c):
						if c.r>c.g: shaft.append(Vector2(x,y))
						else: blade.append(Vector2(x,y))
			var used := body.get_used_rect()
			cells.append({"image":body.get_region(used),"bounds":bounds,"crop":used,"shaft":shaft,"blade":blade})
		result.append(cells)
	return result

func gutter(sheet: Image,vertical: bool,nominal: int,radius: int,band: Rect2i) -> int:
	var best := nominal
	var best_score := INF
	for candidate in range(nominal-radius,nominal+radius+1):
		var occupied := 0
		for across in range(candidate-1,candidate+2):
			for along in range(band.position.y,band.end.y) if vertical else range(band.position.x,band.end.x):
				var c := sheet.get_pixel(across,along) if vertical else sheet.get_pixel(along,across)
				if c.a>.85: occupied+=1
		var score := occupied*10000.0+absi(candidate-nominal)
		if score<best_score: best_score=score; best=candidate
	assert(best_score<10000,"No clear source gutter near "+str(nominal))
	return best

func neck(image: Image) -> Vector2:
	var used := image.get_used_rect()
	var center := used.get_center().x
	var scalp_width := used.size.x*.4
	var best := 0
	var crown_y := used.position.y
	# A flying scarf/extended arm must not move the collar search away from
	# the actual crown. Find the dense dark hair row before reading the neck.
	for y in range(used.position.y,used.position.y+roundi(used.size.y*.55)):
		var total := 0.0
		var count := 0
		var low := image.get_width()
		var high := 0
		for x in range(used.position.x,used.end.x):
			var c := image.get_pixel(x,y)
			if c.a>.65 and maxf(c.r,maxf(c.g,c.b))<.4 and absf(c.r-c.g)<.11 and c.b<c.r+.04:
				total+=x; count+=1; low=mini(low,x); high=maxi(high,x)
		if count>best: best=count; center=total/count; scalp_width=high-low+1; crown_y=y
	var reds: Array[Vector2] = []
	# Raised arms make the collar fall outside the upper fraction of a cel.
	# Search below the crown instead; leather palms are not scarf pixels.
	for y in range(crown_y+1,mini(image.get_height(),crown_y+maxi(12,roundi(scalp_width))+1)):
		for x in range(maxi(0,roundi(center)-maxi(2,roundi(scalp_width*.12))),mini(image.get_width(),roundi(center)+maxi(3,roundi(scalp_width*.12)))):
			var c := image.get_pixel(x,y)
			if c.a>.65 and c.r>.30 and c.r>c.g*3.0 and c.r>c.b*2.2: reds.append(Vector2(x,y))
	if reds.is_empty(): return Vector2(center,used.position.y+used.size.y*.4)
	reds.sort_custom(func(a: Vector2,b: Vector2) -> bool: return a.y<b.y)
	var y: float = reds[reds.size()/2].y
	var total := Vector2.ZERO
	var count := 0
	for point in reds:
		if absf(point.y-y)<=3: total+=point; count+=1
	return total/count

func armor_width(image: Image,socket: Vector2) -> float:
	var widths: Array[int] = []
	for y in range(roundi(socket.y)+4,mini(image.get_height(),roundi(socket.y)+14)):
		var low := image.get_width()
		var high := 0
		for x in range(maxi(0,roundi(socket.x)-image.get_width()/4),mini(image.get_width(),roundi(socket.x)+image.get_width()/4)):
			var c := image.get_pixel(x,y)
			if c.a>.65 and c.b>c.r*1.08 and c.b>=c.g*.95: low=mini(low,x); high=maxi(high,x)
		if high>=low: widths.append(high-low+1)
	widths.sort()
	return widths[widths.size()/2] if not widths.is_empty() else 16.0

func density(first: Image,view: String) -> Vector2:
	var ref := native_ref(view)
	var source_neck := neck(first)
	var target_neck := neck(ref.image)
	var sy: float = (94-target_neck.y)/(first.get_used_rect().end.y-1-source_neck.y)
	var sx: float = armor_width(ref.image,target_neck)/armor_width(first,source_neck)
	return Vector2(clampf(sx,sy*.70,sy*1.1),sy)

func place(part: Image,scale: Vector2,view: String,authored_socket := Vector2.INF) -> Dictionary:
	var socket := neck(part) if authored_socket==Vector2.INF else authored_socket
	var resized: Image = part.duplicate()
	resized.resize(maxi(1,roundi(part.get_width()*scale.x)),maxi(1,roundi(part.get_height()*scale.y)),Image.INTERPOLATE_NEAREST)
	var offset := Vector2i(roundi(96-socket.x*scale.x),94-resized.get_used_rect().end.y+1)
	var body := Image.create(192,128,false,Image.FORMAT_RGBA8)
	body.blit_rect(resized,Rect2i(Vector2i.ZERO,resized.get_size()),offset)
	return {"body":body,"socket":Vector2(offset)+socket*scale,"offset":offset,"scale":scale}

func freeze_head(body: Image,view: String,socket: Vector2,grips: Array=[]) -> Rect2i:
	var ref := native_ref(view)
	var source: Image = ref.image
	var original_head: Rect2i = ref.head
	var target_socket := neck(source)
	var shift := Vector2i(roundi(96-target_socket.x),roundi(socket.y-target_socket.y))
	var head := Rect2i(original_head.position+shift,original_head.size)
	# Remove the complete generated scalp/face matte, including brown hair.
	# Preserve only real raised palms near registered guide grips.
	for y in range(0,mini(128,roundi(socket.y)-1)):
		for x in range(58,135):
			var c := body.get_pixel(x,y)
			var preserve := c.a>.65 and c.r>.25 and c.r>c.g*2.2 and c.r>c.b*1.8
			for grip in grips:
				var shoulder: Vector2 = socket+Vector2(signf(grip.x-socket.x)*7,4)
				if Vector2(x,y).distance_to(Geometry2D.get_closest_point_to_segment(Vector2(x,y),grip,shoulder))<4: preserve=true
			if not preserve: body.set_pixel(x,y,Color.TRANSPARENT)
	# Native silhouettes remain exact pixels; no resize of a head crop.
	for y in original_head.size.y:
		for x in original_head.size.x:
			var c := source.get_pixelv(original_head.position+Vector2i(x,y))
			if c.a>.65 and original_head.position.y+y<target_socket.y-1:
				var target := head.position+Vector2i(x,y)
				var occluded := false
				for grip in grips:
					if Vector2(target).distance_to(grip)<4 and body.get_pixelv(target).a>.65: occluded=true
				if not occluded and Rect2i(0,0,192,128).has_point(target): body.set_pixelv(target,c)
	return head

func axe_guide(cell: Dictionary) -> Dictionary:
	var shaft: Array = cell.shaft
	var blade: Array = cell.blade
	if shaft.is_empty(): return {}
	var center := Vector2.ZERO
	for point in shaft: center+=point
	center/=shaft.size()
	var xx:=0.0; var yy:=0.0; var xy:=0.0
	for point in shaft:
		var d: Vector2 = point-center
		xx+=d.x*d.x; yy+=d.y*d.y; xy+=d.x*d.y
	var axis := Vector2.from_angle(.5*atan2(2*xy,xx-yy))
	var tip := Vector2.ZERO
	for point in blade: tip+=point
	if blade.is_empty(): tip=center+(center-neck(cell.image)-Vector2(cell.crop.position)).normalized()*10
	else: tip/=blade.size()
	if axis.dot(tip-center)<0: axis=-axis
	# Actual leather touching the authored shaft, excluding head and boots.
	var image: Image = cell.image
	var best := INF
	var palm := Vector2.ZERO
	var socket := neck(image)
	for y in range(0,mini(image.get_height(),roundi(socket.y)+roundi(image.get_height()*.38))):
		for x in image.get_width():
			var c := image.get_pixel(x,y)
			if c.a<.8 or c.r<.18 or c.r>.85 or c.r<c.g*1.25 or c.g<c.b*1.15: continue
			if y<socket.y-3 and absf(x-socket.x)<image.get_width()*.15: continue
			var raw := Vector2(x,y)+Vector2(cell.crop.position)
			var perpendicular := absf((raw-center).cross(axis))
			var score := perpendicular+raw.distance_to(center)*.05
			if score<best: best=score; palm=Vector2(x,y)
	return {"grip":palm,"axis":axis,"distance":best}

func save_clip(clip: Resource,folder: String,label: String,followups: Array=[]) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
	clip.body_atlas.get_image().save_png(folder+label+"_body.png")
	clip.hand_atlas.get_image().save_png(folder+label+"_hands.png")
	var offhand: Resource = clip.offhand
	var separate_texture: bool = offhand!=null and offhand.texture.resource_path!=clip.weapon_texture.resource_path
	var count := 5+followups.size()+(2 if offhand!=null else 0)+(1 if separate_texture else 0)
	var text := "[gd_resource type=\"Resource\" load_steps=%d format=3]\n"%count
	var paths := ["res://data/weapons/weapon_family_pose_definition.gd",folder+label+"_body.png",folder+label+"_hands.png",clip.weapon_texture.resource_path]
	for index in paths.size():
		text+="[ext_resource type=\"%s\" path=\"%s\" id=\"%s\"]\n"%[("Script" if index==0 else "Texture2D"),paths[index],str(index+1)]
	for index in followups.size(): text+="[ext_resource type=\"Resource\" path=\"%s%s.tres\" id=\"%s\"]\n"%[folder,followups[index],str(index+5)]
	if offhand!=null:
		if separate_texture: text+="[ext_resource type=\"Texture2D\" path=\"%s\" id=\"other_texture\"]\n"%offhand.texture.resource_path
		text+="[ext_resource type=\"Script\" path=\"res://data/weapons/offhand_pose_definition.gd\" id=\"offhand_script\"]\n[sub_resource type=\"Resource\" id=\"offhand\"]\nscript = ExtResource(\"offhand_script\")\ntexture = ExtResource(\"%s\")\n"%("other_texture" if separate_texture else "4")
		for property in offhand.get_property_list():
			if property.usage&PROPERTY_USAGE_SCRIPT_VARIABLE and property.name!="texture": text+=property.name+" = "+var_to_str(offhand.get(property.name))+"\n"
	text+="[resource]\nscript = ExtResource(\"1\")\nbody_atlas = ExtResource(\"2\")\nhand_atlas = ExtResource(\"3\")\nweapon_texture = ExtResource(\"4\")\n"
	for property in clip.get_property_list():
		if property.usage&PROPERTY_USAGE_SCRIPT_VARIABLE and property.name not in ["body_atlas","hand_atlas","weapon_texture","offhand","planting","follow_up_clips"]:
			text+=property.name+" = "+var_to_str(clip.get(property.name))+"\n"
	if offhand!=null: text+="offhand = SubResource(\"offhand\")\n"
	if not followups.is_empty():
		text+="follow_up_clips = Array[Resource](["
		for index in followups.size(): text+=("," if index else "")+"ExtResource(\"%s\")"%str(index+5)
		text+="])\n"
	FileAccess.open(folder+label+".tres",FileAccess.WRITE).store_string(text)
	for suffix in ["_body.png.import","_hands.png.import"]:
		var path: String = folder+label+suffix
		if FileAccess.file_exists(path):
			var settings := FileAccess.get_file_as_string(path).replace("process/fix_alpha_border=true","process/fix_alpha_border=false")
			FileAccess.open(path,FileAccess.WRITE).store_string(settings)
