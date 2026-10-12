extends "res://tests/sanctuary_test_base.gd"

const Portal = preload("res://gameplay/encounters/stage_portal.tscn")
const OUTPUT := "res://tmp/review/ui/portal_stability_2026_10_03/"
const KEYS := ["calm","ominous","grasp","maw","divine","unknowable"]

func _run() -> void:
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	if DisplayServer.get_name() == "headless":
		push_error("Portal surface stability requires the rendered Compatibility backend.")
		quit(1)
		return
	root.size = Vector2i(960,540)
	DirAccess.make_dir_recursive_absolute(OUTPUT)
	var viewport := SubViewport.new()
	viewport.size = Vector2i(192,160)
	viewport.transparent_bg = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	root.add_child(viewport)
	var report: Dictionary = {}
	for index in 6:
		var portal := Portal.instantiate() as StagePortal
		portal.portal_tier = [0,1,2,2,3,4][index] as StagePortal.PortalTier
		portal.boss_variant = 1 if index == 3 else 0
		viewport.add_child(portal)
		portal.position = Vector2(96,151)
		portal.portal_fx.hide()
		portal.guidance_arrow.hide()
		portal.offscreen_guide.hide()
		portal.set_process(false)
		await create_timer(.7).timeout
		portal._base_pulse.kill()
		var sprite := portal.portal_visual
		sprite.modulate = Color.WHITE
		sprite.pause()
		sprite.set_process(false)
		var surface := sprite.material as ShaderMaterial
		surface.set_shader_parameter("rim_glimmer_strength",0.0)
		var origin := sprite.position
		var scale_at_rest := sprite.scale
		var first: Image
		var inner_changes := [0,0,0]
		var alpha_changes := 0
		var sheet := Image.create(192*8,160,false,Image.FORMAT_RGBA8)
		for frame in 8:
			sprite.frame = frame
			surface.set_shader_parameter("frame_blend",0.0)
			await RenderingServer.frame_post_draw
			var image := viewport.get_texture().get_image()
			check(sprite.position == origin and sprite.scale == scale_at_rest, "Portal transform moves during its idle cycle")
			if frame == 0:
				first = image
				check(first.get_used_rect().has_area(), "Portal shader renders no silhouette")
			else:
				for y in 160:
					for x in 192:
						var current := image.get_pixel(x,y)
						var previous := first.get_pixel(x,y)
						if current.a != previous.a: alpha_changes += 1
						if x > 73 and x < 116 and y > 60 and y < 147 and current.a > .9 and current != previous:
							inner_changes[mini((y-60)/29,2)] += 1
			image.save_png(OUTPUT+KEYS[index]+"_frame_%d.png" % frame)
			sheet.blit_rect(image,Rect2i(Vector2i.ZERO,image.get_size()),Vector2i(frame*192,0))
			surface.set_shader_parameter("frame_blend",0.5)
			await RenderingServer.frame_post_draw
			var half := viewport.get_texture().get_image()
			var halfway_changes := 0
			for y in 160:
				for x in 192:
					if half.get_pixel(x,y).a != first.get_pixel(x,y).a: halfway_changes += 1
			check(halfway_changes == 0,"Interpolating currents moves the portal silhouette: "+KEYS[index])
			alpha_changes += halfway_changes
		check(alpha_changes == 0, "Rendered portal silhouette still changes between source frames: " + KEYS[index])
		for count: int in inner_changes:
			check(count > 20, "Stable portal lost current motion in an inner depth zone: "+KEYS[index])
		check(first.get_used_rect().end.y >= 147, "Portal foot anchor is too far off ground")
		sprite.frame = 7
		surface.set_shader_parameter("frame_blend",1.0)
		await RenderingServer.frame_post_draw
		var last := viewport.get_texture().get_image()
		check(last.get_data() == first.get_data(),"Portal loop seam jumps between frame7 and frame0: "+KEYS[index])
		sprite.set_process(true)
		sprite.play(&"active")
		await create_timer(.12).timeout
		var held_frame := sprite.frame
		var held_progress := sprite.frame_progress
		var held_blend: float = surface.get_shader_parameter("frame_blend")
		paused = true
		await create_timer(.12,true,false,true).timeout
		check(sprite.frame == held_frame and sprite.frame_progress == held_progress and surface.get_shader_parameter("frame_blend") == held_blend,"Portal surface keeps advancing while gameplay is paused")
		paused = false
		sheet.save_png(OUTPUT+KEYS[index]+"_registered.png")
		report[KEYS[index]] = {"changed_silhouette_pixels":alpha_changes,"inner_motion_pixels":inner_changes,"used":str(first.get_used_rect())}
		portal.free()
	FileAccess.open(OUTPUT+"rendered_geometry.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	viewport.queue_free()
	await process_frame
	await process_frame
	print("PORTAL_SURFACE_STABILITY: %d checks, %d failures; " % [checks,failures] + JSON.stringify(report))
	quit(1 if failures else 0)
