class_name BossHealthHUD
extends Control

## Reusable presentation-only health surface for one active major boss.
## HealthComponent remains the sole authority for values and death.

@onready var name_label: Label = %NameLabel
@onready var health_label: Label = %HealthLabel
@onready var context_label: Label = %ContextLabel
@onready var phase_label: Label = %PhaseLabel
@onready var damage_trail: ProgressBar = %DamageTrail
@onready var health_bar: ProgressBar = %HealthBar
@onready var guard_bar: ProgressBar = %GuardBar

var health_component: HealthComponent
var _damage_tween: Tween
var _reveal_tween: Tween
var _phase_status := ""
var _phase_color := Color.WHITE


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	hide()


func bind_boss(
	next_health: HealthComponent,
	boss_name: String,
	context: String = "BOSS ENCOUNTER"
) -> void:
	clear_boss()
	set_phase_markers(0.3, 0.8)
	if next_health == null:
		push_error("BossHealthHUD requires a HealthComponent.")
		return
	health_component = next_health
	name_label.text = boss_name.to_upper()
	context_label.text = context.to_upper()
	health_component.health_changed.connect(_on_health_changed)
	health_component.died.connect(_on_boss_died)
	damage_trail.max_value = health_component.maximum_health
	damage_trail.value = health_component.current_health
	health_bar.max_value = health_component.maximum_health
	health_bar.value = health_component.current_health
	_update_labels(health_component.current_health, health_component.maximum_health)
	show()
	modulate.a = 0.0
	_reveal_tween = create_tween()
	_reveal_tween.tween_property(self, "modulate:a", 1.0, 0.22)


func clear_boss() -> void:
	if is_instance_valid(health_component):
		if health_component.health_changed.is_connected(_on_health_changed):
			health_component.health_changed.disconnect(_on_health_changed)
		if health_component.died.is_connected(_on_boss_died):
			health_component.died.disconnect(_on_boss_died)
	health_component = null
	_phase_status = ""
	clear_guard()
	_kill_tweens()
	hide()


func set_phase_status(text: String, color := Color(0.86, 0.78, 0.55)) -> void:
	# Boss-owned state can override the legacy Stage V health bands.
	_phase_status = text
	_phase_color = color
	if is_instance_valid(health_component):
		_update_labels(health_component.current_health, health_component.maximum_health)


func show_guard(remaining: float, maximum: float, seconds_left: float) -> void:
	guard_bar.show()
	offset_bottom = 92.0
	guard_bar.max_value = maximum
	guard_bar.value = maxf(remaining, 0)
	set_phase_status("SEAL %d/%d  |  %.1fs" % [ceili(maxf(remaining, 0)), int(maximum), seconds_left], Color("edbc72"))


func clear_guard() -> void:
	if guard_bar != null:
		guard_bar.hide()
	offset_bottom = 82.0


func set_phase_markers(first: float, second: float) -> void:
	var marks := [$Panel/Margin/Stack/BarStack/ThirtyMark, $Panel/Margin/Stack/BarStack/EightyMark]
	for index in 2:
		marks[index].anchor_left = first if index == 0 else second
		marks[index].anchor_right = marks[index].anchor_left


func _on_health_changed(current: float, maximum: float) -> void:
	health_bar.max_value = maximum
	damage_trail.max_value = maximum
	var previous_trail := damage_trail.value
	health_bar.value = current
	_update_labels(current, maximum)
	if _damage_tween != null and _damage_tween.is_valid():
		_damage_tween.kill()
	if current >= previous_trail:
		damage_trail.value = current
		return
	_damage_tween = create_tween()
	_damage_tween.tween_interval(0.14)
	_damage_tween.tween_property(damage_trail, "value", current, 0.34).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _update_labels(current: float, maximum: float) -> void:
	health_label.text = "%d / %d" % [roundi(current), roundi(maximum)]
	if current <= 0.0:
		phase_label.text = "DEFEATED"
		phase_label.add_theme_color_override("font_color", Color(0.66, 0.62, 0.56, 1.0))
		return
	if not _phase_status.is_empty():
		phase_label.text = _phase_status
		phase_label.add_theme_color_override("font_color", _phase_color)
		return
	var ratio := current / maxf(maximum, 1.0)
	if ratio <= 0.30:
		phase_label.text = "PHASE III"
		phase_label.add_theme_color_override("font_color", Color(1.0, 0.36, 0.24, 1.0))
	elif ratio < 0.80:
		phase_label.text = "PHASE II"
		phase_label.add_theme_color_override("font_color", Color(0.94, 0.68, 0.28, 1.0))
	else:
		phase_label.text = "PHASE I"
		phase_label.add_theme_color_override("font_color", Color(0.68, 0.88, 0.48, 1.0))


func _on_boss_died() -> void:
	_update_labels(0.0, health_component.maximum_health if is_instance_valid(health_component) else 1.0)


func _kill_tweens() -> void:
	if _damage_tween != null and _damage_tween.is_valid():
		_damage_tween.kill()
	if _reveal_tween != null and _reveal_tween.is_valid():
		_reveal_tween.kill()
