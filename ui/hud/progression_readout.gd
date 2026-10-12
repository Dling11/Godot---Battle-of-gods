extends RefCounted

## Shared display copy reads progression authority; it never grants XP or unlocks.
const Training = preload("res://data/abilities/king/king_training_catalog.gd")

static func describe(progression: PlayerProgressionComponent) -> Dictionary:
	var level := progression.level
	var maximum := progression.definition.maximum_level
	var result := {"level":"LEVEL %d" % level,"hud_level":"LV. %d" % level,"maximum":1,"value":1,"text":"MAX LEVEL","hud_text":"MAX LEVEL","help":"All current levels reached. Visit Eira to finish eligible technique training."}
	if level >= maximum: return result
	if level >= progression.get_current_level_cap():
		var requirement := progression.definition.next_cap_requirement(progression.get_node_or_null("/root/StoryState"),progression.get_current_level_cap())
		result.text = "STAGE CAP · LEVEL %d" % level
		result.hud_text = "STAGE CAP"
		result.help = "Clear %s to unlock Level %d. XP pauses at this cap; gold and loot still count." % [requirement.get("name","the next expedition"),requirement.get("cap",maximum)]
		return result
	result.maximum = progression.experience_required_for_current_level()
	result.value = progression.experience_into_current_level()
	result.text = "%d / %d XP · %d to Lv.%d" % [result.value,result.maximum,result.maximum-result.value,level+1]
	result.hud_text = "XP %s / %s" % [format_number(result.value),format_number(result.maximum)]
	result.help = "Gain experience from expeditions. Each level increases vitality and skill mastery. "+next_training(level)
	return result

static func format_number(value: int) -> String:
	var digits := str(value)
	var groups: Array[String] = []
	while digits.length() > 3:
		groups.push_front(digits.right(3))
		digits = digits.left(digits.length()-3)
	groups.push_front(digits)
	return ",".join(groups)

static func next_training(level: int) -> String:
	var next_level := 100
	var names: Array[String] = []
	for course: Dictionary in Training.COURSES.values():
		for gate: int in course.levels:
			if gate <= level: continue
			if gate < next_level:
				next_level = gate
				names.clear()
			if gate == next_level: names.append(course.name)
	return "Next Eira training: Level %d · %s." % [next_level,", ".join(names)] if not names.is_empty() else "Visit Eira to finish eligible training."

static func training_at(level: int) -> String:
	var names: Array[String] = []
	for course: Dictionary in Training.COURSES.values():
		if level in course.levels: names.append(course.name)
	return ", ".join(names)+" training is ready at Eira." if not names.is_empty() else "Vitality and skill mastery increased."
