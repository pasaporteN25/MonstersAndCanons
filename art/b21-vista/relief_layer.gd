# B-21 v2 · Prototipo, no producción: relieve dibujado sobre la MISMA cuadrícula.
# Reemplaza el dibujo de LevelDecor (mismos materiales) y agrega profundidad sin mover nada:
# el camino queda hundido, con el talud del pasto visible en su borde norte, sombra proyectada
# hacia el sureste (la luz viene de arriba a la izquierda, como en las torres) y un labio
# iluminado en el borde sur. Ninguna casilla cambia de lugar: clics, caminos y alcances quedan igual.
extends Node2D

const SOIL := Color(0.6, 0.45, 0.32)
const SHADOW := Color(0.07, 0.05, 0.03)
const GRASS_LIP := Color(0.33, 0.47, 0.18)
const GRASS_BLADE := Color(0.25, 0.39, 0.13)
const LIT_EDGE := Color(0.93, 0.95, 0.66)
const FRONT_SOIL := Color(0.48, 0.34, 0.23)

var ground: TileMapLayer
var theme_id: StringName = MapThemes.DEFAULT
## Alto del talud, en píxeles del mundo.
var wall_px: float = 12.0
## Canto frontal del tablero (0 = no se dibuja).
var front_px: float = 0.0


func setup(ground_: TileMapLayer, theme_: StringName, wall: float, front: float) -> void:
	ground = ground_
	theme_id = theme_
	wall_px = wall
	front_px = front
	position = ground.position
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	queue_redraw()


func _draw() -> void:
	if ground == null:
		return
	var tile: float = Rules.TILE_SIZE
	var cells: Array[Vector2i] = ground.get_used_cells()
	for cell: Vector2i in cells:
		var texture: Texture2D = MapThemes.PATH_TEXTURE if _is_path(cell) else MapThemes.ground_texture(theme_id)
		draw_texture_rect(texture, Rect2(Vector2(cell) * tile, Vector2(tile, tile)), false)
	for cell: Vector2i in cells:
		if _is_path(cell):
			_draw_path_shading(cell)
	for cell: Vector2i in cells:
		if _is_path(cell) and _is_high(cell + Vector2i.UP):
			_draw_wall(cell)
	for cell: Vector2i in cells:
		if not _is_path(cell):
			_draw_lit_edges(cell)
	if front_px > 0.0:
		_draw_front()


## Sombra proyectada por los bordes altos de la izquierda y de arriba, y pliegue oscuro abajo/derecha.
func _draw_path_shading(cell: Vector2i) -> void:
	var tile: float = Rules.TILE_SIZE
	var o: Vector2 = Vector2(cell) * tile
	if _is_high(cell + Vector2i.LEFT):
		_gradient_rect(Rect2(o, Vector2(11, tile)), Color(SHADOW, 0.32), Color(SHADOW, 0.0), true)
	if _is_high(cell + Vector2i.UP):
		_gradient_rect(Rect2(o + Vector2(0, wall_px), Vector2(tile, 13)), Color(SHADOW, 0.34), Color(SHADOW, 0.0), false)
	elif _is_high(cell + Vector2i(-1, -1)) and not _is_high(cell + Vector2i.LEFT):
		# Esquina interior: la punta del talud de la casilla de arriba a la izquierda.
		draw_colored_polygon(PackedVector2Array([o, o + Vector2(10, 0), o + Vector2(0, 12)]), Color(SHADOW, 0.22))
	if _is_high(cell + Vector2i.DOWN):
		_gradient_rect(Rect2(o + Vector2(0, tile - 6), Vector2(tile, 6)), Color(SHADOW, 0.0), Color(SHADOW, 0.22), false)
		draw_line(o + Vector2(0, tile - 1), o + Vector2(tile, tile - 1), Color(SHADOW, 0.4), 1.5)
	if _is_high(cell + Vector2i.RIGHT):
		_gradient_rect(Rect2(o + Vector2(tile - 6, 0), Vector2(6, tile)), Color(SHADOW, 0.0), Color(SHADOW, 0.18), true)
		draw_line(o + Vector2(tile - 1, 0), o + Vector2(tile - 1, tile), Color(SHADOW, 0.4), 2.0)


