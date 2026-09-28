# Tests del arte provisional (T70-T72, spec §9.6).
# Cómo SE VE se revisa con capturas; aquí se comprueba que cada pieza tiene su dibujo,
# que los dibujos se importaron bien (D-023) y que el juego funciona igual sin dibujos (RF-156).
# Los tests que esperan frames dejan que Godot llame a _draw(): si el dibujo tuviera un
# error, GUT marcaría el test como fallado.
extends GutTest

const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")
const TOWER_SCENE: PackedScene = preload("res://scenes/towers/tower.tscn")
const ENEMY_SCENE: PackedScene = preload("res://scenes/enemies/enemy.tscn")
const ENEMY_IDS: Array[String] = ["normal", "fast", "tank", "flyer", "armored", "boss"]
const DT: float = 1.0 / 60.0
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


# --- Enemigos (RF-151, RF-152, RF-156) ---

func _enemy_data(id: String) -> EnemyData:
	return load("res://data/enemies/%s.tres" % id)


## Un enemigo Normal caminando por un camino que pasa por `points`.
func _walker(points: Array[Vector2], data: EnemyData = null) -> Enemy:
	var path := Path2D.new()
	path.curve = Curve2D.new()
	for point: Vector2 in points:
		path.curve.add_point(point)
	add_child_autofree(path)
	var enemy: Enemy = ENEMY_SCENE.instantiate()
	enemy.setup(data if data != null else _enemy_data("normal"), path, 30)
	add_child_autofree(enemy)
	return enemy


func test_every_enemy_has_its_drawing() -> void:
	for id: String in ENEMY_IDS:
		var texture: Texture2D = _enemy_data(id).texture
		assert_not_null(texture, "%s: dibujo" % id)
		if texture != null:
			assert_eq(texture.resource_path, "res://assets/sprites/enemies/%s.svg" % id)
			assert_eq(texture.get_size(), SPRITE_SIZE, "%s: importado al doble" % id)


func test_walking_right_faces_right() -> void:
	var enemy: Enemy = _walker([Vector2(100, 100), Vector2(400, 100)])
	simulate(enemy, 10, DT)
	assert_false(enemy.is_facing_left())


func test_walking_left_faces_left() -> void:
	var enemy: Enemy = _walker([Vector2(400, 100), Vector2(100, 100)])
	simulate(enemy, 10, DT)
	assert_true(enemy.is_facing_left(), "RF-151: se da vuelta")


func test_going_down_keeps_facing_where_it_was() -> void:
	# Camina 100 px hacia la izquierda y después baja: al bajar sigue mirando a la izquierda.
	var enemy: Enemy = _walker([Vector2(300, 100), Vector2(200, 100), Vector2(200, 500)])
	simulate(enemy, 150, DT)  # 1,5 casillas por segundo → ya está bajando
	assert_gt(enemy.global_position.y, 150.0, "ya dobló hacia abajo")
	assert_true(enemy.is_facing_left(), "RF-151: al subir o bajar no se da vuelta")


func test_every_enemy_is_drawn_hit_and_slowed() -> void:
	for id: String in ENEMY_IDS:
		var enemy: Enemy = _walker([Vector2(400, 100), Vector2(100, 100)], _enemy_data(id))
		enemy.take_hit(1, 0.5, 2.0)  # golpe (RF-123) y ralentización (RF-152)
	await wait_process_frames(2)
	assert_true(true, "se dibujaron sin errores")


func test_an_enemy_without_drawing_still_works() -> void:
	# RF-156: datos sin dibujo → la forma de antes.
	var data := EnemyData.new()
	data.id = &"test"
	data.max_health = 10
	data.speed_tiles = 1.0
	data.size_tiles = 0.25
	data.shape = EnemyData.Shape.TRIANGLE
	var enemy: Enemy = _walker([Vector2(100, 100), Vector2(400, 100)], data)
	enemy.take_hit(1, 0.5, 2.0)
	await wait_process_frames(2)
	assert_null(data.texture)
	assert_true(enemy.is_active(), "se dibujó sin errores")


func test_hit_flash_is_a_white_silhouette_of_the_drawing() -> void:
	# RF-123: misma forma (misma opacidad en cada píxel), pero toda blanca.
	var texture: Texture2D = _enemy_data("tank").texture
	var original: Image = texture.get_image()
	var flash: Image = EnemyShape.flash_texture(texture).get_image()
	assert_eq(flash.get_size(), original.get_size())
	var body: Color = original.get_pixel(40, 70)  # marrón del cuerpo
	assert_almost_eq(body.a, 1.0, 0.01, "ahí hay cuerpo")
	assert_eq(flash.get_pixel(40, 70), Color(1, 1, 1, 1), "en la silueta es blanco")
	assert_eq(flash.get_pixel(2, 2).a, original.get_pixel(2, 2).a, "fuera del dibujo, transparente")
	assert_eq(texture.get_image().get_pixel(40, 70), body, "el dibujo original no cambia")
	assert_same(EnemyShape.flash_texture(texture), EnemyShape.flash_texture(texture), "se arma una sola vez")
