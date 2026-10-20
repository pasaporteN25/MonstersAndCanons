# La pantalla «Novedades de esta versión» (M67, RF-604, T373): se abre con una entrada, se cierra con «Entendido» y
# con Esc, borra sus nodos, entra en 1280 × 720 en PC y en modo celular con 8 novedades y el clic no pasa al menú
# de abajo. Nada cambia de escena. El modo (PC o celular) se fija en el guardado de prueba.
extends GutTest

const TEST_SAVE: String = "user://test_news_screen.json"
const WINDOW: Rect2 = Rect2(0.0, 0.0, 1280.0, 720.0)
const MENU_SCENE: PackedScene = preload("res://scenes/ui/main_menu.tscn")

var _viewport: SubViewport
var _screen: NewsScreen
var _closed: int = 0
var _labels: Dictionary = NewsData.load_file().labels


func before_each() -> void:
	_cleanup()
	SaveManager.save_path = TEST_SAVE
	SaveManager.load_save()
	_closed = 0
	_viewport = SubViewport.new()
	_viewport.size = Vector2i(1280, 720)
	add_child_autofree(_viewport)


func after_each() -> void:
	_cleanup()
	SaveManager.save_path = SaveManager.DEFAULT_PATH
	SaveManager.load_save()


func _cleanup() -> void:
	if FileAccess.file_exists(TEST_SAVE):
		DirAccess.remove_absolute(TEST_SAVE)


func _entry(count: int, kind: String = "presentacion", draft: bool = false) -> Dictionary:
	var items: Array = []
	for i: int in count:
		items.append({"titulo": "Novedad %d" % (i + 1), "texto": "Una frase larga que explica la novedad número %d y que ocupa dos renglones en la pantalla del celular." % (i + 1), "icono": ""})
	return {"id": "1.0.0", "tipo": kind, "borrador": draft, "titulo": "Monsters & Canons 1.0",
		"subtitulo": "Esto es lo que trae el juego completo.", "cabecera": "", "novedades": items}


func _open(entry: Dictionary, mode: int = UiMode.PC) -> void:
	SaveManager.set_setting("ui_mode", mode)
	_screen = NewsScreen.new()
	_viewport.add_child(_screen)
	_screen.closed.connect(func() -> void: _closed += 1)
	_screen.open(entry, _labels)
	await get_tree().process_frame
	await get_tree().process_frame


func _cancel() -> void:
	var event := InputEventAction.new()
	event.action = &"cancel"
	event.pressed = true
	_screen._input(event)


func test_opens_with_title_subtitle_version_and_the_items() -> void:
	await _open(_entry(3))
	assert_true(_screen.is_open())
	assert_eq(_screen.item_count(), 3)
	assert_eq((_screen.find_child("Title", true, false) as Label).text, "Monsters & Canons 1.0")
	assert_eq((_screen.find_child("Subtitle", true, false) as Label).text, "Esto es lo que trae el juego completo.")
	assert_eq((_screen.find_child("Version", true, false) as Label).text, "Versión 1.0.0")
	assert_eq(_screen.button().text, "Entendido")
	assert_null(_screen.find_child("DraftTag", true, false), "aprobada: sin rótulo de borrador")


func test_draft_shows_the_draft_label() -> void:
	await _open(_entry(2, "presentacion", true))
	var tag: Label = _screen.find_child("DraftTag", true, false) as Label
	assert_not_null(tag)
	assert_eq(tag.text, "Borrador")


func test_improvements_use_the_improvements_title() -> void:
	await _open(_entry(2, "mejoras"))
	assert_eq((_screen.find_child("Title", true, false) as Label).text, "Mejoras de esta versión")
	assert_eq((_screen.find_child("Subtitle", true, false) as Label).text, "Esto es lo que trae el juego completo.")


func test_understood_closes_once_and_frees_the_nodes() -> void:
	await _open(_entry(3))
	_screen.button().pressed.emit()
	_screen.close()  # cerrar de nuevo no vuelve a avisar
	assert_eq(_closed, 1)
	assert_false(_screen.is_open())
	assert_false(_screen.visible)
	await get_tree().process_frame
	assert_eq(_screen.get_child_count(), 0, "se borran los nodos al cerrar")
	assert_eq(_screen.item_count(), 0)


func test_escape_closes_and_can_be_reopened() -> void:
	await _open(_entry(3))
	_cancel()
	assert_eq(_closed, 1)
	await get_tree().process_frame
	_screen.open(_entry(2), _labels)
	assert_eq(_screen.item_count(), 2, "al reabrir se arma de nuevo")
	_cancel()
	assert_eq(_closed, 2)


