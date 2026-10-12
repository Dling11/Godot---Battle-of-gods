class_name PlayerHeldAttackComponent
extends Node

## Local mouse intent only. Player's ordinary buffer and Melee own every cut.
const HOLD_DELAY := 0.18
const REPEAT_CHECK_SECONDS := 0.06
var actor: Player
var held := false
var repeating := false
var _timer: Timer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_timer = Timer.new()
	_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	_timer.timeout.connect(_pulse)
	add_child(_timer)
	set_process(false)
	set_physics_process(false)

func begin_world_press() -> void:
	# Called only after unhandled world input, never by a GUI button.
	if get_tree().paused or actor.is_cinematic_locked() or actor.is_defeated:
		return
	held = true
	repeating = false
	_timer.start(HOLD_DELAY)

func cancel() -> void:
	held = false
	repeating = false
	if _timer != null: _timer.stop()
	if is_instance_valid(actor) and actor._buffered_primary_from_hold:
		actor._clear_buffered_action()

func _input(event: InputEvent) -> void:
	if not held: return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			cancel()
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			cancel()
	elif event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.pressed and event.keycode == KEY_TAB):
		cancel()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_WINDOW_FOCUS_OUT: cancel()

func _pulse() -> void:
	if not held or not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or get_tree().paused:
		cancel()
		return
	if actor.is_defeated or actor.is_restrained() or actor.is_in_hit_recovery() or actor.is_cinematic_locked() or actor.is_targeting_any_ability() or actor.is_any_ability_casting() or actor.evade_component.is_dashing():
		cancel()
		return
	if not repeating:
		repeating = true
		actor.auto_combat.set_auto_farm_enabled(false)
		actor.combat_targeting.suspend_auto_attack()
		actor.combat_targeting.cancel_click_move()
	actor.request_held_primary_attack(actor.get_global_mouse_position())
	_timer.start(REPEAT_CHECK_SECONDS)
