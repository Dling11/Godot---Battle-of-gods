extends Control

## Native objective and receipt controls. No reward, progression or travel grants.
signal report_requested
signal return_requested
signal report_closed

const FrameKit = preload("res://ui/inventory/centered_paperdoll_presenter.gd")
const ThemeKit = preload("res://ui/themes/sanctuary_theme.gd")
const Readout = preload("res://ui/hud/progression_readout.gd")

var tracker: PanelContainer
var heading: Label
var objective: Label
var status: Label
var progress: ProgressBar
var report_button: Button
var backdrop: ColorRect
var report: PanelContainer
var report_title: Label
var report_stage: Label
var xp_label: Label
var gold_label: Label
var growth_label: Label
var items: VBoxContainer
var rewards_scroll: ScrollContainer
var explore_button: Button
var return_button: Button
var _owns_pause := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	theme = ThemeKit.build()
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_build_tracker()
	_build_report()

func _build_tracker() -> void:
	tracker = PanelContainer.new()
	tracker.name = "ObjectiveTracker"
	add_child(tracker)
	tracker.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	tracker.offset_left = -264
	tracker.offset_right = -12
	tracker.offset_top = 90
	tracker.offset_bottom = 196
	tracker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tracker.add_theme_stylebox_override("panel", FrameKit.frame())
	var column := _column(tracker, 10, 8)
	heading = _label(column, "", 9, Color("d6c191"))
	heading.clip_text = true
	heading.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	objective = _label(column, "Prepare for the encounter", 11)
	objective.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status = _label(column, "", 9, Color("b1a7cf"))
	progress = ProgressBar.new()
	progress.custom_minimum_size.y = 5
	progress.show_percentage = false
	progress.add_theme_font_size_override("font_size", 1)
	column.add_child(progress)
	report_button = _button(column, "VIEW REWARDS", func() -> void: report_requested.emit())
	report_button.hide()

func _build_report() -> void:
	backdrop = ColorRect.new()
	backdrop.color = Color(0.01, 0.015, 0.025, .78)
	add_child(backdrop)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.hide()
	report = PanelContainer.new()
	report.name = "CompletionReceipt"
	add_child(report)
	report.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	report.offset_left = -320
	report.offset_right = 320
	report.offset_top = -210
	report.offset_bottom = 210
	report.add_theme_stylebox_override("panel", FrameKit.frame())
	var column := _column(report, 16, 12)
	var header := HBoxContainer.new()
	column.add_child(header)
	report_title = _label(header, "STAGE COMPLETE", 12, Color("d6c191"))
	report_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var close_button := _button(header, "CLOSE  [ESC]", close_report)
	close_button.size_flags_horizontal = Control.SIZE_SHRINK_END
	report_stage = _label(column, "", 17)
	report_stage.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var totals := HBoxContainer.new()
	totals.add_theme_constant_override("separation", 10)
	column.add_child(totals)
	xp_label = _stat(totals, "XP CREDITED", Color("a4cdf4"))
	gold_label = _stat(totals, "GOLD EARNED", Color("eac56c"))
	growth_label = _stat(totals, "PLAYER LEVEL", Color("c5a2e9"))
	_label(column, "COLLECTED MATERIALS & UNLOCKS", 10, Color("d6c191"))
	rewards_scroll = ScrollContainer.new()
	rewards_scroll.custom_minimum_size.y = 128
	rewards_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	rewards_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	rewards_scroll.follow_focus = true
	column.add_child(rewards_scroll)
	items = VBoxContainer.new()
	items.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	items.add_theme_constant_override("separation", 5)
	rewards_scroll.add_child(items)
	_label(column, "Collected rewards are in your bag. Explore to collect any remaining drops.", 10, Color("a1aabd")).autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 10)
	column.add_child(actions)
	explore_button = _button(actions, "KEEP EXPLORING", close_report)
	return_button = _button(actions, "RETURN TO SANCTUARY", func() -> void: return_requested.emit())
	explore_button.focus_neighbor_right = explore_button.get_path_to(return_button)
	return_button.focus_neighbor_left = return_button.get_path_to(explore_button)
	report.hide()

