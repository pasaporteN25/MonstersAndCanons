# Decoración del mapa (RF-126, RF-154, RF-260, RF-334): materiales del suelo, bordes del camino,
# piedritas, lo que hay en las casillas bloqueadas y la puerta de salida. Cada tema (MapThemes) tiene
# su material y su decoración.
# Es solo visual: qué casilla es construible lo decide el TileSet.
# Se dibuja una sola vez; cada casilla usa una semilla propia, así el mapa siempre se ve igual.
class_name LevelDecor
extends Node2D

## RF-06: puerta de piedra donde termina un camino dentro del mapa.
const GATE: Texture2D = preload("res://assets/sprites/map/rendered/gate.png")

var _field: ObstacleField
var _ground: TileMapLayer
var _exit_cells: Array[Vector2i] = []
var _theme: StringName = MapThemes.DEFAULT
var _legend_cells: Dictionary = {}  # casilla → nombre del dibujo (RF-262)
var _removable_cells: Array[Vector2i] = []
var _post_conquered: bool = false  # RF-657: lo decide quien arma el mapa; esta clase no lee el guardado
var _banner_recipe: BannerRecipe
var _post_cells: Array[Vector2i] = []  # T475, RF-696: postes superpuestos; los pasa quien arma el mapa
var _mark_cells: Dictionary = {}  # T507, RF-717: casilla → tipo de marca (CampaignMarks); los pasa quien arma el mapa
var _palette: Dictionary = MapThemes.palette(MapThemes.DEFAULT)


## Level la llama al estar lista (constitución P6: el padre le da lo que necesita).
## `exit_cells`: salidas dentro del mapa, donde se dibuja una puerta (RF-06). `theme`: el paisaje (RF-260).
## `legend_cells`: los dibujos que pidió la leyenda del nivel, casilla por casilla (RF-262).
## `post_conquered`: true si los postes de banderines muestran la variante del jugador (RF-657, RF-696).
## `post_cells`: casillas donde se superpone un poste como capa visual, sin tocar el mapa (T475, RF-696).
## `mark_cells`: casilla → tipo de las marcas (señales) superpuestas, también solo visuales (T507, RF-717).
func paint(ground: TileMapLayer, exit_cells: Array[Vector2i] = [], theme: StringName = MapThemes.DEFAULT, legend_cells: Dictionary = {}, removable_cells: Array[Vector2i] = [], post_conquered: bool = false, banner_recipe: BannerRecipe = null, post_cells: Array[Vector2i] = [], mark_cells: Dictionary = {}) -> void:
	_ground = ground
	_exit_cells = exit_cells
	_theme = theme
	_legend_cells = legend_cells
	_removable_cells = removable_cells
	_post_conquered = post_conquered
	_banner_recipe = banner_recipe
	_post_cells = post_cells
	_mark_cells = mark_cells
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
	var posted: Array[Vector2i] = overlay_post_cells()
	var marked: Array[Vector2i] = overlay_mark_cells()
	for cell: Vector2i in _ground.get_used_cells():
		var rng := RandomNumberGenerator.new()
		rng.seed = hash(cell)
		var origin: Vector2 = Vector2(cell) * tile
		if posted.has(cell):  # el ítem de atrás (cactus, roca, columna, flores) no se dibuja bajo el poste
			_draw_ground(origin, rng)
			continue
		if marked.has(cell):  # la marca es el único ítem de la casilla: solo el suelo debajo
			_draw_ground(origin, rng)
			continue
		if _legend_cells.has(cell):
			_draw_legend(cell, origin, rng, _legend_cells[cell])
			continue
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
	_draw_campaign_posts(tile)
	_draw_campaign_marks(tile)


## T475, RF-696: un poste en la casilla, sin el ítem decorativo que había detrás (solo se dibuja el suelo).
## Si la leyenda ya dibuja ahí el poste (nivel 6), no se repite.
func _draw_campaign_posts(tile: float) -> void:
	var texture: Texture2D = campaign_post_texture()
	for cell: Vector2i in overlay_post_cells():
		draw_texture_rect(texture, Rect2(Vector2(cell) * tile, Vector2(tile, tile)), false)


## T507, RF-717: cada marca con el dibujo de su tipo, sobre el suelo de su casilla.
func _draw_campaign_marks(tile: float) -> void:
	for cell: Vector2i in overlay_mark_cells():
		draw_texture_rect(CampaignMarks.texture_of(_mark_cells[cell]), Rect2(Vector2(cell) * tile, Vector2(tile, tile)), false)


