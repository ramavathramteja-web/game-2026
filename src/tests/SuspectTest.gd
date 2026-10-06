extends Node

var _fail := 0
var _out: Array[String] = []
var _level: Node
var _player: Player
var _speakers: Dictionary = {}

func _ready() -> void:
	_level = load("res://src/levels/L2_SuspectStreet.tscn").instantiate()
	add_child(_level)
	await get_tree().process_frame
	await get_tree().process_frame

	_player = null
	for c in _level.get_children():
		if c is Player:
			_player = c as Player
		if c is Speaker:
			_speakers[(c as Speaker).name] = c as Speaker

	_check(_player != null, "player present")
	_check(_speakers.size() == 4, "four suspects placed")

	var moon := _sp("Speaker_MOON")
	var wick := _sp("Speaker_WICK")
	var sir := _sp("Speaker_SIR")
	var clouds := _sp("Speaker_CLOUDS")
	if moon == null or wick == null or sir == null or clouds == null:
		_finish()
		return

	_check(moon.states_total() == 3, "Moon has three states")
	_check(sir.states_total() == 2, "Sir has two states")
	_check(clouds.states_total() == 1, "Clouds has one state")

	await _ask(moon)
	_check(not Game.has_clue("S-01"), "Moon's first state grants nothing")
	await _ask(moon)
	_check(Game.has_clue("S-01"), "Moon grants S-01 (shadows east)")
	_check(not moon.can_interact(), "Moon's third state is gated on S-03")

	await _ask(wick)
	await _ask(wick)
	_check(not Game.has_clue("D-02"), "Wick withholds D-02 without S-03")

	await _ask(sir)
	_check(Game.has_clue("S-03"), "Sir grants S-03 (surge photo)")
	await _ask(sir)
	_check(Game.has_clue("S-04"), "Sir grants S-04 (old slice)")

	await _ask(wick)
	await _ask(wick)
	_check(Game.has_clue("D-02"), "Wick grants D-02 once S-03 is held")

	_check(moon.can_interact(), "Moon unlocks her third state once S-03 is held")
	await _ask(moon)
	_check(not moon.can_interact(), "Moon runs out of states")

	await _ask(clouds)
	_check(clouds.can_interact() == false, "Clouds has nothing more")

	var villain := Game.gate_rule("to_villain_lair")
	_check(villain.is_met(), "S-01 + S-04 unlock the villain lair")
	_check(Game.gate_open("to_villain_lair"), "gate_open true after questioning")

	_finish()

func _sp(n: String) -> Speaker:
	return _speakers.get(n, null)

func _ask(sp: Speaker) -> void:
	sp.interact(null)
	for i in 2:
		await get_tree().process_frame
	if Game.runner != null:
		Game.runner._queue.clear()
		Game.runner._running = false

func _check(cond: bool, label: String) -> void:
	_out.append(("PASS  " if cond else "FAIL  ") + label)
	if not cond:
		_fail += 1

func _finish() -> void:
	for r in _out:
		print(r)
	print("---")
	print("SUSPECTS: " + ("ALL PASS" if _fail == 0 else str(_fail) + " FAILED"))
	get_tree().quit(0 if _fail == 0 else 1)