extends Node

## Event-driven composition. Player components retain all gameplay authority.
const Readout = preload("res://ui/hud/progression_readout.gd")
const VeilStyle = preload("res://ui/hud/veil_theme.gd")
const TipButton = preload("res://ui/hud/hud_tooltip_button.gd")
const EffectStrip = preload("res://ui/hud/status_effect_strip.gd")
const EffectPresenter = preload("res://ui/hud/player_effect_presenter.gd")
var hud: CombatHUD
var frame: Panel
var health_trail: ProgressBar
var health_state: Label
var mastery_button: Button
var mastery_icon: TextureRect
var mastery_inlay: TextureRect
var effect_strip: Control
var _effects: Node
var xp_frame: Panel
var level_toast: PanelContainer
var _toast_text: Label
var _health_tween: Tween
var _toast_tween: Tween
var _last_health := -1.0
var _last_maximum := -1.0
var actor: Player

func configure(owner_hud: CombatHUD) -> void:
	hud = owner_hud
	frame = Panel.new()
	frame.name = "PortraitLinkFrame"
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_theme_stylebox_override("panel",StyleBoxEmpty.new())
	hud.add_child(frame)
	_place(frame,Rect2(12,10,244,89))
	var portrait := TextureRect.new()
	portrait.name = "KingPortrait"
	portrait.texture = VeilStyle.PORTRAIT
	portrait.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_child(portrait)
	_place(portrait,Rect2(0,0,64,64))
	var level_badge := Panel.new()
	level_badge.name = "LevelBadge"
	level_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	level_badge.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	level_badge.add_theme_stylebox_override("panel",VeilStyle.artwork(VeilStyle.LEVEL_BADGE))
	frame.add_child(level_badge)
	_place(level_badge,Rect2(8,49,48,22))
	hud.level_label.text = ""
	_mount(hud.level_label,level_badge,Rect2(18,0,20,22),14)
	hud.level_label.add_theme_font_override("font",VeilStyle.DISPLAY_FONT)
	var level_prefix := Label.new()
	level_prefix.text = "LV"
	level_prefix.mouse_filter = Control.MOUSE_FILTER_IGNORE
	level_prefix.add_theme_font_size_override("font_size",8)
	level_prefix.add_theme_font_override("font",VeilStyle.DISPLAY_FONT)
	level_prefix.add_theme_color_override("font_color",VeilStyle.CYAN)
	level_badge.add_child(level_prefix)
	_place(level_prefix,Rect2(8,6,10,13))
	var health_frame := Panel.new()
	health_frame.name = "VitalityFrame"
	health_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	health_frame.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	health_frame.add_theme_stylebox_override("panel",VeilStyle.artwork(VeilStyle.HEALTH_FRAME))
	frame.add_child(health_frame)
	_place(health_frame,Rect2(60,14,184,22))
	# The portrait rim sits over the rail's socket, rather than the rail
	# painting across the portrait. Keep the level plaque in front of both.
	frame.move_child(health_frame,0)
	_mount(hud.health_label,frame,Rect2(72,18,160,14),10)
	var coins := Panel.new()
	coins.name = "CoinPlaque"
	coins.mouse_filter = Control.MOUSE_FILTER_IGNORE
	coins.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	coins.add_theme_stylebox_override("panel",VeilStyle.artwork(VeilStyle.COIN_PLAQUE))
	frame.add_child(coins)
	_place(coins,Rect2(8,74,48,15))
	hud.coin_label.text = ""
	_mount(hud.coin_label,coins,Rect2(13,1,31,13),8)
	hud.coin_label.add_theme_font_override("font",VeilStyle.DISPLAY_FONT)
	hud.coin_label.add_theme_color_override("font_color",Color("f5dc80"))
	hud.coin_label.clip_text = true
	hud.coin_label.tooltip_text = "Gold · crafting and Sanctuary services"
	hud.get_node("ProgressPanel/Margin/Stack/Header/CoinIcon").hide()
	hud.health_label.add_theme_font_override("font",VeilStyle.DISPLAY_FONT)
	for label: Label in [hud.level_label,hud.experience_label,hud.health_label]:
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_color_override("font_outline_color",Color("080c16"))
		label.add_theme_constant_override("outline_size",1)
	hud.get_node("ProgressPanel").hide()
	hud.get_node("HealthPanel").hide()
	var track := Panel.new()
	track.name = "HealthTrack"
	track.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	track.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Match the frame's inner bevel. The old 14px rectangle covered its
	# lower lip; both live HP and the damage trail now share this inset mask.
	var aperture := StyleBoxFlat.new()
	aperture.bg_color = Color.WHITE
	aperture.set_corner_radius_all(3)
	aperture.corner_detail = 1
	track.add_theme_stylebox_override("panel",aperture)
	track.clip_children = CanvasItem.CLIP_CHILDREN_ONLY
	frame.add_child(track)
	_place(track,Rect2(72,19,160,12))
	health_trail = ProgressBar.new()
	health_trail.show_percentage = false
	health_trail.mouse_filter = Control.MOUSE_FILTER_IGNORE
	health_trail.add_theme_stylebox_override("background",VeilStyle.panel(Color("100c18"),Color("100c18"),0))
	health_trail.add_theme_stylebox_override("fill",VeilStyle.fill(Color("b5a0d8"),Color("71618d")))
	track.add_child(health_trail)
	health_trail.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_mount(hud.health_bar,track,Rect2(0,0,160,12))
	hud.health_bar.add_theme_stylebox_override("background",StyleBoxEmpty.new())
	hud.health_bar.add_theme_stylebox_override("fill",VeilStyle.health_fill())
	frame.move_child(hud.health_label,frame.get_child_count()-1)
	_configure_mastery()
	effect_strip = EffectStrip.new()
	effect_strip.name = "ActiveEffects"
	frame.add_child(effect_strip)
	_place(effect_strip,Rect2(74,74,170,0))
	effect_strip.layout_changed.connect(_layout_status)
	health_state = Label.new()
	health_state.name = "HealthState"
	health_state.mouse_filter = Control.MOUSE_FILTER_IGNORE
	health_state.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	health_state.add_theme_font_size_override("font_size",9)
	health_state.add_theme_color_override("font_color",Color("ff8a91"))
	hud.add_child(health_state)
	_place(health_state,Rect2(150,0,106,10))
	_configure_dock()
	_configure_menu_buttons()
	level_toast = PanelContainer.new()
	level_toast.name = "LevelUpNotice"
	level_toast.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var toast_style := VeilStyle.panel()
	toast_style.set_content_margin_all(8)
	level_toast.add_theme_stylebox_override("panel",toast_style)
	hud.add_child(level_toast)
	_place(level_toast,Rect2(12,202,254,44))
	_toast_text = Label.new()
	_toast_text.custom_minimum_size.x = 238
	_toast_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_toast_text.add_theme_font_size_override("font_size",10)
	level_toast.add_child(_toast_text)
	level_toast.hide()
	hud.resized.connect(layout_dock)
	_layout_status()

