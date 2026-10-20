# Tests del efecto y del texto de mejora de torres (M65, T363, RF-590 a RF-596).
# Partida real: en PC dentro del árbol de GUT y en modo celular dentro de un SubViewport de 1280 × 720.
extends GutTest

const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")
const OPTIONS_SCENE: PackedScene = preload("res://scenes/ui/options_menu.tscn")
const TEST_SAVE: String = "user://test_upgrade_fx.json"

var _viewport: SubViewport
var game: Game
var _original_mode: Variant
var _original_path: String


func before_each() -> void:
	_original_path = SaveManager.save_path
	SaveManager.save_path = TEST_SAVE
	SaveManager.load_save()  # opciones por defecto: animaciones de mejora prendidas
	_original_mode = SaveManager.get_setting("ui_mode")


func after_each() -> void:
	Engine.time_scale = 1.0
	get_tree().paused = false
	SaveManager.set_setting("ui_mode", _original_mode)
	if FileAccess.file_exists(TEST_SAVE):
		DirAccess.remove_absolute(TEST_SAVE)
	SaveManager.save_path = _original_path
	SaveManager.load_save()


func _start_pc() -> void:
	SaveManager.set_setting("ui_mode", UiMode.PC)
	game = GAME_SCENE.instantiate() as Game
	add_child_autofree(game)
	await get_tree().process_frame
	game.session.earn(100000)


func _start_mobile() -> void:
	SaveManager.set_setting("ui_mode", UiMode.MOBILE)
	_viewport = SubViewport.new()
	_viewport.size = Vector2i(1280, 720)
	add_child_autofree(_viewport)
	game = GAME_SCENE.instantiate() as Game
	_viewport.add_child(game)
	await get_tree().process_frame
	await get_tree().process_frame
	game.session.earn(100000)


## Construye la primera torre posible de `data` en una casilla que cumpla `accept`.
func _build(data: TowerData, accept: Callable = Callable()) -> Tower:
	for y: int in game.level.map_size().y:
		for x: int in game.level.map_size().x:
			var cell := Vector2i(x, y)
			if accept.is_valid() and not accept.call(cell):
				continue
			if game.level.is_buildable(cell) and game.build_controller.cells_free(data, cell) \
					and game.build_controller.try_build(data, cell):
				return game.build_controller.tower_at(cell)
	return null


func _children_of(type_check: Callable) -> Array[Node]:
	var found: Array[Node] = []
	for child: Node in game.effects.get_children():
		if not child.is_queued_for_deletion() and type_check.call(child):
			found.append(child)
	return found


func _effects() -> Array[Node]:
	return _children_of(func(node: Node) -> bool: return node is UpgradeEffect)


func _texts() -> Array[Node]:
	return _children_of(func(node: Node) -> bool: return node is FloatingText)


func _rings() -> Array[Node]:
	return _children_of(func(node: Node) -> bool: return node is RingEffect)


func _tower_data(id: String) -> TowerData:
	for data: TowerData in game.tower_types:
		if data.id == id:
			return data
	return null


# --- RF-590: el efecto ---

func test_upgrading_shows_the_refuerzo_in_the_tower_color_and_the_text_with_the_deltas() -> void:
	await _start_pc()
	var tower: Tower = _build(_tower_data("basic"))
	var rings_before: int = _rings().size()
	var gold_before: int = game.session.gold
	assert_true(game.build_controller.try_upgrade(tower))
	assert_eq(game.session.gold, gold_before - tower.stats().cost, "el oro es el de siempre")
	assert_eq(tower.level_number(), 2)
	var effects: Array[Node] = _effects()
	assert_eq(effects.size(), 1)
	var effect := effects[0] as UpgradeEffect
	assert_false(effect.is_mastery())
	assert_almost_eq(effect.duration(), 0.5, 0.0001)
	assert_eq(effect._color, TowerVisual.upgrade_glow_color(&"basic"))
	assert_eq(_rings().size(), rings_before, "reemplaza al anillo de construir: no se suma otro")
	var texts: Array[String] = []
	for node: Node in _texts():
		texts.append((node as FloatingText)._text)
	assert_eq(texts, ["¡Nivel 2!", "+3 daño · +0,5 disp/s"] as Array[String])
	assert_false(" ".join(texts).contains("alcance"), "el alcance no cambió")


