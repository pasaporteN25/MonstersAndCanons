# T234: el Coloso y su Pedazo (RF-481 a RF-484, D-092): dos archivos de datos que usan `death_spawn` (RF-166), el
# mismo mecanismo de la Araña. Acá se prueban los números, partirse, llegar sin partirse, la armadura, la ralentización
# y las entradas de la Wiki. Dónde aparece (oleadas 26, 28 y 30) está en test_level_15.gd.
extends GutTest

const PATH: String = "user://test_colossus.json"
const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")
const ENEMY_SCENE: PackedScene = preload("res://scenes/enemies/enemy.tscn")
const DT: float = 1.0 / 60.0

var game: Game


func before_each() -> void:
	SaveManager.save_path = PATH
	SaveManager.load_save()
	GameFlow.current_index = 14
	GameFlow.intro_pending = false
	game = GAME_SCENE.instantiate()
	add_child_autofree(game)


func after_each() -> void:
	GameFlow.current_index = -1
	SaveManager.save_path = SaveManager.DEFAULT_PATH
	SaveManager.load_save()
	if FileAccess.file_exists(PATH):
		DirAccess.remove_absolute(PATH)


func _enemy_data(id: String) -> EnemyData:
	return load("res://data/enemies/%s.tres" % id)


## Una oleada de un solo grupo (`count` de `id`) por la entrada A, dada como la oleada `number` del nivel 15.
func _start_wave(id: String, count: int, number: int) -> void:
	var group := SpawnGroup.new()
	group.enemy = _enemy_data(id)
	group.count = count
	var wave := WaveData.new()
	wave.groups.append(group)
	game.session.begin_wave()
	game.spawner.start_wave(wave, number)
	simulate(game.spawner, 1, DT)


func _alive() -> Array[Enemy]:
	var list: Array[Enemy] = []
	for node: Node in game.enemies.get_children():
		if (node as Enemy).is_active():
			list.append(node as Enemy)
	return list


func _walker(data: EnemyData, health: int) -> Enemy:
	var path := Path2D.new()
	path.curve = Curve2D.new()
	path.curve.add_point(Vector2(100, 300))
	path.curve.add_point(Vector2(4100, 300))
	add_child_autofree(path)
	var enemy: Enemy = ENEMY_SCENE.instantiate()
	enemy.setup(data, path, health)
	add_child_autofree(enemy)
	return enemy


func _facts(entry: WikiEntry) -> Dictionary:
	var facts: Dictionary = {}
	for block: Dictionary in entry.blocks:
		if block["tipo"] == WikiEntry.KIND_FACTS:
			for row: Array in block["filas"]:
				facts[row[0]] = row[1]
	return facts


func _enemies_category(seen: Callable = Callable()) -> WikiCategory:
	for category: WikiCategory in Wiki.categories(GameFlow.campaign.levels, seen):
		if category.id == &"enemigos":
			return category
	return null


# --- Los datos (RF-481) ---

func test_the_colossus_has_the_numbers_of_rf_481() -> void:
	var colossus: EnemyData = _enemy_data("colossus")
	assert_eq(colossus.id, &"colossus")
	assert_eq(colossus.display_name, "Coloso")
	assert_eq(colossus.max_health, 600)
	assert_almost_eq(colossus.speed_tiles, 0.5, 0.001)
	assert_eq(colossus.armor, 5)
	assert_eq(colossus.reward, 200)
	assert_eq(colossus.lives_damage, 12)
	assert_false(colossus.is_flying)
	assert_almost_eq(colossus.slow_resistance, 0.5, 0.001)
	assert_almost_eq(colossus.size_tiles, 0.5, 0.001)
	assert_eq(colossus.death_spawn, _enemy_data("colossus_shard"))
	assert_eq(colossus.death_spawn_count, 3)
	assert_eq(colossus.description,
		"Masa de piedra lenta y muy blindada: los golpes fuertes la rompen. Al caer se parte en tres pedazos rápidos. ¡Si llega, quita 12 vidas!")


func test_the_shard_has_the_numbers_of_rf_481_and_drops_nothing() -> void:
	var shard: EnemyData = _enemy_data("colossus_shard")
	assert_eq(shard.id, &"colossus_shard")
	assert_eq(shard.display_name, "Pedazo")
	assert_eq(shard.max_health, 180)
	assert_almost_eq(shard.speed_tiles, 1.0, 0.001)
	assert_eq(shard.armor, 0)
	assert_eq(shard.reward, 30)
	assert_eq(shard.lives_damage, 4)
	assert_almost_eq(shard.slow_resistance, 0.0, 0.001)
	assert_almost_eq(shard.size_tiles, 0.3, 0.001)
	assert_null(shard.death_spawn, "el Pedazo no suelta nada")
	assert_eq(shard.death_spawn_count, 0)
	assert_eq(shard.description, "Rápido y sin armadura. El Hielo lo frena y las torres de área lo barren.")


