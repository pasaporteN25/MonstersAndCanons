# B-21 v2 · Prototipo, no producción: el mismo mapa como maqueta 3D real. El terreno tiene geometría
# (camino hundido, pasto elevado, canto del tablero), luz direccional con sombras reales y cámara en
# perspectiva. Torres, monstruos y decoración son los dibujos actuales, en planos que miran a la cámara.
# La lógica no se toca: la partida 2D sigue corriendo (oculta) y este nodo copia posiciones, cuadros
# de animación y barras de vida en cada cuadro. Proyectiles y efectos NO están portados.
extends Node3D

const GRASS_H: float = 0.28
const BASE_H: float = -0.55
const FLY_H: float = 0.95
const PITCH_DEG: float = 55.0
const FOV_DEG: float = 30.0
## Píxeles del mundo 2D por unidad 3D: una casilla mide una unidad.
const UNIT: float = 64.0
const TREE_SCALE: float = 1.3

var game: Game
var camera: Camera3D
var overlay: Node2D
var _origin: Vector2
var _enemies: Dictionary = {}  # Enemy → Sprite3D
var _towers: Dictionary = {}  # Tower → [Sprite3D base, Sprite3D torreta]
var _anchor_cache: Dictionary = {}  # Texture2D → fila más baja con color
var _projectiles: Dictionary = {}  # Projectile → Sprite3D
var _preview: Node3D
var _preview_radius: float = -1.0
var _tint: MeshInstance3D
var _ring_fill: MeshInstance3D
var _ring_line: MeshInstance3D
var _ghost: Sprite3D
var _up: Vector3
var _normal: Vector3


func build(game_: Game, overlay_parent: Node) -> void:
	game = game_
	_origin = game.level.position
	var phi: float = deg_to_rad(PITCH_DEG)
	_up = Vector3(0, cos(phi), -sin(phi))
	_normal = Vector3(0, sin(phi), cos(phi))
	_add_environment()
	_add_terrain()
	_add_props()
	_add_camera()
	overlay = Node2D.new()
	overlay.draw.connect(_draw_overlay)
	overlay_parent.add_child(overlay)
	sync()


func _process(_delta: float) -> void:
	sync()


# --- Escena ---

func _add_environment() -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.3, 0.3, 0.3)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.8, 0.84, 0.95)
	env.ambient_light_energy = 0.48
	env.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	var world_env := WorldEnvironment.new()
	world_env.environment = env
	add_child(world_env)
	var sun := DirectionalLight3D.new()
	sun.light_energy = 0.7
	sun.light_color = Color(1.0, 0.96, 0.88)
	sun.shadow_enabled = true
	sun.shadow_blur = 1.5
	# La escena mide unas 20 unidades: el sesgo por defecto (pensado en metros) se come las sombras chicas.
	sun.shadow_bias = 0.01
	sun.shadow_normal_bias = 0.2
	sun.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL
	sun.directional_shadow_max_distance = 40.0
	add_child(sun)
	# Luz desde arriba a la izquierda (noroeste), como la pintada en torres y monstruos.
	sun.look_at_from_position(Vector3.ZERO, Vector3(0.75, -1.25, 0.85), Vector3.UP)


func _add_terrain() -> void:
	var ground: TileMapLayer = game.level.ground
	var grass := SurfaceTool.new()
	var path := SurfaceTool.new()
	var wall := SurfaceTool.new()
	for st: SurfaceTool in [grass, path, wall]:
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var sides: Array[Vector2i] = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
	for cell: Vector2i in ground.get_used_cells():
		var h: float = _height(cell)
		var x: float = cell.x
		var z: float = cell.y
		var top: SurfaceTool = path if _is_path(cell) else grass
		_quad(top, [Vector3(x, h, z), Vector3(x + 1, h, z), Vector3(x + 1, h, z + 1), Vector3(x, h, z + 1)],
			[Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1)], Vector3.UP)
		for side: Vector2i in sides:
			var other: float = _height(cell + side)
			if other >= h:
				continue
			var a: Vector3
			var b: Vector3
			match side:
				Vector2i.UP:
					a = Vector3(x + 1, 0, z); b = Vector3(x, 0, z)
				Vector2i.DOWN:
					a = Vector3(x, 0, z + 1); b = Vector3(x + 1, 0, z + 1)
				Vector2i.LEFT:
					a = Vector3(x, 0, z); b = Vector3(x, 0, z + 1)
				_:
					a = Vector3(x + 1, 0, z + 1); b = Vector3(x + 1, 0, z)
			var drop: float = h - other
			_quad(wall, [a + Vector3(0, h, 0), b + Vector3(0, h, 0), b + Vector3(0, other, 0), a + Vector3(0, other, 0)],
				[Vector2(0, 0.3), Vector2(1, 0.3), Vector2(1, 0.3 + drop), Vector2(0, 0.3 + drop)],
				Vector3(side.x, 0, side.y))
	var mesh := ArrayMesh.new()
	var materials: Array[Material] = [
		_material(MapThemes.ground_texture(game.level.theme), Color.WHITE),
		_material(MapThemes.PATH_TEXTURE, Color.WHITE),
		_material(MapThemes.PATH_TEXTURE, Color(0.62, 0.47, 0.34)),
	]
	var tools: Array[SurfaceTool] = [grass, path, wall]
	for i: int in tools.size():
		tools[i].commit(mesh)
		mesh.surface_set_material(mesh.get_surface_count() - 1, materials[i])
	var terrain := MeshInstance3D.new()
	terrain.mesh = mesh
	add_child(terrain)


