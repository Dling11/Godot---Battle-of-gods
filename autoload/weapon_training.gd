extends Node

## Permanent family proofs, separate from King XP and item ownership.
signal training_changed
const AXE_LESSON := &"axe_cyclone"
const CYCLONE := &"axe_war_cyclone"
var _proofs: Array[String] = []

func reset_training() -> void:
	_proofs.clear()
	training_changed.emit()

func has_technique(technique_id: StringName) -> bool:
	return technique_id == CYCLONE and String(AXE_LESSON) in _proofs

func complete_axe_lesson(trial: Node) -> bool:
	var scene := get_tree().current_scene
	if not is_instance_valid(trial) or scene == null or scene.scene_file_path != "res://levels/sanctuary/sanctuary.tscn" or not scene.is_ancestor_of(trial):
		return false
	if trial.get_script().resource_path != "res://gameplay/training/axe_mastery_trial.gd" or not trial.has_completed_proof():
		return false
	# Lab/admin loans can never become a permanent profile reward.
	if get_node("/root/SaveService").is_autosave_suppressed_for_debug() or trial.actor.war_cyclone.enabled_for_review:
		return false
	if has_technique(CYCLONE): return true
	_proofs.append(String(AXE_LESSON))
	if not get_node("/root/SaveService").save_profile():
		_proofs.erase(String(AXE_LESSON))
		return false
	training_changed.emit()
	return true

func create_snapshot() -> Dictionary:
	return {"version":1,"proofs":_proofs.duplicate()}

func can_restore_snapshot(snapshot: Dictionary) -> bool:
	if snapshot.is_empty(): return true
	if snapshot.get("version") != 1 or not snapshot.get("proofs") is Array: return false
	var seen: Array[String] = []
	for proof: Variant in snapshot.proofs:
		if not proof is String or proof != String(AXE_LESSON) or proof in seen: return false
		seen.append(proof)
	return true

func restore_snapshot(snapshot: Dictionary) -> bool:
	if not can_restore_snapshot(snapshot): return false
	_proofs.clear()
	for proof: String in snapshot.get("proofs",[]): _proofs.append(proof)
	training_changed.emit()
	return true
