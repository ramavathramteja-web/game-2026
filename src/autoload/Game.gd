extends Node

signal tier_changed(tier: int)
signal clue_found(clue_id: String)
signal beat_advanced(beat: int)
signal hint(text: String)
signal tape_requested(text: String)

enum Tier { MOON, BEAM, AGREED }

const TIERS := {
	Tier.MOON: { "label": "T1", "name": "MOONLIGHT", "color": Color("9db4d6") },
	Tier.BEAM: { "label": "T2", "name": "BEAM", "color": Color("ffb968") },
	Tier.AGREED: { "label": "T3", "name": "AGREED BEAM", "color": Color("d9f2a8") },
}

var tier: int = Tier.BEAM
var torch_on: bool = true
var beat: int = 1
var clues: Array[String] = []
var contradictions: Dictionary = {}
var flags: Dictionary = {}
var closed_case: bool = false
var hud: Node = null
var runner: Node = null

const CLUE_META := {
	"I-01": { "title": "Every clock reads 9:14:00", "beat": 1, "tag": "TIME" },
	"I-04": { "title": "Page twelve, signed by Ray", "beat": 1, "tag": "LOGBOOK" },
	"I-05": { "title": "The mirror, already angled", "beat": 1, "tag": "SCENE" },
	"I-06": { "title": "9:14, written on the wall", "beat": 1, "tag": "SUNWRITING" },
	"D-02": { "title": "A bulb that blew outward", "beat": 2, "tag": "PHYSICAL" },
	"S-01": { "title": "Every shadow swung east", "beat": 3, "tag": "TESTIMONY" },
	"S-03": { "title": "A photograph, burnt into bread", "beat": 3, "tag": "PHYSICAL" },
	"S-04": { "title": "The old pale slice", "beat": 3, "tag": "PHYSICAL" },
	"V-02": { "title": "The counter reads 2", "beat": 4, "tag": "COUNTER" },
	"V-03": { "title": "TECH 4 / MARLOW and CD-19", "beat": 4, "tag": "SIGNATURE" },
	"N-01": { "title": "Four numbered shapes", "beat": 5, "tag": "GLYPHS" },
	"F-01": { "title": "9:13:41", "beat": 6, "tag": "TIMESTAMP" },
	"F-03": { "title": "Counter 2, CD-19, a fresh thumbprint", "beat": 6, "tag": "PHYSICAL" },
	"F-04": { "title": "The access log tape", "beat": 6, "tag": "DOCUMENT" },
	"F-05": { "title": "Log Entry 914, line twelve", "beat": 7, "tag": "WITHHELD" },
	"Z-01": { "title": "Custody Transfer", "beat": 7, "tag": "RULE" },
	"Z-02": { "title": "The rest of the wall", "beat": 7, "tag": "SUNWRITING" },
}

func set_flag(name: String, value: Variant = true) -> void:
	flags[name] = value

func get_flag(name: String, fallback: Variant = false) -> Variant:
	return flags.get(name, fallback)

func clue_title(id: String) -> String:
	var meta: Dictionary = CLUE_META.get(id, {})
	return String(meta.get("title", id))