func _add_props() -> void:
	var ground: TileMapLayer = game.level.ground
	for cell: Vector2i in ground.get_used_cells():
		if ground.get_cell_atlas_coords(cell) != Level.ATLAS_BLOCKED:
			continue
		var texture: Texture2D = LevelDecor.blocked_decor(cell, game.level.theme)
		var size: float = TREE_SCALE if texture == MapThemes.TREE else 1.0
		var anchor: float = _anchor_row(texture)
		var sprite := _sprite(texture, size, anchor)
		var ground_offset: float = (anchor / texture.get_height() - 0.5) * size
		sprite.position = Vector3(cell.x + 0.5, GRASS_H, cell.y + 0.5 + ground_offset)
		add_child(sprite)


func _add_camera() -> void:
	camera = Camera3D.new()
	camera.fov = FOV_DEG
	add_child(camera)
	camera.make_current()
	var size: Vector2i = game.level.map_size()
	var center := Vector3(size.x / 2.0, 0.0, size.y / 2.0)
	var phi: float = deg_to_rad(PITCH_DEG)
	# La distancia más corta a la que el mapa entra entero entre las dos barras del HUD.
	for step: int in 200:
		var distance: float = 12.0 + step * 0.25
		camera.position = center + Vector3(0, sin(phi), cos(phi)) * distance
		camera.look_at(center, Vector3.UP)
		var front_left: Vector2 = camera.unproject_position(Vector3(0, BASE_H, size.y))
		var front_right: Vector2 = camera.unproject_position(Vector3(size.x, BASE_H, size.y))
		var back_left: Vector2 = camera.unproject_position(Vector3(0, GRASS_H, 0))
		var height: float = front_left.y - back_left.y
		if front_left.x >= 8.0 and front_right.x <= Rules.SCREEN_SIZE.x - 8.0 and height <= Rules.MAP_AREA.size.y - 16.0:
			break
	# Centrar verticalmente entre las barras (arriba 48 px, abajo 96 px).
	var top_y: float = camera.unproject_position(Vector3(0, GRASS_H, 0)).y
	var bottom_y: float = camera.unproject_position(Vector3(0, BASE_H, size.y)).y
	var shift_px: float = Rules.MAP_AREA.get_center().y - (top_y + bottom_y) / 2.0
	var units_per_px: float = 2.0 * camera.position.distance_to(center) * tan(deg_to_rad(FOV_DEG) / 2.0) / Rules.SCREEN_SIZE.y
	camera.v_offset = shift_px * units_per_px
	print("B21 cámara: distancia %.2f · arriba %.0f · abajo %.0f · corrimiento %.0f px · visible %s" % [
		camera.position.distance_to(center), top_y, bottom_y, shift_px, get_viewport().get_visible_rect()])


# --- Copia de la partida 2D ---

