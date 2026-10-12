class_name StunIndicator
extends Node2D

## Presentation only. Place at the actor's head, outside animated body scaling.
## Player recovery and enemy controller states are authoritative; raw incoming
## stagger alone may be ignored by super armor or a committed enemy attack.
@export var actor: Node
@export var stun_state_names := PackedStringArray(["DAZED", "GUARD_BROKEN"])
@export var orbit_radius := Vector2(9.0, 3.0)
@export var cycle_seconds := 1.1
@export var star_color := Color("ffe38b")

var _stun_states: Array[int] = []
var _player_recovery := false
var _state_driven := false
var _stagger_state := -1
var _control: StaggerComponent
var _elapsed := 0.0

const STAR_ROWS := ["0001000", "0011100", "1111111", "0111110", "0011100", "0110110", "0100010"]
const SMALL_STAR_ROWS := ["00100", "11111", "01110", "01010"]


func _ready() -> void:
	set_stunned(false)
	if actor == null:
		actor = get_parent()
	_control = actor.get_node_or_null("StaggerComponent") as StaggerComponent
	if _control != null:
		_control.stun_changed.connect(_on_stun_changed)
	if actor.has_signal("hit_recovery_started") and actor.has_method("is_in_hit_recovery"):
		_player_recovery = true
		actor.connect("hit_recovery_started", _on_recovery_started)
		actor.connect("hit_recovery_finished", _on_recovery_finished)
		actor.connect("defeated", _on_recovery_finished)
	elif actor.has_signal("state_changed"):
		var constants: Dictionary = actor.get_script().get_script_constant_map()
		var states: Dictionary = constants.get("State", {})
		_stagger_state = int(states.get("STAGGER", -1))
		for state_name in stun_state_names:
			if states.has(state_name):
				_stun_states.append(int(states[state_name]))
		_state_driven = true
		actor.connect("state_changed", _on_state_changed)


## Other controllers can drive this directly with their accepted stun lifecycle.
func set_stunned(active: bool) -> void:
	if active and not visible:
		_elapsed = 0.0
	visible = active
	set_process(active)
	if active:
		queue_redraw()


func _on_recovery_started(_duration_seconds: float) -> void:
	set_stunned(_has_accepted_stun())


func _on_recovery_finished() -> void:
	set_stunned(false)


func _on_state_changed(_next_state: int, _duration_seconds: float) -> void:
	set_stunned(_has_accepted_stun())


func _on_stun_changed(_active: bool) -> void:
	set_stunned(_has_accepted_stun())


func _has_accepted_stun() -> bool:
	if not is_instance_valid(actor):
		return false
	var explicit_stun := _control != null and _control.is_stunned()
	if _player_recovery:
		return explicit_stun and actor.is_in_hit_recovery()
	if _state_driven:
		var state: int = actor.get("state")
		return state in _stun_states or state == _stagger_state and explicit_stun
	return visible


func _process(delta: float) -> void:
	# Active-only checks also catch a silent debug/reset clear. No idle polling.
	if not is_instance_valid(actor):
		set_stunned(false)
		return
	if not _has_accepted_stun():
		set_stunned(false)
		return
	_elapsed += delta
	queue_redraw()


func _draw() -> void:
	var phase := _elapsed * TAU / maxf(cycle_seconds, 0.1)
	# Rear stars first. Integer positions and stepped silhouettes stay readable
	# at the game's logical resolution without a blurred rotating texture.
	for rear in [true, false]:
		for index in 3:
			var angle := phase + index * TAU / 3.0
			var depth := sin(angle)
			if (depth < 0.0) != rear:
				continue
			var center := Vector2(cos(angle) * orbit_radius.x,
				depth * orbit_radius.y + sin(phase * 2.0) * 0.6).round()
			var tint := star_color.darkened(0.22) if rear else star_color
			var tail := (center - Vector2(-sin(angle), cos(angle) * 0.35) * 3.0).round()
			draw_rect(Rect2(tail, Vector2.ONE), Color(tint, 0.45))
			_draw_star(center, tint, rear)


func _draw_star(center: Vector2, tint: Color, small: bool) -> void:
	var outline := Color("403645")
	var rows: Array = SMALL_STAR_ROWS if small else STAR_ROWS
	var origin := center - Vector2(2, 2) if small else center - Vector2(3, 3)
	for border in [true, false]:
		for y in rows.size():
			for x in rows[y].length():
				if rows[y][x] != "1":
					continue
				var point := origin + Vector2(x, y)
				if border:
					for offset in [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]:
						draw_rect(Rect2(point + offset, Vector2.ONE), outline)
				else:
					var color := Color("fff9df") if y < 3 and x == rows[y].length() / 2 else tint
					draw_rect(Rect2(point, Vector2.ONE), color)
