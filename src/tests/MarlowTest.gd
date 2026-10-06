extends Node

var _fail := 0
var _out: Array[String] = []
var _level: Node
var _marlow: Speaker
var _counter: BeamReceiver

func _ready() -> void:
	Game.add_clue("S-04")
	Game.add_clue("S-03")

	_level = load("res://src/levels/L3_VillainLair.tscn").instantiate()
	add_child(_level)
	await get_tree().process_frame
	await get_tree().process_frame

	for c in _level.get_children():
		if c is Speaker:
			_marlow = c as Speaker
		if c is BeamReceiver:
			_counter = c as BeamReceiver

	_check(_marlow != null, "Marlow placed")
	_check(_counter != null, "counter receiver placed")
	if _marlow == null or _counter == null:
		_finish()
		return

	_check(_marlow.states_total() == 4, "Marlow has four states")

	await _ask(_marlow)
	_check(_marlow.remaining() == 3, "first state consumed")
	_check(not Game.has_clue("V-01"), "nothing granted yet")

	await _ask(_marlow)
	_check(Game.has_clue("V-01"), "four-second confession recorded")
	_check(not _marlow.can_interact(), "state three waits on the counter")

	_check(_counter.armed, "counter readable immediately")
	_check(not _counter.is_revealed, "counter starts unread")

	_counter.receive(1.0, 1.2)
	_check(_counter.is_revealed, "holding the counter reveals it")
	_check(Game.has_clue("V-02"), "counter grants V-02")

	_check(_marlow.can_interact(), "Marlow unlocks once V-02 is held")
	await _ask(_marlow)
	_check(_marlow.can_interact(), "Marlow has one more thing to say with the counter in hand")

	await _ask(_marlow)
	_check(Game.has_clue("V-03"), "Marlow names the signer, granting V-03")

	var g := Game.gate_rule("to_facility")
	_check(g.is_met(), "V-02 + V-03 open the Sun Facility")
	_check(Game.gate_open("to_facility"), "gate_open true after Marlow")

	_finish()

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
	print("MARLOW: " + ("ALL PASS" if _fail == 0 else str(_fail) + " FAILED"))
	get_tree().quit(0 if _fail == 0 else 1)