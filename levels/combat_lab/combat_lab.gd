extends Node

const LandingFeedback = preload("res://entities/enemies/stage_5_boss/stage_5_boss_landing_feedback.gd")
const ROSTER := [
	{"label": "Mireling", "scene": preload("res://entities/enemies/mireling/mireling.tscn")},
	{"label": "Rootling", "scene": preload("res://entities/enemies/rootling/rootling.tscn")},
	{"label": "Forsaken Thrall", "scene": preload("res://entities/enemies/forsaken_thrall/forsaken_thrall.tscn")},
	{"label": "Bramble Spitter", "scene": preload("res://entities/enemies/bramble_spitter/bramble_spitter.tscn")},
	{"label": "Armored Hog [ELITE]", "scene": preload("res://entities/enemies/armored_hog/armored_hog.tscn")},
	{"label": "Crag Bear [STAGE VI]", "scene": preload("res://entities/enemies/crag_bear/crag_bear.tscn")},
	{"label": "Rootbound Husk [MINI-BOSS]", "scene": preload("res://entities/enemies/rootbound_husk/rootbound_husk.tscn")},
	{"label": "Stage 5 Boss [PROOF]", "scene": preload("res://entities/enemies/stage_5_boss/stage_5_boss.tscn")},
	{"label": "The Examiner [DIVINE TRIAL]", "scene": preload("res://entities/enemies/examiner/examiner.tscn")},
]
const ARENA_BOUNDS := Rect2(40.0, 92.0, 650.0, 390.0)

@export var player: Player
@export var actors: Node2D
@export var projectiles: Node2D
@export var effects: Node2D
@export var camera: Camera2D
@export var combat_hud: CombatHUD
@export var boss_hud: BossHealthHUD
@export var court_arena: CourtOfFirstMeasure
@export var base_arena: CanvasItem
@export var base_arena_border: CanvasItem
@export var examiner_director: ExaminerEncounterDirector
@export var enemy_selector: OptionButton
@export var spawn_one_button: Button
@export var spawn_four_button: Button
@export var spawn_eight_button: Button
@export var force_phase_button: Button
@export var clear_button: Button
@export var reset_button: Button
@export var exit_button: Button
@export var ai_toggle: CheckButton
@export var invincible_toggle: CheckButton
@export var combat_tools_button: Button
@export var status_label: Label
@export var latest_label: Label

@onready var review_tabs: TabContainer = $UI/LabPanel/Margin/Stack/Tabs
@onready var skills_controls: VBoxContainer = $UI/LabPanel/Margin/Stack/Tabs/Skills/Controls

var _active_enemies: Array[Node2D] = []
var _ai_enabled := true
var _invincible := true


func _ready() -> void:
	if not OS.is_debug_build():
		_transition_to_sanctuary()
		return
	if not _has_required_dependencies():
		push_error("CombatLab is missing a required dependency.")
		return
	var admin_state := get_node_or_null("/root/DebugAdminState")
	if admin_state != null:
		admin_state.call("set_enabled", true)
	combat_hud.bind_player(player)
	combat_hud.character_menu_requested.connect(get_node("UI/CharacterMenu").open_menu)
	# Trial instructions must sit below the boss HUD, not behind its panel.
	combat_hud.stage_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	combat_hud.stage_label.position = Vector2(55, 132)
	combat_hud.stage_label.size = Vector2(620, 26)
	combat_hud.stage_label.add_theme_font_size_override("font_size", 11)
	player.enable_debug_combat_tools()
	player.health_component.set_current_health(player.health_component.maximum_health)
	player.health_component.set_invulnerable(true)
	player.health_component.is_damage_immune = true
	for entry: Dictionary in ROSTER:
		enemy_selector.add_item(String(entry["label"]))
	enemy_selector.select(ROSTER.size() - 1)
	_set_examiner_arena(true)
	_bind_controls()
	_style_review_panel()
	var king_review := preload("res://levels/combat_lab/king_combat_review.gd").new()
	king_review.name = "KingCombatReview"
	add_child(king_review)
	var weapon_review := preload("res://levels/combat_lab/weapon_review.gd").new()
	weapon_review.lab = self
	weapon_review.name = "Weapons"
	review_tabs.add_child(weapon_review)
	review_tabs.get_tab_bar().focus_mode = Control.FOCUS_NONE
	review_tabs.tab_changed.connect(_on_review_tab_changed)
	player.testing_preset_applied.connect(_on_testing_preset_applied)
	_update_latest_label()
	_update_status()
	call_deferred("spawn_selected", 1)
	if "--king-review" in OS.get_cmdline_user_args() or "--pursuit-review" in OS.get_cmdline_user_args():
		king_review.call_deferred("open_review")
	if "--earthsplitter-review" in OS.get_cmdline_user_args() or "--earthsplitter-advanced-review" in OS.get_cmdline_user_args():
		king_review.call_deferred("open_review")
		if "--earthsplitter-advanced-review" in OS.get_cmdline_user_args():
			king_review.call_deferred("set_earthsplitter_form", EarthsplitterDefinition.Form.FAN)

	if "--molten-crash-review" in OS.get_cmdline_user_args():
		king_review.call_deferred("open_review")

