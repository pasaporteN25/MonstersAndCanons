# Hub «Herramientas» (T441, RF-660, RF-661, D-184): reemplaza al botón «Editor de mapas» del menú.
# Dos tarjetas: el editor de mapas (funcional) y el de banderines (deshabilitado hasta T443).
class_name ToolsHub
extends Control

const MAP_EDITOR_TITLE: String = "Editor de mapas"
const BANNER_EDITOR_TITLE: String = "Editor de banderines"
const COMING_SOON: String = "Próximamente"

## Costuras de los tests (no cambian de escena): a dónde va cada botón.
var open_map_editor: Callable = GameFlow.go_to_editor
var go_back: Callable = GameFlow.go_to_main_menu

@onready var _map_editor_button: Button = %MapEditorButton
@onready var _banner_editor_button: Button = %BannerEditorButton
@onready var _back_button: Button = %BackButton


func _ready() -> void:
	_map_editor_button.text = MAP_EDITOR_TITLE
	_map_editor_button.disabled = not is_tool_available(&"map_editor")
	_banner_editor_button.text = "%s\n(%s)" % [BANNER_EDITOR_TITLE, COMING_SOON]
	_banner_editor_button.disabled = not is_tool_available(&"banner_editor")
	_map_editor_button.pressed.connect(func() -> void: open_map_editor.call())
	_back_button.pressed.connect(func() -> void: go_back.call())
	Audio.add_click_sounds(self)
	MenuTouch.attach(self)  # RF-550: botones de 56 px en el celular
	_map_editor_button.grab_focus()


## Qué herramientas están listas. El editor de banderines llega en T443.
static func is_tool_available(tool_id: StringName) -> bool:
	return tool_id == &"map_editor"


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("cancel"):
		go_back.call()
		get_viewport().set_input_as_handled()
