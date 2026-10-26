# Flujo entre pantallas y campaña (plan §7). Es un autoload: se usa como `GameFlow`.
# Recuerda qué nivel se está jugando y cambia de pantalla.
extends Node

const BALANCE: BalanceConfig = preload("res://data/balance.tres")
const MAIN_MENU_SCENE: String = "res://scenes/ui/main_menu.tscn"
const LEVEL_SELECT_SCENE: String = "res://scenes/ui/level_select.tscn"
const GAME_SCENE: String = "res://scenes/game/game.tscn"
const RECORDS_SCENE: String = "res://scenes/ui/records_screen.tscn"
const WIKI_SCENE: String = "res://scenes/ui/wiki_screen.tscn"
const EDITOR_SCENE: String = "res://scenes/editor/map_editor.tscn"
const TOOLS_SCENE: String = "res://scenes/ui/tools_hub.tscn"
const BANNER_EDITOR_SCENE: String = "res://scenes/editor/banner_editor.tscn"
## RF-581 (M64): la pantalla de carga. Son valores de interfaz: el fondo es el de los menús y el dorado, el de los títulos.
const LOADING_THEME: Theme = preload("res://assets/ui/menu_theme.tres")
const LOADING_MIN_SECONDS: float = 0.4
const LOADING_BACKGROUND := Color(0.07, 0.08, 0.1, 1.0)
const LOADING_ACCENT := Color(1.0, 0.84, 0.3, 1.0)

## Índice del nivel de la campaña que se está jugando.
## -1 = no se juega desde la campaña (por ejemplo, game.tscn abierto con F6, o un test):
## en ese caso NO se guarda nada.
var current_index: int = -1
## RF-205: los niveles de data/campaign.json, ya leídos (los inválidos se saltean, RF-204).
var campaign: CampaignData = LevelFile.load_campaign()
## El borrador del editor de mapas (spec §10.3). Vive acá para no perderse cuando se prueba el
## nivel: la partida reemplaza la pantalla del editor, y al volver se retoma este mismo borrador.
var editor_draft: LevelDraft
## RF-217: el nivel que se está probando desde el editor. null = se juega un nivel de la campaña.
## Mientras hay uno, la partida no guarda progreso, estrellas ni récords, y al terminar vuelve
## al editor.
var test_level: LevelData
## RF-417: semilla fija del sorteo de los removibles (el bot y los tests). -1 = una nueva en cada partida.
var forced_seed: int = -1
## RF-224: el mapa de la comunidad que se está jugando (null = ninguno). Tiene su progreso y sus
## récords propios, con el id `comunidad_<archivo>`, y no toca la campaña.
var current_community: LevelData
## RF-225: qué solapa de la selección de nivel se ve: &"campaign", &"community" o la de un modo
## (&"mode:<id>", RF-389). Se recuerda para que "Niveles" vuelva a la misma solapa al terminar.
var select_page: StringName = &"campaign"
## RF-694: el mapa de un modo que se jugó por última vez, para que «Niveles» vuelva a la misma selección.
## -1 = ninguno; se borra al cambiar de solapa.
var select_map_index: int = -1
## RF-389: el modo que se está jugando (una entrada de ModePacks.all()) y el índice del mapa en su lista.
## Vacío / -1 = no se juega un modo.
var current_mode: Dictionary = {}
var current_mode_index: int = -1
## M52 (RF-466): la próxima partida que se abre viene de elegir un nivel (o «Siguiente nivel»), así que puede
## mostrar el cartel de entrada. `Game._ready` lo consume y lo apaga; no se guarda. «Reintentar» recarga la
## escena sin pasar por acá, por eso el cartel no vuelve (y probar desde el editor nunca lo enciende).
var intro_pending: bool = false
## M64 (RF-580): el cambio de escena con pantalla de carga y la entrada bloqueada. Lo crea `_ready`.
var transition: SceneTransition
## T476: anfitrión persistente de presentación; es null al abrir escenas directamente (F6/tests/tools).
var presentation_host: Node


func _ready() -> void:
	_make_transition()
	DesktopWindow.apply()
	apply_display_settings()


## RF-142: el botón "atrás" de Android hace lo mismo que Esc.
## En vez de repetir en cada pantalla qué hacer, se simula la acción "cancel":
## así funciona todo lo que ya responde a Esc. (Para que Android no cierre el juego
## de golpe, project.godot tiene application/config/quit_on_go_back = false.)
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		if is_changing():
			return  # RF-583: durante la carga «atrás» no hace nada
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
	return campaign.levels.size()


