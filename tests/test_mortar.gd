# Tests del Mortero, la primera torre de 2×2 (T140 y T142, spec RF-296 a RF-300).
extends GutTest

const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")

var game: Game
var mortar: TowerData


## Una partida del nivel 1 que habilita el Mortero (RF-300), como lo hará el nivel 10.
func _game_with_mortar() -> Game:
	var g: Game = GAME_SCENE.instantiate()
	var level: LevelData = GameFlow.level(0).duplicate()
	level.extra_towers = PackedStringArray(["mortar"])
	g.level_data = level
	add_child_autofree(g)
	return g


func before_each() -> void:
	game = _game_with_mortar()
	mortar = load("res://data/towers/mortar.tres")
	game.session.earn(2000)


func _free_block() -> Vector2i:
	for y: int in range(0, 8):
		for x: int in range(0, 19):
			if game.build_controller.cells_free(mortar, Vector2i(x, y)):
				return Vector2i(x, y)
	return Vector2i(-1, -1)


# --- Los datos (RF-296) ---

func test_the_mortar_has_the_numbers_of_the_spec() -> void:
	assert_eq(mortar.id, &"mortar")
	assert_eq(mortar.display_name, "Mortero")
	assert_eq(mortar.footprint, 2, "RF-290: ocupa 2×2")
	assert_false(mortar.can_hit_air, "no le pega a los voladores")
	assert_eq(mortar.projectile_speed_tiles, 6.0)
	assert_eq(mortar.levels.size(), 3)
	var costs: Array[int] = [300, 250, 350]
	var damage: Array[int] = [90, 140, 220]
	var ranges: Array[float] = [5.0, 5.0, 5.5]
	var splash: Array[float] = [1.5, 1.8, 2.2]
	for i: int in 3:
		assert_eq(mortar.levels[i].cost, costs[i], "costo del nivel %d" % (i + 1))
		assert_eq(mortar.levels[i].damage, damage[i], "daño del nivel %d" % (i + 1))
		assert_eq(mortar.levels[i].fire_rate, 0.25, "un disparo cada 4 s")
		assert_eq(mortar.levels[i].range_tiles, ranges[i], "alcance del nivel %d" % (i + 1))
		assert_eq(mortar.levels[i].splash_radius_tiles, splash[i], "área del nivel %d" % (i + 1))
		assert_not_null(mortar.levels[i].base_texture, "reusa la base del nivel %d" % (i + 1))


func test_the_mortar_has_its_own_drawings_and_sound() -> void:
	assert_not_null(mortar.turret_texture, "RF-299: torreta")
	assert_not_null(mortar.projectile_texture, "RF-299: bomba")
	assert_true(ResourceLoader.exists("res://assets/audio/shot_mortar.wav"), "suena al disparar")
	assert_ne(mortar.description, "", "RF-171")


func test_the_mortar_is_the_ninth_tower_and_the_others_stay_the_same() -> void:
	assert_eq(game.tower_types.size(), 9, "RF-297")
	assert_eq(game.tower_types[8], mortar, "tecla 9")
	assert_eq(game.tower_types[0].id, &"basic", "las ocho de antes siguen en su lugar")
	assert_eq(game.tower_types[7].id, &"tesla")


# --- La barra y la tecla 9 (RF-297) ---

func test_key_9_chooses_the_mortar() -> void:
	assert_true(InputMap.has_action("build_9"), "la acción existe")
	var event := InputEventKey.new()
	event.physical_keycode = KEY_9
	event.pressed = true
	game.build_controller._unhandled_input(event)
	assert_eq(game.build_controller.selected_tower(), mortar)


func test_the_bar_shows_the_mortar_with_its_cost_and_key() -> void:
	var button: Button = game.hud._tower_buttons[8]
	assert_eq(button.text, "300")
	assert_string_contains(button.tooltip_text, "Mortero")
	assert_string_contains(button.tooltip_text, "tecla 9")


func test_choosing_the_mortar_says_it_needs_a_square() -> void:
	game.build_controller.select(8)
	var text: String = (game.hud.get_node("%BuildInfoText") as Label).text
	assert_string_contains(text, mortar.description)
	assert_string_contains(text, "Necesita 2×2 casillas libres", "RF-298")
	game.build_controller.select(0)
	assert_false(((game.hud.get_node("%BuildInfoText") as Label).text).contains("Necesita"), "las chicas no lo dicen")


# --- En el juego (RF-291, RF-296) ---

func test_building_a_real_mortar_takes_four_cells_and_its_300_gold() -> void:
	var origin: Vector2i = _free_block()
	assert_ne(origin, Vector2i(-1, -1))
	var gold: int = game.session.gold
	assert_true(game.build_controller.try_build(mortar, origin))
	assert_eq(game.session.gold, gold - 300)
	assert_eq(game.build_controller.tower_at(origin + Vector2i(1, 1)), game.build_controller.tower_at(origin))


