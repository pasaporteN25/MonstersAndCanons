# El "director" de la partida (plan §5): carga el nivel y CONECTA las señales
# entre todas las piezas. No calcula daño ni lleva la cuenta del oro:
# eso lo hacen Rules, las torres, los proyectiles y LevelSession.
class_name Game
extends Node2D

## El mapa se dibuja debajo de la barra superior del HUD (plan §2).
const MAP_OFFSET := Vector2(0, 48)
## Sacudida de pantalla al perder vidas (RF-128).
const SHAKE_DURATION: float = 0.25
const SHAKE_STRENGTH_PX: float = 4.0
## RF-105: velocidad rápida.
const FAST_SPEED: float = 2.0
## RF-184 (modo de pruebas): oro que da el panel y velocidad "x4".
const DEV_GOLD: int = 1000
const DEV_FAST_SPEED: float = 4.0

signal pause_changed(paused: bool)
signal speed_changed(speed: float)

@export var level_data: LevelData
@export var balance: BalanceConfig
## Torres disponibles, en el orden de los botones y de las teclas 1, 2, 3…
@export var tower_types: Array[TowerData] = []

var level: Level
## RF-184: el panel de pruebas. null si no es el modo de pruebas.
var dev_panel: DevPanel
var _shake_left: float = 0.0

@onready var tower_container: Node2D = $Towers
@onready var enemies: Node2D = $Enemies
@onready var projectiles: Node2D = $Projectiles
@onready var effects: EffectsLayer = $Effects
@onready var build_controller: BuildController = $BuildController
@onready var spawner: WaveSpawner = $WaveSpawner
@onready var session: LevelSession = $Session
@onready var hud: Hud = $HUD
@onready var end_screen: EndScreen = $EndScreen
@onready var pause_menu: PauseMenu = $PauseMenu


func _ready() -> void:
	# Si se llegó desde el menú, se juega el nivel elegido; si no (F6, tests), el del Inspector.
	var campaign_level: LevelData = GameFlow.current_level()
	if campaign_level != null:
		level_data = campaign_level

	level = level_data.map_scene.instantiate()
	level.position = MAP_OFFSET
	add_child(level)
	move_child(level, 0)  # primero en la lista = se dibuja debajo de todo

	# RF-104: la partida (y la interfaz, que hereda) sigue funcionando en pausa;
	# el "mundo" se congela.
	process_mode = Node.PROCESS_MODE_ALWAYS
	for node: Node in _world_nodes():
		node.process_mode = Node.PROCESS_MODE_PAUSABLE

	spawner.setup(level, enemies, level_data.health_scale_percent(balance))
	spawner.enemy_spawned.connect(_on_enemy_spawned)
	spawner.wave_finished.connect(session.complete_wave)

	build_controller.setup(level, session, balance, tower_types, tower_container)
	build_controller.tower_built.connect(_on_tower_built)
	build_controller.tower_upgraded.connect(_on_tower_upgraded)
	build_controller.tower_sold.connect(_on_tower_sold)
	build_controller.selection_changed.connect(hud.show_selected_tower)
	build_controller.placed_selection_changed.connect(_refresh_tower_panel.unbind(1))

	hud.setup_towers(tower_types)
	hud.setup_waves(level_data.waves)  # RF-133, RF-135: antes de bind()
	hud.tower_button_pressed.connect(build_controller.select)
	hud.start_wave_pressed.connect(start_next_wave)
	hud.bind(session)

	# RF-70: el panel avisa; BuildController cobra, mejora y vende.
	var panel: TowerPanel = hud.tower_panel
	panel.upgrade_pressed.connect(func() -> void: build_controller.try_upgrade(build_controller.selected_placed()))
	panel.sell_pressed.connect(func() -> void: build_controller.sell(build_controller.selected_placed()))
	panel.targeting_pressed.connect(_on_targeting_pressed)
	session.gold_changed.connect(panel.refresh)

	session.countdown_finished.connect(start_next_wave)
	session.state_changed.connect(_on_state_changed)
	end_screen.retry_pressed.connect(restart)
	end_screen.next_pressed.connect(GameFlow.next_level)
	end_screen.levels_pressed.connect(GameFlow.go_to_level_select)

	hud.pause_pressed.connect(toggle_pause)
	hud.speed_pressed.connect(toggle_speed)
	pause_changed.connect(hud.show_paused)
	speed_changed.connect(hud.show_speed)

	# RF-114: menú de pausa.
	pause_menu.resume_pressed.connect(close_pause_menu)
	pause_menu.retry_pressed.connect(restart)
	pause_menu.quit_pressed.connect(GameFlow.go_to_main_menu)

	# RF-116: sonidos de la partida (los disparos, al construir cada torre).
	session.wave_changed.connect(func(wave: int, _total: int) -> void:
		if wave > 0:
			Audio.play(&"wave_start"))
	Audio.add_click_sounds(hud)
	Audio.add_click_sounds(end_screen)

	session.start(level_data, balance)
	if DevMode.enabled:
		_add_dev_panel()


