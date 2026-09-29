# Genera los mapas y datos de los niveles 4 (Espiral), 5 (Fortaleza) y 6 (Nido) (T61, T62, T84).
# Mapas: spec §7.5, §7.6 y §7.7. Cada camino se describe por sus esquinas (casillas).
#
# Uso: godot --headless --path . -s tools/make_levels.gd            (los tres)
#      godot --headless --path . -s tools/make_levels.gd -- 6       (solo el nivel 6)
#
# ⚠️ Vuelve a escribir los .tscn y .tres de esos niveles y la campaña. El aumento de vida
# por oleada de cada nivel (T63) se conserva si el .tres ya existía.
extends SceneTree

const FREE := Vector2i(0, 0)
const PATH := Vector2i(1, 0)
const BLOCKED := Vector2i(2, 0)
const TILE: float = 64.0
const MAP_SIZE := Vector2i(20, 9)


func _init() -> void:
	var only: PackedStringArray = OS.get_cmdline_user_args()
	if only.is_empty() or only.has("4") or only.has("5"):
		_levels_4_5()
	if only.is_empty() or only.has("6"):
		_level_6()
	_save_campaign()
	quit()


func _levels_4_5() -> void:
	# --- Nivel 4: Espiral (salida en el centro) ---
	_make_level("res://scenes/levels/level_04.tscn", "Level04",
		[[Vector2i(0, 1), Vector2i(18, 1), Vector2i(18, 7), Vector2i(2, 7), Vector2i(2, 3),
			Vector2i(16, 3), Vector2i(16, 5), Vector2i(5, 5)]],
		[Vector2i(10, 4), Vector2i(19, 4), Vector2i(0, 5)])
	# --- Nivel 5: Fortaleza (tres entradas, una desde arriba) ---
	var tail: Array = [Vector2i(13, 4), Vector2i(13, 7), Vector2i(19, 7)]
	_make_level("res://scenes/levels/level_05.tscn", "Level05",
		[[Vector2i(0, 1), Vector2i(6, 1), Vector2i(6, 4)] + tail,
			[Vector2i(0, 7), Vector2i(6, 7), Vector2i(6, 4)] + tail,
			[Vector2i(13, 0)] + tail],
		[Vector2i(3, 4), Vector2i(10, 1), Vector2i(10, 6), Vector2i(17, 3)])

	_save_level_data("level_04", "Espiral", "res://scenes/levels/level_04.tscn", 200, [
		_w([_g("normal", 12, 0.7)]),
		_w([_g("fast", 15, 0.4)]),
		_w([_g("normal", 10, 0.6), _g("armored", 6, 1.0, 3.0)]),
		_w([_g("tank", 5, 1.5), _g("flyer", 10, 0.6, 2.0)]),
		_w([_g("fast", 20, 0.3), _g("armored", 8, 0.8, 4.0)]),
		_w([_g("normal", 25, 0.4)]),
		_w([_g("flyer", 12, 0.4), _g("tank", 8, 1.2, 3.0)]),
		_w([_g("armored", 12, 0.7), _g("fast", 15, 0.3, 4.0)]),
		_w([_g("boss", 1, 1.0), _g("normal", 20, 0.4, 2.0)]),
		_w([_g("tank", 10, 1.0), _g("flyer", 16, 0.4, 3.0)]),
		_w([_g("fast", 30, 0.25), _g("armored", 10, 0.8, 5.0)]),
		_w([_g("tank", 15, 0.8), _g("normal", 25, 0.35, 4.0)]),
		_w([_g("flyer", 20, 0.35), _g("armored", 15, 0.6, 3.0)]),
		_w([_g("boss", 2, 3.0), _g("fast", 25, 0.25, 4.0)]),
		_w([_g("boss", 3, 3.0), _g("tank", 15, 0.8, 3.0), _g("flyer", 20, 0.35, 6.0), _g("armored", 15, 0.6, 10.0)]),
	])
	# Entradas del nivel 5: 0 = A (izquierda arriba), 1 = B (izquierda abajo), 2 = C (arriba).
	_save_level_data("level_05", "Fortaleza", "res://scenes/levels/level_05.tscn", 300, [
		_w([_g("normal", 8, 1.0, 0.0, 0)]),
		_w([_g("normal", 8, 1.0, 0.0, 1)]),
		_w([_g("normal", 8, 1.0, 0.0, 2)]),
		_w([_g("fast", 8, 0.6, 0.0, 0), _g("fast", 8, 0.6, 1.0, 1), _g("fast", 8, 0.6, 2.0, 2)]),
		_w([_g("armored", 6, 1.0, 0.0, 2), _g("normal", 10, 0.6, 2.0, 0)]),
		_w([_g("flyer", 10, 0.6, 0.0, 1), _g("tank", 4, 1.5, 2.0, 0)]),
		_w([_g("fast", 12, 0.4, 0.0, 2), _g("fast", 12, 0.4, 2.0, 0), _g("fast", 12, 0.4, 4.0, 1)]),
		_w([_g("armored", 8, 0.9, 0.0, 0), _g("armored", 8, 0.9, 3.0, 1)]),
		_w([_g("tank", 6, 1.4, 0.0, 2), _g("flyer", 12, 0.5, 3.0, 0)]),
		_w([_g("boss", 1, 1.0, 0.0, 1), _g("normal", 15, 0.5, 2.0, 2), _g("normal", 15, 0.5, 4.0, 0)]),
		_w([_g("fast", 20, 0.3, 0.0, 0), _g("armored", 10, 0.8, 3.0, 2)]),
		_w([_g("flyer", 16, 0.4, 0.0, 1), _g("flyer", 16, 0.4, 5.0, 2)]),
		_w([_g("tank", 10, 1.1, 0.0, 0), _g("tank", 10, 1.1, 3.0, 1)]),
		_w([_g("normal", 25, 0.3, 0.0, 2), _g("fast", 25, 0.3, 3.0, 0), _g("armored", 12, 0.7, 6.0, 1)]),
		_w([_g("boss", 1, 1.0, 0.0, 0), _g("boss", 1, 1.0, 3.0, 2), _g("flyer", 15, 0.4, 5.0, 1)]),
		_w([_g("armored", 15, 0.7, 0.0, 0), _g("armored", 15, 0.7, 4.0, 2)]),
		_w([_g("tank", 12, 0.9, 0.0, 1), _g("flyer", 20, 0.35, 4.0, 0), _g("fast", 20, 0.3, 6.0, 2)]),
		_w([_g("boss", 2, 3.0, 0.0, 1), _g("fast", 30, 0.25, 3.0, 0)]),
		_w([_g("tank", 15, 0.8, 0.0, 0), _g("tank", 15, 0.8, 3.0, 2), _g("flyer", 25, 0.3, 6.0, 1)]),
		_w([_g("boss", 2, 2.5, 0.0, 0), _g("boss", 2, 2.5, 3.0, 1), _g("boss", 2, 2.5, 6.0, 2),
			_g("armored", 25, 0.5, 9.0, 0), _g("flyer", 25, 0.3, 11.0, 2)]),
	])


