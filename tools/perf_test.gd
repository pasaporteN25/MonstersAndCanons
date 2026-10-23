# Prueba de rendimiento (T56, constitución P7): 200 enemigos, 60 torres y efectos visuales.
# NO es un test automático: abre una ventana (hace falta dibujar de verdad) y mide los FPS.
#
# Uso (desde la carpeta del proyecto):
#   godot --path . -s tools/perf_test.gd
#   godot --path . -s tools/perf_test.gd -- sin_numeros    (compara sin números de daño)
#   godot --path . -s tools/perf_test.gd -- mejoras        (M65: mejora 10 torres seguidas durante la medición)
#   godot --path . -s tools/perf_test.gd -- mejoras sin_fx (lo mismo con «Animaciones de mejora» apagadas: el anillo de siempre)
#   godot --path . -s tools/perf_test.gd -- celular        (interfaz del celular, 1280 × 720 virtual; se puede combinar con lo anterior)
#
# Desactiva el vsync para medir cuántos FPS puede dar el juego, no los del monitor.
extends SceneTree

const ENEMY_SCENE_PATH: String = "res://scenes/enemies/enemy.tscn"
const ENEMY_COUNT: int = 200
const TOWER_COUNT: int = 60
## Muertes "de mentira" por segundo, para que siempre haya estallidos en pantalla.
const DEATH_EFFECTS_PER_SECOND: float = 15.0
const WARMUP_SECONDS: float = 1.0
const MEASURE_SECONDS: float = 6.0
## M65: cuántas torres se mejoran seguidas con "mejoras", y cada cuánto.
const UPGRADE_COUNT: int = 10
const UPGRADE_EVERY_SECONDS: float = 0.4

# Node2D y no Game: este script se compila antes que los autoloads, y game.gd los usa.
var game: Node2D
var time: float = 0.0
var frames_measured: int = 0
var death_timer: float = 0.0
var worst_frame_ms: float = 0.0
## Frames que tardaron más de 16,6 ms (los que a 60 FPS se notarían como un tirón).
var slow_frames: int = 0
var normal: EnemyData = load("res://data/enemies/normal.tres")
## Suma del tiempo de proceso por cuadro (ms): el costo de la lógica sin el dibujo, menos sensible a que la máquina esté ocupada.
var process_ms_total: float = 0.0
var upgrades_done: int = 0
var upgrade_timer: float = 0.0
## La suma de los tiempos de cuadro medidos.
var frame_ms_total: float = 0.0
## Ventana temporal idéntica con/sin efecto: evita diluir la entrada breve en los seis segundos.
var active_process_ms_total: float = 0.0
var active_frame_ms_total: float = 0.0
var active_frames: int = 0


func _initialize() -> void:
	seed(629)  # misma secuencia para cada par con y sin efecto
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0


## Los autoloads todavía no existen en `_initialize` (este script se compila antes): la partida se crea en el primer cuadro.
func _create_game() -> void:
	# Solo memoria: ninguna corrida modifica las preferencias guardadas.
	root.get_node("/root/SaveManager").call("set_setting", "damage_numbers", not "sin_numeros" in OS.get_cmdline_user_args())
	root.get_node("/root/SaveManager").call("set_setting", "upgrade_fx", not "sin_fx" in OS.get_cmdline_user_args())
	root.get_node("/root/SaveManager").call("set_setting", "ui_mode", 1 if "celular" in OS.get_cmdline_user_args() else 2)
	game = (load("res://scenes/game/game.tscn") as PackedScene).instantiate()
	root.add_child(game)


