extends Control

const Portal = preload("res://gameplay/encounters/stage_portal.tscn")
const Loading = preload("res://ui/transitions/quiet_loading_view.tscn")
const Title = preload("res://ui/screens/title/title_screen.tscn")
const FRAMES := QuietLoadingView.KING_FRAMES
var selected_portal: StagePortal
var _portal_parent: Node2D
var _loading: QuietLoadingView
var _controls: VBoxContainer

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var backdrop := TextureRect.new()
	backdrop.texture = QuietLoadingView.BACKGROUND
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(backdrop)
	_controls = VBoxContainer.new()
	_controls.position = Vector2(28,28)
	_controls.size = Vector2(260,470)
	_controls.add_theme_constant_override("separation",9)
	add_child(_controls)
	var heading := Label.new()
	heading.text = "STAGE PRESENTATION REVIEW\nIsolated profile • no ordinary save access"
	heading.add_theme_font_size_override("font_size",13)
	_controls.add_child(heading)
	for index in 6:
		var button := Button.new()
		button.text = ["1 · Calm / Normal", "2 · Ominous / Mini Boss", "3 · Grasp / Boss", "4 · Maw / Boss", "5 · Divine / future", "6 · Unknowable / future"][index]
		button.pressed.connect(show_portal.bind(index))
		_controls.add_child(button)
	var loading_button := Button.new()
	loading_button.text = "Loading motion preview"
	loading_button.pressed.connect(show_loading)
	_controls.add_child(loading_button)
	var travel := Button.new()
	travel.text = "Test REAL loading → Stage I"
	travel.pressed.connect(func() -> void: get_node("/root/SceneTransition").transition_to("res://levels/test_arena/test_arena.tscn"))
	_controls.add_child(travel)
	var title := Button.new()
	title.text = "Title / menu preview"
	title.pressed.connect(func() -> void: get_tree().change_scene_to_packed(Title))
	_controls.add_child(title)
	_portal_parent = Node2D.new()
	_portal_parent.position = Vector2(615,305)
	add_child(_portal_parent)
	var king := AnimatedSprite2D.new()
	king.sprite_frames = FRAMES
	king.scale = Vector2.ONE*0.5
	king.position = Vector2(500,305)
	king.play(&"idle_down")
	var outline := ShaderMaterial.new()
	outline.shader = preload("res://entities/player/presentation/king_spellward_outline.gdshader")
	king.material = outline
	add_child(king)
	var note := Label.new()
	note.text = "Native character scale • separate tier lightning\nFuture tiers are art review, not unlocked campaign stages.\nChest states below: forest / Rootbound / Varkuun"
	note.position = Vector2(355,327)
	note.add_theme_font_size_override("font_size",12)
	add_child(note)
	for row in 3:
		for column in 2:
			var sprite := Sprite2D.new()
			var key: String = ["forest","rootbound","varkuun"][row]+("_closed" if column == 0 else "_open")
			sprite.texture = load("res://assets/gameplay/loot/stage_clear_chest/renewed/"+key+".png")
			sprite.position = Vector2(405+row*180+column*72,444)
			add_child(sprite)
	_loading = Loading.instantiate() as QuietLoadingView
	add_child(_loading)
	_loading.hide()
	show_portal(0)

func show_portal(index: int) -> void:
	if selected_portal != null:
		selected_portal.free()
	selected_portal = Portal.instantiate() as StagePortal
	selected_portal.portal_tier = [0,1,2,2,3,4][index] as StagePortal.PortalTier
	selected_portal.boss_variant = 1 if index == 3 else 0
	_portal_parent.add_child(selected_portal)
	# Showcase has no physical player and no pretend route; real F is verified
	# in campaign and the interaction smoke test.
	selected_portal.set_process(false)
	selected_portal.offscreen_guide.hide()
	selected_portal.guidance_arrow.hide()

func show_loading() -> void:
	_loading.show()
	_loading.begin("res://levels/stage_2/stage_2.tscn", {})
	_loading.set_loading_progress(0.37)
	_loading.heading.text = "MOTION PREVIEW • ESC TO CLOSE"
	_controls.hide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and _loading.visible:
		_loading.finish()
		_loading.hide()
		_controls.show()
		get_viewport().set_input_as_handled()
