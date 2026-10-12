class_name StagePortal
extends Area2D

signal player_entered
signal proximity_changed(is_near: bool, prompt_text: String, prompt_icon: Texture2D)

enum PortalTier {
	NORMAL,
	MINI_BOSS,
	BOSS,
	GOD,
	TRANSCENDENT,
}

const TIER_PRESENTATION := {
	PortalTier.NORMAL: {
		"color": Color(0.38, 0.68, 1.0),
		"fx_color": Color(0.52, 0.78, 1.0),
		"guide_color": Color(0.46, 0.74, 1.0),
		"scale": 0.64, "fx_reach": 0.0,
		"base_speed": 0.78, "fx_speed": 0.0, "fx_alpha": 0.0,
	},
	PortalTier.MINI_BOSS: {
		"color": Color(0.62, 0.34, 1.0),
		"fx_color": Color(0.76, 0.55, 1.0),
		"guide_color": Color(0.72, 0.5, 1.0),
		"scale": 0.70, "fx_reach": 0.82,
		"base_speed": 0.92, "fx_speed": 1.08, "fx_alpha": 0.28,
	},
	PortalTier.BOSS: {
		"color": Color(1.0, 0.18, 0.26),
		"fx_color": Color(1.0, 0.42, 0.32),
		"guide_color": Color(1.0, 0.32, 0.32),
		"scale": 0.78, "fx_reach": 1.18,
		"base_speed": 1.06, "fx_speed": 1.42, "fx_alpha": 0.62,
	},
	PortalTier.GOD: {
		"color": Color(0.94, 0.98, 1.0),
		"fx_color": Color(1.0, 0.94, 0.62),
		"guide_color": Color(1.0, 0.94, 0.62),
		"scale": 0.88, "fx_reach": 1.90,
		"base_speed": 1.24, "fx_speed": 1.86, "fx_alpha": 0.94,
	},
	PortalTier.TRANSCENDENT: {
		"color": Color(0.08, 0.035, 0.12),
		"fx_color": Color(0.38, 0.12, 0.62),
		"guide_color": Color(0.68, 0.42, 1.0),
		"scale": 0.96, "fx_reach": 2.85,
		"base_speed": 1.42, "fx_speed": 2.18, "fx_alpha": 1.0,
	},
}

@export_file("*.tscn") var target_scene_path := ""
@export var portal_tier: PortalTier = PortalTier.NORMAL
@export_enum("Grasp", "Maw") var boss_variant := 0
@export var portal_visual: AnimatedSprite2D
@export var portal_fx: AnimatedSprite2D
@export var guidance_arrow: Label
@export var offscreen_guide: Label
@export var travel_sound: AudioStreamPlayer
@export var interaction_text := "PRESS F TO ENTER PORTAL"
@export var interaction_icon: Texture2D

var _player_inside := false
var _nearby_player: Player
var _travel_started := false
var _fx_color := Color.WHITE
var _fx_alpha := 0.0
var _portal_scale := Vector2.ONE
var _base_pulse: Tween
var _fx_pulse: Tween


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_apply_tier_presentation()
	if guidance_arrow != null:
		var arrow_origin: Vector2 = guidance_arrow.position
		var guide := create_tween().set_loops()
		guide.tween_property(guidance_arrow, "position", arrow_origin + Vector2(0.0, 5.0), 0.42).set_trans(Tween.TRANS_SINE)
		guide.tween_property(guidance_arrow, "position", arrow_origin, 0.42).set_trans(Tween.TRANS_SINE)


func _process(_delta: float) -> void:
	_update_offscreen_guide()


func _apply_tier_presentation() -> void:
	var presentation: Dictionary = TIER_PRESENTATION.get(portal_tier, TIER_PRESENTATION[PortalTier.NORMAL])
	_fx_color = presentation["fx_color"] as Color
	var scale_factor: float = presentation["scale"]
	var fx_reach: float = presentation["fx_reach"]
	var base_speed: float = presentation["base_speed"]
	var fx_speed: float = presentation["fx_speed"]
	_fx_alpha = presentation["fx_alpha"]
	_portal_scale = Vector2.ONE * scale_factor
	if portal_visual != null:
		portal_visual.sprite_frames = StagePortalArt.frames_for(portal_tier, boss_variant)
		portal_visual.material = StagePortalArt.surface_for(portal_tier, boss_variant)
		portal_visual.play(&"active")
		portal_visual.position.y = -71.0 * scale_factor
		portal_visual.speed_scale = base_speed
		portal_visual.scale = _portal_scale * 0.18
		portal_visual.modulate = Color(1, 1, 1, 0)
		var appearance := create_tween().set_parallel(true)
		appearance.tween_property(portal_visual, "scale", _portal_scale, 0.48).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		appearance.tween_property(portal_visual, "modulate", Color.WHITE, 0.3)
		if portal_fx != null:
			portal_fx.visible = _fx_alpha > 0.0
			portal_fx.speed_scale = fx_speed
			var fx_scale := _portal_scale * fx_reach
			portal_fx.scale = fx_scale * 0.1
			portal_fx.modulate = Color(_fx_color, 0.0)
			if portal_fx.visible:
				appearance.tween_property(portal_fx, "scale", fx_scale, 0.56).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
				appearance.tween_property(
					portal_fx,
					"modulate",
					Color(_fx_color, _fx_alpha),
					0.38
				)
		appearance.chain().tween_callback(_start_energy_pulse)
	var guide_color: Color = presentation["guide_color"] as Color
	if guidance_arrow != null:
		guidance_arrow.position.y = -132.0 * scale_factor - 30.0
		guidance_arrow.add_theme_color_override("font_color", guide_color)
	if offscreen_guide != null:
		offscreen_guide.add_theme_color_override("font_color", guide_color)
		offscreen_guide.pivot_offset = offscreen_guide.size * 0.5