func level(index: int) -> LevelData:
	return campaign.levels[index]


## RF-112: el primer nivel siempre está desbloqueado; el resto, según el guardado.
## RF-183: en el modo de pruebas, todos.
## RF-381: una victoria previa habilita también niveles agregados después de esa partida.
func is_level_unlocked(index: int) -> bool:
	return index == 0 or DevMode.enabled or SaveManager.is_unlocked(level(index).id) \
		or SaveManager.is_completed(level(index - 1).id)


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


## El nivel cuyo progreso y récords se guardan: el de la campaña que se juega, o el mapa de la
## comunidad (RF-224). null si no se juega ninguno de los dos (F6, tests, o probando desde el editor).
func played_level() -> LevelData:
	if dev_partial_run():
		return null  # RF-321: no es una partida entera, no guarda nada
	var campaign_level: LevelData = current_level()
	if campaign_level != null:
		return campaign_level
	return current_community if current_community != null else current_mode_level()  # RF-224, RF-390


## RF-321: ¿esta partida empezó en la oleada 2 o más (modo de pruebas)? Entonces no guarda
## victoria, estrellas, récords ni desbloqueos.
func dev_partial_run() -> bool:
	return DevMode.enabled and DevMode.applied_wave > 1


## RF-321: la oleada y el oro elegidos en la selección de nivel se olvidan al seguir de nivel o al
## volver a una pantalla (en la selección se vuelven a elegir).
func forget_dev_start() -> void:
	DevMode.reset_start()


## RF-93 para un mapa de la comunidad: sus estrellas salen de la mejor cantidad de vidas guardada.
func community_stars(community_level: LevelData) -> int:
	if not SaveManager.is_completed(community_level.id):
		return 0
	return Rules.stars_for(SaveManager.best_lives(community_level.id), community_level.starting_lives, BALANCE)


## RF-93 para cualquier nivel que no es de la campaña (un mapa de un modo, RF-390): igual que la comunidad.
func map_stars(lvl: LevelData) -> int:
	return community_stars(lvl)


# --- Modos (RF-389, RF-390) ---

## El mapa del modo que se está jugando, con las reglas del modo (null si no se juega un modo).
func current_mode_level() -> LevelData:
	if current_mode.is_empty():
		return null
	return ModePacks.map_level(current_mode, current_mode_index)


## RF-390: ¿se puede jugar el mapa `index` del modo? RF-183: en el modo de pruebas, todos.
func is_mode_level_unlocked(mode: Dictionary, index: int) -> bool:
	if ModePacks.map_level(mode, index) == null:
		return false
	if DevMode.enabled:
		return true
	if SiegeAccess.applies_to(mode):
		# RF-692: Asedio N se abre al completar la campaña N (o por acceso heredado, RF-693), no por ganar Asedio N−1.
		return SiegeAccess.is_open(mode, index, SaveManager.is_completed, SaveManager.siege_legacy_unlocked())
	return ModePacks.is_open(mode, index, SaveManager.is_completed, SaveManager.is_unlocked)


func has_next_level() -> bool:
	if not current_mode.is_empty():
		var next: int = ModePacks.next_playable(current_mode, current_mode_index)
		return next >= 0 and is_mode_level_unlocked(current_mode, next)
	return current_index >= 0 and current_index + 1 < level_count()


## RF-471: ¿se está jugando el último nivel de la campaña, desde la campaña (no un modo, la comunidad ni «Probar»)
## y con texto de epílogo? Entonces ganarlo ofrece «Epílogo» en lugar de «Siguiente nivel».
func has_epilogue() -> bool:
	if not current_mode.is_empty() or current_community != null or test_level != null:
		return false
	return current_index >= 0 and current_index == level_count() - 1 and level(current_index).epilogue_text != ""


## RF-471: la campaña está terminada cuando todos sus niveles figuran completados. No se guarda un campo aparte.
func is_campaign_complete() -> bool:
	if level_count() == 0:
		return false
	for i: int in level_count():
		if not SaveManager.is_completed(level(i).id):
			return false
	return true


