# Flujo entre pantallas y campaña (plan §7). Es un autoload: se usa como `GameFlow`.
# Recuerda qué nivel se está jugando y cambia de pantalla.
extends Node

const CAMPAIGN: CampaignData = preload("res://data/campaign.tres")
const MAIN_MENU_SCENE: String = "res://scenes/ui/main_menu.tscn"
const LEVEL_SELECT_SCENE: String = "res://scenes/ui/level_select.tscn"
const GAME_SCENE: String = "res://scenes/game/game.tscn"

## Índice del nivel de la campaña que se está jugando.
## -1 = no se juega desde la campaña (por ejemplo, game.tscn abierto con F6, o un test):
## en ese caso NO se guarda nada.
var current_index: int = -1


func level_count() -> int:
	return CAMPAIGN.levels.size()


func level(index: int) -> LevelData:
	return CAMPAIGN.levels[index]


## RF-112: el primer nivel siempre está desbloqueado; el resto, según el guardado.
func is_level_unlocked(index: int) -> bool:
	return index == 0 or SaveManager.is_unlocked(level(index).id)


func current_level() -> LevelData:
	return null if current_index < 0 else level(current_index)


func has_next_level() -> bool:
	return current_index >= 0 and current_index + 1 < level_count()


## RF-90 y RF-112: guarda la victoria y desbloquea el siguiente nivel.
func level_won(lives: int) -> void:
	if current_index < 0:
		return
	SaveManager.record_victory(level(current_index).id, lives)
	if has_next_level():
		SaveManager.unlock(level(current_index + 1).id)
	SaveManager.save()


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
