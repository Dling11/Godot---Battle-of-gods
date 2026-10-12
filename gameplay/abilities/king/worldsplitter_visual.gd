extends Node2D

## Observes sequence contacts. Every strike consumes a separately summoned blade.
const Blade = preload("res://gameplay/abilities/king/worldsplitter_summoned_blade.gd")
const Sword = Blade.Sword
const Ground = Blade.Ground
const Summon = Blade.Summon
const Gather = preload("res://assets/audio/sfx/abilities/king/worldsplitter_gather.wav")
const Fall = preload("res://assets/audio/sfx/abilities/king/worldsplitter_descent.wav")
const Contact = preload("res://assets/audio/sfx/abilities/king/worldsplitter_contact.wav")
const Rupture = preload("res://assets/audio/sfx/abilities/king/worldsplitter_rupture.wav")
const Shards = preload("res://assets/audio/sfx/abilities/king/worldsplitter_light_shards.wav")
# Start the next summon earlier; impacts retain their rapid .28s cadence.
const FOLLOWUP_FORMATION_SECONDS := .34
var source: Player
var component: AbilityComponent
var tuning: KingSkill4Definition
var radius := 72.0
var _blades: Array[Node2D] = []
var _sword: Sprite2D
var _ground: Sprite2D
var _sword_material: ShaderMaterial
var _age := 0.0
var _flight := 0.0
var _contact_age := -1.0
var _contact_index := -1
var _final := false
var _released := false
var _feedback: CombatFeedbackPresenter

func _ready() -> void:
	add_to_group("worldsplitter_effects")
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_feedback = CombatFeedbackPresenter.find_for_player(source)
	_spawn_blade(0)
	_select_contact_blade(0)

func _spawn_blade(index: int) -> void:
	var blade := Blade.new()
	blade.crimson = tuning.rank == KingSkill4Definition.Rank.MATURE or index > 0
	blade.blast_radius = tuning.contact_radius(index)
	add_child(blade)
	_blades.append(blade)
	_sound(Gather,-20.0 if index == 0 else -24.0,1.0 if index == 0 else 1.35)
	if index > 0:
		blade.launch(FOLLOWUP_FORMATION_SECONDS, true)
		_sound(Fall,-21.0,1.25)

func _select_contact_blade(index: int) -> void:
	_sword = _blades[index]._sword
	_ground = _blades[index]._ground
	_sword_material = _blades[index]._sword_material

func release() -> void:
	_released = true
	_flight = 0.0
	_blades[0].launch(tuning.descent_seconds)
	_sound(Fall,-16.0,1.0)

func impact(index: int, final: bool) -> void:
	# Low frame rates can deliver a contact before the observer's spawn tick.
	while _blades.size() <= index: _spawn_blade(_blades.size())
	_contact_index = index
	_contact_age = 0.0
	_final = final
	_blades[index].impact()
	_select_contact_blade(index)
	_sound(Contact,-10.0 if final else -17.0,.92 if final else 1.08)
	_sound(Shards,-23.0 if final else -28.0,1.0 if final else 1.12)
	_sound(Rupture,-19.0 if final else -25.0,.95 if final else 1.1)
	if is_instance_valid(_feedback): _feedback.request_camera_pulse(4.2 if final else 1.7)

func _physics_process(delta: float) -> void:
	if not is_instance_valid(source) or source.is_defeated or not is_instance_valid(component):
		queue_free()
		return
	_age += delta
	if _released:
		_flight += delta
		if _blades.size() < tuning.strike_count():
			var next_contact := tuning.descent_seconds+_blades.size()*tuning.followup_delay_seconds
			if _flight >= next_contact-FOLLOWUP_FORMATION_SECONDS: _spawn_blade(_blades.size())
	for blade in _blades: blade.advance(delta)
	if _contact_age >= 0.0:
		_contact_age += delta
		if _final and _contact_age > .95: queue_free()
	if _age > 3.5: queue_free()

func _sound(stream: AudioStream, volume: float, pitch: float) -> void:
	if DisplayServer.get_name() == "headless": return
	var sound := AudioStreamPlayer2D.new()
	sound.stream = stream
	sound.volume_db = volume
	sound.pitch_scale = pitch
	sound.bus = &"SFX"
	add_child(sound)
	sound.finished.connect(sound.queue_free)
	sound.play()
