# B-21 v2 · Laboratorio de vista. Arma la MISMA escena de partida (Pradera, mismas torres, monstruos y
# vista previa de construcción) con cuatro presentaciones y la fotografía; o mide el costo de cada una
# con la carga de tools/perf_test.gd (200 monstruos, 60 torres disparando, números y muertes).
# No toca producción, mapas ni guardados (guarda en user://test_b21_vista.json).
#
# Uso (con ventana: hace falta dibujar de verdad), desde la carpeta del proyecto:
#   godot --path . res://art/b21-vista/vista_lab.tscn -- jugar variante=C       (el nivel 1 jugable)
#   godot --path . res://art/b21-vista/vista_lab.tscn -- capturas [solo=B] [horneado]
#   godot --path . res://art/b21-vista/vista_lab.tscn -- medidas                 (casillas y clics)
#   godot --path . res://art/b21-vista/vista_lab.tscn -- rendimiento variante=B [horneado] [sin_orden]
# Variantes: A actual · B relieve en la misma cuadrícula · C oblicua comprimida · D maqueta 3D.
# Conviene apuntar APPDATA a una carpeta temporal para no mezclar registros con los del juego.
extends Node

const OUT: String = "res://art/b21-vista/"
const RELIEF := preload("res://art/b21-vista/relief_layer.gd")
const DIORAMA := preload("res://art/b21-vista/diorama_3d.gd")
const VARIANTS: PackedStringArray = ["A", "B", "C", "D"]
const TITLES: Dictionary = {
	"A": "A · Actual: 2D cenital, sin cambios",
	"B": "B · Relieve en la misma cuadrícula",
	"C": "C · Oblicua: suelo al 80 % + relieve",
	"D": "D · Maqueta 3D real + dibujos actuales",
}
## C: el suelo se ve al 80 % de su alto (una cámara a unos 53° sobre el horizonte).
const OBLIQUE_K: float = 0.8
const WALL_PX: float = 16.0
const FRONT_PX: float = 40.0
## [índice en Game.tower_types, casilla]. Algunas quedan al sur del camino (los monstruos pasan
## detrás) y otras al norte (pasan delante), para ver el orden de dibujo.
const TOWERS: Array = [[0, Vector2i(5, 2)], [1, Vector2i(6, 5)], [2, Vector2i(9, 3)], [3, Vector2i(17, 2)],
	[5, Vector2i(11, 0)], [7, Vector2i(13, 6)], [6, Vector2i(8, 8)]]
## [enemigo, píxeles recorridos por el camino terrestre de la entrada A].
const ENEMIES: Array = [["thief", 160], ["normal", 384], ["fast", 557], ["armored", 800], ["tank", 1184],
	["shaman", 1536], ["spider", 1728], ["troll", 1920], ["guardian", 2208], ["boss", 2624],
	["healer", 2816], ["mirror", 2976], ["normal", 3200]]
const DAMAGED: PackedStringArray = ["armored", "tank", "troll", "boss", "healer"]
const PREVIEW_TOWER: StringName = &"fire"
const PREVIEW_CELL := Vector2i(14, 2)
## Recorte de detalle, en coordenadas globales del mundo 2D: cañón, fila 4 y vuelta de la fila 7.
const DETAIL := Rect2(128, 48 + 192, 576, 352)
const STRESS_ENEMIES: int = 200
const STRESS_TOWERS: int = 60
const DEATHS_PER_SECOND: float = 15.0
const WARMUP_SECONDS: float = 1.0
const MEASURE_SECONDS: float = 6.0

var _diorama: Node3D
## Solo para medir: relieve horneado en una textura (como en producción) y orden por profundidad.
var _bake: bool = false
var _y_sort: bool = true
var _camera: Camera2D
## Modo jugar: la partida en curso (en D los clics pasan por la cámara 3D).
var _play_game: Game
var _normal: EnemyData = preload("res://data/enemies/normal.tres")


func _ready() -> void:
	SaveManager.save_path = "user://test_b21_vista.json"
	call_deferred("run")


func run() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	_bake = "horneado" in args
	_y_sort = not "sin_orden" in args
	if "jugar" in args:
		await _play(_variant_arg(args))
		return  # se juega hasta cerrar la ventana
	if "medidas" in args:
		await _measurements()
	elif "rendimiento" in args:
		await _measure(_variant_arg(args))
	else:
		await _captures()
	get_tree().quit()


