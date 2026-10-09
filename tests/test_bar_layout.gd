# T248 (M53): la lógica pura de la barra con pestañas y de la flecha: reparto de botones (RF-455), teclas (RF-456),
# cuándo hay pestañas (RF-454), textos del diálogo (RF-460) y de la pestaña «Infraestructura» (RF-457). Sin escenas.
extends GutTest


# --- BarLayout: el ancho de los botones ---

func test_width_with_tabs_matches_the_spec() -> void:
	assert_eq(BarLayout.button_width(9, true), 71, "RF-455: con 9 torres, unos 71")
	assert_eq(BarLayout.button_width(10, true), 63, "con 10, unos 63")
	assert_eq(BarLayout.button_width(11, true), 57, "con 11 (todas las que existen), unos 57")


func test_width_never_leaves_the_limits() -> void:
	for tabs: bool in [false, true]:
		for count: int in range(1, 31):
			var width: int = BarLayout.button_width(count, tabs)
			assert_between(width, BarLayout.MIN_BUTTON_WIDTH, BarLayout.MAX_BUTTON_WIDTH, "%d torres (pestañas %s)" % [count, tabs])


func test_without_tabs_up_to_nine_towers_are_exactly_as_before() -> void:
	for count: int in range(1, 10):
		assert_eq(BarLayout.button_width(count, false), 76, "%d torres: 76 de ancho, como siempre (RF-454)" % count)
		assert_eq(BarLayout.gap(count, false), 10, "%d torres: separación de 10, como siempre" % count)
	assert_eq(BarLayout.left(false), 20, "la fila arranca en x = 20")


func test_without_tabs_ten_or_more_towers_shrink_to_fit() -> void:
	# RF-454: un mapa con 10 o más torres y sin infraestructura sigue de una fila, con botones más chicos.
	assert_eq(BarLayout.button_width(10, false), 73)
	assert_eq(BarLayout.button_width(11, false), 66)
	assert_eq(BarLayout.button_width(40, false), 56, "borde: nunca menos del piso")


func test_the_row_never_reaches_next_wave() -> void:
	for tabs: bool in [false, true]:
		for count: int in range(1, 12):
			var end_x: int = BarLayout.left(tabs) + count * BarLayout.button_width(count, tabs) + (count - 1) * BarLayout.gap(count, tabs)
			assert_lte(end_x, 800, "%d torres (pestañas %s): termina en %d, «Próxima oleada» arranca en 800" % [count, tabs, end_x])


func test_edge_counts() -> void:
	assert_eq(BarLayout.button_width(0, true), 76, "borde: sin torres")
	assert_eq(BarLayout.button_width(1, true), 76)
	assert_eq(BarLayout.left(true), 118, "con pestañas la fila arranca a la derecha de su columna")
	assert_eq(BarLayout.area_width(true), 674)


# --- BarLayout: las teclas ---

func test_key_labels() -> void:
	var expected: Array[String] = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "", ""]
	for i: int in expected.size():
		assert_eq(BarLayout.key_label(i), expected[i], "torre %d" % (i + 1))
	assert_eq(BarLayout.key_label(-1), "", "borde: índice negativo")


func test_actions_exist_for_the_first_ten_towers_and_not_beyond() -> void:
	assert_eq(BarLayout.action_for(0), &"build_1")
	assert_eq(BarLayout.action_for(8), &"build_9")
	assert_eq(BarLayout.action_for(9), &"build_10", "RF-456: la décima tiene acción (la tecla 0)")
	assert_true(InputMap.has_action(&"switch_tab"), "RF-456: la acción de Tab existe")
	assert_eq(BarLayout.action_for(10), &"", "la torre 11 no tiene tecla")
	assert_eq(BarLayout.action_for(-1), &"")
	assert_eq(BarLayout.action_for(500), &"")


func test_build_10_is_the_zero_key_and_switch_tab_is_tab() -> void:
	var zero := InputEventKey.new()
	zero.physical_keycode = KEY_0
	zero.pressed = true
	assert_true(zero.is_action(&"build_10"))
	var tab := InputEventKey.new()
	tab.physical_keycode = KEY_TAB
	tab.pressed = true
	assert_true(tab.is_action(&"switch_tab"))


# --- LevelData.uses_infrastructure (RF-454) ---

func _load(n: int) -> LevelData:
	var result: Dictionary = LevelFile.load_level("res://data/levels/level_%02d.json" % n)
	assert_eq(result["errors"], PackedStringArray(), "nivel %d sin errores" % n)
	return result["level"]