func _process(delta: float) -> bool:
	if game == null:
		# Una sola partida: duplicarla altera la carga y vuelve inválida la comparación.
		_create_game()
		return false
	if game.enemies.get_child_count() == 0 and time == 0.0:
		# "-- sin_numeros": apaga los números de daño solo en memoria (no se guarda).
		if "sin_numeros" in OS.get_cmdline_user_args():
			root.get_node("/root/SaveManager").call("set_setting", "damage_numbers", false)
			print("Números de daño: apagados")
		_populate()
	_keep_enemy_count()
	_fake_deaths(delta)
	_upgrade_in_a_row(delta)
	time += delta
	if time > WARMUP_SECONDS:
		frames_measured += 1
		process_ms_total += Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0
		frame_ms_total += delta * 1000.0
		# Diez mejoras y sus textos ocupan 4,9 s desde la primera.
		if time >= WARMUP_SECONDS and time < WARMUP_SECONDS + 4.9:
			active_frames += 1
			active_process_ms_total += Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0
			active_frame_ms_total += delta * 1000.0
		worst_frame_ms = maxf(worst_frame_ms, delta * 1000.0)
		if delta * 1000.0 > 1000.0 / 60.0:
			slow_frames += 1
	if time > WARMUP_SECONDS + MEASURE_SECONDS:
		var fps: float = frames_measured / MEASURE_SECONDS
		print("Enemigos: %d · Torres: %d · Efectos: %d" % [
			game.enemies.get_child_count(), game.tower_container.get_child_count(),
			game.effects.get_child_count()])
		if "mejoras" in OS.get_cmdline_user_args():
			print("Mejoras hechas: %d · efectos de mejora vivos al final: %d" % [upgrades_done, game.effects.upgrade_fx_alive()])
		print("Tiempo de proceso promedio: %.2f ms por cuadro" % (process_ms_total / maxf(frames_measured, 1)))
		print("FPS promedio: %.0f · frame más lento: %.1f ms · frames de más de 16,6 ms: %d de %d" % [
			fps, worst_frame_ms, slow_frames, frames_measured])
		print("Tiempo de cuadro promedio: %.2f ms" % (frame_ms_total / maxf(1.0, float(frames_measured))))
		print("Ventana activa simétrica: proceso %.2f ms · cuadro %.2f ms · %d cuadros" % [
			active_process_ms_total / maxi(active_frames, 1), active_frame_ms_total / maxi(active_frames, 1), active_frames])
		print("RESULTADO: %s (objetivo: 60 FPS)" % ("OK" if fps >= 60.0 else "LENTO"))
		return true
	return false


func _populate() -> void:
	game.session.earn(100000)
	game.session.add_resources(100000)  # las torres actuales pueden cobrar recursos además de oro
	if "apoyo" in OS.get_cmdline_user_args():
		var support: TowerData = load("res://data/towers/mechanical_standard.tres")
		game.tower_types.append(support)
		game.available_towers.append(support)
		print("Apoyo mecánico incluido en las 60 torres")
	var built: int = 0
	for cell: Vector2i in game.level.ground.get_used_cells():
		if built >= TOWER_COUNT:
			break
		if game.build_controller.try_build(game.available_towers[built % game.available_towers.size()], cell):
			built += 1
	if built != TOWER_COUNT:
		push_error("Carga de rendimiento incompleta: %d de %d torres" % [built, TOWER_COUNT])
		quit(1)
		return
	var path: Path2D = game.level.get_ground_path(0)
	var length: float = path.curve.get_baked_length()
	for i: int in ENEMY_COUNT:
		_spawn_enemy(length * i / ENEMY_COUNT)


## M65: con "mejoras", mejora una torre cada 0,4 s (10 en total) apenas termina el calentamiento.
func _upgrade_in_a_row(delta: float) -> void:
	if not "mejoras" in OS.get_cmdline_user_args() or time < WARMUP_SECONDS or upgrades_done >= UPGRADE_COUNT:
		return
	if upgrades_done == 0 and upgrade_timer == 0.0 and "sin_fx" in OS.get_cmdline_user_args():
		root.get_node("/root/SaveManager").call("set_setting", "upgrade_fx", false)
		print("Animaciones de mejora: apagadas")
	upgrade_timer += delta
	if upgrade_timer < UPGRADE_EVERY_SECONDS and upgrades_done > 0:
		return
	upgrade_timer = 0.001
	var tower: Node = game.tower_container.get_child(upgrades_done % game.tower_container.get_child_count())
	if game.build_controller.try_upgrade(tower):
		upgrades_done += 1


func _spawn_enemy(distance: float) -> void:
	var enemy: Node2D = (load(ENEMY_SCENE_PATH) as PackedScene).instantiate()
	enemy.setup(normal, game.level.get_ground_path(0), 1000000)  # no mueren: siempre hay 200
	enemy.distance = distance
	# Como en la partida real: cada golpe muestra su número de daño (RF-132).
	var effects: Node = game.get("effects")
	enemy.hit.connect(func(e: Node2D, damage: int, blocked: bool, _combo: int) -> void:
		effects.call("damage_number", e.global_position, damage, blocked))
	game.enemies.add_child(enemy)


## Los que llegan a la salida se reponen al principio del camino.
func _keep_enemy_count() -> void:
	var active: int = 0
	for node: Node in game.enemies.get_children():
		if node.is_active():
			active += 1
	for i: int in ENEMY_COUNT - active:
		_spawn_enemy(0.0)


func _fake_deaths(delta: float) -> void:
	death_timer += delta * DEATH_EFFECTS_PER_SECOND
	while death_timer >= 1.0:
		death_timer -= 1.0
		var enemy := game.enemies.get_child(randi() % game.enemies.get_child_count()) as Node2D
		game.effects.enemy_died(enemy.global_position, normal.color, 16.0, 5, enemy)
