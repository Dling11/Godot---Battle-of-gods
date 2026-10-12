extends SceneTree

const Gallery = preload("res://tools/stage_presentation_gallery.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var save := root.get_node("SaveService")
	assert(save.configure_storage_path_for_testing("user://stage_presentation_review.json"))
	save.delete_profile()
	save.suppress_autosave_for_debug_session()
	root.size = Vector2i(960,540)
	root.title = "Battle of Gods • Stage presentation review • ISOLATED PROFILE"
	var gallery := Control.new()
	gallery.set_script(Gallery)
	root.add_child(gallery)
	current_scene = gallery