func _variant_arg(args: PackedStringArray) -> String:
	for arg: String in args:
		if arg.begins_with("variante="):
			return arg.trim_prefix("variante=").to_upper()
	return "A"


# --- Jugar: el nivel 1 completo con la vista elegida (para probarla en movimiento) ---

func _play(variant: String) -> void:
	_bake = true
	var game: Game = await _new_game()
	await _apply_variant(game, variant)
	_play_game = game
	if variant == "D":
		game.effects.visible = false  # los efectos 2D no coinciden con la perspectiva (no portados)
		game.build_controller.set_process_unhandled_input(false)
		var input: Node = preload("res://art/b21-vista/d_input.gd").new()
		input.handler = _d_input
		game.add_child(input)
		game.move_child(input, game.build_controller.get_index() + 1)
	if "autoprueba" in OS.get_cmdline_user_args():
		await _self_test(game, variant)
		get_tree().quit()


## Tecla 5 (Incendiaria), tres torres, Escape, oleada 1 y una foto en pleno combate. En D los clics se
## simulan sobre la pantalla y pasan por el rayo de la cámara; en las demás vistas el clic real usa
## el mouse del sistema, así que se construye directo (la conversión ya la prueba el modo medidas).
func _self_test(game: Game, variant: String) -> void:
	const CELLS: Array[Vector2i] = [Vector2i(7, 3), Vector2i(12, 6), Vector2i(4, 8)]
	game.session.earn(500)
	await get_tree().create_timer(0.5).timeout
	_push_key(KEY_5)
	for cell: Vector2i in CELLS:
		if variant == "D":
			var click := InputEventMouseButton.new()
			click.button_index = MOUSE_BUTTON_LEFT
			click.pressed = true
			click.position = _diorama.screen_of_cell(cell)
			click.global_position = click.position
			get_viewport().push_input(click, true)
			var release: InputEventMouseButton = click.duplicate()
			release.pressed = false
			get_viewport().push_input(release, true)
		else:
			game.build_controller.try_build(game.build_controller.selected_tower(), cell)
		await get_tree().process_frame
	_push_key(KEY_ESCAPE)
	var built: int = 0
	for cell: Vector2i in CELLS:
		if game.build_controller.tower_at(cell) != null:
			built += 1
	game.start_next_wave()
	await get_tree().create_timer(7.0).timeout
	await RenderingServer.frame_post_draw
	var image: Image = get_viewport().get_texture().get_image()
	image.save_jpg(OUT + "jugar_%s.jpg" % variant.to_lower(), 0.9)
	print("AUTOPRUEBA_B21 ", JSON.stringify({"variante": variant, "torres_pedidas": CELLS.size(), "torres_construidas": built,
		"modo_construccion_cerrado": game.build_controller.selected_tower() == null,
		"enemigos_en_pantalla": game.enemies.get_child_count(), "oro": game.session.gold}))


func _push_key(keycode: Key) -> void:
	for pressed: bool in [true, false]:
		var key := InputEventKey.new()
		key.physical_keycode = keycode
		key.keycode = keycode
		key.pressed = pressed
		get_viewport().push_input(key)


## D: los clics del mapa pasan por un rayo de la cámara 3D; el resto (teclas, clic derecho) sigue igual.
func _d_input(event: InputEvent) -> void:
	var controller: BuildController = _play_game.build_controller
	var click := event as InputEventMouseButton
	if click != null and click.pressed and click.button_index == MOUSE_BUTTON_LEFT:
		var cell: Vector2i = _diorama.cell_at_screen(click.position)
		if controller.selected_tower() != null:
			controller.try_build(controller.selected_tower(), cell)
		elif _play_game.level.is_inside(cell):
			var tower: Tower = controller.tower_at(cell)
			if tower != null:
				controller.select_placed(tower)
			else:
				controller.deselect_placed()
		get_viewport().set_input_as_handled()
		return
	controller._unhandled_input(event)


