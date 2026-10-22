extends Area2D

signal hit

@export var speed: int = 400  # Pixel pro Sekunde
var screen_size: Vector2


func _ready() -> void:
	screen_size = get_viewport_rect().size
	hide()


func _process(delta: float) -> void:
	var velocity := Vector2.ZERO
	# Pfeiltasten ODER WASD
	if Input.is_action_pressed("ui_right") or Input.is_physical_key_pressed(KEY_D):
		velocity.x += 1
	if Input.is_action_pressed("ui_left") or Input.is_physical_key_pressed(KEY_A):
		velocity.x -= 1
	if Input.is_action_pressed("ui_down") or Input.is_physical_key_pressed(KEY_S):
		velocity.y += 1
	if Input.is_action_pressed("ui_up") or Input.is_physical_key_pressed(KEY_W):
		velocity.y -= 1

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$Sprite2D.rotation = velocity.angle() + PI / 2

	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)


func start(pos: Vector2) -> void:
	position = pos
	$Sprite2D.rotation = 0
	show()
	$CollisionShape2D.disabled = false


func _on_body_entered(_body: Node2D) -> void:
	hide()  # Spieler verschwindet nach Treffer
	hit.emit()
	# Deferred, weil wir mitten in einer Physik-Callback sind
	$CollisionShape2D.set_deferred("disabled", true)
