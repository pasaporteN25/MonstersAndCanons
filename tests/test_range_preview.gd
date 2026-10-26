# Tests de la ampliación del alcance (M75, T467, RF-680 a RF-682, D-195).
# Partida real: en PC dentro del árbol de GUT y en modo celular dentro de un SubViewport de 1280 × 720.
extends GutTest

const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")
const TEST_SAVE: String = "user://test_range_preview.json"

var _viewport: SubViewport
var game: Game
var _original_mode: Variant
var _original_path: String
## El oro justo antes del primer toque de `_arm_mobile` (la torre ya está construida y mejorada).
var _gold_before_tap: int = 0


func before_each() -> void:
	_original_path = SaveManager.save_path
	SaveManager.save_path = TEST_SAVE
	SaveManager.load_save()  # opciones por defecto: animaciones de mejora prendidas y alcance Oculto
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


func _tower_data(id: String) -> TowerData:
	for data: TowerData in game.tower_types:
		if data.id == id:
			return data
	return null


## Construye la primera torre posible de `id` y la deja elegida, con `level_number` ya subido.
func _select_tower(id: String, level_number: int = 1) -> Tower:
	var data: TowerData = _tower_data(id)
	var tower: Tower = null
	for y: int in game.level.map_size().y:
		for x: int in game.level.map_size().x:
			var cell := Vector2i(x, y)
			if game.level.is_buildable(cell) and game.build_controller.cells_free(data, cell) \
					and game.build_controller.try_build(data, cell):
				tower = game.build_controller.tower_at(cell)
				break
		if tower != null:
			break
	assert_not_null(tower, "se pudo construir %s" % id)
	while tower.level_number() < level_number:
		assert_true(game.build_controller.try_upgrade(tower))
	game.build_controller.select_placed(tower)
	await get_tree().process_frame
	return tower


func _panel() -> TowerPanel:
	return game.hud.tower_panel


func _hover_upgrade(hovered: bool) -> void:
	if hovered:
		_panel().upgrade_button().mouse_entered.emit()
	else:
		_panel().upgrade_button().mouse_exited.emit()


func _preview() -> RangePreview:
	return game.effects.range_preview()


## Las ampliaciones con forma de efecto de mejora (las que se desvanecen), vivas.
func _fading_previews() -> Array[RangePreview]:
	var found: Array[RangePreview] = []
	for child: Node in game.effects.get_children():
		var preview := child as RangePreview
		if preview != null and preview.fades_out() and not preview.is_queued_for_deletion():
			found.append(preview)
	return found


func _mobile_upgrade_button() -> Button:
	return game.mobile_hud.find_child("MobileUpgrade", true, false) as Button


func _tap_upgrade() -> void:
	game.mobile_hud._on_upgrade_pressed()


func _arm_mobile(id: String = "cannon", level_number: int = 2) -> Tower:
	var tower: Tower = await _select_tower(id, level_number)
	await get_tree().process_frame
	_gold_before_tap = game.session.gold
	_tap_upgrade()
	assert_true(game.mobile_hud.is_upgrade_armed(), "el primer toque arma")
	return tower


## Lo que tiene que cumplirse después de cualquier evento que cancela el armado (RF-681 punto 3).
func _assert_disarmed(tower: Tower, level_before: int, gold_before: int, reason: String) -> void:
	assert_false(game.mobile_hud.is_upgrade_armed(), "%s: desarma" % reason)
	assert_null(_preview(), "%s: la ampliación se va" % reason)
	assert_eq(tower.level_number(), level_before, "%s: no mejora" % reason)
	assert_eq(game.session.gold, gold_before, "%s: no cobra" % reason)


# --- RangePreview: lógica del nodo, sin partida ---

func test_the_preview_grows_from_the_current_to_the_new_radius_and_stays() -> void:
	var preview: RangePreview = autofree(RangePreview.new().setup(100.0, 140.0, 0.5, true))
	assert_almost_eq(preview.radius_at(0.0), 100.0, 0.001)
	assert_almost_eq(preview.radius_at(1.0), 140.0, 0.001)
	assert_between(preview.radius_at(0.5), 100.0, 140.0)
	assert_almost_eq(preview.alpha_at(1.0), 1.0, 0.001, "la vista previa no se desvanece")
	assert_almost_eq(preview.radius_at(5.0), 140.0, 0.001, "pasado el final se queda en el radio nuevo")
	assert_almost_eq(preview.radius_at(-1.0), 100.0, 0.001, "y antes del principio, en el actual")


