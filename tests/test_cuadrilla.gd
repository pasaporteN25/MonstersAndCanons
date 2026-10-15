# T253: La Cuadrilla (RF-485 a RF-491, D-094): el Ratero y el Cargador son dos archivos de datos que usan el robo
# que ya existe (RF-363). Acá se prueban los números, el robo en banda (cada uno en su reloj), los cuatro niveles donde
# aparecen, la Wiki y el artículo de Lore. Lo que cuesta ganar con ellos lo mide el bot (`tools/balance_sim.gd`).
extends GutTest

const PATH: String = "user://test_cuadrilla.json"
const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")
const BAND: Array[StringName] = [&"ratero", &"cargador"]
## Los niveles (índices 0-based de la campaña) donde entra la Cuadrilla: el 7, el 10, el 13 y el 14.
const BAND_LEVELS: Array[int] = [6, 9, 12, 13]
const AURA_ENEMIES: Array[StringName] = [&"guardian", &"healer", &"shaman", &"mirror", &"boss", &"colossus"]

var game: Game
var _old_dev: bool = false


func before_each() -> void:
	_old_dev = DevMode.enabled
	DevMode.enabled = true
	SaveManager.save_path = PATH
	SaveManager.load_save()
	GameFlow.current_index = 6
	GameFlow.intro_pending = false
	game = GAME_SCENE.instantiate()
	add_child_autofree(game)


func after_each() -> void:
	DevMode.enabled = _old_dev
	GameFlow.current_index = -1
	SaveManager.save_path = SaveManager.DEFAULT_PATH
	SaveManager.load_save()
	if FileAccess.file_exists(PATH):
		DirAccess.remove_absolute(PATH)


func _enemy_data(id: String) -> EnemyData:
	return load("res://data/enemies/%s.tres" % id)


## Hace aparecer un enemigo ya, con el robo conectado a la caja de la partida (como en el juego real).
func _spawn(id: String) -> Enemy:
	game.spawner.spawn_now(_enemy_data(id))
	var enemies: Array[Node] = game.get_node("Enemies").get_children()
	var enemy: Enemy = enemies[enemies.size() - 1]
	enemy.set_physics_process(false)
	return enemy


func _enemies_category(seen: Callable = Callable()) -> WikiCategory:
	for category: WikiCategory in Wiki.categories(GameFlow.campaign.levels, seen):
		if category.id == &"enemigos":
			return category
	return null


## Cuántas oleadas del nivel nombran a `id` y cuántos enemigos suman.
func _appearances(level: LevelData, id: StringName) -> Array[int]:
	var waves: Array[int] = []
	for i: int in level.waves.size():
		for group: SpawnGroup in level.waves[i].groups:
			if group.enemy.id == id:
				waves.append(i + 1)
	return waves


# --- Los datos (RF-485) ---

func test_the_ratero_has_the_numbers_of_rf_485() -> void:
	var data: EnemyData = _enemy_data("ratero")
	assert_eq(data.id, &"ratero")
	assert_eq(data.display_name, "Ratero")
	assert_eq(data.max_health, 14)
	assert_almost_eq(data.speed_tiles, 2.2, 0.001)
	assert_eq(data.armor, 0)
	assert_eq(data.reward, 5)
	assert_eq(data.lives_damage, 1)
	assert_false(data.is_flying)
	assert_eq(data.gold_drain_amount, 2)
	assert_almost_eq(data.gold_drain_interval, 2.0, 0.001)
	assert_eq(data.gold_drain_floor, 10)
	assert_almost_eq(data.size_tiles, 0.2, 0.001)
	assert_ne(data.description, "")


func test_the_cargador_has_the_numbers_of_rf_485() -> void:
	var data: EnemyData = _enemy_data("cargador")
	assert_eq(data.id, &"cargador")
	assert_eq(data.display_name, "Cargador")
	assert_eq(data.max_health, 110)
	assert_almost_eq(data.speed_tiles, 0.9, 0.001)
	assert_eq(data.armor, 1)
	assert_eq(data.reward, 30)
	assert_eq(data.lives_damage, 2)
	assert_false(data.is_flying)
	assert_eq(data.gold_drain_amount, 4)
	assert_almost_eq(data.gold_drain_interval, 2.0, 0.001)
	assert_eq(data.gold_drain_floor, 10)
	assert_almost_eq(data.size_tiles, 0.33, 0.001)
	assert_ne(data.description, "")


