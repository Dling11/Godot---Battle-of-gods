class_name QuietLoadingView
extends Control

const BACKGROUND := preload("res://assets/ui/quiet_transition/background.png")
const SEAL_FRAMES := preload("res://assets/ui/quiet_transition/seal_frames.tres")
const SealAnimation := preload("res://ui/presentation/quiet_seal_animation.gd")
const KING_FRAMES := preload("res://assets/characters/playable/king/spellward/spellward_frames.tres")
const GOLD := Color(0.78, 0.68, 0.44)

var seal: AnimatedSprite2D
var king: AnimatedSprite2D
var progress_bar: ProgressBar
var progress_label: Label
var heading: Label
var _group: Control

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	z_index = 20
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var background := TextureRect.new()
	background.texture = BACKGROUND
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	_group = Control.new()
	_group.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_group.set_anchors_preset(Control.PRESET_CENTER)
	_group.position = Vector2(-180, -150)
	_group.size = Vector2(360, 300)
	add_child(_group)
	seal = AnimatedSprite2D.new()
	seal.set_script(SealAnimation)
	seal.sprite_frames = SEAL_FRAMES
	seal.position = Vector2(180, 92)
	_group.add_child(seal)
	_label("B A T T L E   O F   G O D S", Vector2(0, 3), Vector2(360, 24), 13, GOLD)
	heading = _label("ENTERING THE NEXT STAGE", Vector2(0, 173), Vector2(360, 26), 16, Color(0.86,0.84,0.79))
	_label("Beyond the threshold", Vector2(0, 203), Vector2(360, 24), 12, Color(0.43,0.47,0.54))
	progress_bar = ProgressBar.new()
	progress_bar.position = Vector2(40, 255)
	progress_bar.size = Vector2(280, 16)
	progress_bar.max_value = 1.0
	progress_bar.step = 0.001
	progress_bar.show_percentage = false
	progress_bar.add_theme_font_size_override("font_size", 10)
	progress_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var empty := StyleBoxFlat.new()
	empty.bg_color = Color(0.025,0.03,0.045)
	empty.border_color = GOLD.darkened(0.6)
	empty.set_border_width_all(1)
	progress_bar.add_theme_stylebox_override("background", empty)
	var fill := StyleBoxFlat.new()
	fill.bg_color = GOLD.darkened(0.48)
	progress_bar.add_theme_stylebox_override("fill", fill)
	_group.add_child(progress_bar)
	# Parenting refreshes the theme cache; clear its earlier default font-height
	# minimum before setting the slim final size.
	progress_bar.update_minimum_size()
	progress_bar.size = Vector2(280, 16)
	progress_label = _label("LOADING  0%", Vector2(40,255), Vector2(280,16), 10, Color(0.92,0.86,0.72))
	king = AnimatedSprite2D.new()
	king.sprite_frames = KING_FRAMES
	king.scale = Vector2.ONE * 0.5
	king.position = Vector2(180, 237)
	var outline := ShaderMaterial.new()
	outline.shader = preload("res://entities/player/presentation/king_spellward_outline.gdshader")
	king.material = outline
	_group.add_child(king)
	set_loading_progress(0)

func _label(text: String, origin: Vector2, extent: Vector2, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.position = origin
	label.size = extent
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_group.add_child(label)
	return label

func begin(target_scene: String, presentation: Dictionary) -> void:
	heading.text = "RETURNING TO SANCTUARY" if target_scene.ends_with("/sanctuary.tscn") else "ENTERING THE NEXT STAGE"
	# Threat is a restrained bar accent; the generic seal never reveals a boss.
	var color: Color = presentation.get("guide_color", GOLD)
	var fill := progress_bar.get_theme_stylebox("fill") as StyleBoxFlat
	fill.bg_color = color.darkened(0.48)
	set_loading_progress(0)
	seal.play(&"active")
	king.play(&"walk_right")

func set_loading_progress(value: float) -> void:
	progress_bar.value = clampf(value, 0.0, 1.0)
	progress_label.text = "LOADING  %d%%" % roundi(progress_bar.value*100.0)

func finish() -> void:
	seal.stop()
	king.stop()