func show_skills_tab() -> void:
	review_tabs.current_tab = 1


func _on_review_tab_changed(index: int) -> void:
	var review := get_node_or_null("KingCombatReview")
	if index != 1 and review != null and review.buff_test.opened:
		review.buff_test.close(false)


func _on_testing_preset_applied(_level: int, _coins: int) -> void:
	if review_tabs.current_tab!=2: show_skills_tab()


func _style_review_panel() -> void:
	# The lab uses a compact control surface at the real 960x540 viewport.
	var panel := get_node("UI/LabPanel") as Control
	var review_theme := Theme.new()
	review_theme.default_font_size = 11
	for type_name in ["Button", "OptionButton"]:
		for style_name in ["normal", "hover", "pressed", "disabled"]:
			var style := StyleBoxFlat.new()
			style.bg_color = Color("15212b") if style_name == "normal" else Color("23333d")
			style.border_color = Color("60583f") if style_name == "normal" else Color("b4a471")
			style.set_border_width_all(1)
			style.content_margin_left = 7
			style.content_margin_right = 7
			style.content_margin_top = 4
			style.content_margin_bottom = 4
			review_theme.set_stylebox(style_name, type_name, style)
		review_theme.set_color("font_color", type_name, Color("e2dac5"))
	panel.theme = review_theme
	for control in panel.find_children("*", "BaseButton", true, false):
		control.add_theme_font_size_override("font_size", 11)
		control.custom_minimum_size.y = 26.0
	var roster := combat_hud.find_child("EnemyRosterPanel", true, false) as Control
	if roster != null:
		roster.hide()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_combat_lab"):
		get_viewport().set_input_as_handled()
		_transition_to_sanctuary()
	elif event.is_action_pressed("arena_restart"):
		get_viewport().set_input_as_handled()
		get_tree().reload_current_scene()


func spawn_selected(count: int) -> void:
	if not OS.is_debug_build() or enemy_selector.selected < 0:
		return
	var entry: Dictionary = ROSTER[enemy_selector.selected]
	var scene := entry["scene"] as PackedScene
	var spawn_count := 1 if _selected_is_examiner() else clampi(count, 1, 8)
	_set_examiner_arena(_selected_is_examiner())
	for index in range(spawn_count):
		_spawn_enemy(scene, index, spawn_count)
	_update_latest_label()
	_update_status()


func clear_simulation() -> void:
	player.ability_4_component.cancel_cast()
	for group in ["worldsplitter_sequences", "worldsplitter_effects"]:
		for released in get_tree().get_nodes_in_group(group):
			if is_ancestor_of(released): released.queue_free()
	boss_hud.clear_boss()
	examiner_director.bind(null)
	force_phase_button.disabled = true
	for enemy in _active_enemies.duplicate():
		if is_instance_valid(enemy):
			enemy.queue_free()
	_active_enemies.clear()
	_clear_children(projectiles)
	_clear_children(effects)
	latest_label.text = "LATEST: NONE"
	_update_status()


