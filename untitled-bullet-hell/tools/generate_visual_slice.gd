extends SceneTree

const OUT_DIR := "res://assets/pixel/"
const INK := Color("#12131b")
const STONE := Color("#303543")
const STONE_LIGHT := Color("#485160")
const STONE_DARK := Color("#202632")
const ICE := Color("#8ab9c5")
const ICE_LIGHT := Color("#d4edf0")
const CYAN := Color("#55d8dc")

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))
	_generate_player()
	_generate_warden()
	_generate_tiles()
	_generate_projectiles()
	_generate_props()
	print("Generated original pixel-art visual slice in assets/pixel/.")
	quit()

func _image(width: int, height: int) -> Image:
	var image := Image.create(width, height, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	return image

func _save(image: Image, filename: String) -> void:
	var error := image.save_png(ProjectSettings.globalize_path(OUT_DIR + filename))
	if error != OK:
		push_error("Could not save generated sprite %s (error %d)." % [filename, error])

func _rect(image: Image, x: int, y: int, width: int, height: int, color: Color) -> void:
	image.fill_rect(Rect2i(x, y, width, height), color)

func _poly(image: Image, points: Array[Vector2i], color: Color) -> void:
	var min_x := points[0].x
	var max_x := points[0].x
	var min_y := points[0].y
	var max_y := points[0].y
	for point in points:
		min_x = mini(min_x, point.x)
		max_x = maxi(max_x, point.x)
		min_y = mini(min_y, point.y)
		max_y = maxi(max_y, point.y)
	for y in range(min_y, max_y + 1):
		for x in range(min_x, max_x + 1):
			if _inside_polygon(Vector2(x + 0.5, y + 0.5), points):
				image.set_pixel(x, y, color)

func _inside_polygon(point: Vector2, polygon: Array[Vector2i]) -> bool:
	var inside := false
	var previous := polygon.size() - 1
	for current in range(polygon.size()):
		var a := polygon[current]
		var b := polygon[previous]
		var crosses_y := (a.y > point.y) != (b.y > point.y)
		if crosses_y:
			var cross_x := float(b.x - a.x) * (point.y - a.y) / float(b.y - a.y) + a.x
			if point.x < cross_x:
				inside = not inside
		previous = current
	return inside

func _generate_player() -> void:
	var image := _image(32, 40)
	_poly(image, [Vector2i(7, 9), Vector2i(10, 4), Vector2i(22, 4), Vector2i(26, 10), Vector2i(24, 18), Vector2i(28, 27), Vector2i(25, 34), Vector2i(7, 34), Vector2i(4, 27), Vector2i(8, 18)], INK)
	_poly(image, [Vector2i(9, 10), Vector2i(12, 6), Vector2i(21, 6), Vector2i(24, 11), Vector2i(22, 18), Vector2i(25, 27), Vector2i(22, 32), Vector2i(10, 32), Vector2i(7, 27), Vector2i(10, 18)], Color("#514254"))
	_poly(image, [Vector2i(10, 20), Vector2i(22, 20), Vector2i(24, 29), Vector2i(20, 33), Vector2i(11, 33), Vector2i(8, 29)], Color("#393347"))
	_rect(image, 12, 10, 9, 10, Color("#c59b75"))
	_rect(image, 11, 8, 11, 4, Color("#26303a"))
	_rect(image, 9, 9, 14, 3, Color("#687789"))
	_rect(image, 13, 14, 2, 2, Color("#242631"))
	_rect(image, 19, 14, 2, 2, Color("#242631"))
	_rect(image, 14, 18, 5, 2, Color("#e0cba6"))
	_poly(image, [Vector2i(10, 23), Vector2i(22, 23), Vector2i(22, 29), Vector2i(18, 32), Vector2i(12, 31)], Color("#758997"))
	_rect(image, 9, 25, 4, 6, Color("#566c7c"))
	_rect(image, 18, 25, 5, 6, Color("#a6b8bf"))
	_rect(image, 11, 32, 5, 5, INK)
	_rect(image, 19, 32, 5, 5, INK)
	_rect(image, 10, 36, 7, 2, Color("#a98a65"))
	_rect(image, 18, 36, 7, 2, Color("#a98a65"))
	_rect(image, 13, 24, 7, 2, Color("#a3494e"))
	_rect(image, 14, 26, 3, 3, Color("#c1ad77"))
	_rect(image, 11, 11, 2, 4, Color("#e4c59a"))
	_save(image, "player_body.png")

	var staff := _image(28, 10)
	_rect(staff, 3, 4, 20, 2, INK)
	_rect(staff, 4, 4, 18, 1, Color("#72533d"))
	_rect(staff, 4, 5, 18, 1, Color("#b58a54"))
	_rect(staff, 20, 2, 5, 6, INK)
	_poly(staff, [Vector2i(22, 2), Vector2i(24, 3), Vector2i(25, 5), Vector2i(23, 7), Vector2i(21, 6)], Color("#25616b"))
	_rect(staff, 22, 3, 2, 3, CYAN)
	_rect(staff, 23, 3, 1, 2, Color("#efffff"))
	_rect(staff, 7, 3, 2, 4, Color("#dbc18a"))
	_save(staff, "staff.png")

func _generate_warden() -> void:
	var image := _image(80, 80)
	_poly(image, [Vector2i(12, 52), Vector2i(18, 35), Vector2i(15, 21), Vector2i(24, 12), Vector2i(40, 8), Vector2i(56, 13), Vector2i(64, 25), Vector2i(60, 42), Vector2i(70, 56), Vector2i(64, 68), Vector2i(18, 68), Vector2i(10, 60)], INK)
	_poly(image, [Vector2i(17, 51), Vector2i(22, 36), Vector2i(20, 23), Vector2i(27, 16), Vector2i(40, 12), Vector2i(53, 17), Vector2i(59, 27), Vector2i(55, 42), Vector2i(64, 55), Vector2i(59, 64), Vector2i(21, 64), Vector2i(16, 59)], STONE)
	_poly(image, [Vector2i(20, 25), Vector2i(27, 18), Vector2i(39, 15), Vector2i(49, 18), Vector2i(54, 27), Vector2i(50, 37), Vector2i(41, 43), Vector2i(28, 40), Vector2i(21, 34)], STONE_LIGHT)
	_poly(image, [Vector2i(18, 45), Vector2i(29, 39), Vector2i(40, 43), Vector2i(52, 39), Vector2i(58, 52), Vector2i(55, 61), Vector2i(24, 62), Vector2i(17, 56)], STONE_DARK)
	_poly(image, [Vector2i(25, 23), Vector2i(31, 19), Vector2i(40, 18), Vector2i(48, 21), Vector2i(51, 30), Vector2i(47, 37), Vector2i(40, 40), Vector2i(30, 38), Vector2i(25, 32)], Color("#252a36"))
	_rect(image, 29, 27, 5, 3, Color("#c26862"))
	_rect(image, 43, 27, 5, 3, Color("#c26862"))
	_rect(image, 30, 27, 2, 1, Color("#ffcf9c"))
	_rect(image, 44, 27, 2, 1, Color("#ffcf9c"))
	_poly(image, [Vector2i(36, 9), Vector2i(39, 3), Vector2i(42, 10), Vector2i(49, 6), Vector2i(48, 14), Vector2i(32, 14), Vector2i(29, 9)], INK)
	_poly(image, [Vector2i(37, 10), Vector2i(39, 6), Vector2i(42, 11), Vector2i(47, 8), Vector2i(46, 13), Vector2i(34, 13)], ICE)
	_poly(image, [Vector2i(5, 42), Vector2i(13, 35), Vector2i(25, 40), Vector2i(27, 51), Vector2i(20, 58), Vector2i(7, 54)], INK)
	_poly(image, [Vector2i(7, 43), Vector2i(14, 38), Vector2i(23, 42), Vector2i(24, 50), Vector2i(19, 55), Vector2i(9, 52)], Color("#657184"))
	_rect(image, 8, 41, 8, 3, ICE_LIGHT)
	_rect(image, 9, 44, 4, 7, ICE)
	_poly(image, [Vector2i(55, 36), Vector2i(62, 33), Vector2i(67, 41), Vector2i(65, 50), Vector2i(58, 52), Vector2i(53, 46)], INK)
	_poly(image, [Vector2i(57, 38), Vector2i(62, 36), Vector2i(65, 42), Vector2i(63, 47), Vector2i(59, 48), Vector2i(56, 44)], Color("#657184"))
	_rect(image, 59, 38, 5, 2, ICE_LIGHT)
	_poly(image, [Vector2i(6, 53), Vector2i(3, 47), Vector2i(5, 42), Vector2i(8, 44), Vector2i(9, 53)], INK)
	_poly(image, [Vector2i(3, 44), Vector2i(0, 40), Vector2i(3, 31), Vector2i(6, 39), Vector2i(6, 44)], INK)
	_poly(image, [Vector2i(4, 43), Vector2i(2, 40), Vector2i(4, 35), Vector2i(6, 40), Vector2i(6, 43)], ICE_LIGHT)
	_poly(image, [Vector2i(5, 40), Vector2i(2, 39), Vector2i(0, 35), Vector2i(4, 36), Vector2i(7, 39)], Color("#acc6d0"))
	_poly(image, [Vector2i(68, 23), Vector2i(72, 20), Vector2i(75, 24), Vector2i(74, 59), Vector2i(70, 59)], INK)
	_rect(image, 70, 27, 3, 29, Color("#554237"))
	_rect(image, 70, 29, 1, 23, Color("#b28a5d"))
	_poly(image, [Vector2i(56, 9), Vector2i(62, 4), Vector2i(74, 5), Vector2i(79, 11), Vector2i(78, 21), Vector2i(73, 26), Vector2i(60, 24), Vector2i(55, 18)], INK)
	_poly(image, [Vector2i(59, 10), Vector2i(63, 7), Vector2i(72, 8), Vector2i(76, 12), Vector2i(75, 19), Vector2i(71, 22), Vector2i(62, 21), Vector2i(58, 16)], Color("#376176"))
	_poly(image, [Vector2i(61, 10), Vector2i(64, 8), Vector2i(67, 11), Vector2i(66, 17), Vector2i(62, 15)], ICE_LIGHT)
	_rect(image, 68, 9, 6, 3, Color("#78d8e2"))
	_rect(image, 76, 13, 2, 5, Color("#253849"))
	_rect(image, 26, 45, 3, 11, Color("#788596"))
	_rect(image, 49, 44, 3, 12, Color("#788596"))
	_rect(image, 30, 48, 3, 5, CYAN)
	_rect(image, 47, 48, 3, 5, CYAN)
	_rect(image, 35, 44, 10, 3, Color("#171d29"))
	_rect(image, 37, 45, 6, 1, Color("#8df0e9"))
	_poly(image, [Vector2i(35, 51), Vector2i(40, 47), Vector2i(45, 51), Vector2i(40, 57)], INK)
	_poly(image, [Vector2i(37, 51), Vector2i(40, 49), Vector2i(43, 51), Vector2i(40, 55)], CYAN)
	_rect(image, 39, 50, 2, 2, Color("#e9ffff"))
	_poly(image, [Vector2i(24, 61), Vector2i(35, 61), Vector2i(35, 68), Vector2i(21, 68)], INK)
	_poly(image, [Vector2i(44, 61), Vector2i(55, 60), Vector2i(60, 67), Vector2i(44, 68)], INK)
	_rect(image, 26, 63, 8, 4, Color("#718399"))
	_rect(image, 47, 63, 8, 4, Color("#718399"))
	_rect(image, 27, 63, 5, 2, ICE)
	_rect(image, 48, 63, 5, 2, ICE)
	_save(image, "rimebound_warden.png")

func _generate_tiles() -> void:
	var floor_a := _image(32, 32)
	_rect(floor_a, 0, 0, 32, 32, Color("#242936"))
	_rect(floor_a, 1, 1, 30, 30, Color("#303746"))
	_rect(floor_a, 1, 1, 30, 1, Color("#424b59"))
	_rect(floor_a, 1, 1, 1, 30, Color("#3d4655"))
	_rect(floor_a, 15, 2, 1, 13, Color("#242c39"))
	_rect(floor_a, 3, 15, 12, 1, Color("#242c39"))
	_rect(floor_a, 19, 20, 2, 1, Color("#48515d"))
	_rect(floor_a, 22, 21, 1, 2, Color("#48515d"))
	_rect(floor_a, 6, 24, 2, 1, Color("#252e3b"))
	_save(floor_a, "floor_a.png")

	var floor_b := _image(32, 32)
	_rect(floor_b, 0, 0, 32, 32, Color("#222733"))
	_rect(floor_b, 1, 1, 30, 30, Color("#2d3442"))
	_rect(floor_b, 1, 1, 30, 1, Color("#3c4653"))
	_rect(floor_b, 1, 1, 1, 30, Color("#394251"))
	_rect(floor_b, 8, 2, 1, 12, Color("#232b38"))
	_rect(floor_b, 9, 14, 10, 1, Color("#232b38"))
	_rect(floor_b, 20, 15, 1, 13, Color("#232b38"))
	_rect(floor_b, 22, 7, 3, 1, Color("#414a57"))
	_rect(floor_b, 24, 8, 1, 2, Color("#414a57"))
	_save(floor_b, "floor_b.png")

	var wall := _image(32, 32)
	_rect(wall, 0, 0, 32, 32, Color("#171b27"))
	_rect(wall, 1, 1, 30, 30, Color("#465062"))
	_rect(wall, 1, 1, 30, 2, Color("#697385"))
	_rect(wall, 1, 3, 30, 1, Color("#303849"))
	_rect(wall, 1, 16, 30, 2, Color("#202634"))
	_rect(wall, 1, 18, 30, 12, Color("#394456"))
	_rect(wall, 6, 4, 2, 12, Color("#252c3b"))
	_rect(wall, 22, 4, 2, 12, Color("#252c3b"))
	_rect(wall, 14, 18, 2, 12, Color("#242b39"))
	_rect(wall, 1, 29, 30, 1, Color("#697385"))
	_rect(wall, 4, 6, 2, 2, Color("#788394"))
	_rect(wall, 25, 21, 3, 2, Color("#536074"))
	_save(wall, "wall.png")

func _generate_projectiles() -> void:
	var staff_bolt := _image(16, 10)
	_poly(staff_bolt, [Vector2i(2, 5), Vector2i(6, 1), Vector2i(12, 2), Vector2i(15, 5), Vector2i(12, 8), Vector2i(6, 9)], INK)
	_poly(staff_bolt, [Vector2i(4, 5), Vector2i(7, 2), Vector2i(12, 3), Vector2i(14, 5), Vector2i(12, 7), Vector2i(7, 8)], Color("#278a83"))
	_rect(staff_bolt, 7, 4, 5, 2, Color("#62f0c8"))
	_rect(staff_bolt, 10, 3, 3, 2, Color("#eeffe5"))
	_save(staff_bolt, "staff_bolt.png")

	var ice_shard := _image(16, 16)
	_poly(ice_shard, [Vector2i(8, 0), Vector2i(12, 5), Vector2i(13, 11), Vector2i(8, 15), Vector2i(3, 11), Vector2i(4, 5)], INK)
	_poly(ice_shard, [Vector2i(8, 2), Vector2i(10, 6), Vector2i(11, 10), Vector2i(8, 13), Vector2i(5, 10), Vector2i(6, 6)], Color("#4b8da6"))
	_poly(ice_shard, [Vector2i(8, 3), Vector2i(8, 10), Vector2i(6, 8)], Color("#d2f3f4"))
	_rect(ice_shard, 9, 6, 2, 3, Color("#9de0e8"))
	_save(ice_shard, "ice_shard.png")

	var frost_blast := _image(24, 16)
	_poly(frost_blast, [Vector2i(1, 8), Vector2i(5, 2), Vector2i(13, 1), Vector2i(20, 4), Vector2i(23, 8), Vector2i(20, 12), Vector2i(13, 15), Vector2i(5, 14)], INK)
	_poly(frost_blast, [Vector2i(3, 8), Vector2i(7, 4), Vector2i(13, 3), Vector2i(19, 5), Vector2i(21, 8), Vector2i(19, 11), Vector2i(13, 13), Vector2i(7, 12)], Color("#376985"))
	_poly(frost_blast, [Vector2i(6, 8), Vector2i(9, 5), Vector2i(14, 5), Vector2i(19, 8), Vector2i(14, 11), Vector2i(9, 11)], Color("#72d8ed"))
	_rect(frost_blast, 11, 6, 7, 3, Color("#e7ffff"))
	_rect(frost_blast, 7, 7, 2, 2, Color("#bcf4fa"))
	_save(frost_blast, "frost_blast.png")

	var ember := _image(16, 16)
	_poly(ember, [Vector2i(8, 0), Vector2i(13, 5), Vector2i(14, 10), Vector2i(10, 15), Vector2i(4, 13), Vector2i(2, 8), Vector2i(5, 4)], INK)
	_poly(ember, [Vector2i(8, 3), Vector2i(11, 6), Vector2i(12, 10), Vector2i(9, 13), Vector2i(5, 11), Vector2i(5, 8)], Color("#d64f3f"))
	_poly(ember, [Vector2i(8, 5), Vector2i(10, 8), Vector2i(9, 11), Vector2i(6, 10), Vector2i(7, 8)], Color("#ffbd58"))
	_rect(ember, 8, 7, 2, 3, Color("#fff1b1"))
	_save(ember, "ember_orb.png")

func _generate_props() -> void:
	var crystal := _image(40, 40)
	_poly(crystal, [Vector2i(3, 32), Vector2i(10, 26), Vector2i(12, 12), Vector2i(18, 7), Vector2i(22, 14), Vector2i(29, 4), Vector2i(34, 12), Vector2i(37, 31), Vector2i(30, 35), Vector2i(9, 35)], INK)
	_poly(crystal, [Vector2i(7, 30), Vector2i(12, 26), Vector2i(14, 14), Vector2i(18, 10), Vector2i(22, 18), Vector2i(29, 8), Vector2i(32, 14), Vector2i(34, 30), Vector2i(29, 32), Vector2i(11, 32)], Color("#3d6c80"))
	_poly(crystal, [Vector2i(15, 15), Vector2i(18, 11), Vector2i(20, 20), Vector2i(18, 27), Vector2i(14, 25)], Color("#b4eff3"))
	_poly(crystal, [Vector2i(29, 12), Vector2i(31, 16), Vector2i(32, 27), Vector2i(29, 29), Vector2i(27, 21)], Color("#71c6d6"))
	_rect(crystal, 8, 33, 25, 2, Color("#263343"))
	_save(crystal, "ice_crystal_prop.png")

	var pillar := _image(48, 48)
	_poly(pillar, [Vector2i(3, 39), Vector2i(7, 33), Vector2i(13, 35), Vector2i(18, 29), Vector2i(25, 34), Vector2i(34, 30), Vector2i(41, 36), Vector2i(45, 39), Vector2i(40, 44), Vector2i(8, 44)], INK)
	_rect(pillar, 8, 8, 32, 6, INK)
	_rect(pillar, 10, 10, 28, 4, Color("#7d8996"))
	_rect(pillar, 11, 15, 26, 22, Color("#303847"))
	_rect(pillar, 14, 16, 20, 18, Color("#596577"))
	_rect(pillar, 17, 16, 4, 17, Color("#83909c"))
	_rect(pillar, 30, 19, 4, 13, Color("#3d495b"))
	_rect(pillar, 10, 24, 28, 3, Color("#3c4656"))
	_rect(pillar, 13, 37, 22, 4, Color("#465367"))
	_rect(pillar, 6, 40, 36, 3, Color("#151b26"))
	_rect(pillar, 19, 19, 10, 10, INK)
	_rect(pillar, 21, 21, 6, 6, Color("#39677b"))
	_rect(pillar, 23, 22, 2, 4, CYAN)
	_rect(pillar, 11, 6, 7, 2, Color("#a2afb9"))
	_rect(pillar, 29, 6, 7, 2, Color("#a2afb9"))
	_save(pillar, "broken_pillar_prop.png")

	var rubble := _image(40, 28)
	_poly(rubble, [Vector2i(2, 21), Vector2i(6, 13), Vector2i(14, 14), Vector2i(18, 7), Vector2i(24, 12), Vector2i(33, 9), Vector2i(38, 17), Vector2i(35, 23), Vector2i(7, 25)], INK)
	_poly(rubble, [Vector2i(5, 20), Vector2i(9, 15), Vector2i(15, 16), Vector2i(19, 10), Vector2i(23, 15), Vector2i(32, 12), Vector2i(35, 18), Vector2i(33, 21), Vector2i(9, 23)], Color("#566174"))
	_rect(rubble, 9, 14, 6, 3, Color("#7d8997"))
	_rect(rubble, 19, 11, 4, 5, Color("#84909b"))
	_rect(rubble, 25, 15, 7, 3, Color("#3d4959"))
	_rect(rubble, 4, 23, 31, 2, Color("#171d28"))
	_save(rubble, "rubble_prop.png")
