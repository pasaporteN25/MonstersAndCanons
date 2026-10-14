# Tests de la pantalla Wiki (T112, RF-230 a RF-232). La pantalla no cambia de escena: `on_leave`
# es una costura que los tests reemplazan.
extends GutTest

const SCREEN: PackedScene = preload("res://scenes/ui/wiki_screen.tscn")

var screen: Control
var left: int = 0


func before_each() -> void:
	left = 0
	screen = SCREEN.instantiate()
	screen.on_leave = func() -> void: left += 1
	screen.is_seen = func(_id: StringName) -> bool: return true  # sin depender del guardado real
	add_child_autofree(screen)
	await wait_physics_frames(1)


func _action(name: StringName) -> InputEventAction:
	var event := InputEventAction.new()
	event.action = name
	event.pressed = true
	return event


# --- Solapas y lista ---

func test_it_has_one_tab_per_category_and_starts_on_enemies() -> void:
	assert_eq(screen.category_ids(), [&"enemigos", &"torres", &"colecciones", &"guia", &"lore"] as Array[StringName])
	assert_eq(screen.current_category(), &"enemigos")
	assert_eq(screen.tab_text(&"torres"), "Torres")
	assert_eq(screen.entry_ids().size(), LevelFile.enemy_ids().size())


func test_the_first_entry_is_shown_at_the_start() -> void:
	assert_ne(screen.current_entry(), &"")
	assert_eq(screen.current_entry(), screen.entry_ids()[0])
	assert_gt(screen.detail_text().length(), 20)


func test_changing_category_changes_the_list_and_the_detail() -> void:
	screen.show_category(&"torres")
	assert_eq(screen.current_category(), &"torres")
	assert_true(screen.entry_ids().has(&"cannon"))
	assert_false(screen.entry_ids().has(&"boss"))
	assert_eq(screen.current_entry(), screen.entry_ids()[0], "abre la primera entrada")


func test_an_unknown_category_or_entry_does_nothing() -> void:
	screen.show_category(&"no_existe")
	assert_eq(screen.current_category(), &"enemigos")
	var before: StringName = screen.current_entry()
	screen.show_entry(&"no_existe")
	assert_eq(screen.current_entry(), before)


# --- El detalle ---

func test_an_enemy_shows_its_data() -> void:
	screen.show_target(&"enemigos", &"boss")
	var boss: EnemyData = load("res://data/enemies/boss.tres")
	var text: String = screen.detail_text()
	assert_string_contains(text, boss.display_name)
	assert_string_contains(text, str(boss.max_health))
	assert_string_contains(text, "Peligroso")
	assert_string_contains(text, "Dónde aparece")


func test_a_tower_shows_its_level_table() -> void:
	screen.show_target(&"torres", &"cannon")
	var text: String = screen.detail_text()
	assert_string_contains(text, "Cañón")
	assert_string_contains(text, "1 (construir)")
	assert_string_contains(text, "3 (mejorar)")
	assert_string_contains(text, "Daño/s")


func test_an_article_shows_headings_and_paragraphs() -> void:
	screen.show_target(&"guia", &"armadura_y_dano")
	var text: String = screen.detail_text()
	assert_string_contains(text, "Armadura y daño")
	assert_string_contains(text, "El fuego ignora la armadura")


func test_the_keys_article_draws_its_table() -> void:
	screen.show_target(&"guia", &"teclas")
	assert_string_contains(screen.detail_text(), "Espacio")


func test_the_detail_is_rebuilt_and_not_piled_up() -> void:
	screen.show_target(&"torres", &"basic")
	var first: int = screen.detail_text().length()
	for i: int in 5:
		screen.show_entry(&"basic")
	assert_eq(screen.detail_text().length(), first)
	await wait_physics_frames(1)
	assert_eq(screen.detail_text().length(), first)


func test_every_entry_of_every_category_can_be_shown() -> void:
	for category_id: StringName in screen.category_ids():
		screen.show_category(category_id)
		for entry_id: StringName in screen.entry_ids():
			screen.show_entry(entry_id)
			assert_eq(screen.current_entry(), entry_id)
			assert_string_contains(screen.detail_text(), "\n", "%s sin contenido" % entry_id)


# --- Botones y teclado ---

func test_clicking_a_tab_and_an_entry_works() -> void:
	var tabs: Array = screen.find_children("*", "Button", true, false).filter(func(b: Node) -> bool: return (b as Button).text == "Torres")
	assert_eq(tabs.size(), 1)
	(tabs[0] as Button).pressed.emit()
	assert_eq(screen.current_category(), &"torres")
	var buttons: Array = screen.find_children("*", "Button", true, false).filter(func(b: Node) -> bool: return (b as Button).toggle_mode and (b as Button).get_child_count() > 0)
	assert_eq(buttons.size(), screen.entry_ids().size())
	(buttons[2] as Button).pressed.emit()
	assert_eq(screen.current_entry(), screen.entry_ids()[2])


func test_left_and_right_switch_category_and_wrap_around() -> void:
	screen._unhandled_input(_action(&"ui_right"))
	assert_eq(screen.current_category(), &"torres")
	screen._unhandled_input(_action(&"ui_right"))
	screen._unhandled_input(_action(&"ui_right"))
	screen._unhandled_input(_action(&"ui_right"))  # T211: hay una solapa más (Colecciones)
	screen._unhandled_input(_action(&"ui_right"))  # T228 (RF-469): y otra, Lore
	assert_eq(screen.current_category(), &"enemigos", "da la vuelta")
	screen._unhandled_input(_action(&"ui_left"))
	assert_eq(screen.current_category(), &"lore")


func test_escape_and_back_leave() -> void:
	screen._unhandled_input(_action(&"cancel"))
	assert_eq(left, 1)
	var back: Array = screen.find_children("*", "Button", true, false).filter(func(b: Node) -> bool: return (b as Button).text == "Volver")
	(back[0] as Button).pressed.emit()
	assert_eq(left, 2)


func test_the_main_menu_has_the_wiki_button() -> void:
	var menu: Control = load("res://scenes/ui/main_menu.tscn").instantiate()
	add_child_autofree(menu)
	var button: Button = menu.get_node("%WikiButton")
	assert_eq(button.text, "Wiki")
	assert_true(button.visible)
	assert_true(button.pressed.is_connected(GameFlow.go_to_wiki))
