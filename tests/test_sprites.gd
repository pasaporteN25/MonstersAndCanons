# Tests del arte provisional (T70-T72, spec §9.6).
# Cómo SE VE se revisa con capturas; aquí se comprueba que cada pieza tiene su dibujo,
# que los dibujos se importaron bien (D-023) y que el juego funciona igual sin dibujos (RF-156).
# Los tests que esperan frames dejan que Godot llame a _draw(): si el dibujo tuviera un
# error, GUT marcaría el test como fallado.
extends GutTest

const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")
const TOWER_SCENE: PackedScene = preload("res://scenes/towers/tower.tscn")
const ENEMY_SCENE: PackedScene = preload("res://scenes/enemies/enemy.tscn")
const PROJECTILE_SCENE: PackedScene = preload("res://scenes/towers/projectile.tscn")
const ENEMY_IDS: Array[String] = ["normal", "fast", "tank", "flyer", "armored", "troll", "spider", "spiderling", "guardian", "healer", "shaman", "mirror", "boss", "rammer", "thief"]
const DT: float = 1.0 / 60.0
## D-023: los SVG de 64×64 se importan al doble.
const SPRITE_SIZE := Vector2(128, 128)
## M29: los trece monstruos con PNG estático de256×256; la partida también admite atlas.
const RENDERED_IDS: Array[String] = ["normal", "fast", "tank", "flyer", "armored", "troll", "spider", "spiderling", "guardian", "healer", "shaman", "mirror", "boss", "rammer", "thief"]
const RENDERED_SIZE := Vector2(256, 256)
## Los pies caen al 74,55 % del alto del lienzo (tools/prepare_monster_sprites.gd, FOOT_LINE).
const FOOT_ROW: int = 191
## Número de balance de cada uno ANTES de M24: id → [vida, velocidad, armadura, recompensa, vidas, tamaño].
const UNCHANGED_STATS: Dictionary = {
	"normal": [30, 1.5, 0, 5, 1, 0.25],
	"fast": [18, 3.0, 0, 4, 1, 0.2],
	"tank": [135, 0.8, 0, 15, 2, 0.35],
}

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
				assert_eq(base.resource_path, "res://assets/sprites/towers/rendered/base_%d.png" % (i + 1),
					"%s, nivel %d: base renderizada del nivel" % [data.id, i + 1])
				assert_eq(base.get_size(), SPRITE_SIZE)


func test_tower_buttons_show_the_tower() -> void:
	var buttons: Array[Button] = game.hud._tower_buttons
	for i: int in game.available_towers.size():
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
	# En el borde, fuera del mecanismo, se sigue viendo la base.
	assert_gt(icon.get_pixel(64, 104).a, 0.5, "la base sigue visible debajo del mecanismo")
	assert_lt(icon.get_pixel(0, 0).a, 0.01, "el icono conserva margen transparente")


func test_tower_without_drawings_gets_no_icon() -> void:
	assert_null(Tower.make_icon(TowerData.new()), "RF-156: el HUD usa el cuadradito de color")