func test_the_mortar_needs_its_300_gold() -> void:
	var origin: Vector2i = _free_block()
	game.session.spend(game.session.gold - 299)
	assert_false(game.build_controller.try_build(mortar, origin), "con 299 no alcanza")
	assert_true(game.build_controller._level.is_buildable(origin), "la casilla sigue libre")


func test_the_mortar_fires_a_bomb_with_area_damage() -> void:
	var origin: Vector2i = _free_block()
	game.build_controller.try_build(mortar, origin)
	var tower: Tower = game.build_controller.tower_at(origin)
	var fired: Array = []
	tower.fired.connect(func(p: Projectile) -> void: fired.append(p))
	var data: EnemyData = (load("res://data/enemies/normal.tres") as EnemyData).duplicate()
	data.speed_tiles = 0.0
	var enemy: Enemy = preload("res://scenes/enemies/enemy.tscn").instantiate()
	enemy.setup(data, game.level.get_ground_path(0), 5000)
	game.add_child(enemy)
	enemy.global_position = tower.global_position + Vector2(Rules.tiles_to_px(4.0), 0)  # dentro de las 5 casillas
	tower._physics_process(1.0 / 60.0)
	assert_eq(fired.size(), 1, "dispara desde 4 casillas del centro")
	assert_eq(fired[0]._stats.damage, 90)
	assert_gt(fired[0]._stats.splash_radius_tiles, 1.0, "de área")
	enemy.queue_free()


# --- La Wiki (RF-298) ---

func test_the_wiki_writes_the_size() -> void:
	var entry: WikiEntry = Wiki.tower_entry(mortar)
	var text: String = JSON.stringify(entry.blocks)
	assert_string_contains(text, "Tamaño")
	assert_string_contains(text, "2×2 casillas")
	var basic_text: String = JSON.stringify(Wiki.tower_entry(game.tower_types[0]).blocks)
	assert_false(basic_text.contains("Tamaño"), "las de una casilla no lo dicen")


# --- Torre reservada: solo en los niveles que la habilitan (RF-300) ---

func test_a_normal_level_does_not_offer_the_mortar() -> void:
	var plain: Game = GAME_SCENE.instantiate()
	add_child_autofree(plain)
	assert_eq(plain.available_towers.size(), 8, "las ocho de siempre")
	assert_false(plain.available_towers.has(mortar))
	assert_eq(plain.hud._tower_buttons.size(), 8, "la barra no la muestra")
	assert_true(mortar.reserved)
	assert_eq(plain.tower_types.size(), 9, "existe en el juego, pero no se ofrece")


func test_a_level_that_lists_it_offers_it() -> void:
	assert_eq(game.available_towers.size(), 9)
	assert_eq(game.available_towers[8], mortar)
	assert_eq(game.hud._tower_buttons.size(), 9)


func _level_text(extra: Variant) -> String:
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/levels/level_01.json"))
	if extra != null:
		data["torres_extra"] = extra
	return JSON.stringify(data)


func test_the_level_file_reads_torres_extra() -> void:
	var result: Dictionary = LevelFile.parse(_level_text(["mortar"]), &"prueba")
	assert_eq(result["errors"].size(), 0, "sin errores")
	assert_eq((result["level"] as LevelData).extra_towers, PackedStringArray(["mortar"]))
	assert_eq((LevelFile.parse(_level_text(null), &"prueba")["level"] as LevelData).extra_towers.size(), 0, "sin la clave: ninguna")


func test_torres_extra_with_a_wrong_name_or_shape_is_an_error() -> void:
	var unknown: Dictionary = LevelFile.parse(_level_text(["bazooka"]), &"prueba")
	assert_eq(unknown["errors"].size(), 1)
	assert_string_contains(unknown["errors"][0], "bazooka")
	assert_string_contains(unknown["errors"][0], "mortar", "lista las que hay")
	var not_a_list: Dictionary = LevelFile.parse(_level_text("mortar"), &"prueba")
	assert_eq(not_a_list["errors"].size(), 1)
	assert_string_contains(not_a_list["errors"][0], "torres_extra")


func test_a_repeated_name_counts_once() -> void:
	var result: Dictionary = LevelFile.parse(_level_text(["mortar", "mortar"]), &"prueba")
	assert_eq((result["level"] as LevelData).extra_towers.size(), 1)


func test_the_editor_keeps_torres_extra() -> void:
	var draft: LevelDraft = LevelDraft.from_text(_level_text(["mortar"]), "prueba")
	var saved: String = draft.to_text()
	assert_string_contains(saved, "\"torres_extra\": [\"mortar\"]")
	assert_eq(LevelDraft.from_text(saved, "x").to_text(), saved, "guardar dos veces da el mismo texto")
	assert_false(LevelDraft.from_text(_level_text(null), "x").to_text().contains("torres_extra"), "sin la clave, no la escribe")
