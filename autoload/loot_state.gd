extends Node

## Persisted mutable loot memory. MaterialInventory owns quantities; this
## authority owns one-time stage claims and bad-luck-protection counters.

signal first_clear_claimed(claim_id: StringName)
signal loot_state_reset

const SNAPSHOT_VERSION := 1
const MAX_MISS_COUNT := 999999

var _claimed_first_clear_ids: Dictionary = {}
var _bad_luck_misses: Dictionary = {}


func reset_state() -> void:
	_claimed_first_clear_ids.clear()
	_bad_luck_misses.clear()
	loot_state_reset.emit()


func has_first_clear_claim(claim_id: StringName) -> bool:
	return not claim_id.is_empty() and _claimed_first_clear_ids.has(claim_id)


func claim_first_clear(claim_id: StringName) -> bool:
	if claim_id.is_empty() or has_first_clear_claim(claim_id):
		return false
	_claimed_first_clear_ids[claim_id] = true
	first_clear_claimed.emit(claim_id)
	return true


func get_bad_luck_misses(protection_key: StringName) -> int:
	return int(_bad_luck_misses.get(protection_key, 0))


func record_bad_luck_result(protection_key: StringName, succeeded: bool) -> void:
	if protection_key.is_empty():
		return
	if succeeded:
		_bad_luck_misses.erase(protection_key)
		return
	_bad_luck_misses[protection_key] = mini(
		get_bad_luck_misses(protection_key) + 1,
		MAX_MISS_COUNT
	)


func create_snapshot() -> Dictionary:
	var claimed_ids := PackedStringArray()
	for raw_claim_id: Variant in _claimed_first_clear_ids:
		claimed_ids.append(String(raw_claim_id))
	claimed_ids.sort()

	var misses := {}
	var protection_keys := PackedStringArray()
	for raw_key: Variant in _bad_luck_misses:
		protection_keys.append(String(raw_key))
	protection_keys.sort()
	for raw_key: String in protection_keys:
		misses[raw_key] = get_bad_luck_misses(StringName(raw_key))

	return {
		"version": SNAPSHOT_VERSION,
		"claimed_first_clear_ids": claimed_ids,
		"bad_luck_misses": misses,
	}


func can_restore_snapshot(snapshot: Dictionary) -> bool:
	if snapshot.get("version", -1) != SNAPSHOT_VERSION:
		return false
	var raw_claims: Variant = snapshot.get("claimed_first_clear_ids")
	var raw_misses: Variant = snapshot.get("bad_luck_misses")
	if not (raw_claims is Array or raw_claims is PackedStringArray):
		return false
	if not raw_misses is Dictionary:
		return false

	var seen_claims := {}
	for raw_claim_id: Variant in raw_claims:
		if not (raw_claim_id is String or raw_claim_id is StringName):
			return false
		var claim_id := StringName(String(raw_claim_id))
		if claim_id.is_empty() or seen_claims.has(claim_id):
			return false
		seen_claims[claim_id] = true

	for raw_key: Variant in raw_misses:
		if not (raw_key is String or raw_key is StringName):
			return false
		var protection_key := StringName(String(raw_key))
		var raw_count: Variant = raw_misses[raw_key]
		if (
			protection_key.is_empty()
			or not _is_positive_integer(raw_count)
			or int(raw_count) > MAX_MISS_COUNT
		):
			return false
	return true


func restore_snapshot(snapshot: Dictionary) -> bool:
	if not can_restore_snapshot(snapshot):
		return false
	_claimed_first_clear_ids.clear()
	for raw_claim_id: Variant in snapshot["claimed_first_clear_ids"]:
		_claimed_first_clear_ids[StringName(String(raw_claim_id))] = true
	_bad_luck_misses.clear()
	var raw_misses: Dictionary = snapshot["bad_luck_misses"]
	for raw_key: Variant in raw_misses:
		_bad_luck_misses[StringName(String(raw_key))] = int(raw_misses[raw_key])
	loot_state_reset.emit()
	return true


func _is_positive_integer(value: Variant) -> bool:
	if value is int:
		return value > 0
	if value is float:
		return is_finite(value) and value > 0.0 and value == floor(value)
	return false
