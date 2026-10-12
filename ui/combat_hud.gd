class_name CombatHUD
extends Control

const SkillBarSlotScene = preload("res://ui/skills/skill_bar_slot.tscn")
const StageChestIcon = preload(
	"res://assets/gameplay/loot/stage_clear_chest/"
	+ "forest_stage_clear_chest_closed_64x48.png"
)
const ROSTER_REFRESH_SECONDS := 0.25
const ROSTER_REVEAL_DISTANCE := 300.0
const ROSTER_REPEAT_CLICK_WINDOW_MSEC := 520
const MarqueeLabelScript = preload("res://ui/components/marquee_label.gd")
const ProgressionReadout = preload("res://ui/hud/progression_readout.gd")
const StatusPresenter = preload("res://ui/hud/player_status_presenter.gd")
var status_presenter: Node

signal character_menu_requested

@export var enemy_roster_enabled := true

@onready var health_bar: ProgressBar = %HealthBar
@onready var health_label: Label = %HealthLabel
@onready var blocked_label: Label = %BlockedLabel
@onready var defeat_panel: PanelContainer = %DefeatPanel
@onready var stage_label: Label = %StageLabel
@onready var spawn_indicator: Label = %SpawnIndicator
@onready var interaction_panel: PanelContainer = %InteractionPanel
@onready var interaction_icon: TextureRect = %InteractionIcon
@onready var interaction_label: Label = %InteractionLabel
@onready var skill_bar: HBoxContainer = %SkillBar
@onready var level_label: Label = %LevelLabel
@onready var experience_bar: ProgressBar = %ExperienceBar
@onready var experience_label: Label = %ExperienceLabel
@onready var coin_label: Label = %CoinLabel
@onready var character_menu_button: Button = %CharacterMenuButton
@onready var options_button: Button = %OptionsButton
@onready var dash_slot: DashBarSlot = %DashBarSlot
@onready var attack_button: Button = %AttackButton
@onready var target_panel: PanelContainer = %TargetPanel
@onready var target_name_label: Label = %TargetNameLabel
@onready var target_health_bar: ProgressBar = %TargetHealthBar
@onready var target_health_label: Label = %TargetHealthLabel
@onready var target_portrait: TextureRect = %TargetPortrait
@onready var target_close_button: Button = %TargetCloseButton
@onready var enemy_roster_panel: PanelContainer = %EnemyRosterPanel
@onready var enemy_roster_scroll: ScrollContainer = %EnemyRosterScroll
@onready var enemy_roster_rows: VBoxContainer = %EnemyRosterRows
@onready var auto_farm_button: Button = %AutoFarmButton
@onready var auto_skill_button: Button = %AutoSkillButton
@onready var loot_toast_panel: PanelContainer = %LootToastPanel
@onready var loot_toast_icon: TextureRect = %LootToastIcon
@onready var loot_toast_label: Label = %LootToastLabel
@onready var loot_toast_source_label: Label = %LootToastSourceLabel

var _blocked_tween: Tween
var _player: Player
var _pursuit_link_available := false
var _spawn_tween: Tween
var ability_panel: SkillBarSlot
var _skill_slots: Array[SkillBarSlot] = []
var _loot_notifications: Array[Dictionary] = []
var _loot_toast_busy := false
var _announcement_tween: Tween
var _roster_refresh_timer: Timer
var _revealed_enemy_ids: Dictionary = {}
var _last_roster_target_id := 0
var _last_roster_click_msec := -ROSTER_REPEAT_CLICK_WINDOW_MSEC
var _roster_signature := ""


