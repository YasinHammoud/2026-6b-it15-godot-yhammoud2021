extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var scene: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	await process_frame

	var player: CharacterBody2D = scene.get("player")
	var boss: CharacterBody2D = scene.get("boss")
	if player.get_node("BodySprite").texture.get_size() != Vector2(32, 40):
		push_error("Player pixel-art texture is missing or has the wrong canvas size.")
		quit(1)
		return
	if boss.get_node("BodySprite").texture.get_size() != Vector2(80, 80):
		push_error("Warden pixel-art texture is missing or has the wrong canvas size.")
		quit(1)
		return

	player.set("health", 100)
	var projectile := Area2D.new()
	projectile.set_script(load("res://scripts/projectile.gd"))
	scene.add_child(projectile)
	projectile.call("setup", Vector2.LEFT, 0.0, "enemy", 12, "frost")
	projectile.call("_on_body_entered", player)
	if player.get("health") != 88 or player.get("chill_timer") <= 0.0:
		push_error("Frost shard hit did not damage and briefly slow the player.")
		quit(1)
		return

	player.call("fire_frost_blast")
	var frost_found := false
	for child in scene.get_children():
		if child is Area2D and child.get_script() == load("res://scripts/projectile.gd"):
			var visual: Sprite2D = child.get_node("ProjectileSprite")
			if visual.texture.resource_path.ends_with("frost_blast.png"):
				frost_found = true
	if not frost_found:
		push_error("Frost Blast did not use its original pixel-art projectile.")
		quit(1)
		return

	boss.call("disable")
	await create_timer(1.0).timeout
	var reward_panel: Panel = scene.get("reward_panel")
	if not reward_panel.visible:
		push_error("Boss defeat did not show the reward choice.")
		quit(1)
		return
	scene.call("_on_reward_selected", "frost_blast")
	await create_timer(1.1).timeout
	var rematch_boss: CharacterBody2D = scene.get("boss")
	if rematch_boss == boss or rematch_boss.get("health") != rematch_boss.get("max_health"):
		push_error("Choosing a reward did not spawn a healthy boss rematch.")
		quit(1)
		return
	if player.get("boss_reward") != "frost_blast" or not player.is_physics_processing():
		push_error("The rematch did not preserve the selected reward or re-enable the player.")
		quit(1)
		return
	rematch_boss.call("disable")
	await create_timer(1.1).timeout
	var next_boss: CharacterBody2D = scene.get("boss")
	if next_boss == rematch_boss or player.get("boss_reward") != "frost_blast":
		push_error("A later rematch did not respawn the boss with the selected reward preserved.")
		quit(1)
		return

	print("Visual slice smoke test passed: pixel art, frost slow, reward selection, and repeat rematches.")
	quit(0)
