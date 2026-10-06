class_name LightSwitch
extends Interactable

signal thrown(letter: String)

@export var letter: String = "A"
@export var clue_on_use: String = ""
@export var line_on_use: String = ""
@export var hud: Node = null

var is_thrown: bool = false
var consumed: bool = false
var _pivot: Node3D
var _mat: StandardMaterial3D

func _ready() -> void:
	super._ready()
	prompt = "Throw " + letter
	add_to_group("light_switch")
	_build()

func _build() -> void:
	# A real 1-gang plate is 86 x 86mm and sits at 1.2m. The original was a
	# 190x320 slab, which read as a floating box rather than a switch.
	var plate_mat := StandardMaterial3D.new()
	plate_mat.albedo_color = Color("6b7488")
	plate_mat.roughness = 0.5

	_pivot = Node3D.new()
	add_child(_pivot)

	var plate := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Room.PLATE
	plate.mesh = bm
	plate.material_override = plate_mat
	plate.position = Vector3(0.0, 0.0, 0.004)
	plate.name = "Plate"
	_pivot.add_child(plate)

	_mat = plate_mat

	# Rocker, raised on a shallow surround so the edge catches light.
	var surround := MeshInstance3D.new()
	var sm := BoxMesh.new()
	sm.size = Vector3(0.062, 0.062, 0.010)
	surround.mesh = sm
	surround.material_override = plate_mat
	surround.position = Vector3(0.0, 0.0, 0.011)
	_pivot.add_child(surround)

	var lever := MeshInstance3D.new()
	var lm := BoxMesh.new()
	lm.size = Vector3(0.050, 0.052, 0.014)
	lever.mesh = lm
	lever.material_override = plate_mat
	lever.position = Vector3(0.0, 0.0, 0.019)
	lever.name = "Rocker"
	_pivot.add_child(lever)

	# Fixing screws, top and bottom.
	var screw := StandardMaterial3D.new()
	screw.albedo_color = Color("8b8f98")
	screw.roughness = 0.35
	screw.metallic = 0.8
	for sy in [1.0, -1.0]:
		var s := MeshInstance3D.new()
		var sb := BoxMesh.new()
		sb.size = Vector3(0.008, 0.008, 0.004)
		s.mesh = sb
		s.material_override = screw
		s.position = Vector3(0.0, sy * 0.036, 0.007)
		_pivot.add_child(s)

	var cs := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = Vector3(0.30, 0.38, 0.22)
	cs.shape = bs
	add_child(cs)

func focus_text() -> String:
	return "Switch " + letter + " is thrown" if is_thrown else "Throw " + letter

func can_interact() -> bool:
	return not is_thrown

func interact(_who: Node) -> void:
	if is_thrown:
		return
	is_thrown = true
	Snd.sfx("switch", -3.0)
	_throw_animation()
	_mat.albedo_color = Color("ffb968")
	_mat.emission_enabled = true
	_mat.emission = Color("ffb968")
	_mat.emission_energy_multiplier = 1.4
	thrown.emit(letter)
	if clue_on_use != "":
		Game.add_clue(clue_on_use)
	if line_on_use != "" and hud != null and hud.has_method("say"):
		hud.call("say", "RAY", line_on_use)

func _throw_animation() -> void:
	if _pivot == null:
		return
	# A rocker snaps from one end to the other, it does not swing like a lever.
	var tw := create_tween()
	tw.tween_property(_pivot, "rotation:x", deg_to_rad(-14.0), 0.09)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(_pivot, "rotation:x", deg_to_rad(0.0), 0.14)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)