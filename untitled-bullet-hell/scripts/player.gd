extends CharacterBody2D

signal health_changed(current: int, maximum: int)
signal died

var max_health := 100
var health := 100
var move_speed := 210.0
var dash_speed := 590.0
var dash_time := 0.16
var dash_cooldown := 0.75
var dash_direction := Vector2.ZERO
var dash_timer := 0.0
var dash_cooldown_timer := 0.0
var aim_direction := Vector2.RIGHT
var fire_cooldown := 0.34
var fire_timer := 0.0
var ability_cooldown := 2.0
var ability_timer := 0.0
var invulnerability := 0.0
var animation_time := 0.0
var dash_requested := false
var dash_trail_timer := 0.0
var dash_trail_positions: Array[Vector2] = []
var dash_trail_ages: Array[float] = []
var has_frost_resistance := false
var boss_reward := ""
var body_sprite: Sprite2D
var staff_sprite: Sprite2D
var chill_timer := 0.0
var attack_flash_timer := 0.0

var projectile_scene := preload("res://scripts/projectile.gd")
var player_texture := preload("res://assets/pixel/player_body.png")
var staff_texture := preload("res://assets/pixel/staff.png")

func _ready() -> void:
	add_to_group("player")
	var shape := CapsuleShape2D.new()
	shape.radius = 9.0
	shape.height = 17.0
	var collision := CollisionShape2D.new()
	collision.shape = shape
	collision.rotation = PI * 0.5
	add_child(collision)
	body_sprite = Sprite2D.new()
	body_sprite.name = "BodySprite"
	body_sprite.texture = player_texture
	body_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(body_sprite)
	staff_sprite = Sprite2D.new()
	staff_sprite.name = "StaffSprite"
	staff_sprite.texture = staff_texture
	staff_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	staff_sprite.position = Vector2(6.0, -2.0)
	staff_sprite.z_index = 1
	add_child(staff_sprite)
	health_changed.emit(health, max_health)

func _physics_process(delta: float) -> void:
	animation_time += delta
	_update_dash_trail(delta)
	if invulnerability > 0.0:
		invulnerability -= delta
	if dash_cooldown_timer > 0.0:
		dash_cooldown_timer -= delta
	if fire_timer > 0.0:
		fire_timer -= delta
	if ability_timer > 0.0:
		ability_timer -= delta
	if chill_timer > 0.0:
		chill_timer = maxf(0.0, chill_timer - delta)
	if attack_flash_timer > 0.0:
		attack_flash_timer -= delta

	var input_vector := Vector2(
		Input.get_axis("ui_left", "ui_right") + (1.0 if Input.is_physical_key_pressed(KEY_D) else 0.0) - (1.0 if Input.is_physical_key_pressed(KEY_A) else 0.0),
		Input.get_axis("ui_up", "ui_down") + (1.0 if Input.is_physical_key_pressed(KEY_S) else 0.0) - (1.0 if Input.is_physical_key_pressed(KEY_W) else 0.0)
	)
	input_vector = input_vector.limit_length(1.0)
	var movement_scale := 0.65 if chill_timer > 0.0 else 1.0

	var mouse_position := get_global_mouse_position()
	aim_direction = (mouse_position - global_position).normalized()
	staff_sprite.rotation = aim_direction.angle()
	staff_sprite.position = aim_direction * 7.0 + Vector2(0.0, -2.0)

	if dash_timer > 0.0:
		dash_timer -= delta
		velocity = dash_direction * dash_speed
	else:
		if dash_requested and dash_cooldown_timer <= 0.0:
			dash_direction = input_vector if input_vector.length() > 0.1 else aim_direction
			dash_timer = dash_time
			dash_cooldown_timer = dash_cooldown
			velocity = dash_direction * dash_speed
		else:
			velocity = input_vector * move_speed * movement_scale
		dash_requested = false

	move_and_slide()
	global_position.x = clamp(global_position.x, 32.0, 1248.0)
	global_position.y = clamp(global_position.y, 32.0, 688.0)
	var idle_bob := 0.0 if input_vector.length() > 0.1 or dash_timer > 0.0 else sin(animation_time * 4.0) * 1.0
	body_sprite.position.y = idle_bob
	body_sprite.modulate = Color("#bfe9ff") if chill_timer > 0.0 else Color.WHITE
	staff_sprite.position = aim_direction * (7.0 - (3.0 if attack_flash_timer > 0.0 else 0.0)) + Vector2(0.0, -2.0 + idle_bob)

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and fire_timer <= 0.0:
		fire_staff()
	if (Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) or Input.is_physical_key_pressed(KEY_Q)) and ability_timer <= 0.0:
		if boss_reward == "frost_blast":
			fire_frost_blast()
		else:
			fire_ember_wave()
	queue_redraw()

