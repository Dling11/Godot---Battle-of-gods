extends Node2D

## Small event-only review cue; it has no input, damage or timer authority.
var _label: Label
var _counter: Node

func configure(counter: Node) -> void:
	_counter = counter

func _ready() -> void:
	_label = Label.new()
	_label.text = "PURE COUNTER"
	_label.position = Vector2(-44,-63)
	_label.size = Vector2(88,16)
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label.add_theme_font_size_override("font_size",9)
	_label.add_theme_color_override("font_color",Color("ded1ff"))
	_label.add_theme_color_override("font_outline_color",Color("151421"))
	_label.add_theme_constant_override("outline_size",2)
	add_child(_label)
	_counter.counter_ready_changed.connect(func(ready: bool) -> void: visible = ready)
	visible = _counter.is_counter_ready()
