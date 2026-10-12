class_name EnemyRewardComponent
extends Node

## Observes an enemy's authoritative death and grants data-defined session rewards.

const MaterialPickupScene = preload("res://gameplay/loot/material_pickup.tscn")

@export var health_component: HealthComponent
@export var drop_profile: DropProfileDefinition

var _granted := false


func _ready() -> void:
	if health_component == null:
		push_error("EnemyRewardComponent requires a HealthComponent.")
		return
	health_component.died.connect(_grant_rewards)


func _grant_rewards() -> void:
	if _granted:
		return
	_granted = true
	var enemy := get_parent()
	if enemy == null or not "definition" in enemy or not "target" in enemy:
		return
	var definition := enemy.get("definition") as EnemyDefinition
	var recipient := enemy.get("target") as Player
	if definition == null or recipient == null or recipient.progression_component == null:
		return
	var enemy_memory := get_node_or_null("/root/EnemyMemory")
	if enemy_memory != null:
		enemy_memory.record_defeat(definition.enemy_id)
	recipient.progression_component.grant_rewards(definition.experience_reward, definition.coin_reward)
	_spawn_material_drops(enemy, recipient)


func _spawn_material_drops(enemy: Node2D, recipient: Player) -> void:
	if drop_profile == null or not drop_profile.has_valid_layout():
		return
	var pickup_parent := enemy.get_parent() as Node2D
	if pickup_parent == null:
		return
	var loot_service := get_node_or_null("/root/LootService")
	if loot_service == null:
		return
	var resolved: Array[Dictionary] = loot_service.resolve_enemy_drops(drop_profile)
	for index in resolved.size():
		var stack: Dictionary = resolved[index]
		var material := stack.get("material") as MaterialDefinition
		var quantity := int(stack.get("quantity", 0))
		if material == null or quantity <= 0:
			continue
		var pickup := MaterialPickupScene.instantiate() as MaterialPickup
		pickup.configure(material, quantity, recipient)
		pickup_parent.add_child(pickup)
		pickup.global_position = enemy.global_position
		var angle := -PI * 0.5
		if resolved.size() > 1:
			angle += (
				(float(index) / float(resolved.size() - 1) - 0.5)
				* PI * 0.75
			)
		pickup.begin_pop(Vector2.RIGHT.rotated(angle))