## Cara sur del pasto que mira al camino: tierra con estratos, más oscura abajo, pasto colgando arriba.
func _draw_wall(cell: Vector2i) -> void:
	var tile: float = Rules.TILE_SIZE
	var o: Vector2 = Vector2(cell) * tile
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(cell) ^ 0x21
	var source: Vector2 = MapThemes.PATH_TEXTURE.get_size()
	draw_texture_rect_region(MapThemes.PATH_TEXTURE, Rect2(o, Vector2(tile, wall_px)),
		Rect2(Vector2(0, source.y * 0.3), Vector2(source.x, source.y * wall_px / tile)), SOIL)
	_gradient_rect(Rect2(o, Vector2(tile, wall_px)), Color(SHADOW, 0.0), Color(SHADOW, 0.42), false)
	for i: int in rng.randi_range(1, 2):
		var y: float = o.y + rng.randf_range(wall_px * 0.4, wall_px * 0.85)
		var x0: float = o.x + rng.randf_range(0, tile * 0.5)
		draw_line(Vector2(x0, y), Vector2(x0 + rng.randf_range(10, 28), y + rng.randf_range(-1, 1)), Color(SHADOW, 0.35), 1.0)
	draw_rect(Rect2(o, Vector2(tile, 3)), GRASS_LIP)
	for i: int in rng.randi_range(5, 8):
		var x: float = o.x + rng.randf_range(2, tile - 2)
		var length: float = rng.randf_range(2.0, 5.0)
		draw_colored_polygon(PackedVector2Array([Vector2(x - 1.6, o.y + 2), Vector2(x + 1.6, o.y + 2),
			Vector2(x + rng.randf_range(-1, 1), o.y + 2 + length)]), GRASS_BLADE)
	draw_line(o + Vector2(0, 0.5), o + Vector2(tile, 0.5), Color(LIT_EDGE, 0.35), 1.0)


## Bordes del pasto que reciben la luz: el de arriba y el de la izquierda cuando dan al camino.
func _draw_lit_edges(cell: Vector2i) -> void:
	var tile: float = Rules.TILE_SIZE
	var o: Vector2 = Vector2(cell) * tile
	if _is_path_inside(cell + Vector2i.UP):
		draw_line(o + Vector2(0, 1), o + Vector2(tile, 1), Color(LIT_EDGE, 0.42), 1.5)
	if _is_path_inside(cell + Vector2i.LEFT):
		draw_line(o + Vector2(1, 0), o + Vector2(1, tile), Color(LIT_EDGE, 0.28), 1.5)
	if _is_path_inside(cell + Vector2i.RIGHT):
		draw_line(o + Vector2(tile - 1, 0), o + Vector2(tile - 1, tile), Color(SHADOW, 0.25), 2.0)


## Canto delantero del tablero: el mapa se ve como una maqueta apoyada.
func _draw_front() -> void:
	var tile: float = Rules.TILE_SIZE
	var rect: Rect2i = ground.get_used_rect()
	var y: float = rect.end.y * tile
	var source: Vector2 = MapThemes.PATH_TEXTURE.get_size()
	for x: int in range(rect.position.x, rect.end.x):
		var o := Vector2(x * tile, y)
		draw_texture_rect_region(MapThemes.PATH_TEXTURE, Rect2(o, Vector2(tile, front_px)),
			Rect2(Vector2.ZERO, Vector2(source.x, source.y * front_px / tile)), FRONT_SOIL)
		var top: Color = Color(0.45, 0.33, 0.23) if _is_path(Vector2i(x, rect.end.y - 1)) else GRASS_LIP
		draw_rect(Rect2(o, Vector2(tile, 4)), top)
	_gradient_rect(Rect2(Vector2(rect.position.x * tile, y), Vector2(rect.size.x * tile, front_px)),
		Color(SHADOW, 0.1), Color(SHADOW, 0.62), false)
	var rng := RandomNumberGenerator.new()
	rng.seed = 2121
	for i: int in rect.size.x * 2:
		var p := Vector2(rng.randf_range(0, rect.size.x * tile), y + rng.randf_range(front_px * 0.3, front_px * 0.9))
		draw_line(p, p + Vector2(rng.randf_range(16, 60), rng.randf_range(-1.5, 1.5)), Color(SHADOW, 0.3), 1.2)


func _gradient_rect(rect: Rect2, from: Color, to: Color, horizontal: bool) -> void:
	var a: Vector2 = rect.position
	var b: Vector2 = rect.position + Vector2(rect.size.x, 0)
	var c: Vector2 = rect.end
	var d: Vector2 = rect.position + Vector2(0, rect.size.y)
	var colors := PackedColorArray([from, to, to, from]) if horizontal else PackedColorArray([from, from, to, to])
	draw_polygon(PackedVector2Array([a, b, c, d]), colors)


func _is_path(cell: Vector2i) -> bool:
	return ground.get_cell_atlas_coords(cell) == Level.ATLAS_PATH


func _is_path_inside(cell: Vector2i) -> bool:
	return ground.get_used_rect().has_point(cell) and _is_path(cell)


## Alto = pasto o casilla bloqueada dentro del mapa. Afuera del mapa no hay talud (el camino entra y sale).
func _is_high(cell: Vector2i) -> bool:
	return ground.get_used_rect().has_point(cell) and not _is_path(cell)