func test_three_shards_times_four_lives_is_the_colossus_twelve() -> void:
	var colossus: EnemyData = _enemy_data("colossus")
	assert_eq(colossus.death_spawn_count * colossus.death_spawn.lives_damage, colossus.lives_damage,
		"la cuenta cierra a propósito: matarlo no sale más caro que dejarlo pasar")


func test_only_the_colossus_is_dangerous_and_the_pair_uses_provisional_art_in_place() -> void:
	assert_true(Rules.is_dangerous(_enemy_data("colossus")), "lleva la corona (RF-136)")
	assert_false(Rules.is_dangerous(_enemy_data("colossus_shard")), "el Pedazo no (4 vidas)")
	for id: String in ["colossus", "colossus_shard"]:
		var data: EnemyData = _enemy_data(id)
		assert_true(data.texture.resource_path.contains("/rendered/"), id)
		assert_not_null(data.walk_atlas, id)
		assert_false(data.flip_when_walking_left, id)


func test_every_other_enemy_keeps_its_numbers() -> void:
	# RF-483: no cambia ningún otro enemigo (los números del Soberano, el Guardián, el Curandero y el Chamán son los de hoy).
	assert_eq([_enemy_data("boss").max_health, _enemy_data("boss").armor, _enemy_data("boss").lives_damage], [300, 3, 10])
	assert_eq([_enemy_data("guardian").max_health, _enemy_data("guardian").aura_armor_bonus], [200, 2])
	assert_eq(_enemy_data("healer").max_health, 60)
	assert_eq(_enemy_data("shaman").max_health, 90)


# --- Partirse (RF-166, RF-481) ---

func test_a_colossus_that_dies_leaves_three_shards_with_the_health_of_the_wave() -> void:
	_start_wave("colossus", 1, 30)
	var colossus: Enemy = _alive()[0]
	var scale_percent: int = game.level_data.health_scale_percent_per_wave
	assert_eq(colossus.max_health, Rules.scaled_health_percent(600, 30, scale_percent), "vida de la oleada 30")
	simulate(colossus, 60, DT)
	var died_at: float = colossus.distance
	colossus.take_hit(1000000)
	var shards: Array[Enemy] = _alive()
	assert_eq(shards.size(), 3, "tres Pedazos")
	for shard: Enemy in shards:
		assert_eq(shard.data.id, &"colossus_shard")
		assert_eq(shard.max_health, Rules.scaled_health_percent(180, 30, scale_percent), "la vida de la oleada en curso")
		assert_between(shard.distance, died_at - 61.0, died_at + 0.1, "en su lugar, escalonados hacia atrás")
		assert_eq(shard.path(), colossus.path(), "siguen el mismo camino")
	var distances: Array = shards.map(func(shard: Enemy) -> float: return shard.distance)
	distances.sort()
	assert_ne(distances[0], distances[2], "escalonados, no apilados")


func test_with_the_initial_numbers_the_shard_of_wave_30_has_about_1330_health() -> void:
	# RF-481: con 22 % el Pedazo trae ≈ 1330 en la 30. Si el balance cambia el aumento de vida, esta cuenta cambia con él.
	var scale_percent: int = game.level_data.health_scale_percent_per_wave
	var expected: int = 180 * (100 + scale_percent * 29) / 100
	assert_eq(Rules.scaled_health_percent(180, 30, scale_percent), expected)
	assert_between(scale_percent, 20, 40)


func test_the_wave_does_not_end_until_the_three_shards_die() -> void:
	watch_signals(game.spawner)
	_start_wave("colossus", 1, 26)
	_alive()[0].take_hit(1000000)
	await wait_process_frames(2)  # el Coloso ya dejó el árbol
	assert_signal_not_emitted(game.spawner, "wave_finished", "quedan tres Pedazos vivos")
	var shards: Array[Enemy] = _alive()
	assert_eq(shards.size(), 3)
	shards[0].take_hit(1000000)
	shards[1].take_hit(1000000)
	await wait_process_frames(2)
	assert_signal_not_emitted(game.spawner, "wave_finished", "borde: con dos muertos y uno vivo todavía no")
	shards[2].take_hit(1000000)
	await wait_process_frames(2)
	assert_signal_emitted(game.spawner, "wave_finished", "RF-33: ahora sí")


func test_each_shard_gives_its_own_gold() -> void:
	_start_wave("colossus", 1, 30)
	var colossus: Enemy = _alive()[0]
	var before: int = game.session.gold
	colossus.take_hit(1000000)
	var after_colossus: int = game.session.gold
	assert_gt(after_colossus, before, "el Coloso da su oro")
	for shard: Enemy in _alive():
		shard.take_hit(1000000)
	assert_eq(game.session.gold - after_colossus, 3 * 30, "cada Pedazo da 30")


# --- Llegar a la salida (RF-481) ---

func test_a_colossus_that_reaches_the_exit_takes_twelve_lives_and_leaves_nothing() -> void:
	_start_wave("colossus", 1, 26)
	var colossus: Enemy = _alive()[0]
	var lives: int = game.session.lives
	colossus.distance = colossus.path().curve.get_baked_length() - 1.0
	simulate(colossus, 5, DT)
	assert_eq(game.session.lives, lives - 12, "quita sus 12 vidas")
	assert_eq(_alive().size(), 0, "no suelta ningún Pedazo: solo se parte si muere por daño")


