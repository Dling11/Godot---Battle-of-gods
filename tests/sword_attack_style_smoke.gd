extends SceneTree

const PlayerScene = preload("res://entities/player/player.tscn")
const KingSword = preload("res://data/weapons/king_signature_sword.tres")
const KingSwordForm = preload("res://data/weapons/attack_styles/king_sword_form.tres")
const BalancedSlash = preload("res://data/weapons/attack_styles/balanced_slash.tres")
const SwiftSlash = preload("res://data/weapons/attack_styles/swift_slash.tres")
const HeavyCleave = preload("res://data/weapons/attack_styles/heavy_cleave.tres")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var styles: Array[SwordAttackStyleDefinition] = [KingSwordForm, BalancedSlash, SwiftSlash, HeavyCleave]
	var style_ids: Dictionary = {}
	for style in styles:
		if not style.is_valid_style():
			_fail("Sword style %s is invalid." % style.resource_path)
			return
		style_ids[style.style_id] = true
	if style_ids.size() != styles.size():
		_fail("Sword attack style IDs must be unique.")
		return
	if KingSword.attack_style != KingSwordForm:
		_fail("King's signature sword is not using its dedicated sword form.")
		return

	var player := PlayerScene.instantiate() as Player
	root.add_child(player)
	player.set_physics_process(false)
	var body: AnimatedSprite2D = player.get_node("VisualRoot/Body")
	var shared_body_frames := body.sprite_frames
	if (
		player.weapon_visual.position != Vector2(-6.0, -10.0)
		or not is_equal_approx(player.weapon_visual.rotation, -0.45)
	):
		_fail("The down-facing sword does not connect at the body and point away from the player's head.")
		return
	if (
		not is_equal_approx(KingSword.get_melee_forward_reach_pixels(), 36.0)
		or not is_equal_approx(KingSword.get_melee_half_width_pixels(), 22.0)
		or player.attack_component.collision_shape.shape != KingSword.melee_hitbox_shape
	):
		_fail("King's sword form is missing its tightened 36-reach by 44-wide contact fan.")
		return
	if KingSwordForm.normal_variant_count() != 3:
		_fail("King's sword form must expose the approved three-swing visual sequence.")
		return
	var opening_rotations := player.weapon_visual._attack_rotations(
		&"right",
		KingSwordForm.normal_variant_wind_up_arc(0),
		KingSwordForm.normal_variant_strike_arc(0),
		KingSwordForm.normal_variant_direction(0)
	)
	var return_rotations := player.weapon_visual._attack_rotations(
		&"right",
		KingSwordForm.normal_variant_wind_up_arc(1),
		KingSwordForm.normal_variant_strike_arc(1),
		KingSwordForm.normal_variant_direction(1)
	)
	if (
		opening_rotations.x >= opening_rotations.y
		or return_rotations.x <= return_rotations.y
		or KingSwordForm.normal_variant_active_extension(2)
		<= KingSwordForm.normal_variant_active_extension(0)
	):
		_fail("The three-swing sequence lacks an opening, reverse return, or extended finish.")
		return
	var observed_variants: Array[int] = []
	for attack_index in 3:
		player.request_primary_attack()
		observed_variants.append(player.attack_component.combo_step)
		while player.attack_component.phase != MeleeAttackComponent.Phase.IDLE:
			await physics_frame
			if player.weapon_visual.swing_trail.visible:
				_fail("Legacy Line2D trail duplicates the generated greatsword contact.")
				return
	if observed_variants != [0,1,2]:
		_fail("The authoritative three-cut chain is out of order.")
		return

	var upgraded_weapon := KingSword.duplicate(true) as WeaponDefinition
	upgraded_weapon.weapon_id = &"test_upgraded_blade"
	upgraded_weapon.display_name = "Test Upgraded Blade"
	upgraded_weapon.damage = 40.0
	upgraded_weapon.world_visual_scale = 1.2
	upgraded_weapon.attack_style = KingSwordForm
	if not player.set_weapon_definition(upgraded_weapon):
		_fail("An idle higher-grade sword could not reuse the modular weapon rig.")
		return
	if (
		player.attack_component.weapon != upgraded_weapon
		or player.weapon_visual.weapon != upgraded_weapon
		or body.sprite_frames != shared_body_frames
	):
		_fail("Weapon swapping did not preserve one shared body animation and synchronized data.")
		return
	if not is_equal_approx(player.weapon_visual.weapon_sprite.scale.x, 1.2):
		_fail("Weapon-specific world scale was not applied during the swap.")
		return

	var swift_weapon := KingSword.duplicate(true) as WeaponDefinition
	swift_weapon.weapon_id = &"test_swift_blade"
	swift_weapon.attack_style = SwiftSlash
	var heavy_weapon := KingSword.duplicate(true) as WeaponDefinition
	heavy_weapon.weapon_id = &"test_heavy_blade"
	heavy_weapon.attack_style = HeavyCleave
	var heavy_shape := RectangleShape2D.new()
	heavy_shape.size = Vector2(148.0, 88.0)
	heavy_weapon.melee_hitbox_shape = heavy_shape
	if not player.set_weapon_definition(swift_weapon):
		_fail("Swift Slash could not be selected through weapon data.")
		return
	var swift_anchor: Vector2 = player.weapon_visual._attack_anchor(
		&"right", MeleeAttackComponent.Phase.ACTIVE, false
	)
	if not player.set_weapon_definition(heavy_weapon):
		_fail("Heavy Cleave could not be selected through weapon data.")
		return
	var heavy_anchor: Vector2 = player.weapon_visual._attack_anchor(
		&"right", MeleeAttackComponent.Phase.ACTIVE, false
	)
	if heavy_anchor.x <= swift_anchor.x:
		_fail("Heavy Cleave does not visibly extend farther than Swift Slash.")
		return
	if (
		body.sprite_frames != shared_body_frames
		or player.attack_component.collision_shape.shape != heavy_shape
		or not is_equal_approx(heavy_weapon.get_melee_forward_reach_pixels(), 74.0)
		or not is_equal_approx(player.weapon_visual.swing_trail.width, HeavyCleave.trail_width)
		or player.weapon_visual.swing_trail.default_color != HeavyCleave.trail_color
	):
		_fail("Weapon-owned family shape/style swapping did not update combat and presentation together.")
		return

	if not player.request_primary_attack():
		_fail("Could not begin the attack needed to verify swap locking.")
		return
	if player.set_weapon_definition(swift_weapon):
		_fail("Weapon swapping must be rejected while an attack is active.")
		return
	player.attack_component.cancel_attack()
	print("Sword attack style smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
