class_name EncounterController
extends Node

signal wave_changed(index: int, total: int, title: String)
signal wave_cleared(index: int, total: int)
signal stage_cleared
signal portal_sealed
signal portal_prompt_changed(is_visible: bool, prompt_text: String, prompt_icon: Texture2D)
signal enemy_spawned(global_position: Vector2)
signal reinforcement_announced(delay_seconds: float)
signal inter_wave_gate_requested(next_wave_number: int)
signal inter_wave_gate_released
signal reward_chest_spawned(global_position: Vector2)
signal stage_reward_claimed(result: Dictionary)
signal progress_changed(snapshot: Dictionary)
signal arrival_finished

enum CompletionRewardMode {
	DIRECT_PORTAL,
	STAGE_CHEST,
}

@export var player: Player
@export var actors: Node2D
@export var spawn_points_root: Node2D
@export var waves: Array[Resource]
@export var mireling_scene: PackedScene
@export var rootling_scene: PackedScene
@export var thrall_scene: PackedScene
@export var bramble_spitter_scene: PackedScene
@export var armored_hog_scene: PackedScene
@export var rootbound_husk_scene: PackedScene
@export var portal_scene: PackedScene
@export var portal_parent: Node2D
@export var portal_spawn_point: Marker2D
@export_file("*.tscn") var portal_target_scene := ""
@export_enum("Normal", "Mini Boss", "Boss", "God", "Transcendent") var portal_tier := 0
@export_enum("Direct Portal", "Stage Chest") var completion_reward_mode: int = (
	CompletionRewardMode.DIRECT_PORTAL
)
@export var reward_chest_scene: PackedScene
@export var stage_loot_table: LootTableDefinition
@export_enum("Forest Cache", "Rootbound Reliquary") var reward_chest_tier := 0
@export var reward_chest_offset := Vector2(0.0, 52.0)
@export var summon_effect_scene: PackedScene
@export var effects_parent: Node2D
@export var projectiles_parent: Node2D
@export var auto_start := true
@export_range(0.5, 10.0, 0.25, "suffix:s") var inter_wave_delay := 2.25
@export_range(1, 20, 1) var max_active_enemies := 4
@export_range(0.1, 1.0, 0.05, "suffix:s") var arrival_warning_seconds := 0.3
@export var gated_wave_numbers: PackedInt32Array = []

var wave_index := -1
var _active_enemies := 0
var _spawning := false
var _spawn_points: Array[Marker2D] = []
var _transition_pending := false
var _started := false
var _pending_enemies: Array[PackedScene] = []
var _current_wave: EncounterWaveDefinition
var _initial_batch_active := false
var _reinforcement_pending := false
var _inter_wave_gate_active := false
var _completion_spawned := false
var _portal_opened := false
var _wave_defeated := 0
var _arrivals: Dictionary = {}
var _arrival_audio: AudioStreamPlayer2D
var _last_arrival_sound_msec := -1000


func get_progress() -> Dictionary:
	var state := "preparing"
	if _portal_opened: state = "complete"
	elif _completion_spawned: state = "claim_reward"
	elif _inter_wave_gate_active: state = "dialogue"
	elif _transition_pending: state = "wave_clear"
	elif _reinforcement_pending: state = "reinforcements"
	elif _current_wave != null: state = "combat"
	return {"state": state, "wave": mini(wave_index + 1, waves.size()), "waves": waves.size(), "title": _current_wave.title if _current_wave != null else "Prepare for the encounter", "defeated": _wave_defeated, "total": _current_wave.total_enemy_count() if _current_wave != null else 0}


func _emit_progress() -> void:
	progress_changed.emit(get_progress())


func _on_enemy_defeated() -> void:
	_wave_defeated += 1
	_emit_progress()


func _ready() -> void:
	for child in spawn_points_root.get_children():
		if child is Marker2D and child != portal_spawn_point: _spawn_points.append(child)
	if auto_start:
		call_deferred("start_encounter")


func start_encounter() -> void:
	if _started:
		return
	_started = true
	_start_encounter()


func release_inter_wave_gate() -> void:
	if not _inter_wave_gate_active:
		return
	_inter_wave_gate_active = false
	inter_wave_gate_released.emit()


