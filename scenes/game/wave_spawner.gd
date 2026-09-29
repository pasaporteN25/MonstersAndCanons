# Hace salir a los enemigos de una oleada a su tiempo (plan §6.5).
# No da oro ni resta vidas: solo crea enemigos y avisa cuando la oleada termina.
class_name WaveSpawner
extends Node

signal enemy_spawned(enemy: Enemy)
## Ya salieron todos los enemigos de la oleada y no queda ninguno vivo (RF-33).
signal wave_finished

const ENEMY_SCENE: PackedScene = preload("res://scenes/enemies/enemy.tscn")
## RF-166: separación entre las crías que suelta un enemigo al morir, en píxeles de camino.
const DEATH_SPAWN_SPACING_PX: float = 10.0


## Progreso de un grupo dentro de la oleada en curso.
class GroupRun:
	var group: SpawnGroup
	var spawned: int = 0
	var next_time: float = 0.0

	func _init(spawn_group: SpawnGroup) -> void:
		group = spawn_group
		next_time = spawn_group.start_delay

	func is_done() -> bool:
		return spawned >= group.count


var _level: Level
var _container: Node
## % de vida extra por oleada del nivel que se juega (RF-36, D-019).
var _health_scale_percent: int = 0
var _runs: Array[GroupRun] = []
var _wave_number: int = 0
## Reloj propio de la oleada. Se usa delta (no Timers) para que la pausa
## y la velocidad x2 funcionen solas (plan §6.5).
var _clock: float = 0.0
var _alive: int = 0
var _running: bool = false


## `container` es el nodo donde se agregan los enemigos (Game/Enemies).
func setup(level: Level, container: Node, health_scale_percent: int) -> void:
	_level = level
	_container = container
	_health_scale_percent = health_scale_percent


func start_wave(wave: WaveData, wave_number: int) -> void:
	_runs.clear()
	for group: SpawnGroup in wave.groups:
		_runs.append(GroupRun.new(group))
	_wave_number = wave_number
	_clock = 0.0
	_running = true


func is_running() -> bool:
	return _running


## RF-184 (modo de pruebas): no salen más enemigos de esta oleada. Cuando mueran los que
## quedan, la oleada termina como siempre.
func skip_rest_of_wave() -> void:
	for run: GroupRun in _runs:
		run.spawned = run.group.count
	_check_finished()


## RF-184 (modo de pruebas): hace aparecer un enemigo ya, por la entrada 0.
func spawn_now(data: EnemyData) -> void:
	var path: Path2D = _level.get_air_path(0) if data.is_flying else _level.get_ground_path(0)
	_spawn_enemy(data, path, 0.0)


func _process(delta: float) -> void:
	if not _running:
		return
	_clock += delta
	for run: GroupRun in _runs:
		while not run.is_done() and _clock >= run.next_time:
			_spawn(run.group)
			run.spawned += 1
			run.next_time += run.group.interval
	_check_finished()


func _spawn(group: SpawnGroup) -> void:
	var path: Path2D = _level.get_air_path(group.entrance_index) if group.enemy.is_flying \
		else _level.get_ground_path(group.entrance_index)
	_spawn_enemy(group.enemy, path, 0.0)


## Crea un enemigo con la vida de la oleada en curso (RF-36), a `distance` píxeles del
## comienzo de su camino.
func _spawn_enemy(data: EnemyData, path: Path2D, distance: float) -> void:
	var enemy: Enemy = ENEMY_SCENE.instantiate()
	var health: int = Rules.scaled_health_percent(data.max_health, _wave_number, _health_scale_percent)
	enemy.setup(data, path, health)
	enemy.distance = distance
	if data.death_spawn != null and data.death_spawn_count > 0:
		enemy.died.connect(_on_enemy_died_with_spawn)
	# tree_exited se dispara tanto si muere como si llega a la salida.
	enemy.tree_exited.connect(_on_enemy_gone)
	_alive += 1
	_container.add_child(enemy)
	enemy_spawned.emit(enemy)


## RF-166: al morir por daño suelta sus crías, escalonadas hacia atrás en el camino.
## Se suman a los vivos ANTES de que la madre deje el árbol, así la oleada no termina antes.
func _on_enemy_died_with_spawn(enemy: Enemy) -> void:
	for i: int in enemy.data.death_spawn_count:
		var distance: float = maxf(0.0, enemy.distance - i * DEATH_SPAWN_SPACING_PX)
		_spawn_enemy(enemy.data.death_spawn, enemy.path(), distance)


func _on_enemy_gone() -> void:
	# Si la partida entera se está cerrando, no hay nada que contar.
	if not is_inside_tree():
		return
	_alive -= 1
	_check_finished()


func _check_finished() -> void:
	if not _running or _alive > 0:
		return
	for run: GroupRun in _runs:
		if not run.is_done():
			return
	_running = false
	wave_finished.emit()