func test_the_last_level_is_the_big_mastery_and_says_max_level() -> void:
	await _start_pc()
	var tower: Tower = _build(_tower_data("tesla"))
	game.build_controller.try_upgrade(tower)
	var refuerzo := _effects()[0] as UpgradeEffect
	var small_radius: float = refuerzo.radius()
	refuerzo.free()
	for node: Node in _texts():
		node.free()
	assert_true(game.build_controller.try_upgrade(tower))
	var effect := _effects()[0] as UpgradeEffect
	assert_true(effect.is_mastery())
	assert_almost_eq(effect.duration(), 0.7, 0.0001)
	assert_gt(effect.radius(), small_radius, "la maestría es visiblemente más grande")
	assert_eq(effect._color, Color(0.75, 0.4, 1.0), "la Tesla se tiñe de violeta")
	var texts: Array[String] = []
	for node: Node in _texts():
		texts.append((node as FloatingText)._text)
	assert_eq(texts, ["¡Nivel máximo!", "+8 daño · +0,1 disp/s", "+1 saltos · +0,5 alcance"] as Array[String])


func test_a_big_tower_gets_a_bigger_effect() -> void:
	await _start_pc()
	var small: Tower = _build(_tower_data("basic"))
	game.build_controller.try_upgrade(small)
	var small_effect := _effects()[0] as UpgradeEffect
	# Una torre de prueba de 2×2 con los números de la Ametralladora (el Mortero no está en todos los niveles).
	var big_data: TowerData = _tower_data("basic").duplicate() as TowerData
	big_data.footprint = 2
	var big: Tower = _build(big_data)
	assert_not_null(big, "cabe un 2×2")
	game.build_controller.try_upgrade(big)
	var big_effect: UpgradeEffect = null
	for node: Node in _effects():
		if node != small_effect:
			big_effect = node as UpgradeEffect
	assert_almost_eq(big_effect.radius(), small_effect.radius() * 2.0, 0.01, "se adapta al tamaño (footprint 2)")


func test_everything_disappears_by_itself_within_a_second_and_a_bit() -> void:
	await _start_pc()
	var layer_children_before: int = game.effects.get_child_count()
	var tower: Tower = _build(_tower_data("basic"))
	game.build_controller.try_upgrade(tower)
	assert_gt(game.effects.get_child_count(), layer_children_before)
	await get_tree().create_timer(1.35).timeout
	assert_eq(_effects().size(), 0)
	assert_eq(_texts().size(), 0)
	assert_eq(game.effects.upgrade_fx_alive(), 0, "la cuenta vuelve a cero")


func test_the_effect_has_no_per_frame_work() -> void:
	await _start_pc()
	var tower: Tower = _build(_tower_data("basic"))
	game.build_controller.try_upgrade(tower)
	assert_false((_effects()[0] as UpgradeEffect).is_processing(), "sin _process: solo trabaja el Tween mientras dura")
	assert_eq(_effects()[0].get_child_count(), 1, "un solo Sprite2D con el atlas, sin partículas")
	await get_tree().create_timer(1.35).timeout
	assert_eq(_effects().size() + _texts().size(), 0, "sin animación no queda nada vivo")


func test_pause_freezes_the_effect_and_resuming_continues_it() -> void:
	await _start_pc()
	var tower: Tower = _build(_tower_data("basic"))
	game.build_controller.try_upgrade(tower)
	var effect := _effects()[0] as UpgradeEffect
	# Con la máquina cargada 0,1 s reales pueden no alcanzar para un cuadro: se espera a que avance de verdad.
	var guard: int = 0
	while effect.progress <= 0.0 and guard < 120:
		await get_tree().process_frame
		guard += 1
	game.set_paused(true)
	var frozen_at: float = effect.progress
	assert_gt(frozen_at, 0.0)
	await get_tree().create_timer(0.2, true).timeout
	assert_almost_eq(effect.progress, frozen_at, 0.0001, "en pausa se congela")
	game.set_paused(false)
	await get_tree().create_timer(0.1).timeout
	assert_gt(effect.progress, frozen_at, "al reanudar sigue")


func test_a_second_upgrade_while_it_lasts_replaces_the_first_one() -> void:
	await _start_pc()
	var tower: Tower = _build(_tower_data("basic"))
	game.build_controller.try_upgrade(tower)
	game.build_controller.try_upgrade(tower)
	assert_eq(_effects().size(), 1, "una torre no acumula")
	assert_true((_effects()[0] as UpgradeEffect).is_mastery())
	assert_eq(_texts().size(), 3, "y tampoco textos: cabecera y dos renglones, no seis")


