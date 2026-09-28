# El "director" de la partida (plan §5): carga el nivel y CONECTA las señales
# entre todas las piezas. No calcula daño ni lleva la cuenta del oro:
# eso lo hacen Rules, las torres, los proyectiles y LevelSession.
class_name Game
extends Node2D

## El mapa se dibuja debajo de la barra superior del HUD (plan §2).
const MAP_OFFSET := Vector2(0, 48)

@export var level_data: LevelData
@export var balance: BalanceConfig
## Torres disponibles, en el orden de los botones y de las teclas 1, 2, 3…
@export var tower_types: Array[TowerData] = []

var level: Level

@onready var tower_container: Node2D = $Towers
@onready var enemies: Node2D = $Enemies
@onready var projectiles: Node2D = $Projectiles
@onready var build_controller: BuildController = $BuildController
@onready var spawner: WaveSpawner = $WaveSpawner
@onready var session: LevelSession = $Session
@onready var hud: Hud = $HUD
@onready var end_screen: EndScreen = $EndScreen


func _ready() -> void:
	level = level_data.map_scene.instantiate()
	level.position = MAP_OFFSET
	add_child(level)
	move_child(level, 0)  # primero en la lista = se dibuja debajo de todo

	spawner.setup(level, enemies, balance)
	spawner.enemy_spawned.connect(_on_enemy_spawned)
	spawner.wave_finished.connect(session.complete_wave)

	build_controller.setup(level, session, tower_types, tower_container)
	build_controller.tower_built.connect(_on_tower_built)
	build_controller.selection_changed.connect(hud.show_selected_tower)

	hud.setup_towers(tower_types)
	hud.tower_button_pressed.connect(build_controller.select)
	hud.start_wave_pressed.connect(start_next_wave)
	hud.bind(session)

	session.countdown_finished.connect(start_next_wave)
	session.state_changed.connect(_on_state_changed)
	end_screen.retry_pressed.connect(restart)

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


## RF-92: reinicia el nivel desde cero recargando la escena.
func restart() -> void:
	get_tree().reload_current_scene()


func _on_enemy_spawned(enemy: Enemy) -> void:
	enemy.died.connect(_on_enemy_died)
	enemy.reached_exit.connect(_on_enemy_reached_exit)


func _on_enemy_died(enemy: Enemy) -> void:
	session.earn(enemy.data.reward)  # RF-21


func _on_enemy_reached_exit(enemy: Enemy) -> void:
	session.lose_lives(enemy.data.lives_damage)  # RF-11


func _on_tower_built(tower: Tower) -> void:
	tower.fired.connect(_on_tower_fired)


func _on_tower_fired(projectile: Projectile) -> void:
	projectiles.add_child(projectile)


func _on_state_changed(state: LevelSession.State) -> void:
	if state != LevelSession.State.WON and state != LevelSession.State.LOST:
		return
	# RF-91: el juego se detiene. Se congela el "mundo", pero no la interfaz.
	for node: Node in [enemies, tower_container, projectiles, spawner]:
		node.process_mode = Node.PROCESS_MODE_DISABLED
	build_controller.cancel()
	if state == LevelSession.State.WON:
		end_screen.show_victory(session.lives)
	else:
		end_screen.show_defeat(session.wave, session.total_waves)
