class_name EarthsplitterDefinition
extends AbilityDefinition

## Foundation values; presentation reads these same distances and timings.
@export var range_pixels := 164.0
@export var lane_radius := 17.0
@export var contact_offset := 34.0
@export var travel_seconds := .25
@export var segment_spacing := 18.0
enum Form { FOUNDATION, FAN, CASCADE }
@export var form: Form = Form.FOUNDATION
@export var shares_lane_hits := false

func configure_form(value: Form) -> void:
	form = value
	shares_lane_hits = form == Form.FAN
	range_pixels = [164.0,228.0,228.0][form]
	lane_radius = [17.0,21.0,21.0][form]
	weapon_damage_multiplier = [1.65,2.40,2.25][form]
	display_name = ["Earthsplitter", "Earthsplitter: Fan", "Cascading Rupture"][form]
	hud_name = ["EARTHSPLIT","EARTHFAN","CASCADE"][form]
	hitbox_shape = CircleShape2D.new()
	hitbox_shape.radius = lane_radius
	description = ["One aimed rupture. One hit per enemy.","Three spreading lanes, then one stronger center wave. One hit per fan plus one finisher hit.","Three successive waves; the third reaches farther and hits hardest."][form] + " No stun; control returns after 0.36s."

func build_waves() -> Array[Dictionary]:
	if form == Form.FOUNDATION:
		return [{"tuning": duplicate(true), "delay": 0.0, "strength": 1.0, "aftermath_speed": 1.0}]
	var result: Array[Dictionary] = []
	if form == Form.FAN:
		for angle in [-20.0,20.0,0.0]:
			var lane: AbilityDefinition = duplicate(true)
			lane.range_pixels = 196.0
			lane.lane_radius = 19.0
			lane.weapon_damage_multiplier = weapon_damage_multiplier * (5.0/12.0)
			lane.knockback_strength = 12.0
			lane.stagger_seconds = .045
			result.append({"tuning": lane, "delay": 0.0, "angle": deg_to_rad(angle), "strength": 1.0, "aftermath_speed": 1.35, "share_hits": true})
		var finisher: AbilityDefinition = duplicate(true)
		finisher.weapon_damage_multiplier = weapon_damage_multiplier * (7.0/12.0)
		finisher.knockback_strength = 55.0
		finisher.travel_seconds = .23
		result.append({"tuning": finisher, "delay": .22, "angle": 0.0, "strength": 1.18, "aftermath_speed": 1.0, "accent": true})
		return result
	for index in 3:
		var wave: AbilityDefinition = duplicate(true)
		wave.range_pixels = [164.0,196.0,228.0][index]
		wave.lane_radius = [17.0,19.0,21.0][index]
		# Shares sum to one: overlapping waves never multiply the cast budget.
		wave.weapon_damage_multiplier = weapon_damage_multiplier * [.20,.25,.55][index]
		wave.knockback_strength = [12.0,18.0,55.0][index]
		wave.stagger_seconds = [.035,.045,.10][index]
		result.append({"tuning": wave, "delay": index*.16, "strength": [.85,1.0,1.12][index], "aftermath_speed": 1.35 if index<2 else 1.0})
	return result