func test_at_most_eight_effects_at_a_time() -> void:
	await _start_pc()
	var towers: Array[Tower] = []
	for _i: int in 10:
		var tower: Tower = _build(_tower_data("basic"))
		if tower == null:
			break
		towers.append(tower)
	assert_gte(towers.size(), 9, "el mapa tiene lugar para 9 torres")
	var rings_before: int = _rings().size()
	for tower: Tower in towers:
		game.build_controller.try_upgrade(tower)
	assert_lte(_effects().size(), 8, "tope de efectos vivos")
	assert_eq(_effects().size(), 8)
	assert_lte(_texts().size(), 4 * 3, "los textos tienen un tope más bajo: saltean primero el texto")
	assert_gt(_rings().size(), rings_before, "las que no entran caen al anillo de siempre")


# --- RF-593: la opción ---

func test_with_the_option_off_only_the_old_ring_and_the_sound_remain() -> void:
	await _start_pc()
	SaveManager.set_setting("upgrade_fx", false)
	var tower: Tower = _build(_tower_data("basic"))
	var rings_before: int = _rings().size()
	assert_true(game.build_controller.try_upgrade(tower))
	assert_eq(tower.level_number(), 2, "el nivel sube igual")
	assert_eq(_effects().size(), 0)
	assert_eq(_texts().size(), 0)
	assert_eq(_rings().size(), rings_before + 1, "el anillo de siempre (RF-75)")


func test_the_option_is_independent_from_the_damage_numbers() -> void:
	await _start_pc()
	SaveManager.set_setting("damage_numbers", false)
	var tower: Tower = _build(_tower_data("basic"))
	game.build_controller.try_upgrade(tower)
	assert_eq(_effects().size(), 1, "sin números de daño igual sale la mejora")
	SaveManager.set_setting("damage_numbers", true)
	SaveManager.set_setting("upgrade_fx", false)
	var other: Tower = _build(_tower_data("basic"))
	var before: int = _effects().size()
	game.build_controller.try_upgrade(other)
	assert_eq(_effects().size(), before, "apagar la mejora no toca los números")
	assert_true(game.effects.damage_number(Vector2.ZERO, 5, false), "los números de daño siguen")


# --- RF-596: cuándo NO sale ---

func test_nothing_on_build_sell_or_a_failed_upgrade() -> void:
	await _start_pc()
	var tower: Tower = _build(_tower_data("basic"))
	assert_eq(_effects().size(), 0, "construir no hace el efecto de mejora")
	game.session.set_gold(0)
	assert_false(game.build_controller.try_upgrade(tower), "sin oro no mejora")
	assert_eq(_effects().size() + _texts().size(), 0)
	game.session.earn(100000)
	game.build_controller.try_upgrade(tower)
	game.build_controller.try_upgrade(tower)
	for node: Node in _effects() + _texts():
		node.free()
	assert_false(game.build_controller.try_upgrade(tower), "nivel máximo")
	assert_eq(_effects().size() + _texts().size(), 0)
	game.build_controller.sell(tower)
	assert_eq(_effects().size(), 0, "vender tampoco")
	for node: Node in _texts():
		assert_false((node as FloatingText)._text.begins_with("¡"), "ni cabecera de nivel al vender")


# --- RF-592: dónde sale y qué no tapa ---

func _screen_rect(text: FloatingText) -> Rect2:
	var canvas: Transform2D = game.get_viewport().get_canvas_transform()
	var position: Vector2 = canvas * text.global_position
	var zoom: float = canvas.get_scale().x
	var font_size: float = float(text._font_size) * zoom
	var width: float = ThemeDB.fallback_font.get_string_size(text._text, HORIZONTAL_ALIGNMENT_LEFT, -1, text._font_size).x * zoom
	var rise: float = text._rise_px * zoom
	return Rect2(position.x - width / 2.0, position.y - rise - font_size, width, rise + font_size * 1.25)


func _assert_texts_clear_of(zones: Array[Rect2], view_rect: Rect2, label: String) -> void:
	assert_gt(_texts().size(), 0, label)
	for node: Node in _texts():
		var rect: Rect2 = _screen_rect(node as FloatingText)
		for zone: Rect2 in zones:
			assert_false(rect.intersects(zone), "%s: «%s» pisa %s" % [label, (node as FloatingText)._text, zone])
		assert_true(view_rect.grow(0.5).encloses(rect), "%s: «%s» queda dentro del mapa visible (%s en %s)" % [
			label, (node as FloatingText)._text, rect, view_rect])


func _last_row(cell: Vector2i) -> bool:
	return cell.y >= game.level.map_size().y - 1


func _last_column(cell: Vector2i) -> bool:
	return cell.x >= game.level.map_size().x - 1


func _first_row(cell: Vector2i) -> bool:
	return cell.y == 0


