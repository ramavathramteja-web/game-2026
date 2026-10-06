class_name Speaker
extends Interactable

@export var speaker_name: String = "THE MOON"
@export var states: Array[Dictionary] = []
@export var sky_facing: bool = false
@export var view_angle_deg: float = 14.0

var _index: int = 0

func _ready() -> void:
	super._ready()
	prompt = "Question " + speaker_name
	interact_range = 3.0 if not sky_facing else 220.0
	if sky_facing:
		add_to_group("sky_speaker")

func states_total() -> int:
	return states.size()

func remaining() -> int:
	return maxi(0, states.size() - _index)

func _next_askable() -> int:
	for i in range(_index, states.size()):
		if _met(states[i]):
			return i
	return -1

func _met(s: Dictionary) -> bool:
	for c in s.get("requires", []):
		if not Game.has_clue(String(c)):
			return false
	for f in s.get("require_flags", []):
		if not bool(Game.get_flag(String(f))):
			return false
	return true

func focus_text() -> String:
	if _next_askable() == -1:
		return "Nothing more to ask " + speaker_name
	return prompt

func can_interact() -> bool:
	return _next_askable() != -1

func interact(who: Node) -> void:
	var i := _next_askable()
	if i == -1:
		Game.hint.emit("I've got nothing left for " + speaker_name + ".")
		return

	var state := states[i]
	_index = i + 1

	for c in state.get("grants", []):
		Game.add_clue(String(c))

	var hud := Game.hud
	if Game.runner != null:
		Game.runner.play(_lines_of(state))
		return
	if hud != null and hud.has_method("play_script"):
		hud.call("play_script", _lines_of(state))
	else:
		for line in _lines_of(state):
			Game.hint.emit(String(line.get("s", "")))

func _lines_of(state: Dictionary) -> Array:
	var out: Array = []
	for l in state.get("lines", []):
		var d := {"t": l.get("t", "say"), "s": l.get("s", ""), "who": l.get("who", speaker_name)}
		out.append(d)
	return out