## RF-500: ¿el guardado tiene algún nivel de la campaña ganado? Decide a dónde va la intro al terminar.
func has_won_campaign_level() -> bool:
	for i: int in level_count():
		if SaveManager.is_completed(level(i).id):
			return true
	return false


## RF-90 y RF-112: guarda la victoria y desbloquea el siguiente nivel.
func level_won(lives: int, score: int = 0) -> void:
	if dev_partial_run():
		return  # RF-321
	if current_index >= 0:
		SaveManager.record_victory(level(current_index).id, lives, score)
		if has_next_level():
			SaveManager.unlock(level(current_index + 1).id)
		SaveManager.save()
	elif current_community != null:
		# RF-224: solo su propio progreso. No desbloquea nada ni suma a la campaña.
		SaveManager.record_victory(current_community.id, lives, score)
		SaveManager.save()
	elif current_mode_level() != null:
		# RF-390: progreso del mapa del modo; desbloquea el siguiente del MISMO modo, nunca la campaña.
		SaveManager.record_victory(current_mode_level().id, lives, score)
		var next: int = ModePacks.next_playable(current_mode, current_mode_index)
		if next >= 0 and not SiegeAccess.applies_to(current_mode):  # RF-692: ganar Asedio no abre el siguiente
			SaveManager.unlock(ModePacks.map_level(current_mode, next).id)
		SaveManager.save()


# --- Récords de cada nivel (RF-191, RF-196) ---

## ¿Estos puntos entran en el top 5 del nivel que se está jugando (de la campaña o un mapa de la
## comunidad, RF-224)? Fuera de esos dos (F6, tests, probando desde el editor), no.
func level_score_qualifies(points: int) -> bool:
	var played: LevelData = played_level()
	return played != null and HighScores.qualifies(SaveManager.scores(played.id), points)


## Anota el récord del nivel que se está jugando y guarda. Devuelve la posición (0 = primero)
## o -1 si no entró o no se juega desde el menú.
func record_level_score(name: String, points: int) -> int:
	var played: LevelData = played_level()
	if played == null:
		return -1
	var index: int = SaveManager.add_score(played.id, name, points)
	SaveManager.set_last_initials(name)
	SaveManager.save()
	return index


func current_level_scores() -> Array:
	var played: LevelData = played_level()
	return [] if played == null else SaveManager.scores(played.id)


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
	if current_index < 0 or dev_partial_run() or not campaign_complete():
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
	if is_changing():
		return  # RF-582: con un cambio en curso, otro toque no hace nada
	if not is_level_unlocked(index):
		return
	current_index = index
	test_level = null
	current_community = null
	_clear_mode()
	select_page = &"campaign"
	intro_pending = true
	_change_scene(GAME_SCENE)


## RF-224: juega un mapa de la comunidad, con su propio progreso.
func start_community(community_level: LevelData) -> void:
	if is_changing():
		return  # RF-582: con un cambio en curso, otro toque no hace nada
	current_index = -1
	test_level = null
	current_community = community_level
	_clear_mode()
	select_page = &"community"
	intro_pending = true  # RF-468: solo se muestra si el archivo del mapa trae "textos"
	_change_scene(GAME_SCENE)


## RF-217: juega el nivel del editor. No es de la campaña: no guarda nada.
func play_test(level_to_test: LevelData) -> void:
	if is_changing():
		return  # RF-582: con un cambio en curso, otro toque no hace nada
	current_index = -1
	test_level = level_to_test
	current_community = null
	_clear_mode()
	intro_pending = false  # RF-468: probando desde el editor no hay cartel
	_change_scene(GAME_SCENE)


## RF-389: juega el mapa `index` de un modo, con sus reglas y su progreso propio (RF-390).
func start_mode_level(mode: Dictionary, index: int) -> void:
	if is_changing():
		return  # RF-582: con un cambio en curso, otro toque no hace nada
	if not is_mode_level_unlocked(mode, index):
		return
	current_index = -1
	test_level = null
	current_community = null
	current_mode = mode
	current_mode_index = index
	select_page = ModePacks.page_of(mode)
	select_map_index = index
	intro_pending = true  # RF-468: los modos oficiales nunca lo muestran; los propios, si el mapa trae "textos"
	_change_scene(GAME_SCENE)


func next_level() -> void:
	if is_changing():
		return  # RF-582
	if not has_next_level():
		return
	forget_dev_start()  # RF-321
	if not current_mode.is_empty():
		start_mode_level(current_mode, ModePacks.next_playable(current_mode, current_mode_index))
	else:
		start_level(current_index + 1)


