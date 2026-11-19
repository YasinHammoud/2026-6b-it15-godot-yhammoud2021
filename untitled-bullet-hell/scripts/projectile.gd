extends Area2D

var velocity := Vector2.ZERO
var damage := 10
var projectile_type := "enemy"
var radius := 5.0
var life := 4.0
var animation_time := 0.0
var special_effect := ""
var sprite: Sprite2D

func setup(direction: Vector2, speed: float, type: String = "enemy", projectile_damage: int = 10, effect: String = "") -> void:
	velocity = direction.normalized() * speed
	projectile_type = type
	damage = projectile_damage
	special_effect = effect
	if type == "player":
		radius = 9.0 if special_effect == "frost" else 4.5
		life = 2.2 if special_effect == "frost" else 2.0
	else:
		radius = 6.0
		life = 5.0
	var shape := CircleShape2D.new()
	shape.radius = radius
	var collision := CollisionShape2D.new()
	collision.shape = shape
	add_child(collision)
	_update_sprite()

func _ready() -> void:
	add_to_group("projectile")
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	sprite = Sprite2D.new()
	sprite.name = "ProjectileSprite"
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(sprite)
	_update_sprite()

func _update_sprite() -> void:
	if sprite == null:
		return
	if projectile_type == "enemy" and special_effect == "frost":
		sprite.texture = preload("res://assets/pixel/ice_shard.png")
		sprite.rotation = velocity.angle() + PI * 0.5
	elif projectile_type == "enemy":
		sprite.texture = preload("res://assets/pixel/ice_shard.png")
		sprite.rotation = velocity.angle() + PI * 0.5
	elif special_effect == "frost":
		sprite.texture = preload("res://assets/pixel/frost_blast.png")
		sprite.rotation = velocity.angle()
	elif special_effect == "ember":
		sprite.texture = preload("res://assets/pixel/ember_orb.png")
		sprite.rotation = velocity.angle()
	else:
		sprite.texture = preload("res://assets/pixel/staff_bolt.png")
		sprite.rotation = velocity.angle()

func _physics_process(delta: float) -> void:
	animation_time += delta
	position += velocity * delta
	if sprite != null:
		sprite.rotation = velocity.angle() + (PI * 0.5 if projectile_type == "enemy" else 0.0)
	life -= delta
	if life <= 0.0:
		queue_free()
	queue_redraw()

func _on_body_entered(body: Node) -> void:
	if projectile_type == "player" and body.is_in_group("boss"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		if special_effect == "frost" and body.has_method("apply_chill"):
			body.apply_chill(1.0)
		queue_free()
	elif projectile_type == "enemy" and body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		if special_effect == "frost" and body.has_method("apply_chill"):
			body.apply_chill(0.9)
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if projectile_type == "player" and area.is_in_group("boss_hurtbox"):
		var owner_node := area.get_parent()
		if owner_node.has_method("take_damage"):
			owner_node.take_damage(damage)
		queue_free()
