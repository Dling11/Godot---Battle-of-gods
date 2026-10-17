extends Node

## Authored proof authority. Presentation observes this session, never grants skills.
signal changed
signal ended(earned: bool, message: String)
enum Step { INACTIVE, CLEAVE, CONTROL, DODGE, COMPLETE }
const TARGET := preload("res://entities/training/training_target.tscn")
const PostPresentation = preload("res://entities/training/presentation/weapon_training_post.gd")
const AXE := preload("res://data/weapons/king_iron_beard_axe.tres")
const Layout = preload("res://levels/sanctuary/town/sanctuary_layout.gd")
const FLOOR := Layout.TRIAL_FLOOR
const START := Layout.TRIAL_START
const RETURN := Layout.MENTOR_APPROACH
const POSTS := Layout.POSTS
var actor: Player
var hub: Node
var step := Step.INACTIVE
var targets: Array[Node2D] = []
var normal_contacts: Dictionary = {}
var spin_contacts: Dictionary = {}
var travel := 0.0
var warning_center := Vector2.ZERO
var warning_remaining := 0.0
var _dodge_seen := false
var _spin_start := Vector2.ZERO
var _old_weapon: WeaponDefinition
var _old_bounds: Rect2
var _old_auto := false
var _old_auto_skills := false

func configure(owner_hub: Node) -> void:
	hub = owner_hub
	actor = hub.player
	actor.attack_component.hit_landed.connect(_on_normal_hit)
	actor.war_cyclone.hit_landed.connect(_on_spin_hit)
	actor.war_cyclone.phase_changed.connect(_on_phase)
	actor.war_cyclone.ability_finished.connect(_on_spin_finished)
	actor.evade_component.evade_started.connect(_on_dodge)
	_build_posts()
	set_physics_process(false)

func is_active() -> bool:
	return step in [Step.CLEAVE,Step.CONTROL,Step.DODGE]

func begin() -> bool:
	if is_active() or actor.is_defeated or actor.is_any_ability_casting() or actor.attack_component.phase != 0 or actor.evade_component.is_dashing(): return false
	_old_weapon = actor.attack_component.weapon
	if not actor.set_weapon_definition(AXE): return false
	_old_bounds = actor.movement_bounds
	_old_auto = actor.auto_combat.auto_farm_enabled
	_old_auto_skills = actor.auto_combat.auto_skills_enabled
	actor.auto_combat.set_auto_farm_enabled(false)
	actor.combat_targeting.cancel_click_move()
	actor.combat_targeting.clear_target()
	actor._clear_buffered_action()
	actor.set_meta(&"weapon_lesson_active",true)
	actor.movement_bounds = FLOOR
	actor.global_position = START
	actor.velocity = Vector2.ZERO
	actor.war_cyclone.set_lesson_loan(true)
	actor.war_cyclone.clear_cooldown()
	normal_contacts.clear()
	spin_contacts.clear()
	travel = 0.0
	step = Step.CLEAVE
	for target in targets:
		var health := target.get_node("HealthComponent") as HealthComponent
		health.set_current_health(health.maximum_health)
	set_physics_process(true)
	actor.get_node("Camera2D").reset_smoothing()
	changed.emit()
	return true

func _build_posts() -> void:
	for point: Vector2 in POSTS:
		var target: Node2D = TARGET.instantiate()
		target.position = point
		target.set_meta(&"weapon_lesson_target",self)
		target.get_node("HealthComponent").maximum_health = 100000
		hub.get_node("World/Actors").add_child(target)
		target.get_node("BodyVisual").hide()
		target.get_node("Rune").hide()
		target.get_node("HealthLabel").hide()
		var shadow: Polygon2D = target.get_node("Shadow")
		shadow.position = Vector2(0,-1)
		shadow.scale = Vector2(.65,.65)
		shadow.color = Color(.02,.03,.03,.35)
		shadow.z_index = -2
		var presentation := PostPresentation.new()
		target.add_child(presentation)
		presentation.configure(target)
		var footprint := CircleShape2D.new()
		footprint.radius = 5
		target.get_node("BodyCollision").shape = footprint
		target.get_node("BodyCollision").position.y = -2
		targets.append(target)

func _is_post(target: HurtboxComponent) -> bool:
	return is_instance_valid(target) and target.get_parent().get_meta(&"weapon_lesson_target",null) == self

