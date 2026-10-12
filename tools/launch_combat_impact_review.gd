extends "res://tools/launch_enemy_arrival_review.gd"

## Real combat with reversible instance-only comparisons and isolated storage.
const Counter = preload("res://gameplay/abilities/king/perfect_dodge_counter.gd")
const CounterCue = preload("res://gameplay/presentation/perfect_counter_cue.gd")
var _type_choice := 0
var _showcase_crit := true
var _longer_reach := false
var _counter_enabled := true
var _safe_king := false
var _defense_choice := 0
var _target_defenses: Dictionary = {}
var _baseline_definitions: Dictionary = {}
var _baseline_weapon: WeaponDefinition

func _run() -> void:
	root.get_node("SaveService").configure_storage_path_for_testing("user://combat_impact_review.json")
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	root.get_node("RunSession").reset_run()
	root.mode = Window.MODE_WINDOWED
	root.grab_focus()
	await open_review()

func open_review() -> void:
	await super.open_review()
	root.title = "Battle of Gods — Combat Impact / Types / Counter (NO SAVES / REWARDS)"
	stage.player.health_component.is_damage_immune = _safe_king
	_visit(Vector2(520,480))
	_baseline_definitions.clear()
	_baseline_weapon = stage.player.attack_component.weapon.duplicate(true)
	_target_defenses.clear()
	for ability: AbilityComponent in stage.player.get_all_ability_components():
		_baseline_definitions[ability.get_instance_id()] = ability.definition.duplicate(true)
	_apply_player_profile()
	if _counter_enabled:
		var counter := Counter.new()
		counter.name = "PerfectDodgeCounter"
		stage.player.add_child(counter)
		var cue := CounterCue.new()
		cue.configure(counter)
		stage.player.add_child(cue)
	stage.encounter_controller.enemy_spawned.connect(_apply_target_defenses.unbind(1))
	var column: VBoxContainer = toolbar.get_child(0)
	for child in column.get_children():
		column.remove_child(child)
		child.queue_free()
	column.position = Vector2(12,144)
	column.custom_minimum_size.x = 210
	var title := Label.new()
	title.text = "COMBAT IMPACT · NO SAVES\nWASD · attack · 1/2/3/5 skills\nSPACE before a hit → counter"
	title.add_theme_font_size_override("font_size",10)
	column.add_child(title)
	var kind := OptionButton.new()
	for label in ["Damage: authored types","Damage test: physical","Damage test: magic","Damage test: pure"]: kind.add_item(label)
	kind.select(_type_choice)
	kind.item_selected.connect(func(index: int) -> void:
		_type_choice = index
		reset_review())
	column.add_child(kind)
	var defense := OptionButton.new()
	for label in ["Foes: authored defenses","Foes test: armor 100","Foes test: magic resist 100","Foes test: ward 50%"]: defense.add_item(label)
	defense.select(_defense_choice)
	defense.item_selected.connect(func(index: int) -> void:
		_defense_choice = index
		_apply_target_defenses())
	column.add_child(defense)
	_button(column,"Crit test: 50%" if _showcase_crit else "Crit: weapon rate",func() -> void:
		_showcase_crit = not _showcase_crit
		reset_review())
	_button(column,"Reach test: 42px" if _longer_reach else "Reach: current 36px",func() -> void:
		_longer_reach = not _longer_reach
		reset_review())
	_button(column,"Counter prototype: ON" if _counter_enabled else "Counter prototype: OFF",func() -> void:
		_counter_enabled = not _counter_enabled
		reset_review())
	_batch_buttons.clear()
	_batch_buttons.append(_button(column,"Spawn one melee foe",_spawn_batch.bind(1)))
	_batch_buttons.append(_button(column,"Spawn eight: melee + caster",_spawn_batch.bind(8)))
	_button(column,"King safe: ON" if _safe_king else "King vulnerable",func() -> void:
		_safe_king = not _safe_king
		reset_review())
	_button(column,"Reset comparison",reset_review)

func _apply_player_profile() -> void:
	var actor: Player = stage.player
	actor.attack_component.cancel_attack()
	var weapon := _baseline_weapon.duplicate(true) as WeaponDefinition
	weapon.critical_chance_ratio = .5 if _showcase_crit else weapon.critical_chance_ratio
	if _type_choice > 0: weapon.damage_type = DamageInfo.normalize_type(_type_choice-1)
	if _longer_reach:
		weapon.melee_hitbox_shape = weapon.melee_hitbox_shape.duplicate(true)
		var points: PackedVector2Array = weapon.melee_hitbox_shape.points
		for index in points.size(): points[index].x *= 42.0/36.0
		weapon.melee_hitbox_shape.points = points
	actor.set_weapon_definition(weapon)
	for ability: AbilityComponent in actor.get_all_ability_components():
		ability.definition = _baseline_definitions[ability.get_instance_id()].duplicate(true)
		if _type_choice > 0: ability.definition.damage_type = DamageInfo.normalize_type(_type_choice-1)
		actor._configure_ability_critical_profile(ability)
	actor.get_node("KingSkillLibrary").refresh()

func _apply_target_defenses() -> void:
	for enemy in stage.encounter_controller.actors.get_children():
		var health := enemy.get_node_or_null("HealthComponent") as HealthComponent
		if health == null: continue
		var id: int = enemy.get_instance_id()
		if not _target_defenses.has(id):
			_target_defenses[id] = Vector3(health.armor_rating,health.magic_resistance_rating,health.ward_reduction_ratio)
		var baseline: Vector3 = _target_defenses[id]
		match _defense_choice:
			0: health.set_equipment_defenses(baseline.x,baseline.z,baseline.y)
			1: health.set_equipment_defenses(100.0,0.0,0.0)
			2: health.set_equipment_defenses(0.0,0.0,100.0)
			3: health.set_equipment_defenses(0.0,.5,0.0)
