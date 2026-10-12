extends "res://tools/launch_generic_spawn_review.gd"

const OUT := "res://tmp/review/ui/targeting_recovery_2026_10_04/"
var checks := 0
var failures := 0

func _run() -> void:
	await super._run()
	root.size = Vector2i(960,540)
	toolbar.hide()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	for dark in [false,true]:
		_visit(Vector2(1040,480) if dark else Vector2(520,480))
		await create_timer(.4).timeout
		var actor: Player = stage.player
		for slot in [1,3,5]:
			var skill := actor.get_ability_component_for_slot(slot)
			skill.clear_cooldown()
			var aim := actor.ground_point_targeting
			check(aim.begin_targeting(skill,Vector2.RIGHT), "Slot %d failed to aim" % slot)
			aim.update_aim(actor.global_position+Vector2(155,30),Vector2.ZERO)
			# Freeze only the screenshot fixture's pointer; runtime is render-frame aiming.
			aim.set_process(false)
			check(aim._aim_origin() == actor.global_position, "Aiming origin left King's feet")
			check(root.get_node("CursorService").targeting_active, "Hardware aim cursor did not activate")
			await RenderingServer.frame_post_draw
			check(root.get_texture().get_image().save_png(OUT+"skill_%d_%s.png" % [slot,"dark" if dark else "grass"]) == OK,"Capture failed")
			aim.cancel_targeting()
			check(not aim.is_processing(),"Cancelled aim continued render work")
	var cursors := root.get_node("CursorService")
	var textures := [cursors.AIM_CURSOR,cursors.DEFAULT_CURSOR,cursors.INTERACT_CURSOR,cursors.TARGET_CURSOR]
	for texture: Texture2D in textures:
		var image := texture.get_image()
		check(image.get_pixel(0,0).a == 0.0, "Targeting art lacks transparent padding")
		var gold := 0
		for y in image.get_height():
			for x in image.get_width():
				var pixel := image.get_pixel(x,y)
				if pixel.a > .5 and pixel.r > .5 and pixel.g > .35 and pixel.b < pixel.r*.6: gold += 1
		check(gold == 0, "Owner-rejected gold remains in targeting artwork")
	check(root.get_node("SaveService").is_autosave_suppressed_for_debug(), "Art proof can mutate ordinary saves")
	stage.queue_free()
	await process_frame
	print("KING_TARGETING_ART checks=%d failures=%d" % [checks,failures])
	quit(1 if failures else 0)

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
