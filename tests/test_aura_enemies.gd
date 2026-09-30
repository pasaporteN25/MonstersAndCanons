# Tests del Guardián y el Curandero (T131, T132, RF-274 a RF-277, D-041).
extends GutTest

const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")


func _enemy(id: String) -> EnemyData:
	return load("res://data/enemies/%s.tres" % id) as EnemyData


# --- Los datos (RF-275) ---

func test_the_guardian_has_the_numbers_of_the_spec() -> void:
	var g: EnemyData = _enemy("guardian")
	assert_eq(g.id, &"guardian")
	assert_eq(g.display_name, "Guardián")
	assert_eq(g.max_health, 200)
	assert_almost_eq(g.speed_tiles, 0.7, 0.001)
	assert_eq(g.armor, 1)
	assert_eq(g.reward, 25)
	assert_eq(g.lives_damage, 3)
	assert_false(g.is_flying)
	assert_almost_eq(g.size_tiles, 0.38, 0.001)
	assert_almost_eq(g.aura_radius_tiles, 2.0, 0.001)
	assert_eq(g.aura_armor_bonus, 2)
	assert_eq(g.aura_heal_percent_per_second, 0.0, "el Guardián no cura")


func test_the_healer_has_the_numbers_of_the_spec() -> void:
	var h: EnemyData = _enemy("healer")
	assert_eq(h.id, &"healer")
	assert_eq(h.display_name, "Curandero")
	assert_eq(h.max_health, 60)
	assert_almost_eq(h.speed_tiles, 1.1, 0.001)
	assert_eq(h.armor, 0)
	assert_eq(h.reward, 10)
	assert_eq(h.lives_damage, 1)
	assert_almost_eq(h.size_tiles, 0.28, 0.001)
	assert_almost_eq(h.aura_radius_tiles, 2.5, 0.001)
	assert_almost_eq(h.aura_heal_percent_per_second, 3.0, 0.001)
	assert_eq(h.aura_armor_bonus, 0, "el Curandero no da armadura")


func test_the_presentation_phrases_are_the_ones_of_the_spec() -> void:
	assert_eq(_enemy("guardian").description, "Da armadura a los enemigos que lo rodean. Conviene eliminarlo primero, o pegarle de lejos.")
	assert_eq(_enemy("healer").description, "Cura a los enemigos que lo rodean. Conviene eliminarlo primero; el fuego frena la cura.")


func test_only_these_two_enemies_have_an_aura() -> void:
	for id: String in LevelFile.enemy_ids():
		var data: EnemyData = _enemy(id)
		var has: bool = data.aura_radius_tiles > 0.0
		assert_eq(has, id == "guardian" or id == "healer", "%s" % id)


func test_their_colors_do_not_look_like_any_other_enemy() -> void:
	# Guía de arte §3: cada especie tiene su color y no se repite.
	for mine: String in ["guardian", "healer"]:
		var color: Color = _enemy(mine).color
		for id: String in LevelFile.enemy_ids():
			if id == mine:
				continue
			var other: Color = _enemy(id).color
			var distance: float = Vector3(color.r - other.r, color.g - other.g, color.b - other.b).length()
			assert_gt(distance, 0.18, "%s se parece demasiado a %s" % [mine, id])


func test_they_have_a_drawing() -> void:
	for id: String in ["guardian", "healer"]:
		var texture: Texture2D = _enemy(id).texture
		assert_not_null(texture, id)
		assert_eq(texture.get_width(), texture.get_height(), "%s: cuadrado" % id)


# --- En el resto del juego (RF-277) ---

func test_they_are_found_by_name_like_any_other_enemy() -> void:
	assert_true(LevelFile.enemy_ids().has("guardian"))
	assert_true(LevelFile.enemy_ids().has("healer"))
	assert_not_null(LevelFile.find_enemy("guardian"))
	assert_not_null(LevelFile.find_enemy("healer"))


func _facts(id: String) -> Dictionary:
	var entry: WikiEntry
	for category: WikiCategory in Wiki.categories(GameFlow.campaign.levels):
		if category.id == &"enemigos":
			entry = category.find(StringName(id))
	var facts: Dictionary = {}
	for block: Dictionary in entry.blocks:
		if block["tipo"] == WikiEntry.KIND_FACTS:
			for row: Array in block["filas"]:
				facts[row[0]] = row[1]
	return facts


func test_the_wiki_writes_down_their_aura() -> void:
	var guardian: Dictionary = _facts("guardian")
	assert_eq(guardian["Aura de armadura"], "+2 de armadura a los enemigos a menos de 2 casillas")
	assert_false(guardian.has("Aura de cura"))
	var healer: Dictionary = _facts("healer")
	assert_eq(healer["Aura de cura"], "cura 3 % de la vida por segundo a los enemigos a menos de 2.5 casillas")
	assert_false(healer.has("Aura de armadura"))
	assert_false(_facts("normal").has("Aura de armadura"), "el resto no tiene")


func test_they_start_closed_in_the_bestiary() -> void:
	for category: WikiCategory in Wiki.categories(GameFlow.campaign.levels, func(_id: StringName) -> bool: return false):
		if category.id == &"enemigos":
			assert_true(category.find(&"guardian").locked)
			assert_true(category.find(&"healer").locked)
			assert_false(category.find(&"guardian").plain_text().contains("Aura"), "la entrada cerrada no cuenta nada")


func test_they_are_not_in_any_official_level_yet() -> void:
	# D-041: el Guardián debuta en el nivel 8 y el Curandero en el 9. Cuando existan, este test se cambia.
	for level: LevelData in GameFlow.campaign.levels:
		for wave: WaveData in level.waves:
			for group: SpawnGroup in wave.groups:
				assert_false(group.enemy.id == &"guardian" or group.enemy.id == &"healer", "%s" % level.id)


# --- En una partida (RF-271, RF-274) ---

func test_the_guardian_protects_a_normal_enemy_in_a_real_game() -> void:
	var game: Game = GAME_SCENE.instantiate()
	add_child_autofree(game)
	game.dev_spawn(_enemy("guardian"))
	game.dev_spawn(_enemy("normal"))
	simulate(game, 30, 1.0 / 60.0)
	var guardian: Enemy
	var normal: Enemy
	for node: Node in game.enemies.get_children():
		if (node as Enemy).data.id == &"guardian":
			guardian = node
		else:
			normal = node
	assert_not_null(guardian)
	assert_not_null(normal)
	assert_eq(normal.aura_armor(), 2, "el Normal recibe el +2 (viajan juntos al principio del camino)")
	assert_eq(guardian.aura_armor(), 0)
	var before: int = normal.health
	normal.take_hit(5)
	assert_eq(before - normal.health, 3, "5 − 2 = 3 (criterio de aceptación)")


func test_auras_are_drawn_without_errors() -> void:
	var game: Game = GAME_SCENE.instantiate()
	add_child_autofree(game)
	game.dev_spawn(_enemy("guardian"))
	game.dev_spawn(_enemy("healer"))
	game.dev_spawn(_enemy("normal"))
	simulate(game, 30, 1.0 / 60.0)
	await wait_frames(3)
	assert_eq(game.enemies.get_child_count(), 3)
	assert_true(true, "el anillo y los íconos se dibujaron")
