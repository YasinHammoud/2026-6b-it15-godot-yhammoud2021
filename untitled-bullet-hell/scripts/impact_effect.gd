extends Node2D

var tint := Color.WHITE
var intensity := 1.0
var age := 0.0
var lifetime := 0.24
var spark_directions: Array[Vector2] = []

func setup(effect_tint: Color, effect_intensity: float = 1.0) -> void:
	tint = effect_tint
	intensity = effect_intensity
	for index in range(8):
		var angle := TAU * float(index) / 8.0
		spark_directions.append(Vector2.RIGHT.rotated(angle))

func _process(delta: float) -> void:
	age += delta
	if age >= lifetime:
		queue_free()
		return
	queue_redraw()

func _draw() -> void:
	var progress := age / lifetime
	var ring_radius := lerpf(3.0, 20.0 * intensity, progress)
	var alpha := 1.0 - progress
	draw_arc(Vector2.ZERO, ring_radius, 0.0, TAU, 12, Color(tint, alpha), 2.0)
	draw_rect(Rect2(-2, -2, 4, 4), Color("#fff4d5", alpha))
	for direction in spark_directions:
		var start := direction * (4.0 + progress * 5.0) * intensity
		var finish := direction * (10.0 + progress * 10.0) * intensity
		draw_line(start, finish, Color(tint, alpha), 2.0)