func _process(_delta: float) -> void:
	if _diorama == null or _play_game == null:
		return
	var controller: BuildController = _play_game.build_controller
	var cell: Vector2i = _diorama.cell_at_screen(get_viewport().get_mouse_position())
	var building: TowerData = controller.selected_tower()
	var placed: Tower = controller.selected_placed()
	if building != null and _play_game.level.is_inside(cell):
		_diorama.update_preview(cell, building, building.levels[0].range_tiles, true, controller.can_build(building, cell))
	elif placed != null:
		_diorama.update_preview(placed.origin_cell, null, placed.range_px() / Rules.TILE_SIZE, false, true)
	else:
		_diorama.update_preview(Vector2i.ZERO, null, 0.0, false, true)


# --- Capturas ---

func _captures() -> void:
	var shots: Dictionary = {}
	var crops: Dictionary = {}
	var only: String = ""
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("solo="):
			only = arg.trim_prefix("solo=").to_upper()
	for variant: String in VARIANTS:
		if only != "" and variant != only:
			continue
		var game: Game = await _new_game()
		_populate_scene(game)
		await get_tree().create_timer(0.35).timeout  # la torre aparece creciendo (RF-130)
		await _apply_variant(game, variant)
		if variant == "D":
			_diorama.show_preview(PREVIEW_CELL, game.available_towers[_preview_index(game)])
		for i: int in 3:
			await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var image: Image = get_viewport().get_texture().get_image()
		image.save_jpg(OUT + "vista_%s.jpg" % variant.to_lower(), 0.9)
		shots[variant] = image
		var factor: Vector2 = Vector2(image.get_size()) / Rules.SCREEN_SIZE  # la ventana puede ser más grande que 1280×720
		var detail: Rect2 = Rect2(_detail_rect(game, variant))
		crops[variant] = image.get_region(Rect2i(Rect2(detail.position * factor, detail.size * factor)))
		await _teardown(game)
	if only != "":
		return
	await _sheet(shots, "comparacion_vistas.jpg", false)
	await _sheet(crops, "comparacion_detalle.jpg", true)


func _populate_scene(game: Game) -> void:
	game.session.earn(100000)
	var towers: Array[Tower] = []
	for entry: Array in TOWERS:
		game.build_controller.try_build(game.tower_types[entry[0]], entry[1])
		towers.append(game.build_controller.tower_at(entry[1]))
	var enemies: Array[Enemy] = []
	for entry: Array in ENEMIES:
		enemies.append(_place_enemy(game, load("res://data/enemies/%s.tres" % entry[0]), game.level.get_ground_path(0), entry[1]))
	var air: Path2D = game.level.get_air_path(0)
	enemies.append(_place_enemy(game, preload("res://data/enemies/flyer.tres"), air, air.curve.get_baked_length() * 0.42))
	for enemy: Enemy in enemies:
		if DAMAGED.has(String(enemy.data.id)):
			enemy.health = int(enemy.max_health * 0.55)
		enemy.queue_redraw()
	for tower: Tower in towers:
		tower.set_physics_process(false)
		var nearest: Enemy = enemies[0]
		for enemy: Enemy in enemies:
			if enemy.global_position.distance_to(tower.global_position) < nearest.global_position.distance_to(tower.global_position):
				nearest = enemy
		tower.aim_angle = (nearest.global_position - tower.global_position).angle()
		tower.queue_redraw()
	# Vista previa de construcción (RF-40): casilla, torre fantasma y alcance.
	game.build_controller.select(_preview_index(game))
	game.build_controller.set_process(false)
	game.build_controller._hover_cell = PREVIEW_CELL
	game.build_controller.queue_redraw()


func _place_enemy(game: Game, data: EnemyData, path: Path2D, distance: float) -> Enemy:
	var enemy: Enemy = preload("res://scenes/enemies/enemy.tscn").instantiate()
	enemy.setup(data, path, data.max_health)
	enemy.distance = distance
	game.enemies.add_child(enemy)
	enemy.set_physics_process(false)
	for i: int in 20:
		enemy._animate(0.05)  # que termine de girar hacia donde camina
	return enemy


func _preview_index(game: Game) -> int:
	for i: int in game.available_towers.size():
		if game.available_towers[i].id == PREVIEW_TOWER:
			return i
	return 0


