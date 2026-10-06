class_name LogProp
extends Interactable

@export var clue_id: String = "I-04"
@export var body_text: String = "Twelve pages and the twelfth is a lovely clean nothing. Somebody's idea of a joke."

var _book: MeshInstance3D

func _ready() -> void:
	super._ready()
	prompt = "Read the logbook"
	interact_range = 2.2
	_build()

func _build() -> void:
	_collide(Vector3(0.7, 0.06, 0.5))

	var bm := BoxMesh.new()
	bm.size = Vector3(0.62, 0.07, 0.44)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color("d8d2c4")
	mat.roughness = 0.85
	bm.material = mat

	_book = MeshInstance3D.new()
	_book.mesh = bm
	add_child(_book)

	var pages := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(0.56, 0.38)
	pages.mesh = pm
	pages.position = Vector3(0, 0.036, 0)
	var pmat := StandardMaterial3D.new()
	pmat.albedo_color = Color("efe9dc")
	pmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	pm.material = pmat
	add_child(pages)

func _collide(size: Vector3) -> void:
	var cs := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = size
	cs.shape = bs
	add_child(cs)

func focus_text() -> String:
	return "Read the logbook"

func can_interact() -> bool:
	return true

func interact(_who: Node) -> void:
	already_used = true
	used.emit(_who)
	var tw := create_tween()
	tw.tween_property(_book, "rotation:y", deg_to_rad(6.0), 0.4)\
		.set_trans(Tween.TRANS_SINE)