func _start_encounter() -> void:
	var navigation_map := player.get_world_2d().get_navigation_map()
	# The authored map may synchronize after several fast headless frames.
	# Do not consume an initial slot or announce reinforcement before it exists.
	while NavigationServer2D.map_get_iteration_id(navigation_map) == 0:
		await get_tree().create_timer(0.05, false).timeout
		if not is_inside_tree(): return
	_advance_wave()


func _advance_wave() -> void:
	if player.health_component.current_health <= 0: return
	wave_index += 1
	if wave_index >= waves.size():
		_complete_encounter()
		return
	var wave := waves[wave_index] as EncounterWaveDefinition
	_current_wave = wave
	_wave_defeated = 0
	wave_changed.emit(wave_index + 1, waves.size(), wave.title)
	_emit_progress()
	_spawning = true
	_pending_enemies.clear()
	wave.append_spawn_scenes(_pending_enemies)
	## Preserve the implemented Stage I-IV wave resources while new stages use
	## generic scene/count entries instead of adding one property per enemy.
	for count in range(wave.mireling_count): _pending_enemies.append(mireling_scene)
	for count in range(wave.rootling_count): _pending_enemies.append(rootling_scene)
	for count in range(wave.thrall_count): _pending_enemies.append(thrall_scene)
	for count in range(wave.bramble_spitter_count): _pending_enemies.append(bramble_spitter_scene)
	for count in range(wave.armored_hog_count): _pending_enemies.append(armored_hog_scene)
	for count in range(wave.rootbound_husk_count): _pending_enemies.append(rootbound_husk_scene)
	_initial_batch_active = true
	await _spawn_initial_batch()
	_initial_batch_active = false
	_spawning = not _pending_enemies.is_empty()
	if not _pending_enemies.is_empty() and _active_enemies < max_active_enemies:
		_queue_reinforcements()
	_try_finish_stage()


func _spawn_initial_batch() -> void:
	var initial_batch_size: int = mini(max_active_enemies, _pending_enemies.size())
	for spawn_index in range(initial_batch_size):
		_spawn_enemy(_pending_enemies.pop_front())
		if spawn_index < initial_batch_size - 1:
			await get_tree().create_timer(_current_wave.spawn_interval, false).timeout
	while not _arrivals.is_empty():
		await arrival_finished


func _queue_reinforcements() -> void:
	if player.health_component.current_health <= 0: return
	if _reinforcement_pending or _pending_enemies.is_empty() or _current_wave == null:
		return
	_reinforcement_pending = true
	_spawning = true
	_emit_progress()
	reinforcement_announced.emit(_current_wave.reinforcement_delay)
	await get_tree().create_timer(_current_wave.reinforcement_delay, false).timeout
	if not is_inside_tree():
		return
	if _active_enemies < max_active_enemies and not _pending_enemies.is_empty():
		await _spawn_enemy(_pending_enemies.pop_front())
	_reinforcement_pending = false
	_spawning = not _pending_enemies.is_empty()
	_emit_progress()
	_try_finish_stage()
	if _active_enemies < max_active_enemies and not _pending_enemies.is_empty():
		call_deferred("_queue_reinforcements")


func _spawn_enemy(scene: PackedScene) -> void:
	if scene == null or _spawn_points.is_empty(): return
	if player.health_component.current_health <= 0: return
	if _active_enemies >= max_active_enemies:
		_retry_arrival(scene)
		return
	var enemy := scene.instantiate()
	var definition := enemy.get("definition") as EnemyDefinition
	var radius := maxf(14.0, definition.movement_footprint_radius + 4.0) if definition != null else 14.0
	var candidate: Variant = _find_safe_arrival(radius)
	if candidate == null:
		enemy.free()
		_retry_arrival(scene)
		return
	var spawn_position: Vector2 = candidate
	var effect := _spawn_summon_effect(spawn_position)
	# Reserve the slot before yielding; warnings count towards the live cap.
	_active_enemies += 1
	_arrivals[enemy] = {"point": spawn_position, "radius": radius, "effect": effect}
	_play_arrival_sound(spawn_position)
	await get_tree().create_timer(arrival_warning_seconds, false).timeout
	if not is_inside_tree() or not is_instance_valid(enemy): return
	_arrivals.erase(enemy)
	if player.health_component.current_health <= 0 or not _arrival_is_safe(spawn_position, radius):
		if is_instance_valid(effect): effect.queue_free()
		enemy.free()
		_active_enemies -= 1
		if player.health_component.current_health > 0: _retry_arrival(scene)
		arrival_finished.emit()
		return
	enemy.target = player
	_prepare_enemy(enemy)
	# Set the transform before ready: no timers/AI begin at the world origin.
	enemy.position = actors.to_local(spawn_position)
	actors.add_child(enemy)
	var health := enemy.get("health_component") as HealthComponent
	if health != null:
		health.died.connect(_on_enemy_defeated, CONNECT_ONE_SHOT)
	if enemy.has_method("set_projectile_parent"):
		enemy.set_projectile_parent(projectiles_parent)
	var direction := player.global_position - spawn_position
	if enemy.has_method("_set_facing"): enemy.call("_set_facing", direction)
	elif enemy.has_method("_set_facing_direction"): enemy.call("_set_facing_direction", direction)
	if is_instance_valid(effect): effect.release()
	enemy_spawned.emit(enemy.global_position)
	enemy.tree_exited.connect(_on_enemy_removed)
	arrival_finished.emit()


