extends CanvasLayer

const LoadingView := preload("res://ui/transitions/quiet_loading_view.tscn")

signal transition_started(target_scene: String)
signal transition_finished(target_scene: String)
signal transition_failed(target_scene: String)
signal loading_progress_changed(progress: float)

var _overlay: ColorRect
var _loading_view: QuietLoadingView
var _transitioning := false
var _loading_path := ""
var _load_status := ResourceLoader.THREAD_LOAD_INVALID_RESOURCE
var _last_progress := -1.0

func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	_overlay = ColorRect.new()
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.color = Color.BLACK
	_overlay.modulate.a = 0.0
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_overlay)
	_loading_view = LoadingView.instantiate() as QuietLoadingView
	_loading_view.modulate.a = 0.0
	_loading_view.hide()
	add_child(_loading_view)
	set_process(false)

func _process(_delta: float) -> void:
	var progress: Array = []
	_load_status = ResourceLoader.load_threaded_get_status(_loading_path, progress)
	if not progress.is_empty():
		_report_progress(float(progress[0]))
	if _load_status != ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		set_process(false)

func transition_to(target_scene: String, portal_presentation: Dictionary = {}) -> bool:
	if _transitioning:
		return false
	if target_scene.is_empty() or not ResourceLoader.exists(target_scene, "PackedScene"):
		transition_failed.emit(target_scene)
		return false
	# Start IO before the fade. Only retrieve a completed request: get() would
	# otherwise block the main thread and freeze the mascot/seal.
	var error := ResourceLoader.load_threaded_request(target_scene, "PackedScene", false)
	if error != OK:
		transition_failed.emit(target_scene)
		return false
	var was_paused := get_tree().paused
	_transitioning = true
	_loading_path = target_scene
	_load_status = ResourceLoader.THREAD_LOAD_IN_PROGRESS
	_last_progress = -1.0
	set_process(true)
	_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	_loading_view.show()
	_loading_view.begin(target_scene, portal_presentation)
	get_tree().paused = true
	transition_started.emit(target_scene)
	var fade_out := create_tween().set_parallel(true)
	fade_out.tween_property(_overlay, "modulate:a", 1.0, 0.3)
	fade_out.tween_property(_loading_view, "modulate:a", 1.0, 0.3)
	await fade_out.finished
	while _load_status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		await get_tree().process_frame
	if _load_status != ResourceLoader.THREAD_LOAD_LOADED:
		return _restore_after_failure(target_scene, was_paused)
	var next_scene := ResourceLoader.load_threaded_get(target_scene) as PackedScene
	if next_scene == null:
		return _restore_after_failure(target_scene, was_paused)
	error = get_tree().change_scene_to_packed(next_scene)
	if error != OK:
		return _restore_after_failure(target_scene, was_paused)
	await get_tree().scene_changed
	await get_tree().process_frame
	_report_progress(1.0)
	get_tree().paused = false
	var fade_in := create_tween().set_parallel(true)
	fade_in.tween_property(_loading_view, "modulate:a", 0.0, 0.25)
	fade_in.tween_property(_overlay, "modulate:a", 0.0, 0.3)
	await fade_in.finished
	_release_overlay()
	transition_finished.emit(target_scene)
	return true

func _report_progress(progress: float) -> void:
	if is_equal_approx(_last_progress, progress):
		return
	_last_progress = progress
	_loading_view.set_loading_progress(progress)
	loading_progress_changed.emit(progress)

func _restore_after_failure(target_scene: String, was_paused: bool) -> bool:
	_overlay.modulate.a = 0.0
	_loading_view.modulate.a = 0.0
	get_tree().paused = was_paused
	_release_overlay()
	transition_failed.emit(target_scene)
	return false

func _release_overlay() -> void:
	_loading_view.finish()
	_loading_view.hide()
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_transitioning = false
	_loading_path = ""
	set_process(false)

func is_input_blocking() -> bool:
	return _overlay != null and _overlay.mouse_filter == Control.MOUSE_FILTER_STOP
