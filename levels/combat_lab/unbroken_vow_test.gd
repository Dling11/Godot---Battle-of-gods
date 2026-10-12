extends Node

## Opt-in animation rehearsal on the real Player. Never grants combat stats.
signal pressure_released
signal control_returned

const ART := "res://assets/vfx/abilities/king/unbroken_vow_test/"
const CAST_SECONDS := .32
const SUSTAIN_SECONDS := 6.0
var lab: Node
var actor: Player
var body: AnimatedSprite2D
var opened := false
var casting := false
var active := false
var slow := false
var sound_enabled := true
var elapsed := 0.0
var released := false
var _old_ai := true
var _body_was_visible := true
var _old_zoom := Vector2.ONE
var _visual: Node2D
var _cast: Sprite2D
var _shell: Sprite2D
var _lip: Sprite2D
var _pressure: Sprite2D
var _red: Sprite2D
var _audio: AudioStreamPlayer2D
var _panel: PanelContainer
var _status: Label
var _slow_button: Button
var _sound_button: Button
var _zoom_button: Button


func _ready() -> void:
	lab = get_parent().lab
	actor = lab.player
	body = actor.get_node("VisualRoot/Body")
	_visual = Node2D.new()
	_visual.name = "UnbrokenVowTestVisual"
	actor.add_child(_visual)
	_shell = _sprite("barrier.png", Vector2(-28, -44), -1)
	_pressure = _sprite("pressure.png", Vector2(-36, -48), -2)
	_cast = _sprite("body_down.png", Vector2(-48, -48), 1)
	_cast.material = body.material
	_red = _sprite("pressure.png", Vector2(-36, -48), 2)
	var material := ShaderMaterial.new()
	var shader := Shader.new()
	shader.code = "shader_type canvas_item; void fragment(){vec4 c=texture(TEXTURE,UV); if(c.r<c.b*1.2 || c.r<c.g*1.3){discard;} COLOR=c;}"
	material.shader = shader
	_red.material = material
	_lip = _sprite("barrier.png", Vector2(-28, -1), 3)
	_audio = AudioStreamPlayer2D.new()
	_audio.stream = load(ART + "pressure_contact.wav")
	_audio.bus = &"SFX"
	_audio.volume_db = -7.0
	_visual.add_child(_audio)
	_build_panel()
	_visual.hide()
	set_physics_process(false)
	set_process_input(false)
	actor.defeated.connect(reset_preview)
	actor.hit_recovery_started.connect(func(_duration: float) -> void: reset_preview())


func open() -> bool:
	if opened:
		return true
	if not OS.is_debug_build() or not get_parent().can_switch() or actor.is_cinematic_locked():
		return false
	opened = true
	_old_ai = lab._ai_enabled
	_old_zoom = lab.camera.zoom
	_zoom_button.text = "VIEW: GAME" if _old_zoom == Vector2.ONE else "VIEW: CLOSE"
	lab.set_enemy_ai_enabled(false)
	lab.ai_toggle.set_pressed_no_signal(false)
	lab.show_skills_tab()
	_panel.show()
	get_parent()._panel.hide()
	lab.review_tabs.get_child(1).scroll_vertical = 0
	set_process_input(true)
	_status.text = "UNBROKEN VOW · Down-facing art test. T / REPLAY, then move, dodge and attack. No shield or damage bonus."
	return true


func play_preview() -> bool:
	if not opened or casting or not get_parent().can_switch() or actor.is_cinematic_locked():
		return false
	reset_preview()
	_body_was_visible = body.visible
	actor.set_cinematic_locked(true)
	actor.facing_direction = Vector2.DOWN
	actor.facing_changed.emit(Vector2.DOWN)
	body.hide()
	casting = true
	active = true
	elapsed = 0.0
	released = false
	_visual.show()
	_cast.show()
	_pressure.show()
	_red.show()
	_show_cast_frame(0)
	set_physics_process(true)
	_status.text = "BRACE → PRESSURE → SHIELD · " + ("0.96s slow inspection" if slow else "0.32s normal cast")
	return true


func _physics_process(delta: float) -> void:
	advance(delta)


func advance(delta: float) -> void:
	if not active:
		return
	elapsed += delta
	var duration := CAST_SECONDS * (3.0 if slow else 1.0)
	if casting:
		var frame := mini(7, int(elapsed / duration * 8.0))
		_show_cast_frame(frame)
		if frame >= 4 and not released:
			released = true
			if sound_enabled and DisplayServer.get_name() != "headless":
				_audio.play()
			pressure_released.emit()
		if elapsed >= duration:
			_release_control()
			_status.text = "CONTROL RETURNED · Walk / dodge / attack with the visual barrier. Combat stats unchanged."
	if not casting:
		_show_shell(3 + (int((elapsed - duration) / .14) % 3))
		_region(_red, 7, 4, Vector2i(144, 112))
		_red.position = Vector2(-36, -38)
		if elapsed >= duration + SUSTAIN_SECONDS:
			reset_preview()
			_status.text = "TEST FINISHED · T / REPLAY again. Shield break and expiry art are still pending."