func test_pc_a_tower_in_the_bottom_row_does_not_cover_the_bottom_bar() -> void:
	await _start_pc()
	var tower: Tower = _build(_tower_data("tesla"), _last_row)
	if tower == null:
		tower = _build(_tower_data("tesla"), func(cell: Vector2i) -> bool: return cell.y >= game.level.map_size().y - 2)
	assert_not_null(tower, "hay una torre en las últimas filas")
	game.build_controller.try_upgrade(tower)
	game.build_controller.try_upgrade(tower)
	var bar: Rect2 = (game.hud.get_node("BottomBar") as Control).get_global_rect()
	_assert_texts_clear_of([bar] as Array[Rect2], game._upgrade_fx_view_rect(), "PC, fila de abajo")


func test_mobile_bottom_row_right_column_and_first_row_stay_visible_and_clear_of_the_controls() -> void:
	await _start_mobile()
	var data: TowerData = _tower_data("tesla")
	var spots: Dictionary = {"fila de abajo": _last_row, "columna de la derecha": _last_column, "fila de arriba": _first_row}
	for label: String in spots:
		var tower: Tower = _build(data, spots[label])
		if tower == null:
			continue
		for node: Node in _texts() + _effects():
			node.free()
		game.build_controller.select_placed(tower)
		game._refresh_tower_panel()
		while tower.level_number() > 1:
			tower.level_index = 0
		game.build_controller.try_upgrade(tower)
		var zones: Array[Rect2] = game.mobile_hud.forbidden_rects()
		assert_gt(zones.size(), 0, "la barra de abajo siempre cuenta")
		_assert_texts_clear_of(zones, game._upgrade_fx_view_rect(), "celular, %s" % label)


func test_mobile_the_tilde_and_the_cross_are_forbidden_zones_when_they_show() -> void:
	await _start_mobile()
	var hud: MobileHud = game.mobile_hud
	var before: int = hud.forbidden_rects().size()
	hud.show_placement(Vector2(300, 300), "50", true, "")
	var zones: Array[Rect2] = hud.forbidden_rects()
	assert_gt(zones.size(), before, "la tilde y la cruz entran en la lista cuando se ven")
	assert_true(zones.has(hud._confirm_button.get_global_rect()))
	assert_true(zones.has(hud._cancel_button.get_global_rect()))
	assert_true(zones.has(hud._cart_button.get_global_rect()), "y los botones flotantes")
	# Una torre cuyo texto caería justo sobre la tilde: el bloque se corre.
	var tower: Tower = _build(_tower_data("tesla"), func(cell: Vector2i) -> bool: return cell.y >= 3)
	var canvas: Transform2D = game.get_viewport().get_canvas_transform()
	var top: Vector2 = canvas * (tower.global_position + Vector2(0, -48))
	hud._confirm_button.position = top - hud._confirm_button.size / 2.0 - Vector2(0, 30)
	for node: Node in _texts():
		node.free()
	game.build_controller.try_upgrade(tower)
	_assert_texts_clear_of(hud.forbidden_rects(), game._upgrade_fx_view_rect(), "celular, con la tilde encima")


func test_the_text_is_at_least_20_screen_pixels_even_with_a_small_zoom() -> void:
	await _start_mobile()
	var tower: Tower = _build(_tower_data("basic"))
	tower.level_index = 1  # como si ya se hubiera mejorado: se llama a la capa directo con otro zoom
	var view := Rect2(Vector2.ZERO, Vector2(1280, 720))
	for zoom: float in [0.5, 1.0, 1.5]:
		var canvas := Transform2D(0.0, Vector2(zoom, zoom), 0.0, Vector2(100, 100))
		assert_true(game.effects.tower_upgraded(tower, canvas, [] as Array[Rect2], view))
		var texts: Array[Node] = _texts()
		assert_gt(texts.size(), 0)
		for node: Node in texts:
			var on_screen: float = float((node as FloatingText)._font_size) * zoom
			assert_gte(on_screen, 19.5, "al menos 20 px en pantalla (zoom %s)" % zoom)
			assert_lte(on_screen, 30.5, "y no más de 30 (zoom %s)" % zoom)
		for node: Node in texts + _effects():
			node.free()
		game.effects._upgrade_live.clear()


func test_the_balance_does_not_depend_on_the_animation() -> void:
	await _start_pc()
	var results: Array = []
	for fx_on: bool in [true, false]:
		SaveManager.set_setting("upgrade_fx", fx_on)
		var tower: Tower = _build(_tower_data("cannon"))
		var gold_before: int = game.session.gold
		game.build_controller.try_upgrade(tower)
		results.append([gold_before - game.session.gold, tower.stats().damage, tower.total_invested, tower.level_number()])
	assert_eq(results[0], results[1], "costo, daño, inversión y nivel son los mismos con y sin la opción")