func test_without_animation_the_preview_is_already_at_the_new_radius() -> void:
	var preview: RangePreview = autofree(RangePreview.new().setup(100.0, 140.0, 0.5, false))
	assert_almost_eq(preview.radius_at(0.0), 140.0, 0.001, "RF-680: quieto, el círculo nuevo")
	assert_almost_eq(preview.alpha_at(0.5), 1.0, 0.001)


func test_the_upgrade_effect_form_keeps_the_new_radius_and_fades_out() -> void:
	var preview: RangePreview = autofree(RangePreview.new().setup(140.0, 140.0, 0.5, true, true))
	assert_almost_eq(preview.radius_at(0.5), 140.0, 0.001)
	assert_almost_eq(preview.alpha_at(0.0), 1.0, 0.001)
	assert_almost_eq(preview.alpha_at(0.5), 0.5, 0.001)
	assert_almost_eq(preview.alpha_at(1.0), 0.0, 0.001)


func test_a_radius_that_does_not_change_does_not_grow() -> void:
	var preview: RangePreview = autofree(RangePreview.new().setup(75.0, 75.0, 0.5, true))
	for amount: float in [0.0, 0.3, 1.0]:
		assert_almost_eq(preview.radius_at(amount), 75.0, 0.001)


func test_the_preview_does_not_use_process() -> void:
	var names: Array[String] = []
	for method: Dictionary in (RangePreview as Script).get_script_method_list():
		names.append(String(method["name"]))
	assert_false(names.has("_process") or names.has("_physics_process"), "RangePreview mueve todo con un Tween")


# --- RF-680: PC, el mouse sobre «Mejorar» ---

func test_pc_hover_on_an_active_upgrade_button_shows_the_growing_circle_and_leaving_hides_it() -> void:
	await _start_pc()
	var tower: Tower = await _select_tower("cannon", 2)  # 3 → 3,5 casillas
	assert_null(_preview(), "sin el mouse encima no hay nada")
	_hover_upgrade(true)
	var preview: RangePreview = _preview()
	assert_not_null(preview)
	assert_false(preview.fades_out())
	assert_true(preview.is_animated())
	assert_almost_eq(preview._from_radius, Rules.tiles_to_px(3.0), 0.001)
	assert_almost_eq(preview._to_radius, Rules.tiles_to_px(3.5), 0.001)
	assert_almost_eq(preview.duration(), 0.5, 0.0001, "la misma duración que el refuerzo")
	assert_eq(preview.position, tower.global_position)
	_hover_upgrade(false)
	assert_null(_preview(), "al sacar el mouse desaparece")
	assert_eq(tower.level_number(), 2, "mirar no mejora")


func test_pc_hover_when_the_range_does_not_change_shows_the_same_circle() -> void:
	await _start_pc()
	await _select_tower("tesla", 1)  # 2,5 → 2,5
	_hover_upgrade(true)
	var preview: RangePreview = _preview()
	assert_not_null(preview)
	assert_almost_eq(preview._from_radius, Rules.tiles_to_px(2.5), 0.001)
	assert_almost_eq(preview._to_radius, Rules.tiles_to_px(2.5), 0.001)


func test_pc_hover_shows_the_circle_even_with_the_range_option_hidden() -> void:
	await _start_pc()
	SaveManager.set_setting("range_display", 0)
	await _select_tower("cannon", 2)
	_hover_upgrade(true)
	assert_not_null(_preview(), "RF-680: vale con cualquier valor, incluido Oculto")
	_hover_upgrade(false)
	assert_null(_preview())
	assert_eq(BuildController.placed_range_style(SaveManager.range_display()), 0, "y la torre elegida sigue sin círculo")


