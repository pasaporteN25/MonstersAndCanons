extends GutTest
# T313 y T314 (RF-550, RF-555): la distribución de los menús en 1280 × 720, en el modo celular y en el de PC.
# Pantallas reales dentro de un SubViewport; guardado de prueba para no tocar el verdadero.

const WINDOW: Rect2 = Rect2(0.0, 0.0, 1280.0, 720.0)

var _viewport: SubViewport
var _original_mode: Variant
var _original_save_path: String


func before_each() -> void:
	_original_save_path = SaveManager.save_path
	SaveManager.save_path = "user://test_t313_menu_layout.json"
	_original_mode = SaveManager.get_setting("ui_mode")
	_viewport = SubViewport.new()
	_viewport.size = Vector2i(1280, 720)
	add_child_autofree(_viewport)


func after_each() -> void:
	SaveManager.set_setting("ui_mode", _original_mode)
	if FileAccess.file_exists(SaveManager.save_path):
		DirAccess.remove_absolute(SaveManager.save_path)
	SaveManager.save_path = _original_save_path


func _open_scene(path: String, mode: int) -> Node:
	SaveManager.set_setting("ui_mode", mode)
	var node: Node = (load(path) as PackedScene).instantiate()
	_viewport.add_child(node)
	await get_tree().process_frame
	await get_tree().process_frame
	return node


func _visible_buttons(root: Node) -> Array[Button]:
	var found: Array[Button] = []
	for node: Node in root.find_children("*", "Button", true, false):
		if (node as Button).is_visible_in_tree():
			found.append(node as Button)
	return found


## Los botones que están fuera de un `ScrollContainer` (los de adentro se alcanzan desplazando).
func _fixed_buttons(root: Node) -> Array[Button]:
	var fixed: Array[Button] = []
	for button: Button in _visible_buttons(root):
		var inside: bool = false
		var parent: Node = button.get_parent()
		while parent != null and parent != root:
			if parent is ScrollContainer:
				inside = true
			parent = parent.get_parent()
		if not inside:
			fixed.append(button)
	return fixed


func _assert_buttons_inside_window(buttons: Array[Button], what: String) -> void:
	assert_gt(buttons.size(), 0, "%s: hay botones" % what)
	for button: Button in buttons:
		assert_true(WINDOW.encloses(button.get_global_rect()), "%s: «%s» entra en la ventana %s" % [what, button.text, button.get_global_rect()])


func _assert_min_height(buttons: Array[Button], minimum: float, what: String) -> void:
	for button: Button in buttons:
		assert_gte(button.size.y, minimum - 0.5, "%s: «%s» mide %.0f" % [what, button.text, button.size.y])


# --- Menú principal ---

func test_mobile_main_menu_has_two_columns_and_tall_buttons() -> void:
	var menu: MainMenu = await _open_scene("res://scenes/ui/main_menu.tscn", UiMode.MOBILE) as MainMenu
	var logo: Control = menu.get_node("%Logo")
	var play: Button = menu.get_node("%PlayButton")
	assert_lt(logo.get_global_rect().end.x, play.get_global_rect().position.x + 1.0, "el logo a la izquierda y los botones a la derecha")
	var buttons: Array[Button] = _visible_buttons(menu)
	_assert_buttons_inside_window(buttons, "menú principal (celular)")
	_assert_min_height(buttons, 56.0, "menú principal (celular)")
	assert_true(WINDOW.encloses(logo.get_global_rect()), "el logo entra")


func test_mobile_main_menu_fits_with_the_editor_button_too() -> void:
	var menu: MainMenu = await _open_scene("res://scenes/ui/main_menu.tscn", UiMode.MOBILE) as MainMenu
	# El modo de pruebas muestra el editor también en el celular (RF-210): seis botones.
	(menu.get_node("%EditorButton") as Button).visible = true
	await get_tree().process_frame
	_assert_buttons_inside_window(_visible_buttons(menu), "menú principal con editor")


func test_pc_main_menu_is_the_same_single_column() -> void:
	var menu: MainMenu = await _open_scene("res://scenes/ui/main_menu.tscn", UiMode.PC) as MainMenu
	assert_null(menu.find_child("MobileColumns", true, false), "sin columnas en PC")
	assert_null(menu.find_child("MenuTouch", true, false), "sin ayuda táctil en PC")
	var logo: Control = menu.get_node("%Logo")
	var play: Button = menu.get_node("%PlayButton")
	assert_lt(logo.get_global_rect().end.y, play.get_global_rect().position.y + 1.0, "el logo arriba de los botones")
	assert_eq(play.size.y, 52.0, "los botones siguen en 52 px")


# --- Opciones ---