func _configure_mastery() -> void:
	mastery_button = TipButton.new()
	mastery_button.name = "WeaponMastery"
	frame.add_child(mastery_button)
	_style_button(mastery_button,8)
	mastery_button.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	mastery_button.configure_tooltip(_mastery_tip)
	var ribbon := VeilStyle.artwork(VeilStyle.MASTERY_FRAME)
	mastery_button.add_theme_stylebox_override("normal",ribbon)
	var highlighted := ribbon.duplicate() as StyleBoxTexture
	highlighted.modulate_color = Color("ddecff")
	mastery_button.add_theme_stylebox_override("hover",highlighted)
	mastery_button.add_theme_stylebox_override("pressed",highlighted)
	_place(mastery_button,Rect2(60,36,184,30))
	mastery_icon = TextureRect.new()
	mastery_icon.name = "FamilyIcon"
	mastery_icon.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	mastery_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mastery_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	mastery_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	mastery_button.add_child(mastery_icon)
	_place(mastery_icon,Rect2(11,2,18,15))
	var heading := Label.new()
	heading.name = "MasteryHeading"
	heading.text = "WEAPON MASTERY"
	heading.mouse_filter = Control.MOUSE_FILTER_IGNORE
	heading.add_theme_font_size_override("font_size",8)
	heading.add_theme_font_override("font",VeilStyle.DISPLAY_FONT)
	mastery_button.add_child(heading)
	_place(heading,Rect2(32,4,122,12))
	var seal := TextureRect.new()
	seal.name = "MasterySeal"
	seal.texture = VeilStyle.MASTERY_SEAL
	seal.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	seal.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	seal.mouse_filter = Control.MOUSE_FILTER_IGNORE
	seal.self_modulate = Color(1.8,1.7,2.2,1)
	mastery_button.add_child(seal)
	_place(seal,Rect2(159,3,13,13))
	# A dormant engraved inlay is presentation, not an unbound XP gauge.
	# Replace it with earned progress when family mastery has an authority.
	mastery_inlay = TextureRect.new()
	mastery_inlay.name = "MasteryDormantInlay"
	mastery_inlay.texture = VeilStyle.MASTERY_FILL
	mastery_inlay.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	mastery_inlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mastery_inlay.self_modulate = Color(.55,.55,.65,.5)
	mastery_button.add_child(mastery_inlay)
	_place(mastery_inlay,Rect2(12,18,160,7))
	var state := Label.new()
	state.name = "MasteryState"
	state.text = "SEALED"
	state.mouse_filter = Control.MOUSE_FILTER_IGNORE
	state.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	state.add_theme_font_size_override("font_size",7)
	state.add_theme_font_override("font",VeilStyle.DISPLAY_FONT)
	state.add_theme_color_override("font_color",Color("e3d9f5"))
	state.add_theme_color_override("font_outline_color",Color("080c16"))
	state.add_theme_constant_override("outline_size",1)
	mastery_button.add_child(state)
	_place(state,Rect2(12,16,160,11))

