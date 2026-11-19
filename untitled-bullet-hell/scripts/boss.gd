extends CharacterBody2D

signal health_changed(current: int, maximum: int)
signal defeated

var max_health := 300
var health := 300
var player: Node2D
var projectile_scene := preload("res://scripts/projectile.gd")
var spiral_angle := 0.0
var enrage := false
var hit_flash := 0.0
var animation_time := 0.0
var attack_cooldown := 0.9
var attack_pattern := -1
var telegraphing := false
var telegraph_timer := 0.0
var telegraph_direction := Vector2.LEFT
var fan_volleys_left := 0
var fan_volley_timer := 0.0
var spiral_bullets_left := 0
var spiral_bullet_timer := 0.0
var chill_timer := 0.0
var defeated_state := false
var defeat_time := 0.0
var boss_sprite: Sprite2D

func _ready() -> void:
	add_to_group("boss")
	var shape := CircleShape2D.new()
	shape.radius = 38.0
	var collision := CollisionShape2D.new()
	collision.shape = shape
	add_child(collision)
	boss_sprite = Sprite2D.new()
	boss_sprite.name = "BodySprite"
	boss_sprite.texture = preload("res://assets/pixel/rimebound_warden.png")
	boss_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(boss_sprite)
	health_changed.emit(health, max_health)

func _physics_process(delta: float) -> void:
	animation_time += delta
	if player == null:
		return
	if hit_flash > 0.0:
		hit_flash -= delta
	if chill_timer > 0.0:
		chill_timer = maxf(0.0, chill_timer - delta)

	if health <= 150 and not enrage:
		enrage = true

	if telegraphing:
		telegraph_timer -= delta
		if telegraph_timer <= 0.0:
			telegraphing = false
			_execute_attack()
	else:
		attack_cooldown -= delta
		if attack_cooldown <= 0.0:
			_begin_attack()

	if fan_volleys_left > 0:
		fan_volley_timer -= delta
		if fan_volley_timer <= 0.0:
			_fire_aimed_fan()
			fan_volleys_left -= 1
			fan_volley_timer = 0.24

	if spiral_bullets_left > 0:
		spiral_bullet_timer -= delta
		if spiral_bullet_timer <= 0.0:
			spawn_projectile(Vector2.RIGHT.rotated(spiral_angle), 150.0 if enrage else 135.0)
			spiral_angle += 0.42
			spiral_bullets_left -= 1
			spiral_bullet_timer = 0.09

	var to_player := player.global_position - global_position
	if telegraphing:
		velocity = Vector2.ZERO
	elif to_player.length() > 220.0:
		velocity = to_player.normalized() * 35.0
	elif to_player.length() < 155.0:
		velocity = -to_player.normalized() * 28.0
	else:
		velocity = Vector2.RIGHT.rotated(spiral_angle) * 20.0
	if chill_timer > 0.0:
		velocity *= 0.5
	move_and_slide()
	boss_sprite.position.y = sin(animation_time * 2.1) * 1.0
	if hit_flash > 0.0:
		boss_sprite.modulate = Color("#d9ffff")
	elif chill_timer > 0.0:
		boss_sprite.modulate = Color("#a8e9ff")
	else:
		boss_sprite.modulate = Color.WHITE
	queue_redraw()

func _process(delta: float) -> void:
	if not defeated_state:
		return
	defeat_time += delta
	var fade := clampf(1.0 - defeat_time / 0.9, 0.0, 1.0)
	modulate.a = fade
	scale = Vector2.ONE * (0.8 + fade * 0.2)
	if fade <= 0.0:
		queue_free()

func _begin_attack() -> void:
	attack_pattern = (attack_pattern + 1) % 3
	telegraph_direction = (player.global_position - global_position).normalized()
	telegraph_timer = 0.5 if not enrage else 0.4
	telegraphing = true

func _execute_attack() -> void:
	attack_cooldown = 1.25 if not enrage else 1.0
	match attack_pattern:
		0:
			fan_volleys_left = 4 if not enrage else 5
			fan_volley_timer = 0.0
		1:
			_fire_ring_with_gap()
		2:
			spiral_angle = telegraph_direction.angle()
			spiral_bullets_left = 18 if not enrage else 22
			spiral_bullet_timer = 0.0

func _fire_aimed_fan() -> void:
	var bullet_count := 7 if not enrage else 9
	var spread := deg_to_rad(9.0)
	for i in range(bullet_count):
		var centered_index: float = float(i) - float(bullet_count - 1) * 0.5
		spawn_projectile(telegraph_direction.rotated(centered_index * spread), 200.0 if enrage else 178.0)

func _fire_ring_with_gap() -> void:
	var bullet_count := 22 if not enrage else 26
	var gap_half_angle := deg_to_rad(34.0 if not enrage else 27.0)
	for i in range(bullet_count):
		var angle: float = TAU * float(i) / float(bullet_count) + spiral_angle
		var difference: float = absf(wrapf(angle - telegraph_direction.angle(), -PI, PI))
		if difference > gap_half_angle:
			spawn_projectile(Vector2.RIGHT.rotated(angle), 158.0 if enrage else 138.0)
	spiral_angle += 0.18

func spawn_projectile(direction: Vector2, speed: float) -> void:
	var projectile := Area2D.new()
	projectile.set_script(projectile_scene)
	projectile.position = global_position + direction * 44.0
	get_parent().add_child(projectile)
	projectile.setup(direction, speed, "enemy", 12, "frost")

func take_damage(amount: int) -> void:
	if defeated_state:
		return
	hit_flash = 0.08
	health = max(0, health - amount)
	health_changed.emit(health, max_health)
	var scene := get_tree().current_scene
	if scene != null and scene.has_method("spawn_impact"):
		scene.spawn_impact(global_position, Color("#90f5ee"), 0.8)
	if scene != null and scene.has_method("trigger_hit_stop"):
		scene.trigger_hit_stop(0.035)
	if health == 0:
		disable()

func apply_chill(duration: float) -> void:
	chill_timer = maxf(chill_timer, duration)

func disable() -> void:
	if defeated_state:
		return
	defeated_state = true
	set_physics_process(false)
	for child in get_children():
		if child is CollisionShape2D:
			child.disabled = true
	var scene := get_tree().current_scene
	if scene != null and scene.has_method("spawn_impact"):
		scene.spawn_impact(global_position, Color("#b5f7ff"), 2.2)
	defeated.emit()

func _draw() -> void:
	if not telegraphing:
		return
	var warning_alpha := 0.25 + sin(animation_time * 18.0) * 0.1
	if attack_pattern == 1:
		draw_arc(Vector2.ZERO, 150.0, 0.0, TAU, 48, Color("#ffb85c", warning_alpha), 3.0)
	elif attack_pattern == 0:
		for i in range(-2, 3):
			var ray_direction := telegraph_direction.rotated(deg_to_rad(i * 9.0))
			draw_line(ray_direction * 50.0, ray_direction * 430.0, Color("#ff7169", warning_alpha), 3.0)
	else:
		draw_arc(Vector2.ZERO, 90.0, 0.0, TAU, 32, Color("#7de9ff", warning_alpha), 3.0)