func test_escape_does_nothing_when_closed() -> void:
	await _open(_entry(1))
	_screen.close()
	_cancel()
	assert_eq(_closed, 1)


func test_pc_layout_fits_with_eight_items() -> void:
	await _open(_entry(8), UiMode.PC)
	assert_eq(_screen.panel().custom_minimum_size.x, 720.0)
	assert_true(WINDOW.encloses(_screen.panel().get_global_rect()), "el panel entra: %s" % _screen.panel().get_global_rect())
	assert_true(WINDOW.encloses(_screen.button().get_global_rect()), "«Entendido» está a la vista")
	assert_gte(_screen.button().size.y, 43.5)
	assert_null(_screen.scroll().find_child("TouchScroller", false, false), "en PC, rueda y barra")


func test_mobile_layout_fits_scrolls_and_has_big_targets() -> void:
	await _open(_entry(8), UiMode.MOBILE)
	assert_eq(_screen.panel().custom_minimum_size.x, 880.0)
	assert_true(WINDOW.encloses(_screen.panel().get_global_rect()), "el panel entra: %s" % _screen.panel().get_global_rect())
	assert_true(WINDOW.encloses(_screen.button().get_global_rect()), "«Entendido» está a la vista")
	assert_gte(_screen.button().size.y, 55.5)
	assert_not_null(_screen.scroll().find_child("TouchScroller", false, false), "un dedo con inercia")
	var content: float = (_screen.scroll().get_child(0) as Control).get_combined_minimum_size().y
	assert_gt(content, _screen.scroll().size.y, "con 8 novedades la lista se desplaza")
	for row: Node in _screen.find_children("Item", "HBoxContainer", true, false):
		assert_gte((row as Control).size.y, 55.5, "las filas miden 56 o más")
	for label: Node in _screen.find_children("*", "Label", true, false):
		var size: int = (label as Label).get_theme_font_size("font_size")
		assert_gte(size, 20, "textos de 20 px o más en el celular: «%s»" % (label as Label).text)


func test_mobile_with_one_item_fits_without_scrolling() -> void:
	await _open(_entry(1), UiMode.MOBILE)
	assert_true(WINDOW.encloses(_screen.panel().get_global_rect()))
	var content: float = (_screen.scroll().get_child(0) as Control).get_combined_minimum_size().y
	assert_lte(content, _screen.scroll().size.y + 1.0, "una novedad no necesita desplazar")


func test_pc_text_sizes_are_18_or_more() -> void:
	await _open(_entry(3), UiMode.PC)
	for label: Node in _screen.find_children("*", "Label", true, false):
		assert_gte((label as Label).get_theme_font_size("font_size"), 18)


func test_overlay_blocks_clicks_to_the_menu_below() -> void:
	SaveManager.set_setting("ui_mode", UiMode.PC)
	var played: Array = [0]
	var menu: MainMenu = MENU_SCENE.instantiate() as MainMenu
	menu.open_level_select = func() -> void: played[0] += 1
	menu.intro_path = "res://no/existe.json"
	_viewport.add_child(menu)
	await get_tree().process_frame
	var play: Button = menu.get_node("%PlayButton")
	_click(play.get_global_rect().get_center(), true)
	_click(play.get_global_rect().get_center(), false)
	assert_eq(played[0], 1, "control: sin la pantalla, el mismo clic sí activa «Jugar»")
	played[0] = 0
	_screen = NewsScreen.new()
	_viewport.add_child(_screen)
	_screen.closed.connect(func() -> void: _closed += 1)
	_screen.open(_entry(3), _labels)
	await get_tree().process_frame
	await get_tree().process_frame
	_click(play.get_global_rect().get_center(), true)
	_click(play.get_global_rect().get_center(), false)
	assert_eq(played[0], 0, "un clic sobre el menú con la pantalla abierta no llega a «Jugar»")
	assert_true(_screen.is_open(), "y tampoco la cierra")
	var target: Vector2 = _screen.button().get_global_rect().get_center()
	_click(target, true)
	_click(target, false)
	assert_eq(_closed, 1, "«Entendido» cierra al soltar")
	assert_eq(played[0], 0, "y el toque que cierra no activa nada de abajo")


func _click(position: Vector2, pressed: bool) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = pressed
	event.position = position
	event.global_position = position
	_viewport.push_input(event)
