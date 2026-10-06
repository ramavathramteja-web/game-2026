extends Node

var _fail := 0
var _out: Array[String] = []
var _levels: Array[String] = [
	"res://src/levels/L1_DarkCity.tscn",
	"res://src/levels/L2_SuspectStreet.tscn",
	"res://src/levels/L3_VillainLair.tscn",
	"res://src/levels/L4_SunFacility.tscn",
	"res://src/levels/L5_TheSwitch.tscn",
]

func _ready() -> void:
	await _test_scenes_exist()
	await _test_gates_resolve()
	await _test_clue_chain()
	await _test_levels_instantiate()
	await _test_ending_fires()
	_finish()

func _test_scenes_exist() -> void:
	for l in _levels:
		_check(ResourceLoader.exists(l), "scene exists: " + l.get_file())

func _test_gates_resolve() -> void:
	var ids := ["leave_annex", "to_suspect_street", "enter_lair", "to_villain_lair",
		"enter_facility", "to_facility", "enter_switch", "to_switch"]
	for id in ids:
		var r := Game.gate_rule(id)
		if r == null:
			_check(false, "gate rule resolves: " + id)
			continue
		_check(true, "gate rule resolves: " + id)
		if r.to_scene != "":
			_check(ResourceLoader.exists(r.to_scene),
				"gate '" + id + "' target exists: " + r.to_scene.get_file())

func _test_clue_chain() -> void:
	Game.clues.clear()
	Game.flags.clear()

	var s1 := Game.gate_rule("leave_annex")
	Game.set_flag("annex_door_open", true)
	_check(s1.is_met(), "annex -> street once switches thrown")
	Game.flags.clear()

	var s2 := Game.gate_rule("enter_lair")
	Game.set_flag("villain_door_open", true)
	_check(s2.is_met(), "street -> lair once suspects questioned")
	Game.flags.clear()

	var s3 := Game.gate_rule("enter_facility")
	Game.set_flag("lair_door_open", true)
	_check(s3.is_met(), "lair -> facility once Marlow named")
	Game.flags.clear()

	var s4 := Game.gate_rule("enter_switch")
	Game.set_flag("control_door_open", true)
	_check(s4.is_met(), "facility -> switch once the tape is read")
	Game.flags.clear()

	_check(Game.clues.is_empty(), "flag probes granted no clues")

	var v := Game.gate_rule("to_villain_lair")
	_check(not v.is_met(), "villain gate shut with no evidence")
	Game.add_clue("S-01")
	_check(not v.is_met(), "villain gate still shut on one clue")
	Game.add_clue("S-04")
	_check(v.is_met(), "villain gate opens on both")

	var f := Game.gate_rule("to_facility")
	Game.add_clue("V-02")
	_check(not f.is_met(), "facility gate shut on one stamp")
	Game.add_clue("V-03")
	_check(f.is_met(), "facility gate opens on both stamps")

	var t := Game.gate_rule("to_switch")
	_check(not t.is_met(), "switch gate shut before the tape")
	Game.add_clue("F-04")
	_check(t.is_met(), "switch gate opens on the tape")

func _test_levels_instantiate() -> void:
	for l in _levels:
		var n: Node = load(l).instantiate()
		add_child(n)
		await get_tree().process_frame
		var players := 0
		var hud := false
		var runner := false
		var nb := false
		for c in n.get_children():
			if c is Player:
				players += 1
			if c is Hud:
				hud = true
			if c is DialogueRunner:
				runner = true
			if c is Notebook:
				nb = true
		_check(players == 1, l.get_file() + " has exactly one player")
		_check(hud, l.get_file() + " builds a HUD")
		_check(runner, l.get_file() + " builds a dialogue runner")
		_check(nb, l.get_file() + " builds a notebook")
		n.queue_free()
		await get_tree().process_frame

func _test_ending_fires() -> void:
	var hud := Hud.new()
	add_child(hud)
	_check(hud.has_method("show_finale"), "HUD can show the finale")
	_check(Game.hud == hud, "HUD registered as the global one")

	hud.show_finale()
	await get_tree().process_frame
	await get_tree().process_frame
	var found := false
	for c in hud.get_children():
		if c is Control:
			found = true
	_check(found, "finale overlay actually renders")

	Game.closed_case = false
	_check(await notebook_has_hook(), "notebook exposes the case-closed hook")

	hud.queue_free()

func notebook_has_hook() -> bool:
	var n := Notebook.new()
	add_child(n)
	await get_tree().process_frame
	var has := n.has_method("_on_case_closed")
	n.queue_free()
	return has

func _check(cond: bool, label: String) -> void:
	_out.append(("PASS  " if cond else "FAIL  ") + label)
	if not cond:
		_fail += 1

func _finish() -> void:
	for r in _out:
		print(r)
	print("---")
	print("CHAIN: " + ("ALL PASS" if _fail == 0 else str(_fail) + " FAILED"))
	get_tree().quit(0 if _fail == 0 else 1)