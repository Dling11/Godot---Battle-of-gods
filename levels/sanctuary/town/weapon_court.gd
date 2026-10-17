extends Node2D

## Sanctuary placement and presentation. AxeTrial owns the lesson proof.
const Trial = preload("res://gameplay/training/axe_mastery_trial.gd")
const Nameplate = preload("res://entities/npcs/presentation/npc_nameplate.gd")
const Beacon = preload("res://entities/npcs/presentation/service_beacon.gd")
const UiSkin = preload("res://ui/hud/veil_theme.gd")
const IDLE := preload("res://assets/characters/npcs/veyr/idle.png")
const Layout = preload("res://levels/sanctuary/town/sanctuary_layout.gd")
const PAVILION := preload("res://assets/environment/sanctuary/weapon_court/training_pavilion.png")
const MENTOR_POSITION := Layout.MENTOR
var hub: Node
var trial: Node
var mentor: DialogueNpc
var pavilion: StaticBody2D
var menu: Control
var start_button: Button
var lesson_state: Label
var facts: RichTextLabel
var practice_panel: PanelContainer
var practice_title: Label
var practice_hint: Label
var _owns_pause := false

func configure(owner_hub: Node) -> void:
	hub = owner_hub
	name = "WeaponCourt"
	_build_pavilion()
	_build_mentor()
	trial = Trial.new()
	trial.name = "AxeLesson"
	add_child(trial)
	trial.configure(hub)
	trial.changed.connect(_refresh_practice)
	trial.ended.connect(_on_ended)
	_build_menu()
	get_node("/root/WeaponTraining").training_changed.connect(_refresh_menu)
	set_physics_process(false)

func _build_mentor() -> void:
	mentor = DialogueNpc.new()
	mentor.name = "Veyr"
	mentor.position = MENTOR_POSITION
	mentor.collision_layer = 0
	mentor.collision_mask = 2
	mentor.prompt_text = "F · VEYR · WEAPON LESSONS"
	mentor.speaker_name = "VEYR THE GODSCARRED"
	var trigger := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 48
	trigger.shape = shape
	trigger.position.y = -9
	mentor.add_child(trigger)
	var shadow := Polygon2D.new()
	shadow.name = "Shadow"
	shadow.position = Vector2(0,-2)
	shadow.polygon = PackedVector2Array([Vector2(-9,0),Vector2(-6,-3),Vector2(6,-3),Vector2(9,0),Vector2(6,3),Vector2(-6,3)])
	shadow.color = Color(.02,.03,.03,.45)
	shadow.z_index = -2
	mentor.add_child(shadow)
	var sprite := AnimatedSprite2D.new()
	sprite.name = "Sprite"
	sprite.scale = Layout.NPC_SCALE
	sprite.position = Vector2(0,-15)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.sprite_frames = SpriteFrames.new()
	sprite.sprite_frames.set_animation_speed(&"default",4)
	for index in 8:
		var frame := AtlasTexture.new()
		frame.atlas = IDLE
		frame.region = Rect2(Vector2(index%4,index/4)*96,Vector2(96,96))
		sprite.sprite_frames.add_frame(&"default",frame)
	mentor.add_child(sprite)
	var nameplate := Nameplate.new()
	nameplate.npc_name = "Veyr"
	nameplate.role_name = "Weapon Mentor"
	nameplate.position.y = -62
	mentor.add_child(nameplate)
	hub.get_node("World/Actors").add_child(mentor)
	sprite.play()
	mentor.proximity_changed.connect(hub.combat_hud.show_interaction_prompt)
	mentor.proximity_changed.connect(func(near: bool,_text: String,_icon: Texture2D) -> void: nameplate.set_near(near))
	mentor.dialogue_requested.connect(func(_speaker: String,_lines: Array[String],_portrait: Texture2D) -> void: open_menu())
	var beacon := Beacon.new()
	beacon.configure(mentor,Color("9dc4d9"),"Steel teaches. Show me what you have learned.")
	beacon.set_enabled(true)
	# Feet occupy a small solid base, independent of interaction range/art.
	var body := StaticBody2D.new()
	body.collision_layer = 1
	body.collision_mask = 0
	var collision := CollisionShape2D.new()
	var footprint := CircleShape2D.new()
	footprint.radius = 7
	collision.shape = footprint
	collision.position.y = -5
	body.add_child(collision)
	mentor.add_child(body)

