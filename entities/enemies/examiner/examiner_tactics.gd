class_name ExaminerTactics
extends RefCounted

## Choose among legal actions; remember recent choices without reading inputs.
var history: Array[StringName] = []
var random := RandomNumberGenerator.new()


func _init() -> void:
	random.randomize()


func choose(actor: Examiner, distance: float) -> StringName:
	var choices: Dictionary = {}
	if distance <= actor.definition.attack_range:
		choices[&"combo"] = 4.0
	if actor._charge_cooldown <= 0 and distance >= 138:
		choices[&"charge"] = 3.0
	if actor._slam_cooldown <= 0 and distance <= 92 and actor._close_exchange_count >= 1:
		choices[&"slam"] = 2.0
	if actor._refutation_cooldown <= 0 and distance <= 112:
		choices[&"refutation"] = 1.0
	if actor._axiom_cooldown <= 0:
		choices[&"axiom"] = 2.0
	if actor._orb_cooldown <= 0:
		choices[&"sun"] = 1.6
	if actor.is_berserk() and actor._crownfall_cooldown <= 0:
		choices[&"crownfall"] = 1.6
	if actor.is_berserk() and actor._firmament_cooldown <= 0:
		choices[&"firmament"] = 1.6
	if choices.is_empty():
		return &""
	if history.size() > 0 and choices.size() > 1:
		choices.erase(history.back())
	var total := 0.0
	for key: StringName in choices:
		if history.has(key):
			choices[key] *= 0.4
		total += float(choices[key])
	var roll := random.randf() * total
	for key: StringName in choices:
		roll -= float(choices[key])
		if roll <= 0:
			record(key)
			return key
	return &""


func record(action: StringName) -> void:
	history.append(action)
	if history.size() > 4:
		history.pop_front()
