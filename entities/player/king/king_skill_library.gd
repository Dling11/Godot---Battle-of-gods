class_name KingSkillLibrary
extends Node

## Learnable techniques and ten equipped slots; persistence stores stable IDs.
signal library_changed
const Training = preload("res://data/abilities/king/king_training_catalog.gd")
var actor: Player
var _collection: CanvasLayer

func _ready() -> void:
	actor = get_parent() as Player
	actor.ready.connect(_bind)

func _bind() -> void:
	if not is_lab():
		_apply_training_rank("echoing_sever",get_node("/root/RunSession").king_earthsplitter_rank)
		_apply_training_rank("riftbreak",get_node("/root/RunSession").king_molten_rank)
	var pursuit := actor.ability_3_component as SovereignPursuitComponent
	if pursuit != null:
		pursuit.apply_rank(get_node("/root/RunSession").king_pursuit_rank)
	var vow := actor.get_node("UnbrokenVowComponent") as UnbrokenVowComponent
	vow.apply_rank(get_node("/root/RunSession").king_vow_rank)
	(actor.ability_4_component as KingSkill4Component).apply_rank(get_node("/root/RunSession").king_worldsplitter_rank)
	refresh()
	if is_lab():
		_apply_slots(KingSkillCatalog.IDS)
		return
	var saved: Array = get_node("/root/RunSession").king_skill_slots
	if not saved.is_empty() and KingSkillCatalog.valid_slots(saved):
		var session := get_node("/root/RunSession")
		var normalized := KingSkillCatalog.migrate_legacy_slots(saved) if session.king_skill_layout_version < 2 else KingSkillCatalog.expanded_slots(saved)
		session.king_skill_layout_version = 2
		_apply_slots(normalized)
		get_node("/root/RunSession").king_skill_slots = normalized

func is_learned(id: String) -> bool:
	if id not in KingSkillCatalog.IDS:
		return false
	return true

func can_edit() -> bool:
	if actor.is_cinematic_locked() or actor.is_defeated or actor.is_any_ability_casting() or actor.attack_component.phase!=MeleeAttackComponent.Phase.IDLE or actor.evade_component.is_dashing() or actor.is_restrained() or actor.is_in_hit_recovery() or actor._is_targeting_any_ability():
		return false
	var scene := get_tree().current_scene
	var path := scene.scene_file_path if scene!=null else ""
	return path=="res://levels/sanctuary/sanctuary.tscn" or is_lab()

func is_lab() -> bool:
	var node: Node = actor
	while node!=null:
		if node.scene_file_path=="res://levels/combat_lab/combat_lab.tscn":
			return OS.is_debug_build()
		node=node.get_parent()
	return false

func entries() -> Array[AbilityComponent]:
	return actor.get_all_ability_components()

func equip(id: String, slot_number: int) -> bool:
	if not can_edit() or (not id.is_empty() and not is_learned(id)) or slot_number<1 or slot_number>SkillLoadoutDefinition.SLOT_COUNT:
		return false
	var ids := current_ids()
	var previous := ids.find(id)
	if previous>=0 and not id.is_empty():
		ids[previous]=ids[slot_number-1]
	ids[slot_number-1]=id
	_apply_slots(ids)
	actor._clear_buffered_action()
	if not is_lab():
		get_node("/root/RunSession").king_skill_slots=ids.duplicate()
		get_node("/root/SaveService").save_profile()
	return true

func current_ids() -> Array:
	var ids: Array = []
	for slot in actor.skill_loadout.get_ordered_slots():
		ids.append(String(slot.ability.ability_id) if slot.ability!=null else "")
	return ids

func equip_core_kit() -> bool:
	if not can_edit():
		return false
	var ids := current_ids()
	for index in KingSkillCatalog.IDS.size():
		var id: String = KingSkillCatalog.IDS[index]
		var previous := ids.find(id)
		if previous>=KingSkillCatalog.IDS.size():
			ids[previous]=""
		ids[index]=id if is_learned(id) else ""
	_apply_slots(ids)
	actor._clear_buffered_action()
	if not is_lab():
		get_node("/root/RunSession").king_skill_slots=ids.duplicate()
		get_node("/root/SaveService").save_profile()
	return true

func open_collection(at_skillkeeper := false) -> void:
	if is_instance_valid(_collection):
		return
	_collection=load("res://ui/skills/king_skill_collection.gd").new()
	_collection.library=self
	_collection.trainer_access=at_skillkeeper
	_collection.tree_exited.connect(func() -> void: _collection = null,CONNECT_ONE_SHOT)
	add_child(_collection)

func training_info(id: String) -> Dictionary:
	var course := Training.course(id)
	if course.is_empty(): return {}
	var rank: int = get_node("/root/RunSession").get(course.field)
	var result := course.duplicate(true)
	result.rank = rank
	result.required_level = course.levels[rank] if rank < course.levels.size() else 0
	result.current_level = actor.progression_component.level
	return result

