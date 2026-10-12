extends Resource

## A second independent blade. Axis landmarks do not stand for another fist.
@export var texture: Texture2D
@export var grip := Vector2.ZERO
@export var tip := Vector2(-1,-1)
@export var handle_axis := Vector2.DOWN
@export var hands := PackedVector2Array()
@export var axes := PackedVector2Array()
@export var behind_body := PackedByteArray()
@export var visible_poses := PackedByteArray()

func has_valid_layout(count: int, cell: Vector2i) -> bool:
	if texture==null or not grip.is_finite() or not tip.is_finite() or not handle_axis.is_finite() or handle_axis.is_zero_approx(): return false
	var bounds := Rect2(Vector2.ZERO,texture.get_size())
	if not bounds.has_point(grip) or not bounds.has_point(tip): return false
	if hands.size()!=count or axes.size()!=count or behind_body.size()!=count or visible_poses.size()!=count: return false
	var body_bounds := Rect2(Vector2.ZERO,Vector2(cell))
	for index in count:
		if not hands[index].is_finite() or not axes[index].is_finite() or not body_bounds.has_point(hands[index]) or not body_bounds.has_point(axes[index]) or hands[index].distance_to(axes[index])<1.0: return false
		if behind_body[index]>1 or visible_poses[index]>1: return false
	return true

func basis_for(index: int, cell: Vector2i) -> Transform2D:
	var angle := (axes[index]-hands[index]).angle()-handle_axis.angle()
	return Transform2D(angle,hands[index]-Vector2(cell)*0.5)
