# Bot que juega el nivel 1 solo, a toda velocidad, para revisar el balance (T25).
# NO es un test: es una herramienta. Imprime cómo termina cada oleada.
#
# Uso (desde la carpeta del proyecto):
#   godot --headless --path . --fixed-fps 60 -s tools/balance_sim.gd -- smart
#   godot --headless --path . --fixed-fps 60 -s tools/balance_sim.gd -- naive
#
# Estrategias:
#   smart  → mezcla las 4 torres de M1–M2 y las pone donde cubren más camino.
#   mix    → como smart, pero con las 8 torres (M5): sirve para el nivel 6 y para ver
#            cuánto ayudan las torres nuevas en los niveles 1–5.
#   heavy  → como mix, pero también compra Morteros (M19, torre de 2×2) donde haya un cuadrado libre.
#   basic  → solo Ametralladoras, bien puestas (sirve para ver si mezclar torres vale la pena).
#   naive  → solo Ametralladoras, en casillas libres al azar.
#
# Estrategias de M50 (T214), todas con el orden de compra de "mix" y solo con las torres que el mapa ofrece:
#   sin_recursos     → como mix: no demuele, no extrae, no compra la demoledora y no usa recursos. Es la de la regla de oro.
#   demoler          → demuele de a uno, con oro, los removibles que abren casillas mejores que las libres que quedan.
#   demoledora       → compra la máquina cuando quedan 4 o más removibles que valgan la pena, y después demuele.
#   pieza            → como sin_recursos, pero después de las 2 primeras torres junta oro y demuele la ruina con la pieza de
#                      colección (T245), y nada más. Sirve para ver si la pieza se alcanza sin perder.
#   extraer_temprano → habilita los puntos de extracción desde la oleada 1 y construye torres con recursos apenas puede.
#   extraer_tarde    → defiende primero y habilita los puntos a mitad del nivel.
#   Para juntar oro, el bot deja de comprar torres (después de las 2 primeras) hasta pagar lo que quiere.
#   Torre con recursos: la primera del mapa que alcance, con la segunda forma de pago si la tiene (Francotirador)
#   y si no con su costo en recursos (Mortero).
#   check_rule=1    comprueba la regla de oro (RF-432): juega sin_recursos con 5 semillas en cada mapa con recursos
#                   y termina con código 1 si algún mapa gana menos de 4. Sin level/levels/file/modo, mira toda la
#                   campaña y se salta los mapas sin recursos. Ejemplos:
#     godot ... -s tools/balance_sim.gd -- x check_rule=1 file=tools/ejemplos/mapa_recursos.json
#     godot ... -s tools/balance_sim.gd -- x check_rule=1 levels=10-15
#   Con las estrategias de infraestructura la tabla suma: momento de la máquina, recursos obtenidos y sobrantes,
#   oro invertido en infraestructura y oleada de la primera torre con recursos.
#
# Después de la estrategia se pueden agregar ajustes para probar números sin tocar
# los archivos (ver _apply_override). Ejemplo:
#   godot ... -s tools/balance_sim.gd -- smart hp=2 cannon.damage=20
#   godot ... -s tools/balance_sim.gd -- smart level=2          (jugar el nivel 2 de la campaña)
#   godot ... -s tools/balance_sim.gd -- smart level=3 levelscale=25   (probar otro % de vida por oleada)
#   godot ... -s tools/balance_sim.gd -- mix file=tools/ejemplos/mapa_grande.json   (jugar un archivo de nivel cualquiera)
#   godot ... -s tools/balance_sim.gd -- mix modo=asedio level=2   (jugar el mapa 2 del modo Asedio, con sus reglas)
#
# Varias semillas y varios mapas en una sola corrida (T204):
#   seed=N          una semilla (por defecto 12345). Fija TODO el azar de la partida: el temblor de
#                   pantalla (RF-128), la probabilidad de los grupos (RF-364) y las casillas del bot "naive".
#   seeds=N         las semillas 1 a N, una partida por semilla.
#   levels=A-B      juega los mapas A a B seguidos (levels=6-9). Con level=N, uno solo.
#   mix,smart       (la estrategia) se pueden pedir varias separadas por coma.
#   report=ruta     además de la tabla final, la guarda en JSON (por ejemplo report=user://balance.json).
#   Ejemplos:
#     godot ... -s tools/balance_sim.gd -- mix level=6 seeds=5
#     godot ... -s tools/balance_sim.gd -- mix levels=6-9 seeds=5 report=user://balance.json
#   La misma semilla da siempre el mismo resultado. Al final imprime una tabla: mapa, estrategia,
#   semilla, resultado, vidas, oleada y oro sobrante.
#
# Disruptora (T217, RF-452): la estrategia "mix" la compra por id cuando el mapa la ofrece y hay emisores de aura
# en la oleada en curso o la siguiente (3 torres comunes antes de la primera, 8 antes de la segunda, nunca más de 2).
#   disruptor=0     no la compra (para comparar con y sin ella). Por omisión, disruptor=1.
#   El bot no recoge piezas ni extrae recursos: simula la colección completa y le da 4 recursos al empezar.
#   "sin_recursos" (T214) nunca la compra.
#
# --fixed-fps 60 hace que cada frame cuente como 1/60 s sin esperar al reloj real,
# así una partida de ~10 minutos se simula en segundos.
extends SceneTree