func _update_dash_trail(delta: float) -> void:
	for index in range(dash_trail_ages.size() - 1, -1, -1):
		dash_trail_ages[index] += delta
		if dash_trail_ages[index] >= 0.2:
			dash_trail_ages.remove_at(index)
			dash_trail_positions.remove_at(index)

	if dash_timer > 0.0:
		dash_trail_timer -= delta
		if dash_trail_timer <= 0.0:
			dash_trail_positions.append(global_position)
			dash_trail_ages.append(0.0)
			dash_trail_timer = 0.035
	queue_redraw()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.physical_keycode == KEY_SPACE and event.pressed and not event.echo:
		dash_requested = true

func fire_staff() -> void:
	fire_timer = fire_cooldown
	attack_flash_timer = 0.08
	spawn_projectile(aim_direction, 520.0, "player", 12)

func fire_ember_wave() -> void:
	ability_timer = ability_cooldown
	for angle in range(-2, 3):
		var direction := aim_direction.rotated(deg_to_rad(angle * 18.0))
		spawn_projectile(direction, 360.0, "player", 16, "ember")

func fire_frost_blast() -> void:
	ability_timer = ability_cooldown
	spawn_projectile(aim_direction, 400.0, "player", 36, "frost")

func spawn_projectile(direction: Vector2, speed: float, type: String, projectile_damage: int, effect: String = "") -> void:
	var projectile := Area2D.new()
	projectile.set_script(projectile_scene)
	projectile.position = global_position + direction * 22.0
	get_parent().add_child(projectile)
	projectile.setup(direction, speed, type, projectile_damage, effect)

func take_damage(amount: int) -> void:
	if invulnerability > 0.0:
		return
	invulnerability = 0.65
	var final_damage := maxi(1, roundi(amount * 0.75)) if has_frost_resistance else amount
	health = max(0, health - final_damage)
	health_changed.emit(health, max_health)
	var scene := get_tree().current_scene
	if scene != null and scene.has_method("spawn_impact"):
		scene.spawn_impact(global_position, Color("#ff795e"), 1.15)
	if scene != null and scene.has_method("trigger_hit_stop"):
		scene.trigger_hit_stop(0.07)
	if health == 0:
		died.emit()

func apply_chill(duration: float) -> void:
	chill_timer = maxf(chill_timer, duration * (0.75 if has_frost_resistance else 1.0))

func _draw() -> void:
	_draw_dash_trail()
	var flash := invulnerability > 0.0 and int(invulnerability * 20.0) % 2 == 0
	if flash:
		body_sprite.modulate = Color("#ffc5b4")

func _draw_dash_trail() -> void:
	for index in range(dash_trail_positions.size()):
		var age := dash_trail_ages[index]
		var alpha := (1.0 - age / 0.2) * 0.3
		var offset := dash_trail_positions[index] - global_position
		draw_colored_polygon(PackedVector2Array([
			offset + Vector2(-10, 10), offset + Vector2(-8, 3),
			offset + Vector2(-7, -8), offset + Vector2(-3, -13),
			offset + Vector2(5, -13), offset + Vector2(8, -7),
			offset + Vector2(7, 3), offset + Vector2(11, 9),
			offset + Vector2(4, 12), offset + Vector2(-3, 12)
		]), Color("#63e9dc", alpha))
		draw_rect(Rect2(offset + Vector2(-5, -5), Vector2(10, 8)), Color("#b5fff0", alpha * 0.55))
