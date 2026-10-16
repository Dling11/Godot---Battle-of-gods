extends "res://tests/king_twinsteel_art_contract.gd"

func _run() -> void:
	verify_lanes(["run","idle"])
	print("TWINSTEEL_WALK checks=",checks," failures=",failures)
	quit(1 if failures else 0)
