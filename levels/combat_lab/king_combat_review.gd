extends Node2D

## Lab-only tuning controls. The production body and Skills 1-3 are already active.
var lab: Node
var actor: Player
var body: AnimatedSprite2D
var _panel: PanelContainer
var _message: Label
var _earth_form: OptionButton
var _molten_form: OptionButton
var _pursuit_rank: OptionButton
var _vow_rank: OptionButton
var _world_rank: OptionButton
var _speed_button: Button
var _zoom_button: Button
var _speed_mode := 0
var _show_reach := false
var buff_test: Node


func _ready() -> void:
	lab = get_parent()
	actor = lab.player
	body = actor.get_node("VisualRoot/Body")
	z_index = 20
	set_process(false)
	_build_panel()
	buff_test = preload("res://levels/combat_lab/unbroken_vow_test.gd").new()
	buff_test.name = "UnbrokenVowTest"
	add_child(buff_test)
	actor.equipment_stats_changed.connect(_restore_speed)


func open_review() -> void:
	lab.show_skills_tab()
	_panel.show()
	_message.text = "Choose upgrades below. Lab previews never spend levels or change trained ranks."


func open_buff_test() -> void:
	if not buff_test.open():
		_message.text = "Finish the current action before opening BUFF TEST."


func can_switch() -> bool:
	return not actor.is_cinematic_locked() and not actor.is_defeated and not actor.is_restrained() and not actor.is_in_hit_recovery() and not actor._is_targeting_any_ability() and not actor.is_any_ability_casting() and not actor.evade_component.is_dashing() and actor.attack_component.phase == MeleeAttackComponent.Phase.IDLE


func set_earthsplitter_form(value: int) -> bool:
	if value < EarthsplitterDefinition.Form.FOUNDATION or value > EarthsplitterDefinition.Form.CASCADE or not can_switch():
		return false
	for sequence in get_tree().get_nodes_in_group("earthsplitter_sequences"):
		if sequence.source == actor:
			return false
	var next := actor.ability_1_component.definition.duplicate(true) as EarthsplitterDefinition
	next.configure_form(value)
	actor.ability_1_component.definition = next
	actor.ability_1_component.collision_shape.shape = next.hitbox_shape
	actor.ability_1_component.clear_cooldown()
	actor.get_node("KingSkillLibrary").refresh()
	_earth_form.select(value)
	_message.text = "Skill 1 form preview only; campaign starts with Foundation."
	return true


func set_molten_form(value: int) -> bool:
	if value < MoltenCrashDefinition.Form.FOUNDATION or value > MoltenCrashDefinition.Form.MATURE or not can_switch():
		return false
	for pulse in get_tree().get_nodes_in_group("molten_crash_pulses"):
		if pulse.source == actor:
			return false
	var next := actor.ability_2_component.definition.duplicate(true) as MoltenCrashDefinition
	next.configure_form(value)
	actor.ability_2_component.definition = next
	actor.ability_2_component.collision_shape.shape = next.hitbox_shape
	actor.ability_2_component.clear_cooldown()
	actor.get_node("KingSkillLibrary").refresh()
	_molten_form.select(value)
	_message.text = "Skill 2 form preview only; campaign starts with blue Foundation."
	return true


func set_pursuit_rank(value: int) -> bool:
	if value < SovereignPursuitDefinition.Rank.FOUNDATION or value > SovereignPursuitDefinition.Rank.MATURE or not can_switch():
		return false
	var pursuit := actor.ability_3_component as SovereignPursuitComponent
	pursuit.apply_rank(value)
	actor.get_node("KingSkillLibrary").refresh()
	_pursuit_rank.select(value)
	_message.text = "Pursuit charge preview only; campaign upgrades are trained with Eira."
	return true


func cycle_speed() -> void:
	if not can_switch():
		return
	_speed_mode = (_speed_mode + 1) % 3
	if _speed_mode == 0:
		actor._apply_equipment_stats()
	else:
		actor.movement_component.set_equipment_speed_bonus(.35 if _speed_mode == 2 else 0.0)
		actor.attack_component.set_equipment_attack_speed_bonus(.5 if _speed_mode == 2 else 0.0)
		body.call("_refresh_stride")
	_speed_button.text = ["SPEED: GEAR", "SPEED: BASE", "SPEED: CAPS"][_speed_mode]


func _restore_speed() -> void:
	_speed_mode = 0
	if _speed_button != null:
		_speed_button.text = "SPEED: GEAR"


func sample_hit(seconds: float) -> void:
	if not can_switch():
		return
	var health := actor.health_component
	var was_immune := health.is_damage_immune
	var was_invulnerable: bool = health.is_invulnerable
	var before := health.current_health
	health.is_damage_immune = false
	health.set_invulnerable(false)
	var sample := DamageInfo.new(minf(1.0, before * .25), self, Vector2.LEFT)
	if seconds >= .3:
		sample.stun_seconds = seconds
	else:
		sample.stagger_seconds = seconds
	health.apply_damage(sample)
	health.set_current_health(before)
	health.is_damage_immune = was_immune
	health.set_invulnerable(was_invulnerable)


