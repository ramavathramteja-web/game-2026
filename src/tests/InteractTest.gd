extends Node

var _fail := 0
var _out: Array[String] = []
var _level: Node
var _player: Player
var _sw_a: LightSwitch
var _sw_b: LightSwitch
var _sw_c: LightSwitch

func _ready() -> void:
	_level = load("res://src/levels/L1_DarkCity.tscn").instantiate()
	add_child(_level)
	await get_tree().process_frame
	await get_tree().process_frame

	_player = null
	var switches: Array[LightSwitch] = []
	for c in _level.get_children():
		if c is Player:
			_player = c as Player
		if c is LightSwitch:
			switches.append(c as LightSwitch)

	_check(_player != null, "player present")
	_check(switches.size() == 4, "four switches placed")
	if switches.size() < 4 or _player == null:
		_finish()
		return

	switches.sort_custom(_by_letter)
	_sw_a = switches[0]
	_sw_b = switches[1]
	_sw_c = switches[2]

	_check(_sw_a.letter == "A" and _sw_b.letter == "B", "letters assigned in order")
	_check(Game.hud != null, "HUD registered on Game")

	var reach := _player.camera().global_position.distance_to(_sw_a.global_position)
	_check(reach < 9.0, "switch A within ray range from spawn (" + str(snappedf(reach, 0.1)) + "m)")
	_check(_sw_a.interact_range >= 2.6, "switch interact range is sane")

	await _stand_near(_sw_a)
	_check(_player.focus == _sw_a, "looking at A focuses it")
	_check(_prompt() == "Throw A", "prompt shows the action")

	_player._try_interact()
	await get_tree().physics_frame
	_check(_sw_a.is_thrown, "E throws switch A")
	_check(_player.focus == null, "spent switch drops focus")
	_check(_prompt() == "", "prompt clears after use")

	await _stand_near(_sw_b)
	_check(_player.focus == _sw_b, "looking at B focuses it")
	_player._try_interact()
	await get_tree().physics_frame
	_check(_sw_b.is_thrown, "E throws switch B")
	_check(_receiver_armed(), "A and B arm the beam receiver")

	await _stand_near(_sw_c)
	_player._try_interact()
	await get_tree().physics_frame
	_check(_sw_c.is_thrown, "C throws too")
	_check(_player.focus == null, "spent switch drops focus again")

	await _stand_near(_sw_b)
	_player._try_interact()
	await get_tree().physics_frame
	_check(_sw_b.is_thrown, "re-pressing E on a thrown switch is harmless")

	_finish()

func _by_letter(a: LightSwitch, b: LightSwitch) -> bool:
	return a.letter < b.letter

func _receiver_armed() -> bool:
	for c in _level.get_children():
		if c is BeamReceiver:
			return (c as BeamReceiver).armed
	return false

func _stand_near(target: Node3D) -> void:
	# Stand on the floor beside the target rather than at a fixed height, so the
	# test does not break when interactables move to their real-world height.
	var back := Vector3(0, 0, 1).normalized()
	var spot := target.global_position + back * 1.7
	_player.global_position = Vector3(spot.x, 0.1, spot.z)
	_player.velocity = Vector3.ZERO
	_aim_at(target)
	for i in 3:
		await get_tree().process_frame

func _aim_at(target: Node3D) -> void:
	var to: Vector3 = target.global_position - _player.camera().global_position
	_player.yaw = atan2(-to.x, -to.z)
	_player.pitch = atan2(to.y, Vector2(to.x, to.z).length())

func _prompt() -> String:
	if Game.hud == null or not Game.hud.has_method("prompt_text"):
		return "<none>"
	return String(Game.hud.call("prompt_text"))

func _check(cond: bool, label: String) -> void:
	_out.append(("PASS  " if cond else "FAIL  ") + label)
	if not cond:
		_fail += 1

func _finish() -> void:
	for r in _out:
		print(r)
	print("---")
	print("INTERACT: " + ("ALL PASS" if _fail == 0 else str(_fail) + " FAILED"))
	get_tree().quit(0 if _fail == 0 else 1)