## Rectángulo de pantalla que muestra la zona DETAIL en cada variante.
func _detail_rect(game: Game, variant: String) -> Rect2i:
	var corners: Array[Vector2] = [DETAIL.position, Vector2(DETAIL.end.x, DETAIL.position.y), DETAIL.end, Vector2(DETAIL.position.x, DETAIL.end.y)]
	var points: Array[Vector2] = []
	for p: Vector2 in corners:
		match variant:
			"C":
				points.append(Vector2(p.x, Rules.SCREEN_SIZE.y / 2.0 + (p.y - _camera.position.y) * OBLIQUE_K))
			"D":
				var local: Vector2 = (p - game.level.position) / DIORAMA.UNIT
				points.append(_diorama.camera.unproject_position(Vector3(local.x, 0.0, local.y)))
			_:
				points.append(p)
	var rect := Rect2(points[0], Vector2.ZERO)
	for p: Vector2 in points:
		rect = rect.expand(p)
	# Un margen arriba para que se vean las torres y monstruos de la primera fila.
	rect = rect.grow_individual(0, 40, 0, 0)
	return Rect2i(rect).intersection(Rect2i(Vector2i.ZERO, Vector2i(Rules.SCREEN_SIZE)))


## Hoja 2×2 con títulos: las cuatro vistas completas o los cuatro recortes.
func _sheet(images: Dictionary, file: String, fit: bool) -> void:
	var holder := Control.new()
	holder.size = Rules.SCREEN_SIZE
	var background := ColorRect.new()
	background.color = Color(0.12, 0.12, 0.13)
	background.size = Rules.SCREEN_SIZE
	holder.add_child(background)
	var cell_size: Vector2 = Rules.SCREEN_SIZE / 2.0
	for i: int in VARIANTS.size():
		var variant: String = VARIANTS[i]
		var origin := Vector2(i % 2, i / 2) * cell_size
		var picture := TextureRect.new()
		picture.texture = ImageTexture.create_from_image(images[variant])
		picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED if fit else TextureRect.STRETCH_SCALE
		picture.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		picture.position = origin + Vector2(2, 2)
		picture.size = cell_size - Vector2(4, 4)
		holder.add_child(picture)
		var label := Label.new()
		label.text = " %s " % TITLES[variant]
		label.add_theme_font_size_override("font_size", 17)
		var box := StyleBoxFlat.new()
		box.bg_color = Color(0, 0, 0, 0.72)
		box.set_content_margin_all(4)
		label.add_theme_stylebox_override("normal", box)
		label.position = origin + Vector2(8, 6)
		holder.add_child(label)
	var layer := CanvasLayer.new()
	layer.layer = 100
	layer.add_child(holder)
	add_child(layer)
	for i: int in 3:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_jpg(OUT + file, 0.9)
	layer.queue_free()
	await get_tree().process_frame


# --- Variantes ---

func _new_game() -> Game:
	var game: Game = preload("res://scenes/game/game.tscn").instantiate()
	add_child(game)
	await get_tree().process_frame
	return game


func _teardown(game: Game) -> void:
	game.queue_free()
	if _diorama != null:
		_diorama.overlay.queue_free()
		_diorama.queue_free()
		_diorama = null
	_camera = null
	await get_tree().process_frame
	await get_tree().process_frame


func _apply_variant(game: Game, variant: String) -> void:
	match variant:
		"B":
			await _apply_relief(game, 1.0)
		"C":
			await _apply_relief(game, OBLIQUE_K)
		"D":
			_apply_3d(game)


