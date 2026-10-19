# «Novedades de esta versión» en el menú principal y en Opciones (M67, RF-603, RF-607, RF-608, T373). Todo por las
# costuras del menú (ruta del archivo, versión, bandera del editor): no se toca `config/version` ni se cambia de
# escena, y el guardado es uno de prueba.
extends GutTest

const TEST_SAVE: String = "user://test_news_menu.json"
const NEWS_FILE: String = "user://test_news_menu_novedades.json"
const MENU_SCENE: PackedScene = preload("res://scenes/ui/main_menu.tscn")
const WINDOW: Rect2 = Rect2(0.0, 0.0, 1280.0, 720.0)

var _viewport: SubViewport


func before_each() -> void:
	_cleanup()
	SaveManager.save_path = TEST_SAVE
	SaveManager.load_save()
	DevMode.enabled = false
	_viewport = SubViewport.new()
	_viewport.size = Vector2i(1280, 720)
	add_child_autofree(_viewport)


func after_each() -> void:
	DevMode.enabled = false
	SaveManager.set_setting("ui_mode", UiMode.AUTOMATIC)
	_cleanup()
	SaveManager.save_path = SaveManager.DEFAULT_PATH
	SaveManager.load_save()


func _cleanup() -> void:
	for path: String in [TEST_SAVE, NEWS_FILE]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)


func _write_news(draft: bool, kind: String = "presentacion", id: String = "1.0.0", count: int = 3) -> void:
	var items: Array = []
	for i: int in count:
		items.append({"titulo": "Novedad %d" % (i + 1), "texto": "Texto %d." % (i + 1)})
	var raw: Dictionary = {"version": 1, "interfaz": {"entendido": "Entendido", "titulo_novedades": "Novedades de esta versión",
		"titulo_mejoras": "Mejoras de esta versión", "borrador": "Borrador", "sin_novedades": "No hay novedades"},
		"versiones": [{"id": id, "tipo": kind, "borrador": draft, "titulo": "Monsters & Canons", "novedades": items}]}
	var file := FileAccess.open(NEWS_FILE, FileAccess.WRITE)
	file.store_string(JSON.stringify(raw))
	file.close()


func _menu(version: String, in_editor: bool = false, path: String = NEWS_FILE) -> MainMenu:
	var menu: MainMenu = MENU_SCENE.instantiate() as MainMenu
	menu.news_path = path
	menu.news_version_source = func() -> String: return version
	menu.news_in_editor = in_editor
	menu.intro_path = "res://no/existe.json"
	_viewport.add_child(menu)
	return menu


# --- El menú principal (RF-603) ---

func test_shows_once_for_an_old_save_and_marks_the_version_on_opening() -> void:
	_write_news(false)
	SaveManager.record_victory(&"level_01", 20, 100)  # un guardado viejo, con progreso
	SaveManager.save()
	var menu: MainMenu = _menu("1.0.0")
	assert_true(menu.news_screen.is_open(), "sale sola")
	assert_eq(SaveManager.news_version_seen(), "1.0.0", "se marca al abrirse")
	assert_eq(int(JSON.parse_string(FileAccess.get_file_as_string(TEST_SAVE))["version"]), 1)
	assert_eq(String(JSON.parse_string(FileAccess.get_file_as_string(TEST_SAVE))["news_version"]), "1.0.0")
	menu.news_screen.close()
	menu.queue_free()
	var again: MainMenu = _menu("1.0.0")
	assert_false(again.news_screen.is_open(), "la segunda vez no sale")


func test_presentation_also_shows_to_a_brand_new_save() -> void:
	_write_news(false)
	var menu: MainMenu = _menu("1.0.0")
	assert_true(menu.news_screen.is_open())


func test_beta_never_shows() -> void:
	_write_news(false)
	var menu: MainMenu = _menu("beta")
	assert_false(menu.news_screen.is_open())
	assert_eq(SaveManager.news_version_seen(), "", "y no marca nada")


func test_draft_never_shows_on_its_own() -> void:
	_write_news(true)
	var menu: MainMenu = _menu("1.0.0")
	assert_false(menu.news_screen.is_open())
	assert_eq(SaveManager.news_version_seen(), "")