func set_enemy_ai_enabled(enabled: bool) -> void:
	_ai_enabled = enabled
	ai_toggle.set_pressed_no_signal(enabled)
	for enemy in _active_enemies:
		if is_instance_valid(enemy) and "target" in enemy:
			enemy.set("target", player if enabled else null)
	_update_status()


func set_player_invincible(enabled: bool) -> void:
	_invincible = enabled
	invincible_toggle.set_pressed_no_signal(enabled)
	player.health_component.set_invulnerable(enabled)
	player.health_component.is_damage_immune = enabled
	if enabled:
		player.health_component.set_current_health(player.health_component.maximum_health)
	_update_status()


func get_live_enemy_count() -> int:
	var count := 0
	for enemy in _active_enemies:
		if not is_instance_valid(enemy):
			continue
		var health := enemy.find_child("HealthComponent", true, false) as HealthComponent
		if health != null and health.current_health > 0.0:
			count += 1
	return count


func _spawn_enemy(scene: PackedScene, index: int, requested_count: int) -> void:
	if scene == null:
		return
	var enemy := scene.instantiate() as Node2D
	if enemy == null or not "target" in enemy:
		if enemy != null:
			enemy.free()
		return
	var reward := enemy.get_node_or_null("EnemyRewardComponent")
	if reward != null:
		enemy.remove_child(reward)
		reward.free()
	enemy.set("target", player if _ai_enabled else null)
	if "arena_bounds" in enemy:
		enemy.set("arena_bounds", ARENA_BOUNDS)
	if enemy.has_method("set_projectile_parent"):
		enemy.call("set_projectile_parent", projectiles)
	actors.add_child(enemy)
	enemy.global_position = _spawn_position(index, requested_count)
	_active_enemies.append(enemy)
	enemy.tree_exited.connect(_on_enemy_exited.bind(enemy))
	var health := enemy.find_child("HealthComponent", true, false) as HealthComponent
	if health != null:
		health.died.connect(_on_enemy_died.bind(enemy))
		health.health_changed.connect(_on_enemy_health_changed.bind(enemy))
	if enemy is Stage5Boss:
		boss_hud.bind_boss(enemy.health_component, "STAGE 5 BOSS", "COMBAT LAB")
		var feedback := LandingFeedback.new()
		feedback.boss = enemy
		feedback.camera = camera
		add_child(feedback)
		enemy.tree_exited.connect(feedback.queue_free)
	elif enemy is Examiner:
		boss_hud.bind_boss(enemy.health_component, "THE EXAMINER", "COURT OF THE FIRST MEASURE")
		boss_hud.set_phase_status("FIRST MEASURE")
		boss_hud.set_phase_markers(0.35, 0.60)
		enemy.trial_progressed.connect(func(damage: float, required: float, seconds_left: float) -> void:
			boss_hud.show_guard(required - damage, required, seconds_left)
		)
		enemy.state_changed.connect(_on_examiner_state_changed.bind(enemy))
		enemy.phase_two_started.connect(func() -> void: boss_hud.set_phase_status("SECOND MEASURE", Color("91d8df")))
		enemy.axiom_started.connect(court_arena.pulse_measure)
		enemy.measure_recognized.connect(_on_measure_recognized)
		examiner_director.bind(enemy)
		force_phase_button.disabled = false


