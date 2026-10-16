extends "res://tests/sanctuary_test_base.gd"

const LAB = preload("res://levels/combat_lab/combat_lab.tscn")
const ITEM = preload("res://data/items/equipment/king_iron_reaper.tres")
const AUDIT = "res://art_source/reference/characters/king/reaper-grounding.json"

func _run() -> void:
	root.get_node("SaveService").configure_storage_path_for_testing("user://iron_reaper_grounding_smoke.json")
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	var lab := LAB.instantiate()
	root.add_child(lab)
	current_scene = lab
	await process_frame
	lab.clear_simulation()
	lab._set_examiner_arena(false)
	var actor: Player = lab.player
	actor.set_physics_process(false)
	actor.apply_debug_testing_preset()
	actor.set_weapon_definition(ITEM.weapon_definition)
	var family: Node = actor.get_node("WeaponFamilyPresentation")
	family.set_physics_process(false)
	var presenter: Node2D = family.presenter
	presenter._rest_timer.stop()
	presenter._stop_tween()
	var audit: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(AUDIT))
	var samples := 0
	var peak := 0.0
	for record: Dictionary in audit.records:
		if not record.has("stance"): continue
		var parts: PackedStringArray = str(record.stance).split("-")
		var clip: Resource = load("res://assets/characters/playable/king/iron_reaper/%s/%s.tres" % [parts[0],parts[1]])
		check(clip.has_valid_layout(),"Centered clip has invalid grip/phase data")
		for reflected in ([false,true] if parts[0]=="side" else [false]):
			presenter.select_clip(clip)
			presenter.face_horizontal(-1 if reflected else 1)
			presenter.set_pose(int(record.key))
			var sole := Vector2(record.native_ground[0],record.native_ground[1])
			var world := presenter.to_global(sole-Vector2(clip.cell_size)*0.5)
			# Undo only intentional airborne lift; the circle stays on the floor.
			world.y -= clip.lift_pixels[int(record.key)]*0.5
			var error := world.distance_to(actor.get_node("CombatFootAura").global_position)
			peak = maxf(peak,error)
			check(error<=1.6,"Attack stance drifts from the actor's real ground circle")
			samples += 1
	check(samples==160,"Missing directional attack/queue stance checks")
	print("REAPER_GROUNDING samples=",samples," peak_world_error=",peak)
	lab.queue_free()
	current_scene = null
	await process_frame
	print("IRON_REAPER_GROUNDING checks=",checks," failures=",failures)
	quit(1 if failures else 0)
