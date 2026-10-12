class_name UnbrokenVowDefinition
extends AbilityDefinition

enum Rank { FOUNDATION, ADVANCED, MATURE }
@export var rank := Rank.FOUNDATION
var shield_ratio := .25
var duration_seconds := 6.0
var damage_bonus := .12
var movement_bonus := 0.0

func configure_rank(value: int) -> void:
	rank = clampi(value, 0, 2)
	shield_ratio = [.25, .30, .35][rank]
	duration_seconds = [6.0, 7.0, 8.0][rank]
	damage_bonus = [.12, .15, .18][rank]
	movement_bonus = 0.0 if rank == 0 else .08
	description = "Brace and release a protective seal. Shield absorbs %d%% maximum HP after armor for %ds; +%d%% outgoing damage while shielded. Break or expiry ends the bonuses. No invulnerability or stun.\n0.32s cast · 20s cooldown" % [roundi(shield_ratio*100), int(duration_seconds), roundi(damage_bonus*100)]
	if rank > 0:
		description += "\n+8% movement, sharing the existing 35% equipment speed cap."
	if rank == Rank.MATURE:
		description += "\nThird basic-combo cut gains +30% damage and a rising/downward pressure accent; no extra contact or stun."
