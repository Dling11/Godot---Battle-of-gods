class_name WeaponCombatReadout
extends RefCounted

## Shared immutable readout, never live damage authority. Excludes defenses, crits,
## buffs, hitstop, missed contacts and equipment attack-speed bonuses.
static func base_range(weapon: WeaponDefinition) -> Vector2:
	if weapon.basic_damage_minimum > 0.0 and weapon.basic_damage_maximum >= weapon.basic_damage_minimum:
		return Vector2(roundi(weapon.basic_damage_minimum), roundi(weapon.basic_damage_maximum))
	return Vector2.ONE * weapon.damage


static func steps(weapon: WeaponDefinition) -> int:
	return weapon.combo.step_count() if weapon.combo != null and weapon.combo.step_count() > 0 else 1


static func duration(weapon: WeaponDefinition) -> float:
	if weapon.combo == null or weapon.combo.step_count() == 0:
		return weapon.wind_up_seconds + weapon.active_seconds + weapon.recovery_seconds
	var seconds := 0.0
	for step in weapon.combo.step_count():
		seconds += weapon.combo.windups[step] + weapon.combo.contacts[step] + weapon.combo.recoveries[step]
	return seconds


static func step_range(weapon: WeaponDefinition, step: int) -> Vector2:
	var multiplier := weapon.combo.damage_multipliers[step] if weapon.combo != null and weapon.combo.step_count() > 0 else 1.0
	return base_range(weapon) * multiplier


static func chain_range(weapon: WeaponDefinition) -> Vector2:
	var damage := Vector2.ZERO
	for step in steps(weapon):
		damage += step_range(weapon, step)
	return damage


static func base_dps(weapon: WeaponDefinition) -> float:
	var damage := chain_range(weapon)
	return (damage.x + damage.y) * 0.5 / maxf(duration(weapon), 0.0001)


static func summary(weapon: WeaponDefinition) -> String:
	var damage := base_range(weapon)
	var has_return := false
	if weapon.combo != null:
		for step in steps(weapon): has_return = has_return or weapon.combo.returning_attack(step) != null
	return "BASE ROLL %d–%d  •  %s\n%d %s / %.2fs  •  %.1f BASE DPS\nSKILL POWER %d" % [
		damage.x, damage.y, DamageInfo.type_name(weapon.damage_type),
		steps(weapon), "CUTS" if has_return else "HITS", duration(weapon), base_dps(weapon), weapon.damage,
	]


static func combo_description(weapon: WeaponDefinition) -> String:
	var ranges := PackedStringArray()
	var released := PackedStringArray()
	for step in steps(weapon):
		var damage := step_range(weapon, step)
		ranges.append("%.1f–%.1f" % [damage.x, damage.y])
		if weapon.combo != null and weapon.combo.returning_attack(step) != null:
			released.append("Cut %d total includes outward and return hits; both must connect." % (step+1))
	var description := "Damage per hit: %s.\nBase DPS: full combo before buffs or defenses." % " / ".join(ranges)
	if not released.is_empty(): description = description.replace("Damage per hit:","Damage per cut:") + "\n" + "\n".join(released)
	return description