func test_campaign_levels_1_to_5_do_not_use_infrastructure() -> void:
	for n: int in range(1, 6):
		assert_false(_load(n).uses_infrastructure(), "nivel %d" % n)


func test_campaign_levels_6_to_10_use_infrastructure() -> void:
	for n: int in range(6, 11):
		assert_true(_load(n).uses_infrastructure(), "nivel %d" % n)


func _level_from(extra: Dictionary) -> LevelData:
	var data := {"version": 1, "nombre": "Borde", "oro": 100, "vidas": 10,
		"leyenda": {"t": {"removible": {"clase": "arbol"}}, "m": {"extraccion": {"clase": "mina"}}, "f": {"dibujo": "helecho"}},
		"mapa": ["....................", "A##################S", "....................", "....................", "....................", "....................", "....................", "....................", "...................."],
		"oleadas": [[{"enemigo": "normal", "cantidad": 2, "cada": 1.0}]]}
	data.merge(extra, true)
	var result: Dictionary = LevelFile.parse(JSON.stringify(data), &"prueba")
	assert_eq(result["errors"], PackedStringArray(), "el nivel de prueba carga sin errores")
	return result["level"]


func test_a_level_with_only_the_machine_uses_infrastructure() -> void:
	assert_true(_level_from({"demoledora": true}).uses_infrastructure())


func test_a_level_with_one_tree_uses_infrastructure() -> void:
	var rows: Array = ["....................", "A##################S", "..t.................", "....................", "....................", "....................", "....................", "....................", "...................."]
	assert_true(_level_from({"mapa": rows}).uses_infrastructure(), "un solo árbol removible alcanza (mapa de la comunidad)")


func test_a_level_with_only_a_mine_uses_infrastructure() -> void:
	var rows: Array = ["....................", "A##################S", "..m.................", "....................", "....................", "....................", "....................", "....................", "...................."]
	assert_true(_level_from({"mapa": rows}).uses_infrastructure(), "un punto de extracción alcanza")


func test_a_level_with_only_decoration_does_not_use_infrastructure() -> void:
	var rows: Array = ["....................", "A##################S", "..f.................", "....................", "....................", "....................", "....................", "....................", "...................."]
	var level: LevelData = _level_from({"mapa": rows})
	assert_false(level.uses_infrastructure(), "borde: un helecho decorativo no cuenta")
	assert_false(_level_from({}).uses_infrastructure(), "borde: sin nada")


# --- ExitText (RF-460) ---

func test_exit_text_without_pieces_has_only_the_two_lines() -> void:
	var text: String = ExitText.message([] as Array[String], false)
	assert_string_contains(text, "Se abandona esta partida. El oro, las torres y la oleada actual no se guardan.")
	assert_string_contains(text, "Lo que ya ganaste (niveles, estrellas, récords y piezas guardadas) se conserva.")
	assert_false(text.contains("Perdés"), "sin piezas no dice que se pierda ninguna")
	assert_false(text.contains("demolición"), "sin trabajo no habla de la demolición")


func test_exit_text_counts_the_pieces_and_names_their_collections() -> void:
	var two: Array[String] = ["technology", "disruptor"]
	var text: String = ExitText.message(two, false)
	assert_string_contains(text, "Perdés 2 piezas de colección recogidas en esta partida (Avances tecnológicos, Disruptora). Se guardan recién al terminar la partida.")


func test_exit_text_one_piece_and_the_same_collection_twice() -> void:
	var one: Array[String] = ["disruptor"]
	assert_string_contains(ExitText.message(one, false), "Perdés 1 pieza de colección recogida en esta partida (Disruptora).")
	var twice: Array[String] = ["disruptor", "disruptor"]
	var text: String = ExitText.message(twice, false)
	assert_string_contains(text, "Perdés 2 piezas")
	assert_string_contains(text, "(Disruptora)")
	assert_false(text.contains("Disruptora, Disruptora"), "el nombre sale una sola vez")


func test_exit_text_warns_about_the_demolition_in_progress() -> void:
	var text: String = ExitText.message([] as Array[String], true)
	assert_string_contains(text, "La demolición en curso se pierde y no devuelve el oro.")