func _ready() -> void:
	character_menu_button.pressed.connect(_on_character_menu_button_pressed)
	options_button.pressed.connect(_on_options_button_pressed)
	dash_slot.activation_requested.connect(_on_dash_activation_requested)
	attack_button.pressed.connect(_on_attack_button_pressed)
	auto_farm_button.pressed.connect(_on_auto_farm_button_pressed)
	auto_skill_button.pressed.connect(_on_auto_skill_button_pressed)
	target_close_button.pressed.connect(_on_target_close_button_pressed)
	target_panel.hide()
	enemy_roster_panel.hide()
	_style_enemy_roster_scrollbar()
	status_presenter = StatusPresenter.new()
	add_child(status_presenter)
	status_presenter.configure(self)


func _style_enemy_roster_scrollbar() -> void:
	var scroll_bar := enemy_roster_scroll.get_v_scroll_bar()
	scroll_bar.custom_minimum_size.x = 4.0
	scroll_bar.add_theme_stylebox_override("scroll", StyleBoxEmpty.new())
	scroll_bar.add_theme_stylebox_override("scroll_focus", StyleBoxEmpty.new())
	var grabber := StyleBoxFlat.new()
	grabber.bg_color = Color(0.92, 0.42, 0.24, 0.34)
	grabber.set_corner_radius_all(2)
	scroll_bar.add_theme_stylebox_override("grabber", grabber)
	var highlighted := grabber.duplicate() as StyleBoxFlat
	highlighted.bg_color = Color(1.0, 0.58, 0.30, 0.6)
	scroll_bar.add_theme_stylebox_override("grabber_highlight", highlighted)
	scroll_bar.add_theme_stylebox_override("grabber_pressed", highlighted)


func bind_player(player: Player) -> void:
	_player = player
	status_presenter.bind_player(player)
	if player.has_node("UnbrokenVowComponent"):
		var vow_status := preload("res://ui/skills/vow_status.gd").new()
		vow_status.actor = player
		add_child(vow_status)
		vow_status.position = Vector2(12,130)
	var mastery := player.get_node_or_null("KingMastery") as KingMasteryComponent
	if mastery != null:
		mastery.resolve_changed.connect(_update_resolve)
		mastery.link_changed.connect(_update_link)
		_update_resolve(mastery.stacks,mastery.definition.resolve_hits)
	var health: HealthComponent = player.health_component
	health.health_changed.connect(_update_health)
	health.damage_blocked.connect(_show_blocked)
	dash_slot.bind_evade(player.evade_component)
	player.combat_targeting.target_changed.connect(_on_combat_target_changed)
	player.combat_targeting.target_health_changed.connect(_on_combat_target_health_changed)
	player.auto_combat_changed.connect(_on_auto_combat_changed)
	player.directional_wedge_targeting.targeting_started.connect(_on_skill_targeting_started)
	player.directional_wedge_targeting.targeting_cancelled.connect(_on_skill_targeting_ended)
	player.directional_wedge_targeting.targeting_confirmed.connect(
		func(_component: AbilityComponent, _direction: Vector2) -> void:
			_on_skill_targeting_ended()
	)
	player.ground_point_targeting.targeting_started.connect(_on_skill_targeting_started)
	player.ground_point_targeting.targeting_cancelled.connect(_on_skill_targeting_ended)
	player.ground_point_targeting.targeting_confirmed.connect(
		func(_component: AbilityComponent, _position: Vector2) -> void:
			_on_skill_targeting_ended()
	)
	_build_skill_bar(player)
	_update_health(health.current_health, health.maximum_health)
	var progression := player.progression_component
	progression.progression_changed.connect(_update_progression)
	progression.coins_changed.connect(_update_coins)
	player.testing_preset_applied.connect(_show_testing_preset)
	player.skill_loadout_changed.connect(_on_skill_loadout_changed)
	player.selected_skill_changed.connect(_show_selected_skill)
	player.restraint_started.connect(_on_restraint_started)
	player.restraint_progress.connect(_on_restraint_progress)
	player.restraint_ended.connect(_on_restraint_ended)
	var loot_service := get_node_or_null("/root/LootService")
	if (
		loot_service != null
		and not loot_service.material_granted.is_connected(_on_material_granted)
	):
		loot_service.material_granted.connect(_on_material_granted)
	if (
		loot_service != null
		and not loot_service.stage_reward_granted.is_connected(
			_on_stage_reward_granted
		)
	):
		loot_service.stage_reward_granted.connect(_on_stage_reward_granted)
	_update_progression(progression.level, progression.total_experience, 0)
	_update_coins(progression.coins)
	_roster_refresh_timer = Timer.new()
	_roster_refresh_timer.wait_time = ROSTER_REFRESH_SECONDS
	_roster_refresh_timer.timeout.connect(_refresh_enemy_roster)
	add_child(_roster_refresh_timer)
	_roster_refresh_timer.start()
	_refresh_enemy_roster()
	_on_auto_combat_changed(player.auto_combat.auto_farm_enabled, player.auto_combat.auto_skills_enabled)

