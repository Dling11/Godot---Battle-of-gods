class_name Rotcaller
extends CharacterBody2D

## Caster authority. Drawing, animation and warning rings are observers.
signal state_changed(state: State, seconds: float)
signal facing_changed(direction: Vector2)
signal moving_changed(moving: bool)
signal cast_started(point: Vector2)
signal cast_interrupted

enum State { SPAWNING, POSITIONING, WIND_UP, RECOVERY, STAGGER, DEAD }
const Footprint = preload("res://entities/enemies/components/enemy_footprint_system.gd")
const Separation = preload("res://entities/enemies/components/enemy_separation_component.tscn")
const ZoneScene = preload("res://entities/enemies/rotcaller/rotcaller_zone.tscn")

@export var definition: RotcallerDefinition
@export var target: CharacterBody2D
var state := State.SPAWNING
var facing_direction := Vector2.DOWN
var interrupted_casts := 0
var _zone: Node2D
var _zone_parent: Node2D
var _repath := 0.0
var _moving := false
var _separation: EnemySeparationComponent
var _state_timer: Timer
var _cooldown: Timer
@onready var health_component: HealthComponent = %HealthComponent
@onready var navigation_agent: NavigationAgent2D = %NavigationAgent2D
@onready var knockback: KnockbackComponent = $KnockbackComponent
@onready var stagger: StaggerComponent = $StaggerComponent

func _ready() -> void:
	assert(definition != null)
	_separation = Separation.instantiate()
	add_child(_separation)
	Footprint.configure(definition,$BodyCollision,navigation_agent,_separation)
	health_component.maximum_health = definition.maximum_health
	health_component.current_health = definition.maximum_health
	health_component.armor_rating = definition.armor_rating
	health_component.magic_resistance_rating = definition.magic_resistance_rating
	health_component.damaged.connect(_on_damaged)
	health_component.died.connect(_die)
	knockback.configure(definition)
	stagger.configure(definition)
	stagger.stagger_started.connect(_on_stagger_started)
	_state_timer = Timer.new()
	_state_timer.one_shot = true
	add_child(_state_timer)
	_state_timer.timeout.connect(_advance_state)
	_cooldown = Timer.new()
	_cooldown.one_shot = true
	add_child(_cooldown)
	_enter(State.SPAWNING,definition.spawn_seconds)

func set_projectile_parent(parent: Node2D) -> void:
	_zone_parent = parent

func _physics_process(delta: float) -> void:
	if state in [State.SPAWNING,State.DEAD] or not is_instance_valid(target):
		velocity = Vector2.ZERO
		_set_moving(false)
		return
	if target.get("health_component") != null and target.health_component.current_health <= 0:
		_cancel_zone()
		velocity = Vector2.ZERO
		_set_moving(false)
		return
	var direction := Vector2.ZERO
	if state == State.POSITIONING:
		var offset := target.global_position-global_position
		if offset.length() <= definition.attack_range and _cooldown.is_stopped() and not stagger.is_staggered():
			if _has_clear_line() and _safe_zone(target.global_position): _begin_cast(target.global_position)
			else: _cooldown.start(.3)
		elif offset.length() > 120 or not _has_clear_line():
			_repath -= delta
			if _repath <= 0:
				navigation_agent.target_position = target.global_position
				_repath = .25
			if not navigation_agent.is_navigation_finished(): direction = navigation_agent.get_next_path_position()-global_position
			elif _has_clear_line(): direction = offset
			direction = _separation.blend_direction(self,direction)
			_set_facing(direction)
	velocity = velocity.move_toward(direction.normalized()*definition.move_speed,definition.acceleration*delta)
	var motion := velocity
	velocity += knockback.velocity
	move_and_slide()
	_set_moving(state == State.POSITIONING and get_real_velocity().length_squared() > 1)
	velocity = motion
	if state == State.STAGGER and not stagger.is_staggered(): _enter(State.POSITIONING,0)