func test_towers_of_every_level_are_drawn() -> void:
	game.session.earn(5000)
	game.session.add_resources(10)  # RF-420: el Mortero cuesta recursos
	# Casillas libres del nivel 1, una por torre (las ocho de una casilla).
	var cells: Array[Vector2i] = [Vector2i(1, 2), Vector2i(4, 2), Vector2i(8, 2), Vector2i(11, 2),
		Vector2i(5, 6), Vector2i(8, 6), Vector2i(15, 6), Vector2i(18, 6)]
	for i: int in cells.size():
		assert_true(game.build_controller.try_build(game.tower_types[i], cells[i]))
	# Las torres de 2×2 (M19) se ponen donde haya un cuadrado libre.
	for i: int in range(cells.size(), game.tower_types.size()):
		var big: TowerData = game.tower_types[i]
		var origin := Vector2i(-1, -1)
		for y: int in range(0, 8):
			for x: int in range(0, 19):
				if origin.x < 0 and game.build_controller.cells_free(big, Vector2i(x, y)):
					origin = Vector2i(x, y)
		assert_true(game.build_controller.try_build(big, origin), "%s cabe en el nivel 1" % big.id)
		cells.append(origin)
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
			if RENDERED_IDS.has(id):
				assert_eq(texture.resource_path, "res://assets/sprites/enemies/rendered/%s%s.png" % [id, "_m43" if id in ["healer","rammer","thief"] else ""])
				assert_eq(texture.get_size(), RENDERED_SIZE, "%s: PNG de producción" % id)
			else:
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
	var body: Color = original.get_pixel(128, 130)  # piedra y piel del cuerpo, al centro
	assert_gt(body.a, 0.9, "ahí hay cuerpo")
	assert_eq(flash.get_pixel(128, 130), Color(1, 1, 1, body.a), "en la silueta es blanco, con la misma opacidad")
	assert_eq(flash.get_pixel(2, 2).a, original.get_pixel(2, 2).a, "fuera del dibujo, transparente")
	assert_eq(texture.get_image().get_pixel(128, 130), body, "el dibujo original no cambia")
	assert_same(EnemyShape.flash_texture(texture), EnemyShape.flash_texture(texture), "se arma una sola vez")


# --- Proyectiles y mapa (RF-153, RF-154) ---

func test_every_tower_has_its_projectile() -> void:
	for data: TowerData in game.tower_types:
		var texture: Texture2D = data.projectile_texture
		assert_not_null(texture, "%s: proyectil" % data.id)
		if texture != null:
			assert_eq(texture.resource_path, "res://assets/sprites/projectiles/rendered/%s.png" % data.id)
			assert_eq(texture.get_size(), Vector2(64, 64), "%s: 32×32 importado al doble" % data.id)


func test_projectile_points_at_its_target() -> void:
	var enemy: Enemy = _walker([Vector2(100, 400), Vector2(60, 400)])
	var basic: TowerData = game.tower_types[0]
	var start := Vector2(400, 100)
	var projectile: Projectile = PROJECTILE_SCENE.instantiate()
	projectile.setup(enemy, start, basic.levels[0], true, 10.0, basic.color, basic.projectile_texture)
	add_child_autofree(projectile)
	assert_almost_eq(projectile.rotation, (enemy.global_position - start).angle(), 0.01,
		"RF-153: apunta hacia abajo a la izquierda, donde está el enemigo")
	await wait_process_frames(2)  # se dibuja con su dibujo sin errores


func test_blocked_cells_always_show_the_same_thing() -> void:
	var different: int = 0
	var shown: Dictionary = {}
	for x: int in 20:
		for y: int in 9:
			var cell := Vector2i(x, y)
			if LevelDecor.blocked_decor(cell) != LevelDecor.blocked_decor(cell):
				different += 1
			shown[LevelDecor.blocked_decor(cell).resource_path] = true
	assert_eq(different, 0, "cada casilla elige siempre lo mismo")
	assert_eq(shown.size(), 4, "en un mapa aparecen rocas, piedras, árboles y arbustos")


func test_every_level_map_is_drawn() -> void:
	for level: LevelData in GameFlow.campaign.levels:
		add_child_autofree(level.build_map())
	await wait_process_frames(2)
	assert_true(true, "los mapas (con rocas, árboles y puertas) se dibujaron sin errores")


# --- Monstruos M24: PNG de producción de una sola vista (RF-329, RF-330, D-050) ---

## El rectángulo del cuerpo de una textura: los píxeles con más de 10 % de opacidad, como los cuenta
## tools/prepare_monster_sprites.gd.
func _body_rect(texture: Texture2D) -> Rect2i:
	var image: Image = texture.get_image()
	var low := Vector2i(image.get_width(), image.get_height())
	var high := Vector2i(-1, -1)
	for y: int in image.get_height():
		for x: int in image.get_width():
			if image.get_pixel(x, y).a > 0.1:
				low = Vector2i(mini(low.x, x), mini(low.y, y))
				high = Vector2i(maxi(high.x, x), maxi(high.y, y))
	return Rect2i(low, high - low + Vector2i.ONE) if high.x >= 0 else Rect2i()


