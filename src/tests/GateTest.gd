extends Node

const GateDoor := preload("res://src/core/GateDoor.gd")
const LevelGate := preload("res://src/core/LevelGate.gd")

var _fail := 0
var _out: Array[String] = []
var _door: GateDoor
var _gate: LevelGate

func _ready() -> void:
	var r := Game.gate_rule("to_suspect_street")
	_check(r != null, "gate rule resolves")
	if r == null:
		_finish()
		return

	_check(not r.is_met(), "locked with no evidence")
	_check(r.missing().size() == 1, "one requirement outstanding")
	_check(r.progress() == "0 / 1", "progress reads 0 / 1")

	var lvl := Game.gate_rule("to_switch")
	_check(lvl != null and lvl.requires_clues.has("F-04"), "later gate keyed to the tape")
	_check(Game.gate_rule("nope_not_real") == null, "unknown gate returns null")
	_check(Game.gate_open("to_switch") == false, "gate_open false before evidence")

	Game.add_clue("I-06")
	_check(r.is_met(), "unlocks once I-06 is found")
	_check(r.progress() == "1 / 1", "progress reads 1 / 1")
	_check(Game.gate_open("to_suspect_street") == true, "gate_open true after evidence")

	Game.set_flag("solved_p1b", true)
	_check(Game.get_flag("solved_p1b") == true, "flags persist")

	var level: Node = load("res://src/levels/L1_DarkCity.tscn").instantiate()
	add_child(level)
	await get_tree().process_frame
	for c in level.get_children():
		if c is GateDoor:
			_door = c as GateDoor
		if c is LevelGate:
			_gate = c as LevelGate

	_check(_door != null, "gate door placed in level")
	if _door != null:
		_check(_door.rule != null and _door.rule.is_met(), "door reads the live rule")
		_check(not _door.is_open, "door starts closed")
		_check(_door.can_interact(), "locked door still answers E")
		_door.interact(null)
		_check(_door.is_open, "interacting with a met rule opens the door")

	Game.set_flag("to_switch", false)
	var partial := Game.gate_rule("to_villain_lair")
	Game.add_clue("S-01")
	_check(not partial.is_met(), "two-clue gate stays shut on one clue")
	_check(partial.missing().has("S-04"), "names the missing clue specifically")
	_finish()

func _check(cond: bool, label: String) -> void:
	_out.append(("PASS  " if cond else "FAIL  ") + label)
	if not cond:
		_fail += 1

func _finish() -> void:
	for r in _out:
		print(r)
	print("---")
	print("GATES: " + ("ALL PASS" if _fail == 0 else str(_fail) + " FAILED"))
	get_tree().quit(0 if _fail == 0 else 1)