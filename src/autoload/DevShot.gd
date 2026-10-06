extends Node

const Player := preload("res://src/player/Player.gd")

var _frames: int = 0
var _warm: int = 0
var _active: bool = false
var _shots: int = 0
var _out_dir: String = "res://shots"
var _scene_arg: String = ""
var _label: String = "shot"
var _lock_yaw: float = 0.0
var _lock_pitch: float = 0.0
var _look_taken: bool = false
var _has_look: bool = false
var _torch_off: bool = false

func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	var raw := false
	for a in args:
		if a == "--noengrave":
			raw = true
		elif a.begins_with("--shot="):
			_active = true
			_label = a.substr(7)
		elif a.begins_with("--scene="):
			_scene_arg = a.substr(8)
		elif a.begins_with("--look="):
			_has_look = true
			var parts := a.substr(7).split(",")
			if parts.size() == 2:
				_lock_yaw = float(parts[0])
				_lock_pitch = float(parts[1])
		elif a == "--notorch":
			_torch_off = true
	if raw and Engrave != null:
		Engrave.enabled(false)
		print("ENGRAVE DISABLED")
	if not _active:
		return
	if _scene_arg != "":
		call_deferred("_go", _scene_arg)

func _go(scene: String) -> void:
	if ResourceLoader.exists(scene):
		get_tree().change_scene_to_file(scene)

func _process(_d: float) -> void:
	if not _active:
		return
	_frames += 1
	_lock_camera()
	if _warm < 60:
		if _torch_off:
			Game.torch_on = false
		_warm += 1
		return
	if _frames % 45 != 0:
		return

	var img := get_viewport().get_texture().get_image()
	if img == null:
		return

	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(_out_dir))
	var path := _out_dir + "/" + _label + ".png"
	var err := img.save_png(path)
	if err != OK:
		push_error("save failed " + str(err))
		return

	_shots += 1
	print("SHOT " + path + "  " + str(img.get_width()) + "x" + str(img.get_height()) + "  " + _cam_debug())
	if _shots >= 3:
		_active = false
		get_tree().quit(0)

func _lock_camera() -> void:
	for n in get_tree().get_nodes_in_group("player"):
		var p := n as Player
		if p == null or p.camera() == null:
			continue
		if not _look_taken:
			_look_taken = true
			if not _has_look:
				_lock_yaw = p.yaw
				_lock_pitch = p.pitch
		p.yaw = _lock_yaw
		p.pitch = _lock_pitch
		p.velocity = Vector3.ZERO
		return

func _cam_debug() -> String:
	for n in get_tree().get_nodes_in_group("player"):
		var p := n as Player
		if p == null or p.camera() == null:
			continue
		var c := p.camera()
		return "pos " + str(c.global_position.snapped(Vector3(0.01, 0.01, 0.01))) \
			+ "  yaw " + str(snappedf(p.yaw, 0.01)) \
			+ "  pitch " + str(snappedf(p.pitch, 0.01)) \
			+ "  vel " + str(p.velocity.snapped(Vector3(0.01, 0.01, 0.01)))
	return "no player"