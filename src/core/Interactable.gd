class_name Interactable
extends StaticBody3D

signal used(who)

@export var prompt: String = "Examine"
@export var enabled: bool = true
@export var one_shot: bool = false
@export var interact_range: float = 2.6

var already_used: bool = false

func _ready() -> void:
	add_to_group("interactable")

func focus_text() -> String:
	return prompt

func can_interact() -> bool:
	if not enabled:
		return false
	if one_shot and already_used:
		return false
	return true

func interact(_who: Node) -> void:
	already_used = true
	used.emit(_who)

func set_enabled(v: bool) -> void:
	enabled = v