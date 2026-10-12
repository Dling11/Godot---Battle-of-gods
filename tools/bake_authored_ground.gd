extends SceneTree


func _initialize() -> void:
	call_deferred("_bake")


func _bake() -> void:
	var input_path := _argument_value("--input=")
	var output_path := _argument_value("--output=")
	if input_path.is_empty() or output_path.is_empty():
		push_error("Usage: --input=res://level.tscn --output=res://level.tscn")
		quit(1)
		return
	var source := load(input_path) as PackedScene
	if source == null:
		push_error("Unable to load scene: %s" % input_path)
		quit(1)
		return
	var instance := source.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
	var ground := instance.get_node_or_null("World/Level/Ground") as TileMapLayer
	if ground == null or not ground.has_method("rebuild_from_layout"):
		push_error("Scene has no authored ground layer: %s" % input_path)
		quit(1)
		return
	var encounter_controller := instance.get_node_or_null("GameplayServices/EncounterController")
	var preserved_gated_waves := PackedInt32Array()
	if encounter_controller != null:
		preserved_gated_waves = encounter_controller.get("gated_wave_numbers").duplicate()
	ground.rebuild_from_layout()
	# Reassert encounter-owned scene overrides after the tool script touches the
	# instantiated graph. Stage III's dialogue gate must never be normalized to
	# the controller's empty default while baking presentation-only terrain.
	if encounter_controller != null:
		encounter_controller.set("gated_wave_numbers", preserved_gated_waves)
	var packed := PackedScene.new()
	var pack_error := packed.pack(instance)
	if pack_error != OK:
		push_error("Unable to pack authored scene: %s" % input_path)
		quit(1)
		return
	var save_error := ResourceSaver.save(packed, output_path)
	if save_error != OK:
		push_error("Unable to save authored scene: %s" % output_path)
		quit(1)
		return
	var cell_count := ground.get_used_cells().size()
	instance.free()
	print("Baked %d authored cells into %s" % [cell_count, output_path])
	quit(0)


func _argument_value(prefix: String) -> String:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with(prefix):
			return argument.trim_prefix(prefix)
	return ""
