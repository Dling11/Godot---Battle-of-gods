extends RefCounted

const FRAME = preload("res://assets/ui/sanctuary_theme/panel.png")
const BASE = preload("res://assets/ui/themes/battle_of_gods_theme.tres")

static func frame(inset: float = 0) -> StyleBoxTexture:
	var style := StyleBoxTexture.new()
	style.texture = FRAME
	style.texture_margin_left = 40
	style.texture_margin_right = 40
	style.texture_margin_top = 32
	style.texture_margin_bottom = 32
	style.set_content_margin_all(inset)
	return style

static func build() -> Theme:
	var theme := BASE.duplicate() as Theme
	theme.set_color("font_color","Label",Color(.91,.88,.79))
	theme.set_color("font_color","Button",Color(.91,.88,.79))
	theme.set_color("font_hover_color","Button",Color(1,.87,.55))
	theme.set_stylebox("panel","PanelContainer",_flat(Color(.045,.061,.078,.98),Color(.29,.26,.20)))
	theme.set_stylebox("normal","Button",_flat(Color(.07,.085,.105),Color(.42,.35,.23)))
	theme.set_stylebox("hover","Button",_flat(Color(.15,.16,.17),Color(.84,.68,.37)))
	theme.set_stylebox("pressed","Button",_flat(Color(.18,.13,.23),Color(.76,.62,.36)))
	theme.set_stylebox("disabled","Button",_flat(Color(.055,.065,.08),Color(.23,.23,.22)))
	return theme

static func _flat(fill: Color, edge: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = edge
	style.set_border_width_all(1)
	style.set_corner_radius_all(2)
	return style