## Orden de compra de "smart" (índices de Game.tower_types): primero Ametralladoras
## baratas para sobrevivir al principio, después mezcla.
const SMART_ORDER: Array[int] = [0, 0, 0, 1, 0, 2, 3, 1, 0, 3, 1, 2]
## Orden de compra de "mix": las 8 torres (4 Incendiaria, 5 Múltiple, 6 Ráfaga, 7 Eléctrica).
const MIX_ORDER: Array[int] = [0, 0, 0, 7, 1, 4, 0, 5, 3, 6, 2, 7, 0, 4, 5, 6, 3, 1]
## T229: orden de compra de "mix" y de las estrategias de M50 en los mapas que NO ofrecen la Ametralladora (niveles 11
## a 15, RF-474): abre con Cañón y Hielo (RF-474: Hielo + una torre de 90 a 110) y sigue con lo barato antes que lo caro.
const NO_BASIC_ORDER: Array[int] = [1, 2, 1, 3, 1, 5, 3, 7, 1, 6, 3, 4, 1, 2, 7, 3, 6, 5]
## Orden de compra de "heavy" (M19): como "mix" más el Mortero (8) cada tanto.
const HEAVY_ORDER: Array[int] = [0, 0, 0, 7, 1, 4, 0, 8, 5, 3, 6, 8, 2, 7, 0, 4, 8, 5, 6, 3, 1]
## RF-452: id de la Disruptora y cuántas compra como máximo el bot (valores de la herramienta, no del juego).
const DISRUPTOR_ID: StringName = &"disruptor"
const DISRUPTOR_MAX: int = 2
const DISRUPTOR_AFTER_COMMON: int = 3
const DISRUPTOR_SECOND_AT: int = 8
const DISRUPTOR_BOT_RESOURCES: int = 4
## Cada cuántos píxeles se mide el camino para puntuar las casillas.
const PATH_SAMPLE_STEP: float = 16.0
## T214: torres que se compran antes de juntar oro para infraestructura (que no se quede sin defensa).
const MIN_DEFENSE: int = 2
## T214: removibles que tienen que valer la pena para que "demoledora" compre la máquina.
const MACHINE_MIN_TARGETS: int = 4

# Node2D y no Game: este script se compila antes que los autoloads, y game.gd los usa.
var game: Node2D
var strategy: String = "smart"
## Estrategias a jugar (T204): normalmente una; "mix,smart" juega las dos.
var strategies: Array[String] = []
var rng := RandomNumberGenerator.new()
var built: int = 0
var last_reported_wave: int = 0
var path_points: Array[Vector2] = []
var air_points: Array[Vector2] = []
## Nivel de la campaña a jugar (1, 2, 3…). 0 = el primero.
var level_number: int = 0
## file=ruta: juega un archivo de nivel en vez de uno de la campaña (por ejemplo, un mapa de ejemplo o de la comunidad).
var level_file: String = ""
## modo=asedio: juega el mapa level=N de un modo oficial, con las reglas del modo (RF-391).
var mode_id: String = ""
## levelscale=N: prueba otro % de vida por oleada para el nivel elegido (D-019). -1 = no tocar.
var level_scale_override: int = -1
var starting_gold_override: int = -1
## T204: mapas y semillas a jugar, y la cola de partidas pendientes.
var level_numbers: Array[int] = []
var seed_list: Array[int] = [BalanceArgs.DEFAULT_SEED]
var report_path: String = ""
## RF-452: disruptor=0 apaga la compra de la Disruptora (para comparar).
var disruptor_enabled: bool = true
var disruptors_built: int = 0
var _disruptor_prepared: bool = false
var _queue: Array[Dictionary] = []
var _rows: Array[Dictionary] = []
var _current: Dictionary = {}
var _spawner_seeded: bool = false
## T214: orden de compra (posición en MIX_ORDER), torres con recursos, y lo que mide cada partida.
var _order_pos: int = 0
var _check_rule: bool = false
var _seeds_given: bool = false
var _worth_cache: Array[Vector2i] = []
var _worth_dirty: bool = true
var _had_job: bool = false
var _watched: LevelSession
var _res_last: int = 0
var _res_gained: int = 0
## Oro que le robaron en la partida (T253: mide a La Cuadrilla; no cambia ningún resultado).
var _stolen: int = 0
var _infra_gold: int = 0
var _machine_wave: int = -1
var _first_resource_tower_wave: int = -1
var _sites_enabled: int = 0
var _campaign: CampaignData
## Recursos modificados por los ajustes. Se guardan aquí para que Godot no los descarte
## de su caché (si nadie los usa, los libera y la partida los volvería a leer del disco).
var _kept: Array[Resource] = []


