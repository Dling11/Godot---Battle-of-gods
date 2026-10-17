extends RefCounted

## Shared presentation only. Sizes are logical pixels at the 960x540 baseline.
const MEDALLION = preload("res://assets/ui/hud/veil_sigils/medallion.png")
const PORTRAIT = preload("res://assets/ui/hud/veil_sigils/king_portrait.png")
const HEALTH_FRAME = preload("res://assets/ui/hud/veil_sigils/health_frame.png")
const MASTERY_FRAME = preload("res://assets/ui/hud/veil_sigils/mastery_frame.png")
const LEVEL_BADGE = preload("res://assets/ui/hud/veil_sigils/level_badge.png")
const COIN_PLAQUE = preload("res://assets/ui/hud/veil_sigils/coin_plaque.png")
const TOOLTIP_FRAME = preload("res://assets/ui/hud/veil_sigils/tooltip_frame.png")
const STATUS_BENEFICIAL = preload("res://assets/ui/hud/veil_sigils/status_beneficial.png")
const STATUS_HARMFUL = preload("res://assets/ui/hud/veil_sigils/status_harmful.png")
const STATUS_RESOLVE = preload("res://assets/ui/hud/veil_sigils/status_resolve.png")
const STATUS_ROOT = preload("res://assets/ui/hud/veil_sigils/status_root.png")
const STATUS_STUN = preload("res://assets/ui/hud/veil_sigils/status_stun.png")
const STATUS_SHIELD = preload("res://assets/ui/hud/veil_sigils/status_shield.png")
const MASTERY_FILL = preload("res://assets/ui/hud/veil_sigils/mastery_fill.png")
const MASTERY_SEAL = preload("res://assets/ui/icons/states/icon_slot_locked_16x16.png")
const DISPLAY_FONT = preload("res://ui/hud/display_font.tres")
const BODY_FONT = preload("res://assets/ui/fonts/lora/Lora.ttf")
const FAMILY_ICONS := {
	"Sword":preload("res://assets/ui/hud/veil_sigils/family_sword.png"),
	"Greatsword":preload("res://assets/ui/hud/veil_sigils/family_greatsword.png"),
	"Dual Swords":preload("res://assets/ui/hud/veil_sigils/family_dual_swords.png"),
	"Axe":preload("res://assets/ui/hud/veil_sigils/family_axe.png"),
	"Scythe":preload("res://assets/ui/hud/veil_sigils/family_scythe.png"),
}
const XP_FRAME = preload("res://assets/ui/hud/veil_sigils/xp_frame.png")
const BAG_FACE = preload("res://assets/ui/hud/veil_sigils/bag_face.png")
const SETTINGS_FACE = preload("res://assets/ui/hud/veil_sigils/settings_face.png")
const DODGE = preload("res://assets/ui/hud/veil_sigils/dodge.png")
const INK := Color("101927f2")
const EDGE := Color("54677e")
const CYAN := Color("83d3ed")

static func panel(background := INK, border := EDGE, radius := 3) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(radius)
	return style

static func skin_slot(slot: Control, button: Button) -> void:
	slot.custom_minimum_size = Vector2(40,40)
	var style := StyleBoxTexture.new()
	style.texture = MEDALLION
	slot.add_theme_stylebox_override("panel",style)
	slot.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	var icon := slot.get_node_or_null("AbilityIcon") as TextureRect
	if icon == null: icon = slot.get_node("Icon") as TextureRect
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	button.add_theme_stylebox_override("normal",StyleBoxEmpty.new())
	button.add_theme_stylebox_override("hover",panel(Color("76c9eb18"),CYAN,20))
	button.add_theme_stylebox_override("pressed",panel(Color("76c9eb35"),CYAN,20))
	button.add_theme_stylebox_override("focus",panel(Color.TRANSPARENT,Color("baa6ee"),20))
	var key := slot.get_node("KeyLabel") as Label
	key.z_index = 2
	key.add_theme_stylebox_override("normal",panel(Color("080d17"),Color("8795ac"),2))
	key.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	key.position.y = -2
	key.size.y = 13

static func artwork(texture: Texture2D) -> StyleBoxTexture:
	# Fixed-layout high-density artwork scales as a complete frame. Texture
	# pixels must not become logical nine-slice margins or enlarge its borders.
	var style := StyleBoxTexture.new()
	style.texture = texture
	style.set_content_margin_all(0)
	return style

static func framed_backdrop(control: Control, texture: Texture2D, margins: Vector4) -> void:
	# A non-Control wrapper keeps Container layout from resizing the physical
	# threefold texture grid. Corner sizes stay in logical pixels after scaling.
	var backdrop := Node2D.new()
	backdrop.name = "IllustratedBorder"
	backdrop.scale = Vector2.ONE/3.0
	control.add_child(backdrop)
	control.move_child(backdrop,0)
	var patch := NinePatchRect.new()
	patch.texture = texture
	patch.mouse_filter = Control.MOUSE_FILTER_IGNORE
	patch.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	patch.patch_margin_left = roundi(margins.x*3)
	patch.patch_margin_top = roundi(margins.y*3)
	patch.patch_margin_right = roundi(margins.z*3)
	patch.patch_margin_bottom = roundi(margins.w*3)
	backdrop.add_child(patch)
	var layout := func() -> void: patch.size = control.size*3
	control.resized.connect(layout)
	layout.call()

static func fill(top: Color, bottom: Color) -> StyleBoxTexture:
	var gradient := Gradient.new()
	gradient.colors = PackedColorArray([top,top.lerp(bottom,.35),bottom])
	gradient.offsets = PackedFloat32Array([0,.25,1])
	var texture := GradientTexture2D.new()
	texture.width = 1
	texture.height = 16
	texture.fill_from = Vector2.ZERO
	texture.fill_to = Vector2(0,1)
	texture.gradient = gradient
	var style := StyleBoxTexture.new()
	style.texture = texture
	return style

static func health_fill(critical := false) -> StyleBoxTexture:
	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array([0,.08,.46,.52,1])
	gradient.colors = PackedColorArray([Color("ff7786"),Color("f82041"),Color("ed0b2a"),Color("bc0d2c"),Color("900d24")])
	if critical:
		gradient.colors = PackedColorArray([Color("ffd3ca"),Color("ff8d83"),Color("f34449"),Color("ce263c"),Color("9a142c")])
	var texture := GradientTexture2D.new()
	texture.width = 1
	texture.height = 64
	texture.fill_from = Vector2.ZERO
	texture.fill_to = Vector2(0,1)
	texture.gradient = gradient
	return artwork(texture)
