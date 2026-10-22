extends Node

@export var mob_scene: PackedScene
var score: int = 0
var high_score: int = 0
var running: bool = false


func _ready() -> void:
	# Pfad, der das Spielfenster umschließt (Mobs spawnen am Rand)
	var size := get_viewport().get_visible_rect().size
	var curve := Curve2D.new()
	curve.add_point(Vector2(0, 0))
	curve.add_point(Vector2(size.x, 0))
	curve.add_point(Vector2(size.x, size.y))
	curve.add_point(Vector2(0, size.y))
	curve.add_point(Vector2(0, 0))
	$MobPath.curve = curve
	$StartPosition.position = size / 2.0

	$HUD.update_high_score(high_score)


func game_over() -> void:
	running = false
	$ScoreTimer.stop()
	$MobTimer.stop()
	$Music.stop()
	$DeathSound.play()
	if score > high_score:
		high_score = score
		$HUD.update_high_score(high_score)
	$HUD.show_game_over()


func new_game() -> void:
	running = true
	score = 0
	$Player.start($StartPosition.position)
	$StartTimer.start()
	$HUD.update_score(score)
	$HUD.show_message("Get Ready")
	# Alle alten Mobs restlos entfernen
	get_tree().call_group("mobs", "queue_free")
	$Music.play()


func _on_score_timer_timeout() -> void:
	score += 1
	$HUD.update_score(score)


func _on_start_timer_timeout() -> void:
	$MobTimer.start()
	$ScoreTimer.start()


func _on_mob_timer_timeout() -> void:
	var mob = mob_scene.instantiate()

	# Zufällige Position auf dem Pfad
	var mob_spawn_location = $MobPath/MobSpawnLocation
	mob_spawn_location.progress_ratio = randf()

	# Richtung senkrecht zum Pfad (nach innen)
	var direction = mob_spawn_location.rotation + PI / 2

	mob.position = mob_spawn_location.position

	# Etwas Zufall in der Richtung
	direction += randf_range(-PI / 4, PI / 4)
	mob.rotation = direction

	# Zufällige Geschwindigkeit
	var velocity = Vector2(randf_range(150.0, 250.0), 0.0)
	mob.linear_velocity = velocity.rotated(direction)

	add_child(mob)


func _on_music_finished() -> void:
	# Musik als Loop, solange das Spiel läuft
	if running:
		$Music.play()