# --- Nivel 6: Nido (spec §7.7): entrada A a la izquierda y B desde arriba ---

func _level_6() -> void:
	var tail: Array = [Vector2i(10, 3), Vector2i(17, 3), Vector2i(17, 5), Vector2i(2, 5), Vector2i(2, 7), Vector2i(19, 7)]
	_make_level("res://scenes/levels/level_06.tscn", "Level06",
		[[Vector2i(0, 1), Vector2i(5, 1), Vector2i(5, 3)] + tail,
			[Vector2i(10, 0)] + tail],
		[Vector2i(18, 1), Vector2i(3, 3), Vector2i(12, 6), Vector2i(7, 8)])
	_save_level_data("level_06", "Nido", "res://scenes/levels/level_06.tscn", 250, [
		_w([_g("normal", 10, 0.8, 0.0, 0)]),
		_w([_g("troll", 6, 1.5, 0.0, 0)]),
		_w([_g("fast", 12, 0.4, 0.0, 1), _g("normal", 8, 0.8, 2.0, 0)]),
		_w([_g("spider", 4, 2.0, 0.0, 0)]),
		_w([_g("troll", 8, 1.2, 0.0, 1), _g("flyer", 10, 0.6, 3.0, 0)]),
		_w([_g("spider", 6, 1.5, 0.0, 1), _g("armored", 8, 1.0, 2.0, 0)]),
		_w([_g("troll", 10, 1.0, 0.0, 0), _g("spider", 6, 1.5, 3.0, 1)]),
		_w([_g("fast", 20, 0.3, 0.0, 0), _g("flyer", 10, 0.5, 3.0, 1)]),
		_w([_g("armored", 12, 0.8, 0.0, 1), _g("troll", 8, 1.0, 3.0, 0)]),
		_w([_g("boss", 1, 1.0, 0.0, 0), _g("spider", 8, 1.2, 3.0, 1)]),
		_w([_g("troll", 12, 0.8, 0.0, 0), _g("troll", 12, 0.8, 4.0, 1)]),
		_w([_g("spider", 10, 1.0, 0.0, 0), _g("flyer", 15, 0.4, 4.0, 1)]),
		_w([_g("tank", 15, 1.0, 0.0, 1), _g("spider", 10, 1.0, 4.0, 0)]),
		_w([_g("boss", 2, 3.0, 0.0, 0), _g("troll", 15, 0.6, 3.0, 1)]),
		_w([_g("boss", 2, 3.0, 0.0, 0), _g("boss", 2, 3.0, 3.0, 1), _g("spider", 12, 0.8, 6.0, 0),
			_g("troll", 15, 0.6, 8.0, 1)]),
	])


## La campaña: todos los niveles que existan (level_01, level_02…), en orden.
func _save_campaign() -> void:
	var campaign: CampaignData = load("res://data/campaign.tres")
	var levels: Array[LevelData] = []
	var n: int = 1
	while ResourceLoader.exists("res://data/levels/level_%02d.tres" % n):
		levels.append(load("res://data/levels/level_%02d.tres" % n))
		n += 1
	campaign.levels = levels
	print("campaign: ", ResourceSaver.save(campaign, campaign.resource_path), " · niveles: ", levels.size())


