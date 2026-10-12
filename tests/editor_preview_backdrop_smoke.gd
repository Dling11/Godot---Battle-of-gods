extends SceneTree

const PREVIEW_SCENES := [
	"res://gameplay/expeditions/expedition_altar.tscn",
	"res://environment/props/sanctuary/divine_fountain.tscn",
	"res://entities/npcs/skillkeeper/skillkeeper.tscn",
	"res://entities/npcs/armskeeper/armskeeper.tscn",
]


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	for scene_path: String in PREVIEW_SCENES:
		var packed_scene := load(scene_path) as PackedScene
		if packed_scene == null:
			_fail("Could not load preview-enabled scene: %s" % scene_path)
			return
		var instance := packed_scene.instantiate()
		root.add_child(instance)
		var backdrop := instance.get_node_or_null("EditorPreviewBackdrop") as EditorPreviewBackdrop
		if backdrop == null:
			_fail("Scene has no editor preview backdrop: %s" % scene_path)
			return
		if backdrop.process_mode != Node.PROCESS_MODE_DISABLED:
			_fail("Editor preview performs runtime processing: %s" % scene_path)
			return
		if Engine.is_editor_hint():
			edited_scene_root = instance
			if not backdrop.is_editor_preview_active():
				_fail("Editor preview did not activate for its isolated scene: %s" % scene_path)
				return
			edited_scene_root = null
		elif backdrop.is_editor_preview_active():
			_fail("Editor preview became visible during runtime: %s" % scene_path)
			return
		if not Engine.is_editor_hint():
			await process_frame
			if instance.has_node("EditorPreviewBackdrop"):
				_fail("Editor preview remained in the runtime scene tree: %s" % scene_path)
				return
		instance.queue_free()
		await process_frame
	print("Editor preview backdrop smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
