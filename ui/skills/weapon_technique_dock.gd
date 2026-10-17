extends Control

## Observe the reviewed technique without granting a learned/mastery state.
const Slot = preload("res://ui/skills/skill_bar_slot.tscn")
const Tips = preload("res://ui/hud/combat_tooltip_readout.gd")
var actor: Player
var component: WarCycloneComponent
var slot: SkillBarSlot

func configure(player: Player) -> void:
	actor = player
	component = actor.war_cyclone
	name = "WeaponTechniqueDock"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot = Slot.instantiate()
	add_child(slot)
	var data := SkillSlotDefinition.new()
	data.slot_number = 1
	data.ability = component.definition
	slot.configure(data)
	slot.key_label.text = "F1"
	slot.bind_ability(component)
	slot.cooldown_tick.timeout.connect(_tick_channel)
	slot.activation_button.configure_tooltip(_tooltip)
	slot.activation_requested.connect(func(_index: int) -> void: actor.request_weapon_technique())
	component.availability_changed.connect(_refresh)
	component.phase_changed.connect(_phase)
	component.ability_finished.connect(_refresh)
	get_parent().resized.connect(_layout)
	_layout()
	_refresh()

func _layout() -> void:
	var viewport_size: Vector2 = (get_parent() as Control).size
	position = Vector2(roundf(viewport_size.x*.5-20),viewport_size.y-108)
	size = Vector2(40,40)
	slot.size = size

func _refresh() -> void:
	visible = component.is_available()
	if not visible:
		slot.cooldown_tick.stop()
		if slot._cooldown_tween != null and slot._cooldown_tween.is_valid(): slot._cooldown_tween.kill()
		return
	if component.is_ready(): slot._show_ready()
	elif component.cooldown_remaining > 0: slot._show_cooldown(component.cooldown_remaining)

func _phase(_phase_value: int, _seconds: float) -> void:
	slot.activation_button.disabled = false
	if component.phase == AbilityComponent.Phase.ACTIVE:
		if slot._cooldown_tween != null and slot._cooldown_tween.is_valid(): slot._cooldown_tween.kill()
		slot.ability_icon.modulate = Color.WHITE
		slot.cooldown_bar.max_value = component.definition.active_seconds
		_tick_channel()
	elif component.phase == AbilityComponent.Phase.RECOVERY:
		_refresh()

func _tick_channel() -> void:
	if component.phase != AbilityComponent.Phase.ACTIVE: return
	var remaining := maxf(component.definition.active_seconds-component.active_elapsed,0.0)
	slot.state_label.text = "%.1f" % remaining
	slot.state_label.add_theme_color_override("font_color",Color("a6e3f5"))
	slot.cooldown_bar.value = remaining

func _tooltip() -> Dictionary:
	var tuning := component.definition as WarCycloneDefinition
	var power := actor.attack_component.weapon.damage
	var damage := tuning.resolve_damage(power)
	return {
		"title": tuning.display_name+" · F1",
		"icon": tuning.icon,
		"subtitle":"PHYSICAL DAMAGE · CONTINUOUS AREA",
		"subtitle_color":Tips.type_color(tuning.damage_type),
		"facts":Tips.damage_fact(damage,tuning.damage_type,"Total damage")+"\n"+Tips.damage_fact(damage/tuning.active_seconds,tuning.damage_type,"Damage / second")+"\n[b]Duration[/b]  %.0fs     [b]Cooldown[/b]  %.0fs\n[b]Protection[/b]  [color=#a6e3f5]%d%% less incoming damage[/color]\n[b]Immunity[/b]  [color=#a6e3f5]Stun and stagger[/color]" % [tuning.active_seconds,tuning.cooldown_seconds,roundi(tuning.damage_reduction_ratio*100)],
		"body":"Sweep enemies within %dpx. Steer with WASD or right-click.\nF1 keeps spinning · Space dodges out.\n\nAttack speed quickens pulses. Stay in range for the full damage." % (tuning.hitbox_shape as CircleShape2D).radius,
		"footer":"AXE TECHNIQUE · Values before criticals, buffs and enemy defenses.",
	}
