extends SceneTree

## Native pixel proof: clipped light fades inside contact, without atlas bleed.
const Trail = preload("res://gameplay/presentation/axe_swing_trail.gd")
var checks := 0
var failures := 0

func check(ok: bool,message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var view := SubViewport.new()
	view.size = Vector2i(96,96)
	view.transparent_bg = true
	view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(view)
	var texture_image := Image.create(384,288,false,Image.FORMAT_RGBA8)
	texture_image.fill(Color.WHITE)
	var trail := Trail.new()
	trail.atlas = ImageTexture.create_from_image(texture_image)
	trail._attack = MeleeAttackComponent.new()
	root.add_child(trail._attack)
	trail.position = Vector2(32,32)
	trail.edge_feather_pixels = 3
	view.add_child(trail)
	trail._points = PackedVector2Array([Vector2(0,0),Vector2(32,0),Vector2(32,32),Vector2(0,32)])
	trail.prepare_edge_feather()
	trail._set_frame(0)
	await process_frame
	await RenderingServer.frame_post_draw
	var image := view.get_texture().get_image()
	check(image.get_pixel(31,48).a==0,"Light extends outside authoritative contact")
	check(image.get_pixel(32,48).a>0 and image.get_pixel(32,48).a<0.35,"Contact edge remains hard")
	check(image.get_pixel(33,48).a>image.get_pixel(32,48).a,"Border fails to fade inward")
	check(image.get_pixel(35,48).a>0.85 and image.get_pixel(48,48).a>0.85,"Feather dims the full attack interior")
	trail.clear()
	await process_frame
	await RenderingServer.frame_post_draw
	check(view.get_texture().get_image().get_used_rect().size==Vector2i.ZERO,"Clear leaves contact light")
	var art: Image = load("res://assets/characters/playable/king/axe_proof_v3/swing.png").get_image()
	for row in 5:
		for frame in 4:
			var border_empty := true
			for pixel in 128:
				for point in [Vector2i(frame*128+pixel,row*128),Vector2i(frame*128+pixel,row*128+127),Vector2i(frame*128,row*128+pixel),Vector2i(frame*128+127,row*128+pixel)]:
					if art.get_pixelv(point).a>0: border_empty = false
			check(border_empty,"Raster frame touches atlas border")
	var attack: MeleeAttackComponent = trail._attack
	view.queue_free()
	attack.queue_free()
	await process_frame
	print("AXE_TRAIL_EDGE checks=%d failures=%d" % [checks,failures])
	quit(1 if failures else 0)
