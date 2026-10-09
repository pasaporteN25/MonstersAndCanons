# Mide los FPS de un nivel REAL con las oleadas finales (T236, constitución P7). NO es un test: abre una ventana.
# Usa la escena de partida de verdad (`game.tscn`), un mapa de la campaña y su oleada completa a velocidad 1.
#
#   godot --path . res://tools/perf_levels.tscn -- level=15 from=25
#
#   level=N    mapa de la campaña (por omisión 15)
#   from=W     las oleadas 1 a W se dan por completadas con la sesión (no se juegan) y se juegan de verdad la W+1 en adelante
#              (por omisión, las últimas 5)
#   to=W       última oleada que se juega (por omisión, la última del nivel)
#   towers=K   tope de torres a comprar (por omisión, todas las que alcance el oro)
#   seconds=N  mide solo los primeros N segundos de cada oleada (diagnóstico)
#   shot=ruta  guarda una captura (PNG) a los 10 segundos de cada oleada; sirve para mirar qué se ve
#   vsync=1    deja el vsync prendido (por omisión se apaga para medir lo que el equipo puede dar)
#
# Compra defensa con `try_build` (no con clics: acá se mide el dibujo y la simulación, no la interfaz), usa la máquina
# demoledora y demuele los removibles, habilita los puntos de extracción y deja a la Disruptora disparar sus pulsos cuando el
# mapa la ofrece. Las vidas son infinitas: lo que se mide es el rendimiento, no si la defensa aguanta (eso es del bot).
# Imprime, por oleada, los FPS promedio, el 1 % más lento, el frame más lento, los frames de más de 16,6 ms y los
# enemigos y torres. Termina con un resumen en una línea.
extends Node

const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")
## Mismo orden de compra que el bot en mapas sin Ametralladora; la Disruptora al final para que haya pulsos.
const ORDER: Array[String] = ["cannon", "frost", "cannon", "sniper", "cannon", "multi", "sniper", "tesla", "cannon",
	"burst", "disruptor", "sniper", "fire", "cannon", "frost", "disruptor", "tesla", "sniper", "burst", "multi", "mortar"]

var level_number: int = 15
var from_wave: int = -1
var to_wave: int = -1
var max_towers: int = 1000
## Para buscar qué cuesta: "towers" apaga la lógica de las torres, "enemies" la de los enemigos (solo diagnóstico).
var off: String = ""
var shot_path: String = ""
## Para diagnosticar: corta la medición de cada oleada a los N segundos (0 = la oleada entera).
var max_seconds: float = 0.0
var game: Game
var _order_pos: int = 0
var _bad_cells: Dictionary = {}
var _summary: Array[String] = []


func _ready() -> void:
	var vsync: bool = false
	for arg: String in OS.get_cmdline_user_args():
		var parts: PackedStringArray = arg.split("=")
		if parts.size() != 2:
			continue
		match parts[0]:
			"level": level_number = int(parts[1])
			"from": from_wave = int(parts[1])
			"to": to_wave = int(parts[1])
			"towers": max_towers = int(parts[1])
			"off": off = parts[1]
			"shot": shot_path = parts[1]
			"seconds": max_seconds = float(parts[1])
			"vsync": vsync = parts[1] == "1"
	if not vsync:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		Engine.max_fps = 0
	DevMode.enabled = false
	SaveManager.save_path = "user://perf_levels_%d.json" % level_number
	if FileAccess.file_exists(SaveManager.save_path):
		DirAccess.remove_absolute(SaveManager.save_path)
	SaveManager.load_save()
	# Con las dos colecciones completas, así la Disruptora y el resto están en la barra.
	for source: String in ["level_08", "level_09", "level_10"]:
		SaveManager.collect_source(&"disruptor", StringName(source))
	GameFlow.current_index = level_number - 1
	GameFlow.current_community = null
	GameFlow.intro_pending = false
	GameFlow.forced_seed = 3
	game = GAME_SCENE.instantiate()
	add_child(game)
	await _frames(4)
	await _run()
	if FileAccess.file_exists(SaveManager.save_path):
		DirAccess.remove_absolute(SaveManager.save_path)
	get_tree().quit()


func _frames(count: int) -> void:
	for i: int in count:
		await get_tree().process_frame


func _run() -> void:
	var total: int = game.level_data.waves.size()
	if to_wave <= 0 or to_wave > total:
		to_wave = total
	if from_wave < 0:
		from_wave = maxi(0, to_wave - 5)
	print("PERF nivel %d «%s» · %s · ventana %s · %s · oleadas jugadas %d a %d de %d" % [level_number, game.level_data.display_name,
		RenderingServer.get_video_adapter_name(), get_window().size, "vsync" if DisplayServer.window_get_vsync_mode() != DisplayServer.VSYNC_DISABLED else "sin vsync",
		from_wave + 1, to_wave, total])
	game.session.infinite_lives = true
	game.session.earn(20000)
	await _buy()
	var infra: InfrastructureController = game.infrastructure
	infra.buy_machine()
	for cell: Vector2i in infra.field.extraction_cells():
		infra.enable(cell)
	for i: int in from_wave:
		game.session.begin_wave()
		game.session.complete_wave()
		if i % 6 == 5:
			game.session.earn(3000)
			await _buy()
	game.session.earn(3000)
	await _buy()
	print("PERF defensa: %d torres, %d de oro, %d vidas" % [game.tower_container.get_child_count(), game.session.gold, game.session.lives])
	while not game.session.is_over() and game.session.wave < to_wave:
		await _wave()
	print("PERF RESUMEN nivel %d: %s" % [level_number, " | ".join(_summary)])