## B y C: relieve dibujado, luz ambiental y orden por profundidad. C además comprime el suelo.
func _apply_relief(game: Game, k: float) -> void:
	var level: Level = game.level
	(level.get_node("Decor") as CanvasItem).visible = false
	var relief: Node2D = RELIEF.new()
	level.add_child(relief)
	relief.setup(level.ground, level.theme, WALL_PX / k, 0.0 if k >= 1.0 else FRONT_PX / k)
	var light: Sprite2D = _light_overlay(level)
	level.add_child(light)
	if _bake:
		await _bake_ground(level, relief, light)
	# Torres, monstruos y decoración se ordenan juntos por su posición vertical (y_sort).
	var actors := Node2D.new()
	actors.name = "Actors"
	actors.y_sort_enabled = _y_sort
	game.add_child(actors)
	game.move_child(actors, game.tower_container.get_index())
	game.tower_container.reparent(actors)
	game.enemies.reparent(actors)
	game.tower_container.y_sort_enabled = _y_sort
	game.enemies.y_sort_enabled = _y_sort
	var props := Node2D.new()
	props.name = "Props"
	props.y_sort_enabled = _y_sort
	props.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	actors.add_child(props)
	for cell: Vector2i in level.ground.get_used_cells():
		if level.ground.get_cell_atlas_coords(cell) != Level.ATLAS_BLOCKED:
			continue
		var texture: Texture2D = LevelDecor.blocked_decor(cell, level.theme)
		var side: float = Rules.TILE_SIZE * (DIORAMA.TREE_SCALE if texture == MapThemes.TREE else 1.0)
		var sprite := Sprite2D.new()
		sprite.texture = texture
		sprite.scale = Vector2.ONE * side / texture.get_width()
		sprite.offset = Vector2(0, (Rules.TILE_SIZE / 2.0 - side / 2.0) / sprite.scale.x)
		sprite.position = level.cell_center(cell)
		sprite.set_meta(&"base_scale", sprite.scale)
		props.add_child(sprite)
	if k >= 1.0:
		return
	# Fondo detrás de la maqueta: con el suelo comprimido sobra alto de pantalla.
	var backdrop := Polygon2D.new()
	backdrop.polygon = PackedVector2Array([Vector2(-400, -600), Vector2(1700, -600), Vector2(1700, 1400), Vector2(-400, 1400)])
	backdrop.color = Color(0.16, 0.15, 0.14)
	game.add_child(backdrop)
	game.move_child(backdrop, 0)
	# C: la cámara comprime el mundo en vertical. Los clics siguen funcionando porque
	# get_global_mouse_position() deshace la transformación de la cámara.
	_camera = Camera2D.new()
	_camera.zoom = Vector2(1.0, k)
	var size: Vector2i = level.map_size()
	var map_h: float = (size.y * Rules.TILE_SIZE + FRONT_PX / k) * k
	var top_screen: float = Rules.MAP_AREA.position.y + (Rules.MAP_AREA.size.y - map_h) / 2.0
	_camera.position = Vector2(Rules.SCREEN_SIZE.x / 2.0, level.position.y - (top_screen - Rules.SCREEN_SIZE.y / 2.0) / k)
	game.add_child(_camera)
	_camera.make_current()
	# Lo que está "de pie" se estira al revés para no verse aplastado.
	var upright := Vector2(1.0, 1.0 / k)
	for container: Node in [game.tower_container, game.enemies, props]:
		for node: Node in container.get_children():
			(node as Node2D).scale = upright * node.get_meta(&"base_scale", Vector2.ONE)
		container.child_entered_tree.connect(_stand_up.bind(upright))
	game.projectiles.child_entered_tree.connect(_stand_up.bind(upright))


## C: lo que aparece durante la partida también se estira al revés. Las torres llegan creciendo
## (RF-130, una animación de escala), así que se corrigen cuando termina.
func _stand_up(node: Node, upright: Vector2) -> void:
	var item := node as Node2D
	if item == null:
		return
	item.scale = upright
	if item is Tower:
		get_tree().create_timer(0.25).timeout.connect(func() -> void:
			if is_instance_valid(item):
				item.scale = upright)


## Producción: el suelo con relieve no cambia durante la partida, así que se dibuja UNA vez (al doble de
## resolución, para que no se vea borroso en Full HD) y queda una sola textura por cuadro.
func _bake_ground(level: Level, relief: Node2D, light: Sprite2D) -> void:
	const SCALE: float = 2.0
	var map_px: Vector2 = Vector2(level.map_size()) * Rules.TILE_SIZE + Vector2(0, relief.front_px)
	var viewport := SubViewport.new()
	viewport.size = Vector2i(map_px * SCALE)
	viewport.transparent_bg = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	add_child(viewport)
	relief.reparent(viewport, false)
	light.reparent(viewport, false)
	relief.position = Vector2.ZERO
	relief.scale = Vector2.ONE * SCALE
	light.position = Vector2.ZERO
	light.scale *= SCALE
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	var image: Image = viewport.get_texture().get_image()
	image.generate_mipmaps()
	var baked := Sprite2D.new()
	baked.texture = ImageTexture.create_from_image(image)
	baked.centered = false
	baked.scale = Vector2.ONE / SCALE
	baked.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	level.add_child(baked)
	viewport.queue_free()


