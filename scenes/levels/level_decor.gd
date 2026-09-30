# Decoración del mapa (RF-126, RF-154, RF-260): variaciones de tono del suelo, matas, bordes del camino,
# piedritas, lo que hay en las casillas bloqueadas y la puerta de salida. Cada tema (MapThemes) tiene
# su paleta y su decoración; la pradera es la de siempre.
# Es solo visual: qué casilla es construible lo decide el TileSet.
# Se dibuja una sola vez; cada casilla usa una semilla propia, así el mapa siempre se ve igual.
class_name LevelDecor
extends Node2D

## RF-06: puerta de piedra donde termina un camino dentro del mapa.
const GATE: Texture2D = preload("res://assets/sprites/map/gate.svg")

var _ground: TileMapLayer
var _exit_cells: Array[Vector2i] = []
var _theme: StringName = MapThemes.DEFAULT
var _palette: Dictionary = MapThemes.palette(MapThemes.DEFAULT)


## Level la llama al estar lista (constitución P6: el padre le da lo que necesita).
## `exit_cells`: salidas dentro del mapa, donde se dibuja una puerta (RF-06). `theme`: el paisaje (RF-260).
func paint(ground: TileMapLayer, exit_cells: Array[Vector2i] = [], theme: StringName = MapThemes.DEFAULT) -> void:
	_ground = ground
	_exit_cells = exit_cells
	_theme = theme
	_palette = MapThemes.palette(theme)
	position = ground.position
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS  # D-023
	queue_redraw()


## RF-154: qué hay en una casilla bloqueada de la pradera. Depende solo de la casilla: siempre lo mismo.
static func blocked_decor(cell: Vector2i, theme: StringName = MapThemes.DEFAULT) -> Texture2D:
	return MapThemes.blocked_decor(theme, cell)


func _draw() -> void:
	if _ground == null:
		return
	var tile: float = Rules.TILE_SIZE
	for cell: Vector2i in _ground.get_used_cells():
		var rng := RandomNumberGenerator.new()
		rng.seed = hash(cell)
		var origin: Vector2 = Vector2(cell) * tile
		match _ground.get_cell_atlas_coords(cell):
			Level.ATLAS_GRASS:
				_draw_ground(origin, rng)
			Level.ATLAS_PATH:
				_draw_path(cell, origin, rng)
			Level.ATLAS_BLOCKED:
				_draw_ground(origin, rng)
				draw_texture_rect(blocked_decor(cell, _theme), Rect2(origin, Vector2(tile, tile)), false)
	for cell: Vector2i in _exit_cells:
		draw_texture_rect(GATE, Rect2(Vector2(cell) * tile, Vector2(tile, tile)), false)  # RF-06


## El suelo de una casilla: el color de fondo del tema (la pradera se ve por el TileSet) y su decoración.
func _draw_ground(origin: Vector2, rng: RandomNumberGenerator) -> void:
	var tile: float = Rules.TILE_SIZE
	if _palette["fill_grass"] != null:
		draw_rect(Rect2(origin, Vector2(tile, tile)), _palette["fill_grass"])
	match _palette["detail"]:
		"tufts":
			_draw_grass(origin, rng)
		"leaves":
			_draw_grass(origin, rng)
			_draw_leaves(origin, rng)
		"dunes":
			_draw_shade(origin, rng)
			_draw_dunes(origin, rng)
		"snow":
			_draw_shade(origin, rng)
			_draw_snow(origin, rng)
		"cracks":
			_draw_shade(origin, rng)
			_draw_cracks(origin, rng)
		"mud":
			_draw_shade(origin, rng)
			_draw_mud(origin, rng)
		"cobbles":
			_draw_shade(origin, rng)
			_draw_cobbles(origin, rng)


## Variación de tono: cada casilla un poco más clara u oscura.
func _draw_shade(origin: Vector2, rng: RandomNumberGenerator) -> void:
	var tile: float = Rules.TILE_SIZE
	var shade: float = rng.randf_range(-0.05, 0.05)
	var tint := Color(1, 1, 1, shade) if shade > 0.0 else Color(0, 0, 0, -shade)
	draw_rect(Rect2(origin, Vector2(tile, tile)), tint)


func _draw_grass(origin: Vector2, rng: RandomNumberGenerator) -> void:
	var tile: float = Rules.TILE_SIZE
	_draw_shade(origin, rng)
	# Matas de pasto: pequeñas "V".
	for i: int in rng.randi_range(1, 3):
		var p: Vector2 = origin + Vector2(rng.randf_range(8, tile - 8), rng.randf_range(10, tile - 6))
		draw_line(p, p + Vector2(-3, -6), _palette["tuft"], 1.5)
		draw_line(p, p + Vector2(3, -6), _palette["tuft"], 1.5)
	# De vez en cuando, una flor.
	var flowers: Array = _palette["flowers"]
	if _palette["detail"] == "tufts" and rng.randf() < _palette["flower_chance"]:
		var f: Vector2 = origin + Vector2(rng.randf_range(10, tile - 10), rng.randf_range(10, tile - 10))
		draw_circle(f, 2.5, flowers[rng.randi_range(0, flowers.size() - 1)])


## Bosque: hojas caídas (puntitos anaranjados y amarillos).
func _draw_leaves(origin: Vector2, rng: RandomNumberGenerator) -> void:
	var tile: float = Rules.TILE_SIZE
	var colors: Array = _palette["flowers"]
	for i: int in rng.randi_range(1, 3):
		if rng.randf() < _palette["flower_chance"] * 1.5:
			var p: Vector2 = origin + Vector2(rng.randf_range(8, tile - 8), rng.randf_range(8, tile - 8))
			draw_circle(p, rng.randf_range(1.8, 2.8), colors[rng.randi_range(0, colors.size() - 1)])


