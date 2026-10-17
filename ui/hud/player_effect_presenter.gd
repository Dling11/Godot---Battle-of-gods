extends Node

## Adapts existing component signals to icons; never creates gameplay effects.
const VeilStyle = preload("res://ui/hud/veil_theme.gd")
const VOW_ICON = VeilStyle.STATUS_SHIELD
const LINK_ICON = preload("res://assets/ui/icons/combat/king_skill_3_icon.tres")
const CONTROL_ICON = VeilStyle.STATUS_STUN
var strip: Control
var actor: Player
var _mastery: KingMasteryComponent
var _vow: UnbrokenVowComponent
var _cyclone: WarCycloneComponent
var _tick: Timer

func bind_player(player: Player, effect_strip: Control) -> void:
	actor = player
	strip = effect_strip
	_mastery = actor.get_node_or_null("KingMastery") as KingMasteryComponent
	_vow = actor.get_node_or_null("UnbrokenVowComponent") as UnbrokenVowComponent
	_cyclone = actor.war_cyclone
	_tick = Timer.new()
	_tick.wait_time = .1
	_tick.timeout.connect(_refresh)
	add_child(_tick)
	if _mastery != null:
		_mastery.resolve_changed.connect(func(_stacks: int,_maximum: int) -> void: _refresh())
		_mastery.link_changed.connect(func(_available: bool) -> void: _refresh())
	if _vow != null:
		_vow.buff_started.connect(_refresh)
		_vow.buff_ended.connect(func(_broken: bool) -> void: _refresh())
		_vow.duration_changed.connect(func(_seconds: float) -> void: _refresh_vow())
		actor.health_component.shield_changed.connect(func(_current: float,_maximum: float) -> void: _refresh_vow())
	actor.stagger_component.stagger_started.connect(func(_seconds: float) -> void: _refresh())
	actor.stagger_component.stagger_finished.connect(_refresh)
	actor.stagger_component.stun_changed.connect(func(_active: bool) -> void: _refresh())
	actor.restraint_started.connect(func(_source: Node,total: int) -> void: _restraint(total,total))
	actor.restraint_progress.connect(func(_source: Node,remaining: int,total: int) -> void: _restraint(remaining,total))
	actor.restraint_ended.connect(func(_source: Node,_escaped: bool) -> void: strip.remove_effect(&"root"))
	actor.defeated.connect(_clear)
	_cyclone.phase_changed.connect(func(_phase: int,_seconds: float) -> void: _refresh())
	_cyclone.ability_finished.connect(_refresh)
	_refresh()

func _refresh() -> void:
	if not is_instance_valid(actor) or actor.is_defeated:
		_clear()
		return
	_refresh_vow()
	_refresh_cyclone()
	if _mastery != null:
		var tuning := _mastery.definition
		if _mastery.stacks > 0:
			var seconds := _mastery.get_resolve_remaining_seconds()
			strip.set_effect(&"resolve",{"icon":VeilStyle.STATUS_RESOLVE,"counter":str(_mastery.stacks),"priority":20,
				"card":{"title":"Resolve","subtitle":"King combat effect · %d/%d stacks" % [_mastery.stacks,tuning.resolve_hits],
				"body":"Each landed basic swing grants one stack, regardless of enemies hit. At %d stacks, the next damaging King skill gains +%d%% damage." % [tuning.resolve_hits,roundi((tuning.resolve_multiplier-1)*100)],
				"footer":"%.1fs remaining · basic hits refresh duration" % seconds}})
		else: strip.remove_effect(&"resolve")
		var link_seconds := _mastery.get_link_remaining_seconds()
		if link_seconds > 0:
			strip.set_effect(&"pursuit_link",{"icon":LINK_ICON,"counter":"%.1f" % link_seconds,"priority":30,
				"card":{"title":"Pursuit Link","subtitle":"Sovereign Pursuit → Riftbreak",
				"body":"Your next Riftbreak gains +%d%% damage. Starting another damaging King skill ends this opportunity." % roundi((tuning.pursuit_rift_multiplier-1)*100),
				"footer":"%.1fs remaining" % link_seconds}})
		else: strip.remove_effect(&"pursuit_link")
	var stagger := actor.stagger_component
	if stagger.is_staggered():
		var stunned := stagger.is_stunned()
		var seconds := stagger.stun_remaining_seconds if stunned else stagger.remaining_seconds
		strip.set_effect(&"control",{"icon":CONTROL_ICON,"counter":"%.1f" % seconds,"harmful":true,"priority":100,
			"card":{"title":"Stunned" if stunned else "Staggered","subtitle":"Incoming control",
			"body":"Movement and actions are interrupted until recovery completes.","footer":"%.1fs remaining" % seconds}})
	else: strip.remove_effect(&"control")
	var needs_tick := stagger.is_staggered() or _cyclone.has_guard() or (_mastery != null and (_mastery.stacks > 0 or _mastery.get_link_remaining_seconds() > 0))
	if needs_tick and _tick.is_stopped(): _tick.start()
	elif not needs_tick: _tick.stop()

func _refresh_cyclone() -> void:
	if _cyclone == null or not _cyclone.has_guard():
		strip.remove_effect(&"cyclone_guard")
		return
	var tuning := _cyclone.definition as WarCycloneDefinition
	var remaining := maxf(tuning.active_seconds-_cyclone.active_elapsed,0.0)
	strip.set_effect(&"cyclone_guard",{"icon":tuning.icon,"counter":"%.1f" % remaining,"priority":35,
		"card":{"title":"Blade Guard","subtitle":"War Cyclone",
			"body":"%d%% less incoming Physical, Magic and Pure damage.\nImmune to stun and stagger while spinning." % roundi(tuning.damage_reduction_ratio*100),
			"footer":"%.1fs remaining · ends with Cyclone" % remaining}})

func _refresh_vow() -> void:
	if _vow == null or not _vow.active or actor.is_defeated:
		strip.remove_effect(&"vow")
		return
	var tuning := _vow.definition as UnbrokenVowDefinition
	var body := "Shield: %d / %d HP\n+%d%% outgoing damage" % [ceili(actor.health_component.shield_health),ceili(actor.health_component.shield_maximum),roundi(_vow.get_damage_bonus()*100)]
	if tuning.movement_bonus > 0: body += "\n+%d%% movement (capped)" % roundi(tuning.movement_bonus*100)
	if _vow.has_mature_finisher(): body += "\nThird cut: +30% damage"
	strip.set_effect(&"vow",{"icon":VOW_ICON,"counter":"%ds" % ceili(_vow.remaining),"priority":40,
		"card":{"title":"Unbroken Vow","body":body,
		"footer":"%.1fs remaining" % _vow.remaining}})

func _restraint(remaining: int,total: int) -> void:
	strip.set_effect(&"root",{"icon":VeilStyle.STATUS_ROOT,"counter":str(remaining),"harmful":true,"priority":110,
		"card":{"title":"Root Prison","subtitle":"Rootbound Husk · restraint",
		"body":"Cannot move or attack. Press Dodge [Space] or tap repeatedly to escape.\n%d of %d escape inputs remaining." % [remaining,total],
		"footer":"Counter shows escape inputs, not seconds."}})

func _clear() -> void:
	if is_instance_valid(_tick): _tick.stop()
	if is_instance_valid(strip): strip.clear_effects()
