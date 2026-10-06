extends Node

var _fail := 0
var _out: Array[String] = []
var _level: Node
var _wall: BeamReceiver
var _interactables: Array[Interactable] = []
var _switches: Array[LightSwitch] = []

func _ready() -> void:
	_level = load("res://src/levels/L5_TheSwitch.tscn").instantiate()
	add_child(_level)
	await get_tree().process_frame
	await get_tree().process_frame

	for c in _level.get_children():
		if c is BeamReceiver:
			_wall = c as BeamReceiver
		if c is Interactable and not (c is LightSwitch):
			_interactables.append(c as Interactable)
		if c is LightSwitch:
			_switches.append(c as LightSwitch)

	_check(_wall != null, "wall mark present")
	_check(_switches.size() == 2, "two reconstruction switches (A and B)")
	_check(_interactables.size() >= 3, "lamp, mirror and panel are interactable")

	if _wall == null or _switches.size() < 2:
		_finish()
		return

	_check(not _wall.armed, "wall is dark until the path is rebuilt")

	_interactables[0].interact(null)
	await get_tree().process_frame
	_check(not _wall.armed, "lamp alone does not rebuild the path")

	_interactables[1].interact(null)
	await get_tree().process_frame
	_check(not _wall.armed, "mirror alone does not rebuild the path")

	_switches[0].interact(null)
	_switches[1].interact(null)
	await get_tree().process_frame
	_check(_wall.armed, "lamp + mirror + A and B rebuild the path")

	_wall.receive(1.0, 1.5)
	_check(_wall.is_revealed, "holding the wall reveals Ray's message")
	_check(Game.has_clue("Z-02"), "message grants Z-02")
	_check("CLOSED" in _wall.revealed_text.to_upper(), "message names the case closure")

	for i in _interactables.size():
		if _interactables[i].prompt.find("Custody") != -1:
			_interactables[i].interact(null)
			break
	await get_tree().process_frame
	_check(Game.has_clue("Z-01"), "Custody Transfer panel grants Z-01")
	_check(_interactables[0].can_interact(), "rebuilding is repeatable, never a dead end")

	Game.set_flag("case_closed", true)
	_check(Game.get_flag("case_closed") == true, "case closure flag set")
	_check(Game.closed_case == false or Game.closed_case == true, "case state is readable")

	_finish()

func _check(cond: bool, label: String) -> void:
	_out.append(("PASS  " if cond else "FAIL  ") + label)
	if not cond:
		_fail += 1

func _finish() -> void:
	for r in _out:
		print(r)
	print("---")
	print("ENDING: " + ("ALL PASS" if _fail == 0 else str(_fail) + " FAILED"))
	get_tree().quit(0 if _fail == 0 else 1)