func _initialize() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	var strategy_text: String = "smart"
	if not args.is_empty():
		strategy_text = args[0]
	strategies = BalanceArgs.parse_strategies(strategy_text)
	if strategies.is_empty():
		strategies = ["smart"]
	for arg: String in args.slice(1):
		_apply_override(arg)
	if _check_rule:
		_prepare_rule_check()
	# Este script se compila antes que los autoloads: no puede usar GameFlow por su nombre.
	_campaign = _keep(LevelFile.load_campaign())
	if level_numbers.is_empty() and not _check_rule:
		level_numbers = [maxi(level_number, 1)]
	for level_n: int in level_numbers:
		for strategy_name: String in strategies:
			for seed_n: int in seed_list:
				_queue.append({"level": level_n, "strategy": strategy_name, "seed": seed_n})
	if _queue.is_empty() and _check_rule:
		_finish_rule_check()  # ningún mapa con recursos: no hay nada que comprobar
		return
	_start_next_run()


## Arma la partida de la cola y la agrega al árbol. Devuelve false si no quedan más.
func _start_next_run() -> bool:
	if _queue.is_empty():
		return false
	_current = _queue.pop_front()
	strategy = _current["strategy"]
	level_number = _current["level"]
	built = 0
	disruptors_built = 0
	_disruptor_prepared = false
	last_reported_wave = 0
	_order_pos = 0
	_worth_cache.clear()
	_worth_dirty = true
	_had_job = false
	_watched = null
	_res_last = 0
	_res_gained = 0
	_stolen = 0
	_infra_gold = 0
	_machine_wave = -1
	_first_resource_tower_wave = -1
	_sites_enabled = 0
	path_points.clear()
	air_points.clear()
	rng.seed = _current["seed"]
	# T204: la semilla manda sobre TODO el azar de la partida, sin cambiar cómo se sortea nada:
	# el temblor de pantalla usa el generador global; el sorteo de grupos, el del WaveSpawner (más abajo).
	seed(_current["seed"])
	# T214: el sorteo del drop de los removibles (RF-417) usa la misma semilla. GameFlow es un autoload:
	# este script no puede nombrarlo, se lo busca por el árbol.
	root.get_node("GameFlow").set("forced_seed", _current["seed"])
	game = (_keep(load("res://scenes/game/game.tscn")) as PackedScene).instantiate()
	if level_number > _campaign.levels.size():
		print("No existe el mapa %d (la campaña tiene %d)." % [level_number, _campaign.levels.size()])
		quit(1)
		return false
	game.level_data = _campaign.levels[level_number - 1]
	if level_file != "":
		var result: Dictionary = LevelFile.load_level(level_file)
		if result["level"] == null:
			print("No se pudo leer %s: %s" % [level_file, result["errors"]])
			quit(1)
			return false
		game.level_data = _keep(result["level"])
	if mode_id != "":
		var mode: Dictionary = ModePacks.read(ModePacks.OFFICIAL_DIR, mode_id, true)
		var mode_level: LevelData = ModePacks.map_level(mode, level_number - 1)
		if mode_level == null:
			print("No se pudo leer el mapa %d del modo %s: %s" % [level_number, mode_id, mode["errors"]])
			quit(1)
			return false
		game.level_data = _keep(mode_level)
		print("Modo: %s · oro inicial %d · vida de los monstruos %d %%" % [mode["name"], mode_level.starting_gold, mode_level.enemy_health_percent])
	if strategy == "heavy":
		game.level_data.extra_towers = PackedStringArray(["mortar"])  # RF-300: los niveles comunes no lo traen
	if starting_gold_override >= 0:
		game.level_data.starting_gold = starting_gold_override
	if level_scale_override >= 0:
		game.level_data.health_scale_percent_per_wave = level_scale_override
	root.add_child(game)
	_seed_spawner()
	print("Nivel: %s · estrategia: %s · semilla: %d · vida del Normal: %d" % [
		game.level_data.display_name, strategy, _current["seed"],
		(load("res://data/enemies/normal.tres") as EnemyData).max_health])
	return true


