# Bot que juega el nivel 1 solo, a toda velocidad, para revisar el balance (T25).
# NO es un test: es una herramienta. Imprime cómo termina cada oleada.
#
# Uso (desde la carpeta del proyecto):
#   godot --headless --path . --fixed-fps 60 -s tools/balance_sim.gd -- smart
#   godot --headless --path . --fixed-fps 60 -s tools/balance_sim.gd -- naive
#
# Estrategias:
#   smart  → mezcla torres y las pone donde cubren más camino.
#   basic  → solo Ametralladoras, bien puestas (sirve para ver si mezclar torres vale la pena).
#   naive  → solo Ametralladoras, en casillas libres al azar.
#
# Después de la estrategia se pueden agregar ajustes para probar números sin tocar
# los archivos (ver _apply_override). Ejemplo:
#   godot ... -s tools/balance_sim.gd -- smart hp=2 cannon.damage=20
#
# --fixed-fps 60 hace que cada frame cuente como 1/60 s sin esperar al reloj real,
# así una partida de ~10 minutos se simula en segundos.
extends SceneTree

## Orden de compra de "smart" (índices de Game.tower_types): primero Ametralladoras
## baratas para sobrevivir al principio, después mezcla.
const SMART_ORDER: Array[int] = [0, 0, 0, 1, 0, 2, 3, 1, 0, 3, 1, 2]
## Cada cuántos píxeles se mide el camino para puntuar las casillas.
const PATH_SAMPLE_STEP: float = 16.0

var game: Game
var strategy: String = "smart"
var rng := RandomNumberGenerator.new()
var built: int = 0
var last_reported_wave: int = 0
var path_points: Array[Vector2] = []
var air_points: Array[Vector2] = []
## Recursos modificados por los ajustes. Se guardan aquí para que Godot no los descarte
## de su caché (si nadie los usa, los libera y la partida los volvería a leer del disco).
var _kept: Array[Resource] = []


func _initialize() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if not args.is_empty():
		strategy = args[0]
	for arg: String in args.slice(1):
		_apply_override(arg)
	rng.seed = 12345
	game = (_keep(load("res://scenes/game/game.tscn")) as PackedScene).instantiate()
	root.add_child(game)
	print("Estrategia: %s · vida del Normal: %d" % [strategy, (load("res://data/enemies/normal.tres") as EnemyData).max_health])


## Prueba de números SIN tocar los archivos: cambia los recursos ya cargados en memoria.
##   hp=1.5      multiplica la vida base de todos los enemigos
##   scale=15    % de vida extra por oleada (BalanceConfig)
##   reward=0.8  multiplica el oro que da cada enemigo
##   gold=120    oro inicial del nivel
##   <torre>.<campo>=valor    cambia el nivel 1 de una torre (ej: cannon.damage=20)
##   <enemigo>.<campo>=valor  cambia un enemigo (ej: tank.max_health=120)
func _apply_override(arg: String) -> void:
	var parts: PackedStringArray = arg.split("=")
	var value: float = parts[1].to_float()
	if "." in parts[0]:
		_apply_field_override(parts[0].get_slice(".", 0), parts[0].get_slice(".", 1), value)
		print("Ajuste: ", arg)
		return
	match parts[0]:
		"hp":
			for id: String in ["normal", "fast", "tank", "flyer", "armored", "boss"]:
				var enemy: EnemyData = _keep(load("res://data/enemies/%s.tres" % id))
				enemy.max_health = roundi(enemy.max_health * value)
		"scale":
			(_keep(load("res://data/balance.tres")) as BalanceConfig).health_scale_percent_per_wave = int(value)
		"reward":
			for id: String in ["normal", "fast", "tank", "flyer", "armored", "boss"]:
				var enemy: EnemyData = _keep(load("res://data/enemies/%s.tres" % id))
				enemy.reward = maxi(1, roundi(enemy.reward * value))
		"gold":
			(_keep(load("res://data/levels/level_01.tres")) as LevelData).starting_gold = int(value)
	print("Ajuste: ", arg)


func _apply_field_override(id: String, field: String, value: float) -> void:
	var target: Resource
	if FileAccess.file_exists("res://data/towers/%s.tres" % id):
		target = (_keep(load("res://data/towers/%s.tres" % id)) as TowerData).levels[0]
	else:
		target = _keep(load("res://data/enemies/%s.tres" % id))
	# Respeta el tipo del campo: los enteros siguen siendo enteros.
	target.set(field, roundi(value) if typeof(target.get(field)) == TYPE_INT else value)


func _keep(resource: Resource) -> Resource:
	_kept.append(resource)
	return resource


func _process(_delta: float) -> bool:
	if path_points.is_empty():
		_sample_path()
	var session: LevelSession = game.session
	if session.wave > last_reported_wave and session.state != LevelSession.State.WAVE_RUNNING:
		last_reported_wave = session.wave
		print("  oleada %2d terminada · vidas %2d · oro %4d · torres %2d" % [
			session.wave, session.lives, session.gold, built])
	if session.is_over():
		var won: bool = session.state == LevelSession.State.WON
		print("RESULTADO: %s · oleada %d/%d · vidas %d" % [
			"VICTORIA" if won else "DERROTA", session.wave, session.total_waves, session.lives])
		return true
	_buy_towers()
	if session.can_start_wave():
		game.start_next_wave()  # sin esperar la cuenta atrás
	return false


func _buy_towers() -> void:
	while true:
		var index: int = SMART_ORDER[built % SMART_ORDER.size()] if strategy == "smart" else 0
		var tower: TowerData = game.tower_types[index]
		if not game.session.can_afford(tower.levels[0].cost):
			return
		var cell: Vector2i = _random_cell() if strategy == "naive" else _best_cell(tower)
		if not game.build_controller.try_build(tower, cell):
			return
		built += 1


func _free_cells() -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for cell: Vector2i in game.level.ground.get_used_cells():
		if game.level.is_buildable(cell) and not game.build_controller.is_occupied(cell):
			cells.append(cell)
	return cells


func _random_cell() -> Vector2i:
	var cells: Array[Vector2i] = _free_cells()
	return cells[rng.randi_range(0, cells.size() - 1)]


## La casilla libre desde la que la torre alcanza más tramo de camino.
## Las torres que golpean voladores también cuentan el camino aéreo.
func _best_cell(tower: TowerData) -> Vector2i:
	var range_px: float = Rules.tiles_to_px(tower.levels[0].range_tiles)
	var best: Vector2i = Vector2i(-1, -1)
	var best_score: int = -1
	for cell: Vector2i in _free_cells():
		var center: Vector2 = game.level.cell_center(cell)
		var score: int = _points_in_range(path_points, center, range_px)
		if tower.can_hit_air:
			score += _points_in_range(air_points, center, range_px)
		if score > best_score:
			best_score = score
			best = cell
	return best


func _points_in_range(points: Array[Vector2], center: Vector2, range_px: float) -> int:
	var count: int = 0
	for point: Vector2 in points:
		if center.distance_to(point) <= range_px:
			count += 1
	return count


func _sample_path() -> void:
	path_points = _sample(game.level.get_ground_path(0))
	air_points = _sample(game.level.get_air_path(0))


func _sample(path: Path2D) -> Array[Vector2]:
	var points: Array[Vector2] = []
	var distance: float = 0.0
	while distance <= path.curve.get_baked_length():
		points.append(path.to_global(path.curve.sample_baked(distance)))
		distance += PATH_SAMPLE_STEP
	return points
