class_name MoltenCrashDefinition
extends RiftbreakDefinition

## Four bounded forms of the same local control skill, trained through Eira.
enum Form { FOUNDATION, ADVANCED, AWAKENED, MATURE }
@export var form: Form = Form.FOUNDATION
@export var aftershock_delay_seconds := 0.0
@export var aftershock_damage_share := 0.0
@export var aftershock_radius_pixels := 0.0
@export var damage_core_radius_pixels := 0.0

func _init() -> void:
	ability_id = &"riftbreak"
	display_name = "Molten Crash"
	hud_name = "MOLTEN"
	activation_mode = ActivationMode.SELF_AREA
	ground_center_offset_y = 0.0
	target_range_pixels = 0.0
	stun_core_radius_pixels = 0.0
	outer_damage_ratio = 1.0
	knockback_strength = 65.0
	stagger_seconds = .10
	stun_seconds = .55
	wind_up_seconds = .18
	active_seconds = .04
	recovery_seconds = .14
	cooldown_seconds = 8.0
	dash_cancelable = true
	impact_weight = ImpactWeight.HEAVY
	configure_form(Form.FOUNDATION)

func configure_form(value: Form) -> void:
	form = value
	effect_radius_pixels = [72.0,80.0,84.0,86.0][form]
	weapon_damage_multiplier = [2.0,2.3,2.4,2.7][form]
	# The later pulse redistributes the cast budget; it does not duplicate it.
	aftershock_damage_share = 0.2 if form >= Form.AWAKENED else 0.0
	aftershock_delay_seconds = .34 if form >= Form.AWAKENED else 0.0
	aftershock_radius_pixels = 86.0 if form >= Form.AWAKENED else 0.0
	stun_core_radius_pixels = 0.0
	damage_core_radius_pixels = 48.0 if form == Form.MATURE else 0.0
	outer_damage_ratio = .72 if form == Form.MATURE else 1.0
	display_name = ["Molten Crash","Molten Crash: Advanced","Furnace Break","Caldera"][form]
	hud_name = ["CRASH","MOLTEN","FURNACE","CALDERA"][form]
	hitbox_shape = CircleShape2D.new()
	hitbox_shape.radius = effect_radius_pixels
	description = [
		"A quick blue stone-and-light sword crash. 72px local impact and initial stun.",
		"Molten sword crash: 80px impact and stronger damage, with initial stun.",
		"The 84px crash leaves one delayed, damage-only heat pulse in 86px.",
		"A stronger 86px center, gentler rim and one damage-only heat pulse."
	][form] + " Control returns after 0.36s."
