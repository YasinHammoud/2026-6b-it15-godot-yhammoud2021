extends RigidBody2D


func _ready() -> void:
	# Zufällige Farbvariante für etwas Abwechslung
	$Sprite2D.modulate = Color.from_hsv(randf(), 0.45, 1.0)


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
