# Estado de UNA partida: oro, vidas, oleada actual y fase (plan §5.2 y §5.4).
# No dibuja nada ni crea nodos: guarda números y avisa con señales cuando cambian.
class_name LevelSession
extends Node

## Fases de la partida (plan §5.4).
enum State { BUILDING, WAVE_RUNNING, COUNTDOWN, WON, LOST }

signal gold_changed(gold: int)
signal gold_stolen(amount: int)
## RF-415: cambiaron los recursos de la partida.
signal resources_changed(resources: int)
signal lives_changed(lives: int)
## RF-190: cambiaron los puntos.
signal score_changed(score: int)
signal wave_changed(wave: int, total_waves: int)
signal wave_completed(wave: int, bonus: int)
signal state_changed(state: State)
signal countdown_changed(seconds_left: float)
## La cuenta atrás entre oleadas llegó a 0 (RF-34).
signal countdown_finished

var gold: int = 0
var lives: int = 0
## RF-415: recursos de esta partida (un solo tipo). Empiezan en 0, no se guardan y no dan puntos.
var resources: int = 0
## RF-190: puntos de esta partida.
var score: int = 0
## Número de la oleada actual. 0 = todavía no empezó ninguna.
var wave: int = 0
var total_waves: int = 0
var state: State = State.BUILDING
var countdown_left: float = 0.0
## RF-184 (modo de pruebas): si es true, los enemigos que llegan no quitan vidas.
var infinite_lives: bool = false

var _balance: BalanceConfig


func start(level: LevelData, balance: BalanceConfig) -> void:
	_balance = balance
	gold = level.starting_gold
	resources = 0
	lives = level.starting_lives
	score = 0
	wave = 0
	total_waves = level.waves.size()
	countdown_left = 0.0
	state = State.BUILDING
	gold_changed.emit(gold)
	resources_changed.emit(resources)
	lives_changed.emit(lives)
	score_changed.emit(score)
	wave_changed.emit(wave, total_waves)
	state_changed.emit(state)


func _process(delta: float) -> void:
	if state != State.COUNTDOWN:
		return
	countdown_left = maxf(0.0, countdown_left - delta)
	countdown_changed.emit(countdown_left)
	if countdown_left == 0.0:
		countdown_finished.emit()


# --- Oro (RF-20 a RF-24) ---

func earn(amount: int) -> void:
	gold += amount
	gold_changed.emit(gold)


## RF-320 (modo de pruebas): fija el oro de arranque (puede ser 0).
func set_gold(amount: int) -> void:
	gold = maxi(amount, 0)
	gold_changed.emit(gold)


func can_afford(cost: int) -> bool:
	return gold >= cost


## Descuenta `cost` si alcanza. Devuelve false (y no cambia nada) si no alcanza.
func spend(cost: int) -> bool:
	if not can_afford(cost):
		return false
	gold -= cost
	gold_changed.emit(gold)
	return true


# --- Recursos (RF-415 y RF-418) ---

func add_resources(amount: int) -> void:
	if amount <= 0:
		return
	resources += amount
	resources_changed.emit(resources)


func can_afford_both(gold_cost: int, resource_cost: int) -> bool:
	return gold >= gold_cost and resources >= resource_cost


## RF-418: cobra oro y recursos a la vez, o no cobra nada. Devuelve false (sin cambiar nada) si falta alguno.
func spend_both(gold_cost: int, resource_cost: int) -> bool:
	if not can_afford_both(gold_cost, resource_cost):
		return false
	gold -= gold_cost
	resources -= resource_cost
	gold_changed.emit(gold)
	if resource_cost > 0:
		resources_changed.emit(resources)
	return true


# --- Puntos (RF-190) ---

func add_score(amount: int) -> void:
	if amount <= 0:
		return
	score += amount
	score_changed.emit(score)


# --- Vidas (RF-10 a RF-12) ---

func lose_lives(amount: int) -> void:
	if is_over() or infinite_lives:
		return
	lives = maxi(0, lives - amount)
	lives_changed.emit(lives)
	if lives == 0:
		_set_state(State.LOST)


# --- Oleadas (RF-30 a RF-35) ---

## RF-35: solo se puede llamar a una oleada si no hay otra en curso.
func can_start_wave() -> bool:
	return (state == State.BUILDING or state == State.COUNTDOWN) and wave < total_waves


## Pasa a la siguiente oleada y devuelve su número (empezando en 1).
func begin_wave() -> int:
	assert(can_start_wave(), "begin_wave() llamado cuando no se puede empezar una oleada")
	wave += 1
	wave_changed.emit(wave, total_waves)
	_set_state(State.WAVE_RUNNING)
	return wave


## RF-33: la oleada terminó. Da el bono (RF-22) y pasa a la cuenta atrás o a la victoria.
func complete_wave() -> void:
	if state != State.WAVE_RUNNING:
		return
	var bonus: int = Rules.wave_bonus(wave, _balance)
	earn(bonus)
	wave_completed.emit(wave, bonus)
	if wave >= total_waves:
		_set_state(State.WON)
	else:
		countdown_left = _balance.countdown_seconds
		_set_state(State.COUNTDOWN)
		countdown_changed.emit(countdown_left)


## RF-184 (modo de pruebas): termina la partida ya, ganada o perdida.
func finish(won: bool) -> void:
	if not is_over():
		_set_state(State.WON if won else State.LOST)


func is_over() -> bool:
	return state == State.WON or state == State.LOST


func _set_state(new_state: State) -> void:
	if new_state == State.WON:
		add_score(Rules.victory_points(lives, _balance))  # RF-190: antes de avisar la victoria
	state = new_state
	state_changed.emit(state)


## RF-319 (modo de pruebas): la partida arranca lista para empezar la oleada `target`, como si las
## anteriores ya se hubieran jugado. Solo antes de empezar la primera. Con un `target` fuera de rango
## se usa la última oleada del nivel. No da oro ni bonos: el oro lo decide `DevStart.start_gold`.
func jump_to_wave(target: int) -> void:
	if state != State.BUILDING or wave != 0 or total_waves == 0:
		return
	wave = DevStart.clamp_wave(target, total_waves) - 1
	wave_changed.emit(wave, total_waves)

## RF-363: descuento limitado sin crear oro por debajo del piso.
func steal(amount: int, floor_gold: int) -> int:
	if is_over() or amount <= 0:
		return 0
	var taken: int = mini(amount, maxi(0, gold - maxi(0, floor_gold)))
	if taken > 0:
		gold -= taken
		gold_changed.emit(gold)
		gold_stolen.emit(taken)
	return taken

