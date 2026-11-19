extends Node2D

var animation_time := 0.0

func _process(delta: float) -> void:
	animation_time += delta
	queue_redraw()

func _draw() -> void:
	var flicker := 0.8 + sin(animation_time * 10.0 + position.y) * 0.12
	draw_circle(Vector2.ZERO, 18.0, Color("#e27643", 0.10))
	draw_rect(Rect2(-7, -8, 14, 19), Color("#171923"))
	draw_rect(Rect2(-5, -6, 10, 15), Color("#61443d"))
	draw_rect(Rect2(-3, -12, 6, 8), Color("#f5a751", flicker))
	draw_rect(Rect2(-2, -15, 4, 6), Color("#fff1ac", flicker))
	draw_rect(Rect2(-1, -18, 2, 3), Color("#e9fff0", flicker))