func _process(delta: float) -> void:
	# RF-128: se mueve todo el "mundo"; el HUD está en otra capa y no se sacude.
	if _shake_left <= 0.0:
		return
	_shake_left -= delta
	if _shake_left <= 0.0:
		position = Vector2.ZERO
	else:
		var strength: float = SHAKE_STRENGTH_PX * _shake_left / SHAKE_DURATION
		position = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * strength


## Al salir de la partida (reintentar, cerrar, o un test que la borra) nunca debe
## quedar el juego en pausa ni acelerado (RF-105, plan §6.7).
func _exit_tree() -> void:
	_reset_time()


func _unhandled_input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if dev_panel != null and key != null and key.pressed and not key.echo and key.physical_keycode == KEY_F1:
		dev_panel.toggle()  # RF-184
		get_viewport().set_input_as_handled()
		return
	# BuildController recibe Esc primero (cancelar construcción o selección);
	# si nadie lo usó, llega aquí y abre o cierra el menú de pausa (RF-114).
	if event.is_action_pressed("cancel"):
		if pause_menu.is_open():
			pause_menu.handle_cancel()
		else:
			open_pause_menu()
	elif pause_menu.is_open():
		return  # con el menú abierto, las otras teclas no hacen nada
	elif event.is_action_pressed("start_wave"):
		start_next_wave()
	elif event.is_action_pressed("pause"):
		toggle_pause()
	elif event.is_action_pressed("toggle_speed"):
		toggle_speed()


# --- Menú de pausa (RF-114) ---

func open_pause_menu() -> void:
	if session.is_over():
		return
	build_controller.cancel()
	build_controller.deselect_placed()
	set_paused(true)
	hud.show_paused(true, false)  # el menú ya dice "Pausa"
	pause_menu.open()


func close_pause_menu() -> void:
	pause_menu.close()
	set_paused(false)


# --- Pausa y velocidad (RF-104, RF-105) ---

func is_paused() -> bool:
	return get_tree().paused


func set_paused(paused: bool) -> void:
	if session.is_over() and paused:
		return  # con la partida terminada no hay nada que pausar
	get_tree().paused = paused
	if paused:
		build_controller.cancel()  # en pausa no se construye
	pause_changed.emit(paused)


func toggle_pause() -> void:
	if pause_menu.is_open():
		return  # desde el menú de pausa se sale con "Continuar" o Esc
	set_paused(not is_paused())


func set_speed(speed: float) -> void:
	Engine.time_scale = speed
	speed_changed.emit(speed)


func toggle_speed() -> void:
	set_speed(1.0 if Engine.time_scale > 1.0 else FAST_SPEED)


func _reset_time() -> void:
	Engine.time_scale = 1.0
	if is_inside_tree():
		get_tree().paused = false


## Las partes del mundo que se congelan en pausa y al terminar la partida.
func _world_nodes() -> Array[Node]:
	return [level, tower_container, enemies, projectiles, effects, spawner, session]


## RF-32 y RF-34: la oleada empieza con el botón, con Espacio o al terminar la cuenta atrás.
func start_next_wave() -> void:
	if not session.can_start_wave():
		return
	var wave_number: int = session.begin_wave()
	spawner.start_wave(level_data.waves[wave_number - 1], wave_number)


## RF-92: reinicia el nivel desde cero recargando la escena.
func restart() -> void:
	_reset_time()
	get_tree().reload_current_scene()


# --- Modo de pruebas (RF-184): lo que hace cada botón del panel ---

func _add_dev_panel() -> void:
	dev_panel = DevPanel.new().setup(self)
	hud.add_child(dev_panel)
	var button := Button.new()
	button.text = "Pruebas [F1]"
	button.focus_mode = Control.FOCUS_NONE
	button.position = Vector2(880, 8)
	button.size = Vector2(126, 32)
	button.pressed.connect(dev_panel.toggle)
	hud.get_node("TopBar").add_child(button)


func dev_add_gold() -> void:
	session.earn(DEV_GOLD)


func dev_set_infinite_lives(on: bool) -> void:
	session.infinite_lives = on


## Los enemigos desaparecen sin morir: no dan oro ni puntos ni sueltan crías.
func dev_kill_all() -> void:
	for node: Node in enemies.get_children():
		(node as Enemy).vanish()