## Desierto: arcos chicos, como la cresta de una duna.
func _draw_dunes(origin: Vector2, rng: RandomNumberGenerator) -> void:
	var tile: float = Rules.TILE_SIZE
	for i: int in rng.randi_range(1, 2):
		var c: Vector2 = origin + Vector2(rng.randf_range(14, tile - 14), rng.randf_range(20, tile - 10))
		draw_arc(c, rng.randf_range(7.0, 12.0), PI * 1.15, PI * 1.85, 8, _palette["accent"], 2.0)


## Nieve: destellos y una sombrita azulada.
func _draw_snow(origin: Vector2, rng: RandomNumberGenerator) -> void:
	var tile: float = Rules.TILE_SIZE
	for i: int in rng.randi_range(1, 3):
		var p: Vector2 = origin + Vector2(rng.randf_range(8, tile - 8), rng.randf_range(8, tile - 8))
		draw_circle(p, 1.4, Color(1, 1, 1, 0.95))
	var s: Vector2 = origin + Vector2(rng.randf_range(10, tile - 22), rng.randf_range(20, tile - 8))
	draw_line(s, s + Vector2(rng.randf_range(8, 14), 0), _palette["accent"], 2.0)


## Volcán: grietas finas en la roca y, de vez en cuando, una brasa.
func _draw_cracks(origin: Vector2, rng: RandomNumberGenerator) -> void:
	var tile: float = Rules.TILE_SIZE
	var p: Vector2 = origin + Vector2(rng.randf_range(10, tile - 30), rng.randf_range(12, tile - 12))
	var points := PackedVector2Array([p])
	for i: int in 3:
		p += Vector2(rng.randf_range(6, 12), rng.randf_range(-7, 7))
		points.append(p)
	draw_polyline(points, _palette["accent"], 1.8)
	if rng.randf() < 0.07:
		draw_circle(origin + Vector2(rng.randf_range(10, tile - 10), rng.randf_range(10, tile - 10)), 1.9, Color(1.0, 0.48, 0.18))


## Pantano: manchas oscuras de barro y, a veces, un charco.
func _draw_mud(origin: Vector2, rng: RandomNumberGenerator) -> void:
	var tile: float = Rules.TILE_SIZE
	for i: int in rng.randi_range(1, 2):
		draw_circle(origin + Vector2(rng.randf_range(10, tile - 10), rng.randf_range(10, tile - 10)), rng.randf_range(4.0, 8.0), Color(_palette["accent"], 0.55))
	if rng.randf() < 0.16:
		draw_set_transform(origin + Vector2(rng.randf_range(16, tile - 16), rng.randf_range(16, tile - 16)), 0.0, Vector2(1.7, 0.85))
		draw_circle(Vector2.ZERO, 6.0, Color(_palette["tuft"], 0.85))
		draw_set_transform(Vector2.ZERO)


## Ruinas: adoquines (juntas en los bordes de la casilla) y, a veces, pasto ralo entre las piedras.
func _draw_cobbles(origin: Vector2, rng: RandomNumberGenerator) -> void:
	var tile: float = Rules.TILE_SIZE
	draw_line(origin + Vector2(0, tile - 1), origin + Vector2(tile, tile - 1), _palette["accent"], 2.0)
	draw_line(origin + Vector2(tile - 1, 0), origin + Vector2(tile - 1, tile), _palette["accent"], 2.0)
	var joint: float = rng.randf_range(14.0, tile - 14.0)
	draw_line(origin + Vector2(joint, 0), origin + Vector2(joint, tile * 0.5), Color(_palette["accent"], 0.6), 1.5)
	if rng.randf() < 0.3:
		var p: Vector2 = origin + Vector2(rng.randf_range(10, tile - 10), rng.randf_range(12, tile - 6))
		draw_line(p, p + Vector2(-3, -6), _palette["tuft"], 1.6)
		draw_line(p, p + Vector2(3, -6), _palette["tuft"], 1.6)


func _draw_path(cell: Vector2i, origin: Vector2, rng: RandomNumberGenerator) -> void:
	var tile: float = Rules.TILE_SIZE
	if _palette["fill_path"] != null:
		draw_rect(Rect2(origin, Vector2(tile, tile)), _palette["fill_path"])
	# Bordes: una línea en cada lado que toca algo que no es camino.
	var sides: Array[Vector2i] = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
	for side: Vector2i in sides:
		var neighbor: Vector2i = cell + side
		if _ground.get_cell_atlas_coords(neighbor) == Level.ATLAS_PATH or not _is_inside(neighbor):
			continue
		var a: Vector2
		var b: Vector2
		match side:
			Vector2i.UP:
				a = origin; b = origin + Vector2(tile, 0)
			Vector2i.DOWN:
				a = origin + Vector2(0, tile); b = origin + Vector2(tile, tile)
			Vector2i.LEFT:
				a = origin; b = origin + Vector2(0, tile)
			_:
				a = origin + Vector2(tile, 0); b = origin + Vector2(tile, tile)
		draw_line(a, b, _palette["edge"], 4.0)
	# Piedritas.
	for i: int in rng.randi_range(0, 3):
		var p: Vector2 = origin + Vector2(rng.randf_range(8, tile - 8), rng.randf_range(8, tile - 8))
		draw_circle(p, rng.randf_range(1.5, 3.0), _palette["pebble"])


## Fuera del mapa no se dibuja borde (el camino entra y sale por los costados).
func _is_inside(cell: Vector2i) -> bool:
	return _ground.get_used_rect().has_point(cell)
