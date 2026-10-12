extends RefCounted

## A voluntary safe return after an authoritative clear/claim. UI cannot bank
## rewards, unlock a stage, or skip the required milestone chest.
const SANCTUARY := "res://levels/sanctuary/sanctuary.tscn"

static func can_return(flow: Node) -> bool:
	if flow == null or not flow.is_inside_tree() or not "player" in flow:
		return false
	var player := flow.get("player") as Player
	if player == null or player.is_defeated:
		return false
	if "encounter_controller" in flow:
		var encounter := flow.get("encounter_controller") as EncounterController
		return encounter != null and encounter.get_progress().state == "complete"
	return "stage_completed" in flow and bool(flow.get("stage_completed"))

static func request(flow: Node) -> bool:
	if not can_return(flow):
		return false
	var loot := flow.get_node("/root/LootService")
	if loot.has_active_expedition():
		return false
	flow.get_node("/root/SceneTransition").call("transition_to", SANCTUARY)
	return true