func get_skill_slot(slot_number: int) -> SkillBarSlot:
	for slot: SkillBarSlot in _skill_slots:
		if slot.slot_definition != null and slot.slot_definition.slot_number == slot_number:
			return slot
	return null

func _show_selected_skill(slot_number: int) -> void:
	for slot in _skill_slots:
		slot.key_label.text = ("›" if slot.slot_definition.slot_number==slot_number else "") + slot.slot_definition.get_key_label()

func _build_skill_bar(player: Player) -> void:
	for child: Node in skill_bar.get_children():
		skill_bar.remove_child(child)
		child.queue_free()
	_skill_slots.clear()
	ability_panel = null
	if player.skill_loadout == null or not player.skill_loadout.has_complete_layout():
		push_error("CombatHUD requires a complete ten-slot skill loadout.")
		return
	for definition: SkillSlotDefinition in player.skill_loadout.get_ordered_slots():
		var slot := SkillBarSlotScene.instantiate() as SkillBarSlot
		skill_bar.add_child(slot)
		slot.configure(definition)
		slot.bind_ability(player.get_ability_component_for_slot(definition.slot_number))
		slot.activation_requested.connect(_on_skill_activation_requested)
		_skill_slots.append(slot)
		if definition.slot_number == 1:
			ability_panel = slot
	if not Input.get_connected_joypads().is_empty():
		_show_selected_skill(player.selected_skill_slot)


func _on_skill_activation_requested(slot_number: int) -> void:
	if is_instance_valid(_player):
		_player.request_ability(slot_number)


func _on_skill_targeting_started(component: AbilityComponent) -> void:
	for slot: SkillBarSlot in _skill_slots:
		if slot.ability_component == component:
			slot.show_targeting()
		else:
			slot.clear_targeting_presentation()


func _on_skill_targeting_ended() -> void:
	for slot: SkillBarSlot in _skill_slots:
		slot.clear_targeting_presentation()


func _on_dash_activation_requested() -> void:
	if not is_instance_valid(_player):
		return
	var direction := _player.input_source.get_move_direction()
	if direction.is_zero_approx():
		direction = _player.facing_direction
	_player.request_evade(direction)


func _on_attack_button_pressed() -> void:
	if is_instance_valid(_player):
		_player.request_assisted_primary_attack()


func _on_auto_farm_button_pressed() -> void:
	if is_instance_valid(_player):
		_player.set_auto_farm_enabled(not _player.auto_combat.auto_farm_enabled)


func _on_auto_skill_button_pressed() -> void:
	if is_instance_valid(_player):
		_player.set_auto_skills_enabled(not _player.auto_combat.auto_skills_enabled)


func _on_auto_combat_changed(auto_farm_enabled: bool, auto_skills_enabled: bool) -> void:
	auto_farm_button.text = "AUTO ON" if auto_farm_enabled else "AUTO ALL"
	auto_skill_button.text = "SKILL ON" if auto_skills_enabled else "AUTO SKILL"
	_style_auto_button(auto_farm_button, auto_farm_enabled, Color(0.35, 0.88, 0.64, 1.0))
	_style_auto_button(auto_skill_button, auto_skills_enabled, Color(0.65, 0.58, 1.0, 1.0))
	if auto_farm_enabled and enemy_roster_enabled:
		enemy_roster_panel.show()


