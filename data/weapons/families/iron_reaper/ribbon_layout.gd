extends Resource

## Offline-fitted whole ribbons. One stable transform per cut/view prevents
## frame breathing; the retained contact shader remains a safety boundary.
@export var right: Array[Transform2D] = []
@export var up: Array[Transform2D] = []
@export var down: Array[Transform2D] = []
@export var clearance_pixels := 6.0

func for_attack(direction: Vector2, row: int) -> Transform2D:
	if absf(direction.x)>absf(direction.y):
		var basis := right[row]
		if direction.x<0: basis = Transform2D(0,Vector2(-1,1),0,Vector2.ZERO)*basis
		return basis
	return up[row] if direction.y<0 else down[row]

func is_valid_layout() -> bool:
	if not is_finite(clearance_pixels) or clearance_pixels<4: return false
	for view: Array[Transform2D] in [right,up,down]:
		if view.size()!=3: return false
		for basis in view:
			if not basis.is_finite() or basis.determinant()<=0: return false
	return true
