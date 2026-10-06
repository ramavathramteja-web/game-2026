class_name GateRule
extends Resource

@export var id: String = ""
@export var requires_clues: Array[String] = []
@export var requires_flags: Array[String] = []
@export var to_scene: String = ""
@export var blocked_line: String = "That won't move yet."
@export var open_line: String = ""

func is_met() -> bool:
	return missing().is_empty()

func missing() -> Array[String]:
	var out: Array[String] = []
	for c in requires_clues:
		if not Game.has_clue(c):
			out.append(c)
	for f in requires_flags:
		if not bool(Game.get_flag(f)):
			out.append(f)
	return out

func progress() -> String:
	var need := requires_clues.size() + requires_flags.size()
	var have := need - missing().size()
	return str(have) + " / " + str(need)