## La variante de los postes superpuestos según el contexto que recibió (nunca consulta el guardado).
func campaign_post_texture() -> Texture2D:
	return MapDrawings.post_texture(_post_conquered, _banner_recipe)


## Casillas donde de verdad se superpone un poste: las pedidas, dentro del mapa y sin repetir el poste que la
## leyenda ya dibuja ahí.
func overlay_post_cells() -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for cell: Vector2i in _post_cells:
		if _ground != null and _is_inside(cell) and _legend_cells.get(cell, "") != MapDrawings.POST_DRAWING:
			cells.append(cell)
	return cells


## T507, RF-717: casillas donde de verdad se dibuja una marca. Una marca sin arte aprobado, fuera del mapa, de un tipo
## desconocido o en una casilla que no le corresponde se ignora: la grabada va sobre una señal de la leyenda (`roca_marcada`
## o `simbolo_ruina`, no removible); estela y pintada, sobre una `X` libre. Nunca sobre un poste ni sobre el camino,
## una entrada, la salida, una casilla construible o una leyenda de otro tipo.
func overlay_mark_cells() -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	if _ground == null:
		return cells
	for cell: Vector2i in _mark_cells:
		var type_id: StringName = _mark_cells[cell]
		if CampaignMarks.texture_of(type_id) == null or not _is_inside(cell) or _post_cells.has(cell):
			continue
		if _ground.get_cell_atlas_coords(cell) != Level.ATLAS_BLOCKED or _removable_cells.has(cell):
			continue
		var is_signal: bool = CampaignMarks.SIGNAL_DRAWINGS.has(_legend_cells.get(cell, ""))
		if (CampaignMarks.support_of(type_id) == CampaignMarks.Support.SIGNAL) != is_signal:
			continue
		if not is_signal and _legend_cells.has(cell):
			continue
		cells.append(cell)
	return cells


## RF-263: una casilla de la leyenda. Un "objeto" va sobre el suelo del tema; un "suelo" (agua, hielo,
## lava, barro) cubre toda la casilla.
func _draw_legend(cell: Vector2i, origin: Vector2, rng: RandomNumberGenerator, drawing: String) -> void:
	var tile: float = Rules.TILE_SIZE
	if MapDrawings.kind(drawing) == MapDrawings.KIND_OBJECT:
		_draw_ground(origin, rng)
		var texture: Texture2D = object_texture(cell, drawing)
		if texture != null:
			draw_texture_rect(texture, Rect2(origin, Vector2(tile, tile)), false)
		if _removable_cells.has(cell):
			_draw_removable_mark(origin, tile)
		return
	var colors: Dictionary = MapDrawings.ground_colors(drawing)
	draw_rect(Rect2(origin, Vector2(tile, tile)), colors["base"])
	match drawing:
		"agua":
			_draw_waves(origin, rng, colors)
		"hielo":
			_draw_ice(origin, rng, colors)
		"lava":
			_draw_lava(origin, rng, colors)
		"barro":
			_draw_puddles(origin, rng, colors)
	# Donde la mancha termina, un borde (contra el suelo, no contra otra casilla igual).
	var sides: Array[Vector2i] = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
	for side: Vector2i in sides:
		var neighbor: Vector2i = cell + side
		if not _is_inside(neighbor) or _legend_cells.get(neighbor, "") == drawing:
			continue
		var a: Vector2 = origin + Vector2(maxf(side.x, 0.0), maxf(side.y, 0.0)) * tile
		var along: Vector2 = Vector2(absf(side.y), absf(side.x)) * tile
		draw_line(a, a + along, colors["edge"], 4.0)
		var inward: Vector2 = Vector2(-side) * 4.0
		draw_line(a + inward, a + along + inward, Color(colors["light"], 0.55), 2.0)


## El padre conecta la vista al campo real; las señales solo piden redibujar.
func bind_field(field: ObstacleField) -> void:
	_field = field
	field.job_started.connect(queue_redraw.unbind(1))
	field.job_cancelled.connect(queue_redraw.unbind(2))
	field.job_finished.connect(queue_redraw.unbind(2))
	field.site_changed.connect(queue_redraw.unbind(1))
	queue_redraw()


func object_texture(cell: Vector2i, drawing: String) -> Texture2D:
	if drawing == "estatua":
		return MapDrawings.statue_texture(cell, _theme)
	if drawing == MapDrawings.POST_DRAWING:
		return MapDrawings.post_texture(_post_conquered, _banner_recipe)
	var state: ObstacleField.State = ObstacleField.State.DISABLED if _field == null else _field.state_of(cell)
	return MapDrawings.state_texture(drawing, state)