func _release_control() -> void:
	if not casting:
		return
	casting = false
	_cast.hide()
	_pressure.hide()
	body.visible = _body_was_visible
	actor.set_cinematic_locked(false)
	body.resume_locomotion()
	control_returned.emit()


func reset_preview() -> void:
	_release_control()
	active = false
	if is_instance_valid(_visual):
		_visual.hide()
	if is_instance_valid(_audio):
		_audio.stop()
	set_physics_process(false)


func close(return_to_skills := true) -> void:
	reset_preview()
	if not opened:
		return
	opened = false
	_panel.hide()
	set_process_input(false)
	lab.set_enemy_ai_enabled(_old_ai)
	lab.ai_toggle.set_pressed_no_signal(_old_ai)
	lab.camera.zoom = _old_zoom
	get_parent()._panel.show()
	get_parent()._zoom_button.text = "VIEW: GAME" if _old_zoom == Vector2.ONE else "VIEW: CLOSE"
	if return_to_skills:
		get_parent().open_review()


func _exit_tree() -> void:
	# Visual is attached to Player, so explicitly free it if this review is removed.
	if is_instance_valid(actor) and is_instance_valid(body):
		reset_preview()
	if opened and is_instance_valid(lab) and not lab.is_queued_for_deletion():
		lab.set_enemy_ai_enabled(_old_ai)
		lab.ai_toggle.set_pressed_no_signal(_old_ai)
		lab.camera.zoom = _old_zoom
	if is_instance_valid(_visual):
		_visual.queue_free()
	if is_instance_valid(_panel):
		_panel.queue_free()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_T or event.keycode == KEY_T:
			play_preview()
			get_viewport().set_input_as_handled()
		elif event.physical_keycode == KEY_ESCAPE or event.keycode == KEY_ESCAPE:
			close()
			get_viewport().set_input_as_handled()


func _sprite(file: String, origin: Vector2, depth: int) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.texture = load(ART + file)
	sprite.centered = false
	sprite.scale = Vector2(.5, .5)
	sprite.position = origin
	sprite.z_index = depth
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.region_enabled = true
	sprite.region_filter_clip_enabled = true
	_visual.add_child(sprite)
	return sprite


func _region(sprite: Sprite2D, index: int, columns: int, cell: Vector2i) -> void:
	sprite.region_rect = Rect2(Vector2(index % columns, index / columns) * Vector2(cell), Vector2(cell))


func _show_shell(index: int) -> void:
	_region(_shell, index, 3, Vector2i(112, 112))
	_lip.region_rect = Rect2(_shell.region_rect.position + Vector2(0, 86), Vector2(112, 26))


func _show_cast_frame(index: int) -> void:
	_region(_cast, index, 4, Vector2i(192, 128))
	_show_shell([0, 0, 0, 1, 2, 3, 4, 5][index])
	for sprite in [_pressure, _red]:
		_region(sprite, index, 4, Vector2i(144, 112))
		sprite.position = Vector2(-36, -48 if index < 4 else -38)


func _build_panel() -> void:
	_panel = PanelContainer.new()
	_panel.name = "UnbrokenVowTestPanel"
	_panel.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	_panel.theme = lab.get_node("UI/LabPanel").theme
	var stack := VBoxContainer.new()
	_panel.add_child(stack)
	var row := GridContainer.new()
	row.columns = 2
	stack.add_child(row)
	_button(row, "REPLAY [T]", play_preview)
	_slow_button = _button(row, "NORMAL", func() -> void:
		if casting: return
		slow = not slow
		_slow_button.text = "SLOW x3" if slow else "SPEED: NORMAL")
	_sound_button = _button(row, "SOUND: ON", func() -> void:
		sound_enabled = not sound_enabled
		if not sound_enabled: _audio.stop()
		_sound_button.text = "SOUND: ON" if sound_enabled else "SOUND: OFF")
	_zoom_button = _button(row, "VIEW: GAME", func() -> void:
		var close_view: bool = lab.camera.zoom == Vector2.ONE
		lab.camera.zoom = Vector2(2, 2) if close_view else Vector2.ONE
		_zoom_button.text = "VIEW: CLOSE" if close_view else "VIEW: GAME")
	_button(row, "RESET", reset_preview)
	_button(row, "BACK [ESC]", close)
	_status = Label.new()
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_status.add_theme_font_size_override("font_size", 10)
	stack.add_child(_status)
	var upgrades := Label.new()
	upgrades.text = "LIVE SKILL: HOTKEY 4\nUpgrade Foundation / Advanced / Mature on the Skills tab.\nThis optional pose rehearsal grants no stats; use normal hotkey 4 for combat."
	upgrades.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	upgrades.add_theme_font_size_override("font_size", 10)
	stack.add_child(upgrades)
	lab.skills_controls.add_child(_panel)
	_panel.hide()


func _button(row: Container, text: String, action: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.focus_mode = Control.FOCUS_NONE
	button.pressed.connect(action)
	row.add_child(button)
	return button
