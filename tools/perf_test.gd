# Prueba de rendimiento (T56, constitución P7): 200 enemigos, 60 torres y efectos visuales.
# NO es un test automático: abre una ventana (hace falta dibujar de verdad) y mide los FPS.
#
# Uso (desde la carpeta del proyecto):
#   godot --path . -s tools/perf_test.gd
#
# Desactiva el vsync para medir cuántos FPS puede dar el juego, no los del monitor.
extends SceneTree

const ENEMY_SCENE: PackedScene = preload("res://scenes/enemies/enemy.tscn")
const ENEMY_COUNT: int = 200
const TOWER_COUNT: int = 60
## Muertes "de mentira" por segundo, para que siempre haya estallidos en pantalla.
const DEATH_EFFECTS_PER_SECOND: float = 15.0
const WARMUP_SECONDS: float = 1.0
const MEASURE_SECONDS: float = 6.0

var game: Game
var time: float = 0.0
var frames_measured: int = 0
var death_timer: float = 0.0
var worst_frame_ms: float = 0.0
var normal: EnemyData = load("res://data/enemies/normal.tres")


func _initialize() -> void:
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	game = (load("res://scenes/game/game.tscn") as PackedScene).instantiate()
	root.add_child(game)


func _process(delta: float) -> bool:
	if game.enemies.get_child_count() == 0 and time == 0.0:
		_populate()
	_keep_enemy_count()
	_fake_deaths(delta)
	time += delta
	if time > WARMUP_SECONDS:
		frames_measured += 1
		worst_frame_ms = maxf(worst_frame_ms, delta * 1000.0)
	if time > WARMUP_SECONDS + MEASURE_SECONDS:
		var fps: float = frames_measured / MEASURE_SECONDS
		print("Enemigos: %d · Torres: %d · Efectos: %d" % [
			game.enemies.get_child_count(), game.tower_container.get_child_count(),
			game.effects.get_child_count()])
		print("FPS promedio: %.0f · frame más lento: %.1f ms" % [fps, worst_frame_ms])
		print("RESULTADO: %s (objetivo: 60 FPS)" % ("OK" if fps >= 60.0 else "LENTO"))
		return true
	return false


func _populate() -> void:
	game.session.earn(100000)
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
	var enemy: Enemy = ENEMY_SCENE.instantiate()
	enemy.setup(normal, game.level.get_ground_path(0), 1000000)  # no mueren: siempre hay 200
	enemy.distance = distance
	game.enemies.add_child(enemy)


## Los que llegan a la salida se reponen al principio del camino.
func _keep_enemy_count() -> void:
	var active: int = 0
	for node: Node in game.enemies.get_children():
		if (node as Enemy).is_active():
			active += 1
	for i: int in ENEMY_COUNT - active:
		_spawn_enemy(0.0)


func _fake_deaths(delta: float) -> void:
	death_timer += delta * DEATH_EFFECTS_PER_SECOND
	while death_timer >= 1.0:
		death_timer -= 1.0
		var enemy := game.enemies.get_child(randi() % game.enemies.get_child_count()) as Enemy
		game.effects.enemy_died(enemy.global_position, normal.color, 16.0, 5)
