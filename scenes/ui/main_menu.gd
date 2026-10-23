# Menú principal (RF-110): Jugar, Récords, Wiki, Herramientas (T441, antes «Editor de mapas»; RF-210: no en el celular), Opciones
# y Salir. «Jugar» abre la intro la primera vez (M57, RF-498) y después va a la selección de niveles.
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
## RF-550: en el celular, el logo a la izquierda y los botones a la derecha. Medidas de interfaz.
const MOBILE_LOGO_SIZE: Vector2 = Vector2(560.0, 320.0)
const MOBILE_COLUMN_GAP: float = 48.0

## Costuras de los tests (no cambian de escena): a dónde se va y de dónde se lee la intro.
var open_level_select: Callable = GameFlow.go_to_level_select
var open_first_level: Callable = GameFlow.start_level.bind(0)
var open_tools: Callable = GameFlow.go_to_tools
var intro_path: String = IntroData.DEFAULT_PATH
## M67 (RF-603, RF-608): de dónde se leen las novedades, qué versión está instalada y si se corre desde el editor.
var news_path: String = NewsData.DEFAULT_PATH
var news_version_source: Callable = GameVersion.raw
var news_in_editor: bool = OS.has_feature("editor")

## La intro (RF-499). Es hija del menú: la música de menú sigue sonando por debajo.
var intro_screen: IntroScreen
## «Novedades de esta versión» (M67). También es hija del menú; sale sola una vez por versión.
var news_screen: NewsScreen

var _two_columns: bool = false


func _ready() -> void:
	intro_screen = IntroScreen.new()
	add_child(intro_screen)
	intro_screen.finished.connect(_on_intro_finished)
	_play_button.pressed.connect(play)
	_records_button.pressed.connect(GameFlow.go_to_records)  # RF-195
	_wiki_button.pressed.connect(GameFlow.go_to_wiki)  # RF-230
	_editor_button.visible = editor_available(OS.has_feature("mobile"))  # RF-210
	_editor_button.pressed.connect(func() -> void: open_tools.call())
	_options_button.pressed.connect(_options.open)
	_quit_button.pressed.connect(get_tree().quit)
	_options.closed.connect(_play_button.grab_focus)
	# RF-383, RF-384: el modo de pruebas se prende y se apaga desde Opciones, solo acá (no en la pausa).
	# Al cambiar, el menú se vuelve a armar (botón del editor en el celular, cartel, guardado).
	_options.admin_available = true
	_options.dev_mode_changed.connect(func(_on: bool) -> void: GameFlow.go_to_main_menu())
	Audio.add_click_sounds(self)
	_logo.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS  # D-023: el logo se achica
	_arrange_mobile_columns()
	resized.connect(_fit_logo)
	_fit_logo()
	MenuTouch.attach(self)  # RF-550, RF-551: botones de 56 px en el celular
	_play_button.grab_focus()  # se puede jugar con Enter sin tocar el mouse
	news_screen = NewsScreen.new()
	add_child(news_screen)
	news_screen.closed.connect(_play_button.grab_focus)
	_show_news_if_new()


## RF-498: «Jugar». Abre la intro si el guardado no la vio (fuera del modo de pruebas y con el archivo en orden);
## si no, la selección de niveles. Una intro rota se avisa en la salida y nunca bloquea jugar.
func play() -> void:
	if intro_screen.is_open():
		return
	if not IntroFlow.should_auto_show(SaveManager.intro_seen(), DevMode.enabled, true):
		open_level_select.call()
		return
	var data: IntroData = IntroData.load_file(intro_path)
	if not IntroFlow.should_auto_show(SaveManager.intro_seen(), DevMode.enabled, data.is_valid()):
		push_warning("La intro no se muestra: %s" % "; ".join(data.errors))
		open_level_select.call()
		return
	SaveManager.mark_intro_seen()  # al abrirse, no al terminar (RF-498)
	intro_screen.open(data)


## RF-603: al abrir el menú, las novedades de la versión instalada salen solas si corresponde (una vez por versión,
## fuera del modo de pruebas y del editor). Un archivo roto se avisa en la salida y nunca bloquea el menú.
func _show_news_if_new() -> void:
	var version: String = String(news_version_source.call())
	if version.is_empty() or version == SaveManager.news_version_seen() or DevMode.enabled or news_in_editor:
		return  # nada que decidir: ni se lee el archivo
	var data: NewsData = NewsData.load_file(news_path)
	if not data.is_valid():
		push_warning("Las novedades no se muestran: %s" % "; ".join(data.errors))
		return
	var new_save: bool = NewsFlow.is_new_save(GameFlow.has_won_campaign_level(), SaveManager.intro_seen())
	var entry: Dictionary = data.entry_for(version)
	match NewsFlow.decide(version, SaveManager.news_version_seen(), entry, true, DevMode.enabled, news_in_editor, false, new_save):
		NewsFlow.Decision.SHOW:
			SaveManager.mark_news_seen(version)  # al abrirse, no al cerrarse (RF-603)
			news_screen.open(entry, data.labels)
		NewsFlow.Decision.MARK_SILENTLY:
			SaveManager.mark_news_seen(version)


## RF-500: al terminar u omitir, el nivel 1 si no hay niveles ganados; la selección si los hay.
func _on_intro_finished() -> void:
	if IntroFlow.after_finish(GameFlow.has_won_campaign_level()) == IntroFlow.Destination.LEVEL_1:
		open_first_level.call()
	else:
		open_level_select.call()


## RF-331: el alto del logo para que, con `button_count` botones, todo entre en una ventana de
## `window_height`: lo que sobra después de los botones, entre un mínimo y un máximo.
static func logo_height(window_height: float, button_count: int) -> float:
	var buttons: float = button_count * (BUTTON_HEIGHT + ROW_GAP)
	var spare: float = window_height - SCREEN_MARGIN * 2.0 - buttons - 8.0 - ROW_GAP
	return clampf(spare, LOGO_MIN_HEIGHT, LOGO_MAX_HEIGHT)


## RF-550: con botones de 56 px, seis botones y el logo ya no entran en una sola columna de 720 de alto. En el modo
## celular el logo pasa a la izquierda y la columna de botones a la derecha. En PC no se toca nada.
func _arrange_mobile_columns() -> void:
	if not UiMode.is_mobile():
		return
	_two_columns = true
	var center: Control = $Center
	var rows: Control = $Center/Rows
	var columns := HBoxContainer.new()
	columns.name = "MobileColumns"
	columns.add_theme_constant_override("separation", int(MOBILE_COLUMN_GAP))
	center.add_child(columns)
	_logo.reparent(columns, false)
	rows.reparent(columns, false)
	columns.move_child(_logo, 0)
	$Center/MobileColumns/Rows/Spacer.queue_free()
	_logo.custom_minimum_size = MOBILE_LOGO_SIZE
	_logo.size_flags_vertical = Control.SIZE_SHRINK_CENTER


func _fit_logo() -> void:
	if _two_columns:
		return
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
