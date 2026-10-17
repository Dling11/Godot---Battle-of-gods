extends Button

## Native delayed mouse tooltip; the same nonblocking card is available on focus.
const VeilStyle = preload("res://ui/hud/veil_theme.gd")
var content_provider: Callable
var _focus_card: Control
var _focus_layer: CanvasLayer
var _mouse_card: WeakRef

func configure_tooltip(provider: Callable) -> void:
	content_provider = provider
	var tooltip_theme := Theme.new()
	tooltip_theme.set_stylebox("panel","TooltipPanel",StyleBoxEmpty.new())
	theme = tooltip_theme
	tooltip_text = "Details"
	focus_mode = Control.FOCUS_ALL
	if not focus_entered.is_connected(_show_focus_card):
		focus_entered.connect(_show_focus_card)
		focus_exited.connect(_hide_focus_card)
		pressed.connect(_hide_focus_card)
		visibility_changed.connect(_hide_focus_card)

func _make_custom_tooltip(_text: String) -> Object:
	var card := create_card()
	_mouse_card = weakref(card)
	return card

func _input(event: InputEvent) -> void:
	# Space is gameplay dodge, even after clicking/focusing a skill button.
	# Release GUI focus before Button can interpret the shared ui_accept key.
	if has_focus() and event.is_action_pressed("player_dodge"):
		release_focus()

func create_card() -> PanelContainer:
	var data: Dictionary = content_provider.call() if content_provider.is_valid() else {}
	var compact: bool = data.get("compact",false)
	var card := PanelContainer.new()
	card.name = "VeilHoverCard"
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxEmpty.new()
	style.set_content_margin_all(10 if compact else 12)
	card.add_theme_stylebox_override("panel",style)
	VeilStyle.framed_backdrop(card,VeilStyle.TOOLTIP_FRAME,Vector4(8,8,8,8))
	var stack := VBoxContainer.new()
	stack.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stack.name = "Fields"
	stack.add_theme_constant_override("separation",3 if compact else 5)
	card.add_child(stack)
	for field in ["title","subtitle","body","footer"]:
		var label := Label.new()
		label.name = field
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.add_theme_font_override("font",VeilStyle.DISPLAY_FONT if field == "title" else VeilStyle.BODY_FONT)
		label.add_theme_font_size_override("font_size",(10 if compact else 12) if field == "title" else (8 if compact else 9))
		label.add_theme_color_override("font_color",Color("f1eff5") if field in ["title","body"] else Color("b8c9dd"))
		stack.add_child(label)
		if field == "subtitle":
			var facts := RichTextLabel.new()
			facts.name = "facts"
			facts.bbcode_enabled = true
			facts.fit_content = true
			facts.scroll_active = false
			facts.mouse_filter = Control.MOUSE_FILTER_IGNORE
			facts.add_theme_font_override("normal_font",VeilStyle.BODY_FONT)
			facts.add_theme_font_size_override("normal_font_size",9)
			facts.add_theme_font_override("bold_font",VeilStyle.BODY_FONT)
			facts.add_theme_font_size_override("bold_font_size",9)
			facts.add_theme_font_override("italics_font",VeilStyle.BODY_FONT)
			facts.add_theme_font_size_override("italics_font_size",9)
			stack.add_child(facts)
		if field == "title":
			var icon := TextureRect.new()
			icon.name = "Icon"
			icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			icon.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
			icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
			icon.position = Vector2(0,1)
			icon.size = Vector2(15,15) if compact else Vector2(17,17)
			label.add_child(icon)
			var separator := HSeparator.new()
			separator.name = "Separator"
			separator.mouse_filter = Control.MOUSE_FILTER_IGNORE
			var line := StyleBoxLine.new()
			line.color = Color("a9b8d47a")
			line.thickness = 1
			separator.add_theme_stylebox_override("separator",line)
			stack.add_child(separator)
	_update_card(card)
	return card

func refresh_open_card() -> void:
	if is_instance_valid(_focus_card):
		_update_card(_focus_card)
		_position_focus_card.call_deferred()
	if _mouse_card != null and is_instance_valid(_mouse_card.get_ref()):
		_update_card(_mouse_card.get_ref())

func _update_card(card: Control) -> void:
	var data: Dictionary = content_provider.call() if content_provider.is_valid() else {"title":text,"body":tooltip_text}
	for field in ["title","subtitle","body","footer"]:
		var label := card.get_node("Fields/"+field) as Label
		label.custom_minimum_size.x = 128 if data.get("compact",false) else 238
		var value := str(data.get(field,""))
		if label.text != value: label.text = value
		label.visible = not value.is_empty()
		if field=="subtitle": label.add_theme_color_override("font_color",data.get("subtitle_color",Color("b8c9dd")))
	var facts := card.get_node("Fields/facts") as RichTextLabel
	facts.custom_minimum_size.x = 128 if data.get("compact",false) else 238
	var fact_text := str(data.get("facts",""))
	if facts.text!=fact_text: facts.text = fact_text
	facts.visible = not fact_text.is_empty()
	var title_label := card.get_node("Fields/title") as Label
	var icon := title_label.get_node("Icon") as TextureRect
	icon.texture = data.get("icon") as Texture2D
	icon.visible = icon.texture != null
	var title_style := StyleBoxEmpty.new()
	title_style.set_content_margin(SIDE_LEFT,23 if icon.visible else 0)
	title_style.set_content_margin(SIDE_TOP,2)
	title_style.set_content_margin(SIDE_BOTTOM,2)
	title_label.add_theme_stylebox_override("normal",title_style)

func _show_focus_card() -> void:
	_hide_focus_card()
	_focus_card = create_card()
	_focus_layer = CanvasLayer.new()
	_focus_layer.layer = 100
	get_tree().root.add_child(_focus_layer)
	_focus_layer.add_child(_focus_card)
	_position_focus_card.call_deferred()

func _position_focus_card() -> void:
	if not is_instance_valid(_focus_card): return
	var bounds := get_viewport_rect()
	var box := get_global_rect()
	var minimum := _focus_card.get_combined_minimum_size()
	_focus_card.size = minimum
	_focus_card.position = Vector2(clampf(box.get_center().x-minimum.x/2,6,bounds.size.x-minimum.x-6),maxf(6,box.position.y-minimum.y-7))
	if box.position.y < minimum.y+12:
		_focus_card.position.y = minf(box.end.y+7,bounds.size.y-minimum.y-6)

func _hide_focus_card() -> void:
	if is_instance_valid(_focus_layer): _focus_layer.queue_free()
	_focus_card = null
	_focus_layer = null

func _exit_tree() -> void:
	_hide_focus_card()

func _notification(what: int) -> void:
	if what == NOTIFICATION_PAUSED:
		_hide_focus_card()
