# Flujo entre pantallas y campaña (plan §7). Es un autoload: se usa como `GameFlow`.
# Recuerda qué nivel se está jugando y cambia de pantalla.
extends Node

const CAMPAIGN: CampaignData = preload("res://data/campaign.tres")
const BALANCE: BalanceConfig = preload("res://data/balance.tres")
const MAIN_MENU_SCENE: String = "res://scenes/ui/main_menu.tscn"
const LEVEL_SELECT_SCENE: String = "res://scenes/ui/level_select.tscn"
const GAME_SCENE: String = "res://scenes/game/game.tscn"
const RECORDS_SCENE: String = "res://scenes/ui/records_screen.tscn"

## Índice del nivel de la campaña que se está jugando.
## -1 = no se juega desde la campaña (por ejemplo, game.tscn abierto con F6, o un test):
## en ese caso NO se guarda nada.
var current_index: int = -1


func _ready() -> void:
	apply_display_settings()


## RF-142: el botón "atrás" de Android hace lo mismo que Esc.
## En vez de repetir en cada pantalla qué hacer, se simula la acción "cancel":
## así funciona todo lo que ya responde a Esc. (Para que Android no cierre el juego
## de golpe, project.godot tiene application/config/quit_on_go_back = false.)
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		for pressed: bool in [true, false]:
			var event := InputEventAction.new()
			event.action = &"cancel"
			event.pressed = pressed
			Input.parse_input_event(event)


## RF-113: pantalla completa o ventana, según las opciones guardadas.
## Solo cambia algo si hace falta (así no "des-maximiza" la ventana al arrancar).
func apply_display_settings() -> void:
	var want_fullscreen: bool = bool(SaveManager.get_setting("fullscreen"))
	var mode: DisplayServer.WindowMode = DisplayServer.window_get_mode()
	var is_fullscreen: bool = mode == DisplayServer.WINDOW_MODE_FULLSCREEN \
		or mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
	if want_fullscreen != is_fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if want_fullscreen \
			else DisplayServer.WINDOW_MODE_WINDOWED)


func level_count() -> int:
	return CAMPAIGN.levels.size()


func level(index: int) -> LevelData:
	return CAMPAIGN.levels[index]


## RF-112: el primer nivel siempre está desbloqueado; el resto, según el guardado.
## RF-183: en el modo de pruebas, todos.
func is_level_unlocked(index: int) -> bool:
	return index == 0 or DevMode.enabled or SaveManager.is_unlocked(level(index).id)


## RF-93: estrellas conseguidas en un nivel (0 si nunca se ganó).
## No se guardan aparte: salen de la mejor cantidad de vidas, que sí se guarda.
func level_stars(index: int) -> int:
	var lvl: LevelData = level(index)
	if not SaveManager.is_completed(lvl.id):
		return 0
	return Rules.stars_for(SaveManager.best_lives(lvl.id), lvl.starting_lives, BALANCE)


func total_stars() -> int:
	var total: int = 0
	for i: int in level_count():
		total += level_stars(i)
	return total


func max_stars() -> int:
	return level_count() * StarsDisplay.MAX_STARS


func current_level() -> LevelData:
	return null if current_index < 0 else level(current_index)


func has_next_level() -> bool:
	return current_index >= 0 and current_index + 1 < level_count()


## RF-90 y RF-112: guarda la victoria y desbloquea el siguiente nivel.
func level_won(lives: int, score: int = 0) -> void:
	if current_index < 0:
		return
	SaveManager.record_victory(level(current_index).id, lives, score)
	if has_next_level():
		SaveManager.unlock(level(current_index + 1).id)
	SaveManager.save()


# --- Récords de cada nivel (RF-191, RF-196) ---

## ¿Estos puntos entran en el top 5 del nivel que se está jugando? Fuera de la campaña, no.
func level_score_qualifies(points: int) -> bool:
	return current_index >= 0 and HighScores.qualifies(SaveManager.scores(current_level().id), points)


## Anota el récord del nivel que se está jugando y guarda. Devuelve la posición (0 = primero)
## o -1 si no entró o no se juega desde la campaña.
func record_level_score(name: String, points: int) -> int:
	if current_index < 0:
		return -1
	var index: int = SaveManager.add_score(current_level().id, name, points)
	SaveManager.set_last_initials(name)
	SaveManager.save()
	return index


func current_level_scores() -> Array:
	return [] if current_index < 0 else SaveManager.scores(current_level().id)


# --- Salón de la fama (RF-194) ---

## ¿Se ganaron todos los niveles de la campaña?
func campaign_complete() -> bool:
	for i: int in level_count():
		if not SaveManager.is_completed(level(i).id):
			return false
	return true


## Suma del mejor puntaje en victoria de cada nivel.
func campaign_total() -> int:
	var total: int = 0
	for i: int in level_count():
		total += SaveManager.best_score(level(i).id)
	return total


## ¿Hay que pedir 5 letras para el Salón? Solo en la campaña, con todos los niveles ganados,
## si el total SUBIÓ desde la última vez y entra en el top 5.
func hall_of_fame_pending() -> bool:
	if current_index < 0 or not campaign_complete():
		return false
	var total: int = campaign_total()
	return total > SaveManager.hall_total() and HighScores.qualifies(hall_of_fame(), total)


## Anota el total de la campaña en el Salón y guarda. Devuelve la posición (0 = primero).
func record_hall_of_fame(name: String) -> int:
	var total: int = campaign_total()
	var index: int = SaveManager.add_score(SaveManager.HALL_OF_FAME_ID, name, total)
	SaveManager.set_hall_total(total)
	SaveManager.set_last_initials(name)
	SaveManager.save()
	return index


func hall_of_fame() -> Array:
	return SaveManager.scores(SaveManager.HALL_OF_FAME_ID)


# --- Cambiar de pantalla ---

func start_level(index: int) -> void:
	if not is_level_unlocked(index):
		return
	current_index = index
	get_tree().change_scene_to_file(GAME_SCENE)


func next_level() -> void:
	if has_next_level():
		start_level(current_index + 1)


func go_to_main_menu() -> void:
	current_index = -1
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)


func go_to_level_select() -> void:
	current_index = -1
	get_tree().change_scene_to_file(LEVEL_SELECT_SCENE)


## RF-195: la pantalla de récords.
func go_to_records() -> void:
	current_index = -1
	get_tree().change_scene_to_file(RECORDS_SCENE)