func test_mobile_options_fit_in_two_columns_with_back_in_view() -> void:
	var menu: MainMenu = await _open_scene("res://scenes/ui/main_menu.tscn", UiMode.MOBILE) as MainMenu
	var options: OptionsMenu = menu.get_node("%OptionsMenu")
	options.admin_available = true
	options.open()
	await get_tree().process_frame
	await get_tree().process_frame
	# Las filas del centro (casillas) se alcanzan desplazando: solo los botones fijos tienen que estar a la vista.
	var buttons: Array[Button] = _fixed_buttons(options)
	_assert_buttons_inside_window(buttons, "Opciones (celular)")
	_assert_min_height(_visible_buttons(options), 56.0, "Opciones (celular)")
	var panel: Control = options.get_node("%Panel")
	assert_true(WINDOW.encloses(panel.get_global_rect()), "el panel entra en la ventana: %s" % panel.get_global_rect())
	var scroll: ScrollContainer = options.get_node("%Scroll")
	assert_not_null(scroll.find_child("TouchScroller", false, false), "el centro se desplaza con el dedo")
	var selector: Control = options.find_child("UiModeSelector", true, false)
	assert_eq(selector.get_parent().name, &"OptionsPage4", "«Interfaz» está en Avanzado")
	assert_eq(options._tab_buttons.size(), 4, "el celular no muestra Controles")
	options._select_tab(2)
	var tutorial: Control = options.find_child("TutorialRow", true, false)
	assert_lt(tutorial.get_global_rect().end.y, scroll.get_global_rect().end.y + 1.0, "el tutorial se ve en su solapa")


func test_mobile_options_confirm_screen_fits_and_hides_the_rest() -> void:
	var menu: MainMenu = await _open_scene("res://scenes/ui/main_menu.tscn", UiMode.MOBILE) as MainMenu
	var options: OptionsMenu = menu.get_node("%OptionsMenu")
	options.admin_available = true
	options.open()
	(options.get_node("%AdminButton") as Button).pressed.emit()
	await get_tree().process_frame
	await get_tree().process_frame
	assert_true(options.is_confirm_visible())
	assert_false((options.get_node("%BackButton") as Control).visible)
	assert_false((options.get_node("%MusicSlider") as Control).is_visible_in_tree())
	_assert_buttons_inside_window(_visible_buttons(options), "confirmación (celular)")
	(options.get_node("%AdminCancelButton") as Button).pressed.emit()
	await get_tree().process_frame
	assert_true((options.get_node("%MusicSlider") as Control).is_visible_in_tree(), "al cancelar vuelve todo")


func test_pc_options_keep_one_column_and_scroll_when_too_tall() -> void:
	var menu: MainMenu = await _open_scene("res://scenes/ui/main_menu.tscn", UiMode.PC) as MainMenu
	var options: OptionsMenu = menu.get_node("%OptionsMenu")
	options.admin_available = true
	options.open()
	await get_tree().process_frame
	await get_tree().process_frame
	assert_null(options.find_child("Side", true, false), "una sola columna")
	var panel: Control = options.get_node("%Panel")
	assert_true(WINDOW.encloses(panel.get_global_rect()), "RF-555: entra en 720 de alto")
	assert_eq(panel.get_global_rect().size.x, 920.0, "el ancho alcanza para las cinco solapas")
	var back: Control = options.get_node("%BackButton")
	assert_true(WINDOW.encloses(back.get_global_rect()), "«Volver» a la vista")
	assert_null(options.find_child("TouchScroller", true, false), "sin desplazamiento táctil en PC")


func test_interface_selector_sits_in_advanced_before_back_in_pc() -> void:
	var menu: MainMenu = await _open_scene("res://scenes/ui/main_menu.tscn", UiMode.PC) as MainMenu
	var options: OptionsMenu = menu.get_node("%OptionsMenu")
	var page: Control = options.find_child("OptionsPage4", true, false)
	var names: Array[String] = []
	for child: Node in page.get_children():
		names.append(child.name)
	var selector: int = names.find("UiModeSelector")
	var admin: int = names.find("AdminSection")
	assert_eq(selector, names.find("UiModeLabel") + 1, "Interfaz aparece primero en Avanzado")
	assert_gt(admin, selector, "y va antes de «Administración»")
	assert_eq(options.get_node("%BackButton").get_parent().get_child(-1), options.get_node("%BackButton"), "«Volver» es lo último")


# --- Pausa ---

func test_mobile_pause_menu_has_tall_buttons_and_fits() -> void:
	var pause: PauseMenu = await _open_scene("res://scenes/ui/pause_menu.tscn", UiMode.MOBILE) as PauseMenu
	pause.open()
	await get_tree().process_frame
	await get_tree().process_frame
	var buttons: Array[Button] = _visible_buttons(pause)
	_assert_buttons_inside_window(buttons, "Pausa (celular)")
	_assert_min_height(buttons, 56.0, "Pausa (celular)")


# --- T314: las otras pantallas ---