func test_exit_text_order_is_always_then_pieces_then_job_then_kept() -> void:
	var pieces: Array[String] = ["disruptor"]
	var text: String = ExitText.message(pieces, true)
	var always: int = text.find("Se abandona")
	var lost: int = text.find("Perdés")
	var job: int = text.find("demolición")
	var kept: int = text.find("Lo que ya ganaste")
	assert_true(always < lost and lost < job and job < kept, "el orden del RF-460")


# --- InfrastructureText (RF-457, RF-458) ---

func test_the_badge_seconds_round_up() -> void:
	assert_eq(InfrastructureText.seconds_text(3.2), "4 s", "los segundos se redondean hacia arriba")
	assert_eq(InfrastructureText.job_left_line(3.2), "Faltan 4 s")
	assert_eq(InfrastructureText.seconds_text(0.1), "1 s", "borde: falta una décima y todavía dice 1 s")
	assert_eq(InfrastructureText.seconds_text(-2.0), "0 s", "borde: nunca negativo")


func test_machine_texts_come_from_the_data() -> void:
	assert_eq(InfrastructureText.machine_title(180, false), "Demoledora · 180 de oro")
	assert_eq(InfrastructureText.machine_title(180, true), "Demoledora activa")
	assert_eq(InfrastructureText.machine_effect(), "Cada demolición cuesta el 10 % y tarda el 80 %")
	assert_eq(InfrastructureText.machine_effect({"costo_uso_porcentaje": 25, "tiempo_porcentaje": 50}), "Cada demolición cuesta el 25 % y tarda el 50 %", "con otros datos, otro texto")
	assert_eq(InfrastructureText.buy_text(180, 200), "Comprar")
	assert_eq(InfrastructureText.buy_text(180, 180), "Comprar", "borde: justo alcanza")
	assert_eq(InfrastructureText.buy_text(180, 100), "Te faltan 80 de oro")


func test_site_lines() -> void:
	assert_eq(InfrastructureText.site_line(ObstacleField.State.DISABLED, 100, 8, 8, 2), "Habilitar · 100 de oro")
	assert_eq(InfrastructureText.site_line(ObstacleField.State.ACTIVE, 100, 6, 8, 2), "Activa · reserva 6/8 · +2 por oleada")
	assert_eq(InfrastructureText.site_line(ObstacleField.State.DEPLETED, 100, 0, 8, 2), "Agotada")


func _mine(cell: Vector2i, reserve: int, production: int) -> ObstacleSpec:
	var spec := ObstacleSpec.new()
	spec.cell = cell
	spec.kind = ObstacleSpec.Kind.EXTRACTION
	spec.class_id = &"mina"
	spec.cost = 100
	spec.reserve = reserve
	spec.production = production
	return spec


func test_expected_resources_matches_what_the_wave_really_delivers() -> void:
	var rng := RandomNumberGenerator.new()
	var specs: Array[ObstacleSpec] = [_mine(Vector2i(2, 2), 8, 2), _mine(Vector2i(5, 2), 1, 2), _mine(Vector2i(8, 2), 8, 3)]
	var field := ObstacleField.new()
	field.setup(specs, rng)
	assert_eq(InfrastructureText.expected_resources(field), 0, "sin habilitar no entrega nada")
	field.enable_site(Vector2i(2, 2))
	field.enable_site(Vector2i(5, 2))
	assert_eq(InfrastructureText.expected_resources(field), 3, "min(2, 8) + min(2, 1): la reserva corta lo que entrega")
	var expected: int = InfrastructureText.expected_resources(field)
	var delivered: int = 0
	for amount: int in field.complete_wave().values():
		delivered += amount
	assert_eq(delivered, expected, "lo esperado es lo mismo que entrega complete_wave")
	assert_eq(InfrastructureText.expected_resources(field), 2, "el de reserva 1 quedó agotado: ahora solo entrega el otro")


func test_sites_list_is_ordered_and_complete() -> void:
	var field := ObstacleField.new()
	var specs: Array[ObstacleSpec] = [_mine(Vector2i(8, 2), 8, 3), _mine(Vector2i(2, 2), 8, 2)]
	field.setup(specs, RandomNumberGenerator.new())
	var sites: Array[Dictionary] = InfrastructureText.sites(field)
	assert_eq(sites.size(), 2)
	assert_eq(sites[0]["cell"], Vector2i(2, 2), "en orden de fila y columna")
	assert_eq(sites[0]["kind_name"], "Mina")
	assert_eq(sites[0]["state"], ObstacleField.State.DISABLED)
	assert_eq(sites[1]["production"], 3)
	assert_eq(sites[1]["max_reserve"], 8)