func _on_normal_hit(target: HurtboxComponent, _info: DamageInfo) -> void:
	if step != Step.CLEAVE or not _is_post(target) or actor.attack_component.weapon != AXE: return
	if normal_contacts.has(target.get_instance_id()): return
	normal_contacts[target.get_instance_id()] = true
	if normal_contacts.size() >= 3:
		step = Step.CONTROL
		actor.war_cyclone.clear_cooldown()
	changed.emit()

func _on_spin_hit(target: HurtboxComponent, _info: DamageInfo) -> void:
	if step != Step.CONTROL or not _is_post(target): return
	if spin_contacts.has(target.get_instance_id()): return
	spin_contacts[target.get_instance_id()] = true
	changed.emit()

func _on_phase(phase: int, _duration: float) -> void:
	if step == Step.CONTROL and phase == AbilityComponent.Phase.ACTIVE:
		spin_contacts.clear()
		travel = 0.0
		_spin_start = actor.global_position

func _on_spin_finished() -> void:
	if step != Step.CONTROL: return
	if spin_contacts.size() >= 3 and travel >= 36.0:
		step = Step.DODGE
		_arm_warning()
	else:
		# Repetition is practice; cooldown is waived only in the loaned lesson.
		actor.war_cyclone.clear_cooldown()
	changed.emit()

func _arm_warning() -> void:
	warning_center = actor.global_position
	warning_remaining = 1.0
	_dodge_seen = false

func _on_dodge(_direction: Vector2) -> void:
	if step == Step.DODGE: _dodge_seen = true

func _physics_process(delta: float) -> void:
	if step == Step.CONTROL and actor.war_cyclone.phase == AbilityComponent.Phase.ACTIVE:
		var distance := actor.global_position.distance_to(_spin_start)
		if distance > travel:
			var previous := mini(roundi(travel),36)
			travel = distance
			if mini(roundi(travel),36) != previous: changed.emit()
	elif step == Step.DODGE:
		warning_remaining -= delta
		if warning_remaining <= 0:
			if _dodge_seen and actor.global_position.distance_to(warning_center) > 54:
				step = Step.COMPLETE
				_restore()
				claim()
			else:
				_arm_warning()
			changed.emit()

func has_completed_proof() -> bool:
	return step == Step.COMPLETE and normal_contacts.size() >= 3 and spin_contacts.size() >= 3 and travel >= 36.0 and not actor.war_cyclone.borrowed_for_lesson

func claim() -> bool:
	if not has_completed_proof(): return false
	var earned: bool = get_node("/root/WeaponTraining").complete_axe_lesson(self)
	var message := "CYCLONE LEARNED · Forge an Axe with Nema, equip it, then press F1."
	if not earned:
		message = "Practice complete. Leave this debug session to earn permanent lessons." if get_node("/root/SaveService").is_autosave_suppressed_for_debug() else "Lesson complete, but progress could not be saved. Speak to Veyr to retry the claim."
	ended.emit(earned,message)
	return earned

func cancel() -> void:
	if not is_active(): return
	step = Step.INACTIVE
	_restore()
	changed.emit()
	ended.emit(false,"Lesson ended. Your equipment is restored; try again with Veyr.")

func _restore() -> void:
	set_physics_process(false)
	actor.attack_component.cancel_attack()
	for ability in actor.get_all_ability_components(): ability.cancel_cast()
	actor.war_cyclone.cancel_cast()
	actor.war_cyclone.set_lesson_loan(false)
	actor.evade_component.cancel_evade()
	actor._clear_buffered_action()
	actor.set_meta(&"weapon_lesson_active",false)
	actor.combat_targeting.cancel_click_move()
	actor.combat_targeting.clear_target()
	actor.velocity = Vector2.ZERO
	actor.movement_bounds = _old_bounds
	actor.global_position = RETURN
	actor.set_weapon_definition(_old_weapon)
	actor.auto_combat.set_auto_farm_enabled(_old_auto)
	actor.auto_combat.set_auto_skills_enabled(_old_auto_skills)
	actor.get_node("Camera2D").reset_smoothing()

func _exit_tree() -> void:
	if is_active() and is_instance_valid(actor):
		actor.war_cyclone.set_lesson_loan(false)
		actor.set_meta(&"weapon_lesson_active",false)