# --- RF-593: Opciones ---

func test_options_has_the_checkbox_on_by_default_right_under_the_damage_numbers() -> void:
	var options: OptionsMenu = OPTIONS_SCENE.instantiate() as OptionsMenu
	add_child_autofree(options)
	await get_tree().process_frame
	options.open()
	var check: CheckBox = options.find_child("UpgradeFxCheck", true, false) as CheckBox
	var damage: CheckBox = options.find_child("DamageNumbersCheck", true, false) as CheckBox
	assert_not_null(check)
	assert_eq(check.text, "Animaciones de mejora")
	assert_true(check.button_pressed, "un guardado nuevo o viejo la muestra prendida")
	assert_eq(check.get_index(), damage.get_index() + 1, "justo debajo de «Mostrar números de daño»")
	check.button_pressed = false
	assert_false(SaveManager.upgrade_fx_enabled())
	assert_true(bool(SaveManager.get_setting("damage_numbers")), "no toca los números de daño")
	options.close()
	SaveManager.load_save()
	assert_false(SaveManager.upgrade_fx_enabled(), "queda guardado")


func test_mobile_options_still_fit_in_720_and_the_row_respects_the_touch_minimum() -> void:
	SaveManager.set_setting("ui_mode", UiMode.MOBILE)
	var options: OptionsMenu = OPTIONS_SCENE.instantiate() as OptionsMenu
	add_child_autofree(options)
	await get_tree().process_frame
	for from_main_menu: bool in [false, true]:
		options.admin_available = from_main_menu
		options.open()
		for _i: int in 3:
			await get_tree().process_frame
		var panel: Control = options.find_child("Panel", true, false) as Control
		assert_lte(panel.size.y, 720.0, "Opciones entra en 720 de alto (menú principal: %s)" % from_main_menu)
		var check: CheckBox = options.find_child("UpgradeFxCheck", true, false) as CheckBox
		assert_gte(check.size.y, 56.0, "mínimo táctil")
		assert_true(panel.get_global_rect().encloses(check.get_global_rect()), "la fila nueva queda dentro del panel")


# --- T411 (RF-625, D-165): el arte aprobado ---

func test_the_effect_shows_the_approved_atlas_frame_by_progress() -> void:
	var refuerzo := UpgradeEffect.new().setup(Color(1.0, 0.7, 0.2), 51.2, 0.5, false)
	add_child_autofree(refuerzo)
	var sprite: Sprite2D = refuerzo.get_child(0) as Sprite2D
	assert_eq(sprite.texture.get_size(), Vector2(768, 384), "atlas de 4 × 2 cuadros de 192")
	assert_eq(sprite.hframes * sprite.vframes, 8)
	assert_eq(sprite.modulate, Color(1.0, 0.7, 0.2), "se tiñe con el color de la torre")
	assert_eq(sprite.scale, Vector2.ONE, "1:1 en una torre de 1 × 1")
	var expected: Dictionary = {0.0: 0, 0.13: 1, 0.5: 4, 0.99: 7, 1.0: 7}
	for progress: float in expected:
		refuerzo.progress = progress
		assert_eq(refuerzo.frame(), expected[progress], "progreso %s" % progress)


func test_mastery_uses_its_own_atlas_and_the_footprint_scales_it() -> void:
	var maestria := UpgradeEffect.new().setup(Color.WHITE, 153.6, 0.7, true, 2.0)
	add_child_autofree(maestria)
	var sprite: Sprite2D = maestria.get_child(0) as Sprite2D
	assert_ne(sprite.texture, UpgradeEffect.ATLAS_REFUERZO)
	assert_eq(sprite.texture, UpgradeEffect.ATLAS_MAESTRIA)
	assert_eq(sprite.scale, Vector2(2, 2), "el Mortero (2 × 2) lo agranda")


func test_the_layer_passes_the_footprint_and_the_option_off_creates_nothing() -> void:
	await _start_pc()
	var tower: Tower = _build(_tower_data("basic"))
	game.build_controller.try_upgrade(tower)
	assert_eq((_effects()[0] as UpgradeEffect).art_scale(), 1.0)
	SaveManager.set_setting("upgrade_fx", false)
	var second: Tower = _build(_tower_data("basic"))
	var before: int = _effects().size()
	game.build_controller.try_upgrade(second)
	assert_eq(_effects().size(), before, "con la opción apagada no nace ningún efecto")
