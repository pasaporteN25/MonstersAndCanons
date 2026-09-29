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

var enabled: bool = false

var _banner: CanvasLayer


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


func is_banner_visible() -> bool:
	return _banner != null and _banner.visible


## RF-182: cartel "MODO PRUEBAS" abajo al centro, encima de todas las pantallas.
func _show_banner(on: bool) -> void:
	if _banner == null:
		_banner = CanvasLayer.new()
		_banner.layer = 100
		var label := Label.new()
		label.text = "MODO PRUEBAS · F1: panel"
		label.position = Vector2(540, 699)  # franja libre de abajo, bajo los botones
		label.size = Vector2(200, 20)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label.add_theme_font_size_override("font_size", 13)
		label.add_theme_color_override("font_color", Color(1, 0.55, 0.3))
		label.add_theme_color_override("font_outline_color", Color(0.1, 0.1, 0.12))
		label.add_theme_constant_override("outline_size", 5)
		_banner.add_child(label)
		add_child(_banner)
	_banner.visible = on