func _wave() -> void:
	await _buy()
	var infra: InfrastructureController = game.infrastructure
	game.start_next_wave()
	if off == "towers":
		for tower: Node in game.tower_container.get_children():
			tower.set_physics_process(false)
	var wave: int = game.session.wave
	var deltas: Array[float] = []
	var max_enemies: int = 0
	var proc_sum: float = 0.0
	var phys_sum: float = 0.0
	var draws_sum: float = 0.0
	var nodes_max: int = 0
	var started: int = Time.get_ticks_usec()
	var last: int = started
	var demolitions: int = 0
	var frames_since_order: int = 1000
	while game.session.state == LevelSession.State.WAVE_RUNNING and Time.get_ticks_usec() - started < (400 if max_seconds <= 0.0 else max_seconds) * 1000000.0:
		await get_tree().process_frame
		var now: int = Time.get_ticks_usec()
		deltas.append((now - last) / 1000.0)
		last = now
		max_enemies = maxi(max_enemies, get_tree().get_nodes_in_group(Enemy.GROUP).size())
		proc_sum += Performance.get_monitor(Performance.TIME_PROCESS)
		phys_sum += Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS)
		draws_sum += Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
		nodes_max = maxi(nodes_max, int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT)))
		if shot_path != "" and Time.get_ticks_usec() - started > 10 * 1000000 and not FileAccess.file_exists(shot_path.replace(".png", "_%d.png" % wave)):
			await RenderingServer.frame_post_draw
			get_viewport().get_texture().get_image().save_png(shot_path.replace(".png", "_%d.png" % wave))
		# Una demolición a la vez durante la oleada: es el trabajo que corre junto con el combate.
		frames_since_order += 1
		if not infra.field.has_job() and frames_since_order > 120:
			for y: int in game.level_data.map_rows.size():
				for x: int in game.level_data.map_rows[0].length():
					if infra.order(Vector2i(x, y)):
						demolitions += 1
						frames_since_order = 0
						break
				if frames_since_order == 0:
					break
	var n: float = maxf(1.0, deltas.size())
	print("PERF   detalle oleada %d: proceso %.1f ms · física %.1f ms por frame · %.0f llamadas de dibujo · hasta %d nodos" % [
		wave, proc_sum / n * 1000.0, phys_sum / n * 1000.0, draws_sum / n, nodes_max])
	_report(wave, deltas, max_enemies, demolitions)


func _report(wave: int, deltas: Array[float], max_enemies: int, demolitions: int) -> void:
	if deltas.is_empty():
		return
	var sorted: Array[float] = deltas.duplicate()
	sorted.sort()
	var sum: float = 0.0
	var slow: int = 0
	for d: float in deltas:
		sum += d
		if d > 1000.0 / 60.0:
			slow += 1
	var fps: float = 1000.0 * deltas.size() / sum
	var p99: float = sorted[mini(sorted.size() - 1, int(sorted.size() * 0.99))]
	var line: String = "oleada %d: %.0f FPS promedio · 1%% más lento %.1f ms (%.0f FPS) · peor frame %.1f ms · %d de %d frames > 16,6 ms · hasta %d enemigos · %d torres · %d demoliciones · vidas %d · %.0f s" % [
		wave, fps, p99, 1000.0 / p99, sorted[-1], slow, deltas.size(), max_enemies,
		game.tower_container.get_child_count(), demolitions, game.session.lives, sum / 1000.0]
	print("PERF ", line)
	_summary.append("%d: %.0f FPS (peor %.0f ms)" % [wave, fps, sorted[-1]])


func _tower_index(id: String) -> int:
	for i: int in game.available_towers.size():
		if String(game.available_towers[i].id) == id:
			return i
	return -1


func _best_cell(tower: TowerData, points: Array[Vector2]) -> Vector2i:
	var best: Vector2i = Vector2i(-1, -1)
	var best_score: int = -1
	var range_px: float = Rules.tiles_to_px(tower.levels[0].range_tiles)
	var rows: int = game.level_data.map_rows.size()
	var cols: int = game.level_data.map_rows[0].length()
	for y: int in rows:
		for x: int in cols:
			var cell := Vector2i(x, y)
			if _bad_cells.has(cell) or not game.build_controller.cells_free(tower, cell):
				continue
			var center: Vector2 = game.level.cell_center(cell)
			var score: int = 0
			for point: Vector2 in points:
				if point.distance_to(center) <= range_px:
					score += 1
			if score > best_score:
				best_score = score
				best = cell
	return best


func _path_points() -> Array[Vector2]:
	var points: Array[Vector2] = []
	for entrance: int in game.level.entrance_count():
		var path: Path2D = game.level.get_ground_path(entrance)
		var length: float = path.curve.get_baked_length()
		var d: float = 0.0
		while d < length:
			points.append(path.to_global(path.curve.sample_baked(d)))
			d += 16.0
	return points


func _buy() -> void:
	var points: Array[Vector2] = _path_points()
	var misses: int = 0
	while not game.session.is_over() and misses < 30 and game.tower_container.get_child_count() < max_towers:
		var id: String = ORDER[_order_pos % ORDER.size()]
		_order_pos += 1
		var index: int = _tower_index(id)
		if index < 0:
			misses += 1
			continue
		var tower: TowerData = game.available_towers[index]
		if game.session.gold < tower.levels[0].cost:
			misses += 1
			continue
		var cell: Vector2i = _best_cell(tower, points)
		if cell.x < 0 or not game.build_controller.try_build(tower, cell):
			_bad_cells[cell] = true
			misses += 1
			continue
		misses = 0