func _start_energy_pulse() -> void:
	if portal_visual == null or not is_instance_valid(portal_visual):
		return
	if _base_pulse != null and _base_pulse.is_valid():
		_base_pulse.kill()
	if _fx_pulse != null and _fx_pulse.is_valid():
		_fx_pulse.kill()
	_base_pulse = create_tween().set_loops()
	_base_pulse.tween_property(portal_visual, "modulate", Color(0.92, 0.92, 0.92), 0.62).set_trans(Tween.TRANS_SINE)
	_base_pulse.tween_property(portal_visual, "modulate", Color.WHITE, 0.78).set_trans(Tween.TRANS_SINE)
	if portal_fx != null and is_instance_valid(portal_fx) and _fx_alpha > 0.0:
		_fx_pulse = create_tween().set_loops()
		_fx_pulse.tween_property(
			portal_fx, "modulate", Color(_fx_color.lightened(0.16), _fx_alpha), 0.31
		).set_trans(Tween.TRANS_SINE)
		_fx_pulse.tween_property(
			portal_fx, "modulate", Color(_fx_color.darkened(0.12), _fx_alpha * 0.68), 0.47
		).set_trans(Tween.TRANS_SINE)


func _update_offscreen_guide() -> void:
	if offscreen_guide == null or guidance_arrow == null:
		return
	var viewport_size := get_viewport().get_visible_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		offscreen_guide.visible = false
		return
	var screen_position := get_viewport().get_canvas_transform() * global_position
	var margin := Vector2(34.0, 34.0)
	var safe_rect := Rect2(margin, viewport_size - margin * 2.0)
	var portal_is_on_screen := safe_rect.has_point(screen_position)
	guidance_arrow.visible = portal_is_on_screen
	offscreen_guide.visible = not portal_is_on_screen
	if portal_is_on_screen:
		return
	var center := viewport_size * 0.5
	var direction := (screen_position - center).normalized()
	var clamped_position := Vector2(
		clampf(screen_position.x, margin.x, viewport_size.x - margin.x),
		clampf(screen_position.y, margin.y, viewport_size.y - margin.y)
	)
	offscreen_guide.position = clamped_position - offscreen_guide.size * 0.5
	offscreen_guide.rotation = direction.angle()


func _unhandled_input(event: InputEvent) -> void:
	if not _player_inside or _travel_started or not event.is_action_pressed("player_interact"):
		return
	get_viewport().set_input_as_handled()
	player_entered.emit()
	if target_scene_path.is_empty():
		return
	proximity_changed.emit(false, "", null)
	_player_inside = false
	_travel_started = true
	_fade_player_into_portal(_nearby_player)


func _fade_player_into_portal(player: Player) -> void:
	if is_instance_valid(player):
		player.set_physics_process(false)
		player.set_process_unhandled_input(false)
		if travel_sound != null:
			travel_sound.play()
		var departure := create_tween().set_parallel(true)
		departure.tween_property(player, "global_position", global_position + Vector2(0.0, -24.0), 0.36).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		departure.tween_property(player, "modulate:a", 0.0, 0.34)
		departure.tween_property(player, "scale", Vector2(0.72, 0.72), 0.36).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		await departure.finished
	var transition_service := get_node_or_null("/root/SceneTransition")
	if transition_service == null:
		push_error("StagePortal requires the SceneTransition autoload.")
		_restore_player_after_failed_travel(player)
		return
	var presentation: Dictionary = TIER_PRESENTATION.get(
		portal_tier, TIER_PRESENTATION[PortalTier.NORMAL]
	)
	if not await transition_service.transition_to(target_scene_path, presentation):
		_restore_player_after_failed_travel(player)


func _restore_player_after_failed_travel(player: Player) -> void:
	_travel_started = false
	if not is_instance_valid(player):
		return
	player.modulate.a = 1.0
	player.scale = Vector2.ONE
	player.set_physics_process(true)
	player.set_process_unhandled_input(true)
	# Restore F even when the player remains inside after a failed load.
	_player_inside = overlaps_body(player)
	_nearby_player = player if _player_inside else null
	proximity_changed.emit(_player_inside, interaction_text if _player_inside else "", interaction_icon if _player_inside else null)


func _on_body_entered(body: Node2D) -> void:
	if not body is Player: return
	_player_inside = true
	_nearby_player = body as Player
	proximity_changed.emit(true, interaction_text, interaction_icon)


func _on_body_exited(body: Node2D) -> void:
	if not body is Player: return
	_player_inside = false
	if body == _nearby_player:
		_nearby_player = null
	proximity_changed.emit(false, "", null)