func _build_panel() -> void:
	_panel = PanelContainer.new()
	_panel.name = "SkillReview"
	_panel.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	lab.skills_controls.add_child(_panel)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 5)
	_panel.add_child(stack)
	_heading(stack, "1 · EARTHSPLITTER")
	_earth_form = _option(stack, ["Foundation · one lane", "Fan · three lanes + follow-up", "Cascade · successive waves"], func(value: int) -> void:
		if not set_earthsplitter_form(value): _selection_busy())
	_heading(stack, "2 · MOLTEN CRASH")
	_molten_form = _option(stack, ["Foundation · blue impact", "Advanced · molten impact", "Awakened · aftershock", "Mature · stronger core"], func(value: int) -> void:
		if not set_molten_form(value): _selection_busy())
	_heading(stack, "3 · SOVEREIGN PURSUIT")
	_pursuit_rank = _option(stack, ["Foundation · 1 use / 220px", "Advanced · 2 uses / 250px", "Mature · 3 uses / 280px"], func(value: int) -> void:
		if not set_pursuit_rank(value): _selection_busy())
	_heading(stack, "4 · UNBROKEN VOW")
	_vow_rank = _option(stack, ["Foundation · shield + damage", "Advanced · shield + speed", "Mature · empowered combo"], func(value: int) -> void:
		if not set_vow_rank(value): _selection_busy())
	_heading(stack, "5 · WORLDSPLITTER · AVAILABLE")
	_world_rank = _option(stack, ["Foundation · 1 blue sword", "Advanced · 2 summoned swords", "Mature · 3 crimson swords"], func(value: int) -> void:
		if not set_worldsplitter_rank(value): _selection_busy())
	_button(stack, "OLD POSE REHEARSAL", open_buff_test)
	_button(stack, "EDIT TEN-SLOT LOADOUT", func() -> void: actor.get_node("KingSkillLibrary").open_collection())
	_heading(stack, "KING · MOVEMENT & HIT REVIEW")
	var row := GridContainer.new()
	row.columns = 2
	stack.add_child(row)
	_speed_button = _button(row, "SPEED: GEAR", cycle_speed)
	_zoom_button = _button(row, "VIEW: GAME", _toggle_zoom)
	_button(row, "HIT", sample_hit.bind(.11))
	_button(row, "STUN", sample_hit.bind(.8))
	_button(stack, "TOGGLE ATTACK REACH", func() -> void: _show_reach = not _show_reach; set_process(_show_reach); queue_redraw())
	_message = Label.new()
	_message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_message.add_theme_font_size_override("font_size", 10)
	_message.text = "Upgrade previews are Lab-only. Press 4 to buff; aim 5 for Worldsplitter."
	stack.add_child(_message)
	_sync_forms()


func _sync_forms() -> void:
	_earth_form.select((actor.ability_1_component.definition as EarthsplitterDefinition).form)
	_molten_form.select((actor.ability_2_component.definition as MoltenCrashDefinition).form)
	_pursuit_rank.select((actor.ability_3_component.definition as SovereignPursuitDefinition).rank)
	_vow_rank.select((actor.get_node("UnbrokenVowComponent").definition as UnbrokenVowDefinition).rank)
	_world_rank.select((actor.ability_4_component.definition as KingSkill4Definition).rank)


func _selection_busy() -> void:
	_sync_forms()
	_message.text = "Finish the current action and its impacts before changing upgrades."


func _heading(stack: Container, label: String) -> void:
	var heading := Label.new()
	heading.text = label
	heading.add_theme_font_size_override("font_size", 10)
	heading.add_theme_color_override("font_color", Color("c7b88e"))
	stack.add_child(heading)


func _option(stack: Container, choices: Array, action: Callable) -> OptionButton:
	var option := OptionButton.new()
	option.fit_to_longest_item = false
	option.focus_mode = Control.FOCUS_NONE
	for choice: String in choices:
		option.add_item(choice)
	option.item_selected.connect(action)
	stack.add_child(option)
	return option


func _button(row: Container, label: String, action: Callable) -> Button:
	var button := Button.new()
	button.text = label
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.focus_mode = Control.FOCUS_NONE
	button.pressed.connect(action)
	row.add_child(button)
	return button


func _toggle_zoom() -> void:
	var close_view: bool = lab.camera.zoom == Vector2.ONE
	lab.camera.zoom = Vector2(2, 2) if close_view else Vector2.ONE
	_zoom_button.text = "VIEW: CLOSE" if close_view else "VIEW: GAME"


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	if not _show_reach:
		return
	var shape := actor.attack_component.collision_shape.shape as ConvexPolygonShape2D
	if shape == null:
		return
	var transform := global_transform.affine_inverse() * actor.attack_component.collision_shape.global_transform
	var points := PackedVector2Array()
	for point in shape.points:
		points.append(transform * point)
	points.append(points[0])
	draw_polyline(points, Color("c6edff") if actor.attack_component.phase == MeleeAttackComponent.Phase.ACTIVE else Color("607c86"), 1.0)

func set_vow_rank(value: int) -> bool:
	if value < 0 or value > 2 or not can_switch(): return false
	(actor.get_node("UnbrokenVowComponent") as UnbrokenVowComponent).apply_rank(value)
	actor.get_node("KingSkillLibrary").refresh()
	_vow_rank.select(value)
	_message.text = "Vow upgrade preview. Press 4; disable invincibility under AI to test shield damage."
	return true

func set_worldsplitter_rank(value: int) -> bool:
	if value < 0 or value > 2 or not can_switch(): return false
	for sequence in get_tree().get_nodes_in_group("worldsplitter_sequences"):
		if sequence.source == actor: return false
	(actor.ability_4_component as KingSkill4Component).apply_rank(value)
	actor.ability_4_component.clear_cooldown()
	actor.get_node("KingSkillLibrary").refresh()
	_world_rank.select(value)
	_message.text = "Worldsplitter: aim 5, then move. Each new sword buries and bursts across the target area."
	return true
