class_name PauseMenu
extends Control

## Stage-local pause surface. It owns only modal presentation and requests a
## scene transition; progression/session state remains owned by autoloads.

@export_file("*.tscn") var sanctuary_scene := "res://levels/sanctuary/sanctuary.tscn"

@onready var resume_button: Button = %ResumeButton
@onready var music_button: Button = %MusicButton
@onready var sfx_button: Button = %SfxButton
@onready var ui_audio_button: Button = %UiAudioButton

var _owns_pause := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("pause_menu")
	hide()
	_refresh_audio_labels()


func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		close_menu()
		return
	if visible or get_tree().paused or not event.is_action_pressed("ui_pause"):
		return
	get_viewport().set_input_as_handled()
	open_menu()


func open_menu() -> void:
	if visible or get_tree().paused:
		return
	_owns_pause = true
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_refresh_audio_labels()
	show()
	resume_button.grab_focus()


func close_menu() -> void:
	if not visible:
		return
	hide()
	if _owns_pause:
		get_tree().paused = false
		_owns_pause = false


func return_to_sanctuary() -> void:
	## Intentionally preserves RunSession and WeaponInventory. It abandons only
	## this active scene/encounter, giving the player a safe route home.
	if sanctuary_scene.is_empty() or not ResourceLoader.exists(sanctuary_scene):
		push_error("PauseMenu requires a valid Sanctuary scene.")
		return
	if _owns_pause:
		get_tree().paused = false
		_owns_pause = false
	var transition_service := get_node_or_null("/root/SceneTransition")
	if transition_service == null:
		push_error("PauseMenu requires the SceneTransition autoload.")
		return
	var loot_service := get_node_or_null("/root/LootService")
	if loot_service != null:
		loot_service.abort_expedition_rewards()
	transition_service.transition_to(sanctuary_scene)


func quit_game() -> void:
	get_tree().quit()


func toggle_music() -> void:
	_toggle_bus(AudioDirector.MUSIC_BUS)


func toggle_sfx() -> void:
	_toggle_bus(AudioDirector.SFX_BUS)


func toggle_ui_audio() -> void:
	_toggle_bus(AudioDirector.UI_BUS)


func _toggle_bus(bus_name: String) -> void:
	var bus_index := AudioServer.get_bus_index(bus_name)
	if bus_index < 0:
		push_error("PauseMenu could not find the %s audio bus." % bus_name)
		return
	AudioServer.set_bus_mute(bus_index, not AudioServer.is_bus_mute(bus_index))
	_refresh_audio_labels()


func _refresh_audio_labels() -> void:
	music_button.text = _bus_label("MUSIC & AMBIENCE", AudioDirector.MUSIC_BUS)
	sfx_button.text = _bus_label("COMBAT SOUND", AudioDirector.SFX_BUS)
	ui_audio_button.text = _bus_label("MENU SOUND", AudioDirector.UI_BUS)


func _bus_label(label: String, bus_name: String) -> String:
	var bus_index := AudioServer.get_bus_index(bus_name)
	var state := "OFF" if bus_index >= 0 and AudioServer.is_bus_mute(bus_index) else "ON"
	return "%s  %s" % [label, state]


func _exit_tree() -> void:
	if _owns_pause and get_tree() != null:
		get_tree().paused = false
