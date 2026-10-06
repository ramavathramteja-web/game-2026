extends Node

var _fail := 0
var _out: Array[String] = []

func _ready() -> void:
	var level: Node = load("res://src/levels/L2_SuspectStreet.tscn").instantiate()
	add_child(level)
	await get_tree().process_frame
	await get_tree().process_frame

	var player: Player = null
	var sky: Array[Speaker] = []
	for c in level.get_children():
		if c is Player:
			player = c as Player
		if c is Speaker and (c as Speaker).sky_facing:
			sky.append(c as Speaker)

	_check(player != null, "player present")
	_check(sky.size() == 2, "two sky speakers (Moon and Clouds)")
	if player == null or sky.is_empty():
		_finish()
		return

	var cam := player.camera()
	var eye := cam.global_position
	var far_plane := cam.far
	var margin := 1.25

	_check(far_plane > 100.0, "camera far plane reaches the sky (" + str(far_plane) + "m)")

	var env_node := level.get_node_or_null("WorldEnvironment")
	_check(env_node != null, "WorldEnvironment present")

	for sp in sky:
		var d := eye.distance_to(sp.global_position)
		var label := sp.speaker_name
		_check(d < far_plane * margin,
			label + " inside the far plane (" + str(snappedf(d, 1.0)) + "m < " + str(far_plane) + "m)")
		_check(d < sp.interact_range,
			label + " inside its own interact range")
		_check(sp.global_position.y > 20.0,
			label + " is actually in the sky, not the room (y=" + str(snappedf(sp.global_position.y, 1.0)) + ")")
		_check(_has_visual(sp), label + " has a mesh attached")

	var moon: Speaker = null
	var clouds: Speaker = null
	for sp in sky:
		if sp.speaker_name == "THE MOON":
			moon = sp
		if sp.speaker_name == "THE CLOUDS":
			clouds = sp

	if moon != null and clouds != null:
		_check(moon.global_position.y < clouds.global_position.y,
			"Clouds sit above the Moon")
		_check((moon.global_position - player.global_position).length() > 40.0,
			"Moon is distant, not a prop")

	_finish()

func _has_visual(sp: Speaker) -> bool:
	for c in sp.get_children():
		if c is MeshInstance3D:
			return true
	return false

func _check(cond: bool, label: String) -> void:
	_out.append(("PASS  " if cond else "FAIL  ") + label)
	if not cond:
		_fail += 1

func _finish() -> void:
	for r in _out:
		print(r)
	print("---")
	print("SKY: " + ("ALL PASS" if _fail == 0 else str(_fail) + " FAILED"))
	get_tree().quit(0 if _fail == 0 else 1)