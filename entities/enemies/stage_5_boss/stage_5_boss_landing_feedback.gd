extends Node

signal shake_started
signal slap_shake_started
signal root_execution_shake_started

@export var boss: Stage5Boss
@export var camera: Camera2D

var _base_offset := Vector2.ZERO
var _shake_tween: Tween


func _ready() -> void:
	if boss == null or camera == null:
		push_error("Stage5BossLandingFeedback requires boss and camera references.")
		return
	_base_offset = camera.offset
	boss.landed.connect(_on_boss_landed)
	boss.slap_landed.connect(_on_boss_slapped)
	boss.root_executed.connect(_on_root_executed)


func _on_boss_landed(_position: Vector2) -> void:
	shake_started.emit()
	_play_shake(boss.get_landing_feedback_strength())


func _on_boss_slapped(_position: Vector2) -> void:
	slap_shake_started.emit()
	_play_shake(2.5)


func _on_root_executed(_position: Vector2, _hit_player: bool) -> void:
	root_execution_shake_started.emit()
	_play_shake(8.0)


func _play_shake(strength: float) -> void:
	if _shake_tween != null and _shake_tween.is_valid():
		_shake_tween.kill()
	camera.offset = _base_offset
	_shake_tween = create_tween()
	_shake_tween.tween_property(camera, "offset", _base_offset + Vector2(strength, -strength * 0.4), 0.025)
	_shake_tween.tween_property(camera, "offset", _base_offset + Vector2(-strength * 0.8, strength * 0.4), 0.035)
	_shake_tween.tween_property(camera, "offset", _base_offset + Vector2(strength * 0.6, strength * 0.2), 0.035)
	_shake_tween.tween_property(camera, "offset", _base_offset + Vector2(-2.0, -1.0), 0.04)
	_shake_tween.tween_property(camera, "offset", _base_offset, 0.055)
