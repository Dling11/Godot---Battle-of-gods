class_name EnemyFootprintSystem
extends RefCounted

## Applies one authoritative underfoot radius to physical movement,
## navigation avoidance, and optional crowd separation. Hurtboxes and attack
## shapes are deliberately outside this contract.


static func configure(
	definition: EnemyDefinition,
	movement_collision: CollisionShape2D,
	navigation_agent: NavigationAgent2D,
	separation_component: EnemySeparationComponent = null
) -> bool:
	if definition == null or movement_collision == null or navigation_agent == null:
		push_error("EnemyFootprintSystem requires definition, movement collision, and navigation agent.")
		return false
	if not movement_collision.shape is CircleShape2D:
		push_error("Enemy movement footprints must use CircleShape2D.")
		return false

	# Scene subresources may be shared by multiple instances. Duplicate before
	# applying archetype data so one spawn cannot resize another spawn.
	var runtime_shape := movement_collision.shape.duplicate() as CircleShape2D
	runtime_shape.radius = definition.movement_footprint_radius
	movement_collision.shape = runtime_shape
	navigation_agent.radius = definition.movement_footprint_radius
	if separation_component != null:
		separation_component.configure_radius(definition.crowd_separation_radius)
	return true
