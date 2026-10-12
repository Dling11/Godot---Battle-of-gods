extends HurtboxComponent

## Applies the hog's temporary frontal brace reduction before HealthComponent
## accepts damage. Health remains the sole authority for damage/death signals.


func receive_hit(info: DamageInfo) -> bool:
	var hog := get_parent() as ArmoredHog
	if hog == null or hog.definition == null:
		return super.receive_hit(info)
	if hog.state not in [ArmoredHog.State.BRACE, ArmoredHog.State.CHARGE]:
		return super.receive_hit(info)
	var source_2d := info.source as Node2D
	if source_2d == null:
		return super.receive_hit(info)
	var from_source := (source_2d.global_position - hog.global_position).normalized()
	var guard_cosine := cos(deg_to_rad(hog.definition.front_guard_half_angle_degrees))
	if hog.facing_direction.dot(from_source) < guard_cosine:
		return super.receive_hit(info)
	# Preserve critical/type metadata and let accepted feedback see the same
	# mitigated payload as health. Brace still blocks explicit hard stun.
	info.amount *= hog.definition.braced_front_damage_multiplier
	info.knockback_strength *= .2
	info.stagger_seconds *= .2
	info.stun_seconds = 0.0
	return super.receive_hit(info)

