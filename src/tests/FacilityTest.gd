extends Node

var _fail := 0
var _out: Array[String] = []
var _level: Node
var _lumen: Speaker
var _switch: BeamReceiver
var _tape: TapeProp
var _log: LogProp

func _ready() -> void:
	Game.add_clue("V-03")

	_level = load("res://src/levels/L4_SunFacility.tscn").instantiate()
	add_child(_level)
	await get_tree().process_frame
	await get_tree().process_frame

	var tape_requests: Array[String] = []
	Game.tape_requested.connect(func(t: String) -> void: tape_requests.append(t))

	for c in _level.get_children():
		if c is Speaker:
			_lumen = c as Speaker
		if c is BeamReceiver:
			_switch = c as BeamReceiver
		if c is TapeProp:
			_tape = c as TapeProp
		if c is LogProp:
			_log = c as LogProp

	_check(_lumen != null, "Lumen placed")
	_check(_switch != null, "Sun Control switch placed")
	_check(_tape != null, "access log tape placed")
	_check(_log != null, "log entry prop placed")
	if _lumen == null or _switch == null or _tape == null:
		_finish()
		return

	_check(_lumen.states_total() == 4, "Lumen has four states")
	_check(_lumen.can_interact(), "Lumen starts askable")
	_check(_switch.armed, "Sun Control switch is readable")

	await _ask(_lumen)
	_check(not Game.has_clue("F-01"), "Lumen's greeting grants nothing")
	await _ask(_lumen)
	_check(Game.has_clue("F-01"), "Lumen gives the timestamp 9:13:41")

	await _ask(_lumen)
	_check(Game.has_clue("F-02"), "Lumen answers once the badge number is held")
	_check(not _lumen.can_interact(), "final state still gated on the tape")

	_switch.receive(1.0, 1.4)
	_check(_switch.is_revealed, "holding the Sun Control switch reveals the stamps")
	_check(Game.has_clue("F-03"), "switch grants F-03")

	_tape.interact(null)
	await get_tree().process_frame
	_check(Game.has_clue("F-04"), "reading the tape grants F-04")
	_check(tape_requests.size() == 1, "tape overlay requested")
	_check(tape_requests[0].contains("HELLO, RAY"), "tape is addressed to Ray")
	_check(not _tape.can_interact(), "tape is one-shot")

	await _ask(_lumen)
	_check(true, "Lumen's thank-you beat is reachable after the tape")

	_log.interact(null)
	await get_tree().process_frame
	_check(Game.has_clue("F-05"), "line twelve can be found and stays black")

	var g := Game.gate_rule("to_switch")
	_check(g.is_met(), "F-04 opens the way to the Annex")
	_check(Game.gate_open("to_switch"), "gate_open true after the tape")

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
	print("FACILITY: " + ("ALL PASS" if _fail == 0 else str(_fail) + " FAILED"))
	get_tree().quit(0 if _fail == 0 else 1)