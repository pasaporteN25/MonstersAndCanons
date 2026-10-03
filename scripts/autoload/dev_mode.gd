# Modo de pruebas (spec §10.2, D-028). Es un autoload: se usa como `DevMode`.
# Solo se activa en el ejecutable de pruebas (característica de exportación "pruebas") o
# al jugar desde el editor con el argumento --pruebas. Usa un guardado aparte, así las
# pruebas no tocan el progreso ni los récords reales.
extends Node

## Característica que agrega el preset de exportación "Windows (pruebas)".
const FEATURE: String = "pruebas"
## Argumento para activarlo desde el editor (Proyecto → Configuración → Editor → Run →
## Main Run Args: `-- --pruebas`). En un ejecutable normal se ignora.
const EDITOR_ARG: String = "--pruebas"
## RF-181: guardado del modo de pruebas.
const SAVE_PATH: String = "user://save_pruebas.json"
## RF-182: el texto del cartel (sin la velocidad).
const BANNER_TEXT: String = "MODO PRUEBAS · F1: panel"
## RF-325: dónde se escribe el informe de la partida de pruebas.
const STATS_PATH: String = "user://pruebas_stats.json"

## RF-323: los atajos de teclado del modo de pruebas (acción del `InputMap`, tecla, texto del panel).
## F1 abre el panel. Ninguna tecla es `1`–`9`, `Esc`, `Espacio`, `P`, `F`, `U` ni `S`, que usa el juego.
## F5 se saltea: Godot la usa para actualizar los cuadros de diálogo de archivos (`ui_filedialog_refresh`).
const ACTIONS: Array[Dictionary] = [
	{"action": &"dev_kill_all", "key": KEY_F2, "text": "Matar a todos"},
	{"action": &"dev_skip_wave", "key": KEY_F3, "text": "Saltar oleada"},
	{"action": &"dev_infinite_lives", "key": KEY_F4, "text": "Vidas infinitas"},
	{"action": &"dev_slower", "key": KEY_F6, "text": "Velocidad más lenta"},
	{"action": &"dev_faster", "key": KEY_F7, "text": "Velocidad más rápida"},
]

## RF-324: los números del modo de pruebas (oro del botón, velocidades).
var config: DevConfig = preload("res://data/dev_config.tres")
var enabled: bool = false
## Habilitación temporal de apoyo, nunca escribe colección.
var support_unlocked: bool = false
## RF-319: lo que se eligió en la selección de nivel. La oleada desde la que se empieza (1 = como
## siempre) y el oro inicial (-1 = automático, RF-320). `Game` los lee al arrancar y NO los borra,
## así reintentar repite la misma partida (RF-321).
var start_wave: int = 1
var start_gold: int = -1
## La oleada con la que arrancó de verdad la partida en curso (ya ajustada al total del nivel).
## Mayor que 1 = no es una partida entera y no guarda progreso (RF-321). La fija `Game`.
var applied_wave: int = 1

## RF-325: archivo del informe. Con un guardado de prueba (`set_enabled(true, ruta)`) es otro archivo al lado,
## así los tests no pisan el informe del jugador.
var stats_path: String = STATS_PATH
var _banner: CanvasLayer
var _banner_label: Label
var _speed: float = 1.0


func _ready() -> void:
	# Va después de SaveManager en la lista de autoloads y antes de GameFlow y Audio,
	# así las opciones (pantalla completa, volumen) ya salen del guardado de pruebas.
	if detect():
		set_enabled(true)


## RF-180: ¿este ejecutable trae el modo de pruebas?
static func detect() -> bool:
	if OS.has_feature(FEATURE):
		return true
	return OS.has_feature("editor") and OS.get_cmdline_user_args().has(EDITOR_ARG)


## Prende o apaga el modo y cambia de guardado (RF-181). Los tests pasan su propio
## `save_path` para no crear archivos en la carpeta del jugador.
func set_enabled(on: bool, save_path: String = "") -> void:
	enabled = on
	support_unlocked = false
	if save_path == "":
		save_path = SAVE_PATH if on else SaveManager.DEFAULT_PATH
	SaveManager.save_path = save_path
	stats_path = save_path.get_basename() + "_stats.json" if on and save_path != SAVE_PATH else STATS_PATH
	SaveManager.load_save()
	if on:
		register_actions()
	else:
		unregister_actions()
	_show_banner(on)
	if on:
		print("Modo de pruebas activado. Guardado: %s" % save_path)  # queda en el log
		# Sirve para comprobar, en el ejecutable exportado, que las listas de enemigos no salen vacías.
		print("Enemigos disponibles: %d" % LevelFile.enemy_ids().size())


## RF-321: vuelve a "empezar en la oleada 1 con el oro del nivel".
func reset_start() -> void:
	start_wave = 1
	start_gold = -1
	applied_wave = 1


## RF-322: el cartel dice la velocidad cuando no es x1. `Game` avisa cada vez que cambia.
func show_speed(speed: float) -> void:
	_speed = speed
	if _banner_label != null:
		_banner_label.text = banner_text()


## RF-182 y RF-322: el texto del cartel.
func banner_text() -> String:
	var text: String = BANNER_TEXT
	if not is_equal_approx(_speed, 1.0):
		text += " · %s" % Rules.speed_text(_speed)
	return text


## RF-323: crea las acciones de los atajos en el `InputMap`. El juego normal no las tiene.
func register_actions() -> void:
	for shortcut: Dictionary in ACTIONS:
		var action: StringName = shortcut["action"]
		if not InputMap.has_action(action):
			InputMap.add_action(action)
			var event := InputEventKey.new()
			event.physical_keycode = shortcut["key"]
			InputMap.action_add_event(action, event)


func unregister_actions() -> void:
	for shortcut: Dictionary in ACTIONS:
		var action: StringName = shortcut["action"]
		if InputMap.has_action(action):
			InputMap.erase_action(action)


## El nombre de la tecla de un atajo, por ejemplo "F2", para escribirlo en el panel.
static func key_label(action: StringName) -> String:
	for shortcut: Dictionary in ACTIONS:
		if shortcut["action"] == action:
			return OS.get_keycode_string(shortcut["key"])
	return ""


## RF-325: escribe el informe de la partida. Devuelve false si no se pudo (queda un aviso en el log).
func write_stats(report: Dictionary) -> bool:
	var ok: bool = DevStats.write(report, stats_path)
	if not ok:
		print("No se pudo escribir el informe de pruebas en %s" % stats_path)
	return ok


## Borra el archivo del informe (lo usan los tests para no dejar nada).
func clear_stats_file() -> void:
	if FileAccess.file_exists(stats_path):
		DirAccess.remove_absolute(stats_path)


func is_banner_visible() -> bool:
	return _banner != null and _banner.visible


## RF-182: cartel "MODO PRUEBAS" abajo al centro, encima de todas las pantallas.
func _show_banner(on: bool) -> void:
	if _banner == null:
		_banner = CanvasLayer.new()
		_banner.layer = 100
		var label := Label.new()
		label.text = banner_text()
		_banner_label = label
		label.position = Vector2(460, 699)  # franja libre de abajo, bajo los botones (el ancho deja lugar a la velocidad)
		label.size = Vector2(360, 20)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label.add_theme_font_size_override("font_size", 13)
		label.add_theme_color_override("font_color", Color(1, 0.55, 0.3))
		label.add_theme_color_override("font_outline_color", Color(0.1, 0.1, 0.12))
		label.add_theme_constant_override("outline_size", 5)
		_banner.add_child(label)
		add_child(_banner)
	_banner.visible = on