func sync() -> void:
	for enemy: Node in game.enemies.get_children():
		var e := enemy as Enemy
		if e == null or not e.is_active():
			continue
		if not _enemies.has(e):
			_enemies[e] = _new_enemy_sprite(e)
		_update_enemy(e, _enemies[e])
	for key: Variant in _enemies.keys():  # sin tipo: puede ser un enemigo ya liberado
		if not is_instance_valid(key) or not (key as Enemy).is_active():
			var sprite: Sprite3D = _enemies[key]
			sprite.queue_free()
			_enemies.erase(key)
	for node: Node in game.tower_container.get_children():
		var tower := node as Tower
		if tower == null or tower.is_queued_for_deletion():
			continue
		if not _towers.has(tower):
			_towers[tower] = _new_tower_sprites(tower)
		var pair: Array = _towers[tower]
		(pair[0] as Sprite3D).texture = tower.stats().base_texture  # cambia al mejorar
		if tower.current_turret_atlas() != null:
			(pair[1] as Sprite3D).texture = tower.current_turret_atlas()
			(pair[1] as Sprite3D).region_rect = TowerVisual.frame_rect(tower.current_turret_atlas(), tower.aim_angle)
	for key: Variant in _towers.keys():  # vendidas
		if not is_instance_valid(key) or (key as Tower).is_queued_for_deletion():
			for sprite: Sprite3D in _towers[key]:
				sprite.queue_free()
			_towers.erase(key)
	_sync_projectiles()
	overlay.queue_redraw()


## Los proyectiles vuelan a media altura; su daño sigue calculándose en 2D.
func _sync_projectiles() -> void:
	for node: Node in game.projectiles.get_children():
		var shot := node as Node2D
		if shot == null or shot.is_queued_for_deletion():
			continue
		if not _projectiles.has(shot):
			var texture: Texture2D = shot.get("_texture")
			var sprite := Sprite3D.new()
			sprite.texture = texture if texture != null else MapThemes.ROCK_A
			sprite.pixel_size = 28.0 / UNIT / sprite.texture.get_width()  # Projectile.SPRITE_SIZE_PX
			sprite.shaded = false
			sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
			sprite.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
			add_child(sprite)
			_projectiles[shot] = sprite
		var local: Vector2 = shot.global_position - _origin
		(_projectiles[shot] as Sprite3D).position = Vector3(local.x / UNIT, GRASS_H + 0.4, local.y / UNIT)
	for key: Variant in _projectiles.keys():
		if not is_instance_valid(key) or (key as Node).is_queued_for_deletion():
			(_projectiles[key] as Sprite3D).queue_free()
			_projectiles.erase(key)


func _new_enemy_sprite(enemy: Enemy) -> Sprite3D:
	var texture: Texture2D = enemy.visual_texture()
	var region: Rect2 = enemy.visual_frame_region()
	var size: Vector2 = region.size if region.has_area() else texture.get_size()
	var sprite := _sprite(texture, 1.0, size.y * 191.0 / 256.0, region)
	add_child(sprite)
	return sprite


func _update_enemy(enemy: Enemy, sprite: Sprite3D) -> void:
	var r: float = Rules.tiles_to_px(enemy.data.size_tiles)
	var side: float = r * EnemyShape.SPRITE_SCALE * enemy.visual_draw_scale()
	var foot: float = r * EnemyShape.SPRITE_SCALE * (191.0 / 256.0 - 0.5 - 1.0 / 32.0)
	var region: Rect2 = enemy.visual_frame_region()
	if region.has_area():
		sprite.region_rect = region
	var source: Vector2 = region.size if region.has_area() else sprite.texture.get_size()
	sprite.pixel_size = side / UNIT / source.x
	var local: Vector2 = enemy.global_position - _origin + Vector2(0, foot)
	var h: float = FLY_H if enemy.data.is_flying else _height(Vector2i((local / UNIT).floor()))
	sprite.position = Vector3(local.x / UNIT, h, local.y / UNIT)
	sprite.modulate = Enemy.SLOW_MODULATE if enemy.is_slowed() else Color.WHITE


func _new_tower_sprites(tower: Tower) -> Array:
	var base_texture: Texture2D = tower.stats().base_texture
	var anchor: float = _anchor_row(base_texture)
	var scale_tiles: float = float(tower.data.footprint)
	var base := _sprite(base_texture, scale_tiles, anchor)
	var local: Vector2 = tower.global_position - _origin
	var ground_offset: float = (anchor / base_texture.get_height() - 0.5) * scale_tiles
	var ground_point := Vector3(local.x / UNIT, GRASS_H, local.y / UNIT + ground_offset)
	base.position = ground_point
	add_child(base)
	var atlas: Texture2D = tower.current_turret_atlas()
	var turret_texture: Texture2D = atlas if atlas != null else tower.data.turret_texture
	var frame: Rect2 = TowerVisual.frame_rect(atlas, tower.aim_angle) if atlas != null else Rect2()
	var frame_height: float = frame.size.y if atlas != null else turret_texture.get_height()
	# La torreta va 12 px (del mundo) más arriba que el centro de la base, como en 2D (MOUNT_OFFSET).
	var base_px_per_world: float = base_texture.get_height() / (UNIT * scale_tiles)
	var turret_anchor: float = anchor * frame_height / base_texture.get_height() \
		- TowerVisual.MOUNT_OFFSET.y * base_px_per_world * frame_height / base_texture.get_height()
	var turret := _sprite(turret_texture, scale_tiles, turret_anchor, frame)
	turret.position = ground_point + _normal * 0.02
	add_child(turret)
	return [base, turret]


