# Tests de cómo se descubre el combo (M20, T147, spec RF-317 y RF-318, D-047):
# lo dice la torre que pone el estado (panel, Wiki, barra), el artículo lo explica y el enemigo
# "listo para un combo" muestra una dianita.
extends GutTest

const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")
const TEST_PATH: String = "user://test_save.json"
const DT: float = 1.0 / 60.0

var basic: TowerData = load("res://data/towers/basic.tres")
var cannon: TowerData = load("res://data/towers/cannon.tres")
var frost: TowerData = load("res://data/towers/frost.tres")
var sniper: TowerData = load("res://data/towers/sniper.tres")
var fire: TowerData = load("res://data/towers/fire.tres")
var tesla: TowerData = load("res://data/towers/tesla.tres")
var mortar: TowerData = load("res://data/towers/mortar.tres")
var game: Game


func before_each() -> void:
	if FileAccess.file_exists(TEST_PATH):
		DirAccess.remove_absolute(TEST_PATH)
	SaveManager.save_path = TEST_PATH
	SaveManager.load_save()


func after_each() -> void:
	if FileAccess.file_exists(TEST_PATH):
		DirAccess.remove_absolute(TEST_PATH)
	SaveManager.save_path = SaveManager.DEFAULT_PATH
	SaveManager.load_save()


func _all() -> Array[TowerData]:
	var towers: Array[TowerData] = [basic, cannon, frost, sniper, fire, tesla, mortar]
	return towers


## El nivel 1 (sin el Mortero, RF-300) con oro de sobra.
func _start_game() -> void:
	game = GAME_SCENE.instantiate()
	add_child_autofree(game)
	game.session.earn(5000)


func _free_cell(skip: int = 0) -> Vector2i:
	var found: int = 0
	for cell: Vector2i in game.level.ground.get_used_cells():
		if game.level.is_buildable(cell) and not game.build_controller.is_occupied(cell):
			if found == skip:
				return cell
			found += 1
	return Vector2i(-1, -1)


func _build(tower: TowerData) -> Tower:
	var cell: Vector2i = _free_cell()
	assert_true(game.build_controller.try_build(tower, cell), "se construye %s" % tower.id)
	return game.build_controller.tower_at(cell)


func _spawn(enemy_id: String) -> Enemy:
	var group := SpawnGroup.new()
	group.enemy = load("res://data/enemies/%s.tres" % enemy_id)
	group.count = 1
	var wave := WaveData.new()
	wave.groups.append(group)
	game.spawner.start_wave(wave, 1)
	simulate(game.spawner, 1, DT)
	return game.enemies.get_child(game.enemies.get_child_count() - 1)


# --- RF-317: el texto, armado desde los datos ---

func test_the_frost_names_every_tower_that_uses_the_slow() -> void:
	assert_eq(TowerText.combo_partners(frost, _all()), ["Combo: Cañón, Francotirador y Mortero +25 % a los que frena"])


func test_in_a_level_without_the_mortar_it_is_not_named() -> void:
	var level_one: Array[TowerData] = [basic, cannon, frost, sniper, fire, tesla]
	assert_eq(TowerText.combo_partners(frost, level_one), ["Combo: Cañón y Francotirador +25 % a los que frena"])


func test_the_fire_names_the_tesla() -> void:
	assert_eq(TowerText.combo_partners(fire, _all()), ["Combo: Eléctrica +30 % a los que quema"])


func test_towers_that_put_no_state_say_nothing() -> void:
	assert_eq(TowerText.combo_partners(basic, _all()), [] as Array[String])
	assert_eq(TowerText.combo_partners(cannon, _all()), [] as Array[String], "el Cañón aprovecha, no pone el estado")
	var only_frost: Array[TowerData] = [frost, basic]
	assert_eq(TowerText.combo_partners(frost, only_frost), [] as Array[String], "sin nadie que lo aproveche, nada")


func test_a_new_tower_with_a_bonus_shows_up_by_itself() -> void:
	# RF-164: no hay una lista escrita a mano; alcanza con el dato.
	var custom: TowerData = basic.duplicate(true)
	custom.id = &"custom"
	custom.display_name = "Torre de prueba"
	custom.levels[0].bonus_vs_slowed_percent = 40
	var towers: Array[TowerData] = [cannon, frost, custom]
	assert_eq(TowerText.combo_partners(frost, towers), ["Combo: Torre de prueba +40 %, Cañón +25 % a los que frena"],
		"de la más barata a la más cara, agrupadas por porcentaje")


func test_names_are_joined_in_spanish() -> void:
	assert_eq(TowerText.join_names([] as Array[String]), "")
	assert_eq(TowerText.join_names(["Cañón"] as Array[String]), "Cañón")
	assert_eq(TowerText.join_names(["Cañón", "Mortero"] as Array[String]), "Cañón y Mortero")
	assert_eq(TowerText.join_names(["A", "B", "C"] as Array[String]), "A, B y C")


func test_the_build_bar_hint_from_both_sides() -> void:
	var level_one: Array[TowerData] = [basic, cannon, frost, sniper, fire, tesla]
	assert_eq(TowerText.combo_hint(cannon, level_one), "Combo: +25 % a ralentizados.")
	assert_eq(TowerText.combo_hint(tesla, level_one), "Combo: +30 % a quemados.")
	assert_eq(TowerText.combo_hint(frost, level_one), "Combo: Cañón y Francotirador +25 % a los que frena.")
	assert_eq(TowerText.combo_hint(basic, level_one), "")


