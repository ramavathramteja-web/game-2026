extends SceneTree

var _test: Node
var _frames: int = 0

func _initialize() -> void:
	_test = load("res://src/tests/InteractTest.tscn").instantiate()
	root.add_child(_test)

func _process(_delta: float) -> bool:
	_frames += 1
	if _frames > 600:
		print("INTERACT: TIMEOUT after " + str(_frames) + " frames")
		return true
	return false
