extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	var hub: Node = load("res://levels/sanctuary/sanctuary.tscn").instantiate()
	root.add_child(hub)
	current_scene = hub
	await process_frame
	await process_frame
	var study: Node = hub.get_node("SanctuaryTown")
	study.enable_test_controls()
	if "--interface-demo" in OS.get_cmdline_user_args():
		configure_interface_demo(hub,study)
	if "--training-demo" in OS.get_cmdline_user_args():
		root.get_node("StoryState").remember_story(&"forest_stage_5_cleared")
		root.get_node("RunSession").update_progression(4950,0)
	if "--interface-demo" in OS.get_cmdline_user_args(): study.visit_nema()
	elif "--workshop-door" in OS.get_cmdline_user_args(): study.visit_workshop()
	elif "--eira" in OS.get_cmdline_user_args(): study.visit_eira()
	else: study.visit_orren()
	root.title = "Battle of Gods — HP, Growth & Bag Review" if "--interface-demo" in OS.get_cmdline_user_args() else "Battle of Gods — Living Sanctuary Review"

func configure_interface_demo(hub: Node, study: Node) -> void:
	var story := root.get_node("StoryState")
	story.record_discovery(&"forest_core_gear_crafting")
	story.grant_key_item(&"forest_core_gear_seal")
	root.get_node("RunSession").update_progression(100,750)
	var catalog: MaterialCatalogDefinition = preload("res://data/items/materials/material_catalog.tres")
	for material in catalog.materials:
		root.get_node("MaterialInventory").add_material(material.material_id,8)
	root.get_node("GearInventory").acquire_item(preload("res://data/items/equipment/forest/stage_5_core/rootfiber_gloves.tres"))
	var column: VBoxContainer = study._panel.get_child(0)
	var row := HBoxContainer.new()
	row.name = "InterfaceDemoControls"
	column.add_child(row)
	var caption := Label.new()
	caption.text = "UI TEST ·"
	caption.add_theme_font_size_override("font_size",11)
	row.add_child(caption)
	_demo_button(row,"+75 XP",func() -> void: hub.player.progression_component.grant_rewards(75,0))
	_demo_button(row,"Lose 35 HP",func() -> void:
		var health: HealthComponent = hub.player.health_component
		var amount := minf(35,maxf(health.current_health-1,0))
		if amount > 0:
			var hit := DamageInfo.new(amount,hub.player,Vector2.ZERO)
			hit.ignores_invulnerability = true
			health.apply_damage(hit))
	_demo_button(row,"Heal",func() -> void: hub.player.health_component.set_current_health(hub.player.health_component.maximum_health))
	_demo_button(row,"Next stage cap",func() -> void:
		var progression: PlayerProgressionComponent = hub.player.progression_component
		var next := progression.definition.next_cap_requirement(story,progression.get_current_level_cap())
		if not next.is_empty(): story.remember_story(next.flag))

func _demo_button(row: HBoxContainer, title: String, action: Callable) -> void:
	var button := Button.new()
	button.text = title
	button.add_theme_font_size_override("font_size",11)
	button.pressed.connect(action)
	row.add_child(button)