# --- Mapas ---

func _make_level(file: String, node_name: String, entrances: Array, blocked: Array) -> void:
	var root := Node2D.new()
	root.name = node_name
	root.set_script(load("res://scenes/levels/level.gd"))
	var ground := TileMapLayer.new()
	ground.name = "Ground"
	ground.tile_set = load("res://assets/tiles/tileset.tres")
	_add(root, ground, root)
	var path_cells := {}
	for corners: Array in entrances:
		path_cells.merge(_cells_of(corners))
	for y: int in MAP_SIZE.y:
		for x: int in MAP_SIZE.x:
			var cell := Vector2i(x, y)
			var atlas: Vector2i = PATH if path_cells.has(cell) else (BLOCKED if cell in blocked else FREE)
			ground.set_cell(cell, 0, atlas)
	var entrances_node := Node2D.new()
	entrances_node.name = "Entrances"
	_add(root, entrances_node, root)
	for i: int in entrances.size():
		var ground_path := Path2D.new()
		ground_path.name = "GroundPath%d" % i
		ground_path.curve = _curve(entrances[i])
		_add(entrances_node, ground_path, root)
		var air := Path2D.new()
		air.name = "AirPath%d" % i
		var air_curve := Curve2D.new()
		air_curve.add_point(ground_path.curve.get_point_position(0))
		air_curve.add_point(ground_path.curve.get_point_position(ground_path.curve.point_count - 1))
		air.curve = air_curve
		_add(entrances_node, air, root)
	var decor := Node2D.new()
	decor.name = "Decor"
	decor.set_script(load("res://scenes/levels/level_decor.gd"))
	_add(root, decor, root)
	var scene := PackedScene.new()
	scene.pack(root)
	print(file, ": ", ResourceSaver.save(scene, file), " · casillas de camino: ", path_cells.size())
	root.free()


func _cells_of(corners: Array) -> Dictionary:
	var cells := {}
	for i: int in corners.size() - 1:
		var a: Vector2i = corners[i]
		var b: Vector2i = corners[i + 1]
		var step := Vector2i(signi(b.x - a.x), signi(b.y - a.y))
		var c := a
		cells[c] = true
		while c != b:
			c += step
			cells[c] = true
	return cells


func _center(cell: Vector2i) -> Vector2:
	return Vector2(cell) * TILE + Vector2(TILE, TILE) / 2.0


func _is_on_border(cell: Vector2i) -> bool:
	return cell.x == 0 or cell.y == 0 or cell.x == MAP_SIZE.x - 1 or cell.y == MAP_SIZE.y - 1


## Curva por los centros de las esquinas. Si el camino empieza o termina en un borde,
## ese punto se corre una casilla hacia afuera (el enemigo entra o sale "desde fuera").
## Si termina dentro del mapa (nivel 4), termina justo en el centro de esa casilla (RF-06).
func _curve(corners: Array) -> Curve2D:
	var curve := Curve2D.new()
	var first: Vector2i = corners[0]
	var last: Vector2i = corners[corners.size() - 1]
	var entry_dir := Vector2(corners[1] - first).normalized()
	var exit_dir := Vector2(last - corners[corners.size() - 2]).normalized()
	for i: int in corners.size():
		var p: Vector2 = _center(corners[i])
		if i == 0:
			p -= entry_dir * TILE
		elif i == corners.size() - 1 and _is_on_border(last):
			p += exit_dir * TILE
		curve.add_point(p)
	return curve


func _add(parent: Node, child: Node, owner_: Node) -> void:
	parent.add_child(child)
	child.owner = owner_


# --- Datos de oleadas ---

func _g(enemy_id: String, count: int, interval: float, delay: float = 0.0, entrance: int = 0) -> SpawnGroup:
	var g := SpawnGroup.new()
	g.enemy = load("res://data/enemies/%s.tres" % enemy_id)
	g.count = count
	g.interval = interval
	g.start_delay = delay
	g.entrance_index = entrance
	return g


func _w(groups: Array[SpawnGroup]) -> WaveData:
	var w := WaveData.new()
	w.groups = groups
	return w


func _save_level_data(id: String, display_name: String, scene: String, gold: int, waves: Array[WaveData]) -> void:
	var path: String = "res://data/levels/%s.tres" % id
	var previous_scale: int = 0
	if ResourceLoader.exists(path):
		previous_scale = (load(path) as LevelData).health_scale_percent_per_wave
	var lvl := LevelData.new()
	lvl.id = StringName(id)
	lvl.display_name = display_name
	lvl.map_scene = load(scene)
	lvl.starting_gold = gold
	lvl.starting_lives = 20
	lvl.waves = waves
	lvl.health_scale_percent_per_wave = previous_scale
	print(id, ": ", ResourceSaver.save(lvl, path))
