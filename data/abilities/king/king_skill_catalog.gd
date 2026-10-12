class_name KingSkillCatalog
extends RefCounted

const IDS := ["echoing_sever", "riftbreak", "sovereign_pursuit", "unbroken_vow", "king_skill_4"]
const RETIRED_SLOT_IDS := {
	"crosscut_advance": "echoing_sever",
	"griefwake": "riftbreak",
	"starfall_step": "sovereign_pursuit",
	"oathstorm": "king_skill_4",
}

static func valid_slots(value: Variant) -> bool:
	if not value is Array or value.size() not in [0, 4, 5, SkillLoadoutDefinition.SLOT_COUNT]:
		return false
	var used := {}
	for id: Variant in value:
		if id is String and id.is_empty():
			continue
		if not id is String or (id not in IDS and not RETIRED_SLOT_IDS.has(id)) or used.has(id):
			return false
		used[id]=true
	return true

static func expanded_slots(value: Array) -> Array:
	var result: Array = []
	var used := {}
	for raw_id in value:
		var id: String = RETIRED_SLOT_IDS.get(raw_id, raw_id)
		result.append(id if id in IDS and not used.has(id) else "")
		used[id] = true
	while result.size() < SkillLoadoutDefinition.SLOT_COUNT:
		result.append("")
	return result

static func migrate_legacy_slots(value: Array) -> Array:
	if value.is_empty():
		return expanded_slots(IDS)
	var result := expanded_slots(value)
	# Reserve 4 for Vow; move the old default Worldsplitter to 5. Preserve custom
	# placements and move displaced techniques into empty slots without losing any.
	if "unbroken_vow" in result:
		return result
	var displaced: String = result[3]
	result[3] = "unbroken_vow"
	if displaced == "king_skill_4":
		displaced = result[4]
		result[4] = "king_skill_4"
	if not displaced.is_empty() and displaced not in result:
		var empty := result.find("")
		if empty >= 0: result[empty] = displaced
	return result