func _style_auto_button(button: Button, enabled: bool, accent: Color) -> void:
	button.modulate = Color.WHITE
	if not enabled:
		button.remove_theme_stylebox_override("normal")
		button.remove_theme_color_override("font_color")
		return
	var active_style := StyleBoxFlat.new()
	active_style.bg_color = Color(accent.r * 0.12, accent.g * 0.12, accent.b * 0.12, 0.98)
	active_style.border_color = accent
	active_style.set_border_width_all(1)
	active_style.set_corner_radius_all(2)
	button.add_theme_stylebox_override("normal", active_style)
	button.add_theme_color_override("font_color", accent.lightened(0.28))


func _on_combat_target_changed(
	actor: Node2D,
	health: HealthComponent,
	display_name: String
) -> void:
	target_panel.visible = actor != null and health != null
	if not target_panel.visible:
		return
	target_name_label.text = display_name.to_upper()
	var definition: Variant = actor.get("definition")
	target_portrait.texture = definition.portrait if definition is EnemyDefinition else null
	target_portrait.visible = target_portrait.texture != null
	_on_combat_target_health_changed(health.current_health, health.maximum_health)


func _on_combat_target_health_changed(current: float, maximum: float) -> void:
	target_health_bar.max_value = maximum
	target_health_bar.value = current
	target_health_label.text = "%d / %d" % [ceili(current), ceili(maximum)]


func _on_target_close_button_pressed() -> void:
	if is_instance_valid(_player):
		_player.combat_targeting.clear_target()


func _refresh_enemy_roster() -> void:
	if not enemy_roster_enabled:
		enemy_roster_panel.hide()
		return
	if not is_instance_valid(_player):
		return
	var targets := _get_revealed_roster_targets()
	enemy_roster_panel.visible = not targets.is_empty() or _player.auto_combat.auto_farm_enabled
	var next_signature := _build_roster_signature(targets)
	if next_signature == _roster_signature:
		return
	_roster_signature = next_signature
	for child: Node in enemy_roster_rows.get_children():
		enemy_roster_rows.remove_child(child)
		child.queue_free()
	for target: Dictionary in targets:
		enemy_roster_rows.add_child(_build_enemy_roster_row(target))


func _get_revealed_roster_targets() -> Array[Dictionary]:
	var revealed: Array[Dictionary] = []
	var living_ids: Dictionary = {}
	for target: Dictionary in _player.combat_targeting.get_selectable_targets():
		var actor := target.get("actor") as Node2D
		if not is_instance_valid(actor) or not actor.is_visible_in_tree():
			continue
		var actor_id := actor.get_instance_id()
		living_ids[actor_id] = true
		if (
			_revealed_enemy_ids.has(actor_id)
			or actor.global_position.distance_to(_player.global_position) <= ROSTER_REVEAL_DISTANCE
		):
			_revealed_enemy_ids[actor_id] = true
			revealed.append(target)
	for actor_id: int in _revealed_enemy_ids.keys():
		if not living_ids.has(actor_id):
			_revealed_enemy_ids.erase(actor_id)
	return revealed


func _build_roster_signature(targets: Array[Dictionary]) -> String:
	var parts: PackedStringArray = []
	for target: Dictionary in targets:
		var actor := target.get("actor") as Node2D
		var health := target.get("health") as HealthComponent
		if not is_instance_valid(actor) or not is_instance_valid(health):
			continue
		parts.append("%d:%d:%d:%d" % [
			actor.get_instance_id(),
			ceili(health.current_health),
			ceili(health.maximum_health),
			1 if actor == _player.combat_targeting.target_actor else 0,
		])
	return "|".join(parts)


