class_name ExpeditionDefeatReturn
extends RefCounted

## Defeat ends the current expedition and returns to the safe hub without
## erasing the player's run progression. Unclaimed expedition loot still rolls
## back through LootService.

const SANCTUARY_SCENE := "res://levels/sanctuary/sanctuary.tscn"


static func request(context: Node) -> bool:
	if context == null or not context.is_inside_tree():
		return false
	var loot_service := context.get_node_or_null("/root/LootService")
	if loot_service != null:
		loot_service.abort_expedition_rewards()
	var transition := context.get_node_or_null("/root/SceneTransition")
	if transition == null:
		push_error("Expedition defeat return requires the SceneTransition autoload.")
		return false
	transition.call("transition_to", SANCTUARY_SCENE)
	return true