func _mastery_tip() -> Dictionary:
	var family := actor.attack_component.weapon.family_display_name if is_instance_valid(actor) else "Weapon"
	if family == "Axe":
		var learned: bool = get_node("/root/WeaponTraining").has_technique(&"axe_war_cyclone")
		return {"title":"Axe Mastery","icon":mastery_icon.texture,"compact":true,
			"subtitle":"First proof earned · War Cyclone" if learned else "First proof · Control the Circle",
			"body":"War Cyclone is learned. Equip any Axe and press F1.\n\nProofs belong to the weapon family and survive equipment changes." if learned else "Visit Veyr in the northern Weapon Court. Complete his practical Axe lesson to learn War Cyclone.\n\nLessons unlock techniques through demonstrated actions.","footer":""}
	return {"title":family+" Mastery","icon":mastery_icon.texture,"compact":true,"subtitle":"Sealed · weapon proficiency",
		"body":"Weapon lessons unlock unique family techniques.\n\nVeyr's first lesson teaches the Axe. Lessons for this family are not yet available.",
		"footer":""}

func _layout_status() -> void:
	frame.size.y = maxf(89,74+effect_strip.size.y) if effect_strip.visible else 89
	if is_instance_valid(level_toast): level_toast.position.y = maxf(160,frame.position.y+frame.size.y+14)