func _build_enemy_roster_row(target: Dictionary) -> Button:
	var actor := target.get("actor") as Node2D
	var hurtbox := target.get("hurtbox") as HurtboxComponent
	var health := target.get("health") as HealthComponent
	var definition: Variant = target.get("definition")
	var row := Button.new()
	row.custom_minimum_size = Vector2(190.0, 42.0)
	row.focus_mode = Control.FOCUS_NONE
	row.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	row.tooltip_text = "Left-click to target • double-click to engage"
	row.add_theme_font_size_override("font_size", 8)
	var content := HBoxContainer.new()
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	content.add_theme_constant_override("separation", 4)
	row.add_child(content)
	var portrait_frame := Panel.new()
	portrait_frame.custom_minimum_size = Vector2(34.0, 34.0)
	portrait_frame.clip_contents = true
	portrait_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var portrait_style := StyleBoxFlat.new()
	portrait_style.bg_color = Color(0.18, 0.08, 0.08, 1.0)
	portrait_style.border_color = Color(0.9, 0.22, 0.18, 0.95)
	portrait_style.set_border_width_all(1)
	portrait_style.set_corner_radius_all(17)
	portrait_frame.add_theme_stylebox_override("panel", portrait_style)
	content.add_child(portrait_frame)
	var portrait := TextureRect.new()
	portrait.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	portrait.texture = definition.portrait if definition is EnemyDefinition else null
	portrait_frame.add_child(portrait)
	var details := VBoxContainer.new()
	details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	details.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(details)
	var header := HBoxContainer.new()
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	details.add_child(header)
	var name_label := MarqueeLabelScript.new() as MarqueeLabel
	name_label.custom_minimum_size = Vector2(0.0, 14.0)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(name_label)
	name_label.configure(
		_enemy_roster_name(definition, actor),
		_enemy_roster_color(definition),
		8
	)
	var health_label := Label.new()
	health_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	health_label.text = "%d/%d" % [ceili(health.current_health), ceili(health.maximum_health)]
	health_label.add_theme_font_size_override("font_size", 7)
	header.add_child(health_label)
	var bar := ProgressBar.new()
	bar.custom_minimum_size = Vector2(0.0, 6.0)
	bar.max_value = health.maximum_health
	bar.value = health.current_health
	bar.show_percentage = false
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var bar_background := StyleBoxFlat.new()
	bar_background.bg_color = Color(0.08, 0.035, 0.035, 0.9)
	bar_background.set_corner_radius_all(2)
	bar.add_theme_stylebox_override("background", bar_background)
	var bar_fill := StyleBoxFlat.new()
	bar_fill.bg_color = _enemy_roster_color(definition).darkened(0.18)
	bar_fill.set_corner_radius_all(2)
	bar.add_theme_stylebox_override("fill", bar_fill)
	details.add_child(bar)
	if actor == _player.combat_targeting.target_actor:
		var selected_style := StyleBoxFlat.new()
		selected_style.bg_color = Color(0.22, 0.055, 0.055, 0.96)
		selected_style.border_color = Color(1.0, 0.34, 0.24, 0.96)
		selected_style.set_border_width_all(1)
		selected_style.set_corner_radius_all(2)
		row.add_theme_stylebox_override("normal", selected_style)
	row.gui_input.connect(_on_enemy_roster_row_input.bind(actor, hurtbox))
	return row


