class_name PlayerProgressionComponent
extends Node

## Player-local progression authority synchronized with the in-memory RunSession service.

signal progression_changed(level: int, total_experience: int, next_level_experience: int)
signal coins_changed(total_coins: int)
signal leveled_up(new_level: int)
signal rewards_granted(credited_experience: int, credited_coins: int)

@export var definition: ProgressionDefinition

var level := 1
var total_experience := 0
var coins := 0
var _debug_cap_bypass := false


func _ready() -> void:
	if definition == null or definition.total_experience_by_level.size() < definition.maximum_level:
		push_error("PlayerProgressionComponent requires thresholds through its maximum level.")
		set_process(false)
		return
	var run_session := get_node_or_null("/root/RunSession")
	if run_session != null:
		total_experience = run_session.total_experience
		coins = run_session.coins
		if not run_session.progression_state_changed.is_connected(_on_run_session_progression_changed):
			run_session.progression_state_changed.connect(_on_run_session_progression_changed)
	_recalculate_level()
	var story := get_node_or_null("/root/StoryState")
	if story != null:
		story.story_state_changed.connect(_emit_progression_changed)
	_emit_progression_changed()
	coins_changed.emit(coins)


func grant_rewards(experience: int, coin_amount: int) -> void:
	var previous_experience := total_experience
	var previous_coins := coins
	if experience > 0:
		var cap := get_current_level_cap()
		var cap_experience := definition.total_experience_by_level[cap - 1]
		# Preserve existing saves above a newly introduced gate. New XP cannot
		# accumulate past the current ceiling and burst through future unlocks.
		var room := maxi(cap_experience - total_experience, 0)
		total_experience += mini(experience, room)
		while level < cap and total_experience >= _next_level_threshold():
			level += 1
			leveled_up.emit(level)
		_emit_progression_changed()
	if coin_amount > 0:
		coins += coin_amount
		coins_changed.emit(coins)
	_sync_run_session()
	rewards_granted.emit(total_experience - previous_experience, coins - previous_coins)


func spend_coins(amount: int) -> bool:
	if amount <= 0 or coins < amount:
		return false
	coins -= amount
	coins_changed.emit(coins)
	_sync_run_session()
	return true


func apply_debug_testing_preset() -> bool:
	if not OS.is_debug_build() or definition == null:
		return false
	var maximum_index := mini(definition.maximum_level - 1, definition.total_experience_by_level.size() - 1)
	if maximum_index < 0:
		return false
	_debug_cap_bypass = true
	total_experience = definition.total_experience_by_level[maximum_index]
	coins = 999
	_recalculate_level()
	_emit_progression_changed()
	coins_changed.emit(coins)
	_sync_run_session()
	return true


func experience_into_current_level() -> int:
	return total_experience - definition.total_experience_by_level[level - 1]


func experience_required_for_current_level() -> int:
	if level >= get_current_level_cap():
		return 0
	return _next_level_threshold() - definition.total_experience_by_level[level - 1]


func _next_level_threshold() -> int:
	return definition.total_experience_by_level[level]


func _emit_progression_changed() -> void:
	var next_level_experience := _next_level_threshold() if level < get_current_level_cap() else total_experience
	progression_changed.emit(level, total_experience, next_level_experience)


func get_current_level_cap() -> int:
	if _debug_cap_bypass:
		return definition.maximum_level
	return maxi(level, definition.unlocked_cap(get_node_or_null("/root/StoryState")))


func _recalculate_level() -> void:
	level = definition.get_level_for_total_experience(total_experience)


func _sync_run_session() -> void:
	var run_session := get_node_or_null("/root/RunSession")
	if run_session != null:
		run_session.update_progression(total_experience, coins)


func _on_run_session_progression_changed(experience: int, coin_total: int) -> void:
	if total_experience == experience and coins == coin_total:
		return
	total_experience = maxi(experience, 0)
	coins = maxi(coin_total, 0)
	_recalculate_level()
	_emit_progression_changed()
	coins_changed.emit(coins)