## Prueba de números SIN tocar los archivos: cambia los recursos ya cargados en memoria.
##   hp=1.5      multiplica la vida base de todos los enemigos
##   scale=15    % de vida extra por oleada (BalanceConfig)
##   reward=0.8  multiplica el oro que da cada enemigo
##   gold=120    oro inicial del nivel
##   <torre>.<campo>=valor    cambia el nivel 1 de una torre (ej: cannon.damage=20)
##   <enemigo>.<campo>=valor  cambia un enemigo (ej: tank.max_health=120)
func _apply_override(arg: String) -> void:
	var parts: PackedStringArray = arg.split("=")
	if parts[0] == "file":
		level_file = parts[1] if parts[1].begins_with("res://") else "res://" + parts[1]
		return
	if parts[0] == "modo":
		mode_id = parts[1]  # RF-391: el mapa level=N de ese modo oficial, con sus reglas
		return
	if parts[0] == "report":
		report_path = parts[1]
		return
	if parts[0] == "check_rule":
		_check_rule = parts[1] == "1"
	if parts[0] == "disruptor":
		disruptor_enabled = parts[1] != "0"
		return
	if parts[0] == "levels":
		level_numbers = BalanceArgs.parse_levels(parts[1])
		if level_numbers.is_empty():
			print("levels=%s no es válido (se espera A-B, por ejemplo levels=6-9)." % parts[1])
			quit(1)
		return
	var value: float = parts[1].to_float()
	if parts[0] == "seed":
		seed_list = [int(value)]
		_seeds_given = true
		return
	if parts[0] == "seeds":
		seed_list = BalanceArgs.seeds_up_to(int(value))
		_seeds_given = true
		return
	if parts[0] == "level":
		level_number = int(value)
		return
	if parts[0] == "levelscale":
		level_scale_override = int(value)  # se aplica al elegir el nivel
		print("Ajuste: ", arg)
		return
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
			starting_gold_override = int(value)  # se aplica al elegir el nivel
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


## El WaveSpawner sortea con randomize() en su setup(), que corre en el _ready de la partida: recién
## ahí se le puede fijar la semilla. Solo inyecta el generador; el juego sortea igual que siempre.
## En la primera partida el árbol todavía no está andando (_ready llega después), así que se reintenta.
func _seed_spawner() -> void:
	if game.is_node_ready():
		game.spawner.rng.seed = _current["seed"]
		_spawner_seeded = true
	else:
		_spawner_seeded = false


func _process(_delta: float) -> bool:
	if game == null:
		return true
	if not _spawner_seeded:
		_seed_spawner()
	if path_points.is_empty():
		_sample_path()
	if not _disruptor_prepared and game.is_node_ready():
		_prepare_disruptor()
	var session: LevelSession = game.session
	if _watched != session:
		_watched = session
		session.resources_changed.connect(_on_resources_changed)
		session.gold_stolen.connect(func(amount: int) -> void: _stolen += amount)
	var single_run: bool = _rows.is_empty() and _queue.is_empty()
	if single_run and session.wave > last_reported_wave and session.state != LevelSession.State.WAVE_RUNNING:
		last_reported_wave = session.wave
		print("  oleada %2d terminada · vidas %2d · oro %4d · torres %2d" % [
			session.wave, session.lives, session.gold, built])
	if session.is_over():
		var won: bool = session.state == LevelSession.State.WON
		print("RESULTADO: %s · oleada %d/%d · vidas %d · oro robado %d" % [
			"VICTORIA" if won else "DERROTA", session.wave, session.total_waves, session.lives, _stolen])
		_rows.append({
			"level": _current["level"], "strategy": strategy, "seed": _current["seed"],
			"won": won, "lives": session.lives, "wave": session.wave,
			"total_waves": session.total_waves, "gold": session.gold,
			"machine_wave": _machine_wave, "resources_gained": _res_gained, "resources_left": session.resources,
			"gold_stolen": _stolen, "infra_gold": _infra_gold, "first_resource_tower_wave": _first_resource_tower_wave})
		root.remove_child(game)
		game.queue_free()
		game = null
		if _start_next_run():
			return false
		_print_summary()
		if _check_rule:
			_finish_rule_check()
		return true
	_buy_towers()
	if session.can_start_wave():
		game.start_next_wave()  # sin esperar la cuenta atrás
	return false