const GATE_DEFS := {
	"enter_facility": {
		"clues": [],
		"flags": ["lair_door_open"],
		"to_scene": "res://src/levels/L4_SunFacility.tscn",
		"blocked": "Not yet.",
		"open": "",
	},
	"enter_switch": {
		"clues": [],
		"flags": ["control_door_open"],
		"to_scene": "res://src/levels/L5_TheSwitch.tscn",
		"blocked": "Not yet.",
		"open": "",
	},
	"enter_lair": {
		"clues": [],
		"flags": ["villain_door_open"],
		"to_scene": "res://src/levels/L3_VillainLair.tscn",
		"blocked": "Not yet.",
		"open": "",
	},
	"leave_annex": {
		"clues": [],
		"flags": ["annex_door_open"],
		"to_scene": "res://src/levels/L2_SuspectStreet.tscn",
		"blocked": "Not yet.",
		"open": "",
	},
	"to_suspect_street": {
		"clues": ["I-06"],
		"flags": [],
		"to_scene": "res://src/levels/L2_SuspectStreet.tscn",
		"blocked": "The street door won't move. The sign says the inner rooms are still powered. Something in here has to be holding the light on.",
		"open": "Right. Whatever's in here is lit. That's a start.",
	},
	"to_villain_lair": {
		"clues": ["S-01", "S-04"],
		"flags": [],
		"to_scene": "res://src/levels/L3_VillainLair.tscn",
		"blocked": "Not yet. I've got a direction but I've got nothing under it. There's more to ask.",
		"open": "A direction, an old slice, and a man who won't finish his sentence. That's enough to walk on.",
	},
	"to_facility": {
		"clues": ["V-02", "V-03"],
		"flags": [],
		"to_scene": "res://src/levels/L4_SunFacility.tscn",
		"blocked": "Two events and a badge number. I've not got both halves of that yet.",
		"open": "Two events. One signature. And the second one is fresh.",
	},
	"to_switch": {
		"clues": ["F-04"],
		"flags": [],
		"to_scene": "res://src/levels/L5_TheSwitch.tscn",
		"blocked": "I know what happened now. I don't know how to undo it. There's a room back through the Annex.",
		"open": "It's all in one room. It was always going to be in one room.",
	},
}

var _rules: Dictionary = {}
const GateRule := preload("res://src/core/GateRule.gd")

func gate_rule(id: String) -> GateRule:
	if _rules.has(id):
		return _rules[id]
	var def: Dictionary = GATE_DEFS.get(id, {})
	if def.is_empty():
		push_warning("unknown gate: " + id)
		return null
	var r := GateRule.new()
	r.id = id
	for c in def.get("clues", []):
		r.requires_clues.append(String(c))
	for f in def.get("flags", []):
		r.requires_flags.append(String(f))
	r.to_scene = String(def.get("to_scene", ""))
	r.blocked_line = String(def.get("blocked", "That won't move yet."))
	r.open_line = String(def.get("open", ""))
	_rules[id] = r
	return r

func gate_open(id: String) -> bool:
	var r := gate_rule(id)
	return r != null and r.is_met()

func _ready() -> void:
	_setup_input()
	randomize()
	if "--p1b" in OS.get_cmdline_user_args():
		call_deferred("_run_p1b")

func _run_p1b() -> void:
	get_tree().change_scene_to_file("res://src/tests/P1bTest.tscn")

func _setup_input() -> void:
	var map := {
		"move_forward": KEY_W,
		"move_back": KEY_S,
		"move_left": KEY_A,
		"move_right": KEY_D,
		"torch": KEY_F,
		"interact": KEY_E,
		"notebook": KEY_TAB,
		"gallery": KEY_G,
	}
	for action in map.keys():
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		var ev := InputEventKey.new()
		ev.physical_keycode = map[action]
		InputMap.action_add_event(action, ev)

	if not InputMap.has_action("look_left"):
		InputMap.add_action("look_left")
	if not InputMap.has_action("look_right"):
		InputMap.add_action("look_right")
	for action in ["look_left", "look_right"]:
		var ev := InputEventMouseMotion.new()
		ev.button_mask = MOUSE_BUTTON_MASK_LEFT
		InputMap.action_add_event(action, ev)

func set_tier(next: int) -> void:
	if next == tier:
		return
	tier = next
	tier_changed.emit(tier)

func tier_info() -> Dictionary:
	return TIERS[tier]

func tier_color() -> Color:
	return TIERS[tier]["color"]

func add_clue(id: String) -> void:
	if clues.has(id):
		return
	clues.append(id)
	clue_found.emit(id)
	Snd.sfx("clue", -4.0)

func has_clue(id: String) -> bool:
	return clues.has(id)

func flag_contradiction(who: String) -> void:
	if contradictions.has(who):
		return
	contradictions[who] = true

func is_contradicted(who: String) -> bool:
	return contradictions.get(who, false)

func advance_beat() -> void:
	beat += 1
	beat_advanced.emit(beat)