extends Control

## Title card for THE MISSING SUN.
const START_SCENE := "res://src/levels/L1_DarkCity.tscn"

const FONT_TITLE := preload("res://assets/Cinzel.tres")
const FONT_BODY := preload("res://assets/Outfit.tres")

const GOLD := Color("ffc98a")
const WARM := Color("ffb968")
const INK := Color("f5f7fa")
const MUTED := Color("8fa0b8")
const FAINT := Color("546274")
const BG := Color("030509")

var _prompt_btn: Button = null
var _t := 0.0
var _armed := false

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build()

func _build() -> void:
	var bg := ColorRect.new()
	bg.color = BG
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	var center := VBoxContainer.new()
	center.set_anchors_preset(Control.PRESET_CENTER)
	center.custom_minimum_size = Vector2(860, 0)
	center.offset_left = -430
	center.offset_right = 430
	center.offset_top = -280
	center.offset_bottom = 280
	center.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_theme_constant_override("separation", 14)
	add_child(center)

	# Eyebrow tag
	var eyebrow := Label.new()
	eyebrow.text = "—  A FIRST-PERSON MYSTERY  —"
	eyebrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	eyebrow.add_theme_font_override("font", FONT_TITLE)
	eyebrow.add_theme_font_size_override("font_size", 13)
	eyebrow.add_theme_color_override("font_color", Color("d9a76a"))
	center.add_child(eyebrow)

	# Main Title
	var title := Label.new()
	title.text = "THE MISSING SUN"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_override("font", FONT_TITLE)
	title.add_theme_font_size_override("font_size", 60)
	title.add_theme_color_override("font_color", INK)
	title.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	title.add_theme_constant_override("shadow_offset_x", 0)
	title.add_theme_constant_override("shadow_offset_y", 4)
	center.add_child(title)

	# Subtitle / Time stamp
	var sub := Label.new()
	sub.text = "9 : 1 4 : 0 0   —   The Sun stopped, and you did it."
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_font_override("font", FONT_BODY)
	sub.add_theme_font_size_override("font_size", 20)
	sub.add_theme_color_override("font_color", GOLD)
	center.add_child(sub)

	# Divider line with center glow
	var div := HBoxContainer.new()
	div.alignment = BoxContainer.ALIGNMENT_CENTER
	div.custom_minimum_size = Vector2(0, 16)
	var line_l := ColorRect.new()
	line_l.custom_minimum_size = Vector2(160, 1)
	line_l.color = Color("ffb968", 0.3)
	div.add_child(line_l)
	var dot := ColorRect.new()
	dot.custom_minimum_size = Vector2(6, 6)
	dot.color = GOLD
	div.add_child(dot)
	var line_r := ColorRect.new()
	line_r.custom_minimum_size = Vector2(160, 1)
	line_r.color = Color("ffb968", 0.3)
	div.add_child(line_r)
	center.add_child(div)

	# Controls card (Glassmorphic panel)
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(680, 0)
	card.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.04, 0.06, 0.1, 0.72)
	sb.border_color = Color(1.0, 0.76, 0.44, 0.22)
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(8)
	sb.content_margin_left = 28
	sb.content_margin_right = 28
	sb.content_margin_top = 18
	sb.content_margin_bottom = 18
	card.add_theme_stylebox_override("panel", sb)
	center.add_child(card)

	var card_col := VBoxContainer.new()
	card_col.add_theme_constant_override("separation", 10)
	card.add_child(card_col)

	var card_head := Label.new()
	card_head.text = "DETECTIVE MANUAL · CONTROLS"
	card_head.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	card_head.add_theme_font_override("font", FONT_TITLE)
	card_head.add_theme_font_size_override("font_size", 12)
	card_head.add_theme_color_override("font_color", WARM)
	card_col.add_child(card_head)

	var ctrl_row1 := Label.new()
	ctrl_row1.text = "[ W A S D ]  Move       ·       [ MOUSE ]  Look"
	ctrl_row1.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ctrl_row1.add_theme_font_override("font", FONT_BODY)
	ctrl_row1.add_theme_font_size_override("font_size", 16)
	ctrl_row1.add_theme_color_override("font_color", INK)
	card_col.add_child(ctrl_row1)

	var ctrl_row2 := Label.new()
	ctrl_row2.text = "[ E ]  Interact / Hold Beam       ·       [ F ]  Flashlight"
	ctrl_row2.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ctrl_row2.add_theme_font_override("font", FONT_BODY)
	ctrl_row2.add_theme_font_size_override("font_size", 16)
	ctrl_row2.add_theme_color_override("font_color", INK)
	card_col.add_child(ctrl_row2)

	var ctrl_row3 := Label.new()
	ctrl_row3.text = "[ TAB ]  Case Notebook       ·       [ ESC ]  Release Mouse"
	ctrl_row3.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ctrl_row3.add_theme_font_override("font", FONT_BODY)
	ctrl_row3.add_theme_font_size_override("font_size", 16)
	ctrl_row3.add_theme_color_override("font_color", INK)
	card_col.add_child(ctrl_row3)

	# Narrative tagline
	var tag := Label.new()
	tag.text = "Ten minutes. Six suspects. Every one of them is telling the truth."
	tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tag.add_theme_font_override("font", FONT_BODY)
	tag.add_theme_font_size_override("font_size", 16)
	tag.add_theme_color_override("font_color", MUTED)
	center.add_child(tag)

	# Spacer
	var sp := Control.new()
	sp.custom_minimum_size = Vector2(0, 10)
	center.add_child(sp)

	# Prompt button
	_prompt_btn = Button.new()
	_prompt_btn.text = "P R E S S   E   T O   B E G I N"
	_prompt_btn.custom_minimum_size = Vector2(340, 50)
	_prompt_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_prompt_btn.add_theme_font_override("font", FONT_TITLE)
	_prompt_btn.add_theme_font_size_override("font_size", 18)
	_prompt_btn.add_theme_color_override("font_color", GOLD)
	_prompt_btn.add_theme_color_override("font_hover_color", INK)
	var btn_sb := StyleBoxFlat.new()
	btn_sb.bg_color = Color(0.12, 0.09, 0.05, 0.8)
	btn_sb.border_color = GOLD
	btn_sb.set_border_width_all(2)
	btn_sb.set_corner_radius_all(25)
	_prompt_btn.add_theme_stylebox_override("normal", btn_sb)
	var btn_hover := StyleBoxFlat.new()
	btn_hover.bg_color = Color(0.24, 0.17, 0.08, 0.95)
	btn_hover.border_color = INK
	btn_hover.set_border_width_all(2)
	btn_hover.set_corner_radius_all(25)
	_prompt_btn.add_theme_stylebox_override("hover", btn_hover)
	_prompt_btn.pressed.connect(_start)
	center.add_child(_prompt_btn)

func _process(delta: float) -> void:
	_t += delta
	if not _armed and _t > 0.6:
		_armed = true
	if _prompt_btn != null:
		_prompt_btn.modulate.a = 0.70 + 0.30 * sin(_t * 2.8)

func _unhandled_input(event: InputEvent) -> void:
	if not _armed:
		return
	var go := false
	if event is InputEventKey and event.pressed and not event.echo:
		var k := event as InputEventKey
		if k.keycode == KEY_ESCAPE:
			get_tree().quit()
			return
		go = k.keycode in [KEY_E, KEY_ENTER, KEY_SPACE, KEY_KP_ENTER]

	if go:
		_start()

func _start() -> void:
	Snd.sfx("torch", -2.0)
	Snd.unlock_audio()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().change_scene_to_file(START_SCENE)