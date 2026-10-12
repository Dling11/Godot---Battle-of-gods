class_name Stage5BossRootPrison
extends Node2D

const PrisonTexture = preload("res://assets/characters/enemies/stage_5_boss/stage_5_boss_root_prison_sheet_128x112.png")
const ExecutionTexture = preload("res://assets/characters/enemies/stage_5_boss/stage_5_boss_root_execution_sheet_192x192.png")

@onready var prison: AnimatedSprite2D = $Prison
@onready var execution: AnimatedSprite2D = $Execution
@onready var struggle_prompt: Label = $StrugglePrompt

var _target: Player
var _source: Node
var _tracking := false


func _ready() -> void:
	prison.sprite_frames = _build_frames(PrisonTexture, Vector2i(128, 112), {
		&"warning": [0, 2, 7.0, true],
		&"capture": [2, 4, 4.0, true],
		&"crack_one": [4, 5, 1.0, false],
		&"crack_two": [5, 6, 1.0, false],
		&"break": [6, 8, 7.0, false],
	})
	execution.sprite_frames = _build_frames(ExecutionTexture, Vector2i(192, 192), {
		&"execute": [0, 8, 8.5, false],
	})
	prison.play(&"warning")
	execution.hide()


func begin_tracking(target: Player, source: Node) -> void:
	_target = target
	_source = source
	_tracking = is_instance_valid(target)
	if _tracking:
		global_position = target.global_position


func lock_target(captured: bool, total_break_points: int) -> void:
	_tracking = false
	prison.z_index = 2 if captured else -1
	if captured:
		prison.play(&"capture")
		struggle_prompt.text = "MASH DASH / TAP  •  0/%d" % total_break_points
		struggle_prompt.show()
	else:
		prison.frame = 1


func bind_restraint(target: Player, source: Node) -> void:
	_target = target
	_source = source
	if not target.restraint_progress.is_connected(_on_restraint_progress):
		target.restraint_progress.connect(_on_restraint_progress)
	if not target.restraint_ended.is_connected(_on_restraint_ended):
		target.restraint_ended.connect(_on_restraint_ended)


func play_execution() -> void:
	_tracking = false
	prison.hide()
	execution.show()
	execution.play(&"execute")
	await execution.animation_finished
	await get_tree().create_timer(0.8).timeout
	var tween := create_tween()
	tween.tween_property(execution, "modulate:a", 0.0, 0.45)
	await tween.finished
	queue_free()


func cancel_effect() -> void:
	_disconnect_target()
	queue_free()


func _process(_delta: float) -> void:
	if _tracking and is_instance_valid(_target):
		global_position = _target.global_position


func _on_restraint_progress(source: Node, remaining: int, total: int) -> void:
	if source != _source or total <= 0:
		return
	var removed := total - remaining
	struggle_prompt.text = "MASH DASH / TAP  •  %d/%d" % [removed, total]
	if removed >= total:
		prison.play(&"break")
	elif removed >= 3:
		prison.play(&"crack_two")
	elif removed >= 1:
		prison.play(&"crack_one")


func _on_restraint_ended(source: Node, escaped: bool) -> void:
	if source != _source:
		return
	if escaped:
		prison.play(&"break")
	struggle_prompt.hide()
	_disconnect_target()


func _disconnect_target() -> void:
	if is_instance_valid(_target):
		if _target.restraint_progress.is_connected(_on_restraint_progress):
			_target.restraint_progress.disconnect(_on_restraint_progress)
		if _target.restraint_ended.is_connected(_on_restraint_ended):
			_target.restraint_ended.disconnect(_on_restraint_ended)
	_target = null


func _build_frames(texture: Texture2D, cell: Vector2i, animations: Dictionary) -> SpriteFrames:
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	for animation: StringName in animations:
		var contract: Array = animations[animation]
		frames.add_animation(animation)
		frames.set_animation_speed(animation, float(contract[2]))
		frames.set_animation_loop(animation, bool(contract[3]))
		for column in range(int(contract[0]), int(contract[1])):
			var atlas := AtlasTexture.new()
			atlas.atlas = texture
			atlas.region = Rect2(column * cell.x, 0, cell.x, cell.y)
			frames.add_frame(animation, atlas)
	return frames
