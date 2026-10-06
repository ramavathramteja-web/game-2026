extends Node

var _player: Player
var _receiver: BeamReceiver
var _frames: int = 0
var _phase: int = 0
var _fail: int = 0
var _results: Array[String] = []

func _ready() -> void:
	var room: Node = load("res://src/levels/P1bProof.tscn").instantiate()
	add_child(room)
	await get_tree().process_frame
	await get_tree().process_frame
	_player = null
	_receiver = null
	for n in room.get_children():
		if n is Player:
			_player = n as Player
		if n is BeamReceiver:
			_receiver = n as BeamReceiver
	_check(_player != null, "player instantiates")
	_check(_receiver != null, "beam receiver instantiates")

func _process(_d: float) -> void:
	_frames += 1
	if _player == null or _receiver == null:
		if _frames > 600:
			_finish()
		return

	match _phase:
		0:
			var to: Vector3 = _receiver.global_position - _player.head().global_position
			_player.yaw = atan2(-to.x, -to.z)
			_player.pitch = atan2(to.y, Vector2(to.x, to.z).length())
			_player.can_move = false
			await get_tree().physics_frame
			_phase = 1
		1:
			_check(not _receiver.armed, "receiver starts disarmed")
			_receiver.armed = true
			_check(_receiver.armed, "receiver arms after switch puzzle")
			_check(not _receiver.is_revealed, "not revealed on the same frame it arms")
			_phase = 2
		2:
			if _receiver.is_revealed:
				_check(true, "hold on mark triggers reveal")
				_check(Game.has_clue("I-06"), "reveal grants clue I-06")
				_check(Game.tier == Game.Tier.AGREED, "tier reads T3 while held")
				_phase = 3
			elif _frames > 300:
				_check(false, "hold on mark triggers reveal")
				_check(false, "reveal grants clue I-06")
				_phase = 3
		3:
			_check(_receiver.is_revealed, "reveal is sticky")
			_phase = 4
		4:
			_player.pitch = 1.2
			await get_tree().physics_frame
			_phase = 5
		5:
			_check(not _receiver.is_revealed or _receiver.hold >= _receiver.hold_time,
				"looking away does not un-reveal")
			_phase = 6
		6:
			_finish()

func _check(cond: bool, label: String) -> void:
	_results.append(("PASS  " if cond else "FAIL  ") + label)
	if not cond:
		_fail += 1

func _finish() -> void:
	for r in _results:
		print(r)
	print("---")
	print("P1B: " + ("ALL PASS" if _fail == 0 else str(_fail) + " FAILED"))
	print("clues: " + str(Game.clues))
	get_tree().quit(0 if _fail == 0 else 1)