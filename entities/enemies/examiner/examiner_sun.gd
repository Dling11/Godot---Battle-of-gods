class_name ExaminerSun
extends Node2D

## Fixed landing point and radius are shared by warning, contact and rendering.
## An airborne cast passes over props; only the warned ground impact deals damage.
var actor: Examiner
var target: Node2D
var origin := Vector2.ZERO
var destination := Vector2.ZERO
var radius := 76.0
var damage := 155.0
var warning_seconds := 1.15
var falling := false
var elapsed := 0.0
var resolved := false
var crimson := false
var presentation_gain := 1.0
var _audio: AudioStreamPlayer2D


func configure(owner_actor: Examiner, player: Node2D, start: Vector2, landing: Vector2,
		impact_radius: float, raw_damage: float, warning: float, from_above := false) -> void:
	actor = owner_actor
	target = player
	origin = start
	destination = landing
	radius = impact_radius
	damage = raw_damage
	warning_seconds = warning
	falling = from_above
	global_position = landing
	z_index = 8
	_audio = AudioStreamPlayer2D.new()
	_audio.bus = &"SFX"
	_audio.stream = load("res://assets/audio/sfx/characters/disciples/examiner/ascendant/sun_impact.wav")
	_audio.volume_db = -5.0
	add_child(_audio)


func _physics_process(delta: float) -> void:
	if not is_instance_valid(actor) or actor.state == Examiner.State.WITHDRAWAL:
		queue_free()
		return
	elapsed += delta
	if not resolved and elapsed >= warning_seconds:
		resolved = true
		_resolve()
	if elapsed >= warning_seconds + 0.85:
		queue_free()
	queue_redraw()


func _resolve() -> void:
	actor.action_impact.emit(&"meteor_impact" if crimson else &"sun_impact", destination, Vector2.DOWN)
	_audio.volume_db = -5.0 + linear_to_db(presentation_gain)
	_audio.pitch_scale = 0.8 if crimson else 1.0
	if DisplayServer.get_name() != "headless":
		_audio.play()
	if not is_instance_valid(target) or target.global_position.distance_to(destination) > radius:
		return
	var health := target.find_child("HealthComponent", true, false) as HealthComponent
	if health != null:
		health.apply_damage(DamageInfo.new(damage, actor, (target.global_position - destination).normalized(), 180.0, 0.16))


func _draw() -> void:
	var progress := clampf(elapsed / warning_seconds, 0, 1)
	if not resolved:
		ExaminerEffectAtlas.danger_circle(self, Vector2.ZERO, radius, progress)
		var travel := pow(progress, 2.2) if falling else pow(progress, 1.45)
		var position_in_air := Vector2(0, -250.0 * (1.0 - travel)) if falling else origin.lerp(destination, travel) - destination + Vector2(0, -65.0 * sin(PI * travel))
		var extent := radius * (0.80 if falling else 0.76)
		var tint := ExaminerEnergyPresentation.CRIMSON if crimson else Color.WHITE
		# Textured wake expands behind an accelerating projectile.
		draw_set_transform(position_in_air, -PI * 0.5 if falling else (origin-destination).angle())
		ExaminerEffectAtlas.draw_frame(self, ExaminerEffectAtlas.Energy, posmod(int(elapsed * 22),8), Rect2(0,-extent * 0.28,70 + travel * 90,extent * 0.56), Color(tint,0.65))
		draw_set_transform(Vector2.ZERO)
		ExaminerEffectAtlas.draw_sun(self, elapsed, position_in_air, extent, tint, elapsed * 2.0, crimson)
		# Sparse trailing sparks follow the same ballistic path.
		for index in 8:
			var phase := fmod(elapsed * 2.0 + index * 0.127, 1.0)
			var mote := position_in_air + Vector2(sin(index * 2.4) * 18, -phase * 48)
			draw_rect(Rect2(mote, Vector2.ONE * 2), Color(1, 0.73, 0.24, (1.0 - phase) * 0.8))
	else:
		var age := (elapsed - warning_seconds) / 0.85
		var frame := 4 + clampi(int(age * 4), 0, 3)
		ExaminerEffectAtlas.draw_frame(self, ExaminerEffectAtlas.Sun, frame,
			Rect2(-Vector2.ONE * radius * 1.18, Vector2.ONE * radius * 2.36), Color(ExaminerEnergyPresentation.CRIMSON if crimson else Color.WHITE, 1.0 - maxf(age - 0.6, 0) * 2.5))
		if crimson and age < 0.5:
			ExaminerEffectAtlas.draw_frame(self, ExaminerEffectAtlas.Sun, frame, Rect2(-Vector2.ONE * radius * 0.5, Vector2.ONE * radius), Color(1,0.87,0.69,1.0-age*2))
