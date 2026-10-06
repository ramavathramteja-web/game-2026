class_name DialogueRunner
extends Node

signal finished
signal line_started(who: String, text: String)

var hud: Node = null
var _queue: Array = []
var _running: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func play(script: Array) -> void:
	if _running:
		return
	_queue = script.duplicate(true)
	_running = true
	_advance()

func is_running() -> bool:
	return _running

func _advance() -> void:
	if _queue.is_empty():
		_running = false
		finished.emit()
		return

	var step: Dictionary = _queue.pop_front()
	var kind: String = step.get("t", "thought")
	var text: String = step.get("s", "")
	var who: String = step.get("who", "RAY")

	line_started.emit(who, text)

	match kind:
		"thought":
			_think(text)
		"say":
			_say(who, text)
		"wait":
			await _wait(step.get("d", 1.0))
			_advance()
		"clue":
			Game.add_clue(text)
			await _wait(0.6)
			_advance()
		"objective":
			if hud != null and hud.has_method("set_objective"):
				hud.call("set_objective", text)
			_advance()
		"flag":
			Game.set_flag(text, step.get("v", true))
			_advance()
		"emit":
			_advance()

func _say(who: String, text: String) -> void:
	if hud == null or not hud.has_method("say"):
		await _wait(0.6 + text.length() * 0.02)
		_advance()
		return
	hud.call("say", who, text)
	await _wait(0.7 + text.length() * 0.045)
	_advance()

func _think(text: String) -> void:
	if hud != null and hud.has_method("think"):
		hud.call("think", text)
	await _wait(1.5 + text.length() * 0.035)
	_advance()

func _wait(seconds: float) -> void:
	await get_tree().create_timer(seconds, true, false, true).timeout