func test_pc_hover_on_a_disabled_button_shows_nothing_without_gold_or_at_max_level() -> void:
	await _start_pc()
	var tower: Tower = await _select_tower("cannon", 2)
	game.session.set_gold(0)
	await get_tree().process_frame
	assert_true(_panel().upgrade_button().disabled)
	_hover_upgrade(true)
	assert_null(_preview(), "sin oro no se muestra")
	_hover_upgrade(false)
	game.session.earn(100000)
	game.build_controller.try_upgrade(tower)  # nivel máximo
	await get_tree().process_frame
	assert_true(_panel().upgrade_button().disabled)
	_hover_upgrade(true)
	assert_null(_preview(), "en el nivel máximo tampoco")


func test_pc_hover_hides_the_circle_if_the_gold_runs_out_meanwhile() -> void:
	await _start_pc()
	await _select_tower("cannon", 2)
	_hover_upgrade(true)
	assert_not_null(_preview())
	game.session.set_gold(0)
	assert_null(_preview(), "el botón se apagó: la ampliación se va")
	game.session.earn(100000)
	assert_not_null(_preview(), "y vuelve si el mouse sigue encima y hay oro")


func test_pc_deselecting_the_tower_with_the_mouse_over_the_button_clears_the_circle() -> void:
	await _start_pc()
	await _select_tower("cannon", 2)
	_hover_upgrade(true)
	assert_not_null(_preview())
	game.build_controller.deselect_placed()
	await get_tree().process_frame
	assert_null(_preview())
	assert_false(_panel().is_upgrade_hovered(), "un panel escondido no cuenta como mouse encima")


func test_pc_click_upgrades_instantly_and_the_hover_moves_on_to_the_next_level() -> void:
	await _start_pc()
	var tower: Tower = await _select_tower("cannon", 1)
	var gold_before: int = game.session.gold
	var cost: int = tower.next_level_stats().cost
	var next_damage: int = tower.next_level_stats().damage
	_hover_upgrade(true)
	_panel().upgrade_button().pressed.emit()
	assert_eq(tower.level_number(), 2, "RF-682: sube en el mismo instante")
	assert_eq(game.session.gold, gold_before - cost, "el oro es el de siempre")
	assert_eq(tower.stats().damage, next_damage)
	var preview: RangePreview = _preview()
	assert_not_null(preview, "el mouse sigue encima: ahora muestra el nivel siguiente")
	assert_almost_eq(preview._from_radius, Rules.tiles_to_px(3.0), 0.001)
	assert_almost_eq(preview._to_radius, Rules.tiles_to_px(3.5), 0.001)


# --- RF-680 (2) y RF-682: el efecto de mejora ---

func test_the_upgrade_effect_draws_the_improved_range_and_fades_even_with_the_option_hidden() -> void:
	await _start_pc()
	SaveManager.set_setting("range_display", 0)
	var tower: Tower = await _select_tower("cannon", 2)
	assert_true(game.build_controller.try_upgrade(tower))
	var fading: Array[RangePreview] = _fading_previews()
	assert_eq(fading.size(), 1)
	assert_almost_eq(fading[0]._to_radius, Rules.tiles_to_px(3.5), 0.001, "con el alcance ya mejorado")
	assert_eq(fading[0].position, tower.global_position)
	assert_null(_preview(), "no queda una vista previa permanente")


func test_the_upgrade_effect_range_removes_itself_when_it_ends() -> void:
	await _start_pc()
	var tower: Tower = await _select_tower("cannon", 1)
	game.build_controller.try_upgrade(tower)
	assert_eq(_fading_previews().size(), 1)
	Engine.time_scale = 100.0
	for i: int in 6:
		await get_tree().process_frame
	Engine.time_scale = 1.0
	assert_eq(_fading_previews().size(), 0, "se borra solo")
	assert_eq(game.effects.upgrade_fx_alive(), 0, "y no queda contada como viva")


