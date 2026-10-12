extends RefCounted

## Review-only balance candidate. Never edits the campaign's shared resources.
static func configure(encounter: EncounterController) -> void:
	assert(not encounter._started,"Choose pressure before starting the encounter")
	var brood := encounter.waves[0].duplicate(true) as EncounterWaveDefinition
	brood.rootling_count = 18
	encounter.waves = [brood,encounter.waves[1]]
	encounter.max_active_enemies = 6