func _prepare_enemy(_enemy: Node) -> void:
	# Review encounters can remove reward components before their ready hooks.
	pass


func _spawn_summon_effect(global_position: Vector2) -> SummonEffect:
	if summon_effect_scene == null or effects_parent == null: return null
	var effect := summon_effect_scene.instantiate() as SummonEffect
	effects_parent.add_child(effect)
	effect.global_position = global_position
	return effect


func _retry_arrival(scene: PackedScene) -> void:
	# Unsafe terrain is deferred, never replaced by an unchecked nearest marker.
	_pending_enemies.push_front(scene)
	_spawning = true
	if not _initial_batch_active:
		call_deferred("_queue_reinforcements")


func _find_safe_arrival(radius: float) -> Variant:
	var requested := _choose_spawn_position()
	var candidates: Array[Vector2] = [requested]
	for distance in [40.0, 80.0]:
		for index in 8:
			candidates.append(requested + Vector2.RIGHT.rotated(index * TAU / 8.0) * distance)
	for point in _spawn_points: candidates.append(point.global_position)
	var map := player.get_world_2d().get_navigation_map()
	if NavigationServer2D.map_get_iteration_id(map) == 0: return null
	for point in candidates:
		var safe := NavigationServer2D.map_get_closest_point(map, point)
		if _arrival_is_safe(safe, radius) and not NavigationServer2D.map_get_path(map, safe, player.global_position, true).is_empty():
			return safe
	return null


func _arrival_is_safe(point: Vector2, radius: float) -> bool:
	if point.distance_to(player.global_position) < 96.0: return false
	if portal_spawn_point != null and point.distance_to(portal_spawn_point.global_position) < 64.0: return false
	for arrival: Dictionary in _arrivals.values():
		if point.distance_to(arrival.point) < radius + float(arrival.radius) + 8.0: return false
	var shape := CircleShape2D.new()
	shape.radius = radius
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.transform = Transform2D(0, point)
	query.collision_mask = 1 | 2 | 4
	query.collide_with_areas = false
	return player.get_world_2d().direct_space_state.intersect_shape(query, 1).is_empty()


func _play_arrival_sound(point: Vector2) -> void:
	if effects_parent == null: return
	var now := Time.get_ticks_msec()
	if now - _last_arrival_sound_msec < 550: return
	_last_arrival_sound_msec = now
	if _arrival_audio == null:
		_arrival_audio = AudioStreamPlayer2D.new()
		_arrival_audio.stream = preload("res://assets/audio/sfx/enemy_arrival.wav")
		_arrival_audio.bus = AudioDirector.SFX_BUS
		_arrival_audio.volume_db = -9.0
		_arrival_audio.max_distance = 850.0
		effects_parent.add_child(_arrival_audio)
	_arrival_audio.global_position = point
	if DisplayServer.get_name() != "headless": _arrival_audio.play()


func _exit_tree() -> void:
	for enemy: Node in _arrivals:
		var effect: Node = _arrivals[enemy].effect
		if is_instance_valid(effect): effect.queue_free()
		if is_instance_valid(enemy): enemy.free()
	_arrivals.clear()
	if is_instance_valid(_arrival_audio): _arrival_audio.queue_free()


