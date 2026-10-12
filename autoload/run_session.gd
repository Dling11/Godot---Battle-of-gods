extends Node

## Current-run state that survives scene transitions. SaveService may snapshot
## this data, but RunSession does not perform file I/O.

signal progression_state_changed(total_experience: int, coins: int)
signal player_health_state_changed(current_health: float)

const SNAPSHOT_VERSION := 1

var total_experience := 0
var coins := 0
var player_current_health := -1.0
var king_skill_slots: Array = []
var king_pursuit_rank := 0
var king_vow_rank := 0
var king_worldsplitter_rank := 0
var king_earthsplitter_rank := 0
var king_molten_rank := 0
var king_skill_layout_version := 2


func update_progression(experience: int, coin_total: int) -> void:
	total_experience = maxi(experience, 0)
	coins = maxi(coin_total, 0)
	progression_state_changed.emit(total_experience, coins)


func can_spend_coins(amount: int) -> bool:
	return amount >= 0 and coins >= amount


func spend_coins(amount: int) -> bool:
	if amount <= 0 or not can_spend_coins(amount):
		return false
	coins -= amount
	progression_state_changed.emit(total_experience, coins)
	return true


func add_coins(amount: int) -> bool:
	if amount <= 0 or coins > 2147483647 - amount:
		return false
	coins += amount
	progression_state_changed.emit(total_experience, coins)
	return true


func has_player_health_state() -> bool:
	return player_current_health >= 0.0


func update_player_health(current_health: float) -> void:
	player_current_health = maxf(current_health, 0.0)
	player_health_state_changed.emit(player_current_health)


func reset_run() -> void:
	king_skill_slots.clear()
	king_pursuit_rank = 0
	king_vow_rank = 0
	king_worldsplitter_rank = 0
	king_earthsplitter_rank = 0
	king_molten_rank = 0
	king_skill_layout_version = 2
	total_experience = 0
	coins = 0
	player_current_health = -1.0
	progression_state_changed.emit(total_experience, coins)
	player_health_state_changed.emit(player_current_health)


func create_snapshot() -> Dictionary:
	return {
		"version": SNAPSHOT_VERSION,
		"total_experience": total_experience,
		"coins": coins,
		"player_current_health": player_current_health,
		"king_skill_slots": king_skill_slots.duplicate(),
		"king_pursuit_rank": king_pursuit_rank,
		"king_vow_rank": king_vow_rank,
		"king_worldsplitter_rank": king_worldsplitter_rank,
		"king_earthsplitter_rank": king_earthsplitter_rank,
		"king_molten_rank": king_molten_rank,
		"king_skill_layout_version": king_skill_layout_version,
	}


func can_restore_snapshot(snapshot: Dictionary) -> bool:
	for field in ["king_earthsplitter_rank","king_molten_rank"]:
		var rank: Variant = snapshot.get(field,0)
		var maximum := 1 if field == "king_earthsplitter_rank" else 3
		if not (rank is int or rank is float) or not is_finite(float(rank)) or rank < 0 or rank > maximum or not is_equal_approx(float(rank),roundf(float(rank))): return false
	if not KingSkillCatalog.valid_slots(snapshot.get("king_skill_slots",[])):
		return false
	for key in ["king_vow_rank", "king_worldsplitter_rank", "king_skill_layout_version"]:
		var value: Variant = snapshot.get(key, 0)
		if not (value is int or value is float) or not is_finite(float(value)) or value < 0 or value > 2 or not is_equal_approx(float(value), roundf(float(value))):
			return false
	var pursuit_rank: Variant = snapshot.get("king_pursuit_rank", 0)
	if (
		not (pursuit_rank is int or pursuit_rank is float)
		or not is_finite(float(pursuit_rank))
		or pursuit_rank < 0
		or pursuit_rank > 2
		or not is_equal_approx(float(pursuit_rank), roundf(float(pursuit_rank)))
	):
		return false
	if snapshot.get("version", -1) != SNAPSHOT_VERSION:
		return false
	var experience_value: Variant = snapshot.get("total_experience")
	var coin_value: Variant = snapshot.get("coins")
	var health_value: Variant = snapshot.get("player_current_health")
	return (
		(experience_value is int or experience_value is float)
		and (coin_value is int or coin_value is float)
		and (health_value is int or health_value is float)
		and is_equal_approx(float(experience_value), roundf(float(experience_value)))
		and is_equal_approx(float(coin_value), roundf(float(coin_value)))
		and float(experience_value) >= 0.0
		and float(coin_value) >= 0.0
		and float(health_value) >= -1.0
		and is_finite(float(health_value))
	)


func restore_snapshot(snapshot: Dictionary) -> bool:
	if not can_restore_snapshot(snapshot):
		return false
	king_skill_slots = snapshot.get("king_skill_slots",[]).duplicate()
	king_pursuit_rank = int(snapshot.get("king_pursuit_rank", 0))
	king_vow_rank = int(snapshot.get("king_vow_rank", 0))
	king_worldsplitter_rank = int(snapshot.get("king_worldsplitter_rank", 0))
	king_earthsplitter_rank = int(snapshot.get("king_earthsplitter_rank", 0))
	king_molten_rank = int(snapshot.get("king_molten_rank", 0))
	king_skill_layout_version = int(snapshot.get("king_skill_layout_version", 0))
	total_experience = int(snapshot["total_experience"])
	coins = int(snapshot["coins"])
	var restored_health := float(snapshot["player_current_health"])
	player_current_health = restored_health
	progression_state_changed.emit(total_experience, coins)
	# Level-driven vitality observers may synchronize a recalculated current HP
	# while handling progression. The explicit saved health must win last.
	player_current_health = restored_health
	player_health_state_changed.emit(player_current_health)
	return true