func _begin_cast(point: Vector2) -> void:
	_set_facing(point-global_position)
	velocity = Vector2.ZERO
	_set_moving(false)
	_zone = ZoneScene.instantiate()
	_zone.radius = definition.zone_radius
	var parent := _zone_parent if is_instance_valid(_zone_parent) else get_parent() as Node2D
	parent.add_child(_zone)
	_zone.global_position = point
	_zone.begin_warning(definition.wind_up_seconds)
	_cooldown.start(definition.cast_interval)
	_enter(State.WIND_UP,definition.wind_up_seconds)
	cast_started.emit(point)

func _safe_zone(point: Vector2) -> bool:
	var map := get_world_2d().get_navigation_map()
	if NavigationServer2D.map_get_iteration_id(map) == 0: return false
	if NavigationServer2D.map_get_closest_point(map,point).distance_to(point) > 2: return false
	if NavigationServer2D.map_get_path(map,global_position,point,true).is_empty(): return false
	var circle := CircleShape2D.new()
	circle.radius = definition.zone_radius
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = circle
	query.transform = Transform2D(0,point)
	query.collision_mask = 1
	query.collide_with_areas = false
	return get_world_2d().direct_space_state.intersect_shape(query,1).is_empty()

func _has_clear_line() -> bool:
	var ray := PhysicsRayQueryParameters2D.create(global_position,target.global_position,1)
	ray.exclude = [get_rid()]
	return get_world_2d().direct_space_state.intersect_ray(ray).is_empty()

func _advance_state() -> void:
	match state:
		State.SPAWNING,State.RECOVERY:
			_enter(State.STAGGER if stagger.is_staggered() else State.POSITIONING,0)
		State.WIND_UP:
			if is_instance_valid(_zone) and is_instance_valid(target) and health_component.current_health > 0 and (target.get("health_component") == null or target.health_component.current_health > 0):
				_zone.erupt(definition.attack_damage,self,definition.active_seconds,definition.damage_type)
			else: _cancel_zone()
			_enter(State.RECOVERY,definition.recovery_seconds)

func _enter(next: State, seconds: float) -> void:
	state = next
	_state_timer.stop()
	if seconds > 0: _state_timer.start(seconds)
	state_changed.emit(state,seconds)

func _on_damaged(_info: DamageInfo) -> void:
	if health_component.current_health <= 0:
		_cancel_zone()
	elif state == State.WIND_UP:
		_interrupt_cast()

func _on_stagger_started(seconds: float) -> void:
	if health_component.current_health <= 0 or state in [State.DEAD,State.SPAWNING]: return
	if state == State.WIND_UP:
		_interrupt_cast()
	elif state != State.RECOVERY:
		_enter(State.STAGGER,0)
		state_changed.emit(State.STAGGER,seconds)

func _interrupt_cast() -> void:
	_cancel_zone()
	interrupted_casts += 1
	cast_interrupted.emit()
	_enter(State.RECOVERY,definition.interruption_recovery)

func _cancel_zone() -> void:
	if is_instance_valid(_zone): _zone.cancel()
	_zone = null

func _set_facing(direction: Vector2) -> void:
	if direction.is_zero_approx(): return
	facing_direction = direction.normalized()
	facing_changed.emit(facing_direction)

func _set_moving(value: bool) -> void:
	if value == _moving: return
	_moving = value
	moving_changed.emit(value)

func _die() -> void:
	_cancel_zone()
	_cooldown.stop()
	_state_timer.stop()
	state = State.DEAD
	velocity = Vector2.ZERO
	_set_moving(false)
	collision_layer = 0
	$Hurtbox.set_deferred("monitorable",false)
	set_physics_process(false)
	state_changed.emit(State.DEAD,.5)
	get_tree().create_timer(.5,false).timeout.connect(queue_free)

func _exit_tree() -> void:
	_cancel_zone()