func _clear_mode() -> void:
	current_mode = {}
	current_mode_index = -1


func go_to_main_menu() -> void:
	if is_changing():
		return  # RF-582: con un cambio en curso, otro toque no hace nada
	forget_dev_start()  # RF-321
	current_index = -1
	test_level = null
	current_community = null
	_clear_mode()
	_change_scene(MAIN_MENU_SCENE)


func go_to_level_select() -> void:
	if is_changing():
		return  # RF-582: con un cambio en curso, otro toque no hace nada
	forget_dev_start()  # RF-321
	current_index = -1
	test_level = null
	current_community = null
	_clear_mode()
	_change_scene(LEVEL_SELECT_SCENE)


## RF-210: el editor de mapas (solo en el modo de pruebas). También es a donde se vuelve al
## terminar de probar un nivel (RF-217): el borrador sigue en `editor_draft`.
func go_to_editor() -> void:
	if is_changing():
		return  # RF-582: con un cambio en curso, otro toque no hace nada
	current_index = -1
	test_level = null
	current_community = null
	_clear_mode()
	_change_scene(EDITOR_SCENE)


## T441 (RF-660): el hub «Herramientas». A él lleva el menú y a él vuelve el editor al salir.
func go_to_tools() -> void:
	if is_changing():
		return  # RF-582: con un cambio en curso, otro toque no hace nada
	current_index = -1
	test_level = null
	current_community = null
	_clear_mode()
	_change_scene(TOOLS_SCENE)


## T443: editor cosmético independiente del borrador de mapas y del guardado de campaña.
func go_to_banner_editor() -> void:
	if is_changing():
		return
	current_index = -1
	test_level = null
	current_community = null
	_clear_mode()
	_change_scene(BANNER_EDITOR_SCENE)


## RF-195: la pantalla de récords.
func go_to_records() -> void:
	if is_changing():
		return  # RF-582: con un cambio en curso, otro toque no hace nada
	current_index = -1
	test_level = null
	current_community = null
	_clear_mode()
	_change_scene(RECORDS_SCENE)


## RF-230: la wiki.
func go_to_wiki() -> void:
	if is_changing():
		return  # RF-582: con un cambio en curso, otro toque no hace nada
	current_index = -1
	test_level = null
	current_community = null
	_clear_mode()
	_change_scene(WIKI_SCENE)


## RF-584: «Reintentar»: vuelve a cargar la escena actual con la misma pantalla de carga.
func reload_current() -> void:
	if is_changing():
		return  # RF-582
	var scene: Node = current_screen()
	if scene == null or scene.scene_file_path == "":
		if presentation_host != null and is_instance_valid(presentation_host):
			presentation_host.install_scene(load("res://scenes/ui/main_menu.tscn") as PackedScene)
		else:
			get_tree().reload_current_scene()
		return
	_change_scene(scene.scene_file_path)


func attach_presentation(host: Node) -> void:
	presentation_host = host
	if transition != null:
		transition.swapper = Callable(host, "install_scene")


func update_presentation_scale(scale: float) -> void:
	if transition != null:
		transition.set_overlay_scale(scale)


func detach_presentation(host: Node) -> void:
	if presentation_host != host:
		return
	presentation_host = null
	if transition != null:
		transition.swapper = Callable()
		transition.set_overlay_scale(1.0)


func current_screen() -> Node:
	if presentation_host != null and is_instance_valid(presentation_host):
		return presentation_host.get_active_screen()
	return get_tree().current_scene


## RF-582: ¿hay un cambio de pantalla en curso? Mientras tanto ninguna función de acá cambia nada.
func is_changing() -> bool:
	return transition != null and transition.is_busy()


## RF-580: todo cambio de pantalla pasa por acá y muestra la pantalla de carga.
func _change_scene(path: String) -> void:
	transition.go(path)


## RF-581: el núcleo genérico (`SceneTransition`) y los colores de este juego.
func _make_transition() -> void:
	transition = SceneTransition.new()
	transition.name = "Transition"
	transition.ui_theme = LOADING_THEME
	transition.min_seconds = LOADING_MIN_SECONDS
	transition.background_color = LOADING_BACKGROUND
	transition.accent_color = LOADING_ACCENT
	add_child(transition)
