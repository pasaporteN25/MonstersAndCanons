# Estado de UNA partida: oro, vidas, oleada actual y fase (plan §5.2 y §5.4).
# No dibuja nada ni crea nodos: guarda números y avisa con señales cuando cambian.
class_name LevelSession
extends Node

## Fases de la partida (plan §5.4).
enum State { BUILDING, WAVE_RUNNING, COUNTDOWN, WON, LOST }

signal gold_changed(gold: int)
signal lives_changed(lives: int)
signal wave_changed(wave: int, total_waves: int)
signal wave_completed(wave: int, bonus: int)
signal state_changed(state: State)
signal countdown_changed(seconds_left: float)
## La cuenta atrás entre oleadas llegó a 0 (RF-34).
signal countdown_finished

var gold: int = 0
var lives: int = 0
## Número de la oleada actual. 0 = todavía no empezó ninguna.
var wave: int = 0
var total_waves: int = 0
var state: State = State.BUILDING
var countdown_left: float = 0.0

var _balance: BalanceConfig


func start(level: LevelData, balance: BalanceConfig) -> void:
	_balance = balance
	gold = level.starting_gold
	lives = level.starting_lives
	wave = 0
	total_waves = level.waves.size()
	countdown_left = 0.0
	state = State.BUILDING
	gold_changed.emit(gold)
	lives_changed.emit(lives)
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


func can_afford(cost: int) -> bool:
	return gold >= cost


## Descuenta `cost` si alcanza. Devuelve false (y no cambia nada) si no alcanza.
func spend(cost: int) -> bool:
	if not can_afford(cost):
		return false
	gold -= cost
	gold_changed.emit(gold)
	return true


# --- Vidas (RF-10 a RF-12) ---

func lose_lives(amount: int) -> void:
	if is_over():
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


func is_over() -> bool:
	return state == State.WON or state == State.LOST


func _set_state(new_state: State) -> void:
	state = new_state
	state_changed.emit(state)
