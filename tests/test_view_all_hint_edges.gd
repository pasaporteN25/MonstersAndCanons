# T464: casos de borde del aviso de «Ver todo» y de la ubicación del botón del celular (RF-674 a RF-676, D-192,
# D-207). Complementa a test_view_all_hint.gd. Nada acá cambia de escena ni toca el guardado real.
extends GutTest

const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")
const TEST_SAVE: String = "user://test_t464_view_all_edges.json"

var _viewport: SubViewport
var _game: Game
var _original_mode: Variant


func before_each() -> void:
	if FileAccess.file_exists(TEST_SAVE):
		DirAccess.remove_absolute(TEST_SAVE)
	SaveManager.save_path = TEST_SAVE
	SaveManager.load_save()
	_original_mode = SaveManager.get_setting("ui_mode")
	GameFlow.intro_pending = false
	DevMode.enabled = false
	_viewport = SubViewport.new()
	_viewport.size = Vector2i(1280, 720)
	add_child_autofree(_viewport)


func after_each() -> void:
	get_tree().paused = false
	Engine.time_scale = 1.0
	GameFlow.current_index = -1
	GameFlow.intro_pending = false
	DevMode.enabled = false
	SaveManager.set_setting("ui_mode", _original_mode)
	if FileAccess.file_exists(TEST_SAVE):
		DirAccess.remove_absolute(TEST_SAVE)
	SaveManager.save_path = SaveManager.DEFAULT_PATH
	SaveManager.load_save()


## Abre la partida del nivel `index` (0 = nivel 1, con tutorial) en el modo pedido.
func _open(mode: int, index: int) -> void:
	SaveManager.set_setting("ui_mode", mode)
	GameFlow.current_index = index
	_game = GAME_SCENE.instantiate() as Game
	_game.level_data = GameFlow.level(index)
	_viewport.add_child(_game)
	await get_tree().process_frame
	await get_tree().process_frame
	if _game.level_intro.is_open():
		_game.level_intro.close()


func _seen() -> bool:
	return SaveManager.get_ui_prefs().view_all_hint_seen


# --- (a) Con el tutorial activo el aviso no sale ---

func test_notice_does_not_show_while_the_tutorial_is_active() -> void:
	await _open(UiMode.PC, 0)
	assert_not_null(_game.tutorial, "el nivel 1 sin tutorial hecho lo arma")
	assert_true(_game.tutorial.is_active())
	_game._on_view_zoomed_in()
	assert_false(_game.hud._view_all_notice.visible, "con el tutorial activo no hay aviso")
	assert_false(_seen(), "y no se gasta la única vez: queda «no visto»")


func test_notice_does_not_show_on_the_phone_while_the_tutorial_is_active() -> void:
	await _open(UiMode.MOBILE, 0)
	assert_true(_game.tutorial.is_active())
	_game._on_view_zoomed_in()
	assert_false(_game.hud._view_all_notice.visible)
	assert_false(_seen())


func test_notice_shows_once_the_tutorial_is_skipped() -> void:
	await _open(UiMode.PC, 0)
	_game._on_view_zoomed_in()
	assert_false(_seen())
	_game.tutorial.overlay.skip_button().pressed.emit()
	await get_tree().process_frame
	assert_false(_game.tutorial.is_active())
	_game._on_view_zoomed_in()
	assert_true(_game.hud._view_all_notice.visible, "terminado el tutorial el aviso vuelve a poder salir")
	assert_true(_seen())


# --- (b) Desplazar y después acercar ---

func test_pan_then_zoom_in_shows_the_notice_only_at_the_zoom() -> void:
	await _open(UiMode.MOBILE, 14)
	var controller: CameraController = _game.camera_controller
	controller._pan_by_screen_delta(Vector2(60.0, 0.0))
	controller._pan_by_screen_delta(Vector2(0.0, 40.0))
	assert_false(_game.hud._view_all_notice.visible, "desplazar no muestra el aviso")
	assert_false(_seen(), "ni gasta la única vez")
	controller._zoom_at(Vector2(640.0, 360.0), 1.3)
	assert_true(_game.hud._view_all_notice.visible, "al acercar, recién ahí, aparece")
	assert_eq(_game.hud._view_all_notice.text, "Acercaste el mapa. Tocá la lupa para volver a verlo entero.")
	assert_true(_seen())


# --- (c) El botón del celular no tapa carrito, X ni demolición (posiciones por omisión) ---

func test_default_view_all_button_does_not_overlap_the_other_floating_buttons() -> void:
	await _open(UiMode.MOBILE, 14)
	var hud: MobileHud = _game.mobile_hud
	var view_all: Button = hud._view_all_button
	var view_all_rect := Rect2(view_all.position, view_all.size)
	assert_gt(view_all_rect.size.x, 0.0, "el botón ya tiene tamaño")
	for button: Button in [hud._cart_button, hud._exit_button, hud._demolish_button]:
		var rect := Rect2(button.position, button.size)
		assert_gt(rect.size.x, 0.0, "%s tiene tamaño" % button.name)
		assert_false(view_all_rect.intersects(rect), "«Ver todo» no pisa %s" % button.name)