func test_with_upgrade_animations_off_the_hover_circle_is_still_and_the_effect_draws_none() -> void:
	await _start_pc()
	SaveManager.set_setting("upgrade_fx", false)
	var tower: Tower = await _select_tower("cannon", 2)
	_hover_upgrade(true)
	var preview: RangePreview = _preview()
	assert_not_null(preview)
	assert_false(preview.is_animated())
	assert_null(preview._tween, "sin Tween")
	assert_almost_eq(preview.current_radius(), Rules.tiles_to_px(3.5), 0.001, "el círculo nuevo, ya completo")
	_hover_upgrade(false)
	var gold_before: int = game.session.gold
	var cost: int = tower.next_level_stats().cost
	assert_true(game.build_controller.try_upgrade(tower))
	assert_eq(tower.level_number(), 3, "la mejora se aplica igual")
	assert_eq(game.session.gold, gold_before - cost, "y cobra una vez")
	assert_eq(_fading_previews().size(), 0, "RF-682: el efecto no dibuja la ampliación")


func test_upgrade_animations_default_to_on() -> void:
	assert_true(SaveManager.upgrade_fx_enabled(), "RF-682: prendida por omisión")
	await _start_pc()
	await _select_tower("cannon", 2)
	_hover_upgrade(true)
	assert_true(_preview().is_animated())


# --- Pausa y velocidad (M36) ---

func test_the_preview_waits_while_the_game_is_paused_and_resumes_after() -> void:
	await _start_pc()
	await _select_tower("cannon", 2)
	_hover_upgrade(true)
	var preview: RangePreview = _preview()
	get_tree().paused = true
	var frozen: float = preview.progress
	for i: int in 5:
		await get_tree().process_frame
	assert_eq(preview.progress, frozen, "en pausa el círculo no crece")
	get_tree().paused = false
	Engine.time_scale = 100.0
	for i: int in 4:
		await get_tree().process_frame
	Engine.time_scale = 1.0
	assert_almost_eq(preview.progress, 1.0, 0.0001, "al seguir, termina de crecer")
	assert_almost_eq(preview.current_radius(), Rules.tiles_to_px(3.5), 0.001)


func test_the_preview_follows_the_game_speed() -> void:
	await _start_pc()
	await _select_tower("cannon", 2)
	_hover_upgrade(true)
	var preview: RangePreview = _preview()
	for i: int in 3:
		await get_tree().process_frame
	assert_lt(preview.progress, 1.0, "a velocidad normal, 3 cuadros no alcanzan para 0,5 s")
	Engine.time_scale = 100.0
	for i: int in 3:
		await get_tree().process_frame
	Engine.time_scale = 1.0
	assert_almost_eq(preview.progress, 1.0, 0.0001, "a mucha velocidad termina enseguida")




# --- RF-681: celular, dos toques ---

func test_mobile_first_tap_arms_without_charging_and_shows_the_circle_with_the_cost() -> void:
	await _start_mobile()
	var tower: Tower = await _arm_mobile("cannon", 2)
	assert_eq(tower.level_number(), 2, "la torre sigue igual")
	assert_eq(game.session.gold, _gold_before_tap, "no se cobró nada")
	var preview: RangePreview = _preview()
	assert_not_null(preview)
	assert_almost_eq(preview._to_radius, Rules.tiles_to_px(3.5), 0.001)
	assert_eq(game.mobile_hud.armed_tower(), tower)
	var button: Button = _mobile_upgrade_button()
	assert_true(button.text.contains("Tocá para confirmar"), "el botón espera confirmación")
	assert_true(button.text.contains(str(tower.next_level_stats().cost)), "y conserva el costo")
	await get_tree().process_frame
	assert_true(game.mobile_hud.is_upgrade_armed(), "el refresco de cada cuadro no lo desarma")
	assert_true(button.text.contains("Tocá para confirmar"))


func test_mobile_second_tap_upgrades_once_instantly() -> void:
	await _start_mobile()
	var tower: Tower = await _arm_mobile("cannon", 1)
	var gold_before: int = game.session.gold
	var cost: int = tower.next_level_stats().cost
	_tap_upgrade()
	assert_eq(tower.level_number(), 2, "RF-682: sube al instante")
	assert_eq(game.session.gold, gold_before - cost, "se cobra una vez")
	assert_false(game.mobile_hud.is_upgrade_armed())
	assert_null(_preview(), "la vista previa se va y queda el efecto")
	assert_eq(_fading_previews().size(), 1)
	assert_true(_mobile_upgrade_button().text.contains("¡Nivel 2!"), "el botón vuelve a su forma inicial y se bloquea")


