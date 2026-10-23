# Tests del hub «Herramientas» (T441, RF-660, RF-661, D-184): rutas y disponibilidad.
# Nunca se llama al GameFlow real: se usan las costuras (open_tools, open_map_editor, go_back).
extends GutTest

const HUB_SCENE: PackedScene = preload("res://scenes/ui/tools_hub.tscn")
const MENU_SCENE: PackedScene = preload("res://scenes/ui/main_menu.tscn")
const EDITOR_SCENE: PackedScene = preload("res://scenes/editor/map_editor.tscn")
const NORMAL_PATH: String = "user://test_tools_hub_normal.flag"
const DEV_PATH: String = "user://test_tools_hub_dev.flag"

var _calls: Array[String] = []


func before_each() -> void:
	_calls.clear()


func after_each() -> void:
	DevMode.set_enabled(false, NORMAL_PATH)
	for path: String in [NORMAL_PATH, DEV_PATH]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)


func _hub() -> ToolsHub:
	var hub: ToolsHub = HUB_SCENE.instantiate()
	add_child_autofree(hub)
	hub.open_map_editor = func() -> void: _calls.append("editor")
	hub.go_back = func() -> void: _calls.append("back")
	return hub


func test_hub_cards_availability() -> void:
	var hub: ToolsHub = _hub()
	var maps: Button = hub.get_node("%MapEditorButton")
	var banners: Button = hub.get_node("%BannerEditorButton")
	assert_false(maps.disabled, "el editor de mapas funciona")
	assert_true(banners.disabled, "el de banderines llega en T443")
	assert_true(banners.text.contains("Próximamente"))
	assert_true(banners.text.contains("Editor de banderines"))
	assert_true(ToolsHub.is_tool_available(&"map_editor"))
	assert_false(ToolsHub.is_tool_available(&"banner_editor"))
	assert_false(ToolsHub.is_tool_available(&"otra_cosa"), "una herramienta desconocida no está disponible")


func test_hub_buttons_route_to_editor_and_back() -> void:
	var hub: ToolsHub = _hub()
	(hub.get_node("%MapEditorButton") as Button).pressed.emit()
	assert_eq(_calls, ["editor"])
	(hub.get_node("%BackButton") as Button).pressed.emit()
	assert_eq(_calls, ["editor", "back"])


func test_disabled_banner_card_goes_nowhere() -> void:
	var hub: ToolsHub = _hub()
	var banners: Button = hub.get_node("%BannerEditorButton")
	banners.pressed.emit()
	assert_eq(_calls, [])


func test_cancel_goes_back_to_the_menu() -> void:
	var hub: ToolsHub = _hub()
	var event := InputEventAction.new()
	event.action = "cancel"
	event.pressed = true
	hub._unhandled_input(event)
	assert_eq(_calls, ["back"])


func test_menu_button_opens_tools_with_the_same_availability() -> void:
	DevMode.set_enabled(false, NORMAL_PATH)
	var menu: MainMenu = MENU_SCENE.instantiate()
	menu.open_tools = func() -> void: _calls.append("tools")
	add_child_autofree(menu)
	var button: Button = menu.get_node("%EditorButton")
	assert_eq(button.text, "Herramientas")
	assert_true(button.visible, "en PC está")
	button.pressed.emit()
	assert_eq(_calls, ["tools"])
	assert_true(MainMenu.editor_available(false))
	assert_false(MainMenu.editor_available(true), "en el celular, no")
	DevMode.set_enabled(true, DEV_PATH)
	assert_true(MainMenu.editor_available(true), "en el modo de pruebas, siempre")


func test_editor_leave_goes_to_the_hub_and_try_keeps_returning_to_the_editor() -> void:
	var editor: MapEditor = EDITOR_SCENE.instantiate()
	add_child_autofree(editor)
	assert_true(editor.left.is_connected(GameFlow.go_to_tools), "la salida normal vuelve al hub")
	assert_false(editor.left.is_connected(GameFlow.go_to_main_menu))
	# «Probar» sigue igual: la partida vuelve al editor, no al hub.
	assert_eq(GameFlow.EDITOR_SCENE, "res://scenes/editor/map_editor.tscn")
	assert_eq(GameFlow.TOOLS_SCENE, "res://scenes/ui/tools_hub.tscn")
	assert_true(editor.test_requested.is_connected(GameFlow.play_test))