func _on_examiner_state_changed(state: Examiner.State, _duration: float, enemy: Examiner) -> void:
	if not is_instance_valid(enemy) or boss_hud.health_component != enemy.health_component:
		return
	var technique := ""
	if state not in [Examiner.State.TRIAL_CHANNEL, Examiner.State.ORB_CHARGE, Examiner.State.FIRMAMENT_CHARGE]:
		boss_hud.clear_guard()
	match state:
		Examiner.State.FIRMAMENT_CHARGE: technique = "CRIMSON FIRMAMENT  |  BREAK THE SEAL"
		Examiner.State.FIRMAMENT_BARRAGE: technique = "CRIMSON FIRMAMENT  |  KEEP MOVING"
		Examiner.State.ORB_CHARGE: technique = "BORROWED SUN  |  BREAK HIS SEAL"
		Examiner.State.ORB_RELEASE: technique = "BORROWED SUN  |  MOVE FROM THE MARK"
		Examiner.State.GUARD_BROKEN: technique = "SEAL SHATTERED  |  ATTACK NOW"
		Examiner.State.GUARD_RECOVERY: technique = "RECOVERING"
		Examiner.State.BERSERK_AWAKEN: technique = "THIRD MEASURE  |  UNBOUND"
		Examiner.State.CROWNFALL: technique = "CROWNFALL  |  THREE VERDICTS"
		Examiner.State.COMBO_WIND_UP: technique = "PRECISION THRUST"
		Examiner.State.PURSUIT_WIND_UP: technique = "REPRISAL  |  SIDESTEP"
		Examiner.State.TRIAL_CHANNEL: technique = "BREAK THE SEAL"
		Examiner.State.SWEEP_WIND_UP: technique = "DIVINE SWEEP"
		Examiner.State.CHARGE_WIND_UP: technique = "JUDGMENT CHARGE"
		Examiner.State.HELD_JUDGMENT: technique = "HELD JUDGMENT  |  WAIT FOR THE FALL"
		Examiner.State.SLAM_WIND_UP: technique = "GROUND JUDGMENT"
		Examiner.State.REFUTATION_WIND_UP: technique = "REFUTATION"
		Examiner.State.AXIOM_WIND_UP: technique = "AXIOM DIVIDE"
		Examiner.State.DESCENT_PREPARE: technique = "DIVINE DESCENT"
		Examiner.State.DESCENT_ABSENT: technique = "REACH SANCTUARY" if enemy._trial_succeeded else "FINAL VERDICT"
		Examiner.State.APPROACH:
			technique = "THIRD MEASURE  |  UNBOUND" if enemy.is_berserk() else ("SECOND MEASURE" if enemy.is_phase_two() else "FIRST MEASURE")
	if not technique.is_empty():
		boss_hud.set_phase_status(technique, Color("91d8df") if enemy.is_phase_two() else Color("d6c593"))


func _spawn_position(index: int, requested_count: int) -> Vector2:
	var columns := 4 if requested_count >= 4 else requested_count
	var rows := ceili(float(requested_count) / float(maxi(columns, 1)))
	var column := index % maxi(columns, 1)
	var row := index / maxi(columns, 1)
	var x := lerpf(120.0, 620.0, float(column + 1) / float(columns + 1))
	var y := lerpf(140.0, 300.0, float(row + 1) / float(rows + 1))
	return Vector2(x, y)


func _bind_controls() -> void:
	## These are mouse/touch administration controls, not gameplay actions.
	## Prevent a clicked control from retaining keyboard focus and consuming the
	## shared UI-accept key (Space), which belongs to Dash/root struggle in play.
	for control: Control in [
		enemy_selector,
		spawn_one_button,
		spawn_four_button,
		spawn_eight_button,
		ai_toggle,
		invincible_toggle,
		combat_tools_button,
		force_phase_button,
		clear_button,
		reset_button,
		exit_button,
	]:
		control.focus_mode = Control.FOCUS_NONE
	spawn_one_button.pressed.connect(spawn_selected.bind(1))
	spawn_four_button.pressed.connect(spawn_selected.bind(4))
	spawn_eight_button.pressed.connect(spawn_selected.bind(8))
	clear_button.pressed.connect(clear_simulation)
	reset_button.pressed.connect(get_tree().reload_current_scene)
	exit_button.pressed.connect(_transition_to_sanctuary)
	ai_toggle.toggled.connect(set_enemy_ai_enabled)
	invincible_toggle.toggled.connect(set_player_invincible)
	combat_tools_button.pressed.connect(player.enable_debug_combat_tools)
	force_phase_button.pressed.connect(_force_examiner_phase)
	enemy_selector.item_selected.connect(_on_roster_selected)


func _on_roster_selected(_index: int) -> void:
	_set_examiner_arena(_selected_is_examiner())
	force_phase_button.visible = _selected_is_examiner()
	force_phase_button.disabled = not _selected_is_examiner()
	_update_latest_label()


