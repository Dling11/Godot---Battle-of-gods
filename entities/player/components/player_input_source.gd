class_name PlayerInputSource
extends Node

## Translates local device input into player intent.
## Keeping this boundary separate lets another authority source replace it later.

func get_move_direction() -> Vector2:
	return Input.get_vector(
		"player_move_left",
		"player_move_right",
		"player_move_up",
		"player_move_down"
	)


func get_aim_direction() -> Vector2:
	return Input.get_vector(
		"player_aim_left",
		"player_aim_right",
		"player_aim_up",
		"player_aim_down"
	)

func resolve_mobility_direction(pointer_direction: Vector2, current_facing: Vector2) -> Vector2:
	var direction := get_move_direction()
	if direction.is_zero_approx():
		direction = get_aim_direction()
	if direction.is_zero_approx() and Input.get_connected_joypads().is_empty():
		direction = pointer_direction
	return current_facing if direction.is_zero_approx() else direction.normalized()


func resolve_cardinal_facing(move_direction: Vector2, current_facing: Vector2) -> Vector2:
	## Combat facing follows movement intent, never passive pointer position.
	## Exact diagonal ties retain the matching current axis to avoid flicker.
	if move_direction.is_zero_approx():
		return current_facing
	var horizontal := Vector2(signf(move_direction.x), 0.0)
	var vertical := Vector2(0.0, signf(move_direction.y))
	if absf(move_direction.x) > absf(move_direction.y):
		return horizontal
	if absf(move_direction.y) > absf(move_direction.x):
		return vertical
	if absf(current_facing.x) > 0.5 and signf(current_facing.x) == signf(move_direction.x):
		return horizontal
	if absf(current_facing.y) > 0.5 and signf(current_facing.y) == signf(move_direction.y):
		return vertical
	return horizontal if not is_zero_approx(move_direction.x) else vertical


func is_primary_attack_just_pressed() -> bool:
	return Input.is_action_just_pressed("player_attack_primary")


func is_evade_just_pressed() -> bool:
	return Input.is_action_just_pressed("player_dodge")


func is_ability_1_just_pressed() -> bool:
	return (
		Input.is_action_just_pressed("player_skill_1")
		or Input.is_action_just_pressed("player_ability_1")
	)


func is_ability_2_just_pressed() -> bool:
	return (
		Input.is_action_just_pressed("player_skill_2")
		or Input.is_action_just_pressed("player_ability_2")
	)


func is_ability_3_just_pressed() -> bool:
	return Input.is_action_just_pressed("player_skill_3")


func is_ability_4_just_pressed() -> bool:
	return Input.is_action_just_pressed("player_skill_4")