## Tabla final de todas las partidas (T204) y, con report=ruta, el mismo contenido en JSON.
## Si se jugó alguna estrategia de M50 (T214), suma las columnas de infraestructura.
func _print_summary() -> void:
	print("")
	var infra: bool = false
	for row: Dictionary in _rows:
		infra = infra or BalanceArgs.is_infra_strategy(row["strategy"])
	var header: String = "mapa | estrategia       | semilla | resultado | vidas | oleada | oro sobrante | oro robado"
	if infra:
		header += " | máquina | recursos obt. | recursos sobr. | oro infra. | 1.ª torre rec."
	print(header)
	for row: Dictionary in _rows:
		var line: String = "%4d | %-16s | %7d | %-9s | %5d | %2d/%-3d | %5d" % [
			row["level"], row["strategy"], row["seed"], "VICTORIA" if row["won"] else "DERROTA",
			row["lives"], row["wave"], row["total_waves"], row["gold"]]
		line += " | %10d" % row["gold_stolen"]
		if infra:
			line += " | %7s | %13d | %14d | %10d | %14s" % [
				_wave_text(row["machine_wave"]), row["resources_gained"], row["resources_left"],
				row["infra_gold"], _wave_text(row["first_resource_tower_wave"])]
		print(line)
	var wins: int = 0
	for row: Dictionary in _rows:
		if row["won"]:
			wins += 1
	print("Victorias: %d de %d" % [wins, _rows.size()])
	if report_path != "":
		var file := FileAccess.open(report_path, FileAccess.WRITE)
		if file == null:
			print("No se pudo escribir %s" % report_path)
			return
		file.store_string(JSON.stringify(_rows, "\t"))
		print("Informe guardado en ", ProjectSettings.globalize_path(report_path))


## "oleada 3" como "o3"; "—" si no pasó.
func _wave_text(wave: int) -> String:
	return "—" if wave < 0 else "o%d" % wave
## RF-452: el bot no puede juntar piezas ni extraer recursos, así que si el mapa ofrece la Disruptora la
## habilita (simula la colección completa) y le da unos recursos. Solo la estrategia "mix".
func _prepare_disruptor() -> void:
	_disruptor_prepared = true
	var tower: TowerData = _disruptor()
	if tower == null or strategy != "mix" or not disruptor_enabled:
		return
	var level: LevelData = game.level_data
	if not (level.towers.has(String(DISRUPTOR_ID)) or level.extra_towers.has(String(DISRUPTOR_ID))):
		return
	if not game.available_towers.has(tower):
		game.available_towers.append(tower)  # es el mismo arreglo que usa el BuildController
	game.session.add_resources(DISRUPTOR_BOT_RESOURCES)


func _disruptor() -> TowerData:
	for tower: TowerData in game.tower_types:
		if tower.id == DISRUPTOR_ID:
			return tower
	return null


## RF-452: ¿la oleada en curso o la que sigue trae un enemigo con aura? (se lee de los datos del enemigo).
## El bot no la compra antes: hasta entonces la Disruptora gasta oro en una torre que casi no daña.
func _level_has_aura_emitters() -> bool:
	var waves: Array[WaveData] = game.level_data.waves
	var first: int = maxi(game.session.wave - 1, 0)
	for index: int in range(first, mini(game.session.wave + 1, waves.size())):
		for group: SpawnGroup in waves[index].groups:
			if group.enemy != null and TowerText.has_aura(group.enemy):
				return true
	return false


## RF-452: la compra de la Disruptora, por id: disponible, hay emisores, 3 torres comunes (8 para la segunda),
## alcanzan oro y recursos, y como mucho 2. "sin_recursos" y disruptor=0 nunca.
func _wants_disruptor() -> bool:
	if strategy != "mix" or not disruptor_enabled or disruptors_built >= DISRUPTOR_MAX:
		return false
	var tower: TowerData = _disruptor()
	if tower == null or not game.available_towers.has(tower) or not _level_has_aura_emitters():
		return false
	var common: int = built - disruptors_built
	if common < DISRUPTOR_AFTER_COMMON or (disruptors_built >= 1 and built < DISRUPTOR_SECOND_AT):
		return false
	return game.session.can_afford_both(tower.build_gold(), tower.build_resources())