func _build_pavilion() -> void:
	pavilion = StaticBody2D.new()
	pavilion.name = "VeyrTrainingPavilion"
	pavilion.position = Layout.PAVILION
	pavilion.collision_layer = 1
	pavilion.collision_mask = 0
	pavilion.set_meta(&"service_id",&"weapon_mentor")
	hub.get_node("World/Actors").add_child(pavilion)
	var art := Sprite2D.new()
	art.name = "Art"
	art.texture = PAVILION
	art.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	art.position.y = 4-PAVILION.get_height()/2.0
	pavilion.add_child(art)
	var collision := CollisionShape2D.new()
	var footprint := RectangleShape2D.new()
	footprint.size = Vector2(208,24)
	collision.shape = footprint
	collision.position.y = -12
	pavilion.add_child(collision)
	var reveal := Area2D.new()
	reveal.collision_layer = 0
	reveal.collision_mask = 2
	pavilion.add_child(reveal)
	var canopy := CollisionShape2D.new()
	var canopy_shape := RectangleShape2D.new()
	canopy_shape.size = Vector2(208,104)
	canopy.shape = canopy_shape
	canopy.position.y = -64
	reveal.add_child(canopy)
	reveal.body_entered.connect(func(body: Node) -> void:
		if body is Player: art.modulate.a = .45)
	reveal.body_exited.connect(func(body: Node) -> void:
		if body is Player: art.modulate.a = 1)
	var sign := Label.new()
	sign.text = "WEAPON COURT"
	sign.position = Vector2(-72,-136)
	sign.size = Vector2(144,16)
	sign.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sign.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sign.add_theme_font_size_override("font_size",10)
	sign.add_theme_color_override("font_color",Color("c9d7e3"))
	sign.add_theme_color_override("font_outline_color",Color("1a2028"))
	sign.add_theme_constant_override("outline_size",2)
	pavilion.add_child(sign)

func _build_menu() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 22
	add_child(layer)
	menu = Control.new()
	menu.name = "WeaponLessons"
	menu.process_mode = Node.PROCESS_MODE_ALWAYS
	menu.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(menu)
	var shade := ColorRect.new()
	shade.color = Color(.015,.02,.04,.8)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	menu.add_child(shade)
	var panel := PanelContainer.new()
	panel.name = "Panel"
	panel.add_theme_stylebox_override("panel",UiSkin.panel(Color("0c1420"),Color("8b8eae"),3))
	menu.add_child(panel)
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel.offset_left = -256
	panel.offset_right = 256
	panel.offset_top = -215
	panel.offset_bottom = 215
	var margin := MarginContainer.new()
	for edge in ["left","right","top","bottom"]: margin.add_theme_constant_override("margin_"+edge,18)
	panel.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation",10)
	margin.add_child(column)
	var header := HBoxContainer.new()
	column.add_child(header)
	var portrait := TextureRect.new()
	var portrait_texture := AtlasTexture.new()
	portrait_texture.atlas = IDLE
	portrait_texture.region = Rect2(16,12,64,72)
	portrait.texture = portrait_texture
	portrait.custom_minimum_size = Vector2(64,72)
	portrait.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	header.add_child(portrait)
	var identity := VBoxContainer.new()
	header.add_child(identity)
	_label(identity,"VEYR · THE GODSCARRED",17,Color("e3e5ef"))
	_label(identity,"WEAPON LESSONS",11,Color("9dc4d9"))
	_label(identity,"“A weapon is learned through action.”",10,Color("adafc2"))
	column.add_child(HSeparator.new())
	lesson_state = _label(column,"",11,Color("c3a4ed"))
	_label(column,"AXE · WAR CYCLONE",18,Color("dfedf9"))
	facts = RichTextLabel.new()
	facts.bbcode_enabled = true
	facts.fit_content = true
	facts.custom_minimum_size.y = 108
	facts.add_theme_font_size_override("normal_font_size",12)
	facts.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(facts)
	var loan := _label(column,"A training axe and Cyclone are lent for the lesson.\nYour equipment returns when you finish or leave.",11,Color("a5b5c6"))
	loan.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	start_button = _button(column,"BEGIN AXE LESSON",_start_lesson)
	_button(column,"BACK · ESC",close_menu)
	menu.hide()
	practice_panel = PanelContainer.new()
	practice_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	practice_panel.add_theme_stylebox_override("panel",UiSkin.panel(Color("0c1420ed"),Color("839bb1"),3))
	layer.add_child(practice_panel)
	practice_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	practice_panel.offset_left = -182
	practice_panel.offset_right = 182
	practice_panel.offset_top = 8
	var practice := VBoxContainer.new()
	practice.add_theme_constant_override("separation",4)
	practice_panel.add_child(practice)
	practice_title = _label(practice,"",12,Color("dce8f7"))
	practice_hint = _label(practice,"",10,Color("a9c6db"))
	practice_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	practice_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_button(practice,"LEAVE LESSON",trial.cancel)
	practice_panel.hide()

