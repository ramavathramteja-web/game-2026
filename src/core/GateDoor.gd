class_name GateDoor
extends Interactable

signal opened

@export var gate_id: String = "to_suspect_street"
@export var door_size: Vector3 = Vector3(1.1, 2.2, 0.18)
@export var slide_axis: Vector3 = Vector3(0, 1, 0)
@export var slide_distance: float = 2.3

var rule: GateRule
var is_open: bool = false

var _slab: Node3D
var _seal: MeshInstance3D
var _seal_mat: StandardMaterial3D
var _frame: Node3D
var _cs: CollisionShape3D

func _ready() -> void:
	super._ready()
	rule = Game.gate_rule(gate_id)
	one_shot = false
	interact_range = 2.8
	prompt = "Locked"
	if rule == null:
		set_enabled(false)
		return
	_build()

func _build() -> void:
	var bm := BoxMesh.new()
	bm.size = door_size
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color("2b3038")
	mat.roughness = 0.9
	bm.material = mat

	_slab = Node3D.new()
	add_child(_slab)

	var slab := MeshInstance3D.new()
	slab.mesh = bm
	_slab.add_child(slab)

	_seal_mat = StandardMaterial3D.new()
	_seal_mat.albedo_color = Color("ffb968")
	_seal_mat.emission_enabled = true
	_seal_mat.emission = Color("ffb968")
	_seal_mat.emission_energy_multiplier = 1.2

	var sm := QuadMesh.new()
	sm.size = Vector2(door_size.x * 0.42, door_size.y * 0.42)
	sm.material = _seal_mat
	_seal = MeshInstance3D.new()
	_seal.mesh = sm
	_seal.position = Vector3(0, 0, door_size.z * 0.5 + 0.01)
	_slab.add_child(_seal)

	_cs = CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = door_size
	_cs.shape = bs
	add_child(_cs)

	_refresh()

func _process(_delta: float) -> void:
	if rule == null or is_open:
		return
	var met := rule.is_met()
	if met != _met_cached:
		_met_cached = met
		_refresh()

var _met_cached: bool = false

func _refresh() -> void:
	_met_cached = rule != null and rule.is_met()
	if _met_cached:
		prompt = "Open the door"
		if _seal_mat != null:
			_seal_mat.albedo_color = Color("d9f2a8")
			_seal_mat.emission = Color("d9f2a8")
	else:
		prompt = "Locked  " + rule.progress()
		if _seal_mat != null:
			_seal_mat.albedo_color = Color("ffb968")
			_seal_mat.emission = Color("ffb968")

func focus_text() -> String:
	if is_open:
		return "Open"
	return prompt

func can_interact() -> bool:
	return rule != null and not is_open

func interact(who: Node) -> void:
	if is_open:
		return
	if not rule.is_met():
		Game.hint.emit(rule.blocked_line)
		return
	if rule.open_line != "":
		Game.hint.emit(rule.open_line)
	_open()

func _open() -> void:
	is_open = true
	opened.emit()
	if _cs != null:
		_cs.set_deferred("disabled", true)
	var tw := create_tween()
	tw.tween_property(_slab, "position",
		slide_axis.normalized() * slide_distance, 1.1)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	if _seal != null:
		var tw2 := create_tween()
		tw2.tween_property(_seal_mat, "emission_energy_multiplier", 0.0, 0.5)
		tw2.parallel().tween_property(_seal_mat, "albedo_color", Color(1, 1, 1, 0), 0.5)