func test_each_shard_that_reaches_the_exit_takes_four_and_three_take_twelve() -> void:
	_start_wave("colossus_shard", 3, 26)
	var lives: int = game.session.lives
	var shard_count: int = 0
	game.spawner.skip_rest_of_wave()
	for shard: Enemy in _alive():
		shard_count += 1
	assert_gte(shard_count, 1)
	var first: Enemy = _alive()[0]
	first.distance = first.path().curve.get_baked_length() - 1.0
	simulate(first, 5, DT)
	assert_eq(game.session.lives, lives - 4, "un Pedazo, 4 vidas")


# --- Armadura y ralentización (RF-482) ---

func test_armor_a_hit_of_8_does_3_to_the_colossus_1_with_the_guardian_aura_and_8_to_the_shard() -> void:
	var colossus: Enemy = _walker(_enemy_data("colossus"), 1000)
	colossus.take_hit(8)
	assert_eq(colossus.health, 1000 - 3, "8 - 5 de armadura")
	var shard: Enemy = _walker(_enemy_data("colossus_shard"), 1000)
	shard.take_hit(8)
	assert_eq(shard.health, 1000 - 8, "sin armadura")
	assert_eq(Rules.damage_after_armor(8, 5 + 2), 1, "con el aura del Guardián (+2): 7 de armadura, 1 de daño")
	assert_eq(Rules.damage_after_armor(1, 5), 1, "borde: un golpe nunca hace menos de 1")


func test_the_ice_slows_the_colossus_by_half_as_much_and_the_shard_completely() -> void:
	var colossus: Enemy = _walker(_enemy_data("colossus"), 100000)
	var shard: Enemy = _walker(_enemy_data("colossus_shard"), 100000)
	var plain: Enemy = _walker(_enemy_data("tank"), 100000)
	for enemy: Enemy in [colossus, shard, plain]:
		enemy.take_hit(0, 0.4, 3.0)
	assert_almost_eq(plain.current_speed_tiles(), plain.data.speed_tiles * 0.6, 0.001, "un enemigo común: -40 %")
	assert_almost_eq(shard.current_speed_tiles(), 1.0 * 0.6, 0.001, "el Pedazo, completo")
	assert_almost_eq(colossus.current_speed_tiles(), 0.5 * (1.0 - 0.4 * 0.5), 0.001, "el Coloso, la mitad")


# --- La Wiki (RF-484) ---

func test_the_wiki_writes_both_entries_by_itself_with_the_corona_and_the_drop() -> void:
	var enemies: WikiCategory = _enemies_category()
	var colossus: WikiEntry = enemies.find(&"colossus")
	var shard: WikiEntry = enemies.find(&"colossus_shard")
	assert_not_null(colossus)
	assert_not_null(shard)
	assert_string_contains(colossus.subtitle, "Peligroso")
	assert_false(shard.subtitle.contains("Peligroso"))
	assert_eq(_facts(colossus)["Al morir suelta"], "3 × Pedazo")
	assert_string_contains(colossus.plain_text(), "Nivel 15 · La Central")
	assert_string_contains(colossus.plain_text(), _enemy_data("colossus").description)
	assert_true(_facts(colossus).has("Resistencia a la ralentización"))
	assert_string_contains(shard.plain_text(), "Lo suelta al morir: Coloso")
	assert_false(shard.plain_text().contains("Nivel 15"), "el Pedazo no figura en ninguna oleada: solo lo suelta el Coloso")
	assert_eq(enemies.entries[enemies.entries.size() - 1].id, &"colossus", "el Coloso queda último: es el de más vida")


func test_in_a_new_save_both_entries_are_closed_until_they_are_seen() -> void:
	var seen: Array[StringName] = []
	var is_seen: Callable = func(id: StringName) -> bool: return seen.has(id)
	var enemies: WikiCategory = _enemies_category(is_seen)
	assert_true(enemies.find(&"colossus").locked)
	assert_true(enemies.find(&"colossus_shard").locked)
	assert_false(enemies.find(&"colossus").plain_text().contains("12 vidas"), "cerrada: no adelanta nada")
	seen.append(&"colossus")
	enemies = _enemies_category(is_seen)
	assert_false(enemies.find(&"colossus").locked)
	assert_true(enemies.find(&"colossus_shard").locked, "el Pedazo se abre cuando aparece")


func test_the_guide_does_not_name_the_colossus() -> void:
	# RF-484: la Guía se ve desde el primer día; nombrar al Coloso allí adelantaría el final.
	for file_name: String in DirAccess.get_files_at("res://data/wiki/"):
		if file_name.ends_with(".json"):
			var text: String = FileAccess.get_file_as_string("res://data/wiki/" + file_name).to_lower()
			assert_false(text.contains("coloso"), file_name)
