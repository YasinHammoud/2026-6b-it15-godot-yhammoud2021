extends Node2D

var player_scene := preload("res://scripts/player.gd")
var boss_scene := preload("res://scripts/boss.gd")
var player: CharacterBody2D
var boss: CharacterBody2D
var health_bar: ProgressBar
var boss_health_bar: ProgressBar
var status_label: Label
var reward_panel: Panel
var hit_stop_generation := 0
var impact_effect_scene := preload("res://scripts/impact_effect.gd")
var selected_reward := ""
var rematch_generation := 0

func _ready() -> void:
	_create_arena()
	_create_player()
	_create_ui()
	player.health_changed.connect(_on_player_health_changed)
	player.died.connect(_on_player_died)
	_create_boss()

func _exit_tree() -> void:
	Engine.time_scale = 1.0

func _create_arena() -> void:
	for y in range(0, 720, 32):
		for x in range(0, 1280, 32):
			var tile := Node2D.new()
			tile.position = Vector2(x + 16, y + 16)
			tile.set_script(preload("res://scripts/tile.gd"))
			add_child(tile)
	_create_wall_lights()
	_create_arena_decor()

func _create_wall_lights() -> void:
	for y in [160.0, 560.0]:
		var torch := Node2D.new()
		torch.position = Vector2(40.0, y)
		torch.set_script(preload("res://scripts/torch.gd"))
		add_child(torch)
		var opposite_torch := Node2D.new()
		opposite_torch.position = Vector2(1240.0, y)
		opposite_torch.set_script(preload("res://scripts/torch.gd"))
		add_child(opposite_torch)

func _create_arena_decor() -> void:
	var props := [
		{"position": Vector2(126, 128), "kind": "ice_crystal"},
		{"position": Vector2(310, 602), "kind": "rubble"},
		{"position": Vector2(500, 119), "kind": "broken_pillar"},
		{"position": Vector2(780, 602), "kind": "rubble"},
		{"position": Vector2(1016, 126), "kind": "ice_crystal"},
		{"position": Vector2(1152, 585), "kind": "broken_pillar"},
		{"position": Vector2(126, 570), "kind": "rubble"}
	]
	for prop_data in props:
		var prop := Node2D.new()
		prop.position = prop_data["position"]
		prop.set_script(preload("res://scripts/arena_prop.gd"))
		add_child(prop)
		prop.setup(prop_data["kind"])

func _create_player() -> void:
	player = CharacterBody2D.new()
	player.set_script(player_scene)
	player.position = Vector2(220.0, 360.0)
	add_child(player)

func _create_boss() -> void:
	_spawn_boss()

func _spawn_boss() -> void:
	boss = CharacterBody2D.new()
	boss.set_script(boss_scene)
	boss.position = Vector2(920.0, 360.0)
	boss.player = player
	add_child(boss)
	boss.health_changed.connect(_on_boss_health_changed)
	boss.defeated.connect(_on_boss_defeated)
	_on_boss_health_changed(boss.health, boss.max_health)

