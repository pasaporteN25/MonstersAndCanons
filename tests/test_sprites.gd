# Tests del arte provisional (T70-T72, spec §9.6).
# Cómo SE VE se revisa con capturas; aquí se comprueba que cada pieza tiene su dibujo,
# que los dibujos se importaron bien (D-023) y que el juego funciona igual sin dibujos (RF-156).
# Los tests que esperan frames dejan que Godot llame a _draw(): si el dibujo tuviera un
# error, GUT marcaría el test como fallado.
extends GutTest

const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")
const TOWER_SCENE: PackedScene = preload("res://scenes/towers/tower.tscn")
## D-023: los SVG de 64×64 se importan al doble.
const SPRITE_SIZE := Vector2(128, 128)

var game: Game


func before_each() -> void:
	game = GAME_SCENE.instantiate()
	add_child_autofree(game)


# --- Torres (RF-150, RF-155, RF-156) ---

func test_every_tower_has_a_turret_drawing() -> void:
	for data: TowerData in game.tower_types:
		assert_not_null(data.turret_texture, "%s: torreta" % data.id)
		if data.turret_texture != null:
			assert_eq(data.turret_texture.get_size(), SPRITE_SIZE, "%s: importada al doble" % data.id)


func test_each_level_has_its_own_base() -> void:
	for data: TowerData in game.tower_types:
		for i: int in data.levels.size():
			var base: Texture2D = data.levels[i].base_texture
			assert_not_null(base, "%s, nivel %d: base" % [data.id, i + 1])
			if base != null:
				assert_eq(base.resource_path, "res://assets/sprites/towers/base_%d.svg" % (i + 1),
					"%s, nivel %d: madera, piedra, piedra con oro" % [data.id, i + 1])
				assert_eq(base.get_size(), SPRITE_SIZE)


func test_tower_buttons_show_the_tower() -> void:
	var buttons: Array[Button] = game.hud._tower_buttons
	for i: int in game.tower_types.size():
		var icon: Texture2D = buttons[i].icon
		assert_true(icon is ImageTexture, "RF-155: ícono armado con base + torreta")
		assert_eq(icon.get_size(), SPRITE_SIZE)


func test_tower_icon_is_the_base_with_the_turret_on_top() -> void:
	var cannon: TowerData = game.tower_types[1]
	var wood: Color = cannon.levels[0].base_texture.get_image().get_pixel(64, 64)
	var icon: Image = Tower.make_icon(cannon).get_image()
	var base: Image = cannon.levels[0].base_texture.get_image()
	assert_eq(base.get_pixel(64, 64), wood, "armar el ícono no cambia la base del mapa")
	# En el centro está la torreta (oscura) y no la madera de la base.
	assert_ne(icon.get_pixel(64, 64), base.get_pixel(64, 64), "la torreta tapa el centro")
	# Abajo, fuera de la torreta, se sigue viendo la madera.
	assert_eq(icon.get_pixel(64, 108), base.get_pixel(64, 108), "abajo, la madera de la base")


func test_tower_without_drawings_gets_no_icon() -> void:
	assert_null(Tower.make_icon(TowerData.new()), "RF-156: el HUD usa el cuadradito de color")


func test_towers_of_every_level_are_drawn() -> void:
	game.session.earn(5000)
	var cells: Array[Vector2i] = [Vector2i(4, 2), Vector2i(8, 2), Vector2i(12, 2), Vector2i(4, 5)]
	for i: int in game.tower_types.size():
		assert_true(game.build_controller.try_build(game.tower_types[i], cells[i]))
	await wait_process_frames(2)  # nivel 1
	for cell: Vector2i in cells:
		game.build_controller.try_upgrade(game.build_controller.tower_at(cell))
	await wait_process_frames(2)  # nivel 2
	for cell: Vector2i in cells:
		game.build_controller.try_upgrade(game.build_controller.tower_at(cell))
	await wait_process_frames(2)  # nivel 3
	assert_eq(game.build_controller.tower_at(cells[0]).level_number(), 3)


func test_a_tower_without_drawings_still_works() -> void:
	# RF-156: datos sin dibujos (como los que arman muchos tests) → cuadrado de color.
	var level := TowerLevelData.new()
	level.cost = 10
	level.range_tiles = 2.0
	level.fire_rate = 1.0
	var data := TowerData.new()
	data.levels.append(level)
	var tower: Tower = TOWER_SCENE.instantiate()
	tower.setup(data)
	add_child_autofree(tower)
	await wait_process_frames(2)
	assert_null(data.turret_texture)
	assert_eq(tower.level_number(), 1, "se creó y se dibujó sin errores")