func _force_examiner_phase() -> void:
	if not examiner_director.force_divine_descent():
		combat_hud.show_story_message("SPAWN A FRESH EXAMINER FIRST", 1.5)


func _on_measure_recognized() -> void:
	combat_hud.show_story_message("THE EXAMINER:  MEASURE ACCEPTED.", 2.0)


func _selected_is_examiner() -> bool:
	return enemy_selector.selected == ROSTER.size() - 1


func _set_examiner_arena(enabled: bool) -> void:
	if court_arena != null:
		court_arena.visible = enabled
	if base_arena != null:
		base_arena.visible = not enabled
	if base_arena_border != null:
		base_arena_border.visible = not enabled


func _on_enemy_health_changed(current: float, maximum: float, enemy: Node2D) -> void:
	if is_instance_valid(enemy) and enemy == _latest_valid_enemy():
		latest_label.text = "LATEST: %s  |  %d / %d HP" % [enemy.name, roundi(current), roundi(maximum)]


func _on_enemy_died(_enemy: Node2D) -> void:
	_update_status()


func _on_enemy_exited(enemy: Node2D) -> void:
	_active_enemies.erase(enemy)
	if enemy is Stage5Boss or enemy is Examiner:
		call_deferred("_refresh_boss_hud")
	_update_latest_label()
	_update_status()


func _refresh_boss_hud() -> void:
	for index in range(_active_enemies.size() - 1, -1, -1):
		var enemy := _active_enemies[index]
		if is_instance_valid(enemy) and enemy is Stage5Boss and enemy.health_component.current_health > 0.0:
			boss_hud.bind_boss(enemy.health_component, "STAGE 5 BOSS", "COMBAT LAB")
			return
		if is_instance_valid(enemy) and enemy is Examiner and enemy.health_component.current_health > 0.0:
			boss_hud.bind_boss(enemy.health_component, "THE EXAMINER", "COURT OF THE FIRST MEASURE")
			boss_hud.set_phase_status("SECOND MEASURE" if enemy.is_phase_two() else "FIRST MEASURE")
			return
	boss_hud.clear_boss()


func _latest_valid_enemy() -> Node2D:
	for index in range(_active_enemies.size() - 1, -1, -1):
		if is_instance_valid(_active_enemies[index]):
			return _active_enemies[index]
	return null


func _update_latest_label() -> void:
	var enemy := _latest_valid_enemy()
	if enemy == null:
		latest_label.text = "LATEST: %s" % String(ROSTER[enemy_selector.selected]["label"])
		return
	var health := enemy.find_child("HealthComponent", true, false) as HealthComponent
	latest_label.text = "LATEST: %s" % enemy.name
	if health != null:
		latest_label.text += "  |  %d / %d HP" % [roundi(health.current_health), roundi(health.maximum_health)]


func _update_status() -> void:
	status_label.text = "LIVE: %d  |  AI: %s  |  KING: %s" % [
		get_live_enemy_count(),
		"ON" if _ai_enabled else "PAUSED",
		"INVINCIBLE" if _invincible else "VULNERABLE",
	]


func _clear_children(parent: Node) -> void:
	for child in parent.get_children():
		child.queue_free()


func _transition_to_sanctuary() -> void:
	var transition := get_node_or_null("/root/SceneTransition")
	if transition != null:
		transition.call("transition_to", "res://levels/sanctuary/sanctuary.tscn")


func _has_required_dependencies() -> bool:
	return (
		player != null
		and actors != null
		and projectiles != null
		and effects != null
		and camera != null
		and combat_hud != null
		and boss_hud != null
		and court_arena != null
		and base_arena != null
		and base_arena_border != null
		and examiner_director != null
		and enemy_selector != null
		and spawn_one_button != null
		and spawn_four_button != null
		and spawn_eight_button != null
		and force_phase_button != null
		and clear_button != null
		and reset_button != null
		and exit_button != null
		and ai_toggle != null
		and invincible_toggle != null
		and combat_tools_button != null
		and status_label != null
		and latest_label != null
	)
