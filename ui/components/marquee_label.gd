class_name MarqueeLabel
extends Control

## A clipped single-line label that only scrolls when its text cannot fit.

@export_range(0.0, 24.0, 1.0) var horizontal_padding := 6.0
@export_range(4.0, 80.0, 1.0) var scroll_speed := 18.0
@export_range(0.0, 4.0, 0.1) var edge_hold_seconds := 1.0

var _label: Label
var _text := ""
var _font_size := 8
var _font_color := Color.WHITE
var _scroll_tween: Tween


func _ready() -> void:
	clip_contents = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label = Label.new()
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	add_child(_label)
	resized.connect(_queue_refresh)
	theme_changed.connect(_queue_refresh)
	_apply_label_style()
	_queue_refresh()


func configure(text_value: String, font_color: Color, font_size := 8) -> void:
	_text = text_value
	_font_color = font_color
	_font_size = font_size
	_apply_label_style()
	_queue_refresh()


func _apply_label_style() -> void:
	if not is_instance_valid(_label):
		return
	_label.text = _text
	_label.add_theme_color_override("font_color", _font_color)
	_label.add_theme_font_size_override("font_size", _font_size)


func _queue_refresh() -> void:
	if is_inside_tree():
		call_deferred("_refresh_overflow")


func _refresh_overflow() -> void:
	if not is_instance_valid(_label) or size.x <= 0.0:
		return
	if _scroll_tween != null and _scroll_tween.is_valid():
		_scroll_tween.kill()
	var available_width := maxf(size.x - horizontal_padding * 2.0, 1.0)
	var font := _label.get_theme_font("font")
	var text_width := ceilf(font.get_string_size(_text, HORIZONTAL_ALIGNMENT_LEFT, -1, _font_size).x)
	_label.position = Vector2(horizontal_padding, 0.0)
	_label.size = Vector2(maxf(text_width, available_width), size.y)
	if text_width <= available_width:
		return
	var travel := text_width - available_width
	var travel_seconds := maxf(travel / scroll_speed, 0.35)
	_scroll_tween = create_tween().set_loops()
	_scroll_tween.tween_interval(edge_hold_seconds)
	_scroll_tween.tween_property(
		_label,
		"position:x",
		horizontal_padding - travel,
		travel_seconds
	).set_trans(Tween.TRANS_LINEAR)
	_scroll_tween.tween_interval(edge_hold_seconds)
	_scroll_tween.tween_property(
		_label,
		"position:x",
		horizontal_padding,
		travel_seconds
	).set_trans(Tween.TRANS_LINEAR)
