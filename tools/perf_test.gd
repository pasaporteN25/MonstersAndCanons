# Prueba de rendimiento (T56, constitución P7): 200 enemigos, 60 torres y efectos visuales.
# NO es un test automático: abre una ventana (hace falta dibujar de verdad) y mide los FPS.
#
# Uso (desde la carpeta del proyecto):
#   godot --path . -s tools/perf_test.gd
#   godot --path . -s tools/perf_test.gd -- sin_numeros    (compara sin números de daño)
#   godot --path . -s tools/perf_test.gd -- entrada_jefe   (M66: nivel 1 «desde el menú» y un Jefe al empezar la medición;
#                                                         se ven el destello y el cartel durante 1,6 s. Se puede sumar `celular`)
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

# Node2D y no Game: este script se compila antes que los autoloads, y game.gd los usa.
var game: Node2D
var time: float = 0.0
var frames_measured: int = 0
var death_timer: float = 0.0
var worst_frame_ms: float = 0.0
## Frames que tardaron más de 16,6 ms (los que a 60 FPS se notarían como un tirón).
var slow_frames: int = 0
var normal: EnemyData = load("res://data/enemies/normal.tres")
## M66: con `entrada_jefe`, a qué segundo nace el Jefe y si ya nació; y la suma de los tiempos de cuadro medidos.
const BOSS_ENTRANCE_AT: float = 1.5
var boss_entrance_fired: bool = false
var frame_ms_total: float = 0.0


func _initialize() -> void:
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0


## Los autoloads todavía no existen en `_initialize` (este script se compila antes): la partida se crea en el primer cuadro.
func _create_game() -> void:
	if "entrada_jefe" in OS.get_cmdline_user_args():
		root.get_node("/root/GameFlow").set("current_index", 0)  # campaña desde el menú: así sale la entrada
		root.get_node("/root/SaveManager").call("set_setting", "tutorial_enabled", false)
	if "celular" in OS.get_cmdline_user_args():
		root.get_node("/root/SaveManager").call("set_setting", "ui_mode", 1)
	game = (load("res://scenes/game/game.tscn") as PackedScene).instantiate()
	root.add_child(game)


func _process(delta: float) -> bool:
	if game == null:
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
	time += delta
	if "entrada_jefe" in OS.get_cmdline_user_args() and not boss_entrance_fired and time > BOSS_ENTRANCE_AT:
		boss_entrance_fired = true
		game.spawner.spawn_now(load("res://data/enemies/boss.tres"))
	if time > WARMUP_SECONDS:
		frames_measured += 1
		frame_ms_total += delta * 1000.0
		worst_frame_ms = maxf(worst_frame_ms, delta * 1000.0)
		if delta * 1000.0 > 1000.0 / 60.0:
			slow_frames += 1
	if time > WARMUP_SECONDS + MEASURE_SECONDS:
		var fps: float = frames_measured / MEASURE_SECONDS
		print("Enemigos: %d · Torres: %d · Efectos: %d" % [
			game.enemies.get_child_count(), game.tower_container.get_child_count(),
			game.effects.get_child_count()])
		print("FPS promedio: %.0f · frame más lento: %.1f ms · frames de más de 16,6 ms: %d de %d" % [
			fps, worst_frame_ms, slow_frames, frames_measured])
		print("Tiempo de cuadro promedio: %.2f ms" % (frame_ms_total / maxf(1.0, float(frames_measured))))
		print("RESULTADO: %s (objetivo: 60 FPS)" % ("OK" if fps >= 60.0 else "LENTO"))
		return true
	return false


func _populate() -> void:
	game.session.earn(100000)
	if "apoyo" in OS.get_cmdline_user_args():
		var support: TowerData = load("res://data/towers/mechanical_standard.tres")
		game.tower_types.append(support)
		game.available_towers.append(support)
		print("Apoyo mecánico incluido en las 60 torres")
	var built: int = 0
	for cell: Vector2i in game.level.ground.get_used_cells():
		if built >= TOWER_COUNT:
			break
		if game.build_controller.try_build(game.tower_types[built % game.tower_types.size()], cell):
			built += 1
	var path: Path2D = game.level.get_ground_path(0)
	var length: float = path.curve.get_baked_length()
	for i: int in ENEMY_COUNT:
		_spawn_enemy(length * i / ENEMY_COUNT)


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
