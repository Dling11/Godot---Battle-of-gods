extends Node

## Escape remains responsive while the lessons modal pauses its world owner.
var court: Node

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _unhandled_input(event: InputEvent) -> void:
	if is_instance_valid(court.menu) and court.menu.visible and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		court.close_menu()
