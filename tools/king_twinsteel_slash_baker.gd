extends RefCounted

## Offline atlas packing. Runtime rotates this common artwork in its floor plane.
const Native=preload("res://tools/king_native_identity.gd")
const Attack=preload("res://tools/king_twinsteel_attack_baker.gd")
const DEST="res://assets/characters/playable/king/dual_v2/slash.png"

func build() -> Image:
	var atlas:=Image.create(768,960,false,Image.FORMAT_RGBA8)
	var native:=Native.new()
	for row in 5:
		var source:=Image.load_from_file(Attack.SOURCE+"slash-"+Attack.ACTIONS[row]+".png")
		var cuts:=PackedInt32Array([0])
		for col in range(1,4): cuts.append(native.gutter(source,true,roundi(col*source.get_width()/4.0),roundi(source.get_width()*.1),Rect2i(Vector2i.ZERO,source.get_size())))
		cuts.append(source.get_width())
		var frames: Array[Image]=[]
		var largest:=Vector2i.ZERO
		for col in 4:
			var frame:=source.get_region(Rect2i(cuts[col],0,cuts[col+1]-cuts[col],source.get_height()))
			for y in frame.get_height():
				for x in frame.get_width():
					var c:=frame.get_pixel(x,y)
					if c.a<.45: frame.set_pixel(x,y,Color.TRANSPARENT)
			var bounds:=frame.get_used_rect()
			assert(bounds.size.x>0 and bounds.position.x>0 and bounds.end.x<frame.get_width(),"Cut generated slash gutter")
			frame=frame.get_region(bounds)
			frames.append(frame)
			largest.x=maxi(largest.x,frame.get_width())
			largest.y=maxi(largest.y,frame.get_height())
		var density:=minf(120.0/largest.x,(64.0 if row==3 else 112.0)/largest.y)
		for col in 4:
			var frame: Image=frames[col]
			frame.resize(maxi(1,roundi(frame.get_width()*density)),maxi(1,roundi(frame.get_height()*density)),Image.INTERPOLATE_NEAREST)
			for y in frame.get_height():
				for x in frame.get_width():
					var c:=frame.get_pixel(x,y)
					if c.a<.45: continue
					var light: float=maxf(c.r,maxf(c.g,c.b))
					c=Color(roundf(light*31)/31,roundf(minf(1,light*1.01)*31)/31,roundf(minf(1,light*1.05)*31)/31,1)
					frame.set_pixel(x,y,c)
			var at:=Vector2i(col*192+96-frame.get_width()/2,row*192+96-frame.get_height()/2)
			atlas.blit_rect(frame,Rect2i(Vector2i.ZERO,frame.get_size()),at)
	return atlas
