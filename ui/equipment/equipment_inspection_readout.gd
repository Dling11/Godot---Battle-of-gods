extends RefCounted

## Inspection formatting only. All numeric combat values come from definitions.
const DAMAGE := "ef9b96"
const POWER := "c4a5f5"
const PACE := "91d4ec"
const GOOD := "99d3ac"
const BAD := "ed9693"

static func stats(item: EquipmentDefinition) -> String:
	var weapon := item.weapon_definition
	if weapon == null:
		return "[color=#%s]%s[/color]" % [PACE,item.get_stat_summary()]
	var roll := WeaponCombatReadout.base_range(weapon)
	var critical := ""
	var contacts := "hits"
	if weapon.combo != null:
		for step in WeaponCombatReadout.steps(weapon):
			if weapon.combo.returning_attack(step) != null: contacts = "cuts"
	if weapon.critical_chance_ratio > 0:
		critical = "  ·  [color=#%s]%d%% crit ×%.2f[/color]" % [DAMAGE,roundi(weapon.critical_chance_ratio*100),weapon.critical_damage_multiplier]
	return "[color=#%s][b]%d–%d[/b] %s[/color]  ·  [color=#%s]%d skill power[/color]\n[color=#%s]%d %s / %.2fs[/color]  ·  [color=#%s][b]%.1f[/b] base DPS[/color]%s" % [
		DAMAGE,roll.x,roll.y,DamageInfo.type_name(weapon.damage_type).capitalize(),POWER,roundi(weapon.damage),
		PACE,WeaponCombatReadout.steps(weapon),contacts,WeaponCombatReadout.duration(weapon),DAMAGE,WeaponCombatReadout.base_dps(weapon),critical]

static func comparison(item: EquipmentDefinition, reference: EquipmentDefinition) -> String:
	if item == reference: return "[color=#%s]Currently equipped[/color]" % PACE
	if reference == null: return "[color=#%s]Empty equipment slot[/color]" % GOOD
	var rows := PackedStringArray()
	if item.weapon_definition != null and reference.weapon_definition != null:
		var weapon := item.weapon_definition
		var current := reference.weapon_definition
		_delta(rows,WeaponCombatReadout.base_dps(weapon)-WeaponCombatReadout.base_dps(current),"base DPS",1)
		_delta(rows,weapon.damage-current.damage,"skill power")
		_delta(rows,(weapon.critical_chance_ratio-current.critical_chance_ratio)*100,"crit %")
	else:
		for pair in [["flat_health_bonus","health"],["armor_bonus","armor"],["magic_resistance_bonus","magic resist"],["regeneration_bonus","regen/s"]]:
			_delta(rows,float(item.get(pair[0]))-float(reference.get(pair[0])),pair[1],1 if pair[0] == "regeneration_bonus" else 0)
		for pair in [["attack_speed_bonus_ratio","attack speed %"],["movement_speed_bonus_ratio","move speed %"],["ward_reduction_ratio","ward %"]]:
			_delta(rows,(float(item.get(pair[0]))-float(reference.get(pair[0])))*100,pair[1])
	return "Vs equipped: "+"  ·  ".join(rows) if not rows.is_empty() else "Same base stats · different handling"

static func mechanics(item: EquipmentDefinition) -> String:
	var weapon := item.weapon_definition
	if weapon == null: return item.synergy_description
	var lines := PackedStringArray()
	var combo := weapon.combo
	for step in WeaponCombatReadout.steps(weapon):
		var hit := WeaponCombatReadout.step_range(weapon,step)
		var seconds := combo.windups[step]+combo.contacts[step]+combo.recoveries[step] if combo != null else WeaponCombatReadout.duration(weapon)
		lines.append("[color=#%s]Cut %d[/color]    [color=#%s]%.1f–%.1f[/color] damage    %.2fs" % [PACE,step+1,DAMAGE,hit.x,hit.y,seconds])
		if combo == null: continue
		var flight := combo.returning_attack(step)
		if flight != null:
			lines.append("Throws outward, lingers %.2fs, then returns. [color=#%s]%d%% outward + %d%% return[/color]; each target is hit once per leg. Terrain stops the outward flight." % [combo.contacts[step]*flight.linger_fraction,DAMAGE,roundi(flight.outward_damage_share*100),roundi((1-flight.outward_damage_share)*100)])
		var rule := combo.contact_rule(step)
		if rule != null:
			if rule.light_pull_distance > 0: lines.append("Pulls Light enemies inward; heavier enemies resist.")
			if rule.wounded_health_ratio > 0 and rule.wounded_damage_multiplier > 1:
				lines.append("[color=#%s]+%d%% damage[/color] to enemies below %d%% health." % [DAMAGE,roundi((rule.wounded_damage_multiplier-1)*100),roundi(rule.wounded_health_ratio*100)])
		if combo.hitbox_shape(step,weapon.melee_hitbox_shape) is CircleShape2D:
			lines.append("Hits around King.")
	lines.append("\n[color=#%s]Attack speed quickens the chain.[/color] Hold LMB to continue; Space queues dodge." % PACE)
	lines.append("\nBase damage per hit/cut, before criticals, buffs, conditional bonuses and defenses. Returning-cut totals require both legs to connect. Skill power feeds King's abilities separately.")
	return "\n".join(lines)

static func _delta(rows: PackedStringArray, value: float, label: String, decimals := 0) -> void:
	if is_zero_approx(value): return
	var amount := "%+.1f" % value if decimals == 1 else "%+d" % roundi(value)
	rows.append("[color=#%s]%s %s[/color]" % [GOOD if value > 0 else BAD,amount,label])