## Manchas suaves de luz y un degradé desde arriba a la izquierda, multiplicados sobre el suelo.
func _light_overlay(level: Level) -> Sprite2D:
	var size: Vector2 = Vector2(level.map_size()) * Rules.TILE_SIZE
	var noise := FastNoiseLite.new()
	noise.seed = 21
	noise.frequency = 0.02
	noise.fractal_octaves = 3
	var w: int = 320
	var h: int = int(w * size.y / size.x)
	var spots: Image = noise.get_image(w, h)
	var light := Image.create(w, h, false, Image.FORMAT_RGB8)
	for y: int in h:
		for x: int in w:
			var diagonal: float = (float(x) / w + float(y) / h) / 2.0
			var value: float = (1.0 - 0.13 * diagonal) * (0.84 + 0.16 * spots.get_pixel(x, y).r)
			light.set_pixel(x, y, Color(value, value, value * 1.02))
	var sprite := Sprite2D.new()
	sprite.texture = ImageTexture.create_from_image(light)
	sprite.centered = false
	sprite.scale = size / Vector2(w, h)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	var material := CanvasItemMaterial.new()
	material.blend_mode = CanvasItemMaterial.BLEND_MODE_MUL
	sprite.material = material
	return sprite


## D: la partida 2D sigue corriendo oculta; la maqueta 3D la copia. Proyectiles y efectos quedan en 2D.
func _apply_3d(game: Game) -> void:
	for node: CanvasItem in [game.level, game.tower_container, game.enemies, game.build_controller, game.projectiles]:
		node.visible = false
	_diorama = DIORAMA.new()
	add_child(_diorama)
	_diorama.build(game, self)


# --- Medidas de interacción: tamaño de casilla en pantalla, superficie usada y clics ---

func _measurements() -> void:
	var report: Dictionary = {}
	for variant: String in VARIANTS:
		var game: Game = await _new_game()
		await _apply_variant(game, variant)
		for i: int in 2:
			await get_tree().process_frame
		var level: Level = game.level
		var size: Vector2i = level.map_size()
		var canvas: Transform2D = get_viewport().get_canvas_transform()
		var to_screen: Callable = func(cell: Vector2i) -> Vector2: return canvas * level.cell_center(cell)
		var to_cell: Callable = func(point: Vector2) -> Vector2i: return level.cell_at(canvas.affine_inverse() * point)
		var tile_size: Callable = func(_cell: Vector2i) -> Vector2:
			return Vector2(canvas.basis_xform(Vector2(Rules.TILE_SIZE, 0)).x, canvas.basis_xform(Vector2(0, Rules.TILE_SIZE)).y)
		var corners: Array[Vector2] = []
		for p: Vector2 in [Vector2.ZERO, Vector2(size.x, 0), Vector2(size), Vector2(0, size.y)]:
			corners.append(canvas * (level.position + p * Rules.TILE_SIZE))
		if variant == "D":
			to_screen = _diorama.screen_of_cell
			to_cell = _diorama.cell_at_screen
			tile_size = _diorama.cell_screen_size
			corners.clear()
			for p: Vector2 in [Vector2.ZERO, Vector2(size.x, 0), Vector2(size), Vector2(0, size.y)]:
				corners.append(_diorama.camera.unproject_position(Vector3(p.x, DIORAMA.GRASS_H, p.y)))
		# Ida y vuelta: el centro de cada casilla construible y cuatro puntos cerca de sus bordes
		# (a 3 px adentro) tienen que volver a la misma casilla.
		var checked: int = 0
		var wrong: int = 0
		for cell: Vector2i in level.ground.get_used_cells():
			if not level.is_buildable(cell):
				continue
			var center: Vector2 = to_screen.call(cell)
			var half: Vector2 = (tile_size.call(cell) as Vector2) / 2.0 - Vector2(3, 3)
			for offset: Vector2 in [Vector2.ZERO, Vector2(half.x, 0), Vector2(-half.x, 0), Vector2(0, half.y), Vector2(0, -half.y)]:
				checked += 1
				if to_cell.call(center + offset) != cell:
					wrong += 1
		var far: Vector2 = tile_size.call(Vector2i(size.x / 2, 0))
		var near: Vector2 = tile_size.call(Vector2i(size.x / 2, size.y - 1))
		report[variant] = {
			"casilla_arriba_px": [snappedf(far.x, 0.1), snappedf(far.y, 0.1)],
			"casilla_abajo_px": [snappedf(near.x, 0.1), snappedf(near.y, 0.1)],
			"superficie_del_area_de_mapa": snappedf(_polygon_area(corners) / (Rules.MAP_AREA.size.x * Rules.MAP_AREA.size.y), 0.01),
			"clics_probados": checked,
			"clics_en_otra_casilla": wrong,
		}
		print("MEDIDAS_B21 ", variant, " ", JSON.stringify(report[variant]))
		await _teardown(game)
	var file := FileAccess.open(OUT + "medidas.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t") + "\n")


