extends SceneTree

const Trail = preload("res://gameplay/presentation/greatsword_blade_trail.gd")
var failures := 0

func check(ok: bool,message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var view := SubViewport.new()
	view.size = Vector2i(192,128)
	view.transparent_bg = true
	view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(view)
	var texture := Image.create(384,288,false,Image.FORMAT_RGBA8)
	texture.fill(Color.GREEN)
	texture.fill_rect(Rect2i(0,0,96,96),Color.WHITE)
	var attack := MeleeAttackComponent.new()
	root.add_child(attack)
	var trail := Trail.new()
	trail.atlas = ImageTexture.create_from_image(texture)
	trail._attack = attack
	trail.position = Vector2(96,64)
	trail.edge_feather_pixels = 3
	view.add_child(trail)
	trail._points = PackedVector2Array([Vector2(-60,-20),Vector2(60,-20),Vector2(60,20),Vector2(-60,20)])
	for index in 4: trail.frame_sample_transforms.append(Transform2D(0,Vector2(48,48)))
	trail.prepare_edge_feather()
	trail._set_frame(0)
	await process_frame
	await RenderingServer.frame_post_draw
	var image := view.get_texture().get_image()
	check(image.get_pixel(96,64).a>0.85,"Registered interior lost")
	check(image.get_pixel(96,64).r>0.85,"Neighbor green sampled")
	check(image.get_pixel(142,64).a>0.85,"Valid cell texels clipped")
	check(image.get_pixel(146,64).a==0,"Neighbor frame bleeding across right cell boundary")
	check(image.get_pixel(44,64).a==0,"Neighbor frame bleeding across left cell boundary")
	trail.clear()
	await process_frame
	await RenderingServer.frame_post_draw
	check(view.get_texture().get_image().get_used_rect().size==Vector2i.ZERO,"Cancel leaves cell light")
	view.queue_free()
	attack.queue_free()
	await process_frame
	print("GREATSWORD_BLADE_ATLAS checks=6 failures=",failures)
	quit(1 if failures else 0)
