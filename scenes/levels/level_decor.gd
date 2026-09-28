# Decoración del mapa (RF-126): variaciones de tono del pasto, matas, bordes del camino,
# piedritas y rocas. Es solo visual: qué casilla es construible lo decide el TileSet.
# Se dibuja una sola vez; cada casilla usa una semilla propia, así el mapa siempre se ve igual.
class_name LevelDecor
extends Node2D

const GRASS_DARK := Color(0.28, 0.5, 0.2)
const FLOWER_COLORS: Array[Color] = [Color(1, 0.95, 0.6), Color(1, 0.75, 0.85), Color(0.95, 0.95, 1)]
const PATH_EDGE := Color(0.62, 0.5, 0.3)
const PEBBLE := Color(0.7, 0.6, 0.42)
const ROCK := Color(0.52, 0.52, 0.55)

var _ground: TileMapLayer


## Level la llama al estar lista (constitución P6: el padre le da lo que necesita).
func paint(ground: TileMapLayer) -> void:
	_ground = ground
	position = ground.position
	queue_redraw()


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
				_draw_grass(origin, rng)
			Level.ATLAS_PATH:
				_draw_path(cell, origin, rng)
			Level.ATLAS_BLOCKED:
				_draw_grass(origin, rng)
				_draw_rock(origin, rng)


func _draw_grass(origin: Vector2, rng: RandomNumberGenerator) -> void:
	var tile: float = Rules.TILE_SIZE
	# Variación de tono: cada casilla un poco más clara u oscura.
	var shade: float = rng.randf_range(-0.05, 0.05)
	var tint := Color(1, 1, 1, shade) if shade > 0.0 else Color(0, 0, 0, -shade)
	draw_rect(Rect2(origin, Vector2(tile, tile)), tint)
	# Matas de pasto: pequeñas "V".
	for i: int in rng.randi_range(1, 3):
		var p: Vector2 = origin + Vector2(rng.randf_range(8, tile - 8), rng.randf_range(10, tile - 6))
		draw_line(p, p + Vector2(-3, -6), GRASS_DARK, 1.5)
		draw_line(p, p + Vector2(3, -6), GRASS_DARK, 1.5)
	# De vez en cuando, una flor.
	if rng.randf() < 0.18:
		var f: Vector2 = origin + Vector2(rng.randf_range(10, tile - 10), rng.randf_range(10, tile - 10))
		draw_circle(f, 2.5, FLOWER_COLORS[rng.randi_range(0, FLOWER_COLORS.size() - 1)])


func _draw_path(cell: Vector2i, origin: Vector2, rng: RandomNumberGenerator) -> void:
	var tile: float = Rules.TILE_SIZE
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
		draw_line(a, b, PATH_EDGE, 4.0)
	# Piedritas.
	for i: int in rng.randi_range(0, 3):
		var p: Vector2 = origin + Vector2(rng.randf_range(8, tile - 8), rng.randf_range(8, tile - 8))
		draw_circle(p, rng.randf_range(1.5, 3.0), PEBBLE)


func _draw_rock(origin: Vector2, rng: RandomNumberGenerator) -> void:
	var center: Vector2 = origin + Vector2(Rules.TILE_SIZE, Rules.TILE_SIZE) / 2.0
	var points := PackedVector2Array()
	for i: int in 7:
		var angle: float = TAU * i / 7.0
		points.append(center + Vector2.from_angle(angle) * rng.randf_range(17.0, 25.0) * Vector2(1.0, 0.8))
	var shadow := PackedVector2Array()
	for p: Vector2 in points:
		shadow.append(p + Vector2(4, 5))
	draw_colored_polygon(shadow, Color(0, 0, 0, 0.25))
	draw_colored_polygon(points, ROCK)
	points.append(points[0])
	draw_polyline(points, ROCK.darkened(0.4), 2.0)
	draw_circle(center + Vector2(-6, -6), 5.0, ROCK.lightened(0.25))


## Fuera del mapa no se dibuja borde (el camino entra y sale por los costados).
func _is_inside(cell: Vector2i) -> bool:
	return _ground.get_used_rect().has_point(cell)
