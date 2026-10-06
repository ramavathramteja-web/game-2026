class_name Reticle
extends Control

var progress: float = 0.0
var tier: int = Game.Tier.BEAM
var tint: Color = Color("ffb968")

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(64, 64)
	size = custom_minimum_size

func _draw() -> void:
	var c := size * 0.5
	var r := minf(size.x, size.y) * 0.42

	draw_arc(c, r, 0.0, TAU, 48, Color(1, 1, 1, 0.13), 1.4, true)

	if progress > 0.001:
		draw_arc(c, r, -PI * 0.5, -PI * 0.5 + TAU * progress, 48, tint, 2.0, true)
		draw_arc(c, r + 5.0, 0.0, TAU, 48, Color(tint.r, tint.g, tint.b, 0.18), 1.0, true)

	var dot := 2.0 if tier != Game.Tier.AGREED else 3.2
	draw_circle(c, dot, tint)