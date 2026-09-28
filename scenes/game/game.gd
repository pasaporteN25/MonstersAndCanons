# El "director" de la partida (plan §5): carga el nivel, crea los enemigos
# en su contenedor y CONECTA las señales entre todas las piezas.
# No calcula daño ni lleva la cuenta del oro: eso lo hacen Rules y LevelSession.
class_name Game
extends Node2D

## El mapa se dibuja debajo de la barra superior del HUD (plan §2).
const MAP_OFFSET := Vector2(0, 48)

@export var level_data: LevelData
@export var balance: BalanceConfig

var level: Level

@onready var enemies: Node2D = $Enemies
@onready var spawner: WaveSpawner = $WaveSpawner
@onready var session: LevelSession = $Session
@onready var hud: Hud = $HUD


func _ready() -> void:
	level = level_data.map_scene.instantiate()
	level.position = MAP_OFFSET
	add_child(level)
	move_child(level, 0)  # primero en la lista = se dibuja debajo de todo

	spawner.setup(level, enemies, balance)
	spawner.enemy_spawned.connect(_on_enemy_spawned)
	spawner.wave_finished.connect(session.complete_wave)
	session.countdown_finished.connect(start_next_wave)
	hud.start_wave_pressed.connect(start_next_wave)
	hud.bind(session)

	session.start(level_data, balance)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("start_wave"):
		start_next_wave()


## RF-32 y RF-34: la oleada empieza con el botón, con Espacio o al terminar la cuenta atrás.
func start_next_wave() -> void:
	if not session.can_start_wave():
		return
	var wave_number: int = session.begin_wave()
	spawner.start_wave(level_data.waves[wave_number - 1], wave_number)


func _on_enemy_spawned(enemy: Enemy) -> void:
	enemy.reached_exit.connect(_on_enemy_reached_exit)


func _on_enemy_reached_exit(enemy: Enemy) -> void:
	session.lose_lives(enemy.data.lives_damage)