func test_dev_mode_and_editor_never_show_and_do_not_mark() -> void:
	_write_news(false)
	DevMode.enabled = true
	var dev_menu: MainMenu = _menu("1.0.0")
	assert_false(dev_menu.news_screen.is_open(), "modo de pruebas")
	DevMode.enabled = false
	var editor_menu: MainMenu = _menu("1.0.0", true)
	assert_false(editor_menu.news_screen.is_open(), "editor de Godot")
	assert_eq(SaveManager.news_version_seen(), "")


func test_improvements_for_a_new_save_are_marked_silently() -> void:
	_write_news(false, "mejoras", "1.1.0")
	var menu: MainMenu = _menu("1.1.0")
	assert_false(menu.news_screen.is_open())
	assert_eq(SaveManager.news_version_seen(), "1.1.0", "queda marcada sin mostrarse")


func test_improvements_for_an_old_save_show() -> void:
	_write_news(false, "mejoras", "1.1.0")
	SaveManager.record_victory(&"level_01", 20, 100)  # un guardado con progreso
	SaveManager.mark_news_seen("1.0.0")
	var menu: MainMenu = _menu("1.1.0")
	assert_true(menu.news_screen.is_open())


func test_broken_or_missing_file_opens_the_menu_normally() -> void:
	var missing: MainMenu = _menu("1.0.0", false, "user://no_existe_novedades.json")
	assert_false(missing.news_screen.is_open())
	assert_eq(SaveManager.news_version_seen(), "")
	var file := FileAccess.open(NEWS_FILE, FileAccess.WRITE)
	file.store_string("{ roto")
	file.close()
	var broken: MainMenu = _menu("1.0.0")
	assert_false(broken.news_screen.is_open())
	assert_true((broken.get_node("%PlayButton") as Button).visible, "el menú abre como siempre")


func test_the_official_file_shows_nothing_with_the_real_beta_version() -> void:
	var menu: MainMenu = MENU_SCENE.instantiate() as MainMenu
	menu.news_in_editor = false
	_viewport.add_child(menu)
	assert_false(menu.news_screen.is_open(), "el archivo oficial no sale mientras la versión sea beta o no haya entrada aprobada")


# --- Opciones (RF-607) ---

func _options(version: String, path: String = NEWS_FILE) -> OptionsMenu:
	var menu: MainMenu = _menu("beta", true)
	var options: OptionsMenu = menu.get_node("%OptionsMenu")
	options.news_path = path
	options.news_version_source = func() -> String: return version
	options.open()
	return options


func test_options_button_opens_the_installed_version_without_touching_the_save() -> void:
	_write_news(true)
	var options: OptionsMenu = _options("beta")
	var button: Button = options.news_button()
	assert_false(button.disabled)
	assert_eq(button.text, "Novedades de esta versión")
	button.pressed.emit()
	assert_true(options.news.is_open(), "con beta abre la más nueva del archivo")
	assert_not_null(options.news.find_child("DraftTag", true, false), "y dice que es borrador")
	assert_eq(SaveManager.news_version_seen(), "", "no marca nada")
	options.news.close()
	assert_eq(SaveManager.news_version_seen(), "")


func test_options_button_is_disabled_when_the_file_fails_or_is_empty() -> void:
	var broken: OptionsMenu = _options("1.0.0", "user://no_existe_novedades.json")
	assert_true(broken.news_button().disabled)
	assert_eq(broken.news_button().text, "No hay novedades")


func test_options_button_comes_right_below_the_credits_button() -> void:
	_write_news(false)
	var options: OptionsMenu = _options("1.0.0")
	var credits: Button = options.get_node("%CreditsButton")
	assert_eq(options.news_button().get_parent(), credits.get_parent())
	assert_eq(options.news_button().get_index(), credits.get_index() + 1)


func test_mobile_options_still_fit_with_the_news_button() -> void:
	SaveManager.set_setting("ui_mode", UiMode.MOBILE)
	_write_news(false)
	var options: OptionsMenu = _options("1.0.0")
	options.admin_available = true
	options.open()
	await get_tree().process_frame
	await get_tree().process_frame
	var panel: Control = options.get_node("%Panel")
	assert_true(WINDOW.encloses(panel.get_global_rect()), "el panel entra en 720: %s" % panel.get_global_rect())
	assert_gte(options.news_button().size.y, 55.5, "el botón respeta el mínimo táctil")
	assert_true(options.news_button().is_visible_in_tree())