func _buy_towers() -> void:
	if BalanceArgs.is_infra_strategy(strategy):
		_buy_towers_infra()
		return
	while true:
		if _wants_disruptor():
			var disruptor: TowerData = _disruptor()
			if game.build_controller.try_build(disruptor, _best_cell(disruptor)):
				built += 1
				disruptors_built += 1
				continue
		var index: int = 0
		var advance: int = 0
		if strategy == "smart":
			index = SMART_ORDER[built % SMART_ORDER.size()]
		elif strategy == "heavy":
			index = HEAVY_ORDER[built % HEAVY_ORDER.size()] % game.tower_types.size()
		elif strategy == "mix":
			index = MIX_ORDER[built % MIX_ORDER.size()] % game.tower_types.size()
		var tower: TowerData = game.tower_types[index]
		if strategy == "mix":
			# T229: "mix" compra solo lo que el mapa ofrece (los niveles 11 a 15 no traen la Ametralladora, RF-474).
			# En los mapas que ofrecen todo el orden da exactamente la misma secuencia de siempre.
			var pick: Dictionary = _order_pick()
			if pick.is_empty():
				return
			tower = pick["tower"]
			advance = pick["advance"]
		if not game.session.can_afford(tower.levels[0].cost):
			return
		var cell: Vector2i = _random_cell() if strategy == "naive" else _best_cell(tower)
		if not game.build_controller.try_build(tower, cell):
			return
		built += 1
		_order_pos += advance


func _free_cells() -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for cell: Vector2i in game.level.ground.get_used_cells():
		if game.level.is_buildable(cell) and not game.build_controller.is_occupied(cell):
			cells.append(cell)
	return cells


## Una casilla libre al azar, o (-1, -1) si el mapa ya está lleno de torres
## (entonces try_build falla y el bot deja de comprar).
func _random_cell() -> Vector2i:
	var cells: Array[Vector2i] = _free_cells()
	if cells.is_empty():
		return Vector2i(-1, -1)
	return cells[rng.randi_range(0, cells.size() - 1)]


## La casilla libre desde la que la torre alcanza más tramo de camino.
## Las torres que golpean voladores también cuentan el camino aéreo.
func _best_cell(tower: TowerData) -> Vector2i:
	var best: Vector2i = Vector2i(-1, -1)
	var best_score: int = -1
	for cell: Vector2i in _free_cells():
		if tower.footprint > 1 and not game.build_controller.cells_free(tower, cell):
			continue  # una torre grande necesita todo su cuadrado libre (RF-291)
		var score: int = _cell_score(tower, cell)
		if score > best_score:
			best_score = score
			best = cell
	return best


## Cuánto camino alcanza la torre desde esa casilla (la casilla puede estar ocupada por un removible).
func _cell_score(tower: TowerData, cell: Vector2i) -> int:
	var range_px: float = Rules.tiles_to_px(tower.levels[0].range_tiles)
	var center: Vector2 = game.level.cell_center(cell) + Vector2.ONE * (tower.footprint - 1) * Rules.TILE_SIZE / 2.0
	var score: int = _points_in_range(path_points, center, range_px)
	if tower.can_hit_air:
		score += _points_in_range(air_points, center, range_px)
	return score


func _points_in_range(points: Array[Vector2], center: Vector2, range_px: float) -> int:
	var count: int = 0
	for point: Vector2 in points:
		if center.distance_to(point) <= range_px:
			count += 1
	return count


func _sample_path() -> void:
	for i: int in game.level.entrance_count():
		path_points.append_array(_sample(game.level.get_ground_path(i)))
		air_points.append_array(_sample(game.level.get_air_path(i)))


func _sample(path: Path2D) -> Array[Vector2]:
	var points: Array[Vector2] = []
	var distance: float = 0.0
	while distance <= path.curve.get_baked_length():
		points.append(path.to_global(path.curve.sample_baked(distance)))
		distance += PATH_SAMPLE_STEP
	return points


# --- T214: estrategias de infraestructura ---

func _on_resources_changed(value: int) -> void:
	if value > _res_last:
		_res_gained += value - _res_last
	_res_last = value