func _label(parent: Node, text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size",font_size)
	label.add_theme_color_override("font_color",color)
	parent.add_child(label)
	return label

func _button(parent: Node, text: String, action: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size.y = 30
	button.add_theme_font_size_override("font_size",11)
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.add_theme_stylebox_override("normal",UiSkin.panel(Color("192638"),Color("6c7c98")))
	button.add_theme_stylebox_override("hover",UiSkin.panel(Color("293c55"),Color("b4c8eb")))
	button.pressed.connect(action)
	parent.add_child(button)
	return button

func open_menu() -> void:
	if menu.visible or trial.is_active(): return
	_owns_pause = not get_tree().paused
	if _owns_pause: get_tree().paused = true
	menu.show()
	_refresh_menu()
	start_button.grab_focus()

func close_menu() -> void:
	if not menu.visible: return
	menu.hide()
	if _owns_pause: get_tree().paused = false
	_owns_pause = false
	mentor.restore_prompt()

func _refresh_menu() -> void:
	var learned: bool = get_node("/root/WeaponTraining").has_technique(&"axe_war_cyclone")
	lesson_state.text = "PROOF EARNED · CYCLONE LEARNED" if learned else "FIRST PROOF · CONTROL THE CIRCLE"
	start_button.text = "PRACTICE AGAIN" if learned else ("CLAIM COMPLETED LESSON" if trial.has_completed_proof() else "BEGIN AXE LESSON")
	var tuning := hub.player.war_cyclone.definition as WarCycloneDefinition
	var damage := tuning.resolve_damage(Trial.AXE.damage)
	facts.text = "[color=#d8b5ff]Prove:[/color] cleave 3 posts, steer a spin, dodge a warning.\n\n[color=#e4c3a4]PHYSICAL[/color]  %.0f total · %.0f per second · %.0fs\n[color=#9fdbed]GUARD[/color]  50%% less damage · immune to stun and stagger\n[color=#c0b7e7]REWARD[/color]  Cyclone technique + Nema's Axe pattern." % [damage,damage/tuning.active_seconds,tuning.active_seconds]

func _start_lesson() -> void:
	close_menu()
	if trial.has_completed_proof() and not get_node("/root/WeaponTraining").has_technique(&"axe_war_cyclone"):
		trial.claim()
		return
	if not trial.begin():
		hub.combat_hud.show_story_message("Finish your current action before beginning a lesson.",2)

func _refresh_practice() -> void:
	practice_panel.visible = trial.is_active()
	set_physics_process(trial.step == Trial.Step.DODGE)
	match trial.step:
		Trial.Step.CLEAVE:
			practice_title.text = "1 / 3 · CLEAVE THE GROUP"
			practice_hint.text = "LMB · Hit three different posts   %d / 3" % mini(trial.normal_contacts.size(),3)
		Trial.Step.CONTROL:
			practice_title.text = "2 / 3 · CONTROL WAR CYCLONE"
			practice_hint.text = "F1 + WASD / right-click · Posts %d / 3 · Steer %d / 36" % [mini(trial.spin_contacts.size(),3),mini(roundi(trial.travel),36)]
		Trial.Step.DODGE:
			practice_title.text = "3 / 3 · DODGE THE WARNING"
			practice_hint.text = "Space + direction · Leave the blue circle before it closes"
	queue_redraw()

func _on_ended(_earned: bool, message: String) -> void:
	practice_panel.hide()
	set_physics_process(false)
	queue_redraw()
	hub.combat_hud.show_story_message(message,4)
	_refresh_menu()

func _physics_process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	if not is_instance_valid(trial) or trial.step != Trial.Step.DODGE: return
	var center: Vector2 = trial.warning_center
	draw_circle(center,44,Color(.25,.65,.85,.12))
	draw_arc(center,44,0,TAU,48,Color(.55,.8,.96,.7),2)
	draw_arc(center,44*maxf(trial.warning_remaining,0),0,TAU,48,Color(.8,.92,1,.65),1)

func _ready() -> void:
	# Only the modal needs input while it owns the pause; trial timers remain paused.
	process_mode = Node.PROCESS_MODE_PAUSABLE
	var input := Node.new()
	input.set_script(preload("res://levels/sanctuary/town/weapon_court_menu_input.gd"))
	input.court = self
	add_child(input)

