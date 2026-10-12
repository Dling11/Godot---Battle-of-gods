class_name DialoguePanel
extends Control

signal dialogue_closed(completed: bool)

@onready var speaker_label: Label = %SpeakerLabel
@onready var body_label: Label = %BodyLabel
@onready var continue_button: Button = %ContinueButton
@onready var skip_button: Button = %SkipButton
@onready var portrait: TextureRect = %Portrait

var _entries: Array[Dictionary] = []
var _line_index := 0
var _owns_pause := false
var _accept_input := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()


func _unhandled_input(event: InputEvent) -> void:
	if not visible or not _accept_input:
		return
	if event is InputEventKey and (event as InputEventKey).echo:
		return
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		close_dialogue(false)
		return
	# Enter/Space are owned by the focused native button. Handling ui_accept here
	# as well would advance twice from one press.
	if event.is_action_pressed("player_interact"):
		get_viewport().set_input_as_handled()
		advance()


func show_dialogue(speaker: String, lines: Array[String], portrait_texture: Texture2D = null) -> void:
	if lines.is_empty():
		return
	var entries: Array[Dictionary] = []
	for line: String in lines:
		entries.append({
			"speaker": speaker,
			"text": line,
			"portrait": portrait_texture,
		})
	show_conversation(entries)


func show_conversation(entries: Array[Dictionary]) -> void:
	if entries.is_empty():
		return
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_entries = entries.duplicate(true)
	_line_index = 0
	_owns_pause = not get_tree().paused
	if _owns_pause:
		get_tree().paused = true
	show()
	_show_current_line()
	_accept_input = false
	continue_button.disabled = true
	call_deferred("_enable_input")


func advance() -> void:
	if not visible:
		return
	_line_index += 1
	if _line_index >= _entries.size():
		close_dialogue(true)
		return
	_show_current_line()


func close_dialogue(completed := false) -> void:
	if not visible:
		return
	hide()
	_accept_input = false
	if _owns_pause:
		get_tree().paused = false
	_owns_pause = false
	dialogue_closed.emit(completed)


func _show_current_line() -> void:
	var entry: Dictionary = _entries[_line_index]
	speaker_label.text = String(entry.get("speaker", ""))
	body_label.text = String(entry.get("text", ""))
	portrait.texture = entry.get("portrait") as Texture2D
	portrait.visible = portrait.texture != null
	continue_button.text = "F / ENTER / SPACE  •  %s" % ("CLOSE" if _line_index == _entries.size() - 1 else "CONTINUE")


func _enable_input() -> void:
	_accept_input = true
	continue_button.disabled = false
	continue_button.grab_focus()
