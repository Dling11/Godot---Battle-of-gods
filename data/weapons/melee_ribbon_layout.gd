extends Resource

## Cached whole-stroke transforms; fitted offline against real contact space.
@export var rows := 5
@export var right: Array[Transform2D] = []
@export var up: Array[Transform2D] = []
@export var down: Array[Transform2D] = []
@export var clearance_pixels := 5.0

func for_attack(direction: Vector2,row: int) -> Transform2D:
	if absf(direction.x)>absf(direction.y):
		return Transform2D(0,Vector2(-1,1),0,Vector2.ZERO)*right[row] if direction.x<0 else right[row]
	return up[row] if direction.y<0 else down[row]

func is_valid_layout() -> bool:
	if rows<1 or clearance_pixels<4: return false
	for view in [right,up,down]:
		if view.size()!=rows: return false
		for basis: Transform2D in view:
			if not basis.is_finite() or basis.determinant()<=0: return false
	return true
