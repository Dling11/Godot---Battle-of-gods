extends RefCounted

## Owner-selected A composition. Geometry and skin only; no equipment authority.
const BACKDROP = preload("res://assets/ui/inventory/portrait_backdrop.tres")
const FRAME = preload("res://assets/ui/inventory/centered_paperdoll_frame.png")
const VeilStyle = preload("res://ui/hud/veil_theme.gd")
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
const PORTRAIT_WIDTH := 168.0
const COLUMN_GAP := 12.0
const PREVIEW_SCALE := 0.85
const PREVIEW_ANCHOR := Vector2(0.5, 0.675)

static func frame() -> StyleBoxTexture:
	# Expedition feedback still uses this existing shared frame contract.
	var style := StyleBoxTexture.new()
	style.texture = FRAME
	for side in [SIDE_LEFT,SIDE_TOP,SIDE_RIGHT,SIDE_BOTTOM]:
		style.set_texture_margin(side,16)
		style.set_content_margin(side,0)
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
	menu.theme.set_font("font","Label",VeilStyle.BODY_FONT)
	menu.theme.set_font("font","Button",VeilStyle.DISPLAY_FONT)
	menu.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	menu.get_node("Panel/Margin/Root/Header/KingPortrait").texture = VeilStyle.PORTRAIT
	for surface: PanelContainer in [menu.get_node("Panel"),menu.equipment_detail_panel]:
		surface.add_theme_stylebox_override("panel",StyleBoxEmpty.new())
		VeilStyle.framed_backdrop(surface,VeilStyle.TOOLTIP_FRAME,Vector4(8,8,8,8))
	var row := menu.get_node("Panel/Margin/Root/PageHost/GearPage/LoadoutRow")
	row.get_node("PaperDollPanel").add_theme_stylebox_override("panel", panel_style())
	var portrait := row.get_node("PaperDollPanel/PaperDollMargin/PaperDollRoot/EquipmentLayout/Portrait") as PanelContainer
	portrait.add_theme_stylebox_override("panel",StyleBoxEmpty.new())
	var backdrop := TextureRect.new()
	backdrop.name = "InspectionBackdrop"
	backdrop.texture = BACKDROP
	backdrop.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	menu.portrait_canvas.add_child(backdrop)
	menu.portrait_canvas.move_child(backdrop,0)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var border := Panel.new()
	border.name = "InspectionBorder"
	border.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var border_style := panel_style(Color("46516a"))
	border_style.bg_color = Color.TRANSPARENT
	border_style.set_corner_radius_all(3)
	border.add_theme_stylebox_override("panel",border_style)
	menu.portrait_canvas.add_child(border)
	border.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	menu.get_node("Panel/Margin/Root/PageHost/GearPage/BagPanel").add_theme_stylebox_override("panel", panel_style())
	for scroll: ScrollContainer in [menu.bag_scroll,menu.equipment_detail_panel.body_scroll]:
		var rail := VeilStyle.panel(Color("0c1120"),Color("35415a"),3)
		rail.set_content_margin_all(3)
		var grabber := VeilStyle.panel(Color("657b9c"),Color("93bdd8"),3)
		grabber.set_content_margin_all(3)
		var bar := scroll.get_v_scroll_bar()
		bar.add_theme_stylebox_override("scroll",rail)
		for state in ["grabber","grabber_highlight","grabber_pressed"]:
			bar.add_theme_stylebox_override(state,grabber)
		bar.custom_minimum_size.x = 6

static func position_preview(pose: Node2D, canvas: Control) -> void:
	# Balance the complete actor within the floorless card, using its boot row.
	var sprite: Sprite2D = pose.body_sprite
	var pixels := sprite.texture.get_image()
	if pixels == null: return
	var occupied := pixels.get_used_rect()
	# Some complete cels include a shoulder blade or long scarf. Their overall
	# bounding-box center is not King's support point. Use the lower boot row.
	var sole_area := Rect2i(occupied.position+Vector2i(0,occupied.size.y-8),Vector2i(occupied.size.x,8))
	var soles := pixels.get_region(sole_area).get_used_rect()
	var feet := Vector2(sole_area.position)+Vector2(soles.position)+Vector2(soles.size.x*.5,soles.size.y)-sprite.texture.get_size()*.5
	pose.scale = Vector2.ONE*PREVIEW_SCALE
	pose.position = canvas.size*PREVIEW_ANCHOR-feet*PREVIEW_SCALE

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
			var equipped: EquipmentDefinition = card.get("_item")
			var color := equipped.get_rarity_color().darkened(.2) if equipped != null else Color("445269")
			card.add_theme_stylebox_override("panel", panel_style(color))
			card.get_node("Margin/Content/Labels/SlotLabel").add_theme_color_override("font_color", Color("b3bfd3"))