func _on_enemy_roster_row_input(
	event: InputEvent,
	actor: Node2D,
	hurtbox: HurtboxComponent
) -> void:
	if (
		not event is InputEventMouseButton
		or event.button_index != MOUSE_BUTTON_LEFT
		or not event.pressed
		or not is_instance_valid(_player)
		or not is_instance_valid(actor)
		or not is_instance_valid(hurtbox)
	):
		return
	var actor_id := actor.get_instance_id()
	var now_msec := Time.get_ticks_msec()
	var engage: bool = (
		event.double_click
		or (
			actor_id == _last_roster_target_id
			and now_msec - _last_roster_click_msec <= ROSTER_REPEAT_CLICK_WINDOW_MSEC
		)
	)
	_last_roster_target_id = actor_id
	_last_roster_click_msec = now_msec
	_player.request_roster_target(hurtbox, engage)
	accept_event()


func _enemy_roster_name(definition: Variant, actor: Node2D) -> String:
	var name_text: String = (definition as EnemyDefinition).display_name if definition is EnemyDefinition else actor.name.capitalize()
	if definition is EnemyDefinition:
		match definition.crowd_control_tier:
			EnemyDefinition.CrowdControlTier.BOSS:
				return "BOSS  •  %s" % name_text.to_upper()
			EnemyDefinition.CrowdControlTier.ELITE:
				return "ELITE  •  %s" % name_text.to_upper()
	return name_text.to_upper()


func _enemy_roster_color(definition: Variant) -> Color:
	if definition is EnemyDefinition:
		if definition.crowd_control_tier == EnemyDefinition.CrowdControlTier.BOSS:
			return Color(1.0, 0.44, 0.2, 1.0)
		if definition.crowd_control_tier == EnemyDefinition.CrowdControlTier.ELITE:
			return Color(1.0, 0.78, 0.32, 1.0)
	return Color(0.94, 0.87, 0.76, 1.0)


func show_spawn_direction(global_position: Vector2) -> void:
	if not is_instance_valid(_player): return
	var direction := (global_position - _player.global_position).normalized()
	spawn_indicator.position = Vector2(480, 270) + Vector2(direction.x * 420.0, direction.y * 225.0) - Vector2(10, 10)
	spawn_indicator.rotation = direction.angle() + PI * 0.5
	spawn_indicator.modulate.a = 0.9
	spawn_indicator.show()
	if _spawn_tween != null and _spawn_tween.is_valid(): _spawn_tween.kill()
	_spawn_tween = create_tween()
	_spawn_tween.tween_interval(0.7)
	_spawn_tween.tween_property(spawn_indicator, "modulate:a", 0.0, 0.25)
	_spawn_tween.tween_callback(spawn_indicator.hide)


func show_defeat() -> void:
	defeat_panel.visible = true
	defeat_panel.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(defeat_panel, "modulate:a", 1.0, 0.25)


func show_wave(index: int, total: int, title: String) -> void:
	_show_announcement("WAVE %d/%d  %s" % [index, total, title], 1.6)


func show_wave_clear(index: int, total: int) -> void:
	_show_announcement("WAVE %d/%d CLEARED" % [index, total], 1.25)


func show_reinforcement_warning(_delay_seconds: float) -> void:
	_show_announcement("REINFORCEMENTS APPROACH", 0.9)


func show_stage_clear() -> void:
	_show_announcement("STAGE CLEAR  •  PORTAL OPEN", 2.4)


func show_reward_chest_ready(_global_position: Vector2) -> void:
	_show_announcement("STAGE CLEAR  •  CLAIM THE FOREST CHEST", 2.2)


func show_story_message(message: String, hold_seconds := 3.0) -> void:
	_show_announcement(message, hold_seconds)


func _update_progression(_level: int, _total_experience: int, _next_level_experience: int) -> void:
	if not is_instance_valid(_player):
		return
	var progression := _player.progression_component
	var readout := ProgressionReadout.describe(progression)
	level_label.text = readout.hud_level
	experience_bar.max_value = readout.maximum
	experience_bar.value = readout.value
	experience_label.text = readout.hud_text
	experience_label.tooltip_text = readout.text+"\n"+readout.help
	level_label.tooltip_text = readout.help


func _update_coins(total_coins: int) -> void:
	coin_label.text = "COINS %s" % ProgressionReadout.format_number(total_coins)