func can_upgrade_skill(id: String, at_skillkeeper: bool) -> bool:
	var info := training_info(id)
	return not info.is_empty() and at_skillkeeper and not is_lab() and can_edit() and info.required_level > 0 and actor.progression_component.level >= info.required_level

func upgrade_skill(id: String, at_skillkeeper: bool) -> bool:
	if not can_upgrade_skill(id,at_skillkeeper): return false
	var info := training_info(id)
	var session := get_node("/root/RunSession")
	session.set(info.field,info.rank+1)
	if not get_node("/root/SaveService").save_profile():
		session.set(info.field,info.rank)
		return false
	_apply_training_rank(id,info.rank+1)
	refresh()
	return true

func _apply_training_rank(id: String, rank: int) -> void:
	match id:
		"echoing_sever":
			# Keep the authored Foundation untouched for old/default saves.
			if rank == 0: return
			var next := actor.ability_1_component.definition.duplicate(true) as EarthsplitterDefinition
			next.configure_form(EarthsplitterDefinition.Form.FAN)
			actor.ability_1_component.definition = next
			actor.ability_1_component.collision_shape.shape = next.hitbox_shape
		"riftbreak":
			if rank == 0: return
			var next := actor.ability_2_component.definition.duplicate(true) as MoltenCrashDefinition
			next.configure_form(rank)
			actor.ability_2_component.definition = next
			actor.ability_2_component.collision_shape.shape = next.hitbox_shape
		"sovereign_pursuit": (actor.ability_3_component as SovereignPursuitComponent).apply_rank(rank)
		"unbroken_vow": (actor.get_node("UnbrokenVowComponent") as UnbrokenVowComponent).apply_rank(rank)
		"king_skill_4": (actor.ability_4_component as KingSkill4Component).apply_rank(rank)

func get_pursuit_upgrade_level() -> int:
	return training_info("sovereign_pursuit").required_level

func can_upgrade_pursuit(at_skillkeeper: bool) -> bool:
	return can_upgrade_skill("sovereign_pursuit",at_skillkeeper)

func upgrade_pursuit(at_skillkeeper: bool) -> bool:
	return upgrade_skill("sovereign_pursuit",at_skillkeeper)

func refresh() -> void:
	_apply_slots(current_ids())

func _apply_slots(ids: Array) -> void:
	# Preserve sealed legacy slots on actors used by older progression proofs.
	# External slot resources inside an exported array must be duplicated
	# explicitly; mutating them can otherwise change another player's loadout.
	var loadout := SkillLoadoutDefinition.new()
	for slot in actor.skill_loadout.get_ordered_slots():
		loadout.slots.append(slot.duplicate(false))
	while loadout.slots.size()<SkillLoadoutDefinition.SLOT_COUNT:
		var empty := SkillSlotDefinition.new()
		empty.slot_number=loadout.slots.size()+1
		empty.input_action=StringName("player_skill_%d" % empty.slot_number)
		empty.locked_title="Empty slot"
		empty.locked_description="Equip a learned technique in Sanctuary."
		empty.unlock_hint="EMPTY"
		loadout.slots.append(empty)
	var expanded := KingSkillCatalog.expanded_slots(ids)
	for index in SkillLoadoutDefinition.SLOT_COUNT:
		var id: String = expanded[index]
		loadout.get_slot(index+1).ability=null
		if id.is_empty() or not is_learned(id):
			continue
		for ability in entries():
			if String(ability.definition.ability_id)==id:
				loadout.get_slot(index+1).ability=ability.definition
				break
	# Shared legacy resource identities are used to resolve slot components.
	for slot in loadout.get_ordered_slots():
		if slot.ability!=null:
			for ability in entries():
				if ability.definition.ability_id==slot.ability.ability_id:
					slot.ability=ability.definition
	actor.skill_loadout=loadout
	actor.skill_loadout_changed.emit()
	library_changed.emit()

func get_vow_upgrade_level() -> int:
	return training_info("unbroken_vow").required_level

func can_upgrade_vow(at_skillkeeper: bool) -> bool:
	return can_upgrade_skill("unbroken_vow",at_skillkeeper)

func upgrade_vow(at_skillkeeper: bool) -> bool:
	return upgrade_skill("unbroken_vow",at_skillkeeper)

func get_worldsplitter_upgrade_level() -> int:
	return training_info("king_skill_4").required_level

func can_upgrade_worldsplitter(at_skillkeeper: bool) -> bool:
	return can_upgrade_skill("king_skill_4",at_skillkeeper)

func upgrade_worldsplitter(at_skillkeeper: bool) -> bool:
	return upgrade_skill("king_skill_4",at_skillkeeper)
