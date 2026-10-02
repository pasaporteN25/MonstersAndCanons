# Menú principal (RF-110): Jugar, Récords, Wiki, Editor de mapas (RF-210: no en el celular), Opciones
# y Salir.
class_name MainMenu
extends Control

@onready var _play_button: Button = %PlayButton
@onready var _records_button: Button = %RecordsButton
@onready var _wiki_button: Button = %WikiButton
@onready var _editor_button: Button = %EditorButton
@onready var _options_button: Button = %OptionsButton
@onready var _quit_button: Button = %QuitButton
@onready var _options: OptionsMenu = %OptionsMenu
@onready var _logo: TextureRect = %Logo

## RF-331: medidas de interfaz del menú (no son de balance): alto de cada botón, separación entre filas,
## aire arriba y abajo, y los límites del alto del logo.
const BUTTON_HEIGHT: float = 52.0
const ROW_GAP: float = 12.0
const SCREEN_MARGIN: float = 24.0
const LOGO_MIN_HEIGHT: float = 70.0
const LOGO_MAX_HEIGHT: float = 240.0


func _ready() -> void:
	_play_button.pressed.connect(GameFlow.go_to_level_select)
	_records_button.pressed.connect(GameFlow.go_to_records)  # RF-195
	_wiki_button.pressed.connect(GameFlow.go_to_wiki)  # RF-230
	_editor_button.visible = editor_available(OS.has_feature("mobile"))  # RF-210
	_editor_button.pressed.connect(GameFlow.go_to_editor)
	_options_button.pressed.connect(_options.open)
	_quit_button.pressed.connect(get_tree().quit)
	_options.closed.connect(_play_button.grab_focus)
	Audio.add_click_sounds(self)
	_logo.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS  # D-023: el logo se achica
	resized.connect(_fit_logo)
	_fit_logo()
	_play_button.grab_focus()  # se puede jugar con Enter sin tocar el mouse


## RF-331: el alto del logo para que, con `button_count` botones, todo entre en una ventana de
## `window_height`: lo que sobra después de los botones, entre un mínimo y un máximo.
static func logo_height(window_height: float, button_count: int) -> float:
	var buttons: float = button_count * (BUTTON_HEIGHT + ROW_GAP)
	var spare: float = window_height - SCREEN_MARGIN * 2.0 - buttons - 8.0 - ROW_GAP
	return clampf(spare, LOGO_MIN_HEIGHT, LOGO_MAX_HEIGHT)


func _fit_logo() -> void:
	var buttons: int = 5 + (1 if _editor_button.visible else 0)
	_logo.custom_minimum_size.y = logo_height(size.y, buttons)


## RF-210 (D-038): el editor es para todos, menos en el celular (se maneja con mouse y teclado); el
## modo de pruebas lo ve siempre.
static func editor_available(is_mobile: bool) -> bool:
	return not is_mobile or DevMode.enabled


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("cancel") and _options.visible:
		_options.close()
		get_viewport().set_input_as_handled()
