extends Control

## Presentation-only collection. Callers own effect lifetimes and actual values.
signal layout_changed
const TipButton = preload("res://ui/hud/hud_tooltip_button.gd")
const VeilStyle = preload("res://ui/hud/veil_theme.gd")
const ICON_SIZE := 22
const GAP := 4
const MAX_COLUMNS := 6
var _effects: Dictionary = {}
var _buttons: Dictionary = {}

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(_layout)
	hide()

func set_effect(id: StringName, data: Dictionary) -> void:
	var added := not _effects.has(id)
	var previous: Dictionary = _effects.get(id,{})
	var restyle := added or bool(previous.get("harmful",false)) != bool(data.get("harmful",false))
	var reorder := restyle or int(previous.get("priority",0)) != int(data.get("priority",0))
	data = data.duplicate()
	var card: Dictionary = data.get("card",{}).duplicate()
	card["icon"] = data.get("icon")
	card["compact"] = true
	data["card"] = card
	_effects[id] = data
	if added:
		var button := TipButton.new()
		button.name = "Effect_"+str(id)
		button.expand_icon = true
		button.add_theme_constant_override("icon_max_width",16)
		button.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		button.configure_tooltip(func() -> Dictionary: return _effects.get(id,{}).get("card",{}))
		add_child(button)
		var counter := Label.new()
		counter.name = "Counter"
		counter.mouse_filter = Control.MOUSE_FILTER_IGNORE
		counter.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		counter.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		counter.add_theme_font_size_override("font_size",8)
		counter.add_theme_color_override("font_outline_color",Color("060a12"))
		counter.add_theme_constant_override("outline_size",2)
		button.add_child(counter)
		counter.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		counter.offset_right = -1
		_buttons[id] = button
	var control: Button = _buttons[id]
	control.icon = data.get("icon") as Texture2D
	(control.get_node("Counter") as Label).text = str(data.get("counter",""))
	if restyle:
		var accent := Color("ef749e") if data.get("harmful",false) else VeilStyle.CYAN
		var art := VeilStyle.artwork(VeilStyle.STATUS_HARMFUL if data.get("harmful",false) else VeilStyle.STATUS_BENEFICIAL)
		control.add_theme_stylebox_override("normal",art)
		var over := art.duplicate() as StyleBoxTexture
		over.modulate_color = Color("ddecff")
		control.add_theme_stylebox_override("hover",over)
		control.add_theme_stylebox_override("pressed",over)
		control.add_theme_stylebox_override("focus",VeilStyle.panel(Color.TRANSPARENT,accent,2))
	control.refresh_open_card()
	if reorder:
		show()
		_layout()

func remove_effect(id: StringName) -> void:
	if not _effects.has(id): return
	var button: Control = _buttons[id]
	_effects.erase(id)
	_buttons.erase(id)
	remove_child(button)
	button.queue_free()
	visible = not _effects.is_empty()
	_layout()

func clear_effects() -> void:
	for id: StringName in _effects.keys(): remove_effect(id)

func get_effect_button(id: StringName) -> Button:
	return _buttons.get(id) as Button

func _layout() -> void:
	var columns := clampi(floori((size.x+GAP)/(ICON_SIZE+GAP)),1,MAX_COLUMNS)
	var ids := _effects.keys()
	ids.sort_custom(func(a: StringName,b: StringName) -> bool:
		var left: Dictionary = _effects[a]
		var right: Dictionary = _effects[b]
		if bool(left.get("harmful",false)) != bool(right.get("harmful",false)):
			return not left.get("harmful",false)
		return int(left.get("priority",0)) > int(right.get("priority",0)))
	for index in ids.size():
		var button: Control = _buttons[ids[index]]
		button.position = Vector2((index%columns)*(ICON_SIZE+GAP),(index/columns)*(ICON_SIZE+GAP))
		button.size = Vector2.ONE*ICON_SIZE
	var height := ceili(float(ids.size())/columns)*(ICON_SIZE+GAP)-GAP if not ids.is_empty() else 0
	if not is_equal_approx(size.y,height): size.y = height
	layout_changed.emit()
