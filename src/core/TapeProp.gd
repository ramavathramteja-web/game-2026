class_name TapeProp
extends Interactable

@export var tape_text: String = ""
@export var clue_on_read: String = ""
@export var once: bool = true

var _read: bool = false
var _strip: MeshInstance3D

func _ready() -> void:
	super._ready()
	prompt = "Read the access log"
	interact_range = 2.4

	var bm := BoxMesh.new()
	bm.size = Vector3(0.9, 0.06, 0.28)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color("e2dccb")
	mat.roughness = 0.95
	bm.material = mat

	_strip = MeshInstance3D.new()
	_strip.mesh = bm
	add_child(_strip)

	var cs := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = Vector3(1.1, 0.3, 0.5)
	cs.shape = bs
	add_child(cs)

func focus_text() -> String:
	return "You already read it" if _read else "Read the access log"

func can_interact() -> bool:
	return not (once and _read)

func interact(_who: Node) -> void:
	_read = true
	if clue_on_read != "":
		Game.add_clue(clue_on_read)
	if tape_text != "":
		Game.tape_requested.emit(tape_text)