func _configure_dock() -> void:
	var tray := hud.get_node("ActionTray") as PanelContainer
	tray.add_theme_stylebox_override("panel",StyleBoxEmpty.new())
	var margin := tray.get_node("Margin") as MarginContainer
	for edge in ["left","right"]: margin.add_theme_constant_override("margin_"+edge,5)
	margin.add_theme_constant_override("margin_top",3)
	margin.add_theme_constant_override("margin_bottom",19)
	var actions := margin.get_node("Actions") as HBoxContainer
	actions.add_theme_constant_override("separation",5)
	hud.skill_bar.add_theme_constant_override("separation",3)
	actions.move_child(hud.skill_bar,0)
	for child_name in ["DashSkillGap","SkillAttackGap","AttackCap"]: actions.get_node(child_name).hide()
	hud.get_node("EclipseFrame").hide()
	hud.get_node("EclipseVeil").hide()
	_mount(hud.experience_bar,hud,Rect2(0,0,220,11))
	_mount(hud.experience_label,hud,Rect2(0,0,220,11),8)
	xp_frame = Panel.new()
	xp_frame.name = "ExperienceRail"
	xp_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	xp_frame.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	xp_frame.add_theme_stylebox_override("panel",StyleBoxEmpty.new())
	VeilStyle.framed_backdrop(xp_frame,VeilStyle.XP_FRAME,Vector4(24,4,24,4))
	hud.add_child(xp_frame)
	hud.move_child(xp_frame,hud.experience_bar.get_index())
	hud.experience_label.mouse_filter = Control.MOUSE_FILTER_STOP
	hud.experience_bar.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	hud.experience_bar.add_theme_stylebox_override("background",VeilStyle.panel(Color("090f19"),Color("657591"),0))
	hud.experience_bar.add_theme_stylebox_override("fill",VeilStyle.fill(Color("91d6ff"),Color("265caa")))
	hud.experience_label.add_theme_color_override("font_color",Color("e8f4ff"))
	layout_dock.call_deferred()

func layout_dock() -> void:
	if not is_instance_valid(hud): return
	var tray := hud.get_node("ActionTray") as Control
	var width := maxf(220,hud.get_node("ActionTray/Margin/Actions").get_combined_minimum_size().x+12)
	var left := roundf((hud.size.x-width)/2)
	_place(tray,Rect2(left,hud.size.y-64,width,62))
	_place(xp_frame,Rect2(left,hud.size.y-23,width,21))
	_place(hud.experience_bar,Rect2(left+22,hud.size.y-19,width-44,13))
	_place(hud.experience_label,Rect2(left+22,hud.size.y-19,width-44,13))
	_place(hud.character_menu_button,Rect2(hud.size.x-90,hud.size.y-48,36,46))
	_place(hud.options_button,Rect2(hud.size.x-48,hud.size.y-48,36,46))

func _configure_menu_buttons() -> void:
	for button: Button in [hud.character_menu_button,hud.options_button]:
		_style_button(button,9)
		button.text = ""
		button.icon = null
		button.custom_minimum_size = Vector2(36,46)
		button.add_theme_stylebox_override("normal",StyleBoxEmpty.new())
		button.set_script(TipButton)
	_button_face(hud.character_menu_button,VeilStyle.BAG_FACE,"TAB")
	_button_face(hud.options_button,VeilStyle.SETTINGS_FACE,"ESC")
	hud.character_menu_button.configure_tooltip(func() -> Dictionary: return {"title":"King's Bag · Tab","body":"Inspect equipment, compare weapons and arrange your loadout."})
	hud.options_button.configure_tooltip(func() -> Dictionary: return {"title":"Menu · Esc","body":"Pause, adjust settings or return to the title screen."})

func bind_player(player: Player) -> void:
	actor = player
	get_node("/root/WeaponTraining").training_changed.connect(func() -> void: _update_weapon(actor.attack_component.weapon))
	player.progression_component.leveled_up.connect(_show_level_up)
	player.weapon_definition_changed.connect(_update_weapon)
	_update_weapon(player.attack_component.weapon)
	_effects = EffectPresenter.new()
	add_child(_effects)
	_effects.bind_player(player,effect_strip)