func _create_ui() -> void:
	var canvas := CanvasLayer.new()
	add_child(canvas)
	var ui_root := Control.new()
	ui_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(ui_root)
	var ui_theme := Theme.new()
	ui_theme.default_font_size = 16
	ui_theme.set_color("font_color", "Label", Color("#e9e3d9"))
	ui_theme.set_color("font_shadow_color", "Label", Color("#0a0c13"))
	ui_theme.set_constant("shadow_offset_x", "Label", 1)
	ui_theme.set_constant("shadow_offset_y", "Label", 2)
	ui_theme.set_color("font_outline_color", "Label", Color("#11131c"))
	ui_theme.set_constant("outline_size", "Label", 3)
	ui_root.theme = ui_theme

	var player_panel := PanelContainer.new()
	player_panel.position = Vector2(20, 16)
	player_panel.size = Vector2(220, 58)
	player_panel.add_theme_stylebox_override("panel", _make_panel_style(Color("#59677e")))
	ui_root.add_child(player_panel)

	var player_label := Label.new()
	player_label.position = Vector2(8, 3)
	player_label.text = "WANDERER"
	player_panel.add_child(player_label)

	health_bar = ProgressBar.new()
	health_bar.position = Vector2(8, 30)
	health_bar.size = Vector2(204, 14)
	health_bar.max_value = 100
	health_bar.value = 100
	health_bar.show_percentage = false
	health_bar.add_theme_stylebox_override("background", _make_bar_style(Color("#181923"), Color("#0b0d13")))
	health_bar.add_theme_stylebox_override("fill", _make_bar_style(Color("#b94650"), Color("#f27973")))
	player_panel.add_child(health_bar)

	var boss_panel := PanelContainer.new()
	boss_panel.position = Vector2(430, 14)
	boss_panel.size = Vector2(420, 64)
	boss_panel.add_theme_stylebox_override("panel", _make_panel_style(Color("#78859a")))
	ui_root.add_child(boss_panel)

	var boss_label := Label.new()
	boss_label.position = Vector2(8, 4)
	boss_label.text = "THE RIMEBOUND WARDEN"
	boss_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	boss_label.size = Vector2(404, 22)
	boss_label.add_theme_color_override("font_color", Color("#c7f5ff"))
	boss_panel.add_child(boss_label)

	boss_health_bar = ProgressBar.new()
	boss_health_bar.position = Vector2(10, 34)
	boss_health_bar.size = Vector2(400, 18)
	boss_health_bar.max_value = 300
	boss_health_bar.value = 300
	boss_health_bar.show_percentage = false
	boss_health_bar.add_theme_stylebox_override("background", _make_bar_style(Color("#171a27"), Color("#0a0d14")))
	boss_health_bar.add_theme_stylebox_override("fill", _make_bar_style(Color("#438a9e"), Color("#9ceafa")))
	boss_panel.add_child(boss_health_bar)

	status_label = Label.new()
	status_label.position = Vector2(350, 670)
	status_label.size = Vector2(580, 30)
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.text = "WASD MOVE   |   MOUSE AIM   |   LMB SHOOT   |   SPACE DASH   |   Q / RMB ABILITY"
	status_label.add_theme_font_size_override("font_size", 13)
	ui_root.add_child(status_label)

	reward_panel = Panel.new()
	reward_panel.position = Vector2(360, 250)
	reward_panel.size = Vector2(560, 220)
	reward_panel.visible = false
	reward_panel.add_theme_stylebox_override("panel", _make_panel_style(Color("#9ceafa")))
	ui_root.add_child(reward_panel)

	var reward_title := Label.new()
	reward_title.position = Vector2(18, 12)
	reward_title.size = Vector2(524, 30)
	reward_title.text = "THE WARDEN'S POWER"
	reward_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	reward_title.add_theme_color_override("font_color", Color("#c7f5ff"))
	reward_panel.add_child(reward_title)

	var blast_description := Label.new()
	blast_description.position = Vector2(20, 54)
	blast_description.size = Vector2(270, 56)
	blast_description.text = "Frost Blast\nA heavy ice bolt that briefly slows the boss."
	blast_description.add_theme_font_size_override("font_size", 14)
	reward_panel.add_child(blast_description)

	var blast_button := Button.new()
	blast_button.position = Vector2(320, 63)
	blast_button.size = Vector2(210, 38)
	blast_button.text = "Choose Frost Blast"
	blast_button.pressed.connect(_on_reward_selected.bind("frost_blast"))
	reward_panel.add_child(blast_button)

	var resistance_description := Label.new()
	resistance_description.position = Vector2(20, 126)
	resistance_description.size = Vector2(270, 56)
	resistance_description.text = "Frost Resistance\nTake 25% less damage from attacks."
	resistance_description.add_theme_font_size_override("font_size", 14)
	reward_panel.add_child(resistance_description)

	var resistance_button := Button.new()
	resistance_button.position = Vector2(320, 135)
	resistance_button.size = Vector2(210, 38)
	resistance_button.text = "Choose Resistance"
	resistance_button.pressed.connect(_on_reward_selected.bind("frost_resistance"))
	reward_panel.add_child(resistance_button)