func _choose_spawn_position() -> Vector2:
	var navigation_map := player.get_world_2d().get_navigation_map()
	if NavigationServer2D.map_get_iteration_id(navigation_map) > 0:
		for attempt in range(8):
			var angle := randf_range(0.0, TAU)
			var requested := player.global_position + Vector2.RIGHT.rotated(angle) * randf_range(250.0, 340.0)
			var safe := NavigationServer2D.map_get_closest_point(navigation_map, requested)
			var distance := safe.distance_to(player.global_position)
			if distance >= 210.0 and distance <= 380.0:
				return safe
	var nearest := _spawn_points[0]
	for point in _spawn_points:
		if point.global_position.distance_to(player.global_position) < nearest.global_position.distance_to(player.global_position):
			nearest = point
	return nearest.global_position


func _on_enemy_removed() -> void:
	_active_enemies = maxi(0, _active_enemies - 1)
	if not is_inside_tree(): return
	if not _initial_batch_active:
		_queue_reinforcements()
	_try_finish_stage()


func _try_finish_stage() -> void:
	if not is_inside_tree() or _transition_pending: return
	if player.health_component.current_health <= 0: return
	if not _spawning and _pending_enemies.is_empty() and _active_enemies == 0:
		_transition_pending = true
		_emit_progress()
		wave_cleared.emit(wave_index + 1, waves.size())
		await get_tree().create_timer(inter_wave_delay, false).timeout
		var next_wave_number := wave_index + 2
		if next_wave_number in gated_wave_numbers:
			_inter_wave_gate_active = true
			_emit_progress()
			inter_wave_gate_requested.emit(next_wave_number)
			await inter_wave_gate_released
			if not is_inside_tree():
				return
		_transition_pending = false
		_advance_wave()


func _spawn_portal() -> void:
	if portal_scene == null or portal_parent == null or portal_spawn_point == null:
		push_error("EncounterController requires a portal scene, parent, and spawn point.")
		return
	var portal := portal_scene.instantiate() as StagePortal
	portal.target_scene_path = portal_target_scene
	portal.portal_tier = portal_tier as StagePortal.PortalTier
	portal_parent.add_child(portal)
	portal.global_position = portal_spawn_point.global_position
	portal.player_entered.connect(func() -> void:
		if portal.target_scene_path.is_empty(): portal_sealed.emit()
	)
	portal.proximity_changed.connect(func(is_near: bool, prompt_text: String, prompt_icon: Texture2D) -> void:
		portal_prompt_changed.emit(is_near, prompt_text, prompt_icon)
	)
	_portal_opened = true
	stage_cleared.emit()
	_emit_progress()


func _complete_encounter() -> void:
	if _completion_spawned:
		return
	if completion_reward_mode == CompletionRewardMode.STAGE_CHEST:
		_spawn_stage_reward()
		return
	_completion_spawned = true
	_emit_progress()
	var loot_service := get_node_or_null("/root/LootService")
	if loot_service != null:
		loot_service.commit_expedition_rewards()
	_spawn_portal()


func _spawn_stage_reward() -> void:
	if _completion_spawned:
		return
	_completion_spawned = true
	if (
		reward_chest_scene == null
		or stage_loot_table == null
		or not stage_loot_table.has_valid_layout()
		or actors == null
		or portal_spawn_point == null
	):
		push_warning(
			"EncounterController has no valid stage reward chest; opening the portal directly."
		)
		_spawn_portal()
		return
	var chest := reward_chest_scene.instantiate() as StageRewardChest
	chest.configure(stage_loot_table, reward_chest_tier)
	actors.add_child(chest)
	chest.global_position = portal_spawn_point.global_position + reward_chest_offset
	chest.proximity_changed.connect(
		func(is_near: bool, prompt_text: String, prompt_icon: Texture2D) -> void:
			portal_prompt_changed.emit(is_near, prompt_text, prompt_icon)
	)
	chest.reward_claimed.connect(_on_stage_reward_claimed)
	reward_chest_spawned.emit(chest.global_position)
	_emit_progress()


func _on_stage_reward_claimed(result: Dictionary) -> void:
	stage_reward_claimed.emit(result)
	_spawn_portal()