func test_rendered_monsters_keep_their_alpha_and_have_margins() -> void:
	for id: String in RENDERED_IDS:
		var image: Image = _enemy_data(id).texture.get_image()
		assert_true(image.detect_alpha() != Image.ALPHA_NONE, "%s: conserva el alfa" % id)
		assert_lt(image.get_pixel(0, 0).a, 0.01, "%s: la esquina es transparente" % id)
		var rect: Rect2i = _body_rect(_enemy_data(id).texture)
		assert_gt(rect.size.x, 100, "%s: tiene cuerpo" % id)
		assert_gte(rect.position.x, 1, "%s: margen izquierdo" % id)
		assert_lte(rect.end.x, 255, "%s: margen derecho" % id)
		assert_gte(rect.position.y, 1, "%s: margen de arriba" % id)


func test_rendered_monsters_stand_on_the_same_ground_line() -> void:
	for id: String in RENDERED_IDS:
		var rect: Rect2i = _body_rect(_enemy_data(id).texture)
		assert_eq(rect.end.y, FOOT_ROW, "%s: los pies apoyan a la misma altura" % id)
		# El cuerpo no sube más de lo que EnemyShape.sprite_top deja para la barra de vida.
		# (en unidades del radio; el dibujo se sube side / 32 respecto del centro)
		var top_above_center: float = (128.0 - rect.position.y) / 256.0 * EnemyShape.SPRITE_SCALE + EnemyShape.SPRITE_SCALE / 32.0
		assert_lte(top_above_center, EnemyShape.sprite_top(1.0) + 0.05, "%s: la cabeza no pasa de sprite_top" % id)


func test_rendered_monsters_do_not_flip_and_the_others_do() -> void:
	for id: String in ENEMY_IDS:
		var data: EnemyData = _enemy_data(id)
		assert_eq(data.flip_when_walking_left, not RENDERED_IDS.has(id), "%s: espejo" % id)
		var enemy: Enemy = _walker([Vector2(400, 100), Vector2(100, 100)], data)
		simulate(enemy, 10, DT)
		assert_true(enemy.is_facing_left(), "%s: camina hacia la izquierda" % id)
		assert_eq(enemy.is_drawn_mirrored(), data.flip_when_walking_left, "%s: dibujo reflejado" % id)


func test_rendered_monsters_keep_their_balance_numbers() -> void:
	for id: String in UNCHANGED_STATS:
		var data: EnemyData = _enemy_data(id)
		var expected: Array = UNCHANGED_STATS[id]
		assert_eq(data.max_health, expected[0], "%s: vida" % id)
		assert_eq(data.speed_tiles, expected[1], "%s: velocidad" % id)
		assert_eq(data.armor, expected[2], "%s: armadura" % id)
		assert_eq(data.reward, expected[3], "%s: recompensa" % id)
		assert_eq(data.lives_damage, expected[4], "%s: vidas" % id)
		assert_eq(data.size_tiles, expected[5], "%s: tamaño (colisión y selección)" % id)
		assert_false(data.is_flying, "%s: no vuela" % id)


func test_rendered_monsters_draw_every_state_without_errors() -> void:
	# Parpadeo, ralentización, quemadura y barra de vida (RF-123, RF-152, RF-158, RF-82) con el PNG nuevo.
	for id: String in RENDERED_IDS:
		var enemy: Enemy = _walker([Vector2(400, 100), Vector2(100, 100)], _enemy_data(id))
		enemy.take_hit(1, 0.5, 2.0)
		enemy.apply_burn(2, 2.0)
	await wait_process_frames(3)
	assert_true(true, "se dibujaron sin errores")