## Compra de las cinco estrategias de M50: primero decide qué infraestructura quiere pagar (y cuánto oro
## guarda para eso), después compra torres con lo que sobra. Las torres que se ofrecen son solo las del mapa.
func _buy_towers_infra() -> void:
	var session: LevelSession = game.session
	var reserve: int = _run_infrastructure()
	while true:
		var tower: TowerData = null
		var alt: bool = false
		var advance: int = 0
		var with_resources: bool = false
		var resource_pick: Dictionary = _resource_tower_pick()
		if not resource_pick.is_empty():
			tower = resource_pick["tower"]
			alt = resource_pick["alt"]
			with_resources = true
		else:
			var pick: Dictionary = _order_pick()
			if pick.is_empty():
				return
			tower = pick["tower"]
			advance = pick["advance"]
		var gold_cost: int = tower.build_gold(alt)
		if not session.can_afford_both(gold_cost, tower.build_resources(alt)):
			return
		if built >= MIN_DEFENSE and session.gold - gold_cost < reserve:
			return  # se está juntando oro para la infraestructura
		var cell: Vector2i = _best_cell(tower)
		if not game.build_controller.try_build(tower, cell, alt):
			return
		built += 1
		_worth_dirty = true
		if with_resources:
			if _first_resource_tower_wave < 0:
				_first_resource_tower_wave = session.wave
		else:
			_order_pos += advance


## El orden de compra de "mix": el de siempre, o el de NO_BASIC_ORDER si el mapa no ofrece la Ametralladora.
func _buy_order() -> Array[int]:
	for tower: TowerData in game.available_towers:
		if tower.id == &"basic":
			return MIX_ORDER
	return NO_BASIC_ORDER


## La próxima torre del orden de "mix" que el mapa ofrece y no cuesta recursos. Vacío si no hay ninguna.
## `advance` cuenta las entradas del orden que se saltó, para seguir desde ahí.
func _order_pick() -> Dictionary:
	var order: Array[int] = _buy_order()
	for offset: int in order.size():
		var tower: TowerData = game.tower_types[order[(_order_pos + offset) % order.size()] % game.tower_types.size()]
		if game.available_towers.has(tower) and tower.resource_cost == 0:
			return {"tower": tower, "advance": offset + 1}
	return {}


## Solo las estrategias de extracción construyen con recursos (la más simple: la primera torre del mapa que
## alcance, con la segunda forma de pago si la tiene). Vacío si no hay ninguna que alcance.
func _resource_tower_pick() -> Dictionary:
	if not strategy.begins_with("extraer"):
		return {}
	var session: LevelSession = game.session
	for tower: TowerData in game.available_towers:
		if tower.has_alt_payment() and session.can_afford_both(tower.build_gold(true), tower.build_resources(true)):
			return {"tower": tower, "alt": true}
		if tower.resource_cost > 0 and session.can_afford_both(tower.build_gold(false), tower.resource_cost):
			return {"tower": tower, "alt": false}
	return {}


## Paga la infraestructura que toca. Devuelve el oro que hay que guardar para la próxima compra (0 si no hay).
func _run_infrastructure() -> int:
	var controller: Node = game.infrastructure
	var session: LevelSession = game.session
	if _had_job and not controller.field.has_job():
		_worth_dirty = true  # terminó una demolición: la casilla ya es pasto
	_had_job = controller.field.has_job()
	match strategy:
		"demoler", "demoledora":
			return _run_demolition(controller, session)
		"pieza":
			return _run_piece(controller, session)
		"extraer_temprano":
			return _run_extraction(controller, session, 1)
		"extraer_tarde":
			return _run_extraction(controller, session, maxi(1, ceili(session.total_waves / 2.0)))
	return 0


func _run_demolition(controller: Node, session: LevelSession) -> int:
	var field: ObstacleField = controller.field
	var worth: Array[Vector2i] = _worthwhile_removables()
	if strategy == "demoledora" and controller.machine_enabled and not field.has_machine and worth.size() >= MACHINE_MIN_TARGETS:
		var price: int = field.machine_price()
		if session.gold >= price and controller.buy_machine():
			_infra_gold += price
			_machine_wave = session.wave
			return 0
		return price
	if field.has_job() or worth.is_empty():
		return 0
	var cell: Vector2i = worth[0]
	var cost: int = field.cost_of(cell)
	if session.gold >= cost and controller.order(cell):
		_infra_gold += cost
		_worth_dirty = true
		return 0
	return cost


## Estrategia "pieza": demuele solo la ruina que guarda la pieza de colección. Devuelve el oro que hay que guardar.
func _run_piece(controller: Node, session: LevelSession) -> int:
	var field: ObstacleField = controller.field
	if field.has_job():
		return 0
	for spec: ObstacleSpec in game.level_data.obstacles:
		if spec.kind != ObstacleSpec.Kind.REMOVABLE or spec.finding_collection == &"":
			continue
		if game.infrastructure.obstacle_at(spec.cell) == null:
			continue  # ya demolida
		var cost: int = field.cost_of(spec.cell)
		if session.gold >= cost and controller.order(spec.cell):
			_infra_gold += cost
			return 0
		return cost
	return 0


