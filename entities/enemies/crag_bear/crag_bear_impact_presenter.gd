class_name CragBearImpactPresenter
extends Node2D

## Spawns the slam effect into a stable world layer at the authoritative hitbox
## origin. The effect therefore remains in place while the bear recovers/moves.

@export var impact_origin: Node2D
@export var impact_scene: PackedScene
@export_range(0.0, 6.0, 0.1) var camera_strength := 2.2


func play_state(state: int, _duration_seconds: float) -> void:
	if state != CragBear.State.SLAM_ACTIVE:
		return
	spawn_impact()


func spawn_impact() -> Node2D:
	if impact_origin == null or impact_scene == null:
		return null
	var effect := impact_scene.instantiate() as Node2D
	if effect == null:
		return null
	var parent := _find_effects_parent()
	parent.add_child(effect)
	effect.global_position = impact_origin.global_position
	_request_camera_pulse()
	return effect


func _find_effects_parent() -> Node2D:
	var current := get_tree().current_scene
	if current != null:
		var world_effects := current.get_node_or_null("World/Effects") as Node2D
		if world_effects != null:
			return world_effects
	var actor := get_parent() as Node2D
	if actor != null and actor.get_parent() is Node2D:
		return actor.get_parent() as Node2D
	return self


func _request_camera_pulse() -> void:
	if camera_strength <= 0.0 or DisplayServer.get_name() == "headless":
		return
	var current := get_tree().current_scene
	if current == null:
		return
	var feedback := current.find_child("CombatFeedback", true, false)
	if feedback != null and feedback.has_method("request_camera_pulse"):
		feedback.request_camera_pulse(camera_strength)
