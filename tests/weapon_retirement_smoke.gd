extends SceneTree

const CURRENT = preload("res://data/items/equipment/king_royal_greatsword_v2.tres")
const OUT := "res://tmp/review/combat/weapon_impact_closure_2026_10_07/"
var checks := 0
var failures := 0

func _initialize() -> void:
	_run.call_deferred()

func check(ok: bool,message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func _run() -> void:
	var inventory := root.get_node("WeaponInventory")
	var saves := root.get_node("SaveService")
	saves.suppress_autosave_for_debug_session()
	inventory.reset_inventory()
	check(inventory.KingCatalog.has_valid_layout(),"Retired catalog is invalid")
	check(inventory.KingCatalog.weapons.size()==5,"Catalog still exposes the redundant Greatsword")
	check(inventory.KingCatalog.find_weapon(&"weapon_king_royal_greatsword")==null,"V1 remains selectable")
	check(inventory.KingCatalog.find_weapon(CURRENT.item_id)==CURRENT,"Approved Greatsword disappeared")
	for version in [1,2]:
		for duplicate_current in [false,true]:
			var owned: Array[String] = ["weapon_king_signature_sword","weapon_king_royal_greatsword"]
			if duplicate_current: owned.append(String(CURRENT.item_id))
			var legacy := {"version":version,"owned_weapon_ids":owned,"equipped_weapon_ids":{"king":"weapon_king_royal_greatsword"}}
			check(inventory.can_restore_snapshot(legacy),"Existing version %d Greatsword save was rejected"%version)
			check(inventory.restore_snapshot(legacy),"Existing Greatsword save could not restore")
			check(inventory.owns_weapon(CURRENT.item_id) and not inventory.owns_weapon(&"weapon_king_royal_greatsword"),"Ownership did not migrate without a ghost item")
			check(inventory.get_equipped_weapon_id(&"king",&"")==CURRENT.item_id,"Equipped legacy Greatsword did not migrate")
			var migrated: Dictionary = inventory.create_snapshot()
			check(migrated.owned_weapon_ids.size()==2,"Migration duplicates ownership")
			check(not migrated.owned_weapon_ids.has("weapon_king_royal_greatsword") and migrated.equipped_weapon_ids.king==String(CURRENT.item_id),"New snapshot writes the retired ID")
			check(inventory.can_restore_snapshot(migrated) and inventory.restore_snapshot(migrated),"Migrated save fails a second load")
			# Exercise full profile validation/restoration too, without disk I/O.
			var profile: Dictionary = saves.create_profile_snapshot()
			profile.weapon_inventory = legacy
			check(saves.can_restore_profile(profile) and saves.restore_profile(profile),"Full profile rejected the supported legacy weapon migration")
	var unknown := {"version":2,"owned_weapon_ids":["weapon_king_signature_sword","not_a_real_weapon"],"equipped_weapon_ids":{"king":"weapon_king_signature_sword"}}
	check(not inventory.can_restore_snapshot(unknown),"Migration accidentally accepts arbitrary unknown items")
	unknown.owned_weapon_ids = ["weapon_king_signature_sword"]
	unknown.equipped_weapon_ids.king = "weapon_king_royal_greatsword"
	check(not inventory.can_restore_snapshot(unknown),"Migration invents ownership for an unowned equipped weapon")
	inventory.reset_inventory()
	check(not inventory.owns_weapon(CURRENT.item_id),"Retirement grants a new campaign an unearned weapon")
	DirAccess.make_dir_recursive_absolute(OUT)
	FileAccess.open(OUT+"retirement_validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"scope":"catalog removal; version1/2 full-profile migration; duplicate collapse; validation retained; fresh campaign unchanged"},"\t"))
	print("WEAPON_RETIREMENT: ",checks," checks, ",failures," failures")
	quit(1 if failures else 0)