func _update_weapon(definition: WeaponDefinition) -> void:
	mastery_icon.texture = VeilStyle.FAMILY_ICONS.get(definition.family_display_name)
	var learned: bool = definition.family_display_name == "Axe" and get_node("/root/WeaponTraining").has_technique(&"axe_war_cyclone")
	(mastery_button.get_node("MasteryState") as Label).text = "1 PROOF · F1 LEARNED" if learned else "SEALED"
	mastery_inlay.self_modulate = Color.WHITE if learned else Color(.55,.55,.65,.5)
	mastery_button.get_node("MasterySeal").visible = not learned
	mastery_button.refresh_open_card()

func set_health(current: float, maximum: float) -> void:
	var lost_health := _last_health >= 0 and current < _last_health and is_equal_approx(maximum,_last_maximum)
	if is_instance_valid(_health_tween): _health_tween.kill()
	health_trail.max_value = maximum
	if lost_health:
		health_trail.value = maxf(health_trail.value,_last_health)
		_health_tween = create_tween()
		_health_tween.tween_interval(.25)
		_health_tween.tween_property(health_trail,"value",current,.55)
	else: health_trail.value = current
	var critical := current > 0 and current/maxf(maximum,1) <= .25
	health_state.text = "CRITICAL" if critical else ("DEFEATED" if current <= 0 else "")
	hud.health_label.add_theme_color_override("font_color",Color("ffc4c0") if critical else Color("f8e9ef"))
	hud.health_bar.add_theme_stylebox_override("fill",VeilStyle.health_fill(critical))
	var delay: float = actor.vitality_component.definition.regeneration_delay_seconds if is_instance_valid(actor) else 5.0
	hud.health_label.tooltip_text = "Vitality · %d%% remaining. Regeneration starts after %s seconds without damage." % [roundi(100*current/maxf(maximum,1)),str(delay)]
	_last_health = current
	_last_maximum = maximum

func _show_level_up(level: int) -> void:
	if is_instance_valid(_toast_tween): _toast_tween.kill()
	_toast_text.text = "LEVEL UP · %d\n%s" % [level,Readout.training_at(level)]
	level_toast.modulate.a = 1
	level_toast.show()
	_toast_tween = create_tween()
	_toast_tween.tween_interval(3)
	_toast_tween.tween_property(level_toast,"modulate:a",0,.3)
	_toast_tween.tween_callback(level_toast.hide)

func _style_button(button: Button, font_size: int) -> void:
	button.add_theme_font_size_override("font_size",font_size)
	button.add_theme_stylebox_override("normal",VeilStyle.panel())
	button.add_theme_stylebox_override("hover",VeilStyle.panel(Color("24384e"),VeilStyle.CYAN))
	button.add_theme_stylebox_override("pressed",VeilStyle.panel(Color("304660"),VeilStyle.CYAN))
	button.add_theme_stylebox_override("focus",VeilStyle.panel(Color.TRANSPARENT,Color("baa6ee")))
	button.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	button.add_theme_color_override("font_color",Color("eef3ff"))

func _button_face(button: Button, texture: Texture2D, key: String) -> void:
	var face := TextureRect.new()
	face.name = "ActionFace"
	face.mouse_filter = Control.MOUSE_FILTER_IGNORE
	face.texture = texture
	face.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	face.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	button.add_child(face)
	_place(face,Rect2(0,0,36,36))
	var label := Label.new()
	label.name = "Keycap"
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.text = key
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size",8)
	label.add_theme_color_override("font_color",Color("f2f2fc"))
	label.add_theme_stylebox_override("normal",VeilStyle.panel(Color("080d17"),Color("8795ac"),2))
	button.add_child(label)
	_place(label,Rect2(4,34,28,12))

func _place(control: Control, rect: Rect2) -> void:
	control.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	control.position = rect.position
	control.size = rect.size

func _mount(control: Control, parent: Node, rect: Rect2, font_size := 0) -> void:
	var scene_owner := control.owner
	control.get_parent().remove_child(control)
	parent.add_child(control)
	control.owner = scene_owner
	control.custom_minimum_size = Vector2.ZERO
	if font_size > 0: control.add_theme_font_size_override("font_size",font_size)
	_place(control,rect)
