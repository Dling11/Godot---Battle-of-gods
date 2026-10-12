extends RefCounted

## Owner-selected A composition. Geometry and skin only; no equipment authority.
const FRAME = preload("res://assets/ui/inventory/centered_paperdoll_frame.png")
const ControlTheme = preload("res://ui/themes/sanctuary_theme.gd")
const EMPTY_ICONS := [
	preload("res://assets/ui/inventory/slot_head.png"),
	preload("res://assets/ui/inventory/slot_weapon.png"),
	preload("res://assets/ui/inventory/slot_plate.png"),
	preload("res://assets/ui/inventory/slot_gloves.png"),
	preload("res://assets/ui/inventory/slot_leggings.png"),
	preload("res://assets/ui/inventory/slot_boots.png"),
	preload("res://assets/ui/inventory/slot_bracer.png"),
	preload("res://assets/ui/inventory/slot_amulet.png"),
	preload("res://assets/ui/inventory/slot_ring.png"),
	preload("res://assets/ui/inventory/slot_talisman.png"),
]
const LEFT_SLOTS := [0, 2, 3, 4, 5]
const RIGHT_SLOTS := [1, 6, 7, 8, 9]
const ROW_HEIGHT := 38.0
const ROW_GAP := 4.0
const PORTRAIT_WIDTH := 152.0
const COLUMN_GAP := 12.0

static func frame() -> StyleBoxTexture:
	var style := StyleBoxTexture.new()
	style.texture = FRAME
	for side in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
		style.set_texture_margin(side, 16)
		style.set_content_margin(side, 0)
	return style

static func panel_style(border: Color = Color("615136")) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("0b111c")
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(2)
	style.set_content_margin_all(0)
	return style

static func apply_skin(menu: Control) -> void:
	menu.theme = ControlTheme.build()
	menu.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	menu.get_node("Panel").add_theme_stylebox_override("panel", frame())
	var row := menu.get_node("Panel/Margin/Root/PageHost/GearPage/LoadoutRow")
	row.get_node("PaperDollPanel").add_theme_stylebox_override("panel", panel_style())
	row.get_node("PaperDollPanel/PaperDollMargin/PaperDollRoot/EquipmentLayout/Portrait").add_theme_stylebox_override("panel", frame())
	row.get_node("EquipmentDetailPanel").add_theme_stylebox_override("panel", frame())
	menu.get_node("Panel/Margin/Root/PageHost/GearPage/BagPanel").add_theme_stylebox_override("panel", panel_style())

static func arrange(field: Control, cards: Array) -> void:
	if cards.size() != 10 or field.size.x <= 0:
		return
	var width := floorf((field.size.x - PORTRAIT_WIDTH - COLUMN_GAP * 2) / 2)
	for row in 5:
		for side in 2:
			var index: int = LEFT_SLOTS[row] if side == 0 else RIGHT_SLOTS[row]
			var card: Control = cards[index]
			card.size = Vector2(width, ROW_HEIGHT)
			card.position = Vector2(0 if side == 0 else field.size.x - width, row * (ROW_HEIGHT + ROW_GAP))
			var color := Color("789eb8") if index == 1 else Color("796447")
			card.add_theme_stylebox_override("panel", panel_style(color))
			card.get_node("Margin/Content/Labels/SlotLabel").add_theme_color_override("font_color", Color("cdbd98"))
