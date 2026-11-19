extends Node2D

const FLOOR_TILES := [
	preload("res://assets/pixel/floor_a.png"),
	preload("res://assets/pixel/floor_b.png")
]
const WALL_TILE := preload("res://assets/pixel/wall.png")

func _ready() -> void:
	var tile_x := int(position.x / 32.0)
	var tile_y := int(position.y / 32.0)
	var at_edge := tile_x < 2 or tile_x > 37 or tile_y < 2 or tile_y > 19
	var variation := posmod(tile_x * 37 + tile_y * 19, 7)
	var sprite := Sprite2D.new()
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if at_edge:
		sprite.texture = WALL_TILE
	else:
		sprite.texture = FLOOR_TILES[1 if variation == 1 or variation == 5 else 0]
	add_child(sprite)