func test_mobile_double_tap_after_confirming_raises_only_one_level() -> void:
	await _start_mobile()
	var tower: Tower = await _arm_mobile("cannon", 1)
	_tap_upgrade()  # confirma
	_tap_upgrade()  # los toques de más, dentro de los 0,35 s
	_tap_upgrade()
	assert_eq(tower.level_number(), 2, "RF-681 punto 4: un solo nivel")
	assert_false(game.mobile_hud.is_upgrade_armed(), "el bloqueo tampoco deja armar de nuevo")
	await get_tree().create_timer(0.4).timeout
	await get_tree().process_frame
	assert_false(_mobile_upgrade_button().disabled, "pasado el bloqueo vuelve a responder")
	_tap_upgrade()
	assert_true(game.mobile_hud.is_upgrade_armed(), "y pide otra vez dos toques")
	assert_eq(tower.level_number(), 2)


func test_mobile_tapping_without_gold_or_at_max_level_arms_nothing() -> void:
	await _start_mobile()
	var tower: Tower = await _select_tower("cannon", 2)
	game.session.set_gold(0)
	await get_tree().process_frame
	_tap_upgrade()
	assert_false(game.mobile_hud.is_upgrade_armed(), "sin oro no arma")
	assert_null(_preview())
	game.session.earn(100000)
	game.build_controller.try_upgrade(tower)
	await get_tree().process_frame
	_tap_upgrade()
	assert_false(game.mobile_hud.is_upgrade_armed(), "en el nivel máximo tampoco")
	assert_eq(_mobile_upgrade_button().text, "Nivel máximo")


func test_mobile_keeps_the_two_taps_with_upgrade_animations_off() -> void:
	await _start_mobile()
	SaveManager.set_setting("upgrade_fx", false)
	var tower: Tower = await _arm_mobile("cannon", 2)
	assert_eq(tower.level_number(), 2)
	var preview: RangePreview = _preview()
	assert_not_null(preview)
	assert_false(preview.is_animated(), "la ampliación sale quieta")
	_tap_upgrade()
	assert_eq(tower.level_number(), 3)
	assert_eq(_fading_previews().size(), 0, "y el efecto no la dibuja")


# --- RF-681 punto 3: un test por cada evento que cancela ---

func test_mobile_tapping_the_map_disarms() -> void:
	await _start_mobile()
	var tower: Tower = await _arm_mobile()
	var level: int = tower.level_number()
	var gold: int = game.session.gold
	game.build_controller._mobile_map_tap(game.level.cell_center(Vector2i.ZERO), Time.get_ticks_msec())
	_assert_disarmed(tower, level, gold, "tocar el mapa")


func test_mobile_releasing_the_tower_disarms() -> void:
	await _start_mobile()
	var tower: Tower = await _arm_mobile()
	var level: int = tower.level_number()
	var gold: int = game.session.gold
	(game.mobile_hud.find_child("BottomCancelPlacement", true, false) as Button).pressed.emit()
	_assert_disarmed(tower, level, gold, "soltar la torre")
	assert_null(game.build_controller.selected_placed())


func test_mobile_choosing_another_tower_disarms() -> void:
	await _start_mobile()
	var other: Tower = await _select_tower("tesla", 2)
	var tower: Tower = await _arm_mobile("cannon", 2)
	var level: int = tower.level_number()
	var gold: int = game.session.gold
	game.build_controller.select_placed(other)
	await get_tree().process_frame
	_assert_disarmed(tower, level, gold, "elegir otra torre")
	assert_eq(other.level_number(), 2, "y la otra tampoco mejoró")


