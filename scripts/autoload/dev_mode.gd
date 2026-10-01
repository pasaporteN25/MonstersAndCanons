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

## RF-324: los números del modo de pruebas (oro del botón, velocidades).
var config: DevConfig = preload("res://data/dev_config.tres")
var enabled: bool = false
## RF-319: lo que se eligió en la selección de nivel. La oleada desde la que se empieza (1 = como
## siempre) y el oro inicial (-1 = automático, RF-320). `Game` los lee al arrancar y NO los borra,
## así reintentar repite la misma partida (RF-321).
var start_wave: int = 1
var start_gold: int = -1
## La oleada con la que arrancó de verdad la partida en curso (ya ajustada al total del nivel).
## Mayor que 1 = no es una partida entera y no guarda progreso (RF-321). La fija `Game`.
var applied_wave: int = 1

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
	if save_path == "":
		save_path = SAVE_PATH if on else SaveManager.DEFAULT_PATH
	SaveManager.save_path = save_path
	SaveManager.load_save()
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