func test_neither_is_dangerous_and_neither_has_special_behaviour() -> void:
	for id: StringName in BAND:
		var data: EnemyData = _enemy_data(String(id))
		assert_false(Rules.is_dangerous(data), "%s no lleva corona (RF-136)" % id)
		assert_between(data.size_tiles, 0.05, 0.5, id)
		assert_almost_eq(data.slow_resistance, 0.0, 0.001, id)
		assert_null(data.death_spawn, id)
		assert_eq(data.optional_wave_limit, 0, "%s: sin el tope del Ladrón" % id)
		assert_ne(data.color, _enemy_data("thief").color, "%s se distingue del Ladrón" % id)
		assert_not_null(data.texture, "%s: arte provisional integrado (T259)" % id)
		assert_not_null(data.walk_atlas, id)


func test_the_two_have_different_shape_and_color() -> void:
	var ratero: EnemyData = _enemy_data("ratero")
	var cargador: EnemyData = _enemy_data("cargador")
	assert_ne(ratero.color, cargador.color)
	assert_ne(ratero.shape, cargador.shape)


func test_no_enemy_that_already_existed_changed_its_numbers() -> void:
	assert_eq([_enemy_data("thief").max_health, _enemy_data("thief").gold_drain_amount, _enemy_data("thief").optional_wave_limit], [24, 3, 1])
	assert_eq([_enemy_data("boss").max_health, _enemy_data("boss").lives_damage], [300, 10])
	assert_eq([_enemy_data("tank").max_health, _enemy_data("tank").speed_tiles], [135, 0.8])
	assert_eq([_enemy_data("fast").max_health, _enemy_data("fast").speed_tiles], [18, 3.0])


func test_enemy_data_has_no_new_field_for_the_band() -> void:
	# RF-485: ningún campo nuevo de `EnemyData`; lo que la Cuadrilla usa ya estaba para el Ladrón (RF-363).
	var names: PackedStringArray = []
	for property: Dictionary in EnemyData.new().get_property_list():
		names.append(property["name"])
	for forbidden: String in ["band", "cuadrilla", "group_speed", "shared_speed", "leader", "ratero", "cargador"]:
		assert_false(names.has(forbidden), forbidden)


# --- El robo en banda (RF-363, RF-485) ---

func test_a_group_of_eight_rateros_comes_out_whole_even_with_probability_one() -> void:
	var spawner := WaveSpawner.new()
	add_child_autofree(spawner)
	var group := SpawnGroup.new()
	group.enemy = _enemy_data("ratero")
	group.count = 8
	group.probability = 1.0
	var wave := WaveData.new()
	wave.groups.append(group)
	spawner.start_wave(wave, 8)
	var pending: int = 0
	for run: WaveSpawner.GroupRun in spawner._runs:
		pending += run.group.count - run.spawned
	assert_eq(pending, 8, "salen los 8: no hay tope de uno por oleada")


func test_a_ratero_steals_two_and_respects_the_floor_of_ten() -> void:
	var ratero: Enemy = _spawn("ratero")
	game.session.gold = 100
	ratero._update_gold_drain(2.0)
	assert_eq(game.session.gold, 98)
	game.session.gold = 11
	ratero._update_gold_drain(2.0)
	assert_eq(game.session.gold, 10, "con 11 baja en 1")
	ratero._update_gold_drain(2.0)
	assert_eq(game.session.gold, 10, "con 10 no roba")


func test_a_cargador_steals_four_every_two_seconds_with_the_same_floor() -> void:
	var cargador: Enemy = _spawn("cargador")
	game.session.gold = 100
	cargador._update_gold_drain(1.0)
	assert_eq(game.session.gold, 100, "a 1 s todavía no")
	cargador._update_gold_drain(1.0)
	assert_eq(game.session.gold, 96)
	game.session.gold = 12
	cargador._update_gold_drain(2.0)
	assert_eq(game.session.gold, 10, "el piso: baja en 2, no en 4")


