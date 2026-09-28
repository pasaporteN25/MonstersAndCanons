# Hace salir a los enemigos de una oleada a su tiempo (plan §6.5).
# No da oro ni resta vidas: solo crea enemigos y avisa cuando la oleada termina.
class_name WaveSpawner
extends Node

signal enemy_spawned(enemy: Enemy)
## Ya salieron todos los enemigos de la oleada y no queda ninguno vivo (RF-33).
signal wave_finished

const ENEMY_SCENE: PackedScene = preload("res://scenes/enemies/enemy.tscn")


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
var _balance: BalanceConfig
var _runs: Array[GroupRun] = []
var _wave_number: int = 0
## Reloj propio de la oleada. Se usa delta (no Timers) para que la pausa
## y la velocidad x2 funcionen solas (plan §6.5).
var _clock: float = 0.0
var _alive: int = 0
var _running: bool = false


## `container` es el nodo donde se agregan los enemigos (Game/Enemies).
func setup(level: Level, container: Node, balance: BalanceConfig) -> void:
	_level = level
	_container = container
	_balance = balance


func start_wave(wave: WaveData, wave_number: int) -> void:
	_runs.clear()
	for group: SpawnGroup in wave.groups:
		_runs.append(GroupRun.new(group))
	_wave_number = wave_number
	_clock = 0.0
	_running = true


func is_running() -> bool:
	return _running


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
	var enemy: Enemy = ENEMY_SCENE.instantiate()
	var health: int = Rules.scaled_health(group.enemy.max_health, _wave_number, _balance)
	enemy.setup(group.enemy, _level.get_ground_path(group.entrance_index), health)
	# tree_exited se dispara tanto si muere como si llega a la salida.
	enemy.tree_exited.connect(_on_enemy_gone)
	_alive += 1
	_container.add_child(enemy)
	enemy_spawned.emit(enemy)


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
