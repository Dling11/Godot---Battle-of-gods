extends PanelContainer

var actor: Player
var _label: Label
var _bar: ProgressBar
var _vow: UnbrokenVowComponent

func _ready() -> void:
	name = "VowStatus"
	position = Vector2(20, 146)
	custom_minimum_size = Vector2(170, 38)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = Color("101e2deb")
	style.border_color = Color("529acd")
	style.set_border_width_all(1)
	style.set_content_margin_all(5)
	add_theme_stylebox_override("panel", style)
	var stack := VBoxContainer.new()
	add_child(stack)
	_label = Label.new()
	_label.add_theme_font_size_override("font_size", 10)
	stack.add_child(_label)
	_bar = ProgressBar.new()
	_bar.show_percentage = false
	_bar.custom_minimum_size.y = 4
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color("64bcf5")
	_bar.add_theme_stylebox_override("fill", fill)
	stack.add_child(_bar)
	_vow = actor.get_node("UnbrokenVowComponent")
	actor.health_component.shield_changed.connect(func(_current: float, _maximum: float) -> void: _refresh())
	_vow.duration_changed.connect(func(_seconds: float) -> void: _refresh())
	_refresh()

func _refresh() -> void:
	visible = _vow.active
	var health := actor.health_component
	_label.text = "VOW  %d/%d  ·  %.1fs" % [ceili(health.shield_health), ceili(health.shield_maximum), _vow.remaining]
	_bar.max_value = maxf(1.0, health.shield_maximum)
	_bar.value = health.shield_health