func _draw_removable_mark(origin: Vector2, tile: float) -> void:
	var center: Vector2 = origin + Vector2(tile - 11, 11)
	draw_colored_polygon(PackedVector2Array([center + Vector2(0, -7), center + Vector2(7, 0), center + Vector2(0, 7), center + Vector2(-7, 0)]), Color("#f0a629"))
	draw_polyline(PackedVector2Array([center + Vector2(0, -7), center + Vector2(7, 0), center + Vector2(0, 7), center + Vector2(-7, 0), center + Vector2(0, -7)]), Color("#49362c"), 1.5)


## Agua: rayitas claras horizontales (reflejos).
func _draw_waves(origin: Vector2, rng: RandomNumberGenerator, colors: Dictionary) -> void:
	var tile: float = Rules.TILE_SIZE
	for i: int in rng.randi_range(2, 3):
		var p: Vector2 = origin + Vector2(rng.randf_range(8, tile - 26), rng.randf_range(10, tile - 8))
		var points := PackedVector2Array([p, p + Vector2(6, -2), p + Vector2(12, 0), p + Vector2(18, -2)])
		draw_polyline(points, Color(colors["light"], 0.8), 2.0)
	if rng.randf() < 0.35:
		draw_circle(origin + Vector2(rng.randf_range(10, tile - 10), rng.randf_range(10, tile - 10)), rng.randf_range(3.0, 6.0), Color(colors["dark"], 0.5))


## Hielo: una grieta y un destello.
func _draw_ice(origin: Vector2, rng: RandomNumberGenerator, colors: Dictionary) -> void:
	var tile: float = Rules.TILE_SIZE
	var p: Vector2 = origin + Vector2(rng.randf_range(8, tile * 0.4), rng.randf_range(10, tile - 10))
	var points := PackedVector2Array([p])
	for i: int in 3:
		p += Vector2(rng.randf_range(7, 14), rng.randf_range(-9, 9))
		points.append(p)
	draw_polyline(points, Color(colors["dark"], 0.9), 1.6)
	var s: Vector2 = origin + Vector2(rng.randf_range(10, tile - 10), rng.randf_range(10, tile - 10))
	draw_line(s, s + Vector2(7, -5), colors["light"], 2.0)


## Lava: manchas oscuras (la costra) y venas brillantes.
func _draw_lava(origin: Vector2, rng: RandomNumberGenerator, colors: Dictionary) -> void:
	var tile: float = Rules.TILE_SIZE
	for i: int in rng.randi_range(1, 2):
		draw_circle(origin + Vector2(rng.randf_range(10, tile - 10), rng.randf_range(10, tile - 10)), rng.randf_range(5.0, 9.0), Color(colors["dark"], 0.75))
	var p: Vector2 = origin + Vector2(rng.randf_range(6, tile * 0.4), rng.randf_range(12, tile - 12))
	var points := PackedVector2Array([p])
	for i: int in 3:
		p += Vector2(rng.randf_range(6, 12), rng.randf_range(-8, 8))
		points.append(p)
	draw_polyline(points, colors["light"], 2.4)


## Barro: manchas más oscuras y más claras.
func _draw_puddles(origin: Vector2, rng: RandomNumberGenerator, colors: Dictionary) -> void:
	var tile: float = Rules.TILE_SIZE
	for i: int in rng.randi_range(2, 3):
		var c: Color = colors["dark"] if rng.randf() < 0.55 else colors["light"]
		draw_circle(origin + Vector2(rng.randf_range(10, tile - 10), rng.randf_range(10, tile - 10)), rng.randf_range(3.0, 7.0), Color(c, 0.7))


## RF-334: el material incluye el relieve y los detalles del suelo.
func _draw_ground(origin: Vector2, _rng: RandomNumberGenerator) -> void:
	var tile: float = Rules.TILE_SIZE
	draw_texture_rect(MapThemes.ground_texture(_theme), Rect2(origin, Vector2(tile, tile)), false)


func _draw_path(cell: Vector2i, origin: Vector2, _rng: RandomNumberGenerator) -> void:
	var tile: float = Rules.TILE_SIZE
	draw_texture_rect(MapThemes.PATH_TEXTURE, Rect2(origin, Vector2(tile, tile)), false)
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
		draw_line(a, b, Color(_palette["edge"], 0.45), 3.0)


## Fuera del mapa no se dibuja borde (el camino entra y sale por los costados).
func _is_inside(cell: Vector2i) -> bool:
	return _ground.get_used_rect().has_point(cell)
