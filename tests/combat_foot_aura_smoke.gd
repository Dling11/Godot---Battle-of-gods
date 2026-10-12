extends SceneTree

const PlayerScene = preload("res://entities/player/player.tscn")
const EnemyScenes: Array[PackedScene] = [
	preload("res://entities/enemies/armored_hog/armored_hog.tscn"),
	preload("res://entities/enemies/bramble_spitter/bramble_spitter.tscn"),
	preload("res://entities/enemies/forsaken_thrall/forsaken_thrall.tscn"),
	preload("res://entities/enemies/mireling/mireling.tscn"),
	preload("res://entities/enemies/rootbound_husk/rootbound_husk.tscn"),
	preload("res://entities/enemies/rootling/rootling.tscn"),
	preload("res://entities/enemies/stage_5_boss/stage_5_boss.tscn"),
]


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var player := PlayerScene.instantiate() as Player
	root.add_child(player)
	var player_aura := player.get_node_or_null("CombatFootAura") as CombatFootAura
	if player_aura == null or not player_aura.player_aura or player_aura.scale.y >= player_aura.scale.x:
		_fail("Player does not have the authored oval footprint aura.")
		return
	for enemy_scene: PackedScene in EnemyScenes:
		var enemy := enemy_scene.instantiate() as Node2D
		root.add_child(enemy)
		var aura := enemy.get_node_or_null("CombatFootAura") as CombatFootAura
		if aura == null or aura.player_aura or aura.scale.y >= aura.scale.x:
			_fail("%s does not have the shared enemy footprint aura." % enemy.name)
			return
	print("Combat footprint aura smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