# --- Vista previa de construcción y alcance (casilla, torre fantasma y círculo en el suelo) ---

## Para las capturas: la vista previa fija de una torre en una casilla.
func show_preview(cell: Vector2i, tower_data: TowerData) -> void:
	update_preview(cell, tower_data, tower_data.levels[0].range_tiles, true, true)


## `radius_tiles` = 0 la oculta. `ghost` = modo construcción (casilla teñida y torre fantasma).
func update_preview(cell: Vector2i, tower_data: TowerData, radius_tiles: float, ghost: bool, valid: bool) -> void:
	if _preview == null:
		_make_preview()
	_preview.visible = radius_tiles > 0.0
	if not _preview.visible:
		return
	_preview.position = Vector3(cell.x + 0.5, _height(cell) + 0.01, cell.y + 0.5)
	if radius_tiles != _preview_radius:
		_preview_radius = radius_tiles
		_ring_fill.mesh = _ring(Vector3(0, 0.005, 0), 0.0, radius_tiles)
		_ring_line.mesh = _ring(Vector3(0, 0.005, 0), radius_tiles - 0.025, radius_tiles + 0.025)
	_tint.visible = ghost
	(_tint.material_override as StandardMaterial3D).albedo_color = BuildController.VALID_TINT if valid else BuildController.INVALID_TINT
	_ghost.visible = ghost and tower_data != null
	if _ghost.visible:
		var base_texture: Texture2D = tower_data.levels[0].base_texture
		var anchor: float = _anchor_row(base_texture)
		_ghost.texture = base_texture
		_ghost.pixel_size = 1.0 / base_texture.get_width()
		_ghost.offset = Vector2(0, anchor - base_texture.get_height() / 2.0)
		_ghost.position = Vector3(0, GRASS_H - _preview.position.y, anchor / base_texture.get_height() - 0.5)


func _make_preview() -> void:
	_preview = Node3D.new()
	add_child(_preview)
	var tint := SurfaceTool.new()
	tint.begin(Mesh.PRIMITIVE_TRIANGLES)
	_quad(tint, [Vector3(-0.5, 0, -0.5), Vector3(0.5, 0, -0.5), Vector3(0.5, 0, 0.5), Vector3(-0.5, 0, 0.5)],
		[Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO], Vector3.UP)
	_tint = _add_flat(tint.commit(), BuildController.VALID_TINT)
	_ring_fill = _add_flat(null, Color(1, 1, 1, 0.08))
	_ring_line = _add_flat(null, Color(1, 1, 1, 0.7))
	_ghost = Sprite3D.new()
	_ghost.alpha_cut = SpriteBase3D.ALPHA_CUT_DISABLED
	_ghost.modulate = Color(1, 1, 1, 0.6)
	_ghost.shaded = false
	_ghost.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_ghost.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_ghost.rotation.x = -deg_to_rad(PITCH_DEG)
	_preview.add_child(_ghost)


func _ring(center: Vector3, inner: float, outer: float) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var steps: int = 72
	for i: int in steps:
		var a0: float = TAU * i / steps
		var a1: float = TAU * (i + 1) / steps
		var p := [center + Vector3(cos(a0), 0, sin(a0)) * outer, center + Vector3(cos(a1), 0, sin(a1)) * outer,
			center + Vector3(cos(a1), 0, sin(a1)) * inner, center + Vector3(cos(a0), 0, sin(a0)) * inner]
		_quad(st, p, [Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO], Vector3.UP)
	return st.commit()


func _add_flat(mesh: ArrayMesh, color: Color) -> MeshInstance3D:
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.albedo_color = color
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.material_override = material
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_preview.add_child(instance)
	return instance


# --- Barras de vida: 2D encima de la proyección (así se haría en producción) ---

