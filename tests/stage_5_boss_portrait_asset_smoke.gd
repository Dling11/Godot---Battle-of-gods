extends SceneTree

const PORTRAIT_PATH := "res://assets/characters/enemies/portraits/stage_5_boss_portrait_96x96.png"


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var portrait := Image.load_from_file(ProjectSettings.globalize_path(PORTRAIT_PATH))
	if portrait == null or portrait.is_empty():
		_fail("Stage 5 boss portrait did not load.")
		return
	if portrait.get_size() != Vector2i(96, 96):
		_fail("Stage 5 boss portrait must remain exactly 96x96.")
		return
	if portrait.detect_alpha() == Image.ALPHA_NONE:
		_fail("Stage 5 boss portrait lost its transparent background.")
		return

	for corner in [Vector2i(0, 0), Vector2i(95, 0), Vector2i(0, 95), Vector2i(95, 95)]:
		if portrait.get_pixelv(corner).a > 0.0:
			_fail("Stage 5 boss portrait lost its transparent corner margin at %s." % corner)
			return

	var used_rect := portrait.get_used_rect()
	if used_rect.size.x < 72 or used_rect.size.y < 72:
		_fail("Stage 5 boss portrait silhouette became too small for dialogue readability: %s." % used_rect)
		return
	if used_rect.position.x < 1 or used_rect.position.y < 1 or used_rect.end.x > 95 or used_rect.end.y > 95:
		_fail("Stage 5 boss portrait no longer retains its transparent canvas margin: %s." % used_rect)
		return

	print("PASS: Stage 5 boss portrait is a readable transparent 96x96 presentation asset.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
