class_name KingTrainingCatalog
extends RefCounted

## One curriculum shared by trainer presentation and authoritative rank validation.
const COURSES := {
	"echoing_sever": {"name":"Earthsplitter", "field":"king_earthsplitter_rank", "levels":[2],
		"ranks":["Foundation","Fan"], "role":"Aimed lane damage",
		"benefits":["One aimed rupture · 164px reach", "Three spreading lanes plus a center follow-up · 228px reach"]},
	"riftbreak": {"name":"Molten Crash", "field":"king_molten_rank", "levels":[3,6,9],
		"ranks":["Foundation","Advanced","Awakened","Mature"], "role":"Close-range control",
		"benefits":["72px impact · 200% weapon damage", "80px impact · 230% weapon damage",
			"84px impact plus one delayed heat pulse · 240% total", "86px impact, stronger center and heat pulse · 270% total"]},
	"sovereign_pursuit": {"name":"Sovereign Pursuit", "field":"king_pursuit_rank", "levels":[5,8],
		"ranks":["Foundation","Advanced","Mature"], "role":"Mobility and follow-up attacks",
		"benefits":["1 aimed use · 220px reach", "2 aimed uses · 250px reach", "3 aimed uses · 280px reach"]},
	"unbroken_vow": {"name":"Unbroken Vow", "field":"king_vow_rank", "levels":[7,10],
		"ranks":["Foundation","Advanced","Mature"], "role":"Defense and empowered attacks",
		"benefits":["Shield and outgoing damage bonus", "Stronger shield, damage and movement bonus", "Empowers the third basic strike while the vow lasts"]},
	"king_skill_4": {"name":"Worldsplitter", "field":"king_worldsplitter_rank", "levels":[8,10],
		"ranks":["Foundation","Advanced","Mature"], "role":"Heavy damage at one chosen point",
		"benefits":["1 summoned blade · 520% total weapon damage", "2 summoned blades · 600% total weapon damage", "3 summoned blades · 700% total weapon damage"]},
}

static func course(id: String) -> Dictionary:
	return COURSES.get(id,{})