func _make_panel_style(edge_color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#171a25")
	style.border_color = edge_color
	style.set_border_width_all(3)
	style.set_content_margin_all(6)
	return style

func _make_bar_style(base_color: Color, edge_color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = base_color
	style.border_color = edge_color
	style.set_border_width_all(2)
	style.set_corner_radius_all(0)
	return style

func spawn_impact(world_position: Vector2, tint: Color, intensity: float = 1.0) -> void:
	var impact := Node2D.new()
	impact.set_script(impact_effect_scene)
	impact.position = world_position
	add_child(impact)
	impact.setup(tint, intensity)

func trigger_hit_stop(duration: float) -> void:
	hit_stop_generation += 1
	Engine.time_scale = 0.12
	_release_hit_stop_after(duration, hit_stop_generation)

func _release_hit_stop_after(duration: float, generation: int) -> void:
	await get_tree().create_timer(duration, true, false, true).timeout
	if generation == hit_stop_generation:
		Engine.time_scale = 1.0

func _show_boss_reward() -> void:
	await get_tree().create_timer(0.9).timeout
	if is_instance_valid(reward_panel):
		reward_panel.visible = true

func _on_reward_selected(reward_id: String) -> void:
	reward_panel.visible = false
	player.boss_reward = reward_id
	selected_reward = reward_id
	player.has_frost_resistance = reward_id == "frost_resistance"
	player.ability_cooldown = 3.0 if reward_id == "frost_blast" else 2.0
	player.ability_timer = 0.0
	if reward_id == "frost_blast":
		status_label.text = "FROST BLAST EQUIPPED — Q / RMB   |   REMATCH IN A MOMENT"
	else:
		status_label.text = "FROST RESISTANCE — 25% LESS DAMAGE   |   REMATCH IN A MOMENT"
	_start_rematch()

func _start_rematch() -> void:
	rematch_generation += 1
	_spawn_rematch_after(1.0, rematch_generation)

func _spawn_rematch_after(delay: float, generation: int) -> void:
	await get_tree().create_timer(delay).timeout
	if generation != rematch_generation or not is_inside_tree():
		return
	player.global_position = Vector2(220.0, 360.0)
	player.health = player.max_health
	player.health_changed.emit(player.health, player.max_health)
	player.ability_timer = 0.0
	_spawn_boss()
	player.set_process_input(true)
	player.set_physics_process(true)
	if selected_reward == "frost_blast":
		status_label.text = "REMATCH — FROST BLAST READY (Q / RMB)"
	else:
		status_label.text = "REMATCH — TEST FROST RESISTANCE"

func _on_player_health_changed(current: int, maximum: int) -> void:
	health_bar.max_value = maximum
	health_bar.value = current

func _on_boss_health_changed(current: int, maximum: int) -> void:
	boss_health_bar.max_value = maximum
	boss_health_bar.value = current

func _on_player_died() -> void:
	status_label.text = "DEFEATED — press R to restart"
	set_process(true)

func _on_boss_defeated() -> void:
	player.set_physics_process(false)
	player.set_process_input(false)
	for projectile in get_tree().get_nodes_in_group("projectile"):
		if projectile.get("projectile_type") == "enemy":
			projectile.queue_free()
	if selected_reward.is_empty():
		status_label.text = "THE RIMEBOUND WARDEN IS DEFEATED"
		_show_boss_reward()
	else:
		status_label.text = "WARDEN DEFEATED — REMATCH IN A MOMENT"
		_start_rematch()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.physical_keycode == KEY_R and event.pressed and not event.echo:
		get_tree().reload_current_scene()

func _draw() -> void:
	draw_rect(Rect2(48, 48, 1184, 624), Color("#101721"), false, 4.0)