func _assert_touch_screen(path: String, what: String) -> Node:
	var screen: Node = await _open_scene(path, UiMode.MOBILE)
	var buttons: Array[Button] = _visible_buttons(screen)
	_assert_buttons_inside_window(_fixed_buttons(screen), what)
	_assert_min_height(buttons, 56.0, what)
	for node: Node in screen.find_children("*", "ScrollContainer", true, false):
		assert_not_null(node.find_child("TouchScroller", false, false), "%s: cada lista se desplaza con el dedo" % what)
	return screen


func test_mobile_level_select_is_touch_ready() -> void:
	var screen: Node = await _assert_touch_screen("res://scenes/ui/level_select.tscn", "niveles")
	var scroll: ScrollContainer = screen.get_node("%Scroll")
	assert_not_null(scroll.find_child("TouchScroller", false, false))
	var content: Control = scroll.get_child(0) as Control
	if scroll.get_v_scroll_bar().visible:
		assert_almost_eq(content.size.x, scroll.size.x - 22.0, 0.5, "la barra de 22 px no tapa el borde de las tarjetas")
	assert_true((screen.get_node("%BackButton") as Button).is_visible_in_tree(), "Volver queda accesible")
	assert_true((screen.get_node("%StyleCards") as Button).is_visible_in_tree(), "se conserva el selector de vista")
	assert_true((screen.get_node("%StyleMap") as Button).is_visible_in_tree(), "se conserva el selector de mapa")
	assert_eq((screen.get_node("%CommunityTab") as Button).text, "Comunidad")
	assert_true((screen.find_child("NavigationRail", true, false) as Control).visible, "ancho suficiente: rail vertical")
	screen.call("show_page", &"community")
	await get_tree().process_frame
	assert_true((screen.get_node("%FolderButton") as Button).visible, "la acción para abrir mapas sigue disponible")
	var map_count: String = (screen.get_node("%TotalStars") as Label).text
	assert_true(map_count.ends_with("mapa") or map_count.ends_with("mapas"), "el conteo sigue en el indicador superior")


func test_narrow_mobile_level_select_uses_a_horizontal_navigation_row() -> void:
	_viewport.size = Vector2i(900, 720)
	var screen: Node = await _assert_touch_screen("res://scenes/ui/level_select.tscn", "niveles angosto")
	var rail: Control = screen.find_child("NavigationRail", true, false) as Control
	assert_true(rail.visible)
	assert_almost_eq(rail.size.x, 876.0, 1.0, "el rail se extiende arriba cuando falta ancho para la columna lateral; incluye los márgenes")
	var tab_scroll: ScrollContainer = screen.get_node("%TabScroll")
	assert_eq(tab_scroll.horizontal_scroll_mode, ScrollContainer.SCROLL_MODE_AUTO)
	assert_eq(tab_scroll.vertical_scroll_mode, ScrollContainer.SCROLL_MODE_DISABLED)


func test_mobile_wiki_is_touch_ready() -> void:
	var screen: Node = await _assert_touch_screen("res://scenes/ui/wiki_screen.tscn", "Wiki")
	var scrolls: Array[Node] = screen.find_children("*", "ScrollContainer", true, false)
	assert_gte(scrolls.size(), 2, "la lista y el detalle")


func test_mobile_records_are_touch_ready() -> void:
	await _assert_touch_screen("res://scenes/ui/records_screen.tscn", "Récords")


func test_mobile_credits_are_touch_ready() -> void:
	SaveManager.set_setting("ui_mode", UiMode.MOBILE)
	var credits := CreditsScreen.new()
	_viewport.add_child(credits)
	credits.open(PackedStringArray(["Línea 1", "Línea 2"]))
	await get_tree().process_frame
	await get_tree().process_frame
	_assert_min_height(_visible_buttons(credits), 56.0, "Créditos")
	assert_not_null(credits.find_child("TouchScroller", true, false), "los créditos largos se desplazan con el dedo")
	var long_lines := PackedStringArray()
	for i: int in 60:
		long_lines.append("Línea %d de los créditos" % i)
	credits.open(long_lines)
	await get_tree().process_frame
	await get_tree().process_frame
	_assert_buttons_inside_window(_visible_buttons(credits), "Créditos largos")


func test_pc_screens_get_no_touch_help() -> void:
	for path: String in ["res://scenes/ui/level_select.tscn", "res://scenes/ui/wiki_screen.tscn", "res://scenes/ui/records_screen.tscn"]:
		var screen: Node = await _open_scene(path, UiMode.PC)
		assert_null(screen.find_child("MenuTouch", true, false), "%s: nada cambia en PC" % path)
		assert_null(screen.find_child("TouchScroller", true, false), "%s: sin desplazamiento táctil en PC" % path)
		screen.queue_free()
		await get_tree().process_frame
