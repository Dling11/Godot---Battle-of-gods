class_name EnemyDefinition
extends Resource

## Shared immutable tuning for an enemy archetype.

## Crowd-control response is intentionally separate from health and damage so
## bosses can remain dangerous without duplicating enemy-controller scripts.
enum CrowdControlTier { LIGHT, ELITE, BOSS, HEAVY }

@export var enemy_id: StringName
@export var display_name: String = "Enemy"
## Presentation-only portrait for target cards, dialogue, and future bestiary UI.
@export var portrait: Texture2D
@export_range(1.0, 99999.0, 1.0) var maximum_health: float = 100.0
@export_range(0.0, 9999.0, 1.0) var armor_rating: float = 0.0
@export_range(0.0, 9999.0, 1.0) var magic_resistance_rating: float = 0.0
@export_range(1.0, 1000.0, 1.0, "suffix:px/s") var move_speed: float = 60.0
@export_range(1.0, 5000.0, 1.0, "suffix:px/s^2") var acceleration: float = 500.0
@export_group("Movement Footprint")
@export_range(2.0, 32.0, 0.5, "suffix:px") var movement_footprint_radius := 6.0
@export_range(8.0, 96.0, 1.0, "suffix:px") var crowd_separation_radius := 30.0
@export_group("")
@export_range(1.0, 200.0, 1.0, "suffix:px") var attack_range: float = 34.0
@export_range(0.0, 9999.0, 1.0) var attack_damage: float = 15.0
@export_range(0.01, 3.0, 0.01, "suffix:s") var wind_up_seconds: float = 0.45
@export_range(0.01, 2.0, 0.01, "suffix:s") var active_seconds: float = 0.12
@export_range(0.01, 3.0, 0.01, "suffix:s") var recovery_seconds: float = 0.55
@export_range(0.05, 3.0, 0.05, "suffix:s") var spawn_seconds: float = 0.7
@export_range(0, 9999, 1) var experience_reward := 1
@export_range(0, 9999, 1) var coin_reward := 0
@export var crowd_control_tier := CrowdControlTier.LIGHT
@export_group("Stagger Chain Resistance")
## Zero keeps the original freely interruptible behavior. Positive values
## break a rapid stagger chain on that hit and begin a temporary resistance
## window without suppressing damage or presentation feedback.
@export_range(0, 12, 1) var stagger_interrupt_limit := 0
@export_range(0.1, 3.0, 0.05, "suffix:s") var stagger_chain_window_seconds := 0.9
@export_range(0.0, 3.0, 0.05, "suffix:s") var stagger_resistance_seconds := 0.0
@export_group("")


func knockback_multiplier() -> float:
	match crowd_control_tier:
		CrowdControlTier.ELITE:
			return 0.35
		CrowdControlTier.HEAVY:
			return 0.2
		CrowdControlTier.BOSS:
			return 0.0
		_:
			return 1.0


func stagger_multiplier() -> float:
	match crowd_control_tier:
		CrowdControlTier.ELITE:
			return 0.45
		CrowdControlTier.HEAVY:
			return 0.3
		CrowdControlTier.BOSS:
			return 0.0
		_:
			return 1.0
