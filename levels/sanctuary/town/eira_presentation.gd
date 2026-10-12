extends "res://entities/npcs/presentation/service_work_animation.gd"

const EIRA_POSITION := Vector2(384,410)
const APPROACH := EIRA_POSITION + Vector2(0,36)

func configure(hub: Node) -> void:
	setup(hub,"Skillkeeper","Eira","Skill Mentor",Vector2(12,-62))
	npc.position = EIRA_POSITION