func _show_testing_preset(level: int, coins: int) -> void:
	_show_announcement(
		"DEBUG TEST  •  LEVEL %d  •  %d COINS  •  STAGE VI [PANEL/F6]"
		% [level, coins],
		2.6
	)


func _on_skill_loadout_changed() -> void:
	if is_instance_valid(_player):
		_build_skill_bar(_player)


func show_portal_sealed() -> void:
	_show_announcement("THE NEXT STAGE IS SEALED", 2.0)


func show_interaction_prompt(is_visible: bool, prompt_text: String, prompt_icon: Texture2D = null) -> void:
	interaction_label.text = prompt_text
	interaction_icon.texture = prompt_icon
	interaction_icon.visible = prompt_icon != null
	interaction_panel.visible = is_visible


func _show_announcement(message: String, hold_seconds: float) -> void:
	if _announcement_tween != null and _announcement_tween.is_valid():
		_announcement_tween.kill()
	stage_label.text = message
	stage_label.modulate.a = 0.0
	stage_label.show()
	_announcement_tween = create_tween()
	_announcement_tween.tween_property(stage_label, "modulate:a", 1.0, 0.2)
	_announcement_tween.tween_interval(hold_seconds)
	_announcement_tween.tween_property(stage_label, "modulate:a", 0.0, 0.3)
	_announcement_tween.tween_callback(stage_label.hide)


func _on_restraint_started(_source: Node, total: int) -> void:
	dash_slot.show_restraint_progress(total, total)
	_show_restraint_message("ROOTED  •  MASH DASH / TAP  •  0/%d" % total)


func _on_restraint_progress(_source: Node, remaining: int, total: int) -> void:
	dash_slot.show_restraint_progress(remaining, total)
	_show_restraint_message("ROOTED  •  MASH DASH / TAP  •  %d/%d" % [total - remaining, total])


func _on_restraint_ended(_source: Node, escaped: bool) -> void:
	dash_slot.clear_restraint_progress()
	_show_announcement("ROOT PRISON BROKEN  •  MOVE!" if escaped else "ROOT EXECUTION", 0.8)


func _show_restraint_message(message: String) -> void:
	if _announcement_tween != null and _announcement_tween.is_valid():
		_announcement_tween.kill()
	stage_label.text = message
	stage_label.modulate.a = 1.0
	stage_label.show()


func _update_health(current: float, maximum: float) -> void:
	health_bar.max_value = maximum
	health_bar.value = current
	health_label.text = "HP  %d / %d" % [ceili(current), ceili(maximum)]
	status_presenter.set_health(current,maximum)


func _show_blocked(_info: DamageInfo) -> void:
	blocked_label.visible = true
	blocked_label.modulate.a = 1.0
	if _blocked_tween != null and _blocked_tween.is_valid():
		_blocked_tween.kill()
	_blocked_tween = create_tween()
	_blocked_tween.tween_interval(0.25)
	_blocked_tween.tween_property(blocked_label, "modulate:a", 0.0, 0.2)
	_blocked_tween.tween_callback(blocked_label.hide)


func _on_character_menu_button_pressed() -> void:
	character_menu_requested.emit()


func _on_options_button_pressed() -> void:
	var pause_menu := get_tree().get_first_node_in_group("pause_menu") as PauseMenu
	if pause_menu != null:
		pause_menu.open_menu()


func _on_material_granted(
	material: MaterialDefinition,
	quantity: int,
	source_kind: StringName,
	reached_cap: bool
) -> void:
	var source_text := "ENEMY DROP"
	if source_kind == &"stage_chest":
		source_text = "STAGE CHEST"
	var title := "%s  ×%d" % [material.display_name.to_upper(), quantity]
	if quantity <= 0:
		title = "%s  •  MAX" % material.display_name.to_upper()
	elif reached_cap:
		title += "  •  MAX"
	if reached_cap:
		source_text += "  •  STACK FULL"
	_queue_loot_notification(
		material.icon,
		title,
		source_text
	)


