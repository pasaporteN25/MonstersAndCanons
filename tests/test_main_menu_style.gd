# Tests del logo y del acabado de los botones del menú principal (M24, RF-331, RF-332).
# Cómo SE VE se revisa con capturas; acá se prueba lo que se puede medir.
extends GutTest

const MENU_SCENE: PackedScene = preload("res://scenes/ui/main_menu.tscn")
const THEME: Theme = preload("res://assets/ui/menu_theme.tres")
const STATES: Array[String] = ["normal", "hover", "pressed", "hover_pressed", "disabled"]


func _menu() -> Control:
	var menu: Control = MENU_SCENE.instantiate()
	add_child_autofree(menu)
	return menu


## Luminancia relativa (WCAG) de un color.
func _luminance(color: Color) -> float:
	var channels: Array[float] = []
	for value: float in [color.r, color.g, color.b]:
		channels.append(value / 12.92 if value <= 0.03928 else pow((value + 0.055) / 1.055, 2.4))
	return 0.2126 * channels[0] + 0.7152 * channels[1] + 0.0722 * channels[2]


func _contrast(a: Color, b: Color) -> float:
	var la: float = _luminance(a)
	var lb: float = _luminance(b)
	return (maxf(la, lb) + 0.05) / (minf(la, lb) + 0.05)


func test_logo_replaces_the_old_titles() -> void:
	var menu: Control = _menu()
	var logo: TextureRect = menu.get_node("%Logo")
	assert_not_null(logo.texture)
	assert_eq(logo.texture.resource_path, "res://assets/ui/logo.png")
	assert_eq(logo.stretch_mode, TextureRect.STRETCH_KEEP_ASPECT_CENTERED, "conserva la proporción")
	var rows: Node = menu.get_node("Center/Rows")
	assert_null(rows.find_child("Title", true, false), "ya no está el título de texto")
	assert_null(rows.find_child("Subtitle", true, false), "ya no está el subtítulo")
	for label: Node in rows.find_children("*", "Label", true, false):
		assert_false((label as Label).text.contains("JuegoA"))


func test_logo_keeps_alpha_and_a_sensible_size() -> void:
	var image: Image = (load("res://assets/ui/logo.png") as Texture2D).get_image()
	assert_eq(image.get_width(), 1024)
	assert_true(image.detect_alpha() != Image.ALPHA_NONE, "conserva el alfa")
	assert_lt(image.get_pixel(0, 0).a, 0.01, "la esquina es transparente")
	assert_gt(image.get_height(), 400)


func test_logo_height_shrinks_when_the_window_is_short() -> void:
	assert_eq(MainMenu.logo_height(720.0, 6), MainMenu.LOGO_MAX_HEIGHT, "con 720 de alto, el máximo")
	assert_lt(MainMenu.logo_height(600.0, 6), MainMenu.LOGO_MAX_HEIGHT, "más bajo, se achica")
	assert_eq(MainMenu.logo_height(100.0, 6), MainMenu.LOGO_MIN_HEIGHT, "nunca desaparece")
	assert_gt(MainMenu.logo_height(720.0, 5), MainMenu.logo_height(600.0, 5))
	assert_gte(MainMenu.logo_height(560.0, 6), MainMenu.LOGO_MIN_HEIGHT)


func test_logo_and_buttons_fit_in_the_screen_without_overlap() -> void:
	var menu: Control = _menu()
	await wait_process_frames(3)
	var rows: Control = menu.get_node("Center/Rows")
	var screen := Rect2(Vector2.ZERO, menu.size)
	assert_true(screen.encloses(rows.get_global_rect()), "todo entra en la pantalla")
	var logo: Control = menu.get_node("%Logo")
	var play: Control = menu.get_node("%PlayButton")
	assert_lte(logo.get_global_rect().end.y, play.get_global_rect().position.y, "el logo no tapa los botones")


func test_buttons_have_iron_bronze_style_and_amber_accent() -> void:
	var normal: StyleBoxFlat = THEME.get_stylebox("normal", "Button")
	var hover: StyleBoxFlat = THEME.get_stylebox("hover", "Button")
	var focus: StyleBoxFlat = THEME.get_stylebox("focus", "Button")
	assert_lt(normal.bg_color.v, 0.2, "hierro oscuro")
	assert_gt(normal.border_color.r, normal.border_color.b, "borde de bronce (más rojo que azul)")
	assert_gt(normal.border_width_bottom, normal.border_width_top, "relieve: borde de abajo más grueso")
	assert_ne(hover.border_color, normal.border_color, "el hover se distingue")
	assert_gt(hover.border_color.r, 0.9, "acento ámbar")
	assert_gt(hover.border_color.g, hover.border_color.b + 0.4)
	assert_false(focus.draw_center, "el foco es un contorno, no tapa el texto")
	assert_gt(focus.border_color.r, 0.9, "el foco también es ámbar")
	for state: String in STATES:
		assert_not_null(THEME.get_stylebox(state, "Button"), state)


func test_button_text_has_enough_contrast() -> void:
	# RF-332: 4,5:1 contra el fondo de cada estado (el desactivado, 3:1, como pide WCAG para lo inactivo).
	var pairs: Array = [["normal", "font_color", 4.5], ["hover", "font_hover_color", 4.5],
		["pressed", "font_pressed_color", 4.5], ["hover_pressed", "font_hover_pressed_color", 4.5],
		["disabled", "font_disabled_color", 3.0]]
	var backdrop := Color(0.07, 0.08, 0.1)  # el fondo oscuro del menú, para el fondo semitransparente
	for pair: Array in pairs:
		var box: StyleBoxFlat = THEME.get_stylebox(pair[0], "Button")
		var text: Color = THEME.get_color(pair[1], "Button")
		var background: Color = backdrop.lerp(Color(box.bg_color, 1.0), box.bg_color.a)
		assert_gte(_contrast(text, background), pair[2], "%s: contraste" % pair[0])
	var focus_text: Color = THEME.get_color("font_focus_color", "Button")
	assert_gte(_contrast(focus_text, THEME.get_stylebox("normal", "Button").bg_color), 4.5, "texto con foco")


func test_menu_buttons_use_the_theme_and_stay_keyboard_navigable() -> void:
	var menu: Control = _menu()
	await wait_process_frames(2)
	var rows: Control = menu.get_node("Center/Rows")
	assert_eq(rows.theme, THEME, "el tema es solo del menú")
	var play: Button = menu.get_node("%PlayButton")
	assert_true(play.has_focus(), "Jugar tiene el foco al abrir")
	var previous: Button = null
	for button: Button in rows.find_children("*", "Button", true, false):
		if not button.visible:
			continue
		assert_ne(button.focus_mode, Control.FOCUS_NONE, "%s: se puede enfocar" % button.text)
		assert_gte(button.size.y, 50.0, "%s: alto cómodo" % button.text)
		assert_gt(button.get_theme_font_size("font_size"), 20, "%s: texto legible" % button.text)
		if previous != null:
			assert_eq(previous.find_valid_focus_neighbor(SIDE_BOTTOM), button, "flecha abajo va al siguiente")
		previous = button


func test_theme_is_not_applied_to_the_rest_of_the_game() -> void:
	assert_null(ThemeDB.get_project_theme(), "no hay tema global")
	var plain := Button.new()
	add_child_autofree(plain)
	assert_ne(plain.get_theme_stylebox("normal"), THEME.get_stylebox("normal", "Button"))