func test_mobile_switching_to_another_bar_state_disarms() -> void:
	await _start_mobile()
	var tower: Tower = await _arm_mobile()
	var level: int = tower.level_number()
	var gold: int = game.session.gold
	game.mobile_hud.show_ghost_status("Cañón", "50 de oro")
	_assert_disarmed(tower, level, gold, "pasar al fantasma")
	game.build_controller.select_placed(tower)
	await get_tree().process_frame
	_tap_upgrade()
	assert_true(game.mobile_hud.is_upgrade_armed())
	game.mobile_hud.show_tool_status("Demoler")
	_assert_disarmed(tower, level, gold, "pasar a una herramienta")
	game.build_controller.select_placed(tower)
	await get_tree().process_frame
	_tap_upgrade()
	assert_true(game.mobile_hud.is_upgrade_armed())
	game.mobile_hud.show_selected_tower(null, gold, 0, 0, false)
	_assert_disarmed(tower, level, gold, "pasar a la barra vacía")


func test_mobile_tapping_sell_disarms() -> void:
	await _start_mobile()
	var tower: Tower = await _arm_mobile()
	var level: int = tower.level_number()
	var gold: int = game.session.gold
	game.mobile_hud._on_sell_pressed()
	_assert_disarmed(tower, level, gold, "tocar Vender")
	assert_true(is_instance_valid(tower) and not tower.is_queued_for_deletion(), "el primer toque de Vender solo arma la venta")


func test_mobile_tapping_the_targeting_priority_disarms() -> void:
	await _start_mobile()
	var tower: Tower = await _arm_mobile()
	var level: int = tower.level_number()
	var gold: int = game.session.gold
	var targeting: int = tower.targeting
	(game.mobile_hud.find_child("MobileTargeting", true, false) as Button).pressed.emit()
	_assert_disarmed(tower, level, gold, "tocar la prioridad")
	assert_ne(tower.targeting, targeting, "y la prioridad sí cambió")


func test_mobile_pausing_disarms() -> void:
	await _start_mobile()
	var tower: Tower = await _arm_mobile()
	var level: int = tower.level_number()
	var gold: int = game.session.gold
	game.set_paused(true)
	_assert_disarmed(tower, level, gold, "pausar")
	game.set_paused(false)


func test_mobile_running_out_of_gold_disarms() -> void:
	await _start_mobile()
	var tower: Tower = await _arm_mobile()
	var level: int = tower.level_number()
	game.session.set_gold(0)
	await get_tree().process_frame
	_assert_disarmed(tower, level, 0, "quedarse sin oro")
	game.session.earn(100000)
	await get_tree().process_frame
	assert_false(game.mobile_hud.is_upgrade_armed(), "y recuperar el oro no lo vuelve a armar solo")
	assert_true(_mobile_upgrade_button().text.contains("Mejorar"))


func test_mobile_a_disarmed_button_goes_back_to_the_initial_text() -> void:
	await _start_mobile()
	var tower: Tower = await _arm_mobile()
	game.mobile_hud.clear_upgrade_arm()
	var button: Button = _mobile_upgrade_button()
	assert_true(button.text.contains("Mejorar → N%d" % (tower.level_number() + 1)))
	assert_false(button.text.contains("Tocá para confirmar"))
	game.mobile_hud.clear_upgrade_arm()  # desarmar de más no rompe nada
	assert_false(game.mobile_hud.is_upgrade_armed())


func test_pc_has_no_two_taps_one_click_upgrades() -> void:
	await _start_pc()
	var tower: Tower = await _select_tower("cannon", 1)
	_panel().upgrade_button().pressed.emit()
	assert_eq(tower.level_number(), 2, "RF-681 punto 5: en la PC no cambia")


# --- Tutorial (M63) ---

func test_the_phone_tutorial_upgrade_step_explains_the_two_taps_and_the_pc_one_is_unchanged() -> void:
	var data: TutorialData = TutorialData.load_file()
	assert_true(data.is_valid())
	var phone: String = ""
	var pc: String = ""
	for step: Dictionary in data.steps_for(true):
		if step["paso"] == "upgrade":
			phone = String(step["texto"])
	for step: Dictionary in data.steps_for(false):
		if step["paso"] == "upgrade":
			pc = String(step["texto"])
	assert_true(phone.contains("Un toque") and phone.contains("otro toque confirma"), "explica el primer toque y el segundo")
	assert_true(phone.contains("alcance"))
	assert_eq(pc, "«Mejorar» hace más fuerte a la torre elegida. Cuesta oro.", "en la PC el paso sigue igual")
