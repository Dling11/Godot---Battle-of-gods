extends SceneTree

const HudScene = preload("res://ui/combat_hud.tscn")
const CharacterMenuScene = preload("res://ui/character_menu.tscn")
const PortalScene = preload("res://gameplay/encounters/stage_portal.tscn")
const ThemeResource = preload("res://assets/ui/themes/battle_of_gods_theme.tres")

const ICON_SIZES := {
	"res://assets/ui/icons/actions/icon_action_move_arrows_1_24.svg": Vector2i(24, 24),
	"res://assets/ui/icons/actions/icon_action_move_arrows_2_24.svg": Vector2i(24, 24),
	"res://assets/ui/icons/economy/icon_currency_coin_16x16.png": Vector2i(16, 16),
	"res://assets/ui/icons/status/icon_status_health_16x16.png": Vector2i(16, 16),
	"res://assets/ui/icons/status/icon_status_experience_16x16.png": Vector2i(16, 16),
	"res://assets/ui/icons/interactions/icon_interaction_portal_16x16.png": Vector2i(16, 16),
	"res://assets/ui/icons/interactions/icon_interaction_talk_16x16.png": Vector2i(16, 16),
	"res://assets/ui/icons/states/icon_slot_locked_16x16.png": Vector2i(16, 16),
	"res://assets/ui/icons/inventory/icon_inventory_bag_24x24.png": Vector2i(24, 24),
}

const GENERATED_ICON_SIZES := {
	"res://assets/ui/icons/combat/combat_action_atlas_bc_6x1_24.png": Vector2i(144, 24),
	"res://assets/ui/targeting/pointer.png": Vector2i(24, 24),
	"res://assets/ui/targeting/interact.png": Vector2i(24, 24),
	"res://assets/ui/targeting/selected.png": Vector2i(24, 24),
}

const ACTION_ICON_REGIONS := {
	"res://assets/ui/icons/combat/king_skill_1_icon.tres": 0,
	"res://assets/ui/icons/combat/king_skill_2_icon.tres": 1,
	"res://assets/ui/icons/combat/king_skill_3_icon.tres": 2,
	"res://assets/ui/icons/combat/king_skill_4_icon.tres": 3,
	"res://assets/ui/icons/combat/basic_attack_icon.tres": 4,
	"res://assets/ui/icons/combat/dodge_dash_icon.tres": 5,
}


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if not ThemeResource.has_stylebox("panel", "PanelContainer"):
		_fail("Shared UI theme is missing its PanelContainer style.")
		return
	if not ThemeResource.has_stylebox("normal", "Button"):
		_fail("Shared UI theme is missing its Button normal state.")
		return
	for path: String in ICON_SIZES:
		var texture := load(path) as Texture2D
		if texture == null or texture.get_size() != Vector2(ICON_SIZES[path]):
			_fail("UI icon has an invalid texture or size: %s" % path)
			return
		# SVG sources are rasterized by Godot with edge antialiasing even when the
		# authored geometry uses crisp integer steps. PNG pixel icons remain strict.
		if path.ends_with(".svg"):
			continue
		var image := texture.get_image()
		for y in image.get_height():
			for x in image.get_width():
				var alpha := image.get_pixel(x, y).a
				if alpha > 0.001 and alpha < 0.999:
					_fail("UI icon contains soft alpha instead of hard pixels: %s" % path)
					return
	for path: String in GENERATED_ICON_SIZES:
		var texture := load(path) as Texture2D
		if texture == null or texture.get_size() != Vector2(GENERATED_ICON_SIZES[path]):
			_fail("Generated UI asset has an invalid texture or size: %s" % path)
			return
		var image := texture.get_image()
		var has_transparency := false
		for y in image.get_height():
			for x in image.get_width():
				if image.get_pixel(x, y).a < 0.01:
					has_transparency = true
					break
			if has_transparency:
				break
		if not has_transparency:
			_fail("Generated UI asset lost its transparent background: %s" % path)
			return
		if path.ends_with("combat_action_atlas_bc_6x1_24.png"):
			for cell_index in range(6):
				var cell := image.get_region(Rect2i(cell_index * 24, 0, 24, 24))
				var colors := {}
				for y in cell.get_height():
					for x in cell.get_width():
						var pixel := cell.get_pixel(x, y)
						if pixel.a > 0.001 and pixel.a < 0.999:
							_fail("Generated action atlas contains soft alpha in cell %d." % cell_index)
							return
						if pixel.a >= 0.999:
							colors[pixel.to_html(false)] = true
				if colors.size() > 14:
					_fail("Generated action atlas cell %d exceeds the approved 14-color palette." % cell_index)
					return
	for path: String in ACTION_ICON_REGIONS:
		var region_texture := load(path) as AtlasTexture
		var expected_x: int = ACTION_ICON_REGIONS[path] * 24
		if (
			region_texture == null
			or region_texture.get_size() != Vector2(24, 24)
			or region_texture.region != Rect2(expected_x, 0, 24, 24)
		):
			_fail("Combat action resource does not map to its fixed atlas cell: %s" % path)
			return
	var hud := HudScene.instantiate() as CombatHUD
	root.add_child(hud)
	if hud.theme != ThemeResource:
		_fail("CombatHUD is not using the shared UI theme.")
		return
	if hud.get_node("HealthPanel/Margin/Stack/Header/HealthIcon").texture == null:
		_fail("CombatHUD health icon is not configured.")
		return
	if hud.character_menu_button.icon == null or hud.character_menu_button.text != "CHARACTER & BAG  [TAB]":
		_fail("CombatHUD character/inventory entry button is not configured.")
		return
	var menu := CharacterMenuScene.instantiate() as CharacterMenu
	if menu.theme != ThemeResource:
		_fail("CharacterMenu is not using the shared UI theme.")
		return
	var portal := PortalScene.instantiate() as StagePortal
	root.add_child(portal)
	if portal.interaction_icon == null:
		_fail("StagePortal is not configured with its contextual prompt icon.")
		return
	hud.queue_free()
	portal.queue_free()
	menu.free()
	await process_frame
	print("UI theme and named icon smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