## Habilita los puntos de extracción (de a uno, el de más reserva primero) desde la oleada `from_wave`.
func _run_extraction(controller: Node, session: LevelSession, from_wave: int) -> int:
	if session.wave < from_wave:
		return 0
	var field: ObstacleField = controller.field
	for cell: Vector2i in field.extraction_cells():
		if field.can_enable(cell) != &"" or field.reserve_left(cell) <= 0:
			continue
		var cost: int = field.cost_of(cell)
		if session.gold >= cost and controller.enable(cell):
			_infra_gold += cost
			_sites_enabled += 1
			return 0
		return cost
	return 0


## Los removibles que valen la pena: desde su casilla la torre de referencia (la primera del orden)
## alcanzaría más camino que desde la mejor casilla libre que queda. Del mejor al peor.
## Se recalcula solo cuando cambió el mapa (se construyó una torre o terminó una demolición).
func _worthwhile_removables() -> Array[Vector2i]:
	if not _worth_dirty:
		return _worth_cache
	_worth_dirty = false
	_worth_cache.clear()
	var reference: TowerData = game.tower_types[0]
	var best_free: int = 0
	for cell: Vector2i in _free_cells():
		best_free = maxi(best_free, _cell_score(reference, cell))
	var scored: Array[Dictionary] = []
	for spec: ObstacleSpec in game.level_data.obstacles:
		if spec.kind != ObstacleSpec.Kind.REMOVABLE or game.infrastructure.obstacle_at(spec.cell) == null:
			continue
		var score: int = _cell_score(reference, spec.cell)
		if score > best_free:
			scored.append({"cell": spec.cell, "score": score})
	scored.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if a["score"] != b["score"]:
			return a["score"] > b["score"]
		return a["cell"].y < b["cell"].y or (a["cell"].y == b["cell"].y and a["cell"].x < b["cell"].x))
	for entry: Dictionary in scored:
		_worth_cache.append(entry["cell"])
	return _worth_cache


# --- T214: regla de oro (check_rule=1, RF-432) ---

## Deja en la cola solo `sin_recursos` con las N semillas, en los mapas con recursos.
func _prepare_rule_check() -> void:
	strategies = ["sin_recursos"]
	if _seeds_given:
		print("check_rule=1 usa siempre %d semillas (RF-432): se ignora seed=/seeds=." % BalanceArgs.RULE_SEEDS)
	seed_list = BalanceArgs.seeds_up_to(BalanceArgs.RULE_SEEDS)
	if not level_numbers.is_empty() or level_number > 0 or level_file != "" or mode_id != "":
		if level_numbers.is_empty():
			level_numbers = [maxi(level_number, 1)]
		return  # el mapa lo pidió quien corre la herramienta: se comprueba aunque no tenga recursos
	var campaign: CampaignData = _keep(LevelFile.load_campaign())
	for index: int in campaign.levels.size():
		if campaign.levels[index].uses_resources():
			level_numbers.append(index + 1)
	if level_numbers.is_empty():
		print("check_rule=1: ningún mapa de la campaña tiene recursos todavía; la regla no tiene nada que comprobar.")


## Imprime el veredicto por mapa y termina con el código de salida (0 cumple, 1 no cumple).
func _finish_rule_check() -> void:
	var summary: Dictionary = BalanceArgs.rule_summary(_rows)
	print("")
	print("Regla de oro (RF-432): sin_recursos tiene que ganar al menos %d de %d partidas en cada mapa con recursos." % [
		BalanceArgs.RULE_MIN_WINS, BalanceArgs.RULE_SEEDS])
	for level_n: int in summary:
		print("  mapa %d: %d de %d · %s" % [level_n, summary[level_n]["wins"], summary[level_n]["total"],
			"CUMPLE" if BalanceArgs.rule_holds(summary[level_n]["wins"], summary[level_n]["total"]) else "NO CUMPLE"])
	var code: int = BalanceArgs.rule_exit_code(_rows)
	if summary.is_empty():
		print("  No se jugó ningún mapa (sin mapas con recursos no hay nada que comprobar).")
		code = 0 if level_numbers.is_empty() else 1
	print("REGLA DE ORO: %s" % ("SE CUMPLE" if code == 0 else "NO SE CUMPLE"))
	quit(code)
