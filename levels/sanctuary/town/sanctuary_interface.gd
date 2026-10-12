extends Node

## Current town theme on real controls; menus retain their existing authority.
const ThemeKit = preload("res://ui/themes/sanctuary_theme.gd")
var _modals: Array[Control] = []
var _collection_panels: Array = []
var _theme: Theme
var _review_controls: Control
var _town_map: Node
var _study: Node

func configure(hub: Node, test_controls: Control) -> void:
	_review_controls = test_controls
	_study = hub.get_node("SanctuaryTown")
	_town_map = _study.town_map
	_theme = ThemeKit.build()
	var library: Node = hub.player.get_node("KingSkillLibrary")
	library.child_entered_tree.connect(func(child: Node) -> void:
		if child.get_script() != null and child.get_script().resource_path == "res://ui/skills/king_skill_collection.gd":
			child.ready.connect(_on_collection_ready.bind(child),CONNECT_ONE_SHOT))
	for modal: Control in [hub.dialogue_panel,hub.character_menu,hub.rootforge_menu,hub.umi_exchange_menu,hub.expedition_menu,hub.get_node("UI/PauseMenu")]:
		_modals.append(modal)
		if modal != hub.character_menu:
			modal.theme = _theme
			modal.get_node("Panel").add_theme_stylebox_override("panel",ThemeKit.frame())
		modal.visibility_changed.connect(_sync_review_controls)
	for recipe in [[hub.dialogue_panel.skip_button,11],[hub.dialogue_panel.continue_button,10],[hub.dialogue_panel.body_label,12]]:
		recipe[0].add_theme_font_size_override("font_size",recipe[1])
	var hud: Control = hub.combat_hud
	hud.get_node("EclipseFrame").hide()
	hud.get_node("EclipseVeil").hide()
	var tray: Control = hud.get_node("ActionTray")
	tray.offset_top = -62
	tray.offset_bottom = -8
	var hint: Control = hud.get_node("ResolveLabel")
	hint.offset_top += 34
	hint.offset_bottom += 34
	var compact := Panel.new()
	compact.name = "CompactSanctuaryFrame"
	compact.mouse_filter = Control.MOUSE_FILTER_IGNORE
	compact.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	hud.add_child(compact)
	hud.move_child(compact,tray.get_index())
	compact.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	compact.offset_left = -330
	compact.offset_right = 330
	compact.offset_top = -68
	compact.offset_bottom = -2
	compact.add_theme_stylebox_override("panel",ThemeKit.frame())

func _on_collection_ready(collection: Node) -> void:
	_collection_panels = _collection_panels.filter(func(panel) -> bool: return is_instance_valid(panel))
	collection.tree_exited.connect(_sync_review_controls)
	for child in collection.get_children():
		if child is PanelContainer:
			_collection_panels.append(child)
			child.theme = _theme
			child.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			child.add_theme_stylebox_override("panel",ThemeKit.frame(18))
	_sync_review_controls()

func _sync_review_controls() -> void:
	var modal_open := false
	for modal in _modals: modal_open = modal_open or modal.visible
	for panel in _collection_panels:
		if is_instance_valid(panel): modal_open = modal_open or panel.is_inside_tree()
	var inside: bool = _study.workshop_visit != null and _study.workshop_visit.inside
	_review_controls.visible = _study.test_controls_enabled and not modal_open and not inside
	if _study.workshop_visit != null: _study.workshop_visit.set_modal_open(modal_open)
	if modal_open: _town_map.hide_for_modal()
