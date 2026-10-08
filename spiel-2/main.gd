extends Node2D


func _ready() -> void:
	$Button.pressed.connect(_on_custom_button_clicked)


func _on_custom_button_clicked() -> void:
	print("Event via Code")


func _process(delta: float) -> void:
	pass