func test_the_wiki_entry_of_the_frost_names_all_the_towers() -> void:
	var text: String = JSON.stringify(Wiki.tower_entry(frost).blocks)
	assert_string_contains(text, "Combos")
	assert_string_contains(text, "Combo: Cañón, Francotirador y Mortero +25 % a los que frena")
	assert_false(JSON.stringify(Wiki.tower_entry(basic).blocks).contains("Combos"))


func test_the_effects_article_explains_combos_without_numbers() -> void:
	var entries: Array[WikiEntry] = Wiki.articles(Wiki.ARTICLES_DIR)["entries"]
	var effects: WikiEntry = null
	for entry: WikiEntry in entries:
		if entry.id == &"efectos":
			effects = entry
	assert_not_null(effects)
	var text: String = JSON.stringify(effects.blocks)
	assert_string_contains(text, "Combos")
	assert_string_contains(text, "celeste")
	assert_false(text.contains("%"), "los números viven en cada torre")


# --- RF-317 en la partida: el panel y la barra ---

func test_the_panel_of_a_built_frost_names_its_partners_in_this_level() -> void:
	_start_game()
	var tower: Tower = _build(frost)
	game.build_controller.select_placed(tower)
	var stats: String = game.hud.tower_panel._stats.text.replace(" ", " ")
	assert_string_contains(stats, "Combo: Cañón y Francotirador +25 % a los que frena")
	assert_false(stats.contains("Mortero"), "RF-300: el nivel 1 no tiene Mortero")


func test_the_build_bar_line_fits_for_every_tower() -> void:
	# La línea de la barra no hace salto: con las 9 torres (también el Mortero, RF-300) tiene que entrar.
	_start_game()
	var label: Label = game.hud._build_info_text
	var name_label: Label = game.hud._build_info_name
	var room: float = (game.hud.get_node("%BuildInfo") as Control).size.x
	var font: Font = label.get_theme_font(&"font")
	var name_font: Font = name_label.get_theme_font(&"font")
	for tower: TowerData in game.tower_types:
		var text: String = "%s %s" % [tower.description, TowerText.combo_hint(tower, game.tower_types)]
		if tower.footprint > 1:
			text += " Necesita 2×2 casillas libres."
		var width: float = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 15).x \
			+ name_font.get_string_size("%s · %d de oro" % [tower.display_name, tower.levels[0].cost], HORIZONTAL_ALIGNMENT_LEFT, -1, 17).x + 10.0
		assert_lt(width, room, "%s: la línea mide %d de %d" % [tower.id, width, room])
		assert_gt(width, 300.0, "la medición es de verdad (no da 0)")


func test_the_panel_never_splits_the_percent() -> void:
	_start_game()
	game.build_controller.select_placed(_build(frost))
	assert_string_contains(game.hud.tower_panel._stats.text, "+25 % a los que frena")


func test_the_build_bar_says_the_combo() -> void:
	_start_game()
	game.hud.show_selected_tower(game.available_towers.find(cannon))
	assert_string_ends_with(game.hud._build_info_text.text, "Combo: +25 % a ralentizados.")
	game.hud.show_selected_tower(game.available_towers.find(basic))
	assert_false(game.hud._build_info_text.text.contains("Combo"))


# --- RF-318: la marca de "vulnerable" ---

func test_the_mark_needs_the_state_and_a_tower_that_uses_it() -> void:
	_start_game()
	var enemy: Enemy = _spawn("tank")
	enemy.take_hit(1, 0.4, 5.0)  # ralentizado
	assert_false(enemy.shows_vulnerable_mark(Enemy.Combo.SLOWED), "sin una torre que lo aproveche, no")
	var tower: Tower = _build(cannon)
	assert_true(enemy.shows_vulnerable_mark(Enemy.Combo.SLOWED), "con un Cañón en el mapa, sí")
	assert_false(enemy.shows_vulnerable_mark(Enemy.Combo.BURNING), "no está quemado")
	game.build_controller.sell(tower)
	assert_false(enemy.shows_vulnerable_mark(Enemy.Combo.SLOWED), "vendido el Cañón, se va")


func test_an_enemy_without_the_state_has_no_mark() -> void:
	_start_game()
	_build(cannon)
	var enemy: Enemy = _spawn("tank")
	assert_false(enemy.shows_vulnerable_mark(Enemy.Combo.SLOWED))
	enemy.take_hit(1, 0.4, 5.0)
	assert_true(enemy.shows_vulnerable_mark(Enemy.Combo.SLOWED), "un enemigo nuevo ya sabe que hay un Cañón")


func test_the_burning_mark_needs_a_tesla() -> void:
	_start_game()
	var enemy: Enemy = _spawn("tank")
	enemy.apply_burn(8, 5.0)
	_build(cannon)
	assert_false(enemy.shows_vulnerable_mark(Enemy.Combo.BURNING), "el Cañón no aprovecha el fuego")
	_build(tesla)
	assert_true(enemy.shows_vulnerable_mark(Enemy.Combo.BURNING))


func test_the_marks_are_drawn_without_errors() -> void:
	_start_game()
	_build(cannon)
	_build(tesla)
	var enemy: Enemy = _spawn("tank")
	enemy.take_hit(1, 0.4, 5.0)
	enemy.apply_burn(8, 5.0)
	enemy.receive_aura(2, 1.0)  # con los íconos de aura en la misma fila
	await wait_frames(2)
	assert_true(enemy.shows_vulnerable_mark(Enemy.Combo.SLOWED) and enemy.shows_vulnerable_mark(Enemy.Combo.BURNING))