func _polygon_area(points: Array[Vector2]) -> float:
	var area: float = 0.0
	for i: int in points.size():
		area += points[i].cross(points[(i + 1) % points.size()])
	return absf(area) / 2.0


# --- Rendimiento ---

func _measure(variant: String) -> void:
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	var game: Game = await _new_game()
	game.session.earn(100000)
	game.session.infinite_lives = true  # en una prueba larga nadie pierde la partida
	var built: int = 0
	for cell: Vector2i in game.level.ground.get_used_cells():
		if built >= STRESS_TOWERS:
			break
		if game.build_controller.try_build(game.tower_types[built % game.tower_types.size()], cell):
			built += 1
	var length: float = game.level.get_ground_path(0).curve.get_baked_length()
	for i: int in STRESS_ENEMIES:
		_spawn_stress(game, length * i / STRESS_ENEMIES)
	await get_tree().create_timer(0.3).timeout
	await _apply_variant(game, variant)
	if "ocultar_actores" in OS.get_cmdline_user_args():
		# Control: la partida sigue igual, pero sin el dibujo 2D de torres y monstruos en cada cuadro.
		game.enemies.visible = false
		game.tower_container.visible = false
	var frames: Array[float] = []
	var elapsed: float = 0.0
	var death_clock: float = 0.0
	var last: int = Time.get_ticks_usec()
	while elapsed < WARMUP_SECONDS + MEASURE_SECONDS:
		await get_tree().process_frame
		var now: int = Time.get_ticks_usec()
		var ms: float = (now - last) / 1000.0
		last = now
		elapsed += ms / 1000.0
		_keep_enemy_count(game, length)
		death_clock += ms / 1000.0 * DEATHS_PER_SECOND
		while death_clock >= 1.0:
			death_clock -= 1.0
			var victim := game.enemies.get_child(randi() % game.enemies.get_child_count()) as Node2D
			game.effects.enemy_died(victim.global_position, _normal.color, 16.0, 5, victim)
		if elapsed > WARMUP_SECONDS:
			frames.append(ms)
	var sorted: Array[float] = frames.duplicate()
	sorted.sort()
	var total: float = 0.0
	var slow: int = 0
	for ms: float in frames:
		total += ms
		if ms > 1000.0 / 60.0:
			slow += 1
	var result: Dictionary = {
		"variante": variant,
		"horneado": _bake,
		"orden_por_profundidad": _y_sort,
		"fps": snappedf(frames.size() / (total / 1000.0), 1),
		"ms_promedio": snappedf(total / frames.size(), 0.01),
		"ms_p95": snappedf(sorted[int(sorted.size() * 0.95)], 0.01),
		"ms_peor": snappedf(sorted[-1], 0.01),
		"cuadros_lentos": slow,
		"cuadros": frames.size(),
		"enemigos": game.enemies.get_child_count(),
		"torres": game.tower_container.get_child_count(),
		"gpu": RenderingServer.get_video_adapter_name(),
		"render": RenderingServer.get_current_rendering_method(),
	}
	print("RESULTADO_B21 ", JSON.stringify(result))


func _spawn_stress(game: Game, distance: float) -> void:
	var enemy: Enemy = preload("res://scenes/enemies/enemy.tscn").instantiate()
	enemy.setup(_normal, game.level.get_ground_path(0), 1000000)  # no mueren: siempre hay 200
	enemy.distance = distance
	enemy.hit.connect(func(e: Enemy, damage: int, blocked: bool, _combo: Enemy.Combo) -> void:
		game.effects.damage_number(e.global_position, damage, blocked))
	game.enemies.add_child(enemy)


func _keep_enemy_count(game: Game, _length: float) -> void:
	var active: int = 0
	for node: Node in game.enemies.get_children():
		if (node as Enemy).is_active():
			active += 1
	for i: int in STRESS_ENEMIES - active:
		_spawn_stress(game, 0.0)