func test_every_one_steals_on_its_own_clock() -> void:
	# Criterio de RF-485: 8 Rateros y 1 Cargador, 200 de oro, 4 s → 8 × 4 + 1 × 8 = 40.
	var band: Array[Enemy] = []
	for i: int in 8:
		band.append(_spawn("ratero"))
	band.append(_spawn("cargador"))
	game.session.gold = 200
	for enemy: Enemy in band:
		enemy._update_gold_drain(2.0)
		enemy._update_gold_drain(2.0)
	assert_eq(game.session.gold, 160)


func test_a_ratero_that_reaches_the_exit_takes_one_life_and_stops_stealing() -> void:
	var ratero: Enemy = _spawn("ratero")
	var lives: int = game.session.lives
	game.session.gold = 100
	ratero.distance = ratero.path().curve.get_baked_length() - 1.0
	ratero.set_physics_process(true)
	ratero._physics_process(1.0)
	assert_eq(game.session.lives, lives - 1)
	ratero._update_gold_drain(10.0)
	assert_eq(game.session.gold, 100, "escapar no roba más")


func test_a_cargador_that_reaches_the_exit_takes_two_lives() -> void:
	var cargador: Enemy = _spawn("cargador")
	var lives: int = game.session.lives
	cargador.distance = cargador.path().curve.get_baked_length() - 1.0
	cargador.set_physics_process(true)
	cargador._physics_process(2.0)
	assert_eq(game.session.lives, lives - 2)


# --- Dónde aparece (RF-487) ---

func test_only_levels_7_10_13_and_14_name_the_band_with_four_appearances() -> void:
	for index: int in GameFlow.campaign.levels.size():
		var level: LevelData = GameFlow.level(index)
		var rateros: Array[int] = _appearances(level, &"ratero")
		var cargadores: Array[int] = _appearances(level, &"cargador")
		if index in BAND_LEVELS:
			assert_eq(rateros.size(), 4, "nivel %d: cuatro apariciones" % (index + 1))
			assert_eq(cargadores, rateros, "nivel %d: el Cargador sale con los Rateros" % (index + 1))
		else:
			assert_eq(rateros.size() + cargadores.size(), 0, "nivel %d no nombra la Cuadrilla" % (index + 1))


func test_the_band_has_no_probability_no_delay_and_the_requested_pace() -> void:
	for index: int in BAND_LEVELS:
		for wave: WaveData in GameFlow.level(index).waves:
			for group: SpawnGroup in wave.groups:
				if group.enemy.id == &"ratero":
					assert_almost_eq(group.interval, 0.4, 0.001)
				elif group.enemy.id == &"cargador":
					assert_almost_eq(group.interval, 3.0, 0.001)
				else:
					continue
				assert_almost_eq(group.probability, 1.0, 0.001)
				assert_almost_eq(group.start_delay, 0.0, 0.001)
				assert_eq(group.entrance_index, 0)


func test_no_wave_with_the_band_has_an_aura_enemy_or_a_boss() -> void:
	for index: int in BAND_LEVELS:
		for wave: WaveData in GameFlow.level(index).waves:
			var has_band: bool = false
			var has_aura: bool = false
			for group: SpawnGroup in wave.groups:
				has_band = has_band or group.enemy.id in BAND
				has_aura = has_aura or group.enemy.id in AURA_ENEMIES
			assert_false(has_band and has_aura, "nivel %d: Cuadrilla y aura en la misma oleada" % (index + 1))


func test_the_band_debuts_in_level_7_wave_8_and_never_in_the_opening() -> void:
	var waves: Array[int] = _appearances(GameFlow.level(6), &"ratero")
	assert_eq(waves[0], 8)
	for index: int in BAND_LEVELS:
		assert_gte(_appearances(GameFlow.level(index), &"ratero")[0], 8, "nivel %d: no entra antes de la oleada 8" % (index + 1))


