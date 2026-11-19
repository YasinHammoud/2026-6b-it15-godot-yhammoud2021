extends Node2D

const PROP_TEXTURES := {
	"ice_crystal": preload("res://assets/pixel/ice_crystal_prop.png"),
	"broken_pillar": preload("res://assets/pixel/broken_pillar_prop.png"),
	"rubble": preload("res://assets/pixel/rubble_prop.png")
}

func setup(kind: String) -> void:
	if not PROP_TEXTURES.has(kind):
		push_error("Unknown arena prop kind: %s" % kind)
		return
	var sprite := Sprite2D.new()
	sprite.texture = PROP_TEXTURES[kind]
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(sprite)
