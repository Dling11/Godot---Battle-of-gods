extends Node

signal enabled_changed(enabled: bool)

var enabled := false


func set_enabled(value: bool) -> bool:
	var accepted := value and OS.is_debug_build()
	if enabled == accepted:
		return enabled
	enabled = accepted
	enabled_changed.emit(enabled)
	return enabled


func toggle() -> bool:
	return set_enabled(not enabled)
