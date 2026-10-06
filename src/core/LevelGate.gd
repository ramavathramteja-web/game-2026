class_name LevelGate
extends Area3D

@export var gate_id: String = "to_suspect_street"
@export var require_interact: bool = true
@export var label_text: String = "Go through"

var rule: GateRule

func _ready() -> void:
	monitoring = false
	rule = Game.gate_rule(gate_id)
	if rule != null and rule.to_scene != "" and not ResourceLoader.exists(rule.to_scene):
		push_warning("gate " + gate_id + " points at missing scene " + rule.to_scene)

func can_enter() -> bool:
	return rule != null and rule.is_met() and ResourceLoader.exists(rule.to_scene)

func missing() -> Array[String]:
	return rule.missing() if rule != null else []

func travel() -> bool:
	if not can_enter():
		return false
	var tree := get_tree()
	tree.change_scene_to_file(rule.to_scene)
	return true