func update_objective(route: ExpeditionDefinition, action: String, detail: String, value: float, maximum: float, complete: bool) -> void:
	heading.text = "%s · %s" % [route.route_label, route.display_name]
	heading.tooltip_text = heading.text
	objective.text = action
	status.text = detail
	progress.max_value = maxf(1, maximum)
	progress.value = value
	report_button.visible = complete

func present_receipt(receipt: Dictionary) -> void:
	report_title.text = receipt.clear_kind
	report_stage.text = receipt.stage
	xp_label.text = "+" + Readout.format_number(receipt.xp)
	gold_label.text = "+" + Readout.format_number(receipt.gold)
	growth_label.text = "%d → %d" % [receipt.start_level, receipt.level] if receipt.level > receipt.start_level else "LV. %d" % receipt.level
	xp_label.tooltip_text = "Only XP actually credited counts. XP stops at your current stage cap."
	for child in items.get_children():
		items.remove_child(child)
		child.queue_free()
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 5)
	items.add_child(grid)
	for stack: Dictionary in receipt.materials:
		var row := HBoxContainer.new()
		row.custom_minimum_size = Vector2(290, 30)
		grid.add_child(row)
		var icon := TextureRect.new()
		icon.custom_minimum_size = Vector2(24, 24)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.texture = stack.material.icon
		row.add_child(icon)
		var text := _label(row, "%s ×%d" % [stack.material.display_name, stack.quantity], 10)
		text.custom_minimum_size.x = 250
		text.clip_text = true
		text.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		text.tooltip_text = text.text
	if receipt.materials.is_empty():
		_label(items, "No materials collected this stage.", 11, Color("a1aabd"))
	for text: String in receipt.unlocks:
		var label := _label(items, "UNLOCKED · " + text, 11, Color("d6c191"))
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if receipt.overflow > 0:
		_label(items, "%d material units could not fit in full stacks." % receipt.overflow, 10, Color("dfa575"))
	if receipt.xp == 0:
		_label(items, "No XP credited. Enemy rewards and stage caps determine XP.", 10, Color("a1aabd")).autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

func open_report() -> void:
	if report.visible or get_tree().paused:
		return
	_owns_pause = true
	get_tree().paused = true
	backdrop.show()
	report.show()
	explore_button.grab_focus()

func close_report() -> void:
	if not report.visible:
		return
	report.hide()
	backdrop.hide()
	if _owns_pause:
		get_tree().paused = false
	_owns_pause = false
	report_closed.emit()

func _input(event: InputEvent) -> void:
	if report != null and report.visible and (event.is_action_pressed("ui_cancel") or event.is_action_pressed("player_character_menu")):
		get_viewport().set_input_as_handled()
		close_report()
	elif report != null and report.visible and event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_PAGEDOWN: rewards_scroll.scroll_vertical += 128
			KEY_PAGEUP: rewards_scroll.scroll_vertical -= 128
			KEY_HOME: rewards_scroll.scroll_vertical = 0
			KEY_END: rewards_scroll.scroll_vertical = int(rewards_scroll.get_v_scroll_bar().max_value)
			_: return
		get_viewport().set_input_as_handled()

func _column(parent: Control, horizontal: int, vertical: int) -> VBoxContainer:
	var margin := MarginContainer.new()
	parent.add_child(margin)
	for side in ["left", "right"]: margin.add_theme_constant_override("margin_" + side, horizontal)
	for side in ["top", "bottom"]: margin.add_theme_constant_override("margin_" + side, vertical)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 3)
	margin.add_child(column)
	return column

func _label(parent: Control, text: String, font_size: int, color: Color = Color("e8e2d4")) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	return label

func _button(parent: Control, text: String, action: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size.y = 24
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.add_theme_font_size_override("font_size", 10)
	button.pressed.connect(action)
	parent.add_child(button)
	return button

func _stat(parent: Control, caption: String, color: Color) -> Label:
	var column := VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(column)
	_label(column, caption, 9, color)
	return _label(column, "0", 18, color)