func _on_stage_reward_granted(result: Dictionary) -> void:
	var materials: Array = result.get("materials", [])
	var total_quantity := 0
	for stack: Dictionary in materials:
		total_quantity += int(stack.get("quantity", 0))
	var overflow_materials: Array = result.get("overflow_materials", [])
	var overflow_quantity := 0
	for stack: Dictionary in overflow_materials:
		overflow_quantity += int(stack.get("quantity", 0))
	var recipe_ids: PackedStringArray = result.get(
		"recipe_ids",
		PackedStringArray()
	)
	var title := "%d MATERIALS" % total_quantity
	if total_quantity == 0 and overflow_quantity > 0:
		title = "MATERIAL STACKS MAX"
	elif overflow_quantity > 0:
		title += "  •  STACK MAX"
	if not recipe_ids.is_empty():
		title += "  •  %d BLUEPRINTS" % recipe_ids.size()
	var key_item_ids: PackedStringArray = result.get(
		"key_item_ids",
		PackedStringArray()
	)
	if key_item_ids.has("forest_core_gear_seal"):
		title += "  •  GEAR CRAFTING UNLOCKED"
	_queue_loot_notification(
		StageChestIcon,
		title,
		(
			"FIRST CLEAR  •  FOREST CORE SEAL"
			if key_item_ids.has("forest_core_gear_seal")
			else ("FIRST CLEAR" if bool(result.get("first_clear", false)) else "REPLAY CHEST")
		)
	)


func _queue_loot_notification(
	icon: Texture2D,
	title: String,
	source_text: String
) -> void:
	_loot_notifications.append({
		"icon": icon,
		"title": title,
		"source": source_text,
	})
	_play_next_loot_notification()


func _play_next_loot_notification() -> void:
	if _loot_toast_busy or _loot_notifications.is_empty() or not is_inside_tree():
		return
	_loot_toast_busy = true
	var notification: Dictionary = _loot_notifications.pop_front()
	loot_toast_icon.texture = notification.get("icon") as Texture2D
	loot_toast_icon.visible = loot_toast_icon.texture != null
	loot_toast_label.text = String(notification.get("title", "MATERIAL ACQUIRED"))
	loot_toast_source_label.text = String(notification.get("source", "LOOT"))
	loot_toast_panel.modulate.a = 0.0
	loot_toast_panel.show()
	var toast := create_tween()
	toast.tween_property(loot_toast_panel, "modulate:a", 1.0, 0.12)
	toast.tween_interval(1.05)
	toast.tween_property(loot_toast_panel, "modulate:a", 0.0, 0.2)
	await toast.finished
	if is_instance_valid(loot_toast_panel):
		loot_toast_panel.hide()
	_loot_toast_busy = false
	_play_next_loot_notification()


func _update_resolve(stacks: int, maximum: int) -> void:
	var label := get_node("ResolveLabel") as Label
	label.text = "RESOLVE %d/%d READY · NEXT SKILL +25%%" % [stacks, maximum] if stacks == maximum else "RESOLVE %d/%d STACKS · BASIC HITS" % [stacks, maximum]
	if _pursuit_link_available:
		label.text += " · RUPTURE +15%"
	label.tooltip_text = "Each landed basic swing fills one bar. Fill all three for +25% damage on your next skill. Lasts 8 seconds after your last basic hit; hitting more enemies in one swing still earns only one bar."
	label.add_theme_color_override("font_color", Color("c7efff") if stacks == maximum else Color("adc5d5"))

func _update_link(available: bool) -> void:
	_pursuit_link_available = available
	var mastery := _player.get_node("KingMastery") as KingMasteryComponent
	_update_resolve(mastery.stacks,mastery.definition.resolve_hits)