func _draw_overlay() -> void:
	for key: Variant in _enemies.keys():
		if not is_instance_valid(key) or not (key as Enemy).is_health_bar_visible():
			continue
		var e := key as Enemy
		var sprite: Sprite3D = _enemies[e]
		var region: Rect2 = sprite.region_rect if sprite.region_enabled else Rect2(Vector2.ZERO, sprite.texture.get_size())
		var bounds: Rect2i = EnemyVisual.body_bounds(sprite.texture, region) if sprite.region_enabled else Rect2i(Vector2i.ZERO, Vector2i(region.size))
		var above_anchor: float = (region.size.y * 191.0 / 256.0 - bounds.position.y) * sprite.pixel_size
		var head: Vector2 = camera.unproject_position(sprite.position + _up * above_anchor)
		var r: float = Rules.tiles_to_px(e.data.size_tiles)
		var width: float = clampf(r * 1.6, 22.0, 56.0)
		var top_left := head - Vector2(width / 2.0, Enemy.HEALTH_BAR_HEIGHT + 4.0)
		overlay.draw_rect(Rect2(top_left, Vector2(width, Enemy.HEALTH_BAR_HEIGHT)), Color(0.35, 0.05, 0.05))
		overlay.draw_rect(Rect2(top_left, Vector2(width * float(e.health) / e.max_health, Enemy.HEALTH_BAR_HEIGHT)), Color(0.3, 0.9, 0.3))


# --- Clics: de un punto de la pantalla a una casilla (lo que necesitaría BuildController) ---

## Rayo desde la cámara hasta el plano del pasto (donde se construye).
func cell_at_screen(point: Vector2) -> Vector2i:
	var origin: Vector3 = camera.project_ray_origin(point)
	var direction: Vector3 = camera.project_ray_normal(point)
	var hit: Vector3 = origin + direction * (GRASS_H - origin.y) / direction.y
	return Vector2i(floori(hit.x), floori(hit.z))


## Centro de una casilla de pasto en la pantalla.
func screen_of_cell(cell: Vector2i) -> Vector2:
	return camera.unproject_position(Vector3(cell.x + 0.5, GRASS_H, cell.y + 0.5))


## Ancho y alto en pantalla de una casilla de pasto.
func cell_screen_size(cell: Vector2i) -> Vector2:
	var left: Vector2 = camera.unproject_position(Vector3(cell.x, GRASS_H, cell.y + 0.5))
	var right: Vector2 = camera.unproject_position(Vector3(cell.x + 1, GRASS_H, cell.y + 0.5))
	var top: Vector2 = camera.unproject_position(Vector3(cell.x + 0.5, GRASS_H, cell.y))
	var bottom: Vector2 = camera.unproject_position(Vector3(cell.x + 0.5, GRASS_H, cell.y + 1))
	return Vector2(right.x - left.x, bottom.y - top.y)


# --- Ayudas ---

func _sprite(texture: Texture2D, width_units: float, anchor_row: float, region: Rect2 = Rect2()) -> Sprite3D:
	var sprite := Sprite3D.new()
	sprite.texture = texture
	var size: Vector2 = texture.get_size()
	if region.has_area():
		sprite.region_enabled = true
		sprite.region_rect = region
		size = region.size
	sprite.pixel_size = width_units / size.x
	# El punto de apoyo (pie o borde delantero de la base) queda en el origen del nodo.
	sprite.offset = Vector2(0, anchor_row - size.y / 2.0)
	sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_OPAQUE_PREPASS
	sprite.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	sprite.shaded = false
	sprite.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	# Plano inclinado hacia la cámara: el dibujo se ve sin deformar y no se hunde en el suelo.
	sprite.rotation.x = -deg_to_rad(PITCH_DEG)
	return sprite


func _anchor_row(texture: Texture2D) -> float:
	if not _anchor_cache.has(texture):
		var image: Image = texture.get_image().duplicate()
		image.decompress()
		_anchor_cache[texture] = float(image.get_used_rect().end.y)
	return _anchor_cache[texture]


func _material(texture: Texture2D, color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_texture = texture
	material.albedo_color = color
	material.roughness = 1.0
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	return material


func _quad(st: SurfaceTool, p: Array, uv: Array, normal: Vector3) -> void:
	for i: int in [0, 1, 2, 0, 2, 3]:
		st.set_normal(normal)
		st.set_uv(uv[i])
		st.add_vertex(p[i])


func _is_path(cell: Vector2i) -> bool:
	return game.level.ground.get_cell_atlas_coords(cell) == Level.ATLAS_PATH


func _height(cell: Vector2i) -> float:
	if not game.level.is_inside(cell):
		return BASE_H
	return 0.0 if _is_path(cell) else GRASS_H