func test_the_other_levels_keep_the_thief_numbers_and_the_ladder_of_lives() -> void:
	# Escalera (RF-475, punto 3): ni la vida inicial ni el aumento de ningún nivel de la Cuadrilla cambiaron.
	var expected: Dictionary = {6: [20, 24], 9: [20, 30], 12: [20, 40], 13: [20, 30]}
	for index: int in expected:
		var level: LevelData = GameFlow.level(index)
		assert_eq([level.starting_lives, level.health_scale_percent_per_wave], expected[index], "nivel %d" % (index + 1))


# --- La Wiki (RF-489) ---

func test_the_wiki_lists_both_and_they_are_closed_in_a_new_save() -> void:
	var seen: Array[StringName] = []
	var is_seen: Callable = func(id: StringName) -> bool: return seen.has(id)
	var enemies: WikiCategory = _enemies_category(is_seen)
	for id: StringName in BAND:
		assert_not_null(enemies.find(id), id)
		assert_true(enemies.find(id).locked, "%s: cerrado hasta verlo" % id)
	seen.append(&"ratero")
	enemies = _enemies_category(is_seen)
	assert_false(enemies.find(&"ratero").locked)
	assert_true(enemies.find(&"cargador").locked, "el Cargador se abre cuando aparece")


func test_the_open_entries_show_the_robbery_and_the_four_levels() -> void:
	var enemies: WikiCategory = _enemies_category(func(_id: StringName) -> bool: return true)
	for id: StringName in BAND:
		var text: String = enemies.find(id).plain_text()
		assert_string_contains(text, "Robo", "%s trae la línea de robo" % id)
		for number: int in [7, 10, 13, 14]:
			assert_string_contains(text, "Nivel %d" % number, "%s: dónde aparece" % id)
		assert_false(text.contains("Nivel 15"), id)


func test_the_card_and_the_wiki_draw_with_the_provisional_art() -> void:
	# T259: el arte provisional de T257 está integrado; la Wiki muestra la ilustración.
	for id: StringName in BAND:
		var enemy: Enemy = _spawn(String(id))
		assert_not_null(enemy.visual_texture(), id)
		assert_true(enemy.visual_frame_region().has_area(), id)
		var entry: WikiEntry = _enemies_category(func(_id: StringName) -> bool: return true).find(id)
		assert_not_null(entry)
		assert_string_contains(entry.plain_text(), _enemy_data(String(id)).description)


# --- Wiki Lore (RF-469, RF-470, RF-489) ---

func test_winning_level_7_opens_la_cuadrilla_and_article_5_stays_the_same() -> void:
	SaveManager.record_victory(&"level_06", 10, 100)
	var before: String = _lore_text(&"criaturas_solas")
	assert_true(_lore_entry(&"la_cuadrilla").locked, "con el 6 ganado todavía no")
	SaveManager.record_victory(&"level_07", 10, 100)
	var entry: WikiEntry = _lore_entry(&"la_cuadrilla")
	assert_false(entry.locked)
	assert_eq(entry.title, "La Cuadrilla")
	assert_string_contains(entry.plain_text(), "los colonos las llaman Rateros")
	assert_eq(_lore_text(&"criaturas_solas"), before, "el artículo 5 no cambia")
	assert_string_contains(_lore_text(&"criaturas_solas"), "va solo")


func test_la_cuadrilla_sits_between_article_5_and_the_ruins() -> void:
	var ids: Array[StringName] = []
	for entry: WikiEntry in _lore().entries:
		ids.append(entry.id)
	var position: int = ids.find(&"la_cuadrilla")
	assert_eq(ids[position - 1], &"criaturas_solas")
	assert_eq(ids[position + 1], &"las_ruinas")
	assert_eq(ids.size(), 11)


func _lore() -> WikiCategory:
	for category: WikiCategory in Wiki.categories(GameFlow.campaign.levels, Callable(), SaveManager.is_completed):
		if category.id == &"lore":
			return category
	return null


func _lore_entry(id: StringName) -> WikiEntry:
	return _lore().find(id)


func _lore_text(id: StringName) -> String:
	return _lore_entry(id).plain_text()
