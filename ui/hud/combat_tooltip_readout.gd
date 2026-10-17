extends RefCounted

## Observes current definitions when a card opens; it never predicts final damage.
static func type_color(kind: int) -> Color:
	match kind:
		DamageInfo.DamageType.MAGIC: return Color("83c9f4")
		DamageInfo.DamageType.PURE: return Color("ded1ff")
	return Color("ece5d5")

static func damage_fact(amount: float,kind: int,label := "Damage") -> String:
	return "[b]%s[/b]  [color=#%s]%.1f %s[/color]" % [label,type_color(kind).to_html(false),amount,DamageInfo.type_name(kind).capitalize()]
static func skill(component: AbilityComponent, key: String) -> Dictionary:
	if not is_instance_valid(component): return {"title":"Unavailable","body":"This technique is not equipped."}
	var definition := component.definition
	var actor := component.owner as Player
	var weapon := actor.attack_component.weapon if actor != null else null
	var subtitle := definition.get_damage_type_label()+"  ·  "+key
	var details := definition.description
	var facts := PackedStringArray()
	if weapon != null and (definition.damage > 0 or definition.weapon_damage_multiplier > 0):
		var total := 0.0
		for index in definition.strike_count(): total += definition.resolve_strike_damage(weapon.damage,index)
		facts.append(damage_fact(total,definition.damage_type,"Total damage" if definition.strike_count()>1 else "Damage"))
		if definition.strike_count()>1:
			facts.append(damage_fact(total/maxf(definition.active_seconds,.01),definition.damage_type,"Damage / second"))
		facts.append("[color=#aab6c7]Before criticals, buffs and enemy defenses.[/color]")
	if definition.stun_seconds>0: facts.append("[b]Stun[/b]  [color=#a6e3f5]%.2f seconds[/color]" % definition.stun_seconds)
	var footer := "Cooldown %.1fs" % definition.cooldown_seconds
	if component is SovereignPursuitComponent:
		footer += " · Charges %d/%d" % [component.charges_available,component.get_max_charges()]
	if component.cooldown_remaining > 0: footer += " · Ready in %.1fs" % component.cooldown_remaining
	if definition.stun_seconds > 0: footer += "\nStun %.2fs (see area rules above)" % definition.stun_seconds
	return {"title":definition.display_name,"subtitle":subtitle,"subtitle_color":type_color(definition.damage_type),"facts":"\n".join(facts),"body":details,"footer":footer}