## Termina la oleada en curso (o empieza la siguiente y la termina): no salen más enemigos
## y desaparecen los que hay. La oleada se completa como siempre (con su bono de oro).
func dev_skip_wave() -> void:
	if session.is_over():
		return
	if session.state != LevelSession.State.WAVE_RUNNING:
		start_next_wave()
	spawner.skip_rest_of_wave()
	dev_kill_all()


func dev_finish(won: bool) -> void:
	spawner.skip_rest_of_wave()
	dev_kill_all()
	session.finish(won)


func dev_set_fast(on: bool) -> void:
	set_speed(DEV_FAST_SPEED if on else 1.0)


func dev_spawn(data: EnemyData) -> void:
	spawner.spawn_now(data)


func _on_enemy_spawned(enemy: Enemy) -> void:
	enemy.died.connect(_on_enemy_died)
	enemy.reached_exit.connect(_on_enemy_reached_exit)
	enemy.hit.connect(func(e: Enemy, damage: int, blocked: bool) -> void:
		effects.damage_number(e.global_position, damage, blocked))  # RF-132
	enemy.healed.connect(func(e: Enemy, amount: int) -> void:
		effects.heal_number(e.global_position, amount))  # RF-165
	# RF-134: la primera vez en todo el juego que aparece este tipo, se presenta.
	if not SaveManager.has_seen_enemy(enemy.data.id):
		SaveManager.mark_enemy_seen(enemy.data.id)
		hud.show_enemy_intro(enemy.data)
		if GameFlow.current_level() != null:
			SaveManager.save()  # RF-117: solo jugando desde el menú


func _on_enemy_died(enemy: Enemy) -> void:
	session.earn(enemy.data.reward)  # RF-21
	effects.enemy_died(enemy.global_position, enemy.data.color,
		Rules.tiles_to_px(enemy.data.size_tiles), enemy.data.reward)
	Audio.play(&"enemy_death")


func _on_enemy_reached_exit(enemy: Enemy) -> void:
	session.lose_lives(enemy.data.lives_damage)  # RF-11
	_shake_left = SHAKE_DURATION
	Audio.play(&"life_lost")


func _on_tower_built(tower: Tower) -> void:
	tower.fired.connect(_on_tower_fired)
	# Cada torre suena distinto: el sonido se llama "shot_" + el id de la torre.
	var shot_sound := StringName("shot_%s" % tower.data.id)
	tower.fired.connect(func(_projectile: Projectile) -> void: Audio.play(shot_sound))
	effects.tower_built(tower.global_position, tower.data.color)
	Audio.play(&"build")


func _on_tower_upgraded(tower: Tower) -> void:
	effects.tower_built(tower.global_position, tower.data.color)  # RF-75: mismo anillo
	_refresh_tower_panel()
	Audio.play(&"upgrade")


func _on_tower_sold(tower: Tower, refund: int) -> void:
	effects.tower_sold(tower.global_position, refund)
	Audio.play(&"sell")


func _on_targeting_pressed() -> void:
	var tower: Tower = build_controller.selected_placed()
	if tower != null:
		tower.cycle_targeting()
		_refresh_tower_panel()


## Muestra en el panel la torre seleccionada (o lo oculta si no hay ninguna).
func _refresh_tower_panel() -> void:
	var tower: Tower = build_controller.selected_placed()
	var value: int = build_controller.sell_value(tower) if tower != null else 0
	hud.tower_panel.show_tower(tower, value, session.gold)


func _on_tower_fired(projectile: Projectile) -> void:
	projectiles.add_child(projectile)
	projectile.impacted.connect(effects.projectile_impacted)
	projectile.chained.connect(effects.lightning)  # RF-163


func _on_state_changed(state: LevelSession.State) -> void:
	if state != LevelSession.State.WON and state != LevelSession.State.LOST:
		return
	# RF-91: el juego se detiene. Se congela el "mundo", pero no la interfaz.
	for node: Node in [enemies, tower_container, projectiles, spawner]:
		node.process_mode = Node.PROCESS_MODE_DISABLED
	build_controller.cancel()
	build_controller.deselect_placed()
	set_speed(1.0)
	var in_campaign: bool = GameFlow.current_level() != null
	if state == LevelSession.State.WON:
		GameFlow.level_won(session.lives)  # RF-112 y RF-115: desbloquea y guarda
		var stars: int = Rules.stars_for(session.lives, level_data.starting_lives, balance)  # RF-93
		end_screen.show_victory(session.lives, stars, GameFlow.has_next_level(), in_campaign)
		Audio.play(&"victory")
	else:
		end_screen.show_defeat(session.wave, session.total_waves, in_campaign)
		Audio.play(&"defeat")
