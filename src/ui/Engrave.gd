extends CanvasLayer

var _rect: ColorRect
var _mat: ShaderMaterial

func _ready() -> void:
	layer = 5
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build()
	get_viewport().size_changed.connect(_sync)

func _build() -> void:
	_rect = ColorRect.new()
	_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

	_mat = ShaderMaterial.new()
	_mat.shader = load("res://shaders/engrave.gdshader")
	_rect.material = _mat
	add_child(_rect)
	_sync()

func _sync() -> void:
	if _mat == null:
		return
	var s := get_viewport().get_visible_rect().size
	_mat.set_shader_parameter("resolution", Vector2(maxf(s.x, 1.0), maxf(s.y, 1.0)))

func set_param(name: String, value: Variant) -> void:
	if _mat != null:
		_mat.set_shader_parameter(name, value)

func enabled(on: bool) -> void:
	if _rect != null:
		_rect.visible = on